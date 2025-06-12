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

  gssh() {
    # Select project
    local project=$(gcloud projects list | tail -n +2 | awk '{print $1}' | fzf)

    local instance_zone=$(gcloud compute instances list --project="$project" | fzf)

    local instance=$(echo "$instance_zone" | awk '{print $1}')
    local zone=$(echo "$instance_zone" | awk '{print $2}')

    # SSH into the instance
    gcloud compute ssh "$instance" --zone="$zone" --project="$project"
  }

  gacp() {
    if [ -z "$1" ]; then
        echo "Error: Please provide a commit message"
        echo "Usage: gacp \"commit message\""
        return 1
    fi
    git add .
    git commit -m "$1"
    git push
  }

  colors() {
    for i in {0..255}; do  printf "\x1b[38;5;''${i}mcolor%-5i\x1b[0m" $i ; if ! (( ($i + 1 ) % 8 )); then echo ; fi ; done
  }

  fs(){
    # if in wsl linux then execute else don't
    if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
      powershell.exe -command '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("{F11}")' > /dev/null 2>&1
      powershell.exe -command '$wshell = New-Object -ComObject Shell.Application; $wshell.minimizeall()' > /dev/null 2>&1
    fi
  }

  explain() {
    local query="$*"
    if [ -z "$query" ]; then
      echo "Usage: explain <query>"
      return 1
    fi

    gh copilot explain "$query"
  }

  neovide() {
    if [[ $(uname -r) == *WSL* ]]; then
      (neovide.exe --frame=none --wsl &)
    else
      (neovide --frame=none &)
    fi
  }
''
