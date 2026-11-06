extends Node2D
class_name EntityInteractive

#
@onready var visibleNode : Node2D			= $TopOffset
@onready var speechContainer : BoxContainer	= $TopOffset/TopBox/Panel/SpeechContainer
@onready var emoteFx : GPUParticles2D		= $TopOffset/Emote
@onready var healthBar : TextureProgressBar	= $UnderBox/HealthBar
@onready var nameLabel : Label				= $UnderBox/Name
@onready var skillPreview : Control			= $SkillPreview
@onready var clickShape : CollisionShape2D	= $ClickArea/ClickShape

@onready var entity : Entity				= get_parent()

var displayName : bool						= false
var selectionFx : GPUParticles2D			= null
var visualOffset : int						= -1
var hpFadeTween : Tween						= null
var currentCastFx : GPUParticles2D			= null
var buffFxs : Dictionary[CellCommons.Modifier, Node2D]	= {}

var speechYExtraOffset : float				= 0.0
var speechOffsetTween : Tween				= null

#
func _ready():
	set_process(false)

func _process(_delta : float):
	Entities.ScheduleSpeechRearrange()

# Custom mouse
func _on_click_area_mouse_entered():
	if not Launcher.Player:
		return

	match entity.type:
		ActorCommons.Type.PLAYER:
			if not ActorCommons.IsSameActor(Launcher.Player, entity):
				Entities.SetHovered(entity)
		ActorCommons.Type.NPC:
			Entities.SetHovered(entity)
		ActorCommons.Type.MONSTER:
			Entities.SetHovered(entity)

func _on_click_area_mouse_exited():
	if Entities.hovered == entity:
		Entities.ClearHovered()

# Displays
func DisplaySelection(hue : float, alpha : float = 1.0):
	if selectionFx == null:
		selectionFx = ActorCommons.SelectionFx.instantiate()
		add_child(selectionFx)

		if selectionFx and ActorCommons.interactionDisplayOffset > 0:
			var targetRadius : int = entity.data._radius if entity.data else ActorCommons.selectionRadius
			var sizeRatio : float = float(targetRadius) / float(ActorCommons.selectionRadius)
			if entity.data:
				selectionFx.position.y = -entity.data._groundOffset
			var emissionShapeScale : Vector3 = selectionFx.process_material.get("emission_shape_scale")
			if emissionShapeScale != Vector3.ZERO:
				var emissionShapeOffset : Vector3 = selectionFx.process_material.get("emission_shape_offset")
				var emissionGravity : Vector3 = selectionFx.process_material.get("gravity")
				selectionFx.process_material.set("emission_shape_scale", emissionShapeScale * sizeRatio)
				selectionFx.process_material.set("emission_shape_offset", emissionShapeOffset * sizeRatio)
				selectionFx.process_material.set("gravity", emissionGravity * sizeRatio)
			selectionFx.amount_ratio = sizeRatio

	if selectionFx:
		var colorRamp : GradientTexture1D = selectionFx.process_material.get("color_ramp")
		if colorRamp and colorRamp.gradient.colors.size() > 1:
			var colorGradient : Color = colorRamp.gradient.get_color(1)
			colorGradient.h = hue
			colorGradient.a = alpha
			colorRamp.gradient.set_color(1, colorGradient)
			selectionFx.process_material.set("color_ramp", colorRamp)

func DisplayTarget(type : ActorCommons.Target):
	match type:
		ActorCommons.Target.NONE:
			if selectionFx and selectionFx.emitting:
				DisplaySelection(0.0, 0.0)
				selectionFx.emitting = false
				Callback.SelfDestructTimer(selectionFx, selectionFx.lifetime, Util.RemoveNode, [selectionFx, self])
				selectionFx = null
			if nameLabel and nameLabel.material:
				nameLabel.material = null
			return
		ActorCommons.Target.ALLY:
			nameLabel.material = ActorCommons.AllyTarget
			DisplaySelection(ActorCommons.PlayerColor)
		ActorCommons.Target.ENEMY:
			nameLabel.material = ActorCommons.EnemyTarget
			DisplaySelection(ActorCommons.MonsterColor)

