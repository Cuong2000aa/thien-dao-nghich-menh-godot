extends SceneTree

# Test script for Phase 3 Task A: Swordsman Network Actor Binding & 8-Direction Verification

const SCREENSHOT_DIR = "docs/images/phase3/"
const EntityScene : PackedScene = preload("res://sources/actor/entity/Entity.tscn")
const PlayerDataRes : EntityData = preload("res://presets/entities/Player.tres")

const TEST_DIRECTIONS = [
	{"name": "east", "vec": Vector2(1, 0)},
	{"name": "south-east", "vec": Vector2(1, 1).normalized()},
	{"name": "south", "vec": Vector2(0, 1)},
	{"name": "south-west", "vec": Vector2(-1, 1).normalized()},
	{"name": "west", "vec": Vector2(-1, 0)},
	{"name": "north-west", "vec": Vector2(-1, -1).normalized()},
	{"name": "north", "vec": Vector2(0, -1)},
	{"name": "north-east", "vec": Vector2(1, -1).normalized()}
]

func _init():
	print("=== STARTING SWORDSMAN ACTOR BINDING TEST ===")
	DirAccess.make_dir_recursive_absolute(SCREENSHOT_DIR)
	
	# Create test root node
	var root_node = Node2D.new()
	root.add_child(root_node)
	
	# Instantiate Entity
	var entity : Entity = EntityScene.instantiate()
	entity.data = PlayerDataRes
	root_node.add_child(entity)
	
	# Initialize entity data
	entity.SetData()
	
	if not entity.visual or not entity.visual.animatedSprite:
		print("FAILED: entity.visual or entity.visual.animatedSprite is null!")
		quit(1)
		return
	
	print("SUCCESS: entity.visual.animatedSprite bound successfully!")
	print("Initial animation: ", entity.visual.animatedSprite.animation)
	
	var pass_count = 0
	
	# Test stationary facing directions (Idle)
	print("\n--- Testing Idle 8 Directions ---")
	for td in TEST_DIRECTIONS:
		entity.Update(Vector2.ZERO, entity.position, td["vec"], ActorCommons.State.IDLE, DB.UnknownHash, true, false)
		var expected_anim = "idle_" + td["name"]
		var actual_anim = entity.visual.animatedSprite.animation
		var expected_offset = -entity.visual.SWORDSMAN_FOOT_OFFSETS["idle"]
		var actual_offset = entity.visual.animatedSprite.offset
		
		if actual_anim == expected_anim and actual_offset == expected_offset:
			print("PASS: Idle direction %s -> anim=%s, offset=%s" % [td["name"], actual_anim, actual_offset])
			pass_count += 1
		else:
			print("FAIL: Idle direction %s -> actual anim=%s (expected %s), offset=%s" % [td["name"], actual_anim, expected_anim, actual_offset])
	
	# Test moving directions (Walk)
	print("\n--- Testing Walk 8 Directions ---")
	for td in TEST_DIRECTIONS:
		var vel = td["vec"] * 120.0
		entity.Update(vel, entity.position, td["vec"], ActorCommons.State.WALK, DB.UnknownHash, true, false)
		var expected_anim = "walk_" + td["name"]
		var actual_anim = entity.visual.animatedSprite.animation
		var expected_offset = -entity.visual.SWORDSMAN_FOOT_OFFSETS["walk"]
		var actual_offset = entity.visual.animatedSprite.offset
		
		if actual_anim == expected_anim and actual_offset == expected_offset:
			print("PASS: Walk direction %s -> anim=%s, offset=%s" % [td["name"], actual_anim, actual_offset])
			pass_count += 1
		else:
			print("FAIL: Walk direction %s -> actual anim=%s (expected %s), offset=%s" % [td["name"], actual_anim, expected_anim, actual_offset])
	
	print("\n=== SWORDSMAN BINDING VERIFICATION RESULT ===")
	print("Passed: %d / 16 tests" % pass_count)
	if pass_count == 16:
		print("ALL 8-DIRECTION ACTOR BINDING TESTS PASSED!")
		quit(0)
	else:
		print("SOME TESTS FAILED!")
		quit(1)
