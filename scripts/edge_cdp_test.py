import asyncio
import json
import urllib.request
import websockets
import subprocess
import time
import os

EDGE_PATH = "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
PORT = 9222
PROFILE_DIR = "/tmp/edge_cdp_profile_tan_thu_thon"
TARGET_URL = "http://127.0.0.1:8085/?autologin=1&account=DaoHuuVillageWeb&char=KiemTuWeb"

async def run_cdp():
    # 1. Start Edge process
    os.makedirs(PROFILE_DIR, exist_ok=True)
    cmd = [
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
    print(f"Starting Edge: {' '.join(cmd)}")
    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    ws_url = None
    for attempt in range(20):
        await asyncio.sleep(0.5)
        try:
            req = urllib.request.urlopen(f"http://127.0.0.1:{PORT}/json/list")
            tabs = json.loads(req.read().decode('utf-8'))
            for tab in tabs:
                if tab.get("type") == "page" and "8085" in tab.get("url", ""):
                    ws_url = tab.get("webSocketDebuggerUrl")
                    print(f"Found page tab: {tab.get('title')} ({tab.get('url')}) -> {ws_url}")
                    break
            if ws_url:
                break
        except Exception:
            pass

    if not ws_url:
        print("ERROR: Could not find page WebSocket URL!")
        proc.terminate()
        return

    print("Connecting to CDP WebSocket...")
    async with websockets.connect(ws_url) as ws:
        # Enable domains
        await ws.send(json.dumps({"id": 1, "method": "Runtime.enable"}))
        await ws.send(json.dumps({"id": 2, "method": "Console.enable"}))
        await ws.send(json.dumps({"id": 3, "method": "Log.enable"}))
        await ws.send(json.dumps({"id": 4, "method": "Network.enable"}))
        
        # Collect events for 35 seconds (Godot PCK is ~98MB so loading takes ~5-15s)
        start_time = time.time()
        print("Listening for browser console and network events (35s)...")
        
        last_eval_time = 0
        while time.time() - start_time < 35:
            try:
                msg_raw = await asyncio.wait_for(ws.recv(), timeout=1.0)
                msg = json.loads(msg_raw)
                method = msg.get("method", "")
                
                if method == "Runtime.consoleAPICalled":
                    args = msg.get("params", {}).get("args", [])
                    texts = [str(a.get("value", a.get("description", ""))) for a in args]
                    print(f"[BROWSER CONSOLE {msg['params']['type'].upper()}]: {' '.join(texts)}")
                elif method == "Log.entryAdded":
                    entry = msg.get("params", {}).get("entry", {})
                    print(f"[BROWSER LOG {entry.get('level').upper()}]: {entry.get('text')}")
                elif method == "Network.webSocketCreated":
                    print(f"[BROWSER WS CREATED]: {msg.get('params', {}).get('url')}")
                elif method == "Network.webSocketFrameSent":
                    print(f"[BROWSER WS SENT]: {msg.get('params', {}).get('response', {}).get('payloadData')[:100]}")
                elif method == "Network.webSocketFrameReceived":
                    print(f"[BROWSER WS RECV]: {msg.get('params', {}).get('response', {}).get('payloadData')[:100]}")
                elif method == "Network.webSocketClosed":
                    print(f"[BROWSER WS CLOSED]")
            except asyncio.TimeoutError:
                pass
                
            # Periodically query progress / status in DOM
            if time.time() - last_eval_time > 3.0:
                last_eval_time = time.time()
                await ws.send(json.dumps({
                    "id": 100,
                    "method": "Runtime.evaluate",
                    "params": {"expression": "(() => { const p = document.getElementById('status-progress'); const n = document.getElementById('status-notice'); return { progress: p ? p.value : null, max: p ? p.max : null, notice: n ? n.innerText : null }; })()", "returnByValue": True}
                }))

        # Capture a screenshot
        print("Capturing screenshot via CDP...")
        await ws.send(json.dumps({"id": 200, "method": "Page.captureScreenshot", "params": {"format": "png"}}))
        resp_raw = await ws.recv()
        resp = json.loads(resp_raw)
        if "result" in resp and "data" in resp["result"]:
            import base64
            img_data = base64.b64decode(resp["result"]["data"])
            os.makedirs("docs/images/phase4_1", exist_ok=True)
            with open("docs/images/phase4_1/10_browser_edge_tan_thu_thon.png", "wb") as f:
                f.write(img_data)
            print(f"Screenshot saved to docs/images/phase4_1/10_browser_edge_tan_thu_thon.png ({len(img_data)} bytes)")

    proc.terminate()
    proc.wait()
    print("Edge process terminated.")

if __name__ == "__main__":
    asyncio.run(run_cdp())
