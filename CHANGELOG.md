# Changelog

Each entry notes whether the change is safe to pull automatically (pure
process — prompts, commands, templates) or needs a manual look at each
project's filled `opencode.jsonc` / `AGENTS.md` (structural — new agents,
changed defaults, changed permission shape).

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
