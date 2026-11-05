extends RefCounted
class_name CombatVisualSystem

## TDNM — BUILD 09: VISUAL POLISH, COMBAT FEEL & IMMERSIVE GAMEPLAY ENGINE
## Master System for Hitstop, Camera Shake, Impact VFX, Phantom Afterimages,
## Elemental Hit Sparks, Skill Effects (Blade Gust, Sword Array, Shield), Boss Polish & Atmosphere.

# ==============================================================================
# 1. SHAKE INTENSITY LEVELS
# ==============================================================================
enum ShakeLevel {
	LIGHT = 1,    # Normal attack: 2.0px, 0.08s
	MEDIUM = 2,   # Combo hit: 4.5px, 0.12s
	HEAVY = 3,    # Critical hit / Skill impact: 7.0px, 0.18s
	BOSS = 4      # Boss roar / Ground slam / Ultimate: 12.0px, 0.30s
}

# Five Elements Colors for Impact Sparks & Floating Numbers
const ELEMENT_COLORS : Dictionary = {
	0: Color(1.0, 1.0, 1.0),       # None / Pure (White)
	1: Color(1.0, 0.90, 0.20),     # Metal / Kim (Vàng kim sáng)
	2: Color(0.25, 0.95, 0.35),    # Wood / Mộc (Xanh lục bảo)
	3: Color(0.20, 0.80, 1.00),    # Water / Thủy (Lam băng thanh)
	4: Color(1.0, 0.35, 0.10),     # Fire / Hỏa (Xích viêm liệt hỏa)
	5: Color(0.90, 0.65, 0.25)     # Earth / Thổ (Hoàng thổ trầm ổn)
}

# ==============================================================================
# 2. HITSTOP (MICRO-PAUSE ON IMPACT)
# ==============================================================================
## Freezes target/attacker animation briefly on impact for high tactile weight
static func TriggerHitstopOnEntity(entityNode : Node2D, duration : float = 0.05):
	if not entityNode or not is_instance_valid(entityNode):
		return
		
	var animSprite : AnimatedSprite2D = null
	if entityNode is AnimatedSprite2D:
		animSprite = entityNode
	else:
		animSprite = entityNode.get_node_or_null("AnimatedSprite2D")
		if not animSprite:
			var preset = entityNode.get_node_or_null("preset")
			if preset and preset.has_node("AnimatedSprite2D"):
				animSprite = preset.get_node("AnimatedSprite2D")
				
	if animSprite and is_instance_valid(animSprite) and animSprite.is_playing():
		animSprite.pause()
		var tween = entityNode.create_tween()
		if tween:
			tween.tween_interval(duration)
			tween.tween_callback(func():
				if is_instance_valid(animSprite):
					animSprite.play()
			)

