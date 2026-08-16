#!/usr/bin/env bash
# link-project.sh <path-to-project>
#
# Run once per project, per device. Links the three handoff templates
# inside <project>/.opencode/handoff/ to this cloned repo's copies, so
# `git pull` here also keeps template wording current in every linked
# project — no per-project copy step for the parts that are pure process.
#
# Deliberately does NOT touch <project>/.opencode/opencode.jsonc or
# AGENTS.md. Those hold real, project-specific facts (crate map, T3
# floor, permissions tuned to that repo's layout) and were never meant
# to be pulled wholesale from a generic template. When a pipeline
# version bump changes something structural in those, this script
# instead prints a diff against the current .example files so you can
# see what to merge by hand.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <path-to-project>"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$(cd "$1" && pwd)"
PROJECT_HANDOFF="$PROJECT_DIR/.opencode/handoff"
TEMPLATE_SRC="$REPO_DIR/project/handoff"

if [ ! -d "$PROJECT_DIR/.opencode" ]; then
  echo "no .opencode/ in $PROJECT_DIR — run /init inside OpenCode there first"
  exit 1
fi

mkdir -p "$PROJECT_HANDOFF/1-plan" "$PROJECT_HANDOFF/2-spec" "$PROJECT_HANDOFF/3-report"

link_template() {
  local name="$1"
  local src="$TEMPLATE_SRC/$name"
  local dst="$PROJECT_HANDOFF/$name"

  if [ -L "$dst" ]; then
    ln -sfn "$src" "$dst"
    echo "already linked, refreshed: $dst"
    return
  fi

  if [ -e "$dst" ]; then
    local backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "backing up existing $dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  echo "linked: $dst -> $src"
}

link_template "PLAN_TEMPLATE.md"
link_template "SPEC_TEMPLATE.md"
link_template "REPORT_TEMPLATE.md"

echo ""
echo "--- checking project-specific files for drift against the current template ---"
echo "(these are NOT auto-updated — review manually if anything looks relevant)"
echo ""

diff_note() {
  local project_file="$1"
  local template_file="$2"
  local label="$3"

  if [ ! -f "$project_file" ]; then
    echo "no $label found at $project_file — nothing to compare"
    return
  fi

  if diff -q "$project_file" "$template_file" > /dev/null 2>&1; then
    echo "$label: identical to template, nothing to review"
  else
    echo "$label: differs from the current template (expected — it holds project facts)."
    echo "  If a pipeline update changed something structural, diff by hand:"
    echo "  diff $template_file $project_file"
  fi
}

diff_note "$PROJECT_DIR/.opencode/AGENTS.md" "$REPO_DIR/project/AGENTS.md.example" "AGENTS.md"

echo ""
echo "Done. Re-run this script after a pipeline update if you want the"
echo "linked templates refreshed immediately (though the symlinks mean"
echo "they already are)."
