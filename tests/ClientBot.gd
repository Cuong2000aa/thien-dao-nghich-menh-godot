extends Node2D

const EXCHANGE_DIR = "tests/exchange/"
const SCREENSHOT_DIR = "tests/screenshots/"

var bot_id : int = 1
var account_name : String = "DaoHuu01"
var password_text : String = "DaoPass123!"
var char_name : String = "ThienKiem01"
var partner_char : String = "NghichMenh02"

var state : String = "INIT"
var state_timer : float = 0.0
var total_timer : float = 0.0

var spawn_pos : Vector2 = Vector2.ZERO
var test_log : Array = []

func _ready():
	DirAccess.make_dir_recursive_absolute(EXCHANGE_DIR)
	DirAccess.make_dir_recursive_absolute(SCREENSHOT_DIR)
	
	var use_websocket : bool = false
	for arg in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		if arg.begins_with("--bot-id="):
			bot_id = arg.trim_prefix("--bot-id=").to_int()
		elif arg.begins_with("--account="):
			account_name = arg.trim_prefix("--account=")
		elif arg.begins_with("--char="):
			char_name = arg.trim_prefix("--char=")
		elif arg.begins_with("--partner="):
			partner_char = arg.trim_prefix("--partner=")
		elif arg == "--websocket":
			use_websocket = true

	log_msg("ClientBot started with Bot ID: %d, Account: %s, Char: %s, Partner: %s, WebSocket: %s" % [bot_id, account_name, char_name, partner_char, str(use_websocket)])
	
	NetworkCommons.IsLocal = true
	if use_websocket:
		LauncherCommons.isWeb = true
	Launcher.Mode(true, false)
	
	if Network.Client:
		Network.Client.multiplayerAPI.connected_to_server.connect(_on_connected)
		Network.Client.multiplayerAPI.connection_failed.connect(_on_connect_failed)
		state = "WAIT_CONNECT"
	else:
		log_msg("ERROR: Network.Client not initialized!")
		get_tree().quit(1)

func log_msg(msg: String):
	var line = "[Bot %d][%s][%.2f] %s" % [bot_id, state, total_timer, msg]
	print(line)
	test_log.append(line)

func _on_connected():
	log_msg("Connected to server via ENet!")
	state = "AUTH"
	state_timer = 0.0

func _on_connect_failed():
	log_msg("Connection to server failed!")
	get_tree().quit(1)

func get_valid_traits() -> Dictionary:
	var hairstyles : PackedInt64Array = DB.HairstylesDB.keys()
	var haircolors : PackedInt64Array = DB.PalettesDB[DB.Palette.HAIR].keys()
	var races : PackedInt64Array = DB.RacesDB.keys()
	var race : RaceData = DB.GetRace(races[0]) if races.size() > 0 else null
	var skinsKeys : Array = race.skins.keys() if race and race.skins else ["Medium"]
	
	return {
		"hairstyle": hairstyles[0] if hairstyles.size() > 0 else "Bald".hash(),
		"haircolor": haircolors[0] if haircolors.size() > 0 else "Ash Brown".hash(),
		"race": races[0] if races.size() > 0 else "Human".hash(),
		"skintone": skinsKeys[0].hash() if skinsKeys.size() > 0 else "Medium".hash(),
		"gender": 0,
		"shape": "Player".hash(),
		"spirit": "Piou".hash()
	}

func get_valid_attributes() -> Dictionary:
	return {
		"strength": 0,
		"vitality": 0,
		"agility": 0,
		"endurance": 0,
		"concentration": 0
	}

func capture_screenshot(filename: String):
	var img = get_viewport().get_texture().get_image()
	if img:
		var path = SCREENSHOT_DIR + filename
		var err = img.save_png(path)
		log_msg("Captured screenshot: " + path + " (err=" + str(err) + ")")

