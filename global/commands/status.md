---
description: Quick status summary from the handoff record — outside the pipeline
agent: ask
---

<summary>
You MUST answer from the actual handoff files, not from memory or guesswork.
You MUST distinguish complete / partial / stopped / blocked, and call out
anything planned or specced but not yet reported as built.
You MUST NOT write anything — this is a read and summarize, not a new record.
If the human wants this to persist, tell them to use /handoff instead.
</summary>

<scope>
$ARGUMENTS
</scope>

Recent reports:
!`ls -t .opencode/handoff/3-report/*.md 2>/dev/null | head -10`

Recent specs (planned, maybe not yet built):
!`ls -t .opencode/handoff/2-spec/*.md 2>/dev/null | head -10`

Recent plans (earliest stage — may not have gone further):
!`ls -t .opencode/handoff/1-plan/*.md 2>/dev/null | head -10`

Answer the scope above against these files — a ticket ID, an epic, "this
week", "the last few slices", whatever was asked. If no scope was given,
summarize the most recent handful across all three stages.

For each stem, work out where it actually got to:

- Report exists, `Status: complete` → done, built, verified — say what was
  verified and what wasn't (check the report's own verification section
  rather than assuming green).
- Report exists, `Status: partial` or `stopped` → say what's built and what
  isn't. Don't round this up to "done".
- Spec exists, no report → planned and specced, not yet built.
- Plan exists, no spec → still in planning, not yet verified against the
  codebase.
- Spec `Status: replan` → kicked back, waiting on the human to reconsider it.

If `.opencode/workitems/` exists and the scope references a ticket ID, cross-
check its stem prefix against work items there so the status connects to the
tracker, not just the pipeline's own filenames.

End with a short list, one line per stem, stage reached, and status. This is
a summary of the record for this conversation — it is not itself a record.
