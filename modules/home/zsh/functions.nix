{ pkgs, lib }:
''
  _fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
  }

  _fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
  }

  fdd() {
    DIR=$(find . -type d -not -path "*/\.*" -not -path "*/node_modules/*" \
    -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/.next/*" \
    -mindepth 1 -maxdepth 8 2> /dev/null | sed 's|^\./||' | fzf-tmux) \
    && [ -n "$DIR" ] && cd "$DIR"
  }

  colors() {
    for i in {0..255}; do  printf "\x1b[38;5;''${i}mcolor%-5i\x1b[0m" $i ; if ! (( ($i + 1 ) % 8 )); then echo ; fi ; done
  }

  explain() {
    local query="$*"
    if [ -z "$query" ]; then
      echo "Usage: explain <query>"
      return 1
    fi
    gh copilot explain "$query"
  }

  grabfiles() {
    [ -n "$1" ] || { echo "usage: grabfiles <app>" >&2; return 1; }
    mkdir -p ./"$1" && \
    rsync -avz \
      cem-server@omv.local:/home/cem-server/DockerApps/"$1"/ \
      ./"$1" \
  }

  cld() {
    local tools="Agent,AskUserQuestion,Bash,Edit,Glob,Grep,ListAgents,NotebookEdit,Read,ReportFindings,Skill,TodoWrite,ToolSearch,Workflow,Write,CronCreate,CronDelete,CronList,EndConversation,EnterPlanMode,ExitPlanMode,EnterWorktree,ExitWorktree,Monitor,PushNotification,RemoteTrigger,SendMessage,TaskOutput,TaskStop,WebFetch,WebSearch"
    command claude --tools "$tools" "$@"
  }
''
+ lib.optionalString pkgs.stdenv.isLinux ''
  nv() {
    if [[ $(uname -r) == *WSL* ]]; then
      (neovide.exe --frame=none --wsl &)
    else
      neovide --fork --frame=none
    fi
  }
''
+ lib.optionalString pkgs.stdenv.isDarwin ''
  nv() {
    neovide --fork --frame=none
  }
''
