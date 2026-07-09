#!/usr/bin/env bash
# sync.sh — keep this repo and the installed kit in ~/.claude in sync.
#
# The kit lives in two places: this git repo (source of truth) and ~/.claude
# (where Claude Code loads it). This script copies the four kit trees —
# skills/ agents/ commands/ pentest-kit/ — in either direction.
#
# Usage:
#   ./sync.sh diff      Show which files differ (default; changes nothing)
#   ./sync.sh collect   ~/.claude  -->  repo   (pull your live edits into the repo)
#   ./sync.sh deploy    repo       -->  ~/.claude (push repo version into Claude Code)
#
# Notes:
#   * Only files already present under skills/agents/commands/pentest-kit in the
#     REPO are synced. A brand-new component must be added to the repo once
#     (git add), after which sync keeps it updated in both directions.
#   * 'deploy' is what install.sh does; use it after a git pull.
#   * After 'collect', review with `git diff` then commit & push.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE="$HOME/.claude"
MODE="${1:-diff}"

# Relative paths of every kit file, derived from the repo layout.
mapfile -t FILES < <(cd "$REPO" && find skills agents commands pentest-kit -type f 2>/dev/null | sort)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "No kit files found under $REPO. Run from a proper clone." >&2
  exit 1
fi

changed=0 missing=0 copied=0

case "$MODE" in
  diff)
    echo "Comparing repo <-> $CLAUDE (no changes made):"
    for rel in "${FILES[@]}"; do
      r="$REPO/$rel"; c="$CLAUDE/$rel"
      if [[ ! -e "$c" ]]; then
        echo "  [only in repo]   $rel"; missing=$((missing+1))
      elif ! diff -q "$r" "$c" >/dev/null 2>&1; then
        echo "  [differs]        $rel"; changed=$((changed+1))
      fi
    done
    [[ $changed -eq 0 && $missing -eq 0 ]] && echo "  everything in sync ✓"
    echo "Summary: $changed differ, $missing missing in ~/.claude."
    echo "Run './sync.sh collect' (~/.claude->repo) or './sync.sh deploy' (repo->~/.claude)."
    ;;

  deploy)  # repo -> ~/.claude
    for rel in "${FILES[@]}"; do
      mkdir -p "$CLAUDE/$(dirname "$rel")"
      if ! diff -q "$REPO/$rel" "$CLAUDE/$rel" >/dev/null 2>&1; then
        cp "$REPO/$rel" "$CLAUDE/$rel"; echo "  -> ~/.claude/$rel"; copied=$((copied+1))
      fi
    done
    chmod +x "$CLAUDE"/pentest-kit/*.py "$CLAUDE"/pentest-kit/*.sh 2>/dev/null || true
    echo "Deployed $copied changed file(s) into $CLAUDE. Restart Claude Code to reload."
    ;;

  collect) # ~/.claude -> repo
    for rel in "${FILES[@]}"; do
      if [[ ! -e "$CLAUDE/$rel" ]]; then
        echo "  [missing in ~/.claude, skipped] $rel"; missing=$((missing+1)); continue
      fi
      if ! diff -q "$CLAUDE/$rel" "$REPO/$rel" >/dev/null 2>&1; then
        cp "$CLAUDE/$rel" "$REPO/$rel"; echo "  <- ~/.claude/$rel"; copied=$((copied+1))
      fi
    done
    echo "Collected $copied changed file(s) into the repo ($missing missing in ~/.claude)."
    echo "Review with 'git diff', then: git add -A && git commit && git push"
    ;;

  *)
    echo "Usage: $0 {diff|collect|deploy}" >&2; exit 2 ;;
esac
