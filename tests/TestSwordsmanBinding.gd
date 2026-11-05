extends Node2D

# Test script for Phase 3 Task A: Swordsman Network Actor Binding & 8-Direction Verification
# Runs within full Godot project context with autoloads initialized.

const SCREENSHOT_DIR = "docs/images/phase3/"
const EntityScene : PackedScene = preload("res://presets/entities/Entity.tscn")
const PlayerDataRes : EntityData = preload("res://presets/entities/Player.tres")

var directions = [
	{"name": "east", "vec": Vector2(1, 0)},
	{"name": "south-east", "vec": Vector2(1, 1).normalized()},
	{"name": "south", "vec": Vector2(0, 1)},
	{"name": "south-west", "vec": Vector2(-1, 1).normalized()},
	{"name": "west", "vec": Vector2(-1, 0)},
	{"name": "north-west", "vec": Vector2(-1, -1).normalized()},
	{"name": "north", "vec": Vector2(0, -1)},
	{"name": "north-east", "vec": Vector2(1, -1).normalized()}
]

var entity : Entity = null
var current_step : int = 0
var test_done : bool = false
var pass_count : int = 0
var test_results : Dictionary = {}

func _ready():
	DirAccess.make_dir_recursive_absolute(SCREENSHOT_DIR)
	print("=== STARTING SWORDSMAN ACTOR BINDING VERIFICATION ===")
	
	# Instantiate Entity with PlayerDataRes (Swordsman)
	entity = EntityScene.instantiate()
	entity.data = PlayerDataRes
	add_child(entity)
	
	# Initialize data
	entity.SetData()
	
	if not entity.visual or not entity.visual.animatedSprite:
		print("FAILED: entity.visual or entity.visual.animatedSprite is null!")
		get_tree().quit(1)
		return
		
	print("SUCCESS: entity.visual.animatedSprite bound successfully!")
	print("Initial animation: ", entity.visual.animatedSprite.animation)

func _process(_delta: float):
	if test_done:
		return
		
	current_step += 1
	
	# Test Idle directions (steps 1..8)
	if current_step >= 1 and current_step <= 8:
		var idx = current_step - 1
		var td = directions[idx]
		entity.Update(Vector2.ZERO, entity.position, td["vec"], ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		var expected_anim = "idle_" + td["name"]
		var actual_anim = entity.visual.animatedSprite.animation
		var expected_offset = -entity.visual.SWORDSMAN_FOOT_OFFSETS["idle"]
		var actual_offset = entity.visual.animatedSprite.offset
		
		var ok = (actual_anim == expected_anim and actual_offset == expected_offset)
		if ok:
			pass_count += 1
			print("PASS [%02d/16]: Idle %s -> anim=%s, offset=%s" % [current_step, td["name"], actual_anim, actual_offset])
		else:
			print("FAIL [%02d/16]: Idle %s -> actual=%s (expected %s), offset=%s" % [current_step, td["name"], actual_anim, expected_anim, actual_offset])
		test_results["idle_" + td["name"]] = {"pass": ok, "anim": actual_anim, "offset": [actual_offset.x, actual_offset.y]}
		
		_capture("direction_%02d_%s.png" % [idx + 1, td["name"]])
			
	# Test Walk directions (steps 9..16)
	elif current_step >= 9 and current_step <= 16:
		var idx = current_step - 9
		var td = directions[idx]
		var vel = td["vec"] * 120.0
		entity.Update(vel, entity.position, td["vec"], ActorCommons.State.WALK, DB.UnknownHash, true, false)
		var expected_anim = "walk_" + td["name"]
		var actual_anim = entity.visual.animatedSprite.animation
		var expected_offset = -entity.visual.SWORDSMAN_FOOT_OFFSETS["walk"]
		var actual_offset = entity.visual.animatedSprite.offset
		
		var ok = (actual_anim == expected_anim and actual_offset == expected_offset)
		if ok:
			pass_count += 1
			print("PASS [%02d/16]: Walk %s -> anim=%s, offset=%s" % [current_step, td["name"], actual_anim, actual_offset])
		else:
			print("FAIL [%02d/16]: Walk %s -> actual=%s (expected %s), offset=%s" % [current_step, td["name"], actual_anim, expected_anim, actual_offset])
		test_results["walk_" + td["name"]] = {"pass": ok, "anim": actual_anim, "offset": [actual_offset.x, actual_offset.y]}
		
		# Capture screenshot of representative walk
		if td["name"] == "north":
			_capture("03_swordsman_walk_north.png")
		elif td["name"] == "east":
			_capture("04_swordsman_walk_east.png")
			
	elif current_step == 18:
		# Capture all 8 directions grid if possible or summary
		print("\n=== SUMMARY ===")
		print("Passed: %d / 16 test cases" % pass_count)
		test_done = true
		
		var report_file = FileAccess.open(SCREENSHOT_DIR + "actor_binding_results.json", FileAccess.WRITE)
		if report_file:
			report_file.store_string(JSON.stringify({
				"total": 16,
				"passed": pass_count,
				"success": pass_count == 16,
				"details": test_results
			}, "  "))
			report_file.close()
			
		if pass_count == 16:
			print("ALL 16 DIRECTION AND STATE TESTS PASSED SUCCESSFULLY!")
			get_tree().quit(0)
		else:
			print("FAILED: Some tests did not pass.")
			get_tree().quit(1)

func _capture(filename: String):
	var img = get_viewport().get_texture().get_image()
	if img:
		var p = SCREENSHOT_DIR + filename
		var err = img.save_png(p)
		print("Captured screenshot: ", p, " (status=", err, ")")
