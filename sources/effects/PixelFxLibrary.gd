extends RefCounted
class_name PixelFxLibrary

## TDNM — BUILD 12: PixelFX sprite-sheet catalog + SpriteFrames cache
## Sheets live under res://assets/vfx/pixelfx/<category>/<id>/
## Each effect folder contains: <id>.png + <id>.json (Aseprite-style from PixelFX).

const ROOT := "res://assets/vfx/pixelfx"

## Logical effect keys used by gameplay → relative folder under ROOT
const CATALOG : Dictionary = {
	# Combat / melee
	"slash": "melee/sword-slash",
	"double_slash": "melee/double-slash",
	"heavy_cleave": "melee/heavy-cleave",
	# Impacts
	"hit_spark": "impacts/hit-spark",
	"crit_hit": "impacts/crit-hit",
	"ground_slam": "impacts/ground-slam",
	"parry": "impacts/parry",
	"shield_block": "impacts/shield-block",
	# Five elements
	"fire_spirit": "fire/spirit-flame",
	"frost_nova": "ice/frost-nova",
	"ice_spikes": "ice/ice-spikes",
	"lightning_charge": "lightning/charge-up",
	"lightning_strike": "lightning/lightning-strike",
	"earth_spike": "nature/earth-spike",
	"poison_cloud": "nature/poison-cloud",
	"leaf_storm": "nature/leaf-storm",
	# Cultivation / skills
	"spell_charge": "arcane/spell-charge",
	"arcane_orb": "arcane/arcane-orb",
	"magic_circle": "arcane/magic-circle-cast",
	"mana_burst": "arcane/mana-burst",
	"divine_shield": "holy/divine-shield",
	"heal": "holy/heal",
	"heal_ring": "holy/heal-aoe",
	"dragon_golden_spiral": "cultivation/dragon-golden-spiral",
	"van_kiem_quy_tong": "sword/van-kiem-quy-tong",
	"nhat_kiem_tram_thien_mon": "sword/nhat-kiem-tram-thien-mon",
	# Environment (god-rays deferred — sheet too large for first pass)
	"fireflies": "weather/fireflies",
	"falling_leaves": "weather/falling-leaves",
	"fog": "weather/fog",
	"cherry_blossoms": "weather/cherry-blossoms",
	# UI / pickups
	"level_up": "ui/level-up",
	"coin_collect": "ui/coin-collect",
	"quest_complete": "ui/quest-complete",
	"damage_number": "ui/damage-number",
	"collect_burst": "pickups/collect-burst",
	"xp_orb": "pickups/xp-orb",
	# --- Batch 2 (patch-gg/pixelfx) ---
	"claw_swipe": "melee/claw-swipe",
	"dagger_flurry": "melee/dagger-flurry",
	"hammer_smash": "melee/hammer-smash",
	"spear_sweep": "melee/spear-sweep",
	"spin_slash": "melee/spin-slash",
	"thrust": "melee/thrust",
	"uppercut": "melee/uppercut",
	"blunt_hit": "impacts/blunt-hit",
	"heavy_landing": "impacts/heavy-landing",
	"hit_flash": "impacts/hit-flash",
	"impact_frame": "impacts/impact-frame",
	"fireball": "fire/fireball",
	"fire_ring": "fire/fire-ring",
	"flame_pillar": "fire/flame-pillar",
	"meteor": "fire/meteor",
	"fire_breath": "fire/fire-breath",
	"fire_tornado": "fire/fire-tornado",
	"ice_lance": "ice/ice-lance",
	"freeze": "ice/freeze",
	"frost_breath": "ice/frost-breath",
	"blizzard_vortex": "ice/blizzard-vortex",
	"ice_shatter": "ice/ice-shatter",
	"snowflake_burst": "ice/snowflake-burst",
	"chain_lightning": "lightning/chain-lightning",
	"thunderclap": "lightning/thunderclap",
	"zap_hit": "lightning/zap-hit",
	"ball_lightning": "lightning/ball-lightning",
	"spark_arc": "lightning/spark-arc",
	"tornado": "nature/tornado",
	"root_snare": "nature/root-snare",
	"vine_whip": "nature/vine-whip",
	"healing_bloom": "nature/healing-bloom",
	"quake": "nature/quake",
	"thorns": "nature/thorns",
	"portal": "arcane/portal",
	"rune_circle": "arcane/rune-circle",
	"star_fall": "arcane/star-fall",
	"arcane_beam": "arcane/arcane-beam",
	"blink_in": "arcane/blink-in",
	"blink_out": "arcane/blink-out",
	"smite": "holy/smite",
	"sunburst": "holy/sunburst",
	"blessing": "holy/blessing",
	"holy_pillar": "holy/holy-pillar",
	"halo": "holy/halo",
	"void_orb": "shadow/void-orb",
	"shadow_flames": "shadow/shadow-flames",
	"curse": "shadow/curse",
	"life_steal": "shadow/life-steal",
	"hex_sigil": "shadow/hex-sigil",
	"small_explosion": "explosions/small-explosion",
	"big_explosion": "explosions/big-explosion",
	"smoke_bomb": "explosions/smoke-bomb",
	"poof": "spawn/poof",
	"summon_rise": "spawn/summon-rise",
	"soul_rise": "spawn/soul-rise",
	"burning": "status/burning",
	"frozen": "status/frozen",
	"poisoned": "status/poisoned",
	"stunned": "status/stunned",
	"bleeding": "status/bleeding",
	"rage": "status/rage",
	"confetti": "ui/confetti",
	"achievement": "ui/achievement",
	"exclamation": "ui/exclamation",
	"crit_number": "ui/crit-number",
	"rain": "weather/rain",
	"snow": "weather/snow",
	"aurora": "weather/aurora",
	"shooting_stars": "weather/shooting-stars",
	"splash": "water/splash",
	"whirlpool": "water/whirlpool",
	"ripples": "water/ripples",
	"heart_pickup": "pickups/heart-pickup",
	"loot_beam": "pickups/loot-beam",
	"potion_fx": "pickups/potion",
}

