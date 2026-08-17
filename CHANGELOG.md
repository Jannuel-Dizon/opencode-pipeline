# Changelog

Each entry notes whether the change is safe to pull automatically (pure
process — prompts, commands, templates) or needs a manual look at each
project's filled `opencode.jsonc` / `AGENTS.md` (structural — new agents,
changed defaults, changed permission shape).

## 1.6.2

**Safe to pull.** Prompt, command, and template changes only — no agent,
model, or permission changes.

Follows a real before/after measurement of two comparable slices
(2026-08-17 facade core/verify at $3.48, facade hal/envelope at $0.22),
per the framework's own "measure it on real tasks" requirement.

- `Model:` is now injected from config rather than self-reported. The
  core/verify report stamped `claude-sonnet-5`; billing shows the build ran
  entirely on `deepseek-v4-pro`. Self-report is not evidence.
- `plan` prompt: ⚠ is the stage's only marker. The cheap planner asserted
  nine of ten assumptions as `[read]` fact, one of which was wrong and
  self-contradicting, leaving `arch` no prioritised work list.
- `arch` prompt: minimum of three `explore` queries and an explicit
  unverified-claims pass before writing. The frontier arch's visible
  advantage was turn count (9 vs 5), which is buyable at current prices.
- No retiering. `build-hard` on Flash did the same work as Pro — 50 vs 41
  calls, 5.3M vs 4.5M cumulative input — at a tenth the cost, with no
  quality drop detectable in the reports.

## 1.6.1

Changed the arch agent from deepseek v4 flash to gpt 5.6 luna

## 1.6.0

**Manual step required** if your project pins its own models: this changes
a default model assignment. Projects with an `agent` block in their own
`opencode.jsonc` keep whatever they already pin — update those by hand.

- **`arch` moves from DeepSeek V4 Pro to DeepSeek V4 Flash.** This is a
  retiering decision, not a benchmark chase: DeepSeek's officially retrained
  V4-Flash (shipped July 31, 2026) now matches or beats V4-Pro-Preview on
  every agent benchmark DeepSeek publishes — Terminal-Bench 2.1 82.7 vs 72.1,
  DeepSWE 54.4 vs 7.3 — while costing roughly a third as much. `arch` was
  already identified in 1.5.0 as the single largest cost driver in a
  plan→arch→build pass, so this is the same lever pulled one step further.
- **Caveat, stated plainly because it matters for a decision this size:**
  the DeepSeek numbers above are vendor-self-reported under DeepSeek's own
  harness, which was not independently reproducible at time of writing.
  Separately, an independent re-run on the contamination-resistant DeepSWE
  benchmark put V4-Pro's pass@1 at 8%, far below its 80.6% vendor-reported
  SWE-bench Verified score — a reminder that the whole V4 family's published
  numbers deserve real skepticism, not just Pro's. This move is a deliberate
  bet that Flash's own trajectory (cheaper, and no longer behind Pro on
  DeepSeek's own suite) is worth taking, not a claim that arch's output
  quality has been independently verified against the old default. Treat the
  first several `arch` sessions after upgrading the way any tier change
  should be treated — read the specs it produces closely, the way Rule 1
  (stop and print) already asks you to.
- `explore` and `build-hard` stay on DeepSeek V4 Flash — unchanged, already
  the cheapest paid tier that clears the bar for those roles.
- `ask`, `plan`, and `build` stay on DeepSeek V4 Flash Free — unchanged.
  These roles either can't see implementation code (`plan`) or are read-only
  / mechanical by design, so the free tier's data-retention caveat and lower
  ceiling aren't costing anything real here.
- `build-critical` stays on Claude Opus 5 — unchanged, and not up for
  retiering on cost grounds. It's the rarest, narrowest agent by design, so
  it contributes little to the bill regardless of model, on the one tier
  where a wrong answer is a bricked device or a security hole rather than a
  failed build.
- **Considered and deliberately not adopted this round:** several other Zen
  models surfaced as candidates — Poolside's Laguna S 2.1 (free tier;
  vendor claims Terminal-Bench 2.1 and SWE-Bench Pro parity with DeepSeek V4
  Flash at a fraction of the parameter count) and NVIDIA's Nemotron 3 Ultra
  (free tier; published architecture paper, not just a launch blog) both
  looked promising enough to name here. Neither has been run against real
  slices in this pipeline yet. The project decision for this release is to
  consolidate on DeepSeek across the pipeline rather than diversify vendors
  further; revisit Laguna/Nemotron for `arch` and `build-hard` in a future
  release once they've been benchmarked against actual specs and reports,
  not just vendor tables.

## 1.5.1

**Safe to pull.** Prompt-only fix — no agent, permission, or model changes.

- **Fixed:** `/handoff` had no agent guard, unlike every other stage-bound
  command. In practice the permission system already prevents `plan`, `arch`,
  or `ask` from actually writing to `3-report/` — each is scoped to its own
  directory or, for `ask`, denied edit outright — so no fabricated report
  could ever land on disk. But without a guard, running `/handoff` from the
  wrong agent meant composing a full report, hitting a silent write denial,
  and possibly printing the fabricated content into chat as if it had saved.
  `/handoff` now checks it's running as `build`, `build-hard`, or
  `build-critical` before doing anything, and refuses with a redirect
  otherwise — same self-check pattern `/build` already uses for tier
  matching, applied to agent identity instead.

## 1.5.0

**Manual step required** if your project pins its own models: this changes
default model assignments. Projects with an `agent` block in their own
`opencode.jsonc` keep whatever they already pin — update those by hand.

Cost-driven retiering after a real measurement: one plan→arch→build-hard pass
came in at ~$3.50, with `arch` on a frontier model reading the codebase
accounting for most of it.

