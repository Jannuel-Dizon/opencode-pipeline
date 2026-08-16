---
description: Set up the handoff pipeline in this repo (safe on new or existing repos)
agent: arch
---

<summary>
You MUST create the handoff directory structure in this repository and report
what you created.
You SHOULD NOT overwrite anything that already exists — this command is safe
to run on a repo that already has a `.opencode/` directory. Skip any file that
is already present rather than touching it.
You MUST print a summary and stop.
</summary>

Current state:
!`ls -la .opencode/ 2>/dev/null || echo "no .opencode directory"`

Create, only where missing:

```
.opencode/handoff/1-plan/
.opencode/handoff/2-spec/
.opencode/handoff/3-report/
.opencode/handoff/PLAN_TEMPLATE.md
.opencode/handoff/SPEC_TEMPLATE.md
.opencode/handoff/REPORT_TEMPLATE.md
```

Copy the three templates from `~/.config/opencode/templates/`. Add a
`.gitkeep` to each empty directory.

Then draft `.opencode/AGENTS.md` from what you can observe about this project,
and **leave the T3 floor section marked TODO** — that list is a human decision
about what is safety- or security-critical here, and guessing at it defeats the
purpose of having a floor.

Report what you created, what you skipped because it already existed, and what
the human still needs to fill in.

**Next step, always:** tell the human to run `/map` now to generate the
initial `.opencode/MAP.md`, and to rerun it after any structural change from
here on — `/init` sets the pipeline up once; `/map` is what keeps it accurate.
