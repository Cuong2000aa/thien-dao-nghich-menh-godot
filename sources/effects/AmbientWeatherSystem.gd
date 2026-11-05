extends RefCounted
class_name AmbientWeatherSystem

## TDNM — BUILD 09: WORLD ATMOSPHERE & LIVING ENVIRONMENT
## Procedural Ambient Weather & Atmospheric Effects:
## Falling Bamboo Leaves, Floating Spiritual Qi Motes, and Regional Xianxia Lighting.

# ==============================================================================
# 1. FALLING BAMBOO LEAVES (LÁ TRÚC RƠI THEO GIÓ)
# ==============================================================================
## Spawns falling bamboo leaves drifting in the wind over an area
static func SpawnBambooLeaves(parent : Node2D, bounds : Rect2 = Rect2(0, 0, 1200, 800), count : int = 25) -> Node2D:
	if not parent or not is_instance_valid(parent):
		return null
		
	var existing = parent.get_node_or_null("AmbientBambooLeaves")
	if existing:
		return existing
		
	var leafNode = BambooLeavesNode.new()
	leafNode.name = "AmbientBambooLeaves"
	leafNode.bounds = bounds
	leafNode.leafCount = count
	leafNode.z_index = 10
	parent.add_child(leafNode)
	return leafNode

class BambooLeavesNode extends Node2D:
	var bounds : Rect2 = Rect2(0, 0, 1200, 800)
	var leafCount : int = 25
	var leaves : Array[Dictionary] = []
	var windTime : float = 0.0
	
	func _ready():
		for i in leafCount:
			leaves.append({
				"pos": Vector2(randf_range(bounds.position.x, bounds.end.x), randf_range(bounds.position.y, bounds.end.y)),
				"speedY": randf_range(25.0, 50.0),
				"speedX": randf_range(15.0, 35.0),
				"phase": randf_range(0.0, TAU),
				"length": randf_range(7.0, 11.0),
				"width": randf_range(2.5, 4.0),
				"color": Color(0.35 + randf_range(0.0, 0.15), 0.75 + randf_range(0.0, 0.2), 0.35, 0.75)
			})
			
	func _process(delta : float):
		windTime += delta
		for leaf in leaves:
			leaf["pos"].y += leaf["speedY"] * delta
			leaf["pos"].x += (leaf["speedX"] + sin(windTime * 2.0 + leaf["phase"]) * 20.0) * delta
			# Wrap around bounds
			if leaf["pos"].y > bounds.end.y:
				leaf["pos"].y = bounds.position.y - 10.0
				leaf["pos"].x = randf_range(bounds.position.x, bounds.end.x)
			if leaf["pos"].x > bounds.end.x:
				leaf["pos"].x = bounds.position.x
		queue_redraw()
		
	func _draw():
		for leaf in leaves:
			var angle = sin(windTime * 2.5 + leaf["phase"]) * 0.5 + 0.4
			var dir = Vector2(cos(angle), sin(angle))
			var p1 = leaf["pos"]
			var p2 = p1 + dir * leaf["length"]
			draw_line(p1, p2, leaf["color"], leaf["width"])

# ==============================================================================
# 2. FLOATING SPIRITUAL QI MOTES (LINH KHÍ ĐIỂM QUANG)
# ==============================================================================
## Spawns rising glowing motes of spiritual qi around cultivation points
static func SpawnSpiritualQiMotes(parent : Node2D, center : Vector2, radius : float = 120.0, count : int = 15) -> Node2D:
	if not parent or not is_instance_valid(parent):
		return null
		
	var motesNode = SpiritualQiMotesNode.new()
	motesNode.name = "SpiritualQiMotes"
	motesNode.position = center
	motesNode.radius = radius
	motesNode.moteCount = count
	motesNode.z_index = 8
	parent.add_child(motesNode)
	return motesNode

class SpiritualQiMotesNode extends Node2D:
	var radius : float = 120.0
	var moteCount : int = 15
	var motes : Array[Dictionary] = []
	var time : float = 0.0
	
	func _ready():
		for i in moteCount:
			var dist = randf_range(0.0, radius)
			var angle = randf_range(0.0, TAU)
			motes.append({
				"pos": Vector2(cos(angle), sin(angle)) * dist,
				"speed": randf_range(18.0, 35.0),
				"phase": randf_range(0.0, TAU),
				"size": randf_range(1.5, 3.0),
				"color": Color(0.4, 0.95, 0.8, 0.7)
			})
			
	func _process(delta : float):
		time += delta
		for m in motes:
			m["pos"].y -= m["speed"] * delta
			m["pos"].x += sin(time * 3.0 + m["phase"]) * 10.0 * delta
			if m["pos"].y < -radius:
				m["pos"].y = radius * randf_range(0.3, 0.9)
				m["pos"].x = randf_range(-radius * 0.7, radius * 0.7)
		queue_redraw()
		
	func _draw():
		for m in motes:
			var alpha = 0.4 + sin(time * 3.0 + m["phase"]) * 0.3
			var col = Color(m["color"].r, m["color"].g, m["color"].b, alpha)
			draw_circle(m["pos"], m["size"], col)

# ==============================================================================
# 3. REGIONAL XIANXIA LIGHTING TINTS
# ==============================================================================
const REGIONAL_TINTS : Dictionary = {
	995840901: Color(0.97, 1.02, 0.96, 1.0),  # SacredSectHub: Jade daylight
	4111682275: Color(1.06, 0.92, 0.88, 1.0), # Candor Boss Arena: Volcanic warm crimson
	0: Color(1.0, 1.0, 1.0, 1.0)              # Default neutral
}

static func GetRegionalTint(mapID : int) -> Color:
	return REGIONAL_TINTS.get(mapID, Color.WHITE)
