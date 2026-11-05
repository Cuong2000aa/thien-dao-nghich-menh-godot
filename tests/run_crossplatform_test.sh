#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

mkdir -p tests/exchange tests/screenshots

rm -f tests/exchange/* tests/bot1_report.json tests/bot2_report.json

echo "=== STARTING PHASE 3 CROSS-PLATFORM (DESKTOP + WEB) TEST ==="
echo "1. Launching Native Desktop Client (Bot 1 via ENet 6119)..."
/tmp/godot_setup/Godot.app/Contents/MacOS/Godot --path . --local --profile=bot_desktop tests/ClientBot.tscn --bot-id=1 --account=DaoHuuDesktop --char=KiemTienDesktop --partner=DaoNhanWeb > tests/bot1_desktop.log 2>&1 &
DESKTOP_PID=$!
echo "   Desktop Client PID: $DESKTOP_PID"

sleep 3

echo "2. Launching Web Client (Bot 2 via WebSocket 6118)..."
/tmp/godot_setup/Godot.app/Contents/MacOS/Godot --path . --local --profile=bot_web tests/ClientBot.tscn --bot-id=2 --account=DaoHuuBrowser --char=DaoNhanWeb --partner=KiemTienDesktop --websocket > tests/bot2_web.log 2>&1 &
WEB_PID=$!
echo "   Web Client PID: $WEB_PID"

echo "3. Waiting for cross-platform simulation to complete..."
wait $DESKTOP_PID || true
wait $WEB_PID || true

echo "=== CROSS-PLATFORM TEST SEQUENCE COMPLETE ==="
echo "--- Desktop Client Log Summary ---"
tail -n 25 tests/bot1_desktop.log || true

echo "--- Web Client Log Summary ---"
tail -n 25 tests/bot2_web.log || true

echo "--- Exchange Synchronization Files ---"
ls -la tests/exchange/ || true

echo "--- Screenshots Generated ---"
ls -la tests/screenshots/ || true

echo "=== DATABASE PERSISTENCE CHECK ==="
sqlite3 "/Users/it/Library/Application Support/SourceOfMana/testing.db" "SELECT char_id, account_id, nickname, pos_x, pos_y, pos_map FROM character WHERE nickname IN ('KiemTienDesktop', 'DaoNhanWeb');" || true
