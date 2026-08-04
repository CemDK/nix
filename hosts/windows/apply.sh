#!/usr/bin/env bash
# Apply the declarative winget configuration for the Windows host backing this
# WSL instance. Run from WSL: `make windows` (or ./hosts/windows/apply.sh [host]).
# Expect UAC prompts on the Windows side for machine-scope installers.
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
