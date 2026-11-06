extends Node

const Localization = preload("res://sources/system/Localization.gd")

# Common singletons
var Root : Node						= null
var Scene : Node2D					= null

# Client services
var Action : ServiceBase			= null
var Audio : AudioStreamPlayer		= null
var GUI : ServiceBase				= null
var Debug : ServiceBase				= null
var Camera : ServiceBase			= null
var Map : ServiceBase				= null

# Server services
var World : ServiceBase				= null
var SQL : ServiceBase				= null
var Discord : ServiceBase			= null
var Email : EmailService			= null

# Accessors
var Player : Entity					= null

# Signals
signal launchModeUpdated
signal dbInitialized
signal shadersWarmed

#
## forceRestart: required for BUILD 11 Host/Offline when topology looks unchanged
## (still client+server) but SessionManager flags changed (listen socket vs in-process).
func Mode(launchClient : bool = false, launchServer : bool = false, forceRestart : bool = false) -> bool:
	var isClientConnected : bool = Network.Client != null
	var isServerConnected : bool = Network.ENetServer != null or Network.WebSocketServer != null
	if not forceRestart and isClientConnected == launchClient and isServerConnected == launchServer:
		return false

	Launcher.Reset(false, false)
	Network.Destroy()
	if launchClient:	Client()
	if launchServer:	Server()
	Network.Mode(launchClient, launchServer)

	DB.Init()
	_post_launch()
	launchModeUpdated.emit(launchClient, launchServer)
	return true

func Client():
	if OS.is_debug_build():
		Debug		= DebugService.new()

	# Load then low-prio services on which the order is not important
	Action			= ActionService.new()
	Camera			= CameraService.new()
	Map				= MapService.new()

	add_child.call_deferred(Action)

func Server():
	World			= WorldService.new()
	SQL				= SQLService.new()
	Discord			= DiscordService.new()
	Email			= EmailService.new()

	add_child.call_deferred(World)
	add_child.call_deferred(SQL)
	add_child.call_deferred(Discord)
	add_child.call_deferred(Email)

func Reset(clientStarted : bool, serverStarted : bool):
	if not clientStarted:
		if Debug:
			Debug.Destroy()
			Debug.queue_free()
			Debug = null
		if Action:
			Action.set_name("ActionDestroyed")
			Action.Destroy()
			Action.queue_free()
			Action = null
		if Camera:
			Camera.Destroy()
			Camera.queue_free()
			Camera = null
		if Map:
			Map.Destroy()
			Map.queue_free()
			Map = null
		if GUI:
			GUI.Destroy()
			# GUI is not cleared, but all signals should be re-connected
		if Network.Client:
			Network.Client.Destroy()
			Network.Client = null
		if Player:
			Player.queue_free()
			Player = null

	if not serverStarted:
		if Network.ENetServer:
			Network.ENetServer.Destroy()
			Network.ENetServer = null
		if Network.WebSocketServer:
			Network.WebSocketServer.Destroy()
			Network.WebSocketServer = null
		if World:
			World.set_name("WorldDestroyed")
			World.Destroy()
			World.queue_free()
			World = null
		if SQL:
			SQL.set_name("SQLDestroyed")
			SQL.Destroy()
			SQL.queue_free()
			SQL = null
		if Discord:
			Discord.set_name("DiscordDestroyed")
			Discord.Destroy()
			Discord.queue_free()
			Discord = null
		if Email:
			Email.queue_free()
			Email = null

func Quit():
	Reset(false, false)
	Network.Destroy()
	Root.remove_child(Scene)
	Scene.free()
	Network.queue_free()
	get_tree().quit()

#
func _init():
	Conf.Init()
	Monitoring.Init()
	Localization.Init()

func _ready():
	var startClient : bool = false
	var startServer : bool = false

	Root = get_tree().get_root()
	# Mobile web: detect phone browser before GUI/settings so sticks + scale apply
	LauncherCommons.RefreshPlatformFlags()
	if LauncherCommons.isMobile:
		Util.PrintLog("Launcher", "Mobile UI mode (sticks + scale) — web=%s" % str(LauncherCommons.isWeb))

	if "--local" in OS.get_cmdline_args():
		NetworkCommons.IsLocal = true
	elif OS.has_feature("web"):
		var isLocalHost = JavaScriptBridge.eval("window.location.hostname === '127.0.0.1' || window.location.hostname === 'localhost' || window.location.search.includes('local')")
		if isLocalHost:
			NetworkCommons.IsLocal = true

	if "--server" in OS.get_cmdline_args():
		Scene = FileSystem.LoadResource(Path.Pst + "Server" + Path.SceneExt)
		Root.add_child.call_deferred(Scene)
		Engine.set_max_fps(LauncherCommons.ServerMaxFPS)
		Engine.set_physics_ticks_per_second(LauncherCommons.ServerMaxFPS)
		startServer = true
	elif "--world-eval" in OS.get_cmdline_args():
		Scene = FileSystem.LoadResource("res://assets/environment/WorldIntegrationScene.tscn")
		Root.add_child.call_deferred(Scene)
		return
	else:
		Scene = FileSystem.LoadResource(Path.Pst + "Client" + Path.SceneExt)
		Root.add_child.call_deferred(Scene)
		GUI = Scene.get_node("Canvas")
		Audio = Scene.get_node("Audio")
		startClient = true
		# Web Pages / browser: always start Offline-first (in-process client+server).
		# Browser cannot reliably Host sockets or reach SoM public gateways from GitHub Pages.
		if LauncherCommons.isWeb:
			startServer = true
		else:
			startServer = OS.is_debug_build() and not NetworkCommons.IsLocal

	if not Root or not Scene:
		printerr("Could not initialize source's base services")
		Quit()

	Mode(startClient, startServer)
	await Scene.ready

	_post_launch()
	_check_web_autologin.call_deferred()