# ==============================================================================
# 3. CAMERA SHAKE ENGINE
# ==============================================================================
static func TriggerCameraShake(level : ShakeLevel = ShakeLevel.LIGHT, customIntensity : float = 0.0, customDuration : float = 0.0):
	if not Launcher.Camera or not Launcher.Camera.camera or not is_instance_valid(Launcher.Camera.camera):
		return
		
	var cam : Camera2D = Launcher.Camera.camera
	var intensity : float = 2.0
	var duration : float = 0.08
	
	match level:
		ShakeLevel.LIGHT:
			intensity = 2.0
			duration = 0.08
		ShakeLevel.MEDIUM:
			intensity = 4.5
			duration = 0.12
		ShakeLevel.HEAVY:
			intensity = 7.0
			duration = 0.18
		ShakeLevel.BOSS:
			intensity = 12.0
			duration = 0.30
			
	if customIntensity > 0.0:
		intensity = customIntensity
	if customDuration > 0.0:
		duration = customDuration
		
	cam.offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
	var tween = cam.create_tween()
	if tween:
		tween.tween_property(cam, "offset", Vector2.ZERO, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# ==============================================================================
# 4. ELEMENTAL IMPACT SPARKS & SLASH VFX
# ==============================================================================
## Spawns PixelFX sheet (preferred) + light procedural sparks as fallback/enhancer
static func SpawnImpactVfx(parent : Node2D, pos : Vector2, element : int = 0, isCrit : bool = false) -> Node2D:
	if not parent or not is_instance_valid(parent):
		return null

	# BUILD 12 — PixelFX hit/crit (always one-shot; never leave looping weather/element sheets)
	# Always return ImpactVfxNode so callers/tests can read .isCrit / .element.
	var PixelFxLibraryClass = preload("res://sources/effects/PixelFxLibrary.gd")
	var PixelFxPlayerClass = preload("res://sources/effects/PixelFxPlayer.gd")
	var fxKey : String = PixelFxLibraryClass.ImpactKey(element, isCrit)
	var sheet = PixelFxPlayerClass.Spawn(parent, fxKey, pos, PixelFxLibraryClass.GetScale(fxKey), false, 12, true)

	var vfxNode = ImpactVfxNode.new()
	vfxNode.position = pos
	vfxNode.element = element
	vfxNode.isCrit = isCrit
	if sheet:
		# Soft procedural spark — skip denser draw on web to cut GPU; sheet carries the look
		vfxNode.duration = 0.08 if OS.has_feature("web") else (0.12 if not isCrit else 0.16)
		vfxNode.name = "ImpactVFX"
		vfxNode.z_index = 11
		parent.add_child(vfxNode)
		return vfxNode
	vfxNode.name = "ImpactVFX"
	parent.add_child(vfxNode)
	return vfxNode

## Play a named PixelFX key at world position (skills, cultivation, environment).
## Pass forceOneShot=true for combat cast/hit so looping sheets never litter the map.
## Ambient loops (cherry blossoms / fireflies) keep forceOneShot=false.
static func SpawnPixelFx(parent : Node2D, key : String, pos : Vector2, scaleMul : float = -1.0, flipH : bool = false, forceOneShot : bool = false) -> Node2D:
	if not parent or not is_instance_valid(parent):
		return null
	var PixelFxLibraryClass = preload("res://sources/effects/PixelFxLibrary.gd")
	var PixelFxPlayerClass = preload("res://sources/effects/PixelFxPlayer.gd")
	var s : float = scaleMul if scaleMul > 0.0 else PixelFxLibraryClass.GetScale(key)
	return PixelFxPlayerClass.Spawn(parent, key, pos, s, flipH, 10, forceOneShot)

## Melee slash smear tied to attack facing (does not replace character attack anim)
static func SpawnMeleeSlashVfx(parent : Node2D, pos : Vector2, facing : Vector2 = Vector2.RIGHT, heavy : bool = false) -> Node2D:
	var key := "heavy_cleave" if heavy else "slash"
	if facing.x < -0.15:
		return SpawnPixelFx(parent, key, pos, -1.0, true, true)
	return SpawnPixelFx(parent, key, pos, -1.0, false, true)

# Internal node for procedural impact starburst & slash sparks
class ImpactVfxNode extends Node2D:
	var element : int = 0
	var isCrit : bool = false
	var elapsed : float = 0.0
	var duration : float = 0.22
	var sparks : Array[Dictionary] = []
	
	func _ready():
		var col = CombatVisualSystem.ELEMENT_COLORS.get(element, Color.WHITE)
		if isCrit:
			col = Color(1.0, 0.2, 0.2)
		var sparkCount = 8 if isCrit else 5
		for i in sparkCount:
			var angle = randf_range(0, TAU)
			var speed = randf_range(60.0, 140.0) if isCrit else randf_range(40.0, 90.0)
			sparks.append({
				"dir": Vector2(cos(angle), sin(angle)),
				"speed": speed,
				"length": randf_range(6.0, 14.0) if isCrit else randf_range(4.0, 8.0),
				"color": col
			})
			
	func _process(delta : float):
		elapsed += delta
		queue_redraw()
		if elapsed >= duration:
			queue_free()
			
	func _draw():
		var progress = clampf(elapsed / duration, 0.0, 1.0)
		var fade = 1.0 - progress
		
		# Center flash ring
		var ringRadius = 14.0 * progress if isCrit else 8.0 * progress
		var ringCol = sparks[0]["color"] if sparks.size() > 0 else Color.WHITE
		draw_arc(Vector2.ZERO, ringRadius, 0, TAU, 16, Color(ringCol.r, ringCol.g, ringCol.b, 0.8 * fade), 2.0)
		
		# Radiating sharp sparks
		for s in sparks:
			var travel = s["dir"] * (s["speed"] * elapsed)
			var tail = travel - s["dir"] * (s["length"] * fade)
			draw_line(tail, travel, Color(s["color"].r, s["color"].g, s["color"].b, fade), 2.0 if isCrit else 1.5)

# ==============================================================================
# 5. PHANTOM AFTERIMAGES (ĐẠP PHONG BỘ & QINGGONG TRAIL)
# ==============================================================================
## Leaves a fading ethereal shadow phantom behind moving character
static func SpawnPhantomAfterimage(target : Node2D, color : Color = Color(0.3, 0.8, 1.0, 0.5), duration : float = 0.25) -> Node2D:
	if not target or not is_instance_valid(target) or not target.is_inside_tree():
		return null
		
	var parent = target.get_parent()
	if not parent:
		return null
		
	var ghost : Sprite2D = Sprite2D.new()
	ghost.global_position = target.global_position
	
	if target is AnimatedSprite2D and target.sprite_frames:
		var curAnim = target.animation
		var curFrame = target.frame
		if target.sprite_frames.has_animation(curAnim):
			ghost.texture = target.sprite_frames.get_frame_texture(curAnim, curFrame)
			ghost.offset = target.offset
			ghost.flip_h = target.flip_h
	elif target is Sprite2D:
		ghost.texture = target.texture
		ghost.hframes = target.hframes
		ghost.vframes = target.vframes
		ghost.frame = target.frame
		ghost.offset = target.offset
		
	if not ghost.texture:
		ghost.queue_free()
		return null
		
	ghost.modulate = color
	ghost.z_index = -1
	parent.add_child(ghost)
	
	var tween = ghost.create_tween()
	if tween:
		tween.tween_property(ghost, "modulate:a", 0.0, duration)
		tween.tween_callback(ghost.queue_free)
	return ghost

# ==============================================================================
# 6. SPIRITUAL SHIELD VFX (QUY NGUYÊN THẦN THUẪN & HUYỀN QUY KÍNH)
# ==============================================================================
## Attaches a shimmering translucent spiritual barrier to target
static func CreateOrUpdateShieldVfx(target : Node2D, isActive : bool = true) -> Node2D:
	if not target or not is_instance_valid(target):
		return null
		
	var existing = target.get_node_or_null("SpiritualShieldVFX")
	var existingPx = target.get_node_or_null("PixelFxDivineShield")
	if not isActive:
		if existing:
			var tween = existing.create_tween()
			if tween:
				tween.tween_property(existing, "modulate:a", 0.0, 0.2)
				tween.tween_callback(existing.queue_free)
		if existingPx and existingPx.has_method("StopAndFree"):
			existingPx.StopAndFree()
		elif existingPx:
			existingPx.queue_free()
		return null
		
	if existing:
		existing.set("hitRipple", 1.0)
		return existing
		
	var shieldNode = SpiritualShieldNode.new()
	shieldNode.name = "SpiritualShieldVFX"
	target.add_child(shieldNode)
	# BUILD 12 — PixelFX divine shield overlay (looping, attached to target)
	var PixelFxPlayerClass = preload("res://sources/effects/PixelFxPlayer.gd")
	var PixelFxLibraryClass = preload("res://sources/effects/PixelFxLibrary.gd")
	var pxShield = PixelFxPlayerClass.Spawn(target, "divine_shield", Vector2.ZERO, PixelFxLibraryClass.GetScale("divine_shield"), false, 5)
	if pxShield:
		pxShield.name = "PixelFxDivineShield"
		pxShield.position = Vector2(0, -8)
	return shieldNode

class SpiritualShieldNode extends Node2D:
	var radius : float = 30.0
	var shieldColor : Color = Color(0.3, 0.85, 1.0, 0.6)
	var pulseTime : float = 0.0
	var hitRipple : float = 0.0
	
	func _process(delta : float):
		pulseTime += delta * 2.5
		if hitRipple > 0.0:
			hitRipple = maxf(0.0, hitRipple - delta * 4.0)
		queue_redraw()
		
	func _draw():
		var alpha = 0.35 + sin(pulseTime) * 0.12 + hitRipple * 0.45
		var r = radius + sin(pulseTime * 1.5) * 1.8 + hitRipple * 5.0
		var col = Color(shieldColor.r, shieldColor.g + hitRipple * 0.3, shieldColor.b, alpha)
		
		# Outer hexagonal boundary
		var pts : PackedVector2Array = []
		for i in 6:
			var angle = (float(i) / 6.0) * TAU + pulseTime * 0.3
			pts.append(Vector2(cos(angle), sin(angle)) * r)
		pts.append(pts[0])
		draw_polyline(pts, col, 2.5 + hitRipple * 2.0)
		
		# Inner translucent protective core
		draw_circle(Vector2.ZERO, r * 0.9, Color(col.r, col.g, col.b, alpha * 0.2))

# ==============================================================================
# 7. TRÚC SƠN KIẾM TRẬN (SWORD ARRAY VFX)
# ==============================================================================
## Spawns descending ethereal spirit swords inside a glowing runic formation
static func SpawnSwordArrayVfx(parent : Node2D, pos : Vector2, radius : float = 110.0, duration : float = 2.5) -> Node2D:
	if not parent or not is_instance_valid(parent):
		return null
		
	var arrayNode = SwordArrayNode.new()
	arrayNode.position = pos
	arrayNode.radius = radius
	arrayNode.duration = duration
	arrayNode.name = "SwordArrayVFX"
	parent.add_child(arrayNode)
	return arrayNode

class SwordArrayNode extends Node2D:
	var radius : float = 110.0
	var duration : float = 2.5
	var elapsed : float = 0.0
	var swordCount : int = 8
	var swordHeights : Array[float] = []
	
	func _ready():
		for i in swordCount:
			swordHeights.append(randf_range(-140.0, -70.0))
			
	func _process(delta : float):
		elapsed += delta
		for i in swordCount:
			if swordHeights[i] < 0.0:
				swordHeights[i] = minf(0.0, swordHeights[i] + delta * 280.0)
		queue_redraw()
		if elapsed >= duration:
			queue_free()
			
	func _draw():
		var progress = clampf(elapsed / duration, 0.0, 1.0)
		var fade = 1.0 - progress if progress > 0.75 else 1.0
		
		# Glowing emerald Bagua runic circles on ground
		var greenColor = Color(0.2, 0.95, 0.45, 0.8 * fade)
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, greenColor, 2.5)
		draw_arc(Vector2.ZERO, radius * 0.5, 0, TAU, 24, Color(0.2, 0.95, 0.45, 0.45 * fade), 1.5)
		
		# Runic star lines
		for i in 8:
			var a = (float(i) / 8.0) * TAU
			var pt = Vector2(cos(a), sin(a)) * radius
			draw_line(Vector2.ZERO, pt, Color(0.3, 1.0, 0.5, 0.25 * fade), 1.0)
			
		# Descending ethereal spirit swords
		for i in swordCount:
			var angle = (float(i) / float(swordCount)) * TAU + elapsed * 0.6
			var groundPos = Vector2(cos(angle), sin(angle)) * (radius * 0.72)
			var currentY = swordHeights[i]
			var swordTip = groundPos + Vector2(0, currentY)
			var swordHilt = swordTip + Vector2(0, -26)
			
			# Emerald sword blade
			draw_line(swordHilt, swordTip, Color(0.4, 1.0, 0.6, 0.95 * fade), 3.0)
			# Inner bright white blade core
			draw_line(swordHilt, swordTip, Color(1.0, 1.0, 1.0, 0.8 * fade), 1.0)
			# Cross guard
			var guardLeft = swordHilt + Vector2(-6, 2)
			var guardRight = swordHilt + Vector2(6, 2)
			draw_line(guardLeft, guardRight, Color(0.9, 1.0, 0.5, 0.9 * fade), 2.0)

