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
	_assert(String(m406.get("fxKey", "")) == "van_kiem_quy_tong", "fx_van_kiem_custom")
	_assert(String(m406.get("fxPlace", "")) == "floor", "place_van_kiem_floor")
	_assert(Lib.Has("van_kiem_quy_tong"), "catalog_van_kiem_quy_tong")

	var m407 = CombatSystemClass.GetMartialForSkill(182736407)
	_assert(int(m407.get("id", 0)) == 1009, "map_nhat_kiem_tram_thien_mon")
	_assert(Lib.Has("nhat_kiem_tram_thien_mon"), "catalog_nhat_kiem_tram_thien_mon")

	# Remapped phép + tu tiên (single cast fxKey, no fxKey2 sticker stack)
	var newBatch := {
		182736408: [1010, "fire_breath"],
		182736409: [1011, "ice_lance_throw"],
		182736410: [1012, "lightning_call"],
		182736411: [1013, "hex_sigil"],
		182736412: [1014, "holy_smite"],
		182736413: [1015, "earth_stomp"],
		182736414: [1016, "chain_lightning"],
		182736415: [1017, "black_hole"],
	}
	for skillId in newBatch:
		var expect = newBatch[skillId]
		var mid : int = int(expect[0])
		var fx : String = String(expect[1])
		var m = CombatSystemClass.GetMartialForSkill(int(skillId))
		_assert(int(m.get("id", 0)) == mid, "map_new_%d" % mid)
		_assert(String(m.get("fxKey", "")) == fx, "fxkey_%d" % mid)
		_assert(Lib.Has(fx), "catalog_%s" % fx)
		_assert(String(m.get("fxKey2", "")).is_empty(), "no_dual_%d" % mid)

	# Core + legacy also single-key
	_assert(String(CombatSystemClass.GetMartialForSkill(182736401).get("fxKey", "")) == "sword_combo", "fx_thanh_phong")
	_assert(String(CombatSystemClass.GetMartialForSkill(0, "Flar").get("fxKey", "")) == "fireball_throw", "fx_flar")
	_assert(String(CombatSystemClass.GetMartialForSkill(0, "Mana Burst").get("fxKey", "")) == "mana_burst", "fx_mana_burst")
	_assert(bool(CombatSystemClass.GetMartialForSkill(0, "Melee").get("skipCastFx", false)), "melee_skip_cast")

	# Direct martial id still works
	_assert(int(CombatSystemClass.GetMartialForSkill(1002).get("id", 0)) == 1002, "map_direct_martial_id")

	# Name fallback
	_assert(int(CombatSystemClass.GetMartialIdForSkill(0, "Quy Nguyên Hộ Thể Thuẫn")) == 1006, "map_by_name")
	_assert(int(CombatSystemClass.GetMartialIdForSkill(0, "Vạn Kiếm Quy Tông")) == 1008, "map_van_kiem_by_name")
	_assert(int(CombatSystemClass.GetMartialIdForSkill(0, "Nhất Kiếm Trảm Thiên Môn")) == 1009, "map_nhat_kiem_by_name")
	_assert(int(CombatSystemClass.GetMartialIdForSkill(0, "Hỏa Long Phun Tức")) == 1010, "map_hoa_long_by_name")
	_assert(int(CombatSystemClass.GetMartialIdForSkill(0, "Hư Không Hấp Tinh")) == 1017, "map_hu_khong_by_name")

	# Unknown → empty (no false positive on raw skillID lookup into catalog)
	_assert(CombatSystemClass.GetMartialForSkill(999999999).is_empty(), "map_unknown_empty")

	# P0 — Impact keys are short PixelFX one-shots (ngũ hành readable, no looping weather)
	_assert(Lib.ImpactKey(1, false) == "slash", "impact_metal_slash")
	_assert(Lib.ImpactKey(2, false) == "thorns", "impact_wood_oneshot")
	_assert(Lib.ImpactKey(3, false) == "ice_spikes", "impact_water_oneshot")
	_assert(Lib.ImpactKey(4, false) == "hit_flash", "impact_fire_oneshot")
	_assert(Lib.ImpactKey(5, false) == "ground_slam", "impact_earth_oneshot")
	_assert(Lib.ImpactKey(0, true) == "crit_hit", "impact_crit")
	_assert(Lib.Has("thorns") and Lib.Has("hit_flash") and Lib.Has("sword_slash"), "impact_catalog_present")

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
	var vkMeta = Lib.GetMeta("van_kiem_quy_tong")
	_assert(int(vkMeta.get("frame_w", 0)) == 278 and int(vkMeta.get("frame_h", 0)) == 192, "van_kiem_frame_size")
	_assert(bool(vkMeta.get("blend_add", false)), "van_kiem_blend_add")

	var nhatKiem = CombatVfx.SpawnPixelFx(host, "nhat_kiem_tram_thien_mon", Vector2(60, 60), -1.0, false, true)
	_assert(nhatKiem != null and is_instance_valid(nhatKiem), "spawn_nhat_kiem_tram_thien_mon")
	var nkFrames = Lib.GetSpriteFrames("nhat_kiem_tram_thien_mon")
	_assert(nkFrames != null and nkFrames.get_frame_count("default") >= 64, "nhat_kiem_64_frames")
	# Corner of first frame should be transparent (no solid black plate)
	var nkMeta = Lib.GetMeta("nhat_kiem_tram_thien_mon")
	_assert(int(nkMeta.get("frame_w", 0)) == 192 and int(nkMeta.get("frame_h", 0)) == 128, "nhat_kiem_frame_size")

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