## Ngũ Hành → preferred sheet key (may include looping sheets — cast/ambient only)
const ELEMENT_FX : Dictionary = {
	0: "hit_spark",
	1: "slash",
	2: "leaf_storm",
	3: "frost_nova",
	4: "fire_spirit",
	5: "earth_spike",
}

## Hit impacts must be short one-shots (no looping weather/element sheets)
const IMPACT_FX : Dictionary = {
	0: "hit_spark",
	1: "slash",
	2: "hit_spark",
	3: "ice_spikes",
	4: "crit_hit",
	5: "ground_slam",
}

## Default world scale so PixelFX sheets fit SoM isometric character size
const DEFAULT_SCALE : Dictionary = {
	"slash": 0.55,
	"double_slash": 0.55,
	"heavy_cleave": 0.50,
	"hit_spark": 0.65,
	"crit_hit": 0.55,
	"ground_slam": 0.40,
	"parry": 0.55,
	"shield_block": 0.60,
	"fire_spirit": 0.70,
	"frost_nova": 0.35,
	"ice_spikes": 0.40,
	"lightning_charge": 0.40,
	"lightning_strike": 0.35,
	"earth_spike": 0.40,
	"poison_cloud": 0.40,
	"leaf_storm": 0.40,
	"spell_charge": 0.55,
	"arcane_orb": 0.55,
	"magic_circle": 0.40,
	"mana_burst": 0.45,
	"divine_shield": 0.75,
	"heal": 0.70,
	"heal_ring": 0.40,
	"dragon_golden_spiral": 0.85,
	"van_kiem_quy_tong": 0.95,
	"nhat_kiem_tram_thien_mon": 1.05,
	"fireflies": 0.50,
	"falling_leaves": 0.45,
	"fog": 0.50,
	"cherry_blossoms": 0.45,
	"level_up": 0.55,
	"coin_collect": 0.70,
	"quest_complete": 0.50,
	"collect_burst": 0.65,
	"xp_orb": 0.70,
	"damage_number": 0.55,
	# Batch 2 defaults
	"claw_swipe": 0.55, "dagger_flurry": 0.50, "hammer_smash": 0.50, "spear_sweep": 0.50,
	"spin_slash": 0.55, "thrust": 0.55, "uppercut": 0.55,
	"blunt_hit": 0.55, "heavy_landing": 0.45, "hit_flash": 0.60, "impact_frame": 0.50,
	"fireball": 0.55, "fire_ring": 0.45, "flame_pillar": 0.45, "meteor": 0.40,
	"fire_breath": 0.50, "fire_tornado": 0.40,
	"ice_lance": 0.50, "freeze": 0.55, "frost_breath": 0.50, "blizzard_vortex": 0.40,
	"ice_shatter": 0.50, "snowflake_burst": 0.50,
	"chain_lightning": 0.45, "thunderclap": 0.45, "zap_hit": 0.55, "ball_lightning": 0.50, "spark_arc": 0.55,
	"tornado": 0.40, "root_snare": 0.45, "vine_whip": 0.50, "healing_bloom": 0.50, "quake": 0.40, "thorns": 0.50,
	"portal": 0.45, "rune_circle": 0.40, "star_fall": 0.45, "arcane_beam": 0.50, "blink_in": 0.55, "blink_out": 0.55,
	"smite": 0.45, "sunburst": 0.40, "blessing": 0.50, "holy_pillar": 0.40, "halo": 0.60,
	"void_orb": 0.50, "shadow_flames": 0.50, "curse": 0.50, "life_steal": 0.50, "hex_sigil": 0.45,
	"small_explosion": 0.40, "big_explosion": 0.35, "smoke_bomb": 0.45,
	"poof": 0.55, "summon_rise": 0.45, "soul_rise": 0.50,
	"burning": 0.60, "frozen": 0.60, "poisoned": 0.60, "stunned": 0.60, "bleeding": 0.60, "rage": 0.60,
	"confetti": 0.45, "achievement": 0.50, "exclamation": 0.55, "crit_number": 0.55,
	"rain": 0.45, "snow": 0.45, "aurora": 0.40, "shooting_stars": 0.45,
	"splash": 0.50, "whirlpool": 0.40, "ripples": 0.55,
	"heart_pickup": 0.65, "loot_beam": 0.50, "potion_fx": 0.60,
}