func _check_web_autologin():
	if not OS.has_feature("web"):
		return
	var auto = JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('autologin')")
	if not auto:
		return
	var acc = str(JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('account') || 'DaoHuuEdge'"))
	var charname = str(JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('char') || 'KiemTuEdge'"))
	print("[WebAutoPlay] Starting Web autologin for account: %s, char: %s" % [acc, charname])
	_run_autologin(acc, charname)

func _run_autologin(acc : String, charname : String):
	while not Network.IsServerReachable():
		await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(0.5).timeout

	print("[WebAutoPlay] Server reachable! Sending LoginWithPassword: %s" % acc)
	Network.LoginWithPassword(acc, "password123", false, NetworkCommons.GetPlatform())

	var login_wait : float = 0.0
	while FSM.currentState != FSM.States.CHAR_SCREEN and login_wait < 2.0:
		await get_tree().create_timer(0.2).timeout
		login_wait += 0.2

	if FSM.currentState != FSM.States.CHAR_SCREEN:
		print("[WebAutoPlay] Not in CHAR_SCREEN yet, trying CreateAccount: %s" % acc)
		Network.CreateAccount(acc, "password123", "edge@som.org", false, NetworkCommons.GetPlatform())
		login_wait = 0.0
		while FSM.currentState != FSM.States.CHAR_SCREEN and login_wait < 3.0:
			await get_tree().create_timer(0.2).timeout
			login_wait += 0.2

	if FSM.currentState != FSM.States.CHAR_SCREEN:
		print("[WebAutoPlay] FAILED to reach CHAR_SCREEN. Current state: %d" % FSM.currentState)
		return

	print("[WebAutoPlay] In CHAR_SCREEN! Attempting CreateCharacter (fallback) & ConnectCharacter: %s" % charname)
	var traits : Dictionary = {}
	var attrs : Dictionary = {}
	if GUI and GUI.characterPanel:
		if GUI.characterPanel.traitsPanel:
			traits = GUI.characterPanel.traitsPanel.GetValues()
		if GUI.characterPanel.attributesPanel:
			attrs = GUI.characterPanel.attributesPanel.GetValues()
	if traits.is_empty():
		var hairstyles : PackedInt64Array = DB.HairstylesDB.keys()
		var haircolors : PackedInt64Array = DB.PalettesDB[DB.Palette.HAIR].keys() if DB.Palette.HAIR in DB.PalettesDB else []
		var races : PackedInt64Array = DB.RacesDB.keys()
		var race : RaceData = DB.GetRace(races[0]) if races.size() > 0 else null
		var skinsKeys : Array = race.skins.keys() if race and race.skins else ["Medium"]
		traits = {
			"hairstyle": hairstyles[0] if hairstyles.size() > 0 else "Bald".hash(),
			"haircolor": haircolors[0] if haircolors.size() > 0 else "Ash Brown".hash(),
			"race": races[0] if races.size() > 0 else "Human".hash(),
			"skintone": skinsKeys[0].hash() if skinsKeys.size() > 0 else "Medium".hash(),
			"gender": 0,
			"shape": "Player".hash(),
			"spirit": "Piou".hash()
		}
	Network.CreateCharacter(charname, traits, attrs)
	# Web SQLite + char panel refresh can lag past 1s
	await get_tree().create_timer(2.5).timeout

	print("[WebAutoPlay] Connecting character: %s" % charname)
	if GUI and GUI.characterPanel and GUI.characterPanel.characterNameDisplay:
		GUI.characterPanel.characterNameDisplay.set_text(charname)
	FSM.EnterState(FSM.States.CHAR_PROGRESS)
	Network.ConnectCharacter(charname)

	# Web map/pck load often exceeds 5s before Entity pushes IN_GAME
	var world_wait : float = 0.0
	var world_timeout : float = 60.0 if LauncherCommons.isWeb else 15.0
	while FSM.currentState != FSM.States.IN_GAME and world_wait < world_timeout:
		await get_tree().create_timer(0.2).timeout
		world_wait += 0.2

	if FSM.currentState != FSM.States.IN_GAME:
		print("[WebAutoPlay] FAILED to enter IN_GAME. Current state: %d after %.1fs" % [FSM.currentState, world_wait])
		return

	print("[WebAutoPlay] SUCCESS! ENTERED WORLD AS %s IN MAP: %s" % [charname, str(Map.currentMapID if Map else "unknown")])
	await get_tree().create_timer(1.0).timeout
	if GUI and GUI.messageBox and GUI.messageBox.is_visible():
		GUI.messageBox.Clear()
	if Player:
		var has_swordsman : bool = Player.has_node("Visual/Preset/AnimatedSprite2D")
		print("[WebAutoPlay] Spawn position: %s, is Swordsman: %s" % [str(Player.position), str(has_swordsman)])

	await _web_autoplay_first_quest()

	# Automated Movement Sequence in Sacred Sect Hub:
	# 1. Move East for 2 seconds
	print("[WebAutoPlay] Moving East...")
	Network.SetMovePos(Vector2(1, 0))
	await get_tree().create_timer(2.0).timeout
	if Player:
		print("[WebAutoPlay] Position after moving East: %s" % str(Player.position))

	# 2. Move South for 2 seconds
	print("[WebAutoPlay] Moving South...")
	Network.SetMovePos(Vector2(0, 1))
	await get_tree().create_timer(2.0).timeout
	if Player:
		print("[WebAutoPlay] Position after moving South: %s" % str(Player.position))

	# 3. Stop
	Network.SetMovePos(Vector2.ZERO)
	print("[WebAutoPlay] Movement sequence complete! Final position: %s" % str(Player.position if Player else "none"))

## First playable quest: Khảo Nghiệm Nhập Môn (Tiếp Dẫn Chấp Sự) + open Chương 1 story.
func _web_autoplay_first_quest():
	var agent : PlayerAgent = Peers.GetAgent(NetworkCommons.PeerAuthorityID)
	if agent == null:
		agent = Peers.GetAgent(NetworkCommons.PeerOfflineID)
	if agent == null:
		print("[WebAutoPlay] FIRST_QUEST FAILED: no PlayerAgent")
		return

	var StorySystemClass = preload("res://sources/story/StorySystem.gd")
	var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
	var qid : int = ProgressCommons.Quest.NHAP_MON_KHAO_NGHIEM

	print("[WebAutoPlay] FIRST_QUEST start: Khảo Nghiệm Nhập Môn")
	NpcCommons.SetQuest(agent, qid, ProgressCommons.NHAP_MON_KHAO_NGHIEM.STARTED)
	await get_tree().create_timer(0.3).timeout
	NpcCommons.SetQuest(agent, qid, ProgressCommons.NHAP_MON_KHAO_NGHIEM.OBJECTIVE_MET)
	await get_tree().create_timer(0.2).timeout
	NpcCommons.SetQuest(agent, qid, ProgressCommons.CompletedProgress)

	SectSystemClass.SetDiscipleRank(agent, SectSystemClass.DiscipleRank.TAP_DICH)
	SectSystemClass.AddContribution(agent, 20, "Nhập Môn Tông Môn Lễ Bao")
	if agent.stat:
		agent.stat.SetExperience(30)
		agent.stat.SetMoney(50)

	var tokenCell = DB.GetItem(DB.GetCellHash("Tap Dich Lenh Bai"))
	if tokenCell and agent.inventory:
		agent.inventory.AddItem(tokenCell, 1)

	StorySystemClass.SetCurrentChapter(agent, StorySystemClass.StoryChapter.CHAPTER_1_STRANGER, 0)

	var qState : int = agent.progress.GetQuest(qid) if agent.progress else ProgressCommons.UnknownProgress
	var rank : int = SectSystemClass.GetDiscipleRank(agent)
	var chapter : int = StorySystemClass.GetCurrentChapter(agent)
	if qState == ProgressCommons.CompletedProgress and rank == SectSystemClass.DiscipleRank.TAP_DICH:
		print("[WebAutoPlay] FIRST_QUEST SUCCESS: Khảo Nghiệm Nhập Môn done | rank=Tạp Dịch | story=Chương %d" % chapter)
	else:
		print("[WebAutoPlay] FIRST_QUEST FAILED: questState=%d rank=%d chapter=%d" % [qState, rank, chapter])
	Network.PushNotification("WebAutoPlay: đã hoàn thành nhiệm vụ đầu — Khảo Nghiệm Nhập Môn", agent.peerID)

# Call _post_launch functions for service depending on other services
func _post_launch():
	if Camera and not Camera.isInitialized:		Camera._post_launch()
	if Map and not Map.isInitialized:			Map._post_launch()
	if GUI and not GUI.isInitialized:			GUI._post_launch()
	if Debug and not Debug.isInitialized:		Debug._post_launch()
	if World and not World.isInitialized:		World._post_launch()
	if SQL and not SQL.isInitialized:			SQL._post_launch()
	if Discord and not Discord.isInitialized:	Discord._post_launch()
	if Audio:									Audio._post_launch()

func _quit():
	Quit()