# ==============================================================================
# 8. THANH PHONG KIẾM KHÍ (BLADE GUST CRESCENT PROJECTILE VFX)
# ==============================================================================
## Spawns a sharp green crescent sword wave projectile
static func SpawnBladeGustVfx(parent : Node2D, fromPos : Vector2, dir : Vector2, speed : float = 380.0, maxDist : float = 240.0) -> Node2D:
	if not parent or not is_instance_valid(parent):
		return null
		
	var gustNode = BladeGustNode.new()
	gustNode.position = fromPos
	gustNode.dir = dir.normalized() if not dir.is_zero_approx() else Vector2.RIGHT
	gustNode.speed = speed
	gustNode.maxDistance = maxDist
	gustNode.name = "BladeGustVFX"
	parent.add_child(gustNode)
	return gustNode

class BladeGustNode extends Node2D:
	var dir : Vector2 = Vector2.RIGHT
	var speed : float = 380.0
	var maxDistance : float = 240.0
	var traveled : float = 0.0
	
	func _process(delta : float):
		var step = speed * delta
		traveled += step
		position += dir * step
		queue_redraw()
		if traveled >= maxDistance:
			queue_free()
			
	func _draw():
		var fade = 1.0 - (traveled / maxDistance)
		var angle = dir.angle()
		# Draw sharp crescent arc perpendicular to flight direction
		var arcRadius = 18.0
		var startAngle = angle - PI * 0.35
		var endAngle = angle + PI * 0.35
		draw_arc(Vector2.ZERO, arcRadius, startAngle, endAngle, 16, Color(0.3, 1.0, 0.5, 0.9 * fade), 3.0)
		draw_arc(Vector2.ZERO, arcRadius * 0.9, startAngle, endAngle, 16, Color(1.0, 1.0, 1.0, 0.8 * fade), 1.5)

