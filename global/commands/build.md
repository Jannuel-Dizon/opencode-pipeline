---
description: Stage 3 — implement a spec (tier must match the current agent)
---

<summary>
You MUST check the spec's Tier header against your own tier before anything
else, and refuse if they do not match.
You SHOULD state your implementation plan and wait for an explicit go-ahead.
You MUST end by writing a report, printing its absolute path and full contents,
and stopping.
</summary>

<spec>
@.opencode/handoff/2-spec/$ARGUMENTS.spec.md
</spec>

Available specs, if the stem above is wrong:
!`ls -t .opencode/handoff/2-spec/*.md 2>/dev/null | head -5`

Working tree state before you start:
!`git status --porcelain`

Tier routing: T1 → `build`, T2 → `build-hard`, T3 → `build-critical`. If the
spec's tier is not yours, stop and tell me which agent to switch to.

If the spec's Status is `replan` or `blocked`, stop — it is not a build
instruction.
