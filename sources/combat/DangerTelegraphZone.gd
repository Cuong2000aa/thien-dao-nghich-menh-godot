extends Node2D
class_name DangerTelegraphZone

var radius : float = 60.0
var duration : float = 1.0
var elapsed : float = 0.0
var onDetonate : Callable

func _process(delta: float):
	elapsed += delta
	queue_redraw()
	if elapsed >= duration:
		if onDetonate.is_valid():
			onDetonate.call()
		queue_free()

func _draw():
	var progress : float = clampf(elapsed / duration, 0.0, 1.0)
	# Outer danger boundary circle
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(1.0, 0.2, 0.2, 0.8), 2.5)
	# Expanding inner warning fill
	draw_circle(Vector2.ZERO, radius * progress, Color(1.0, 0.1, 0.1, 0.25 + 0.25 * progress))
