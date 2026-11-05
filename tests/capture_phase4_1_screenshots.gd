extends Node2D

const SCREENSHOT_DIR = "docs/images/phase4_1/"
const VillageScene : PackedScene = preload("res://presets/maps/layers/xianxia/TanThuThon.tscn")
const EntityScene : PackedScene = preload("res://presets/entities/Entity.tscn")
const PlayerDataRes : EntityData = preload("res://presets/entities/Player.tres")

@onready var camera : Camera2D = $Camera2D

var village_instance : Node2D = null
var fringe : Node2D = null
var player : Entity = null
var second_player : Entity = null

var step : int = 0
var test_done : bool = false

func _ready():
	DirAccess.make_dir_recursive_absolute(SCREENSHOT_DIR)
	
	# Disable all debug visualizations
	get_tree().debug_collisions_hint = false
	get_tree().debug_paths_hint = false
	get_tree().debug_navigation_hint = false
	
	# Immediately hide/kill any Launcher GUI or Source client node
	if Launcher.GUI:
		Launcher.GUI.visible = false
	var source_node = get_tree().root.get_node_or_null("Source")
	if source_node:
		source_node.visible = false
	
	camera.make_current()
	
	village_instance = VillageScene.instantiate()
	add_child(village_instance)
	
	# Free all debug collision shapes from the screenshot viewport
	for node in village_instance.find_children("*", "CollisionShape2D", true, false):
		node.queue_free()
	for node in village_instance.find_children("*", "CollisionPolygon2D", true, false):
		node.queue_free()
	var bounds = village_instance.get_node_or_null("Boundaries")
	if bounds:
		bounds.queue_free()
	
	for child in village_instance.get_children():
		if child is Node2D and child.name == "Fringe":
			fringe = child
			break
			
	assert(fringe != null, "Fringe not found in TanThuThon")
	
	# Primary player
	player = EntityScene.instantiate()
	player.data = PlayerDataRes
	fringe.add_child(player)
	player.SetData()
	
	# Secondary player
	second_player = EntityScene.instantiate()
	second_player.data = PlayerDataRes
	fringe.add_child(second_player)
	second_player.SetData()
	second_player.position = Vector2(1680, 1300)
	second_player.Update(Vector2.ZERO, second_player.position, Vector2(-1, 0), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
	
	print("=== SCENE TREE NODES ===")
	_print_tree(get_tree().root)
	print("========================")
	
	print("=== PHASE 4.1 SCREENSHOT CAPTURE SCENE INITIALIZED ===")

func _print_tree(node: Node, indent: String = ""):
	print(indent + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		_print_tree(child, indent + "  ")

func _process(_delta: float):
	if test_done:
		return
		
	# Ensure Source / CanvasLayer GUI is completely hidden and doesn't draw over screenshots
	for child in get_tree().root.get_children():
		if child != self:
			if child is CanvasItem:
				child.visible = false
			elif child is CanvasLayer:
				child.visible = false
			if child.has_node("Canvas"):
				var c = child.get_node("Canvas")
				if c is CanvasLayer or c is CanvasItem:
					c.visible = false
	if Launcher.GUI:
		Launcher.GUI.visible = false

	step += 1
	
	match step:
		5:
			# 1. Panoramic Overview
			camera.zoom = Vector2(0.42, 0.42)
			camera.position = Vector2(1600, 1200)
			player.position = Vector2(1600, 1300)
			player.Update(Vector2.ZERO, player.position, Vector2(0, 1), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		8:
			_capture("01_tan_thu_thon_panoramic.png")
			
		12:
			# 2. Zone A: Village Center & Ancestral Hall
			camera.zoom = Vector2(1.0, 1.0)
			camera.position = Vector2(1600, 1180)
			player.position = Vector2(1600, 1200)
			player.Update(Vector2.ZERO, player.position, Vector2(0, -1), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		15:
			_capture("02_zone_a_village_center.png")
			
		18:
			# 3. Zone B: Residential Quarters
			camera.zoom = Vector2(0.9, 0.9)
			camera.position = Vector2(1050, 1200)
			player.position = Vector2(1080, 1250)
			player.Update(Vector2.ZERO, player.position, Vector2(-1, 0), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		21:
			_capture("03_zone_b_residential_cluster.png")
			
		24:
			# 4. Zone C: Spiritual Herb Farm & Granary
			camera.zoom = Vector2(0.95, 0.95)
			camera.position = Vector2(1080, 1920)
			player.position = Vector2(1050, 1900)
			player.Update(Vector2.ZERO, player.position, Vector2(0, 1), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		27:
			_capture("04_zone_c_herb_farm.png")
			
		30:
			# 5. Zone D: Peach Blossom Grove
			camera.zoom = Vector2(0.85, 0.85)
			camera.position = Vector2(2500, 750)
			player.position = Vector2(2450, 780)
			player.Update(Vector2.ZERO, player.position, Vector2(1, 0), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		33:
			_capture("05_zone_d_peach_grove.png")
			
		36:
			# 6. Zone E: Stream, Watermill & Covered Bridge
			camera.zoom = Vector2(0.95, 0.95)
			camera.position = Vector2(1950, 1200)
			player.position = Vector2(1950, 1260) # Standing right on covered bridge
			player.Update(Vector2(60, 0), player.position, Vector2(1, 0), ActorCommons.State.WALK, DB.UnknownHash, true, false)
		39:
			_capture("06_zone_e_stream_watermill_bridge.png")
			
		42:
			# 7. Zone F: Moon Gate & Teleport Array
			camera.zoom = Vector2(1.0, 1.0)
			camera.position = Vector2(2650, 1260)
			player.position = Vector2(2750, 1260) # On teleport platform
			player.Update(Vector2.ZERO, player.position, Vector2(0, 1), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		45:
			_capture("07_zone_f_village_gate_portal.png")
			
		48:
			# 8. Y-Sort Depth Occlusion (Behind Thatched Cottage roof)
			camera.zoom = Vector2(1.5, 1.5)
			camera.position = Vector2(1120, 1200)
			player.position = Vector2(1120, 1180) # Behind cottage roof
			player.Update(Vector2(0, 60), player.position, Vector2(0, 1), ActorCommons.State.WALK, DB.UnknownHash, true, false)
		51:
			_capture("08_y_sort_depth_occlusion.png")
			
		54:
			# 9. Two Swordsmen in Village Square
			camera.zoom = Vector2(1.2, 1.2)
			camera.position = Vector2(1600, 1300)
			player.position = Vector2(1540, 1300)
			second_player.position = Vector2(1660, 1300)
			player.Update(Vector2.ZERO, player.position, Vector2(1, 0), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
			second_player.Update(Vector2.ZERO, second_player.position, Vector2(-1, 0), ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		57:
			_capture("09_two_swordsmen_village_square.png")
			
		60:
			print("=== ALL PHASE 4.1 SCREENSHOTS CAPTURED SUCCESSFULLY ===")
			test_done = true
			get_tree().quit(0)

func _capture(filename: String):
	var img = get_viewport().get_texture().get_image()
	if img:
		var p = SCREENSHOT_DIR + filename
		var err = img.save_png(p)
		print("Saved screenshot: ", p, " (status=", err, ")")
