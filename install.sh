#!/usr/bin/env bash
# install.sh — install this pentest kit into ~/.claude so Claude Code picks it up.
# Idempotent: re-run to update. Existing user skills/agents/commands with the same
# name are overwritten by the repo version (this repo is the source of truth).
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.claude"

echo "Installing pentest kit from $SRC -> $DEST"
mkdir -p "$DEST/skills" "$DEST/agents" "$DEST/commands" "$DEST/pentest-kit/templates"

# Skills (each is a directory with SKILL.md)
for d in "$SRC"/skills/*/; do
  name="$(basename "$d")"
  mkdir -p "$DEST/skills/$name"
  cp "$d/SKILL.md" "$DEST/skills/$name/SKILL.md"
  echo "  skill   $name"
done

# Agents & commands (flat .md files)
for f in "$SRC"/agents/*.md;   do cp "$f" "$DEST/agents/";   echo "  agent   $(basename "$f")"; done
for f in "$SRC"/commands/*.md; do cp "$f" "$DEST/commands/"; echo "  command $(basename "$f")"; done

# Pentest-kit tooling (hooks, scaffolder, templates)
cp "$SRC"/pentest-kit/*.py "$SRC"/pentest-kit/new-engagement.sh "$SRC"/pentest-kit/README.md "$DEST/pentest-kit/"
cp "$SRC"/pentest-kit/templates/* "$DEST/pentest-kit/templates/"
chmod +x "$DEST"/pentest-kit/*.py "$DEST"/pentest-kit/new-engagement.sh
echo "  tooling scope-guard.py, evidence-archiver.py, new-engagement.sh, templates/"

echo
echo "Done. Restart Claude Code to load the new skills/agents/commands."
echo "Start an engagement:  ~/.claude/pentest-kit/new-engagement.sh <name> [parent-dir]"
