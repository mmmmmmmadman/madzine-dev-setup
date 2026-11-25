#!/bin/bash
# Claude Code 雲端環境 setup script
# 用途：session 開始時把 madzine-dev-setup 的 agents / commands / knowledge
#       裝到雲端 VM 的 ~/.claude/ 底下。
# 設定位置：claude.ai/code 新 session 畫面 → 訊息框下方第一個控制項（環境選單）
#           → 該環境列的設定圖示 → Setup script → 貼上 → Save changes。
# 注意：setup script 只在第一次跑，之後用快照（約 7 天或腳本改動時才重跑）。
#       知識庫更新後要改一下這個腳本（例如改下面的版本號）才會重新安裝。
# VERSION=1
set -u

SRC_REPO="https://github.com/mmmmmmmadman/madzine-dev-setup.git"
TMP="$(mktemp -d)"
if ! git clone --depth 1 -q "$SRC_REPO" "$TMP/mds"; then
  echo "madzine cloud-setup: git clone failed (GitHub proxy may block unattached repos)" >&2
  rm -rf "$TMP"
  exit 0
fi

DST="$HOME/.claude"
mkdir -p "$DST/agents" "$DST/commands" "$DST/knowledge"
cp -r "$TMP/mds/claude-config/agents/."    "$DST/agents/"    || true
cp -r "$TMP/mds/claude-config/commands/."  "$DST/commands/"  || true
cp -r "$TMP/mds/claude-config/knowledge/." "$DST/knowledge/" || true
rm -rf "$TMP"

echo "madzine claude-config installed to $DST"
echo "  agents:    $(ls "$DST/agents"/*.md 2>/dev/null | wc -l)"
echo "  commands:  $(ls "$DST/commands"/*.md 2>/dev/null | wc -l)"
echo "  knowledge: $(find "$DST/knowledge" -name '*.md' 2>/dev/null | wc -l)"
exit 0
