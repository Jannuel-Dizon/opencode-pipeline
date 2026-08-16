#!/usr/bin/env bash
# install-global.sh
#
# Run once per device. Links ~/.config/opencode/{opencode.jsonc,AGENTS.md,
# prompts,commands,templates} to files inside this cloned repo's global/
# directory. After this, updating on this device is just:
#
#   cd <this repo> && git pull
#
# No copying, no re-running this script, on every version bump.
#
# Personal, per-device tweaks (e.g. swapping a model) do NOT go in the
# symlinked opencode.jsonc — they go in a small override file that this
# script creates once and NEVER touches again, loaded via OPENCODE_CONFIG.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL_SRC="$REPO_DIR/global"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
OVERRIDE_FILE="$CONFIG_DIR/local-overrides.jsonc"

mkdir -p "$CONFIG_DIR"

link_one() {
  local name="$1"
  local src="$GLOBAL_SRC/$name"
  local dst="$CONFIG_DIR/$name"

  if [ -L "$dst" ]; then
    echo "already symlinked: $dst -> $(readlink "$dst")"
    ln -sfn "$src" "$dst"
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

link_one "opencode.jsonc"
link_one "AGENTS.md"
link_one "prompts"
link_one "commands"
link_one "templates"

if [ ! -e "$OVERRIDE_FILE" ]; then
  cat > "$OVERRIDE_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json"

  // Personal, per-device overrides. This file is NEVER touched by
  // `git pull` in the pipeline repo — it lives outside it, in
  // ~/.config/opencode/, and is loaded on top of opencode.jsonc via
  // OPENCODE_CONFIG. Deep-merges: only the keys you set here override
  // the template; everything else still comes from opencode.jsonc.
  //
  // Example — swap the T1 build model to the free tier on this device:
  // "agent": {
  //   "build": {
  //     "model": "opencode/deepseek-v4-flash-free"
  //   }
  // }
}
EOF
  echo "created override file: $OVERRIDE_FILE (edit this for personal tweaks)"
else
  echo "override file already exists, leaving it alone: $OVERRIDE_FILE"
fi

SHELL_RC="$HOME/.bashrc"
EXPORT_LINE="export OPENCODE_CONFIG=\"$OVERRIDE_FILE\""

if ! grep -qF "OPENCODE_CONFIG=" "$SHELL_RC" 2>/dev/null; then
  echo ""
  echo "Add this line to $SHELL_RC (or your shell's rc file) and restart your shell:"
  echo ""
  echo "  $EXPORT_LINE"
  echo ""
else
  echo "OPENCODE_CONFIG already set in $SHELL_RC — check it points at $OVERRIDE_FILE"
fi

echo ""
echo "Done. To update this device in future: cd $REPO_DIR && git pull"
echo "No need to run this script again unless a new file is added upstream."