func DisplayEmote(emoteID : int):
	assert(emoteFx != null, "No emote particle found, could not display emote")
	if emoteFx:
		if DB.EmotesDB and emoteID in DB.EmotesDB:
			var emote : BaseCell = DB.EmotesDB[emoteID]
			emoteFx.texture = emote.icon
			emoteFx.lifetime = ActorCommons.emoteDelay
			emoteFx.restart()
			if entity == Launcher.Player:
				emote.used.emit()

#
func DisplayMorph(callback : Callable, args : Array):
	var particle : GPUParticles2D = ActorCommons.MorphFx.instantiate()
	if particle:
		Callback.SelfDestructTimer(self, ActorCommons.morphDelay, callback, args)
		particle.finished.connect(Util.RemoveNode.bind(particle, self))
		particle.emitting = true
		add_child(particle)

#
func DisplayLevelUp():
	var particle : GPUParticles2D = ActorCommons.LevelUpFx.instantiate()
	if particle:
		particle.finished.connect(Util.RemoveNode.bind(particle, self))
		particle.emitting = true
		add_child(particle)
	# BUILD 12 — PixelFX level-up burst (keeps existing particle)
	if Launcher.Map and Launcher.Map.currentFringe and entity:
		var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
		CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, "level_up", entity.global_position, -1.0, false, true)
		CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, "mana_burst", entity.global_position, -1.0, false, true)

#
func DisplaySkillRange(skill : SkillCell):
	if skill:
		skillPreview.Display(skill.skillRange + entity.stat.current.attackRange)
	else:
		skillPreview.Hide()
	skillPreview.queue_redraw()

func StopCasting():
	if currentCastFx:
		currentCastFx.emitting = false
		Callback.SelfDestructTimer(currentCastFx, currentCastFx.lifetime, Util.RemoveNode, [currentCastFx, self])
		currentCastFx = null

func DisplayBuff(effect : CellCommons.Modifier, skillID : int, enabled : bool):
	var buffFx : Node2D = buffFxs.get(effect, null)
	if enabled:
		if not buffFx:
			var skill : SkillCell = DB.SkillsDB.get(skillID, null)
			var preset : PackedScene = skill.buffPreset if skill else null
			if preset:
				buffFx = preset.instantiate()
				buffFxs[effect] = buffFx
				buffFx.set("emitting", true)
				add_child(buffFx)
	elif buffFx:
		buffFxs.erase(effect)
		buffFx.set("emitting", false)
		var lifetime : float = buffFx.get("lifetime") if buffFx.get("lifetime") else 0.0
		if lifetime > 0.0:
			Callback.SelfDestructTimer(buffFx, lifetime, Util.RemoveNode, [buffFx, self])
		else:
			Util.RemoveNode(buffFx, self)

func DisplayCast(skillID : int):
	if DB.SkillsDB.has(skillID):
		var skill : SkillCell = DB.SkillsDB[skillID]
		if skill.castPreset:
			StopCasting()
			currentCastFx = skill.castPreset.instantiate()
			if currentCastFx:
				currentCastFx.emitting = true
				add_child(currentCastFx)
	else:
		StopCasting()