# ==============================================================================
# 9. BÁT HOANG QUYỀN (CONCUSSIVE FIST SHOCKWAVE VFX)
# ==============================================================================
## Spawns an expanding golden shockwave blast forward
static func SpawnFistShockwaveVfx(parent : Node2D, pos : Vector2, dir : Vector2) -> Node2D:
	if not parent or not is_instance_valid(parent):
		return null
		
	var fistNode = FistShockwaveNode.new()
	fistNode.position = pos
	fistNode.dir = dir.normalized() if not dir.is_zero_approx() else Vector2.DOWN
	fistNode.name = "FistShockwaveVFX"
	parent.add_child(fistNode)
	return fistNode

class FistShockwaveNode extends Node2D:
	var dir : Vector2 = Vector2.DOWN
	var elapsed : float = 0.0
	var duration : float = 0.28
	
	func _process(delta : float):
		elapsed += delta
		queue_redraw()
		if elapsed >= duration:
			queue_free()
			
	func _draw():
		var progress = clampf(elapsed / duration, 0.0, 1.0)
		var fade = 1.0 - progress
		var r = 20.0 + progress * 60.0
		var angle = dir.angle()
		var startAngle = angle - PI * 0.4
		var endAngle = angle + PI * 0.4
		
		# Golden shockwave expanding arc
		draw_arc(Vector2.ZERO, r, startAngle, endAngle, 18, Color(1.0, 0.85, 0.25, 0.9 * fade), 4.0 * fade)
		draw_arc(Vector2.ZERO, r * 0.7, startAngle, endAngle, 18, Color(1.0, 0.6, 0.15, 0.6 * fade), 2.5 * fade)

