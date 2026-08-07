#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-$(hostname -s)}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$DIR/$HOST/winget.yaml"

if [ ! -f "$CONFIG" ]; then
    echo "error: no winget config for host '$HOST' ($CONFIG)" >&2
    exit 1
fi

# winget.exe can't read the WSL filesystem, so stage the config in Windows temp.
WIN_TEMP="$(powershell.exe -NoProfile -Command 'Write-Host -NoNewline $env:TEMP' 2>/dev/null | tr -d '\r')"
cp "$CONFIG" "$(wslpath "$WIN_TEMP")/winget-config.yaml"

echo "Applying $CONFIG via winget configure..."
powershell.exe -NoProfile -Command \
    "winget configure --file \"$WIN_TEMP\\winget-config.yaml\" --accept-configuration-agreements"

# ----------------------------------------------------------------------
# PowerShell profile stub + shared starship config
# ----------------------------------------------------------------------
# The real profile stays in the repo and is dot-sourced live over
# \\wsl.localhost, so edits here apply without re-running this script.
WIN_HOME="$(powershell.exe -NoProfile -Command 'Write-Host -NoNewline $env:USERPROFILE' 2>/dev/null | tr -d '\r')"
WIN_HOME_WSL="$(wslpath "$WIN_HOME")"
REPO_PROFILE_WIN="$(wslpath -w "$DIR/../../dotfiles/powershell/profile.ps1")"

mkdir -p "$WIN_HOME_WSL/.config"
cp "$DIR/../../dotfiles/starship/starship-windows.toml" "$WIN_HOME_WSL/.config/starship.toml"

# psmux config (tmux mirror). Copied, not live-sourced: psmux reads it from
# the Windows filesystem at server start; <prefix> r reloads after redeploy.
mkdir -p "$WIN_HOME_WSL/.config/psmux"
cp "$DIR/../../dotfiles/psmux/psmux.conf" "$WIN_HOME_WSL/.config/psmux/psmux.conf"

mkdir -p "$WIN_HOME_WSL/Documents/PowerShell"
# Load via scriptblock, not dot-source: RemoteSigned treats \\wsl.localhost as
# a remote location and refuses the unsigned .ps1, but not in-memory content.
cat > "$WIN_HOME_WSL/Documents/PowerShell/Microsoft.PowerShell_profile.ps1" <<EOF
# Managed by ~/.config/nix on WSL (make windows) — edit dotfiles/powershell/profile.ps1 there.
\$CemProfile = '$REPO_PROFILE_WIN'
if (Test-Path \$CemProfile) { . ([scriptblock]::Create((Get-Content -Raw \$CemProfile))) }
EOF
echo "Deployed PowerShell profile stub and starship.toml to $WIN_HOME"

# Claude Code: shared statusline + Windows-specific settings (no tmux/sound
# hooks; statusline runs via Git Bash, jq comes from winget).
mkdir -p "$WIN_HOME_WSL/.claude"
cp "$DIR/../../dotfiles/claude/statusline.sh" "$WIN_HOME_WSL/.claude/statusline.sh"
cp "$DIR/../../dotfiles/claude/settings.windows.json" "$WIN_HOME_WSL/.claude/settings.json"
echo "Deployed Claude Code statusline + settings"
