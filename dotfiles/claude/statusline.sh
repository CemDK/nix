#!/usr/bin/env bash
# Custom Claude Code status line: default-style info + 5h rate-limit usage.
input=$(cat)

model=$(jq -r '.model.display_name // "Claude"' <<<"$input")
model=$(sed -E 's/\(([0-9]+)M context\)/[\1m]/I; s/\(([0-9]+)K context\)/[\1k]/I' <<<"$model")
cwd=$(jq -r '.workspace.current_dir // .cwd' <<<"$input")
dir="${cwd/#$HOME/\~}"

read -r in_tok out_tok ctx_pct <<<"$(jq -r '[
  (.context_window.total_input_tokens // 0),
  (.context_window.total_output_tokens // 0),
  (.context_window.used_percentage // "-")
] | join(" ")' <<<"$input")"

tokens=$((in_tok + out_tok))
if (( tokens >= 1000 )); then
  tok_fmt=$(awk -v t="$tokens" 'BEGIN{printf "%.1fk", t/1000}')
else
  tok_fmt="$tokens"
fi

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
SEP="${DIM} │ ${RESET}"

# Color escape for a rate-limit usage percentage (green < 75, yellow 75-89, red >= 90).
usage_zone() {
  if (( $1 >= 90 )); then printf '%s' "$RED"
  elif (( $1 >= 75 )); then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"; fi
}

line=""

# VIM mode: -N- (normal) / -I- (insert)
vim=$(jq -r '.vim.mode // empty' <<<"$input")
if [[ -n "$vim" ]]; then
  [[ "$vim" == "NORMAL" ]] && vim_tag="${BLUE}N" || vim_tag="${MAGENTA}I"
  line+="${BOLD}${vim_tag}${RESET}"
fi

# MODEL
[[ -n "$line" ]] && line+="$SEP"
line+="${BOLD}${FG}${model}${RESET}"

# AGENT NAME (only when a subagent drives the session)
agent=$(jq -r '.agent.name // empty' <<<"$input")
[[ -n "$agent" ]] && line+="${SEP}(${agent})"

# EFFORT
effort=$(jq -r '.effort.level // empty' <<<"$input")
[[ -n "$effort" ]] && line+="${SEP}effort: ${BLUE}${effort}${RESET}"

# DIRECTORY
line+="${SEP}${dir}"

# BRANCH
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
[[ -n "$branch" ]] && line+="${SEP}${CYAN}⎇ ${branch}${RESET}"

# TOKENS
if [[ "$ctx_pct" != "-" ]]; then
  ctx_int=$(printf '%.0f' "$ctx_pct")
  if (( ctx_int >= 25 )); then
    tok_color="$RED"
  elif (( ctx_int >= 15 )); then
    tok_color="$YELLOW"
  else
    tok_color="$GREEN"
  fi
  ctx="${tok_color}${tok_fmt}${RESET} (${tok_color}${ctx_int}%${RESET})"
else
  ctx="${tok_fmt}"
fi
line+="${SEP}${ctx}"

# COST
cost=$(jq -r '.cost.total_cost_usd // empty' <<<"$input")
[[ -n "$cost" ]] && line+="${SEP}$(awk -v c="$cost" 'BEGIN{printf "$%.2f", c}')"

# 5H rate-limit usage
usage=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
if [[ -n "$usage" ]]; then
  usage_int=$(printf '%.0f' "$usage")
  line+="${SEP}5h: $(usage_zone "$usage_int")${usage_int}%${RESET}"
  resets_at=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
  if [[ -n "$resets_at" ]]; then
    reset_fmt=$(date -d "@${resets_at}" +%H:%M 2>/dev/null)
    [[ -n "$reset_fmt" ]] && line+=" ${DIM}(${reset_fmt})${RESET}"
  fi
fi

# 7D rate-limit usage
usage7=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
if [[ -n "$usage7" ]]; then
  usage7_int=$(printf '%.0f' "$usage7")
  line+="${SEP}7d: $(usage_zone "$usage7_int")${usage7_int}%${RESET}"
fi

# LINES changed (appended at end)
read -r added removed <<<"$(jq -r '[
  (.cost.total_lines_added // 0),
  (.cost.total_lines_removed // 0)
] | join(" ")' <<<"$input")"
line+="${SEP}${GREEN}+${added}${RESET} ${RED}-${removed}${RESET}"

# Frame the status line in a rounded box. The borders are derived from the
# line's visible text (ANSI escapes stripped, padded like the middle row):
# every column becomes ─, except separator columns, which join the frame
# as ┬ (top) and ┴ (bottom).
plain=" $(sed 's/\x1b\[[0-9;]*m//g' <<<"$line") "
top=$(sed 's/[^│]/─/g; s/│/┬/g' <<<"$plain")
bottom=$(sed 's/[^│]/─/g; s/│/┴/g' <<<"$plain")

printf '%s╭%s╮%s\n' "$DIM" "$top" "$RESET"
printf '%s│%s %s %s│%s\n' "$DIM" "$RESET" "$line" "$DIM" "$RESET"
printf '%s╰%s╯%s\n' "$DIM" "$bottom" "$RESET"
