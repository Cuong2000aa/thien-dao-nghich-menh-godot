extends Node2D

## TDNM — QA: skill↔martial map, impact one-shot keys, xianxia VFX spawn, web guards
## Run: godot --headless --path . res://tests/test_xianxia_vfx_wiring.tscn

var failed : int = 0
var results : Dictionary = {}

func _ready():
	print("=== TDNM QA — Xianxia VFX Wiring ===")
	call_deferred("_run")

func _run():
	await get_tree().process_frame

	var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
	var CombatVfx = preload("res://sources/combat/CombatVisualSystem.gd")
	var Lib = preload("res://sources/effects/PixelFxLibrary.gd")

	# P0 — SkillCell.id maps into MARTIAL_CATALOG (not empty / not mana_burst fallback)
	var m401 = CombatSystemClass.GetMartialForSkill(182736401)
	_assert(not m401.is_empty() and int(m401.get("id", 0)) == 1002, "map_thanh_phong_kiem_khi")
	_assert(int(m401.get("element", -1)) == CombatSystemClass.Element.WOOD, "elem_thanh_phong_wood")

	var m402 = CombatSystemClass.GetMartialForSkill(182736402)
	_assert(int(m402.get("id", 0)) == 1003, "map_truc_son")

	var m403 = CombatSystemClass.GetMartialForSkill(182736403)
	_assert(int(m403.get("id", 0)) == 1004, "map_dap_phong")

	var m404 = CombatSystemClass.GetMartialForSkill(182736404)
	_assert(int(m404.get("id", 0)) == 1005, "map_bat_hoang")

	var m405 = CombatSystemClass.GetMartialForSkill(182736405)
	_assert(int(m405.get("id", 0)) == 1006, "map_quy_nguyen")

	var m406 = CombatSystemClass.GetMartialForSkill(182736406)
	_assert(int(m406.get("id", 0)) == 1008, "map_van_kiem_quy_tong")
	_assert(Lib.Has("van_kiem_quy_tong"), "catalog_van_kiem_quy_tong")

	# Direct martial id still works
	_assert(int(CombatSystemClass.GetMartialForSkill(1002).get("id", 0)) == 1002, "map_direct_martial_id")

	# Name fallback
	_assert(int(CombatSystemClass.GetMartialIdForSkill(0, "Quy Nguyên Hộ Thể Thuẫn")) == 1006, "map_by_name")
	_assert(int(CombatSystemClass.GetMartialIdForSkill(0, "Vạn Kiếm Quy Tông")) == 1008, "map_van_kiem_by_name")

	# Unknown → empty (no false positive on raw skillID lookup into catalog)
	_assert(CombatSystemClass.GetMartialForSkill(999999999).is_empty(), "map_unknown_empty")

	# P0 — Impact keys are one-shot friendly (not looping leaf_storm / frost_nova / fire_spirit)
	_assert(Lib.ImpactKey(2, false) == "hit_spark", "impact_wood_oneshot")
	_assert(Lib.ImpactKey(3, false) == "ice_spikes", "impact_water_oneshot")
	_assert(Lib.ImpactKey(4, false) == "crit_hit", "impact_fire_oneshot")
	_assert(Lib.ImpactKey(0, true) == "crit_hit", "impact_crit")

	# P1 — Xianxia VFX spawn without crash
	var host := Node2D.new()
	add_child(host)

	var gust = CombatVfx.SpawnBladeGustVfx(host, Vector2(10, 10), Vector2.RIGHT)
	_assert(gust != null and is_instance_valid(gust), "spawn_blade_gust")

	var array = CombatVfx.SpawnSwordArrayVfx(host, Vector2(20, 20))
	_assert(array != null and is_instance_valid(array), "spawn_sword_array")

	var fist = CombatVfx.SpawnFistShockwaveVfx(host, Vector2(30, 30), Vector2.DOWN)
	_assert(fist != null and is_instance_valid(fist), "spawn_fist_shockwave")

	var shield = CombatVfx.CreateOrUpdateShieldVfx(host, true)
	_assert(shield != null and is_instance_valid(shield), "spawn_spiritual_shield")

	var vanKiem = CombatVfx.SpawnPixelFx(host, "van_kiem_quy_tong", Vector2(50, 50), -1.0, false, true)
	_assert(vanKiem != null and is_instance_valid(vanKiem), "spawn_van_kiem_quy_tong")
	var vkFrames = Lib.GetSpriteFrames("van_kiem_quy_tong")
	_assert(vkFrames != null and vkFrames.get_frame_count("default") >= 49, "van_kiem_49_frames")

	var impact = CombatVfx.SpawnImpactVfx(host, Vector2(40, 40), 2, false)
	_assert(impact != null and is_instance_valid(impact), "spawn_impact_wood_oneshot")

	# Shield dismiss
	CombatVfx.CreateOrUpdateShieldVfx(host, false)
	_assert(true, "shield_dismiss_no_crash")

	print("=== QA XIANXIA RESULT: %s (%d failures) %s ===" % ["OK" if failed == 0 else "FAILED", failed, str(results)])
	await get_tree().create_timer(0.4).timeout
	get_tree().quit(0 if failed == 0 else 1)

func _assert(cond : bool, key : String) -> void:
	results[key] = cond
	if cond:
		print("  PASS: %s" % key)
	else:
		printerr("  FAIL: %s" % key)
		failed += 1