func DisplaySkill(emitter : Entity, skillID : int, cooldown : float):
	if DB.SkillsDB.has(skillID):
		var skill : SkillCell = DB.SkillsDB[skillID]
		if skill:
			if emitter == Launcher.Player and cooldown > 0.0:
				skill.used.emit(cooldown)
			# PixelFX / xianxia VFX on cast: skills only (melee stays clean — slash happens on hit).
			var isMelee : bool = skill.name == SkillCommons.SkillMeleeName or skillID == 229218829
			var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
			var martial : Dictionary = CombatSystemClass.GetMartialForSkill(skillID, skill.name)
			var martialId : int = int(martial.get("id", 0))
			# Skip legacy GPUParticles when we already have dedicated martial VFX (avoids double clutter)
			var useLegacyParticles : bool = skill.skillPreset != null and martialId == 0
			if useLegacyParticles:
				var skillFx : GPUParticles2D = skill.skillPreset.instantiate()
				if skillFx:
					skillFx.finished.connect(Util.RemoveNode.bind(skillFx, emitter))
					skillFx.lifetime = skill.skillTime
					skillFx.emitting = true
					emitter.add_child(skillFx)
			if not isMelee and Launcher.Map and Launcher.Map.currentFringe and emitter:
				var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
				var facing : Vector2 = Vector2.RIGHT
				if emitter.entityVelocity.length_squared() > 4.0:
					facing = emitter.entityVelocity
				elif emitter.velocity.length_squared() > 4.0:
					facing = emitter.velocity
				elif emitter.has_method("get") and emitter.get("entityOrientation"):
					facing = emitter.entityOrientation
				match martialId:
					1002: # Thanh Phong Kiếm Khí — blade gust
						CombatVisualSystemClass.SpawnBladeGustVfx(Launcher.Map.currentFringe, emitter.global_position, facing)
						CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, "slash", emitter.global_position, -1.0, facing.x < 0.0, true)
					1003: # Trúc Sơn Kiếm Trận — sword array
						CombatVisualSystemClass.SpawnSwordArrayVfx(Launcher.Map.currentFringe, emitter.global_position)
						CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, "double_slash", emitter.global_position, -1.0, false, true)
					1004: # Đạp Phong Bộ — dash trail
						CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, "lightning_charge", emitter.global_position, -1.0, false, true)
					1005: # Bát Hoang — fist shockwave
						CombatVisualSystemClass.SpawnFistShockwaveVfx(Launcher.Map.currentFringe, emitter.global_position, facing)
						CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, "ground_slam", emitter.global_position, -1.0, false, true)
					1006: # Quy Nguyên — spiritual shield
						CombatVisualSystemClass.CreateOrUpdateShieldVfx(emitter, true)
						CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, "divine_shield", emitter.global_position, -1.0, false, true)
					_:
						# Prefer martial fxKey / fxKey2 (new phép+tu tiên skills + ultimates)
						var key : String = String(martial.get("fxKey", ""))
						if key.is_empty():
							var elem : int = int(martial.get("element", 0))
							var Lib = preload("res://sources/effects/PixelFxLibrary.gd")
							key = Lib.ElementKey(elem, false)
							if key == "hit_spark":
								key = "mana_burst"
						CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, key, emitter.global_position, -1.0, false, true)
						var key2 : String = String(martial.get("fxKey2", ""))
						if not key2.is_empty():
							CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, key2, emitter.global_position, -1.0, false, true)

func DisplayProjectile(targetPos : Vector2, skill : SkillCell):
	if Launcher.Map.currentFringe and skill and skill.projectilePreset:
		var projectileNode : Node2D = skill.projectilePreset.instantiate()
		if not projectileNode:
			return
		if projectileNode is Projectile:
			projectileNode.origin = entity.interactive.visibleNode.global_position
			projectileNode.origin.y += ActorCommons.interactionDisplayOffset
			projectileNode.destination = targetPos
			projectileNode.destination.y -= ActorCommons.interactionDisplayOffset
			projectileNode.delay = entity.stat.current.castAttackDelay
			Launcher.Map.currentFringe.add_child(projectileNode)
		else:
			projectileNode.global_position = targetPos
			projectileNode.finished.connect(Util.RemoveNode.bind(projectileNode, Launcher.Map.currentFringe))
			projectileNode.emitting = true
			Launcher.Map.currentFringe.add_child(projectileNode)

