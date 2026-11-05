extends AnimatedSprite2D
class_name PixelFxPlayer

## TDNM — BUILD 12: One-shot / looping PixelFX sprite player
## Spawns under map fringe (Y-sort friendly). Auto frees when one-shot ends.

var effectKey : String = ""
var autoFree : bool = true
var lifetimeCap : float = 8.0
var _elapsed : float = 0.0
var _looping : bool = false

static func Spawn(parent : Node2D, key : String, worldPos : Vector2, scaleMul : float = 1.0, flipH : bool = false, zOff : int = 8) -> PixelFxPlayer:
	if parent == null or not is_instance_valid(parent):
		return null
	var frames : SpriteFrames = PixelFxLibrary.GetSpriteFrames(key)
	if frames == null:
		return null
	var meta : Dictionary = PixelFxLibrary.GetMeta(key)
	var player := PixelFxPlayer.new()
	player.effectKey = key
	player.sprite_frames = frames
	player.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player.centered = true
	var pivot : Vector2 = meta.get("pivot", Vector2.ZERO)
	var fw : float = float(meta.get("frame_w", 0))
	var fh : float = float(meta.get("frame_h", 0))
	# PixelFX pivot is origin in sheet space (often feet). Convert to Sprite2D offset.
	if fw > 0.0 and fh > 0.0 and pivot != Vector2.ZERO:
		player.offset = Vector2(fw * 0.5 - pivot.x, fh * 0.5 - pivot.y)
	player.scale = Vector2(scaleMul, scaleMul)
	player.flip_h = flipH
	player.z_index = zOff
	player.position = worldPos
	player._looping = bool(meta.get("loop", false))
	player.autoFree = not player._looping
	parent.add_child(player)
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
