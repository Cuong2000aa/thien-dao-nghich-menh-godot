extends RefCounted
class_name HudFeedback

## TDNM — BUILD 13: Lightweight HUD feedback (low HP pulse, skill flash)
## Attaches a non-blocking overlay under Gui Overlay; never blocks input.

static var _pulseRect : ColorRect = null
static var _pulseTween : Tween = null

static func EnsureOverlay() -> ColorRect:
	if _pulseRect and is_instance_valid(_pulseRect):
		return _pulseRect
	if Launcher.GUI == null:
		return null
	var overlay = Launcher.GUI.get_node_or_null("Overlay")
	if overlay == null:
		return null
	_pulseRect = ColorRect.new()
	_pulseRect.name = "HudDangerPulse"
	_pulseRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pulseRect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pulseRect.color = Color(0.7, 0.05, 0.05, 0.0)
	overlay.add_child(_pulseRect)
	overlay.move_child(_pulseRect, overlay.get_child_count() - 1)
	return _pulseRect

static func PulseLowHp(hpRatio : float) -> void:
	var rect = EnsureOverlay()
	if rect == null:
		return
	if hpRatio > 0.25:
		rect.color.a = 0.0
		if _pulseTween:
			_pulseTween.kill()
			_pulseTween = null
		return
	var peak : float = lerpf(0.22, 0.08, clampf(hpRatio / 0.25, 0.0, 1.0))
	if _pulseTween:
		_pulseTween.kill()
	_pulseTween = rect.create_tween().set_loops()
	_pulseTween.tween_property(rect, "color:a", peak, 0.45).set_trans(Tween.TRANS_SINE)
	_pulseTween.tween_property(rect, "color:a", peak * 0.35, 0.45).set_trans(Tween.TRANS_SINE)

static func FlashHit() -> void:
	var rect = EnsureOverlay()
	if rect == null:
		return
	# Brief red flash without interrupting low-HP loop state permanently
	var flash := ColorRect.new()
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(0.85, 0.1, 0.1, 0.18)
	rect.get_parent().add_child(flash)
	var tw = flash.create_tween()
	tw.tween_property(flash, "color:a", 0.0, 0.22)
	tw.tween_callback(flash.queue_free)
