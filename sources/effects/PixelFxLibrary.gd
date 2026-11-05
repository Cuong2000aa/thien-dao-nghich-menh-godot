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
	# Environment (god-rays deferred — sheet too large for first pass)
	"fireflies": "weather/fireflies",
	"falling_leaves": "weather/falling-leaves",
	"fog": "weather/fog",
	"cherry_blossoms": "weather/cherry-blossoms",
	# UI / pickups
	"level_up": "ui/level-up",
	"coin_collect": "ui/coin-collect",
	"quest_complete": "ui/quest-complete",
	"collect_burst": "pickups/collect-burst",
	"xp_orb": "pickups/xp-orb",
}

## Ngũ Hành → preferred sheet key
const ELEMENT_FX : Dictionary = {
	0: "hit_spark",
	1: "slash",
	2: "leaf_storm",
	3: "frost_nova",
	4: "fire_spirit",
	5: "earth_spike",
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
	"fireflies": 0.50,
	"falling_leaves": 0.45,
	"fog": 0.50,
	"cherry_blossoms": 0.45,
	"level_up": 0.55,
	"coin_collect": 0.70,
	"quest_complete": 0.50,
	"collect_burst": 0.65,
	"xp_orb": 0.70,
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

	var tex : Texture2D = load(pngPath) as Texture2D
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
	sf.add_animation(animName)
	sf.set_animation_loop(animName, loop)
	sf.set_animation_speed(animName, 1.0) # durations are absolute seconds via add_frame duration

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
