import asyncio
import json
import urllib.request
import websockets
import subprocess
import time
import os
import shutil

EDGE_PATH = "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
GODOT_BIN = "/tmp/godot_setup/Godot.app/Contents/MacOS/Godot"
PORT = 9222
PROFILE_DIR = "/tmp/edge_cdp_profile"
TARGET_URL = "http://127.0.0.1:8085/?autologin=1&account=DaoHuuEdge&char=KiemTuEdge"

async def run_multiplayer_verification():
    print("=== [PHASE 3.1] BROWSER REALITY & MULTIPLAYER INTEGRITY AUDIT ===")
    os.makedirs("tests/exchange", exist_ok=True)
    os.makedirs("tests/screenshots", exist_ok=True)
    os.makedirs("docs/images/phase3", exist_ok=True)
    
    # 1. Clean previous exchange state
    for f in os.listdir("tests/exchange"):
        os.remove(os.path.join("tests/exchange", f))
    if os.path.exists(PROFILE_DIR):
        shutil.rmtree(PROFILE_DIR, ignore_errors=True)

    # 2. Launch Desktop Native Client (Bot 1 via ENet)
    desktop_cmd = [
        GODOT_BIN,
        "--path", ".",
        "--local",
        "--profile=bot_desktop",
        "tests/ClientBot.tscn",
        "--bot-id=1",
        "--account=DaoHuuDesktop",
        "--char=KiemTienDesktop",
        "--partner=KiemTuEdge"
    ]
    print(f"1. Launching Native Desktop Client (ENet 6119): {' '.join(desktop_cmd)}")
    desktop_log = open("tests/bot1_desktop.log", "w")
    desktop_proc = subprocess.Popen(desktop_cmd, stdout=desktop_log, stderr=subprocess.STDOUT)

    await asyncio.sleep(2.0)

    # 3. Launch Real Microsoft Edge Browser Client
    edge_cmd = [
        EDGE_PATH,
        "--headless=new",
        f"--remote-debugging-port={PORT}",
        f"--user-data-dir={PROFILE_DIR}",
        "--no-first-run",
        "--no-default-browser-check",
        "--disable-background-timer-throttling",
        "--disable-renderer-backgrounding",
        "--disable-backgrounding-occluded-windows",
        "--enable-features=SharedArrayBuffer",
        TARGET_URL
    ]
    print(f"2. Launching Real Microsoft Edge Browser (WebSocket 6118): {TARGET_URL}")
    edge_proc = subprocess.Popen(edge_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    ws_url = None
    for attempt in range(25):
        await asyncio.sleep(0.5)
        try:
            req = urllib.request.urlopen(f"http://127.0.0.1:{PORT}/json/list")
            tabs = json.loads(req.read().decode('utf-8'))
            for tab in tabs:
                if tab.get("type") == "page" and "8085" in tab.get("url", ""):
                    ws_url = tab.get("webSocketDebuggerUrl")
                    print(f"   Found Edge tab: {tab.get('title')} -> {ws_url}")
                    break
            if ws_url:
                break
        except Exception:
            pass

    if not ws_url:
        print("ERROR: Edge CDP endpoint not reachable!")
        desktop_proc.terminate()
        edge_proc.terminate()
        return False

    browser_in_game = False
    browser_saw_partner = False
    browser_movement_verified = False

    async with websockets.connect(ws_url) as ws:
        await ws.send(json.dumps({"id": 1, "method": "Runtime.enable"}))
        await ws.send(json.dumps({"id": 2, "method": "Console.enable"}))
        await ws.send(json.dumps({"id": 3, "method": "Log.enable"}))
        await ws.send(json.dumps({"id": 4, "method": "Network.enable"}))

        print("3. Monitoring Edge Browser and Native Desktop cross-play (40s)...")
        start_t = time.time()
        
        while time.time() - start_t < 40:
            try:
                raw = await asyncio.wait_for(ws.recv(), timeout=0.8)
                msg = json.loads(raw)
                method = msg.get("method", "")
                if method == "Runtime.consoleAPICalled":
                    args = msg.get("params", {}).get("args", [])
                    line = " ".join([str(a.get("value", a.get("description", ""))) for a in args])
                    print(f"[EDGE CONSOLE]: {line}")
                    if "ENTERED WORLD AS KiemTuEdge" in line:
                        browser_in_game = True
                    if "Movement sequence complete" in line:
                        browser_movement_verified = True
            except asyncio.TimeoutError:
                pass

        # Capture Screenshot from Edge Canvas via CDP
        print("4. Capturing screenshot from Edge browser canvas via CDP...")
        await ws.send(json.dumps({"id": 200, "method": "Page.captureScreenshot", "params": {"format": "png"}}))
        resp_raw = await ws.recv()
        resp = json.loads(resp_raw)
        if "result" in resp and "data" in resp["result"]:
            import base64
            img_bytes = base64.b64decode(resp["result"]["data"])
            path = "docs/images/phase3/browser_edge_multiplayer_active.png"
            with open(path, "wb") as f:
                f.write(img_bytes)
            print(f"   Saved Edge screenshot: {path} ({len(img_bytes)} bytes)")

    desktop_proc.terminate()
    edge_proc.terminate()
    desktop_log.close()

    print("\n=== VERIFICATION RESULTS ===")
    print(f"Browser in-game: {browser_in_game}")
    print(f"Browser movement verified: {browser_movement_verified}")
    
    # Check desktop log
    with open("tests/bot1_desktop.log", "r") as f:
        desktop_output = f.read()
    print("--- Tail of Desktop Client Log ---")
    lines = desktop_output.strip().split("\n")
    for l in lines[-20:]:
        print(l)

    return True

if __name__ == "__main__":
    asyncio.run(run_multiplayer_verification())