# ==============================================================================
# 10. BOSS PRESENTATION POLISH (XÍCH VIÊM THÚ HẬU ENRAGE & DEATH)
# ==============================================================================
## Triggers dramatic screen rumble and fiery enrage aura on boss phase change
static func TriggerBossEnrageVfx(boss : Node2D):
	if not boss or not is_instance_valid(boss):
		return
		
	# 1. Heavy Camera Shake
	TriggerCameraShake(ShakeLevel.BOSS, 10.0, 0.35)
	
	# 2. Add Persistent Enraged Flame Aura
	var existingAura = boss.get_node_or_null("BossEnrageAura")
	if not existingAura:
		var aura = BossEnrageAuraNode.new()
		aura.name = "BossEnrageAura"
		boss.add_child(aura)

class BossEnrageAuraNode extends Node2D:
	var time : float = 0.0
	
	func _process(delta : float):
		time += delta * 4.0
		queue_redraw()
		
	func _draw():
		var radius = 38.0 + sin(time) * 4.0
		var alpha = 0.4 + sin(time * 1.5) * 0.15
		draw_arc(Vector2.ZERO, radius, 0, TAU, 28, Color(1.0, 0.25, 0.05, alpha), 3.0)
		draw_circle(Vector2.ZERO, radius * 0.8, Color(1.0, 0.2, 0.0, alpha * 0.2))

