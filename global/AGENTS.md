# Pipeline rules

Pipeline version: **1.1.0**

These rules apply to every agent in this pipeline, at every stage. A project's
own `AGENTS.md` adds facts — module map, critical paths, build commands — but
does not relax anything below.

---

## The pipeline

```
  /plan   →  handoff/1-plan/<stem>.plan.md      intent, assumptions, open questions
  /arch   →  handoff/2-spec/<stem>.spec.md      verified against real code, tiered
  /build  →  handoff/3-report/<stem>.report.md  what actually happened
```

There is also `ask` — a casual Q&A agent that sits **outside** this pipeline
entirely. It writes no document, follows no template, and is not bound by any
rule in this file below this point. Use `/ask` or Tab to it for a question
that isn't worth a planning session. If a question asked there turns out to
need real design thought, `ask` should say so and point back to `/plan` rather
than attempting it.

`<stem>` is `YYYY-MM-DD-<slice-name>`, identical across all three stages, so one
slice stays traceable end to end. Never rename a stem mid-flight.

Each stage runs in its own agent. You are one stage. You do not perform the
next one.

---

## Rule 1 — Stop and print

Every stage ends the same way, without exception:

1. Write the document to its directory.
2. Print the **absolute path** of the file you wrote.
3. Print the **full contents** of that file into the conversation.
4. **Stop.** Do not begin the next stage. Do not summarise and continue. Do
   not ask whether to proceed and then proceed.

The human reads the document. That reading is the only checkpoint in this
pipeline. Skipping the print is not a style problem, it removes the checkpoint.

## Rule 2 — Never claim verification you did not perform

Say "should compile", never "compiles", unless you ran the build in this
session and saw it succeed. If you did not run the test suite, say so plainly.
"Done, all green" when nothing was run is the single most damaging thing any
agent in this pipeline can write, because it silently poisons every later
stage that trusts the record.

Distinguish, always:

- **verified** — you ran it here and observed the result
- **read** — you read it in the source and are quoting ground truth
- **inferred** — you reasoned it out and it could be wrong

Mark inferred claims with ⚠. Later stages are required to check ⚠ items.

## Rule 3 — Ask before writing code

No agent edits source before the human gives an explicit go-ahead in that
session. A reviewed spec is not a go-ahead. Present what you intend to do,
then wait.

## Rule 4 — Tiers escalate, never de-escalate

The architect assigns every slice a tier:

| Tier | Meaning | Agent |
|---|---|---|
| **T1 routine** | Mechanical. Wiring, re-exports, config, renames, tests for behaviour that already exists. | `build` |
| **T2 hard** | Non-obvious. Concurrency, error taxonomy, trait or interface implementation, anything spanning modules, anything with a subtle failure mode. | `build-hard` |
| **T3 critical** | A bug here causes data loss, a security failure, an unrecoverable device state, or a compliance breach. | `build-critical` |

The project's `AGENTS.md` defines a **T3 floor**: paths and concerns that are
always T3 no matter how small the change looks. The architect may raise a
slice above its floor on judgment. The architect may **never** place a slice
below its floor, and may never split a slice specifically to route part of it
around the floor.

If a project defines no floor, treat these as T3 by default: authentication,
cryptography, key or credential handling, data migration, anything writing to
persistent storage in a way that cannot be undone, and anything handling money.

A build agent that receives a spec whose tier does not match its own tier must
refuse and tell the human which agent to switch to.

## Rule 5 — Cross-boundary contracts are named, never decided

Anything requiring agreement with a system you do not own — a wire format, an
API contract, another team's schema — gets **named** in the document and left
open. You do not resolve it. Flag it so the human can take it to whoever owns
the other side.

## Rule 6 — New dependencies are asked about, not added

Adding a dependency is a decision with a licence, a maintenance, and a supply
chain dimension. Name it, explain why it is needed, and stop.

## Rule 7 — Report every file touched

Full path from the repo root, every file added, modified, or deleted. No
exceptions, no "and some minor edits".

## Rule 8 — Context discipline

Reading a file into your own context costs money on every subsequent turn of
the session, not just the turn that read it. Before opening a large file, ask
whether a targeted question to the `explore` subagent would answer it instead.
`explore` runs on a cheap model and returns prose, so its reading is charged
once at a low rate rather than repeatedly at yours.

This matters most for `arch` and `build-critical`, which run on expensive
models. Curate what you look at.

Do not leave a session idle mid-stage. Prompt caches expire; resuming after
a long gap re-bills the whole accumulated context cold. A measured build
session paid $0.24 for a single call after a 22-minute pause — more than a
whole later slice cost end to end. If you need to ask something unrelated,
finish the stage first, or open `ask` in a separate session rather than
Tabbing out of a live one.

---

## Document headers

Every handoff document starts with this block:

```
Stem:      YYYY-MM-DD-<slice>
Stage:     plan | spec | report
Status:    <see below>
Tier:      T1 | T2 | T3 | (unset at plan stage)
Pipeline:  1.0.0
Model:     <the model that wrote this document>
```

Status values, per stage:

- **plan** — `draft`, `ready` (ready for architecture)
- **spec** — `ready` (go build), `replan` (kicked back to planning), `blocked`
- **report** — `complete`, `partial`, `stopped`, `blocked`

`Status` is how the pipeline routes. A spec marked `replan` is an input to the
planning stage, not a build instruction.

`Model` is copied verbatim from the value injected by the command. Do not
write what you believe you are — a model's self-report is not evidence, and
this field is the only one in the header that nothing downstream can check.
