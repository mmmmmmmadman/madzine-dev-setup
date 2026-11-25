#!/bin/bash
# Claude Code 雲端環境 setup script
# 用途：session 開始時把 madzine-dev-setup 的 agents / commands / knowledge
#       放進「目前 repo」的 .claude/ 底下（project 層級，雲端會載入）。
#       只放在工作目錄，不 commit：寫進 .git/info/exclude。
# 設定位置：claude.ai/code → 環境設定 → Setup script，整段貼上。
set -euo pipefail

SRC_REPO="https://github.com/mmmmmmmadman/madzine-dev-setup.git"
TMP="$(mktemp -d)"
git clone --depth 1 -q "$SRC_REPO" "$TMP/mds"

DST="${PWD}/.claude"
mkdir -p "$DST/agents" "$DST/commands" "$DST/knowledge"
cp -r "$TMP/mds/claude-config/agents/."    "$DST/agents/"
cp -r "$TMP/mds/claude-config/commands/."  "$DST/commands/"
cp -r "$TMP/mds/claude-config/knowledge/." "$DST/knowledge/"
rm -rf "$TMP"

# 不讓這些檔案出現在 git status（repo 自己已 commit 的 .claude 檔不受影響）
if [ -d .git ]; then
  EXCL=.git/info/exclude
  touch "$EXCL"
  for p in .claude/agents/ .claude/commands/ .claude/knowledge/; do
    grep -qxF "$p" "$EXCL" || echo "$p" >> "$EXCL"
  done
fi

echo "madzine claude-config installed to $DST"
echo "  agents:    $(ls "$DST/agents"/*.md 2>/dev/null | wc -l)"
echo "  commands:  $(ls "$DST/commands"/*.md 2>/dev/null | wc -l)"
echo "  knowledge: $(find "$DST/knowledge" -name '*.md' | wc -l)"
