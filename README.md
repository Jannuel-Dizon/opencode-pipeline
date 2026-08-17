# opencode-pipeline

A three-stage development pipeline for OpenCode: **plan → architecture →
build**, with a markdown document at every seam and a hard stop between stages.
Plus `ask`, a fourth agent that sits outside the pipeline for quick questions.

Version **1.1.0**.

## What it is for

Different stages of building software want different things from a model.
Planning wants a good conversational partner and produces almost no context.
Architecture wants the whole codebase in view and is expensive because of it.
Building wants to follow instructions accurately and gets run the most often.

Using one model for all three either overpays for the cheap stages or
underpowers the expensive ones. This splits them into separate agents with
separate models, and puts a document the human actually reads at each handoff.

```
  /plan   →  handoff/1-plan/<stem>.plan.md      intent, assumptions, open questions
  /arch   →  handoff/2-spec/<stem>.spec.md      verified against code, tiered
  /build  →  handoff/3-report/<stem>.report.md  what actually happened
```

`<stem>` is `YYYY-MM-DD-<slice>` and stays identical across all three, so a
slice is traceable end to end and the history stays readable months later.

## Quick start

**Recommended — clone it, don't copy it.** This is what makes future updates
a plain `git pull` instead of re-running `cp` on every device and project
every time something changes.

```sh
# 1. Clone once per device, wherever you keep local repos
git clone <your-fork-url> ~/dev/opencode-pipeline
cd ~/dev/opencode-pipeline

# 2. Process layer, once per device
./scripts/install-global.sh
# Symlinks ~/.config/opencode/{opencode.jsonc,AGENTS.md,prompts,commands,templates}
# into this clone. Backs up anything already there. Creates
# ~/.config/opencode/local-overrides.jsonc for personal tweaks that
# `git pull` will never touch — it prints an OPENCODE_CONFIG export line
# to add to your shell rc file; do that once.

# 3. Project layer, once per repo
cd /path/to/your/repo
mkdir -p .opencode
cp ./project/AGENTS.md.example path/to/your/repo/.opencode/AGENTS.md
# optional — only if this repo needs different models or tighter permissions:
cp ./project/opencode.jsonc.example path/to/this/repo/.opencode/opencode.jsonc

# then, from that same clone:
./scripts/link-project.sh /path/to/your/repo
# Symlinks just the three handoff templates — pure process, safe to
# auto-update. Leaves opencode.jsonc and AGENTS.md as real files, since
# those hold this project's actual facts.

# 4. Fill in .opencode/AGENTS.md — especially the T3 floor
# 5. Start OpenCode, run /init once, then /map to generate .opencode/MAP.md
```

From here, updating any device is:

```sh
cd ~/dev/opencode-pipeline && git pull
```

