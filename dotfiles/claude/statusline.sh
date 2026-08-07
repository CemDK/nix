#!/usr/bin/env bash
# Custom Claude Code status line.
#
# Layout: one table. A header row spanning the full width (model, cwd, branch,
# context, diff, spend), then a 2x2 grid of meters — each a label, a progress
# bar, a percentage and a context-specific value:
#
#   ┌───┬──────────────────┬───────────────┬────────┬──────────────┬───────┬────────────────┐
#   │ I │ Opus 5 [1m] high │ ~/.config/nix │ ⎇ main │ 122.4k (12%) │ +0 -0 │ session $47.30 │
#   ├───┴──────────────────┴───────────────┴────┬───┴──────────────┴───────┴────────────────┤
#   │ ctx  ━━──────────────────  12%     122.4k │ 5h   ━━━━━━━─────────────  34%    (21:48) │
#   │ cost ━━━━━━━━━───────────  47%     $94.60 │ 7d   ━───────────────────   3% (Sa 07:38) │
#   └───────────────────────────────────────────┴───────────────────────────────────────────┘
export LC_ALL=C.UTF-8

input=$(cat)

model=$(jq -r '.model.display_name // "Claude"' <<<"$input")
model=$(sed -E 's/\(([0-9]+)M context\)/[\1m]/I; s/\(([0-9]+)K context\)/[\1k]/I' <<<"$model")
cwd=$(jq -r '.workspace.current_dir // .cwd' <<<"$input")
dir="${cwd/#$HOME/\~}"