func DisplayAlteration(target : Entity, emitter : Entity, value : int, alteration : ActorCommons.Alteration, skillID : int):
	if Launcher.Map.currentFringe:
		var newLabel : Label = ActorCommons.AlterationLabel.instantiate()
		newLabel.SetPosition(visibleNode.get_global_position(), target.get_global_position())

		# Resolve elemental affinity from skill/martial data (SkillCell.id ≠ martial id)
		var elem : int = 0
		var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
		var skillNameHint : String = ""
		if DB.SkillsDB.has(skillID):
			skillNameHint = DB.SkillsDB[skillID].name
		var martialData = CombatSystemClass.GetMartialForSkill(skillID, skillNameHint)
		if not martialData.is_empty():
			elem = martialData.get("element", 0)

		if newLabel.has_method("SetElementalValue"):
			newLabel.SetElementalValue(emitter, target, value, alteration, elem)
		else:
			newLabel.SetValue(emitter, target, value, alteration)
		Launcher.Map.currentFringe.add_child(newLabel)

		if entity.type != ActorCommons.Type.PLAYER:
			if alteration == ActorCommons.Alteration.HEAL:
				target.stat.health += value
				target.stat.RefreshVitalStats()
			elif alteration == ActorCommons.Alteration.HIT or alteration == ActorCommons.Alteration.CRIT:
				target.stat.health -= value
				target.stat.RefreshVitalStats()

		if (alteration == ActorCommons.Alteration.HIT or alteration == ActorCommons.Alteration.CRIT):
			if target.visual:
				target.visual.TriggerHurtFeedback()
			var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
			var skillCell : SkillCell = DB.SkillsDB.get(skillID, null)
			var isMeleeHit : bool = skillCell != null and (skillCell.name == SkillCommons.SkillMeleeName or skillID == 229218829)
			# Light impact for all hits; slash smear only for normal attack (skills keep elemental cast FX).
			CombatVisualSystemClass.SpawnImpactVfx(Launcher.Map.currentFringe, target.global_position, elem, alteration == ActorCommons.Alteration.CRIT)
			if isMeleeHit and emitter and emitter != target:
				var facing : Vector2 = Vector2.RIGHT
				if emitter is Entity and emitter.entityVelocity.length_squared() > 4.0:
					facing = emitter.entityVelocity
				elif emitter.velocity.length_squared() > 4.0:
					facing = emitter.velocity
				CombatVisualSystemClass.SpawnMeleeSlashVfx(Launcher.Map.currentFringe, target.global_position, facing, alteration == ActorCommons.Alteration.CRIT)
		elif alteration == ActorCommons.Alteration.HEAL:
			var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
			CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, "heal", target.global_position, -1.0, false, true)

		if emitter != target and Launcher.Player == emitter:
			var skill : SkillCell = DB.SkillsDB.get(skillID, null)
			if skill and skill.mode == Skill.TargetMode.SINGLE:
				DisplayHP()

# Speech
func DisplaySpeech(speech : String):
	assert(speechContainer != null, "No speech container found, could not display speech bubble")
	if speechContainer:
		var speechLabel : RichTextLabel = ActorCommons.SpeechLabel.instantiate()
		speechLabel.set_text("[center]%s[/center]" % [speech])
		speechLabel.set_visible_ratio(0)
		speechContainer.add_child(speechLabel)
		if not self in Entities.speechEntities:
			Entities.speechEntities.append(self)
			set_process(true)
		Callback.SelfDestructTimer(speechLabel, ActorCommons.speechDelay, OnSpeechLabelRemoved, [speechLabel])

func OnSpeechLabelRemoved(speechLabel : RichTextLabel):
	Util.RemoveNode(speechLabel, speechContainer)
	if speechContainer.get_child_count() == 0:
		Entities.speechEntities.erase(self)
		set_process(false)
		TweenSpeechOffset(0.0)

# Speech offset
func SetSpeechOffset(value : float):
	speechYExtraOffset = value
	RefreshVisibleNodeOffset()

func RefreshVisibleNodeOffset():
	if entity.visual:
		var offset : int = entity.visual.GetPlayerOffset()

		visibleNode.position.y = -(offset + ActorCommons.interactionDisplayOffset + speechYExtraOffset)
		visualOffset = clampi(offset, ActorCommons.minVisualOffset, ActorCommons.MaxEntityRadiusSize)
		if clickShape:
			clickShape.shape.height = offset * 1.1
			clickShape.position.y = -offset / 2.0

