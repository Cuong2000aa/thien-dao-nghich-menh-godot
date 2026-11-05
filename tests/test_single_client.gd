extends Node

var test_step : int = 0
var timer : float = 0.0
var client_account = "DaoHuu01"
var client_pass = "DaoPass123!"
var client_char = "ThienKiem01"
var results = {}

func _ready():
	print("[TestClient] Starting Single Client Test against local server...")
	# Ensure NetworkCommons.IsLocal is true
	NetworkCommons.IsLocal = true
	Launcher.Mode(true, false)
	
	if Network.Client:
		Network.Client.multiplayerAPI.connected_to_server.connect(_on_connected)
		Network.Client.multiplayerAPI.connection_failed.connect(_on_connect_failed)
		print("[TestClient] Client NetClient initialized. Waiting for connection...")

func _on_connected():
	print("[TestClient] Connected to server successfully via ENet!")
	results["connected"] = true
	# Step 1: Create Account
	_create_or_login()

func _on_connect_failed():
	print("[TestClient] Connection failed!")
	results["connected"] = false
	get_tree().quit(1)

func _create_or_login():
	print("[TestClient] Sending CreateAccount: ", client_account)
	# Connect to auth callback
	Network.CreateAccount(client_account, client_pass, "daohuu01@thiendao.internal", false)

func _process(delta):
	timer += delta
	# Check periodically for progress
	if timer > 2.0 and test_step == 0:
		test_step = 1
		# If account was already created, attempt login
		print("[TestClient] Attempting LoginWithPassword in case account exists...")
		Network.LoginWithPassword(client_account, client_pass, false)
	
	if timer > 4.0 and test_step == 1:
		test_step = 2
		print("[TestClient] Attempting CreateCharacter: ", client_char)
		Network.CreateCharacter(client_char, ActorCommons.DefaultTraits, ActorCommons.DefaultAttributes)

	if timer > 6.0 and test_step == 2:
		test_step = 3
		print("[TestClient] Attempting ConnectCharacter: ", client_char)
		Network.ConnectCharacter(client_char)

	if timer > 9.0 and test_step == 3:
		test_step = 4
		# Check if Player entity spawned
		var player_spawned = Launcher.Player != null
		print("[TestClient] Player spawned check: ", player_spawned)
		results["player_spawned"] = player_spawned
		if Launcher.Player:
			print("[TestClient] Player position: ", Launcher.Player.position)
			results["position"] = [Launcher.Player.position.x, Launcher.Player.position.y]
		
		# Capture screenshot of client
		var img = get_viewport().get_texture().get_image()
		if img:
			DirAccess.make_dir_recursive_absolute("tests/screenshots")
			img.save_png("tests/screenshots/test_client1_spawn.png")
			print("[TestClient] Screenshot saved to tests/screenshots/test_client1_spawn.png")
		
		var f = FileAccess.open("tests/test_client_result.json", FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify(results, "  "))
			f.close()
		
		print("[TestClient] Single client test complete!")
		get_tree().quit(0)

	if timer > 15.0:
		print("[TestClient] Test timed out!")
		get_tree().quit(1)
