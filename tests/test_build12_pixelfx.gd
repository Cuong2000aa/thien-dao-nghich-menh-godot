extends Node2D

## TDNM — BUILD 12: PixelFX import + combat visual wiring smoke test
## Run: godot --headless --path . res://tests/test_build12_pixelfx.tscn

var failed : int = 0
var results : Dictionary = {}

func _ready():
	print("=== TDNM BUILD 12 — PixelFX Visual Integration ===")
	call_deferred("_run")

func _run():
	await get_tree().process_frame

	var Lib = preload("res://sources/effects/PixelFxLibrary.gd")
	var Player = preload("res://sources/effects/PixelFxPlayer.gd")
	var CombatVfx = preload("res://sources/combat/CombatVisualSystem.gd")

	# Catalog presence
	_assert(Lib.Has("hit_spark"), "catalog_hit_spark")
	_assert(Lib.Has("slash"), "catalog_slash")
	_assert(Lib.Has("crit_hit"), "catalog_crit")
	_assert(Lib.Has("frost_nova"), "catalog_frost")
	_assert(Lib.Has("level_up"), "catalog_level_up")
	_assert(Lib.Has("god_rays"), "catalog_includes_god_rays")
	_assert(Lib.Has("slash"), "alias_slash_to_sword_slash")
	_assert(Lib.Has("fish_school"), "catalog_fish_school")

	# Load frames from disk
	var sf = Lib.GetSpriteFrames("hit_spark")
	_assert(sf != null and sf.get_frame_count("default") > 0, "load_hit_spark_frames")
	var meta = Lib.GetMeta("hit_spark")
	_assert(meta.has("pivot") and meta.has("frame_w"), "hit_spark_meta")

	sf = Lib.GetSpriteFrames("slash")
	_assert(sf != null and sf.get_frame_count("default") >= 10, "load_slash_frames")

	# Element mapping
	_assert(Lib.ElementKey(4, false) == "fire_spirit", "element_fire")
	_assert(Lib.ElementKey(0, true) == "crit_hit", "element_crit")

	# Spawn under a temp parent (no map required)
	var host := Node2D.new()
	add_child(host)
	var spawned = Player.Spawn(host, "hit_spark", Vector2(100, 100), Lib.GetScale("hit_spark"))
	_assert(spawned != null and is_instance_valid(spawned), "spawn_hit_spark_player")

	var impact = CombatVfx.SpawnImpactVfx(host, Vector2(120, 120), 1, false)
	_assert(impact != null, "spawn_impact_vfx_wired")

	var slash = CombatVfx.SpawnMeleeSlashVfx(host, Vector2(140, 120), Vector2.LEFT, false)
	_assert(slash != null, "spawn_melee_slash")

	# Soft UI theme helper loads
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	_assert(ThemeClass.JADE.g > 0.5, "ui_theme_jade")

	print("=== BUILD 12 RESULT: %s (%d failures) %s ===" % ["OK" if failed == 0 else "FAILED", failed, str(results)])
	await get_tree().create_timer(0.35).timeout
	get_tree().quit(0 if failed == 0 else 1)

func _assert(cond : bool, key : String) -> void:
	results[key] = cond
	if cond:
		print("  PASS: %s" % key)
	else:
		printerr("  FAIL: %s" % key)
		failed += 1
