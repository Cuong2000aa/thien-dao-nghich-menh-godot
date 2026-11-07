extends Node2D

## Ensures hero shape is preserved (not forced to default Swordsman/Player).

const HeroLib = preload("res://sources/actor/HeroLibrary.gd")

var fails : int = 0

func _fail(msg : String) -> void:
	fails += 1
	print("FAIL: ", msg)

func _ok(msg : String) -> void:
	print("OK: ", msg)

func _ready():
	if not DB.isInitialized:
		await Launcher.dbInitialized

	print("=== test_hero_shape_equip ===")
	_TestHeroLibraryShapes()
	_TestMapDoesNotForcePlayerShape()

	print("=== RESULT fails=%d ===" % fails)
	get_tree().quit(0 if fails == 0 else 1)

func _TestHeroLibraryShapes() -> void:
	var playerHash : int = "Player".hash()
	var assassinHash : int = "PlayerAssassin".hash()
	var wuxiaHash : int = "PlayerWuxiaSword".hash()
	if HeroLib.FindIndexByShape(playerHash) != 0:
		_fail("Player shape should be hero index 0")
	else:
		_ok("Player → Kiếm Khách idx 0")
	if HeroLib.FindIndexByShape(assassinHash) < 0:
		_fail("PlayerAssassin not registered as hero")
	else:
		_ok("PlayerAssassin hero idx %d" % HeroLib.FindIndexByShape(assassinHash))
	if HeroLib.FindIndexByShape(wuxiaHash) < 0:
		_fail("PlayerWuxiaSword not registered as hero")
	else:
		_ok("PlayerWuxiaSword hero idx %d" % HeroLib.FindIndexByShape(wuxiaHash))
	if not HeroLib.IsHeroShape(assassinHash):
		_fail("IsHeroShape(assassin) false")
	else:
		_ok("IsHeroShape assassin")

func _TestMapDoesNotForcePlayerShape() -> void:
	# Simulate cache entry: assassin base shape must survive spawn assignment logic
	var entryShape : int = "PlayerAssassin".hash()
	var HeroLibLocal = HeroLib
	var baseShape : int = entryShape
	if not HeroLibLocal.IsHeroShape(baseShape):
		baseShape = ActorCommons.PlayerEntityID
	if baseShape != entryShape:
		_fail("Spawn logic would overwrite assassin with Player")
	else:
		_ok("Spawn keeps assassin base shape")