| Agent | Was | Now |
|---|---|---|
| `plan` | Claude Sonnet 5 | DeepSeek V4 Flash |
| `arch` | Claude Opus 5 | DeepSeek V4 Pro |
| `build` (T1) | DeepSeek V4 Flash | DeepSeek V4 Flash Free |
| `build-hard` (T2) | DeepSeek V4 Pro | DeepSeek V4 Flash |
| `build-critical` (T3) | Claude Opus 5 | **unchanged** |

- `build-critical` deliberately stays on Opus 5. It is the rarest agent and
  the narrowest by design (binding file list, per-edit approval), so its
  context stays small and it contributes little to the bill — downgrading it
  saves cents per slice on the one tier where a wrong answer is a bricked
  device rather than a failed build.
- README gained a note that DeepSeek V4 Flash/Pro are half price outside peak
  hours (01:00–04:00 and 06:00–10:00 UTC), which for UTC+8 lands squarely on
  the working day.
- README gained an explicit free-tier retention note: free models may use
  submitted data to improve the model, unlike the rest of Zen.

## 1.4.0

**Safe to pull.** New command, prompt update — no agent or permission
changes. `ask` already had `read: "*": "allow"`, so nothing needed unlocking;
the gap was that its prompt never told it to look at the handoff record.

- `ask`'s prompt now explicitly covers status questions — "what's been done
  on E1", "summarize the last few reports" — and is told to actually read
  `3-report/`, `2-spec/`, and `.opencode/workitems/` rather than answer from
  whatever's already in context.
- Added a hard line: **`ask` summarizes the record, it never becomes the
  record.** A status answer exists for that conversation only. If it should
  persist, the prompt now redirects to `/handoff` — real reports are written
  by `build`, not improvised in a Q&A reply. Without this, a convenient
  status summary could quietly become a second, informal decision record
  that contradicts or duplicates the real one.
- Added `/status [scope]`, bound to `ask`. Reads recent files across all
  three handoff stages and reports where each stem actually got to —
  distinguishing `complete` from `partial`/`stopped`, and flagging anything
  planned or specced but never reported as built, rather than rounding
  everything mentioned up to "done".

## 1.3.1

**Safe to pull.** Bug fix in the ingester — no agent, permission, or template
changes.

- **Fixed:** rerunning `ingest-workitems.py` never deleted item files for
  tickets removed from the source. `WORKITEMS.md` would stop listing a
  finished/removed ticket, but its `items/<ID>.md` stayed on disk untracked
  by anything — a silent orphan. Reruns now remove stale item files, so
  add / update / finish / remove are all reflected correctly.
- **Added a safety check for the fix above:** if a run would remove ≥5 items
  *and* ≥40% of what's currently on disk, it refuses and prints the list
  instead of deleting, since that pattern is far more often a `--from-*` flag
  left off a multi-source command than that many tickets actually vanishing.
  Nothing is written in that case — index and `items/` are left exactly as
  they were. Confirm with `--force-prune` if the removal is real.
- The index and `items/` directory now always update together or not at all
  — the mass-removal check runs before either file is touched, so a blocked
  run can never leave them disagreeing with each other.

## 1.3.0

**Safe to pull.** Script-only — no agent, permission, or template changes.

- `scripts/ingest-workitems.py` gained `--from-csv`: CSV/TSV files or a
  published Google Sheets URL. Handles a `Level` column (EPIC/STORY/TASK) or
  infers depth from ID dash-count; folds each task's parent story — including
  its user story — into the generated item file under a new **Why — parent
  story** section, since task titles alone usually lack the actual intent.
- **Multiple sources can now be combined in one run.** First non-empty value
  per field wins, in the order sources are given; every item file records
  which source(s) it came from.
- Added `--id-column` for boards where the identifier isn't under a column
  literally named ID (common on kanban grids) — falls back to scanning row
  values against `--id-pattern` when no column is given.
- Header matching is now fuzzy (case/spacing/punctuation-insensitive) with
  common field aliases built in, so mildly different exports from project to
  project don't need per-project script changes.

## 1.2.0

**Safe to pull.** No agent or permission changes — one new command and one
new script.

- Added `scripts/ingest-workitems.py`: converts a task source into a canonical
  `.opencode/workitems/` tree (compact `WORKITEMS.md` index plus per-item
  detail files). Two sources so far: `--from-html` for shared HTML breakdowns,
  `--from-appflowy` for AppFlowy Cloud database rows. Adding a source means
  writing one function; nothing downstream changes.
- Added `/tickets` command, bound to the `ask` agent — browse and filter work
  items to decide what to work on. Deliberately cannot plan or switch agents:
  delegation stays a human decision.
- Item files compute a **Blocks** section by inverting the dependency graph,
  which most trackers do not show.


## 1.1.0

**Manual look recommended** if you have existing projects on 1.0.0 — a new
agent was added to the global config shape.

- Added `ask`: a fourth agent outside the plan → arch → build pipeline, for
  quick questions that aren't worth a planning session. No handoff document,
  no template, no tier. Defaults to `deepseek-v4-flash-free` since it's
  read-only and produces no artifact.
- Added `/ask` command, callable from any tab.
- Renamed `/init-pipeline` to `/init`. Output now explicitly tells you to run
  `/map` next.
- Fixed: `project/opencode.json.example` had `"//"` keys inside `permission`
  blocks that fail OpenCode's schema validation. Converted to `.jsonc` with
  real `//` comments.
- Added `scripts/install-global.sh` and `scripts/link-project.sh` for
  symlink-based updates across devices and projects.

## 1.0.0

Initial release. `plan` → `arch` → `build`/`build-hard`/`build-critical`,
tiered by criticality, with a stop-and-print handoff document at every seam.
