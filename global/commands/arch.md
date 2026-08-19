---
description: Stage 2 — verify a plan against the codebase and write a spec
agent: arch
---

<summary>
You MUST verify the plan named below against the real codebase and produce a
spec.
You MUST derive the canonical stem from the loaded plan's own `Stem:` header
field, not from the raw argument below — the argument is a lookup hint only,
and has previously produced corrupted filenames (e.g. `<stem>.plan.md.spec.md`)
when it already carried an extension.
You SHOULD resolve every ⚠ assumption, check the T3 floor in AGENTS.md, and
assign a tier with one sentence of reasoning.
You MUST end by writing the spec, printing its absolute path and full contents,
and stopping. You MUST NOT build.
</summary>

<plan>
@.opencode/handoff/1-plan/$ARGUMENTS.plan.md
</plan>

Available plans, if the stem above is wrong (the argument may already include
an extension, may be mistyped, or may simply not resolve — this list, and the
loaded plan's own header, are the source of truth, never the raw argument):
!`ls -t .opencode/handoff/1-plan/*.md 2>/dev/null | head -5`

Follow `.opencode/handoff/SPEC_TEMPLATE.md`. **Write target:** read the
`Stem:` value out of the plan document's own header block once it loads, and
use *that* — never concatenate a suffix onto `$ARGUMENTS` directly. Write to
`.opencode/handoff/2-spec/<stem-from-plan-header>.spec.md`. If the raw
argument and the plan's own header stem disagree, trust the header and say so
in passing — don't silently guess.

Model actually configured for this agent:
!`grep -A4 '"<agent>"[[:space:]]*:' ${OPENCODE_CONFIG:-~/.config/opencode/opencode.json} | grep '"model"' | head -1`

Delegate exploratory searching to the `explore` subagent. Read files into your
own context only when you need to read them closely.
