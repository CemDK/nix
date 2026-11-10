---
name: pace
description: Check the 5h rate-limit budget and burn rate before fanning out sub-agents or workflows, and structure sub-agent work so nothing is lost if the window runs out. Use before spawning parallel agents, launching a workflow, or when asked how much budget is left.
---

# Pace work against the 5h rate-limit window

The window is wall-clock. The target burn is the rate that lands on the cap exactly at reset, about 20% per hour. Hooks already enforce this mechanically: every tool call is delayed when the burn is over target, and above 98% used every call takes the maximum delay. Per-call holds stay under the prompt-cache lifetime. Spawning an agent is not delayed for pace. The one wait on a spawn is at the concurrency cap, which is held for up to 5 minutes until a running agent finishes. The only thing denied is a spawn at the hard maximum. Your job is to not fight the brake and to make the work durable.

Before a fan-out, run:

```
claude-budget
```

Read `verdict` and `delay/call`:

- `burst` or `normal` with 0s delay: fan out up to the caps: 2 fable, 4 opus, 8 sonnet, 16 haiku running at once, counted across all sessions. A spawn at the cap is held until one finishes; after 5 minutes it goes through anyway, up to a hard maximum of 3 fable, 6 opus, 12 sonnet, 24 haiku, where the gate denies it. Plan for the cap, not the maximum.
- `conserve`: the brake is on. Run 1 to 2 agents at a time instead of many, prefer sonnet or opus over fable, and keep thinking between low and medium. More agents here only queue behind the brake.
- `pause`: the window is nearly spent, every call waits the maximum. Finish the turn with what you have. Spawn nothing.
- `unknown`: no sample yet, treat as normal.

Rules for every sub-agent you spawn:

- Give it a bounded scope: what to touch, what to produce, when it is done. Open-ended tasks are what grow contexts to 300k tokens.
- Tell it to write results to disk as it goes and to return a file path or commit, not a long message. If the window runs out, work on disk survives, work in context does not. Agent types without Write/Edit (Explore, Plan) and agents you made read-only cannot do this: keep their scope small enough that the returned message is the result, or use a general-purpose agent when the output must persist.
- Tell it what it may run. "Read-only" means read files only and run no commands, say so explicitly.
- A returning agent may report unfinished items because its context grew large (sub-agents are told to wrap up at 250k and stop at 300k tokens). Dispatch the remainder to a fresh agent. Do not ask the same agent to continue.

Rules for yourself as orchestrator:

- Keep a progress file in the scratchpad listing tasks, status and output paths. Update it after every agent returns. Resuming means reading that file, never replaying history.
- Re-run `claude-budget` before each new batch on long tasks. The verdict changes as the window fills.
- Few agents at full speed beat many agents throttled. Prompt caches go cold when calls are far apart, and a cold 300k context costs more than a fresh agent.
