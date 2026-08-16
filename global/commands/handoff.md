---
description: Write the change report for the slice just built
---

<summary>
You MUST write a change report for the work completed in this session.
You SHOULD record every file touched with its full path, and be exact about
what was and was not actually run.
You MUST print the report's absolute path and full contents, then stop.
</summary>

<stem>
$ARGUMENTS
</stem>

Follow `.opencode/handoff/REPORT_TEMPLATE.md`. Write to
`.opencode/handoff/3-report/$ARGUMENTS.report.md`.

Files changed in the working tree:
!`git status --porcelain`

Diff summary:
!`git diff --stat`

Cross-check that list against your own account of what you edited. If they
disagree, the git output is right and your memory is wrong — say so in the
report.

Weight the report toward §3 (divergences), §4 (spec claims that were wrong),
and §5 (decisions you made). Those are the sections the next planning session
reads. Do not record anything as verified that you did not run in this session.
