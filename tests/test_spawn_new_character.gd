extends Node

var timer : float = 0.0
var client_account : String = "DaoHuu01"
var client_pass : String = "DaoPass123!"
var client_char : String = "TuDao" + str(int(Time.get_unix_time_from_system()) % 10000)
var test_step : int = 0
var results : Dictionary = {}

func _ready():
	print("[NewCharTest] Testing new character spawn in Tulimshar...")
	NetworkCommons.IsLocal = true
	Launcher.Mode(true, false)
	
	if Network.Client:
		Network.Client.multiplayerAPI.connected_to_server.connect(_on_connected)
		Network.Client.multiplayerAPI.connection_failed.connect(_on_connect_failed)
		print("[NewCharTest] Client NetClient initialized. Connecting...")

func _on_connected():
	print("[NewCharTest] Connected via ENet!")
	results["connected"] = true
	print("[NewCharTest] Logging in with existing account: ", client_account)
	Network.LoginWithPassword(client_account, client_pass, false)

func _on_connect_failed():
	print("[NewCharTest] Connection failed!")
	results["connected"] = false
	get_tree().quit(1)

func _process(delta):
	timer += delta
	
	if timer > 2.0 and test_step == 0:
		test_step = 1
		print("[NewCharTest] Retrying login in case needed...")
		Network.LoginWithPassword(client_account, client_pass, false)
		
	if timer > 4.0 and test_step == 1:
		test_step = 2
		print("[NewCharTest] Creating new character: ", client_char)
		var hairstyles : PackedInt64Array = DB.HairstylesDB.keys()
		var haircolors : Array = DB.PalettesDB[DB.Palette.HAIR].keys() if (DB.PalettesDB.has(DB.Palette.HAIR) and DB.PalettesDB[DB.Palette.HAIR] is Dictionary) else []
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
			"strength": 1,
			"vitality": 1,
			"agility": 1,
			"endurance": 1,
			"concentration": 1
		}
		Network.CreateCharacter(client_char, traits, attrs)
		
	if timer > 6.0 and test_step == 2:
		test_step = 3
		print("[NewCharTest] Connecting new character: ", client_char)
		Network.ConnectCharacter(client_char)
			
	# Check spawn after connecting
	if timer > 9.0 and test_step == 3:
		test_step = 4
		var player_spawned = Launcher.Player != null
		print("[NewCharTest] Player spawned check: ", player_spawned)
		
		if Launcher.Player and Launcher.Map:
			var current_map_id = Launcher.Map.currentMapID
			var tulimshar_id = "Tulimshar".hash()
			var pos = Launcher.Player.position
			var display_name = LocationNaming.GetDisplayName(current_map_id)
			
			print("\n==========================================")
			print("[NewCharTest] SUCCESS: Player spawned in world!")
			print("[NewCharTest] Map ID: ", current_map_id, " (Expected Tulimshar: ", tulimshar_id, ")")
			print("[NewCharTest] Map Display Name: ", display_name)
			print("[NewCharTest] Player Position: ", pos)
			print("==========================================")
			
			results["map_id"] = current_map_id
			results["map_name"] = display_name
			results["position"] = [pos.x, pos.y]
			
			var map_match = (current_map_id == tulimshar_id)
			var pos_match = (abs(pos.x - 2176) <= 64) and (abs(pos.y - 2560) <= 32)
			var name_match = (display_name == "Thanh Sa Cảng")
			
			print("[NewCharTest] Check 1 (Map is Tulimshar): ", map_match)
			print("[NewCharTest] Check 2 (Pos within (2176,2560) ± (64,32)): ", pos_match)
			print("[NewCharTest] Check 3 (Display name is 'Thanh Sa Cảng'): ", name_match)
			
			if map_match and pos_match and name_match:
				print("\n>>> EMPIRICAL VERIFICATION COMPLETE: ALL CHECKS PASSED! <<<")
				get_tree().quit(0)
				return
			else:
				print("\n>>> CHECKS FAILED! <<<")
				get_tree().quit(1)
				return
		else:
			print("FAILED: Player or Map was null at check time!")
			get_tree().quit(1)
			return

	if timer > 20.0:
		print("[NewCharTest] Test timed out after 20 seconds!")
		get_tree().quit(1)
