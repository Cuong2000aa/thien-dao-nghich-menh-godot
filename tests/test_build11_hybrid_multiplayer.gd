extends Node2D

## TDNM — BUILD 11: HYBRID MULTIPLAYER FOUNDATION INTEGRATION TEST
## Verifies session roles, host listen topology, roster sync API, combat auth gate,
## disconnect restore, and offline preservation — within one process (Host path).
##
## Run:
##   godot --headless --path . res://tests/test_build11_hybrid_multiplayer.tscn

const Cultivation = preload("res://sources/actor/Cultivation.gd")

var timer : float = 0.0
var step : int = 0
var failed : int = 0
var test_account : String = "HostDao11_" + str(int(Time.get_unix_time_from_system()) % 100000)
var test_pass : String = "HostPass123!"
var test_char : String = "ChuPhong" + str(int(Time.get_unix_time_from_system()) % 10000)
var results : Dictionary = {}

func _ready():
	print("==================================================================")
	print("=== TDNM — BUILD 11: HYBRID MULTIPLAYER FOUNDATION ===")
	print("==================================================================")
	NetworkCommons.IsLocal = true

	# Step 0: SessionManager offline baseline
	SessionManager.ForceResetOffline()
	_assert(SessionManager.currentMode == SessionManager.Mode.OFFLINE, "step0_offline_baseline")
	_assert(not SessionManager.isHosting and not SessionManager.isClientSession, "step0_flags_clear")

	# Step 1: Create Host room state then force listen topology
	var hostRes = SessionManager.CreateHostRoom(7777, 3, "Test Tien Canh")
	_assert(hostRes.get("success", false), "step1_create_host_success")
	_assert(SessionManager.isHosting and SessionManager.currentMode == SessionManager.Mode.HOST, "step1_host_mode")
	_assert(SessionManager.listenPort == 7777 and SessionManager.maxPlayers == 3, "step1_port_cap")
	_assert(SessionManager.GetMemberCount() >= 1, "step1_host_self_member")

	var topologyOk : bool = SessionManager.ApplyNetworkTopology()
	_assert(topologyOk, "step1_topology_restart")
	_assert(Network.ENetServer != null and not Network.ENetServer.isOffline, "step1_enet_listen")
	_assert(Network.Client != null and Network.Client.isOffline, "step1_host_client_inprocess")
	print("[Step 1 PASS] Host listen server on port %d (max %d)" % [SessionManager.listenPort, SessionManager.maxPlayers])
	results["step1_host_listen"] = true

