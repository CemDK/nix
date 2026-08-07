# fzf/starship glyphs need UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================================================
# PROMPT + NAVIGATION (starship, zoxide; cd = z as in zsh)
# ============================================================================
# Returns the path of a cached init script for $exeName, regenerating it when
# the exe is newer than the cache (version upgrades). Returns $null when the
# tool is not installed. The cache is written via a per-PID temp file + rename
# so two shells starting at once (psmux warm panes) can't interleave writes.
function Get-CachedInit([string]$name, [string]$exeName, [string[]]$initArgs, [scriptblock]$postProcess) {
    $cmd = Get-Command $exeName -ErrorAction SilentlyContinue
    if (-not $cmd) { return $null }
    $cache = Join-Path $env:LOCALAPPDATA "pwsh-init-cache\$name.ps1"
    $item = Get-Item $cache -ErrorAction SilentlyContinue
    if (-not $item -or $item.LastWriteTimeUtc -lt (Get-Item $cmd.Source).LastWriteTimeUtc) {
        $null = New-Item -ItemType Directory -Force -Path (Split-Path $cache)
        $text = & $cmd.Source @initArgs | Out-String
        if ($postProcess) { $text = & $postProcess $text $cmd.Source }
        $tmp = "$cache.$PID.tmp"
        Set-Content -Path $tmp -Value $text -Encoding utf8
        Move-Item -Path $tmp -Destination $cache -Force
    }
    $cache
}

# postProcess: starship's init spawns starship.exe AGAIN at load time just to
# set the (static per config) PSReadLine continuation prompt — ~200ms every
# startup. Capture it once at cache-generation time and bake it in as a
# literal. If starship ever changes the init's shape the regex just won't
# match and the spawn comes back
$cemInit = Get-CachedInit 'starship' 'starship' @('init', 'powershell', '--print-full-init') {
    param($text, $exe)
    $cont = (& $exe prompt --continuation | Out-String).TrimEnd("`r`n")
    if ($LASTEXITCODE -eq 0 -and $cont) {
        $lit = "'" + ($cont -replace "'", "''") + "'"
        $pattern = '(?s)\(\s*Invoke-Native -Executable ''[^'']*'' -Arguments @\(\s*"prompt",\s*"--continuation"\s*\)\s*\)'
        $text = [regex]::Replace($text, $pattern, $lit.Replace('$', '$$'))
    }
    $text
}
if ($cemInit) { . $cemInit }
$cemInit = Get-CachedInit 'zoxide' 'zoxide' @('init', 'powershell')
if ($cemInit) {
    . $cemInit
    Set-Alias -Name cd -Value z -Option AllScope -Force
}
Remove-Variable cemInit

# ============================================================================
# PSREADLINE (history, suggestions, keybindings)
# ============================================================================
Set-PSReadLineOption -PredictionSource History
# Ghost text: the default is a fixed 256-palette gray
# bright black defers to the active scheme instead.
Set-PSReadLineOption -Colors @{ InlinePrediction = "$([char]27)[90m" }
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -MaximumHistoryCount 100000

# Same ignore list as zsh history.ignorePatterns
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $line.Trim() -notmatch '^(cd( .*)?|clear|pwd|ls.*|l|la|ll|lla|lt|exit|vi|vif|vim|nv|nvim|nvime)$'
}

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key Ctrl+z -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key Ctrl+p -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Ctrl+n -Function HistorySearchForward

# ============================================================================
# FZF env
# ============================================================================
$env:FZF_DEFAULT_COMMAND = 'rg --files --follow --hidden --glob "!.git/*"'
$env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
$env:FZF_DEFAULT_OPTS = @(
    '--preview-window=up,70%'
    '--bind ctrl-/:toggle-preview'
    '--color=fg:#93a1a1,hl:#268bd2,fg+:#c5c8c6,bg+:#005F60,hl+:#8ec07c'
    '--color=info:#2aa198,prompt:#f78104,pointer:#f78104,marker:#f78104'
    '--color=spinner:#f78104,header:#268bd2,border:#005F60'
) -join ' '

# ============================================================================
# DEFERRED MODULES (PSFzf)
# ============================================================================
$null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    if (-not (Get-Module -ListAvailable -Name PSFzf)) {
        Write-Host "profile: installing PSFzf from PSGallery..."
        Install-Module PSFzf -Scope CurrentUser -Force
    }
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        Import-Module PSFzf -Global
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }
}

# ============================================================================
# ALIASES (from modules/home/zsh/aliases.nix)
# ============================================================================
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat -Option AllScope -Force
}

if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza --git --group-directories-first --header @args }
    function ll { eza -l --git --group-directories-first --header @args }
    function lla { eza -la --git --group-directories-first --header @args }
    function l { ll @args }
    function la { lla @args }
    function lt { ll --tree --git-ignore @args }
}

foreach ($a in 'v', 'iv', 'vmi', 'nvi', 'nvimi') { Set-Alias -Name $a -Value nvim }
Set-Alias -Name lg -Value lazygit

# nv is a built-in alias for New-Variable, and aliases outrank functions.
Remove-Item Alias:nv -Force -ErrorAction SilentlyContinue
function nv { neovide --frame=none @args }