read -r in_tok out_tok ctx_pct <<<"$(jq -r '[
  (.context_window.total_input_tokens // 0),
  (.context_window.total_output_tokens // 0),
  (.context_window.used_percentage // 0)
] | join(" ")' <<<"$input")"

tokens=$((in_tok + out_tok))
if (( tokens >= 1000 )); then
  tok_fmt=$(awk -v t="$tokens" 'BEGIN{printf "%.1fk", t/1000}')
else
  tok_fmt="$tokens"
fi
ctx_int=$(printf '%.0f' "$ctx_pct")

DIM=$'\033[2m'
BOLD=$'\033[1m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
CYAN=$'\033[36m'
RED=$'\033[31m'
MAGENTA=$'\033[35m'
FG="$YELLOW"
RESET=$'\033[0m'
SEP="${DIM} │ ${RESET}"     # column divider between header fields

BAR_W=12                      # cells in a meter's progress bar
BAR_FULL='━'
BAR_EMPTY='─'
# The table grows to fit the header (which carries the full cwd) up to this
# width; past it the cwd is elided instead. Generous on purpose — a long path
# is worth more than a narrow box.
MAX_W="${CLAUDE_STATUSLINE_MAX_W:-120}"
# Daily spend the cost meter fills up against. Override per-machine by
# exporting CLAUDE_DAILY_GOAL before Claude Code starts.
DAILY_GOAL="${CLAUDE_DAILY_GOAL:-100}"

# Where daily cost tallies live: $COST_STATE/<YYYY-MM-DD>/<session_id>, one
# file per session holding what that session spent on that day.
COST_STATE="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline/cost"
COST_KEEP_DAYS=7

# Drop day buckets older than $COST_KEEP_DAYS, plus anything not shaped like a
# date (e.g. buckets written by an older layout of this script).
prune_cost_state() {
  local cutoff d name
  cutoff=$(date -d "$COST_KEEP_DAYS days ago" +%F) || return 0
  for d in "$COST_STATE"/*; do
    [[ -d "$d" ]] || continue
    name=${d##*/}
    if [[ "$name" != [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ]]; then
      rm -rf "$d"
    elif [[ "$name" < "$cutoff" ]]; then
      rm -rf "$d"
    fi
  done
}

# Format a float as USD.
usd() { awk -v c="$1" 'BEGIN{printf "$%.2f", c}'; }

# Printable width of a string, ignoring ANSI escapes.
vis() { local s; s=$(sed 's/\x1b\[[0-9;]*m//g' <<<"$1"); printf '%s' "${#s}"; }

# Pad a (possibly colored) string with spaces out to a visible width.
padto() {
  local n=$(( $2 - $(vis "$1") ))
  (( n < 0 )) && n=0
  printf '%s%*s' "$1" "$n" ''
}

# rule WIDTH [INDEX:GLYPH ...] -> a horizontal rule of WIDTH cells, with GLYPH
# substituted at each 0-based INDEX. The indices are where column dividers
# meet the rule, so they become tees.
rule() {
  local w=$1 s i; shift
  local -a c=()
  for ((i = 0; i < w; i++)); do c[i]='─'; done
  for s in "$@"; do
    i=${s%%:*}
    (( i >= 0 && i < w )) && c[i]=${s#*:}
  done
  local IFS=''
  printf '%s' "${c[*]}"
}

# Each meter carries its own thresholds, because "how full is too full" differs
# per meter: a rate limit is fine until it nears the cap, context wants warning
# far earlier than that, and a spend budget runs the other way entirely.
#
#   WARN/CRIT   direction   meaning
#   75 / 90     normal      rate limits — green until the cap is in sight
#   15 / 25     normal      context — red early; headroom matters before compaction
#   30 / 70     inverted    cost — a target to reach, so red means barely used
#   80 / 101    normal      pace — projected end-of-window usage, see pace_color
ZONE_LIMIT="75 90"
ZONE_CTX="15 25"
ZONE_COST="30 70 invert"
ZONE_PACE="80 101"       # 101, not 100: landing exactly on the cap is on pace

RANK_COLOR=("$GREEN" "$YELLOW" "$RED")

# rank PCT "WARN CRIT [invert]" -> 0 fine / 1 warn / 2 critical
rank() {
  local warn crit inv
  read -r warn crit inv <<<"$2"
  if [[ -n "$inv" ]]; then
    if   (( $1 >= crit )); then printf 0
    elif (( $1 >= warn )); then printf 1
    else printf 2; fi
  else
    if   (( $1 >= crit )); then printf 2
    elif (( $1 >= warn )); then printf 1
    else printf 0; fi
  fi
}

# zone PCT "WARN CRIT [invert]" -> the color for that reading
zone() { printf '%s' "${RANK_COLOR[$(rank "$1" "$2")]}"; }

# A rate-limit window is judged on pace as much as on fill: spending it evenly
# is fine, spending it faster than it refills is not. Extrapolating the burn so
# far to the moment the window resets,
#
#   projected = used% ÷ fraction of the window elapsed
#
# 100 means landing exactly on the cap and anything above it means running out
# early. For the 5h window an even burn is the 20%/h the cap implies; the same
# arithmetic covers the 7d window without naming its (much slower) rate.
#
# Early in a window the projection is noise — one turn against two elapsed
# minutes reads as an enormous rate — so pace only counts once enough of the
# window has passed. Fill and pace are both judged; the worse one wins.
PACE_MIN_ELAPSED=10           # % of the window that must pass before pace counts

# pace_color PCT RESETS_AT WINDOW_SECS -> color
pace_color() {
  local r p at=${2%%.*} elapsed
  r=$(rank "$1" "$ZONE_LIMIT")
  if [[ "$at" =~ ^[0-9]+$ ]] && (( $3 > 0 )); then
    elapsed=$(( 100 - 100 * (at - $(date +%s)) / $3 ))
    (( elapsed > 100 )) && elapsed=100
    if (( elapsed >= PACE_MIN_ELAPSED )); then
      p=$(rank $(( 100 * $1 / elapsed )) "$ZONE_PACE")
      (( p > r )) && r=$p
    fi
  fi
  printf '%s' "${RANK_COLOR[$r]}"
}

# bar PCT WIDTH COLOR -> progress bar, filled portion in COLOR.
bar() {
  local pct=$1 w=$2 n i out=""
  (( pct > 100 )) && pct=100
  n=$(( (pct * w + 50) / 100 ))
  (( pct > 0 && n == 0 )) && n=1          # never round a live meter down to empty
  for ((i=0; i<w; i++)); do
    (( i < n )) && out+="$BAR_FULL" || out+="$BAR_EMPTY"
  done
  printf '%s%s%s%s%s' "$3" "${out:0:n}" "$DIM" "${out:n}" "$RESET"
}

# The non-bar parts of a cell: "ctx " + " " + " 12%" + " " + value.
CELL_FIXED=11

# cell LABEL PCT VALUE BARW VALW COLOR -> "ctx  ━───────────  12% 44.3k"
# The value is right-aligned in its column so the grid reads as two clean
# edges: labels and bars flush left, percentages and values flush right.
cell() {
  printf '%s%-4s%s %s %s%3d%%%s %s%*s%s' \
    "$DIM" "$1" "$RESET" "$(bar "$2" "$4" "$6")" \
    "$6" "$2" "$RESET" "$DIM" "$5" "$3" "$RESET"
}

# ── header row ────────────────────────────────────────────────────────────
# Built in two halves around the directory: the grid below fixes the table
# width, so the directory is the piece that gets shortened to fit rather than
# the piece that stretches the table.
head_pre=""
head_post=""

# VIM mode: N (normal) / I (insert)
vim=$(jq -r '.vim.mode // empty' <<<"$input")
if [[ -n "$vim" ]]; then
  [[ "$vim" == "NORMAL" ]] && vim_tag="${BLUE}N" || vim_tag="${MAGENTA}I"
  head_pre+="${BOLD}${vim_tag}${RESET}${SEP}"
fi

# MODEL + EFFORT
head_pre+="${BOLD}${FG}${model}${RESET}"
effort=$(jq -r '.effort.level // empty' <<<"$input")
[[ -n "$effort" ]] && head_pre+=" ${BLUE}${effort}${RESET}"

# AGENT NAME (only when a subagent drives the session)
agent=$(jq -r '.agent.name // empty' <<<"$input")
[[ -n "$agent" ]] && head_pre+="${SEP}(${agent})"

head_pre+="$SEP"      # DIRECTORY goes here, sized at layout time

# BRANCH. ⎇ is East-Asian-Ambiguous, so a terminal that draws it double-width
# shifts this cell's divider (and the tees above and below it) one cell left,
# since the layout math counts characters. Harmless in practice — swap it for
# a plain "git" label if a font ever gets it wrong.
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
[[ -n "$branch" ]] && head_post+="${SEP}${CYAN}⎇ ${branch}${RESET}"

# CONTEXT, inline — "44.3k (12%)". Duplicates the ctx meter in the grid below
# on purpose: the numeric form is the one that reads at a glance until the bar
# becomes familiar. Drop this block to go bar-only.
ctx_col=$(zone "$ctx_int" "$ZONE_CTX")
head_post+="${SEP}${ctx_col}${tok_fmt}${RESET} (${ctx_col}${ctx_int}%${RESET})"

# LINES changed
read -r added removed <<<"$(jq -r '[
  (.cost.total_lines_added // 0),
  (.cost.total_lines_removed // 0)
] | join(" ")' <<<"$input")"
head_post+="${SEP}${GREEN}+${added}${RESET} ${RED}-${removed}${RESET}"

# ── cost: today's spend across every concurrent session, plus this session ──
# Claude Code >= 2.1.211 resets .cost.total_cost_usd to $0 whenever /clear
# starts a new session, so bank each session's figure in today's bucket and sum
# them. One file per session id means concurrent sessions never collide.
cost=$(jq -r '.cost.total_cost_usd // empty' <<<"$input")
today_cost=""
if [[ -n "$cost" ]]; then
  today_cost="$cost"
  session=$(jq -r '.session_id // empty' <<<"$input")
  if [[ -n "$session" ]]; then
    tally="$COST_STATE/$(date +%F)"
    if [[ ! -f "$tally/$session" ]]; then
      mkdir -p "$tally" && prune_cost_state
      # A session already banked on an earlier day is mid-flight across
      # midnight: its running total is mostly yesterday's, so offset it and
      # count only what it spends from here on.
      base=0
      compgen -G "$COST_STATE/*/$session" >/dev/null && base="$cost"
      printf '%s\n' "$base" >"$tally/.base-$session"
    fi
    base=$(cat "$tally/.base-$session" 2>/dev/null) || base=0
    awk -v c="$cost" -v b="${base:-0}" \
      'BEGIN{d=c-b; printf "%.6f\n", (d>0 ? d : 0)}' >"$tally/$session"
    # Plain * skips the dot-prefixed .base-* offsets.
    today_cost=$(cat "$tally"/* 2>/dev/null | awk '{s+=$1} END{printf "%.6f", s}')
  fi
  head_post+="${SEP}${DIM}session${RESET} $(usd "$cost")"
fi

# ── the four meters ───────────────────────────────────────────────────────
# Collected as data, not rendered text: the bar width isn't known until the
# table has been sized, so that the bars can absorb any slack a long header
# leaves behind.
lab=(); pct=(); val=(); col=()

# 5H rate limit — value is the reset clock time.
usage=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
if [[ -n "$usage" ]]; then
  resets_at=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
  reset_fmt=""
  if [[ -n "$resets_at" ]]; then
    reset_fmt=$(date -d "@${resets_at}" +%H:%M 2>/dev/null)
    [[ -n "$reset_fmt" ]] && reset_fmt="(${reset_fmt})"
  fi
  lab[0]=5h; pct[0]=$(printf '%.0f' "$usage"); val[0]="$reset_fmt"
  col[0]=$(pace_color "${pct[0]}" "$resets_at" $((5 * 3600)))
fi

# CONTEXT window — value is the token count. Always drawn: a session that has
# not had its first turn yet reports no context, and an empty meter reads
# better than a hole in the grid.
lab[1]=ctx; pct[1]=$ctx_int; val[1]="$tok_fmt"; col[1]="$ctx_col"

# 7D rate limit. The weekly window can reset days out, so name the day
# ("Mo 10:00") rather than the bare clock time used for the 5h window.
usage7=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
if [[ -n "$usage7" ]]; then
  resets7_at=$(jq -r '.rate_limits.seven_day.resets_at // empty' <<<"$input")
  reset7_fmt=""
  if [[ -n "$resets7_at" ]]; then
    reset7_fmt=$(date -d "@${resets7_at}" +'%a %H:%M' 2>/dev/null)
    # Trim the locale's 3-letter abbreviation to 2 chars: "Mon" -> "Mo".
    [[ -n "$reset7_fmt" ]] && reset7_fmt="(${reset7_fmt/#???/${reset7_fmt:0:2}})"
  fi
  lab[2]=7d; pct[2]=$(printf '%.0f' "$usage7"); val[2]="$reset7_fmt"
  col[2]=$(pace_color "${pct[2]}" "$resets7_at" $((7 * 24 * 3600)))
fi

# COST — today's spend as a fraction of $DAILY_GOAL. Inverted zone: this is a
# budget to use up, not a ceiling to avoid.
if [[ -n "$today_cost" ]]; then
  lab[3]=cost
  pct[3]=$(awk -v c="$today_cost" -v g="$DAILY_GOAL" \
    'BEGIN{printf "%.0f", (g > 0 ? 100*c/g : 0)}')
  val[3]="$(usd "$today_cost")"
  col[3]=$(zone "${pct[3]}" "$ZONE_COST")
fi

# ── frame it ──────────────────────────────────────────────────────────────
# Meters sit at fixed grid positions (ctx│5h above cost│7d), but any of them
# can be absent — a plan without rate limits, a session before the first
# turn. Rather than leave holes, drop an empty row outright and fall back to a
# single column when one side is entirely missing.
here() { [[ -n "${lab[$1]:-}" ]]; }
lcol=(1 3)                                    # ctx, cost
rcol=(0 2)                                    # 5h, 7d
if ! here "${lcol[0]}" && ! here "${lcol[1]}"; then
  lcol=("${rcol[@]}"); rcol=()
elif ! here "${rcol[0]}" && ! here "${rcol[1]}"; then
  rcol=()
fi
two_col=$(( ${#rcol[@]} > 0 ))
have_grid=0
here "${lcol[0]}" || here "${lcol[1]}" && have_grid=1

cols=$(( two_col ? 2 : 1 ))
grid_total() { printf '%s' $(( ($1 + 2) * cols + cols - 1 )); }

# Values share a common column width so every bar starts and ends at the same
# column; everything else in a cell is fixed, so the cell width is just
# $CELL_FIXED + value width + however wide the bars end up.
vw=0
for i in "${lcol[@]}" "${rcol[@]}"; do
  here "$i" && (( ${#val[$i]} > vw )) && vw=${#val[$i]}
done
barw=$BAR_W
cw=$(( CELL_FIXED + vw + barw ))

# A header wider than the natural grid stretches the table (up to $MAX_W) —
# and the slack goes into the bars rather than into trailing whitespace.
want=$(( $(vis "$head_pre") + ${#dir} + $(vis "$head_post") + 2 ))
max=$(( MAX_W < $(grid_total $cw) ? $(grid_total $cw) : MAX_W ))
(( want > max )) && want=$max
while (( $(grid_total $cw) < want )); do cw=$(( cw + 1 )); done

# Fit the directory into whatever the rest of the header leaves, dropping
# leading path components: ~/src/a/b/c -> …/b/c.
total=$(grid_total $cw)
budget=$(( total - 2 - $(vis "$head_pre") - $(vis "$head_post") ))
IFS='/' read -ra parts <<<"$dir"
short="$dir"
for (( i = 1; ${#short} > budget && i < ${#parts[@]}; i++ )); do
  short="…/$(IFS=/; printf '%s' "${parts[*]:i}")"
done
# Still over (a single very long component): clip it head-first.
if (( ${#short} > budget && budget > 1 )); then
  short="…${short: -$(( budget - 1 ))}"
fi
head="${head_pre}${short}${head_post}"

# A very long branch or agent name can still overflow; widen rather than clip.
head_w=$(vis "$head")
while (( head_w + 2 > $(grid_total $cw) )); do cw=$(( cw + 1 )); done

inner=$(( cw + 2 ))
total=$(grid_total $cw)
barw=$(( cw - CELL_FIXED - vw ))

# render_cell INDEX -> a full-width cell, or blank space if that meter is absent
render_cell() {
  if here "$1"; then
    cell "${lab[$1]}" "${pct[$1]}" "${val[$1]}" "$barw" "$vw" "${col[$1]}"
  else
    printf '%*s' "$cw" ''
  fi
}

# row N -> the Nth row of the grid
row() {
  if (( two_col )); then
    printf '%s│%s %s %s│%s %s %s│%s\n' "$DIM" "$RESET" \
      "$(padto "$(render_cell "${lcol[$1]}")" $cw)" "$DIM" "$RESET" \
      "$(padto "$(render_cell "${rcol[$1]}")" $cw)" "$DIM" "$RESET"
  else
    printf '%s│%s %s %s│%s\n' "$DIM" "$RESET" \
      "$(padto "$(render_cell "${lcol[$1]}")" $cw)" "$DIM" "$RESET"
  fi
}

# The header's field dividers are carried into the rules above and below, so
# the header reads as a row of columns rather than one long line: a ┬ under
# each divider on the top border, a ┴ over it on the rule beneath. Their
# positions are read back off the rendered header — after the directory has
# been fitted, that string is the only thing that knows where they landed.
# A divider at index i in $head sits one cell further along the rule, since
# the row opens with "│ " before the header content begins.
down=(); up=()
plain=$(sed 's/\x1b\[[0-9;]*m//g' <<<"$head")
for (( i = 0; i < ${#plain}; i++ )); do
  [[ "${plain:i:1}" == "│" ]] || continue
  down+=( "$((i + 1)):┬" )
  up+=( "$((i + 1)):┴" )
done

printf '%s┌%s┐%s\n' "$DIM" "$(rule $total "${down[@]}")" "$RESET"
printf '%s│%s %s %s│%s\n' "$DIM" "$RESET" "$(padto "$head" $(( total - 2 )))" "$DIM" "$RESET"
# No meters yet (very first render): just close the header box.
if (( ! have_grid )); then
  printf '%s└%s┘%s\n' "$DIM" "$(rule $total "${up[@]}")" "$RESET"
  exit 0
fi
# The rule under the header closes the header's columns (┴) and opens the
# grid's (┬). When a header divider lands exactly on the grid divider — a
# matter of how long the directory happens to be — the line runs through the
# rule in both directions, so that junction is a ┼.
if (( two_col )); then
  split='┬'
  for s in "${up[@]}"; do [[ ${s%%:*} == "$inner" ]] && split='┼'; done
  printf '%s├%s┤%s\n' "$DIM" "$(rule $total "${up[@]}" "$inner:$split")" "$RESET"
else
  printf '%s├%s┤%s\n' "$DIM" "$(rule $total "${up[@]}")" "$RESET"
fi
for n in 0 1; do
  here "${lcol[$n]}" || { (( two_col )) && here "${rcol[$n]}"; } || continue
  row "$n"
done
if (( two_col )); then
  printf '%s└%s┘%s\n' "$DIM" "$(rule $total "$inner:┴")" "$RESET"
else
  printf '%s└%s┘%s\n' "$DIM" "$(rule $total)" "$RESET"
fi