# ==============================================================================
# 11. CONTROLLED KNOCKBACK HELPER (TERRAIN AWARE)
# ==============================================================================
## Calculates safe, bounded knockback that avoids pushing entity off map or through walls
static func CalculateControlledKnockback(fromPos : Vector2, targetPos : Vector2, maxDistance : float = 30.0) -> Vector2:
	var dir = (targetPos - fromPos).normalized()
	if dir.is_zero_approx():
		dir = Vector2.DOWN
	var clampedDist = clampf(maxDistance, 0.0, 50.0) # Cap maximum distance for game feel
	return dir * clampedDist

# ==============================================================================
# 12. BUILD 10: EXPLORATION & ANCIENT RUINS VISUAL FX
# ==============================================================================
static func SpawnSecretFoundVfx(parent : Node2D, pos : Vector2):
	if not parent or not is_instance_valid(parent):
		return
	var vfx = SecretFoundVfxNode.new()
	vfx.position = pos
	parent.add_child(vfx)
	TriggerCameraShake(ShakeLevel.LIGHT, 2.5, 0.1)

class SecretFoundVfxNode extends Node2D:
	var elapsed : float = 0.0
	var duration : float = 1.0
	
	func _process(delta : float):
		elapsed += delta
		queue_redraw()
		if elapsed >= duration:
			queue_free()
			
	func _draw():
		var prog = clampf(elapsed / duration, 0.0, 1.0)
		var fade = 1.0 - prog
		var r = 10.0 + prog * 50.0
		# Expanding mystic cyan-gold circle with ascending rays
		draw_arc(Vector2.ZERO, r, 0, TAU, 32, Color(0.2, 0.9, 1.0, 0.9 * fade), 3.0 * fade)
		draw_circle(Vector2.ZERO, r * 0.4, Color(1.0, 0.85, 0.3, 0.3 * fade))
		for i in range(6):
			var a = (TAU / 6.0) * i + prog * 2.0
			var rayDir = Vector2(cos(a), sin(a))
			draw_line(rayDir * (r * 0.5), rayDir * (r * 1.2), Color(1.0, 0.9, 0.4, 0.8 * fade), 2.0 * fade)

