extends RefCounted
class_name HeroLibrary

## Selectable player bodies for character creator / runtime visual swap.
## shape trait stores EntityData id (= hero entity name.hash()).

const HEROES : Array[Dictionary] = [
	{
		"id": "swordsman",
		"name": "Kiếm Khách",
		"entity": "Player",
		"folder": "swordsman",
		"frames": "res://assets/characters/swordsman/swordsman_frames.tres",
		"scale": 1.2,
	},
	{
		"id": "assassin",
		"name": "Ảnh Sát",
		"entity": "PlayerAssassin",
		"folder": "assassin",
		"frames": "",  # runtime from characters.json
		"scale": 1.35,
	},
	{
		"id": "wuxia_swordsman",
		"name": "Kiếm Sĩ",
		"entity": "PlayerWuxiaSword",
		"folder": "wuxia_swordsman",
		"frames": "",
		"scale": 1.3,
	},
]

static var _framesCache : Dictionary = {}  # id -> SpriteFrames
static var _footCache : Dictionary = {}  # id -> Dictionary action -> Vector2
static var _metaCache : Dictionary = {}  # id -> Dictionary

static func Count() -> int:
	return HEROES.size()

static func Get(index : int) -> Dictionary:
	if index < 0 or index >= HEROES.size():
		return HEROES[0]
	return HEROES[index]

static func FindIndexById(heroId : String) -> int:
	for i in HEROES.size():
		if String(HEROES[i].get("id", "")) == heroId:
			return i
	return 0

static func FindIndexByShape(shapeHash : int) -> int:
	for i in HEROES.size():
		var entName : String = String(HEROES[i].get("entity", "Player"))
		if entName.hash() == shapeHash:
			return i
	return -1

static func IsHeroShape(shapeHash : int) -> bool:
	return FindIndexByShape(shapeHash) >= 0

static func GetShapeHash(index : int) -> int:
	return String(Get(index).get("entity", "Player")).hash()

static func GetSpriteFrames(index : int) -> SpriteFrames:
	var hero : Dictionary = Get(index)
	var heroId : String = String(hero.get("id", "swordsman"))
	if _framesCache.has(heroId):
		return _framesCache[heroId]

	var framesPath : String = String(hero.get("frames", ""))
	if not framesPath.is_empty() and ResourceLoader.exists(framesPath):
		var loaded : SpriteFrames = load(framesPath) as SpriteFrames
		_framesCache[heroId] = loaded
		_EnsureFootFromJson(heroId, String(hero.get("folder", heroId)))
		return loaded

	var built : SpriteFrames = _BuildFromJson(String(hero.get("folder", heroId)))
	_framesCache[heroId] = built
	return built

static func GetFootOffsets(index : int) -> Dictionary:
	var heroId : String = String(Get(index).get("id", "swordsman"))
	if _footCache.has(heroId):
		return _footCache[heroId]
	GetSpriteFrames(index)  # ensures foot cache
	return _footCache.get(heroId, {})

static func GetPresetScale(index : int) -> float:
	return float(Get(index).get("scale", 1.2))

static func ApplyToEntity(entity : Entity, index : int) -> void:
	if entity == null or entity.visual == null:
		return
	var frames : SpriteFrames = GetSpriteFrames(index)
	if frames == null:
		return
	var vis : EntityVisual = entity.visual
	if vis.animatedSprite == null:
		return
	vis.animatedSprite.sprite_frames = frames
	vis.SetHeroFootOverrides(GetFootOffsets(index))
	if vis.preset and vis.preset is Node2D:
		var s : float = GetPresetScale(index)
		(vis.preset as Node2D).scale = Vector2(s, s)
	# Persist selection on shape (trait column)
	if entity.stat:
		entity.stat.shape = GetShapeHash(index)
		entity.stat.currentShape = entity.stat.shape
	vis.UpdateSwordsmanVisual(Vector2.ZERO, entity.entityOrientation, entity.state, false)
	vis.spriteOffsetUpdate.emit()
	if entity.interactive and entity.interactive.has_method("RefreshVisibleNodeOffset"):
		entity.interactive.RefreshVisibleNodeOffset()

static func _EnsureFootFromJson(heroId : String, folder : String) -> void:
	if _footCache.has(heroId):
		return
	var path := "res://assets/characters/%s/characters.json" % folder
	if not FileAccess.file_exists(path):
		_footCache[heroId] = {}
		return
	var f := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	var feet : Dictionary = {}
	if typeof(data) == TYPE_DICTIONARY:
		var anims : Dictionary = data.get("anims", {})
		for animName in anims.keys():
			var cfg : Dictionary = anims[animName]
			var fp : Array = cfg.get("foot_px", [20, 38])
			if fp.size() >= 2:
				feet[String(animName)] = Vector2(float(fp[0]), float(fp[1]))
	_footCache[heroId] = feet

static func _BuildFromJson(folder : String) -> SpriteFrames:
	var base := "res://assets/characters/%s/" % folder
	var json_path := base + "characters.json"
	var sf := SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")
	if not FileAccess.file_exists(json_path):
		push_warning("HeroLibrary: missing %s" % json_path)
		return sf
	var file := FileAccess.open(json_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		return sf
	var rows : Array = data.get("rows", [])
	var anims : Dictionary = data.get("anims", {})
	var feet : Dictionary = {}
	for anim_name in anims.keys():
		var cfg : Dictionary = anims[anim_name]
		var cell_w : int = int(cfg["cell"][0])
		var cell_h : int = int(cfg["cell"][1])
		var frame_count : int = int(cfg["frames"])
		var fps : float = float(cfg["fps"])
		var is_loop : bool = bool(cfg.get("loop", false))
		var sheet_rel : String = String(cfg["sheet"])
		var tex := load(base + sheet_rel) as Texture2D
		if tex == null:
			push_warning("HeroLibrary: missing sheet %s" % (base + sheet_rel))
			continue
		var fp : Array = cfg.get("foot_px", [cell_w / 2, cell_h - 2])
		if fp.size() >= 2:
			feet[String(anim_name)] = Vector2(float(fp[0]), float(fp[1]))
		for row_idx in range(rows.size()):
			var dir_name : String = String(rows[row_idx])
			var full := "%s_%s" % [anim_name, dir_name]
			sf.add_animation(full)
			sf.set_animation_speed(full, fps)
			sf.set_animation_loop(full, is_loop)
			for col_idx in range(frame_count):
				var atlas := AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = Rect2(col_idx * cell_w, row_idx * cell_h, cell_w, cell_h)
				sf.add_frame(full, atlas)
	_footCache[folder] = feet
	# also key by hero id aliases
	for h in HEROES:
		if String(h.get("folder", "")) == folder:
			_footCache[String(h.get("id", folder))] = feet
	return sf