See [Updating across devices and projects](#updating-across-devices-and-projects)
below for what does and doesn't update automatically.

**No git, or just trying it once?** Skip the clone and use plain copies
instead — you'll just be back to manual `cp` on every future update:

```sh
cp -r global/* ~/.config/opencode/
cd /path/to/your/repo
mkdir -p .opencode
cp -r /path/to/opencode-pipeline/project/handoff .opencode/
cp /path/to/opencode-pipeline/project/AGENTS.md.example .opencode/AGENTS.md
cp /path/to/opencode-pipeline/project/opencode.jsonc.example .opencode/opencode.jsonc   # optional
```

Then, either way: `/plan <what you want>` → read the doc → `/arch <stem>` →
read the doc → Tab to the agent the tier names → `/build <stem>` →
`/handoff <stem>`.

`/ask <question>` works from any tab, any time, for something not worth
interrupting that flow for.

## The agents

| Agent | Stage | Default model | Can it edit source? |
|---|---|---|---|
| `plan` | 1 | Claude Sonnet 5 | No — only `handoff/1-plan/` |
| `arch` | 2 | Claude Opus 5 | No — only `handoff/2-spec/` |
| `build` | 3 · T1 | DeepSeek V4 Flash | Yes, on approval |
| `build-hard` | 3 · T2 | DeepSeek V4 Pro | Yes, on approval |
| `build-critical` | 3 · T3 | Claude Opus 5 | Yes, per-edit approval |
| `explore` | subagent | DeepSeek V4 Flash | No — read-only |
| `ask` | outside the pipeline | DeepSeek V4 Flash **(free)** | No — read-only |

Tab switches between primary agents. Models are OpenCode Zen ids; swap them for
any provider by editing the `model` field.

**On `ask` defaulting to the free tier:** OpenCode Zen's free models carry a
data-retention caveat the paid tier doesn't — submitted content may be used to
improve the model. `ask` defaults there because it's read-only, low-stakes,
and produces no artifact. `build` deliberately does **not** default to the
free tier for the same reason in reverse: it edits real files in a real repo,
and on proprietary code the zero-retention guarantee of the paid tier is
usually worth the extra fraction of a cent per slice. Decide this per project,
not by leaving the default unexamined.

## Two design choices worth understanding

### The planner cannot read implementation bodies

Deliberate. A planner that reads the current implementation starts designing
the next slice to resemble it, and stops designing. It can read manifests,
docs, public entry points (`lib.rs`, `mod.rs`, `index.ts`, `__init__.py`) and
the whole handoff history — enough to know what exists, not enough to be
anchored by how it works.

It does not produce a list of things for the architect to grep. It produces
**assumptions and open questions**; the architect owns retrieval strategy and
decides how to verify them. That division is the point.

`grep` is denied for the planner as well as `read`, because grep returns
content lines and would otherwise be a way around the restriction. `glob` is
allowed — it returns paths only.

If this is too tight for a given project, loosen it in the project layer. Be
aware of what you are trading away.

### Tiers escalate but never de-escalate

The architect assigns T1, T2, or T3 to every slice and states why in one
sentence. The project's `AGENTS.md` defines a **T3 floor** — paths and concerns
that are always critical no matter how small the diff. The architect can raise
a slice above its floor on judgment; it cannot lower one below, and it cannot
split a slice so part of it escapes.

Build agents check the tier in the spec header before doing anything and refuse
work that is not theirs. `build-critical` requires per-edit approval, a binding
file list, and a written adversarial pass before any code is written.

**Fill in the T3 floor yourself.** `/init` deliberately leaves it as
TODO. An agent guessing at what is safety-critical in your project defeats the
purpose of having a floor at all.

## The stop-and-print rule

Every stage ends by writing its document, printing the absolute path, printing
the full contents, and halting. No stage advances to the next on its own.

This is the load-bearing rule. When planning and building lived in separate
tools, the tool boundary forced you to read each document. In one TUI it is
easy to Tab straight through without reading anything, and then the handoff
documents become an audit trail nobody audits. The pause is the only checkpoint
in the pipeline.

## Global and project layers

**Global** (`~/.config/opencode/`) is process: agent prompts, tier definitions,
commands, templates. Project-agnostic, applies to every repo on your machine.

**Project** (`.opencode/`) is facts: module map, T3 floor, check commands,
conventions, cross-boundary contracts, model overrides.

Config merges global → project, with project winning per key. That is fine for
settings but ambiguous for agent definitions, so:

> **If a repo's `opencode.json` defines agents at all, it defines all six.**

Partial overrides give you one agent name with two definitions and no clear
signal about which one ran. Repos that do not need overrides should simply not
have an `agent` block, and inherit global wholesale.

Every handoff document stamps `Pipeline: <version>` in its header. When a
document from six months ago reads strangely, that line tells you which process
version produced it.

## Cost

Cost is context size × turns, not how often you invoke an agent. The planner is
the most-used stage and among the cheapest, because it never loads source. The
architect is the expensive one because it does.

The levers, in order of effect:

1. **Scope the architect.** Give it a slice and a file list, not "look at the
   repo".
2. **Use `explore`.** It reads on a cheap model and returns prose. A file the
   architect pulls into its own context is re-billed on every subsequent turn
   of that session; a question delegated to `explore` is billed once, cheaply.
3. **Keep `MAP.md` short.** Under 200 lines. The planner reads it every
   session.
4. **Keep T3 narrow.** Narrow scope is simultaneously the safety property and
   the cost control.

Do not route work through the free-tier models on a project you care about.
Several providers' free tiers reserve the right to train on submitted data.

## Files

```
global/                         → ~/.config/opencode/
  opencode.json                 seven agents: models and permissions
  AGENTS.md                     rules that apply to every stage
  prompts/                      one system prompt per agent
  commands/                     /plan /arch /build /handoff /map /init /ask
  templates/                    the three handoff templates
project/                        → <repo>/.opencode/
  opencode.jsonc.example        placeholder-marked, only if you need overrides
  AGENTS.md.example             module map + T3 floor skeleton
  handoff/                      templates and the three stage directories
scripts/
  install-global.sh             one-time per-device setup: symlinks global/ in
  link-project.sh               one-time per-project setup: symlinks handoff templates
```

**On file extensions:** `.jsonc` (not `.json`) throughout this template,
specifically so real comments (`// like this`) are safe to use. A JSON object
key literally named `"//"` is *not* a comment in either format — it's a real
property name, and OpenCode's `permission` schema validates every key inside
a `permission` block strictly, so a `"//"` key there fails to load. Don't
reintroduce that pattern; use `.jsonc` and a real `//` comment line instead.

## Updating across devices and projects

Setup is covered in [Quick start](#quick-start) above — this section is just
the mechanics of what happens on a version bump, once that's done.

### What updates automatically vs. what needs a manual pass

| File | Updates on `git pull`? |
|---|---|
| Global `opencode.jsonc`, `AGENTS.md`, `prompts/`, `commands/`, `templates/` | Yes — pure process |
| Project handoff templates (`*_TEMPLATE.md`) | Yes — pure process |
| Project `opencode.jsonc` (the filled instance) | No — has to hold real facts, edit by hand |
| Project `AGENTS.md` (the filled instance) | No — same reason |

A version bump that only touches prompts, commands, or templates needs zero
action from you beyond the `git pull`. A version bump that changes something
structural in `opencode.json` itself — a new agent, a changed permission
default — is worth a quick look at what changed and a manual decision about
whether to port it into each project's filled config. The `CHANGELOG.md` in
this repo (start one if you haven't) is the right place to flag which kind of
change a release is, so you're not diffing blind.

### On other machines

The same clone-and-link steps apply to any machine — laptop, work desktop,
wherever. Each device needs its own clone and its own one-time
`install-global.sh` run, but after that, `git pull` on that device's clone is
the entire update procedure, same as any other machine tracking the same repo.

## Adapting it

Written with a Rust workspace in mind, but nothing is Rust-specific except some
default glob patterns. To port it, change three things in the project layer:

1. **Planner read globs** — deny your source extensions, allow your public
   entry points.
2. **Check and build commands** in `AGENTS.md` and the build agents' bash
   permissions.
3. **The T3 floor** — what is unrecoverable in *this* system.