func TweenSpeechOffset(target : float):
	if is_equal_approx(speechYExtraOffset, target):
		return

	if speechOffsetTween:
		speechOffsetTween.kill()
	speechOffsetTween = create_tween()
	speechOffsetTween.tween_method(SetSpeechOffset, speechYExtraOffset, target, ActorCommons.speechGroupTweenDuration)
	speechOffsetTween.tween_callback(func(): speechOffsetTween = null)

#
func DisplayHP():
	if hpFadeTween:
		hpFadeTween.kill()
		hpFadeTween = null
	if not ActorCommons.IsAlive(entity) or entity.stat.health == 0 or (entity.stat.current.maxHealth == 0 and healthBar.max_value == 0):
		HideHP()
		return

	if Launcher.Player:
		if Entities.target != entity:
			Callback.SelfDestructTimer(healthBar, ActorCommons.DisplayHPDelay, HideHP, [], "HideHP")
		if entity.stat.level >= Launcher.Player.stat.level and ActorCommons.LevelDifferenceColor:
			nameLabel.modulate = lerp(Color.WHITE, Color.RED, (entity.stat.level - Launcher.Player.stat.level) / ActorCommons.LevelDifferenceColor)

	healthBar.visible = true
	healthBar.modulate.a = 1
	nameLabel.visible = true
	nameLabel.modulate.a = 1

	if entity.stat.current.maxHealth != 0:
		healthBar.max_value = entity.stat.current.maxHealth
	if healthBar.max_value > 0:
		healthBar.value = entity.stat.health
		var ratio : float = healthBar.value / healthBar.max_value
		if ratio <= 0.33:
			healthBar.tint_progress = Color.RED.lerp(Color.YELLOW, ratio * 3.0)
		elif ratio <= 0.66:
			healthBar.tint_progress = Color.YELLOW.lerp(Color.GREEN, (ratio-0.33) * 3.0)
		else:
			healthBar.tint_progress = Color.GREEN

func RefreshHP():
	if healthBar.visible:
		DisplayHP()

func HideHP():
	if not healthBar.visible:
		return
	if hpFadeTween:
		hpFadeTween.kill()
	var duration : float = healthBar.modulate.a / 2.0
	hpFadeTween = create_tween()
	hpFadeTween.tween_property(healthBar, "modulate:a", 0.0, duration)
	if not displayName:
		hpFadeTween.parallel().tween_property(nameLabel, "modulate:a", 0.0, duration)
	hpFadeTween.tween_callback(func():
		healthBar.visible = false
		nameLabel.visible = displayName
		hpFadeTween = null
	)

func DisplaySailContext():
	Launcher.GUI.choiceContext.Clear()
	Launcher.GUI.choiceContext.Push(ContextData.new("ui_context_validate", "Explore", Network.TriggerExplore.bind()))
	Launcher.GUI.choiceContext.Push(ContextData.new("ui_context_cancel", "Cancel", Callback.Empty.bind()))
	Launcher.GUI.choiceContext.FadeIn(true)

#
func Init(data : EntityData):
	displayName = (entity.type == ActorCommons.Type.PLAYER or data._displayName) and entity != Launcher.Player

	if nameLabel:
		nameLabel.set_text(entity.nick)
		nameLabel.set_visible(displayName)
		match entity.type:
			ActorCommons.Type.NPC:
				nameLabel.set("theme_override_colors/font_color", ActorCommons.NPCTextColor)
			ActorCommons.Type.MONSTER:
				nameLabel.set("theme_override_colors/font_color", ActorCommons.MonsterTextColor)

	if entity.visual:
		if not entity.visual.spriteOffsetUpdate.is_connected(RefreshVisibleNodeOffset):
			entity.visual.spriteOffsetUpdate.connect(RefreshVisibleNodeOffset)
		RefreshVisibleNodeOffset()

	if clickShape:
		clickShape.shape.radius = max(data._radius * 1.1, ActorCommons.targetRadius)

func _exit_tree():
	if self in Entities.speechEntities:
		Entities.speechEntities.erase(self)
		Entities.ScheduleSpeechRearrange()