static var _framesCache : Dictionary = {}
static var _metaCache : Dictionary = {}

static func Has(key : String) -> bool:
	return CATALOG.has(key)

static func ResolvePath(key : String) -> String:
	if not CATALOG.has(key):
		return ""
	return "%s/%s" % [ROOT, CATALOG[key]]

static func GetScale(key : String) -> float:
	return float(DEFAULT_SCALE.get(key, 0.5))

static func GetMeta(key : String) -> Dictionary:
	_EnsureLoaded(key)
	return _metaCache.get(key, {})

static func GetSpriteFrames(key : String) -> SpriteFrames:
	_EnsureLoaded(key)
	return _framesCache.get(key, null)

static func ElementKey(element : int, isCrit : bool = false) -> String:
	if isCrit:
		return "crit_hit"
	return ELEMENT_FX.get(element, "hit_spark")

static func ImpactKey(element : int, isCrit : bool = false) -> String:
	if isCrit:
		return "crit_hit"
	return IMPACT_FX.get(element, "hit_spark")

static func _EnsureLoaded(key : String) -> void:
	if _framesCache.has(key):
		return
	if not CATALOG.has(key):
		return
	var folder : String = ResolvePath(key)
	var idName : String = String(CATALOG[key]).get_file()
	var pngPath : String = "%s/%s.png" % [folder, idName]
	var jsonPath : String = "%s/%s.json" % [folder, idName]
	if not ResourceLoader.exists(pngPath) and not FileAccess.file_exists(pngPath):
		Util.PrintInfo("PixelFx", "Missing PNG for '%s' (%s)" % [key, pngPath])
		return
	if not FileAccess.file_exists(jsonPath):
		Util.PrintInfo("PixelFx", "Missing JSON for '%s' (%s)" % [key, jsonPath])
		return

	var tex : Texture2D = null
	if ResourceLoader.exists(pngPath):
		tex = load(pngPath) as Texture2D
	# Headless / fresh checkout: PNG may exist on disk without .import yet
	if tex == null and FileAccess.file_exists(pngPath):
		var img := Image.new()
		if img.load(pngPath) == OK:
			tex = ImageTexture.create_from_image(img)
	if tex == null:
		return

	var raw : String = FileAccess.get_file_as_string(jsonPath)
	var data = JSON.parse_string(raw)
	if typeof(data) != TYPE_DICTIONARY:
		return

	var meta : Dictionary = data.get("meta", {})
	var px : Dictionary = meta.get("pixelfx", {})
	var fps : float = float(px.get("fps", 12))
	var loop : bool = bool(px.get("loop", false))
	var pivot = px.get("pivot", [0, 0])
	var frameSize = px.get("frameSize", [0, 0])
	var frameW : int = 0
	var frameH : int = 0
	if typeof(frameSize) == TYPE_ARRAY and frameSize.size() >= 2:
		frameW = int(frameSize[0])
		frameH = int(frameSize[1])
	var pivotVec := Vector2.ZERO
	if typeof(pivot) == TYPE_ARRAY and pivot.size() >= 2:
		pivotVec = Vector2(float(pivot[0]), float(pivot[1]))

	var framesRaw = data.get("frames", [])
	var frameList : Array = []
	if typeof(framesRaw) == TYPE_ARRAY:
		frameList = framesRaw
	elif typeof(framesRaw) == TYPE_DICTIONARY:
		var keys : Array = framesRaw.keys()
		keys.sort_custom(func(a, b): return str(a) < str(b))
		for fk in keys:
			frameList.append(framesRaw[fk])

	var sf := SpriteFrames.new()
	var animName := StringName("default")
	# SpriteFrames ships with a built-in "default" animation — reuse it
	if not sf.has_animation(animName):
		sf.add_animation(animName)
	sf.set_animation_loop(animName, loop)
	sf.set_animation_speed(animName, 1.0) # durations are absolute seconds via add_frame duration
	sf.clear(animName)

	for fr in frameList:
		if typeof(fr) != TYPE_DICTIONARY:
			continue
		var rectData = fr.get("frame", {})
		var x : int = int(rectData.get("x", 0))
		var y : int = int(rectData.get("y", 0))
		var w : int = int(rectData.get("w", frameW))
		var h : int = int(rectData.get("h", frameH))
		if w <= 0 or h <= 0:
			continue
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(x, y, w, h)
		var durMs : float = float(fr.get("duration", 1000.0 / maxf(fps, 1.0)))
		var frameDur : float = maxf(durMs / 1000.0, 0.01)
		sf.add_frame(animName, atlas, frameDur)
		if frameW <= 0:
			frameW = w
		if frameH <= 0:
			frameH = h

	_framesCache[key] = sf
	_metaCache[key] = {
		"fps": fps,
		"loop": loop,
		"pivot": pivotVec,
		"frame_w": frameW,
		"frame_h": frameH,
		"path": folder,
	}
	Util.PrintLog("PixelFx", "Loaded '%s' (%d frames @ %.0ffps, loop=%s)" % [key, sf.get_frame_count(animName), fps, str(loop)])
