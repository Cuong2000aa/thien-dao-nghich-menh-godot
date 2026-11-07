extends Node2D

## Guard: trait.shape load must not leave currentShape on default Player (false morph → Swordsman).

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

	print("=== test_hero_shape_sync ===")
	_TestSetStatsSyncsCurrentShape()
	_TestFalseMorphHealed()
	_TestHeroHashesResolvable()

	print("=== RESULT fails=%d ===" % fails)
	get_tree().quit(0 if fails == 0 else 1)

func _TestSetStatsSyncsCurrentShape() -> void:
	var stats := ActorStats.new()
	stats.shape = ActorCommons.PlayerEntityID
	stats.currentShape = ActorCommons.PlayerEntityID
	var assassin : int = HeroLib.GetShapeHash(HeroLib.FindIndexById("assassin"))
	stats.SetStats({"shape": assassin, "level": 1})
	if stats.shape != assassin:
		_fail("SetStats did not apply assassin shape")
	elif stats.currentShape != assassin:
		_fail("SetStats left currentShape on Player (false morph)")
	elif stats.IsMorph():
		_fail("IsMorph true after shape-only SetStats")
	else:
		_ok("SetStats syncs currentShape with assassin shape")

func _TestFalseMorphHealed() -> void:
	var stats := ActorStats.new()
	var wuxia : int = HeroLib.GetShapeHash(HeroLib.FindIndexById("wuxia_swordsman"))
	stats.shape = wuxia
	stats.currentShape = ActorCommons.PlayerEntityID
	if not stats.IsMorph():
		_fail("Expected IsMorph before heal")
		return
	# Mimic Entity.SetData heal
	if HeroLib.IsHeroShape(stats.shape) and stats.currentShape == ActorCommons.PlayerEntityID and stats.shape != ActorCommons.PlayerEntityID:
		stats.currentShape = stats.shape
	if stats.IsMorph():
		_fail("False morph not healed for Kiếm Sĩ")
	else:
		_ok("False morph healed for Kiếm Sĩ")

func _TestHeroHashesResolvable() -> void:
	for i in HeroLib.Count():
		var h : int = HeroLib.GetShapeHash(i)
		if HeroLib.FindIndexByShape(h) != i:
			_fail("Hero hash roundtrip failed for index %d" % i)
			return
	_ok("All hero shape hashes resolve")
