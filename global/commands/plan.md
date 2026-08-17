---
description: Stage 1 — design a slice with the planning agent
agent: plan
---

<summary>
You MUST run the planning stage for the slice described below.
You SHOULD read `.opencode/handoff/PLAN_TEMPLATE.md` and the most recent
documents in `.opencode/handoff/3-report/` before responding.
You MUST end by writing the plan, printing its absolute path and full contents,
and stopping.
</summary>

<slice>
$ARGUMENTS
</slice>

Today's date: !`date +%Y-%m-%d`

Recent reports (context for what already exists):
!`ls -t .opencode/handoff/3-report/*.md 2>/dev/null | head -3`

Open items from the last report:
!`ls -t .opencode/handoff/3-report/*.md 2>/dev/null | head -1 | xargs -r sed -n '/## 7. Still open/,/## 8./p'`

Model actually configured for this agent:
!`grep -A4 '"<agent>"[[:space:]]*:' ${OPENCODE_CONFIG:-~/.config/opencode/opencode.json} | grep '"model"' | head -1`

Start by discussing the slice with me. Do not write the document until I say
the plan is settled.