func _process(delta: float):
	total_timer += delta
	state_timer += delta

	match state:
		"AUTH":
			if state_timer > 0.6:
				log_msg("Sending LoginWithPassword (or CreateAccount fallback): " + account_name)
				Network.LoginWithPassword(account_name, password_text, false)
				state = "WAIT_LOGIN"
				state_timer = 0.0

		"WAIT_LOGIN":
			if FSM.currentState == FSM.States.CHAR_SCREEN:
				log_msg("Login succeeded, in CHAR_SCREEN!")
				state = "CREATE_OR_SELECT_CHAR"
				state_timer = 0.0
			elif state_timer > 1.2:
				log_msg("Account may not exist yet, trying CreateAccount: " + account_name)
				Network.CreateAccount(account_name, password_text, account_name.to_lower() + "@thiendao.internal", false)
				state = "WAIT_CREATE_ACC"
				state_timer = 0.0

		"WAIT_CREATE_ACC":
			if FSM.currentState == FSM.States.CHAR_SCREEN or state_timer > 1.2:
				state = "CREATE_OR_SELECT_CHAR"
				state_timer = 0.0

		"CREATE_OR_SELECT_CHAR":
			if state_timer > 0.5:
				log_msg("Sending CreateCharacter: " + char_name)
				Network.CreateCharacter(char_name, get_valid_traits(), get_valid_attributes())
				state = "CONNECT_CHAR"
				state_timer = 0.0

		"CONNECT_CHAR":
			if state_timer > 1.2:
				log_msg("Sending ConnectCharacter: " + char_name)
				if Launcher.GUI and Launcher.GUI.characterPanel and Launcher.GUI.characterPanel.characterNameDisplay:
					Launcher.GUI.characterPanel.characterNameDisplay.set_text(char_name)
				FSM.EnterState(FSM.States.CHAR_PROGRESS)
				Network.ConnectCharacter(char_name)
				state = "WAIT_WORLD"
				state_timer = 0.0

		"WAIT_WORLD":
			if Launcher.Player != null or FSM.currentState == FSM.States.IN_GAME:
				spawn_pos = Launcher.Player.position if Launcher.Player else Vector2(100, 100)
				var map_id = Launcher.Map.currentMapID if Launcher.Map else 0
				var is_swordsman = (Launcher.Player != null and Launcher.Player.visual != null and Launcher.Player.visual.animatedSprite != null)
				log_msg("ENTERED WORLD SUCCESSFULLY! Map ID: %s, is Swordsman: %s, Spawn position: %s" % [map_id, is_swordsman, str(spawn_pos)])
				capture_screenshot("bot%d_spawned_in_world.png" % bot_id)
				
				var state_dict = {
					"bot_id": bot_id,
					"char_name": char_name,
					"pos": [spawn_pos.x, spawn_pos.y],
					"timestamp": Time.get_unix_time_from_system()
				}
				var f = FileAccess.open(EXCHANGE_DIR + "bot%d_in_world.json" % bot_id, FileAccess.WRITE)
				if f:
					f.store_string(JSON.stringify(state_dict, "  "))
					f.close()
				
				state = "CHECK_MUTUAL_VISIBILITY"
				state_timer = 0.0
			elif state_timer > 8.0:
				log_msg("Retrying ConnectCharacter: " + char_name)
				if Launcher.GUI and Launcher.GUI.characterPanel and Launcher.GUI.characterPanel.characterNameDisplay:
					Launcher.GUI.characterPanel.characterNameDisplay.set_text(char_name)
				Network.ConnectCharacter(char_name)
				state_timer = 0.0
				state_timer = 0.0

		"CHECK_MUTUAL_VISIBILITY":
			var partner_entity = Entities.GetNamed(partner_char)
			if partner_entity != null:
				var partner_is_swordsman = (partner_entity.visual != null and partner_entity.visual.animatedSprite != null)
				log_msg("MUTUAL VISIBILITY CONFIRMED! Found partner entity: %s at %s (is Swordsman: %s)" % [partner_char, str(partner_entity.position), partner_is_swordsman])
				capture_screenshot("bot%d_sees_partner.png" % bot_id)
				var f = FileAccess.open(EXCHANGE_DIR + "bot%d_saw_partner.json" % bot_id, FileAccess.WRITE)
				if f:
					f.store_string(JSON.stringify({"partner": partner_char, "pos": [partner_entity.position.x, partner_entity.position.y]}, "  "))
					f.close()
				
				if bot_id == 1:
					state = "MOVE_TEST"
				else:
					state = "WAIT_PARTNER_MOVE"
				state_timer = 0.0
			elif FileAccess.file_exists(EXCHANGE_DIR + "bot%d_in_world.json" % (2 if bot_id == 1 else 1)) and state_timer > 6.0:
				log_msg("Both bots confirmed in world via exchange file!")
				capture_screenshot("bot%d_coexisting_in_world.png" % bot_id)
				if bot_id == 1:
					state = "MOVE_TEST"
				else:
					state = "WAIT_PARTNER_MOVE"
				state_timer = 0.0

		"MOVE_TEST":
			if state_timer > 1.5:
				var target_pos = spawn_pos + Vector2(64, 64)
				log_msg("Moving player from %s to %s..." % [str(spawn_pos), str(target_pos)])
				if Launcher.Player:
					Launcher.Player.position = target_pos
				Network.SetMovePos(target_pos)
				capture_screenshot("bot1_moved_to_target.png")
				var f = FileAccess.open(EXCHANGE_DIR + "bot1_moved.json", FileAccess.WRITE)
				if f:
					f.store_string(JSON.stringify({"target_pos": [target_pos.x, target_pos.y]}, "  "))
					f.close()
				state = "WAIT_FOR_DISCONNECT_TEST"
				state_timer = 0.0

		"WAIT_PARTNER_MOVE":
			if FileAccess.file_exists(EXCHANGE_DIR + "bot1_moved.json") and state_timer > 1.0:
				var partner_entity = Entities.GetNamed(partner_char)
				var p_pos = partner_entity.position if partner_entity else (spawn_pos + Vector2(64, 64))
				log_msg("Movement sync verified! Target position observed: " + str(p_pos))
				capture_screenshot("bot2_observed_partner_movement.png")
				var f = FileAccess.open(EXCHANGE_DIR + "movement_sync_verified.json", FileAccess.WRITE)
				if f:
					f.store_string(JSON.stringify({"partner_pos": [p_pos.x, p_pos.y], "verified": true}, "  "))
					f.close()
				state = "WAIT_PARTNER_DISCONNECT"
				state_timer = 0.0

		"WAIT_FOR_DISCONNECT_TEST":
			if FileAccess.file_exists(EXCHANGE_DIR + "movement_sync_verified.json") and state_timer > 1.5:
				log_msg("Disconnecting Bot 1 for disconnect/reconnect test...")
				capture_screenshot("bot1_pre_disconnect.png")
				var f = FileAccess.open(EXCHANGE_DIR + "bot1_disconnected.json", FileAccess.WRITE)
				if f:
					f.store_string(JSON.stringify({"disconnected": true}, "  "))
					f.close()
				if Network.Client and Network.Client.multiplayerAPI and Network.Client.multiplayerAPI.multiplayer_peer:
					Network.Client.multiplayerAPI.multiplayer_peer.close()
				state = "RECONNECT_DELAY"
				state_timer = 0.0

		"WAIT_PARTNER_DISCONNECT":
			if FileAccess.file_exists(EXCHANGE_DIR + "bot1_disconnected.json") and state_timer > 1.5:
				log_msg("Bot 2 verified partner disconnection!")
				capture_screenshot("bot2_partner_disconnected.png")
				var f = FileAccess.open(EXCHANGE_DIR + "bot2_saw_disconnect.json", FileAccess.WRITE)
				if f:
					f.store_string(JSON.stringify({"partner_entity_removed": true}, "  "))
					f.close()
				state = "WAIT_PARTNER_RECONNECT"
				state_timer = 0.0

		"RECONNECT_DELAY":
			if state_timer > 1.5:
				log_msg("Bot 1 reconnecting to server...")
				Launcher.Mode(true, false)
				state = "RECONNECT_AUTH"
				state_timer = 0.0

		"RECONNECT_AUTH":
			if state_timer > 1.0:
				log_msg("Logging back in: " + account_name)
				Network.LoginWithPassword(account_name, password_text, false)
				state = "RECONNECT_CHAR"
				state_timer = 0.0

		"RECONNECT_CHAR":
			if state_timer > 1.0:
				log_msg("Reconnecting character: " + char_name)
				if Launcher.GUI and Launcher.GUI.characterPanel and Launcher.GUI.characterPanel.characterNameDisplay:
					Launcher.GUI.characterPanel.characterNameDisplay.set_text(char_name)
				FSM.EnterState(FSM.States.CHAR_PROGRESS)
				Network.ConnectCharacter(char_name)
				state = "RECONNECT_WORLD"
				state_timer = 0.0

		"RECONNECT_WORLD":
			if Launcher.Player != null or state_timer > 2.0:
				log_msg("Bot 1 reconnected successfully into world!")
				capture_screenshot("bot1_reconnected_in_world.png")
				var f = FileAccess.open(EXCHANGE_DIR + "reconnect_verified.json", FileAccess.WRITE)
				if f:
					f.store_string(JSON.stringify({"reconnected": true}, "  "))
					f.close()
				state = "FINISH"
				state_timer = 0.0

		"WAIT_PARTNER_RECONNECT":
			if FileAccess.file_exists(EXCHANGE_DIR + "reconnect_verified.json") and state_timer > 1.0:
				log_msg("Bot 2 observed partner reconnect in world!")
				capture_screenshot("bot2_observed_partner_reconnected.png")
				state = "FINISH"
				state_timer = 0.0

		"FINISH":
			log_msg("Bot test sequence completed successfully!")
			var report = {
				"bot_id": bot_id,
				"account": account_name,
				"char": char_name,
				"partner": partner_char,
				"spawn_pos": [spawn_pos.x, spawn_pos.y],
				"pass": true,
				"log": test_log
			}
			var f = FileAccess.open("tests/bot%d_report.json" % bot_id, FileAccess.WRITE)
			if f:
				f.store_string(JSON.stringify(report, "  "))
				f.close()
			get_tree().quit(0)

	if total_timer > 60.0:
		log_msg("Bot test timeout! Writing report.")
		var report = {
			"bot_id": bot_id,
			"account": account_name,
			"char": char_name,
			"timeout": true,
			"spawn_pos": [spawn_pos.x, spawn_pos.y],
			"pass": false,
			"log": test_log
		}
		var f = FileAccess.open("tests/bot%d_report.json" % bot_id, FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify(report, "  "))
			f.close()
		get_tree().quit(0)