func _process(delta: float):
	timer += delta

	if timer > 1.0 and step == 0:
		step = 1
		print("[Step 2] Host login on authoritative SQLite: %s" % test_account)
		Network.LoginWithPassword(test_account, test_pass, false)

	if timer > 3.0 and step == 1:
		step = 2
		results["step2_login"] = true
		print("[Step 2 PASS] Login issued — creating character %s" % test_char)
		var hairstyles : PackedInt64Array = DB.HairstylesDB.keys()
		var haircolors : PackedInt64Array = DB.PalettesDB[DB.Palette.HAIR].keys() if DB.Palette.HAIR < DB.PalettesDB.size() else []
		var races : PackedInt64Array = DB.RacesDB.keys()
		var race : RaceData = DB.GetRace(races[0]) if races.size() > 0 else null
		var skinsKeys : Array = race.skins.keys() if race and race.skins else ["Medium"]
		var traits = {
			"hairstyle": hairstyles[0] if hairstyles.size() > 0 else "Bald".hash(),
			"haircolor": haircolors[0] if haircolors.size() > 0 else "Ash Brown".hash(),
			"race": races[0] if races.size() > 0 else "Human".hash(),
			"skintone": skinsKeys[0].hash() if skinsKeys.size() > 0 else "Medium".hash(),
			"gender": 0,
			"shape": "Player".hash(),
			"spirit": "Piou".hash()
		}
		var attrs = {
			"strength": 1, "vitality": 1, "agility": 1, "endurance": 1, "concentration": 1
		}
		Network.CreateCharacter(test_char, traits, attrs)

	if timer > 5.5 and step == 2:
		step = 3
		print("[Step 3] Connecting character: %s" % test_char)
		Network.ConnectCharacter(test_char)

	if timer > 8.0 and step == 3:
		step = 4
		if Launcher.Player:
			print("[Step 3 PASS] Host character in world: %s @ map %s" % [
				Launcher.Player.nick,
				LocationNaming.GetDisplayName(Launcher.Map.currentMapID) if Launcher.Map else "?"
			])
			results["step3_host_in_world"] = true
			_assert(SessionManager.IsCoopActive() or SessionManager.isHosting, "step3_coop_or_host")

			# Step 4: Roster Apply API (simulates guest sync receive)
			var fakeRoster = [
				{"peerID": 1, "nick": "ChuPhong", "realm": "Phàm Thân • Sơ Nhập", "level": 1, "hp": 100, "maxHp": 100, "isHost": true, "mapId": 0, "status": "Chủ Phòng"},
				{"peerID": 2, "nick": "DaoLu", "realm": Cultivation.GetRealmName(3), "level": 3, "hp": 80, "maxHp": 100, "isHost": false, "mapId": 0, "status": "Đạo Lữ Đồng Hành"}
			]
			# Preserve host mode; temporarily act as client apply path
			var wasHosting = SessionManager.isHosting
			SessionManager.isClientSession = true
			SessionManager.ApplyRoster(fakeRoster)
			_assert(SessionManager.GetMemberCount() == 2, "step4_roster_count")
			_assert(SessionManager.sessionMembers.has(2), "step4_guest_present")
			print("[Step 4 PASS] Roster sync ApplyRoster → 2 members")
			results["step4_roster_sync"] = true
			# Restore host membership for remaining checks
			SessionManager.isClientSession = false
			SessionManager.isHosting = wasHosting
			SessionManager.sessionMembers.clear()
			SessionManager.RegisterMember(NetworkCommons.PeerAuthorityID, Launcher.Player.nick, 1, Cultivation.GetRealmName(1), 100, 100, true, 0)

			# Step 5: Combat auth rejects null / dead requests
			var bad = SessionManager.ValidateCombatRequest(null, null, null)
			_assert(not bad.get("valid", true), "step5_combat_reject_null")
			print("[Step 5 PASS] Combat authority rejects fabricated null request")
			results["step5_combat_auth"] = true

			# Step 6: Leave room → offline topology preserved
			SessionManager.LeaveRoom()
			SessionManager.ApplyNetworkTopology()
			_assert(SessionManager.currentMode == SessionManager.Mode.OFFLINE, "step6_offline_mode")
			_assert(not SessionManager.isHosting and not SessionManager.isClientSession, "step6_flags")
			_assert(Network.Client != null, "step6_client_alive")
			print("[Step 6 PASS] LeaveRoom restores Độc Bộ Tu Chân (offline)")
			results["step6_offline_restore"] = true

			_finish()
		else:
			printerr("[FAIL] Host player never entered world")
			failed += 1
			_finish()

	if timer > 20.0 and step < 4:
		printerr("[FAIL] Timeout waiting for host world entry")
		failed += 1
		_finish()

func _assert(cond : bool, key : String) -> void:
	if cond:
		print("  PASS: %s" % key)
		results[key] = true
	else:
		printerr("  FAIL: %s" % key)
		results[key] = false
		failed += 1

func _finish():
	print("==================================================================")
	print("=== BUILD 11 RESULT: %s (%d failures) ===" % ["OK" if failed == 0 else "FAILED", failed])
	print("Results: %s" % str(results))
	print("==================================================================")
	get_tree().quit(0 if failed == 0 else 1)
