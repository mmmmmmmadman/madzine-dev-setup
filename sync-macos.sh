#!/bin/bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

case "${1:-}" in
  push)
    echo ">>> ~/.claude/ → repo"
    rsync -a --delete "$CLAUDE_DIR/agents/"   "$REPO/claude-config/agents/"
    rsync -a --delete "$CLAUDE_DIR/commands/" "$REPO/claude-config/commands/"
    cp "$CLAUDE_DIR/CLAUDE.md" "$REPO/claude-config/CLAUDE.md"
    cd "$REPO" && git status
    echo
    echo "如要送上 origin: cd $REPO && git add -A && git commit -m '...' && git push"
    ;;
  pull)
    echo ">>> git pull + repo → ~/.claude/"
    cd "$REPO" && git pull
    rsync -a --delete "$REPO/claude-config/agents/"   "$CLAUDE_DIR/agents/"
    rsync -a --delete "$REPO/claude-config/commands/" "$CLAUDE_DIR/commands/"
    cp "$REPO/claude-config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    echo "完成"
    ;;
  check)
    echo ">>> 比對 ~/.claude/ vs repo"
    echo "--- CLAUDE.md ---"
    diff "$CLAUDE_DIR/CLAUDE.md" "$REPO/claude-config/CLAUDE.md" && echo "相同"
    echo "--- agents/ ---"
    diff -rq "$CLAUDE_DIR/agents/" "$REPO/claude-config/agents/" && echo "相同"
    echo "--- commands/ ---"
    diff -rq "$CLAUDE_DIR/commands/" "$REPO/claude-config/commands/" && echo "相同"
    ;;
  *)
    cat <<EOF
用法: $0 {push|pull|check}
  push   本機 ~/.claude/ 推進 repo working tree（git commit/push 仍需手動）
  pull   git pull 後把 repo 內容覆蓋回本機 ~/.claude/
  check  列出 ~/.claude/ 與 repo 的所有差異（exit 0 = 完全一致）
EOF
    exit 1
    ;;
esac
