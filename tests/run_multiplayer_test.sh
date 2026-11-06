#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

mkdir -p tests/exchange tests/screenshots

rm -f tests/exchange/* tests/bot*_report.json

echo "=== STARTING MULTIPLAYER BASELINE VALIDATION ==="
echo "1. Launching Client 1 (DaoHuu01 / ThienKiem01)..."
/tmp/godot_setup/Godot.app/Contents/MacOS/Godot --path . --local --profile=bot1 tests/ClientBot.tscn --bot-id=1 --account=DaoHuu01 --char=ThienKiem01 --partner=NghichMenh02 > tests/bot1.log 2>&1 &
BOT1_PID=$!
echo "   Client 1 PID: $BOT1_PID"

sleep 3

echo "2. Launching Client 2 (DaoHuu02 / NghichMenh02)..."
/tmp/godot_setup/Godot.app/Contents/MacOS/Godot --path . --local --profile=bot2 tests/ClientBot.tscn --bot-id=2 --account=DaoHuu02 --char=NghichMenh02 --partner=ThienKiem01 > tests/bot2.log 2>&1 &
BOT2_PID=$!
echo "   Client 2 PID: $BOT2_PID"

echo "3. Waiting for test sequence to complete..."
wait $BOT1_PID || true
wait $BOT2_PID || true

echo "=== BOT TEST RUNS FINISHED ==="
echo "--- Bot 1 Log Summary ---"
tail -n 25 tests/bot1.log || true

echo "--- Bot 2 Log Summary ---"
tail -n 25 tests/bot2.log || true

echo "--- Exchange Files ---"
ls -la tests/exchange/ || true

echo "--- Screenshots Generated ---"
ls -la tests/screenshots/ || true

echo "=== DATABASE PERSISTENCE CHECK ==="
sqlite3 "/Users/it/Library/Application Support/ThienDaoNghichMenh/testing.db" "SELECT account_id, username, email FROM account;" || true
sqlite3 "/Users/it/Library/Application Support/ThienDaoNghichMenh/testing.db" "SELECT char_id, account_id, nickname, pos_x, pos_y, pos_map FROM character;" || true
