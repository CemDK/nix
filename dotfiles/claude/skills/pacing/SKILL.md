---
name: pacing
description: Switch rate-limit pacing on or off. Off lasts until the current 5h window resets.
argument-hint: "[on|off]"
disable-model-invocation: true
allowed-tools: Bash(~/.local/scripts/claude-budget:*)
---

!`~/.local/scripts/claude-budget --pacing $ARGUMENTS`

The line above is the result of switching pacing. Relay it to the user in one line and do nothing else.
