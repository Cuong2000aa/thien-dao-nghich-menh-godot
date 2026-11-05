extends SceneTree

## TDNM — BUILD 11: SessionManager state machine unit checks
## Avoids ValidateCombatRequest (needs BaseAgent/SkillCell + full game boot).
## Run: godot --headless --path . -s tests/test_build11_session_manager.gd

const SM = preload("res://sources/network/SessionManager.gd")

func _init():
	call_deferred("_run")

func _run():
	print("=== TDNM BUILD 11 — SessionManager unit ===")
	var failed : int = 0

	SM.LeaveRoom()
	if SM.currentMode != SM.Mode.OFFLINE:
		printerr("FAIL: expected OFFLINE after LeaveRoom")
		failed += 1
	else:
		print("PASS: LeaveRoom → OFFLINE")

	var hostRes = SM.CreateHostRoom(7777, 3, "Test Room")
	if not hostRes.get("success", false) or not SM.isHosting or SM.currentMode != SM.Mode.HOST:
		printerr("FAIL: CreateHostRoom HOST state")
		failed += 1
	else:
		print("PASS: CreateHostRoom sets HOST")
	if SM.listenPort != 7777 or SM.maxPlayers != 3:
		printerr("FAIL: Host port/maxPlayers")
		failed += 1
	else:
		print("PASS: Host port=7777 maxPlayers=3")
	if SM.GetMemberCount() < 1:
		printerr("FAIL: Host self-register")
		failed += 1
	else:
		print("PASS: Host registered as member")

	SM.LeaveRoom()
	var joinRes = SM.JoinHostRoom("127.0.0.1", 7777)
	if not joinRes.get("success", false) or not SM.isClientSession or SM.currentMode != SM.Mode.CLIENT:
		printerr("FAIL: JoinHostRoom CLIENT state")
		failed += 1
	else:
		print("PASS: JoinHostRoom sets CLIENT")
	if SM.targetHost != "127.0.0.1" or SM.targetPort != 7777:
		printerr("FAIL: Join target")
		failed += 1
	else:
		print("PASS: Join target 127.0.0.1:7777")

	SM.RegisterMember(2, "DaoLu", 3, "Tụ Khí • Tầng 3", 80, 100, false, 1374526955)
	if SM.GetMemberCount() != 1:
		printerr("FAIL: RegisterMember")
		failed += 1
	else:
		print("PASS: RegisterMember")
	SM.UpdateMemberStats(2, 40, 100, 4, "Tụ Khí • Tầng 4")
	var members = SM.GetMembers()
	if members.is_empty() or members[0].get("hp", 0) != 40:
		printerr("FAIL: UpdateMemberStats")
		failed += 1
	else:
		print("PASS: UpdateMemberStats")
	SM.UnregisterMember(2)
	if SM.GetMemberCount() != 0:
		printerr("FAIL: UnregisterMember")
		failed += 1
	else:
		print("PASS: UnregisterMember")

	SM.LeaveRoom()
	print("=== BUILD 11 SessionManager: %s (%d failures) ===" % ["OK" if failed == 0 else "FAILED", failed])
	quit(0 if failed == 0 else 1)
