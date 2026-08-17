---
description: Stage 2 — verify a plan against the codebase and write a spec
agent: arch
---

<summary>
You MUST verify the plan named below against the real codebase and produce a
spec.
You SHOULD resolve every ⚠ assumption, check the T3 floor in AGENTS.md, and
assign a tier with one sentence of reasoning.
You MUST end by writing the spec, printing its absolute path and full contents,
and stopping. You MUST NOT build.
</summary>

<plan>
@.opencode/handoff/1-plan/$ARGUMENTS.plan.md
</plan>

Available plans, if the stem above is wrong:
!`ls -t .opencode/handoff/1-plan/*.md 2>/dev/null | head -5`

Follow `.opencode/handoff/SPEC_TEMPLATE.md`. Write to
`.opencode/handoff/2-spec/$ARGUMENTS.spec.md`.

Model actually configured for this agent:
!`grep -A4 '"<agent>"[[:space:]]*:' ${OPENCODE_CONFIG:-~/.config/opencode/opencode.json} | grep '"model"' | head -1`

Delegate exploratory searching to the `explore` subagent. Read files into your
own context only when you need to read them closely.
