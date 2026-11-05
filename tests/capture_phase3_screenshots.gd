extends Node2D

const SCREENSHOT_DIR = "docs/images/phase3/"
const HubScene : PackedScene = preload("res://assets/environment/SacredSectHub.tscn")
const EntityScene : PackedScene = preload("res://presets/entities/Entity.tscn")
const PlayerDataRes : EntityData = preload("res://presets/entities/Player.tres")

@onready var camera : Camera2D = $Camera2D

var hub_instance : Node2D = null
var fringe : Node2D = null
var player : Entity = null
var second_player : Entity = null

var step : int = 0
var test_done : bool = false

func _ready():
	DirAccess.make_dir_recursive_absolute(SCREENSHOT_DIR)
	
	hub_instance = HubScene.instantiate()
	add_child(hub_instance)
	
	for child in hub_instance.get_children():
		if child is Node2D and child.name == "Fringe":
			fringe = child
			break
			
	assert(fringe != null, "Fringe not found in SacredSectHub")
	
	# Primary player
	player = EntityScene.instantiate()
	player.data = PlayerDataRes
	fringe.add_child(player)
	player.SetData()
	
	# Secondary player for multi-character co-presence
	second_player = EntityScene.instantiate()
	second_player.data = PlayerDataRes
	fringe.add_child(second_player)
	second_player.SetData()
	second_player.position = Vector2(1080, 1050)
	second_player.Update(Vector2.ZERO, second_player.position, Vector2(-1, 0), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
	
	print("=== PHASE 3 SCREENSHOT CAPTURE SCENE INITIALIZED ===")

func _process(_delta: float):
	if test_done:
		return
		
	step += 1
	
	match step:
		5:
			# 1. Sacred Sect Hub Overview
			camera.zoom = Vector2(0.55, 0.55)
			camera.position = Vector2(1000, 900)
			player.position = Vector2(960, 1050)
			player.Update(Vector2.ZERO, player.position, Vector2(0, 1), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		8:
			_capture("01_sacred_sect_hub_overview.png")
			
		12:
			# 2. Main Hall (Shaolin Daxiong Baodian)
			camera.zoom = Vector2(1.0, 1.0)
			camera.position = Vector2(1000, 520)
			player.position = Vector2(1000, 620) # In front of Main Hall entrance steps
			player.Update(Vector2.ZERO, player.position, Vector2(0, -1), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		15:
			_capture("02_main_hall_shaolin.png")
			
		18:
			# 3. Occlusion: Character Behind Building (North of Shaolin footprint)
			camera.zoom = Vector2(1.1, 1.1)
			camera.position = Vector2(1000, 480)
			player.position = Vector2(1000, 450) # Behind main roof
			player.Update(Vector2(0, -80), player.position, Vector2(0, -1), ActorCommons.State.WALK, DB.UnknownHash, true, false)
		21:
			_capture("03_character_behind_building.png")
			
		24:
			# 4. Occlusion: Character In Front of Building (South of Shaolin footprint)
			player.position = Vector2(1000, 620)
			player.Update(Vector2(0, 80), player.position, Vector2(0, 1), ActorCommons.State.WALK, DB.UnknownHash, true, false)
		27:
			_capture("04_character_in_front_building.png")
			
		30:
			# 5. Two Players Coexisting in the Hub
			camera.zoom = Vector2(1.3, 1.3)
			camera.position = Vector2(1020, 1050)
			player.position = Vector2(960, 1050)
			second_player.position = Vector2(1080, 1050)
			player.Update(Vector2.ZERO, player.position, Vector2(1, 0), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
			second_player.Update(Vector2.ZERO, second_player.position, Vector2(-1, 0), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		33:
			_capture("05_two_players_coexisting.png")
			
		36:
			# 6. Idle State (Close up)
			camera.zoom = Vector2(2.0, 2.0)
			camera.position = Vector2(1000, 1050)
			player.position = Vector2(1000, 1050)
			player.Update(Vector2.ZERO, player.position, Vector2(0, 1), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		39:
			_capture("06_character_idle_state.png")
			
		42:
			# 7. Walk State (Close up)
			player.Update(Vector2(120, 0), player.position, Vector2(1, 0), ActorCommons.State.WALK, DB.UnknownHash, true, false)
		45:
			_capture("07_character_walk_state.png")
			
		48:
			print("=== ALL SCREENSHOTS CAPTURED SUCCESSFULLY ===")
			test_done = true
			get_tree().quit(0)

func _capture(filename: String):
	var img = get_viewport().get_texture().get_image()
	if img:
		var p = SCREENSHOT_DIR + filename
		var err = img.save_png(p)
		print("Saved screenshot: ", p, " (status=", err, ")")