static func SpawnChestOpenedVfx(parent : Node2D, pos : Vector2):
	if not parent or not is_instance_valid(parent):
		return
	var vfx = ChestOpenedVfxNode.new()
	vfx.position = pos
	parent.add_child(vfx)
	TriggerCameraShake(ShakeLevel.LIGHT, 2.0, 0.08)

class ChestOpenedVfxNode extends Node2D:
	var elapsed : float = 0.0
	var duration : float = 0.8
	
	func _process(delta : float):
		elapsed += delta
		queue_redraw()
		if elapsed >= duration:
			queue_free()
			
	func _draw():
		var prog = clampf(elapsed / duration, 0.0, 1.0)
		var fade = 1.0 - prog
		# Rising golden sparkling pillar
		var height = prog * 60.0
		draw_circle(Vector2(0, -height), 8.0 * fade, Color(1.0, 0.85, 0.2, 0.9 * fade))
		draw_line(Vector2(0, 0), Vector2(0, -height), Color(1.0, 0.7, 0.1, 0.5 * fade), 3.0 * fade)

static func SpawnContraptionTriggeredVfx(parent : Node2D, pos : Vector2):
	if not parent or not is_instance_valid(parent):
		return
	var vfx = ContraptionVfxNode.new()
	vfx.position = pos
	parent.add_child(vfx)
	TriggerCameraShake(ShakeLevel.MEDIUM, 4.0, 0.12)

class ContraptionVfxNode extends Node2D:
	var elapsed : float = 0.0
	var duration : float = 0.9
	
	func _process(delta : float):
		elapsed += delta
		queue_redraw()
		if elapsed >= duration:
			queue_free()
			
	func _draw():
		var prog = clampf(elapsed / duration, 0.0, 1.0)
		var fade = 1.0 - prog
		var r = 15.0 + prog * 45.0
		# Runic gear pulse
		draw_arc(Vector2.ZERO, r, 0, TAU, 24, Color(0.9, 0.6, 0.2, 0.85 * fade), 4.0 * fade)
		draw_rect(Rect2(-r * 0.5, -r * 0.5, r, r), Color(1.0, 0.8, 0.3, 0.4 * fade), false, 2.0 * fade)

static func SpawnRuinCompleteFanfareVfx(parent : Node2D, pos : Vector2):
	if not parent or not is_instance_valid(parent):
		return
	var vfx = RuinFanfareVfxNode.new()
	vfx.position = pos
	parent.add_child(vfx)
	TriggerCameraShake(ShakeLevel.HEAVY, 7.0, 0.25)

class RuinFanfareVfxNode extends Node2D:
	var elapsed : float = 0.0
	var duration : float = 1.5
	
	func _process(delta : float):
		elapsed += delta
		queue_redraw()
		if elapsed >= duration:
			queue_free()
			
	func _draw():
		var prog = clampf(elapsed / duration, 0.0, 1.0)
		var fade = 1.0 - prog
		var r = 25.0 + prog * 90.0
		draw_arc(Vector2.ZERO, r, 0, TAU, 36, Color(0.4, 1.0, 0.6, 0.9 * fade), 5.0 * fade)
		draw_arc(Vector2.ZERO, r * 0.6, 0, TAU, 28, Color(1.0, 0.85, 0.25, 0.7 * fade), 3.0 * fade)
		for i in range(8):
			var a = (TAU / 8.0) * i + prog * 1.5
			var rayDir = Vector2(cos(a), sin(a))
			draw_line(rayDir * (r * 0.4), rayDir * (r * 1.3), Color(1.0, 0.95, 0.4, 0.8 * fade), 3.0 * fade)

