# Changelog

Each entry notes whether the change is safe to pull automatically (pure
process — prompts, commands, templates) or needs a manual look at each
project's filled `opencode.jsonc` / `AGENTS.md` (structural — new agents,
changed defaults, changed permission shape).

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
