extends AnimatedSprite2D
class_name PixelFxPlayer

## TDNM — BUILD 12: One-shot / looping PixelFX sprite player
## Spawns under map fringe (Y-sort) or attached to a caster (gallery-style origin).

var effectKey : String = ""
var autoFree : bool = true
var lifetimeCap : float = 8.0
var _elapsed : float = 0.0
var _looping : bool = false

## worldPos = feet/origin. attachTo=caster → local (0,0) so FX comes out of the body like PixelFX #moves.
static func Spawn(parent : Node2D, key : String, worldPos : Vector2, scaleMul : float = 1.0, flipH : bool = false, zOff : int = 8, forceOneShot : bool = false, attachTo : Node2D = null) -> PixelFxPlayer:
	if parent == null or not is_instance_valid(parent):
		return null
	var Lib = preload("res://sources/effects/PixelFxLibrary.gd")
	var frames : SpriteFrames = Lib.GetSpriteFrames(key)
	if frames == null:
		return null
	var meta : Dictionary = Lib.GetMeta(key)
	var player := PixelFxPlayer.new()
	player.effectKey = key
	player.sprite_frames = frames
	player.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player.centered = true
	var pivot : Vector2 = meta.get("pivot", Vector2.ZERO)
	var fw : float = float(meta.get("frame_w", 0))
	var fh : float = float(meta.get("frame_h", 0))
	# PixelFX pivot = effect origin (usually feet). Map that point onto spawn position.
	# When flip_h, mirror offset.x so the origin stays on the character.
	if fw > 0.0 and fh > 0.0 and pivot != Vector2.ZERO:
		var ox : float = fw * 0.5 - pivot.x
		var oy : float = fh * 0.5 - pivot.y
		if flipH:
			ox = -ox
		player.offset = Vector2(ox, oy)
	player.scale = Vector2(scaleMul, scaleMul)
	player.flip_h = flipH
	player.z_index = zOff
	# Combat / world-ground FX must never leave looping assets stuck on the map.
	player._looping = bool(meta.get("loop", false)) and not forceOneShot
	player.autoFree = forceOneShot or not player._looping
	# Soft-glow custom sheets (black-keyed) need ADD so they don't leave a gray plate.
	const ADD_KEYS := {
		"van_kiem_quy_tong": 2.6,
		"dragon_golden_spiral": 3.5,
		"nhat_kiem_tram_thien_mon": 2.4,
	}
	var blendAdd : bool = bool(meta.get("blend_add", false)) or ADD_KEYS.has(key)
	if ADD_KEYS.has(key):
		player.lifetimeCap = float(ADD_KEYS[key])
	elif forceOneShot:
		var sheetDur : float = Lib.GetSheetDuration(key)
		player.lifetimeCap = clampf(sheetDur + 0.2, 0.45, 10.0)
	if blendAdd:
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		player.material = mat

	if attachTo != null and is_instance_valid(attachTo):
		# Gallery local origin on body. Raise slightly so breath/beam leaves chest, not feet-side blob.
		attachTo.add_child(player)
		var bodyLift : float = -18.0
		var LibPlace = Lib.GetPlacement(key)
		if LibPlace == Lib.PLACE_BODY_DIR or LibPlace == Lib.PLACE_BODY_ACT:
			# Nudge toward facing so spitfire/fireball reads as leaving the character toward aim
			var faceSign : float = -1.0 if flipH else 1.0
			player.position = Vector2(faceSign * 6.0, bodyLift)
		elif LibPlace == Lib.PLACE_BODY:
			player.position = Vector2(0.0, bodyLift)
		else:
			player.position = Vector2.ZERO
		player.z_index = maxi(zOff, 12)
	else:
		parent.add_child(player)
		player.position = worldPos

	player.play("default")
	if not player._looping and not player.animation_finished.is_connected(player._OnFinished):
		player.animation_finished.connect(player._OnFinished)
	return player

func _process(delta : float) -> void:
	_elapsed += delta
	if autoFree and _elapsed >= lifetimeCap:
		queue_free()

func _OnFinished() -> void:
	if autoFree and not _looping:
		queue_free()

func StopAndFree() -> void:
	stop()
	queue_free()
