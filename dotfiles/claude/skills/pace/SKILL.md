---
name: pace
description: Check the 5h rate-limit budget and burn rate before fanning out sub-agents or workflows, and structure sub-agent work so nothing is lost if the window runs out. Use before spawning parallel agents, launching a workflow, or when asked how much budget is left.
---

# Pace work against the 5h rate-limit window

The window is wall-clock. The target burn is the rate that lands on the cap exactly at reset, about 20% per hour. Hooks already enforce this mechanically: every tool call is delayed when the burn is over target, spawns are spaced out, and above 98% used every call takes the maximum delay. Per-call holds stay under the prompt-cache lifetime. The one longer wait is a spawn beyond the concurrency cap, which queues for up to 30 minutes until a running agent finishes. Nothing is stopped or denied. Your job is to not fight the brake and to make the work durable.

Before a fan-out, run:

```
claude-budget
```

Read `verdict` and `delay/call`:

- `burst` or `normal` with 0s delay: fan out up to the caps. The gate holds any spawn beyond 2 fable, 4 opus, 8 sonnet running at once until one finishes, so more than that only queues.
- `conserve`: the brake is on. Run 1 to 2 agents at a time instead of many, prefer sonnet or opus over fable, and keep thinking between low and medium. More agents here only queue behind the brake.
- `pause`: the window is nearly spent, every call waits the maximum. Finish the turn with what you have. Spawn nothing.
- `unknown`: no sample yet, treat as normal.

Rules for every sub-agent you spawn:

- Give it a bounded scope: what to touch, what to produce, when it is done. Open-ended tasks are what grow contexts to 300k tokens.
- Tell it to write results to disk as it goes and to return a file path or commit, not a long message. If the window runs out, work on disk survives, work in context does not.
- Tell it what it may run. "Read-only" means read files only and run no commands, say so explicitly.
- A returning agent may report unfinished items because its context grew large (sub-agents are told to wrap up at 150k and stop at 200k tokens). Dispatch the remainder to a fresh agent. Do not ask the same agent to continue.

Rules for yourself as orchestrator:

- Keep a progress file in the scratchpad listing tasks, status and output paths. Update it after every agent returns. Resuming means reading that file, never replaying history.
- Re-run `claude-budget` before each new batch on long tasks. The verdict changes as the window fills.
- Few agents at full speed beat many agents throttled. Prompt caches go cold when calls are far apart, and a cold 300k context costs more than a fresh agent.
