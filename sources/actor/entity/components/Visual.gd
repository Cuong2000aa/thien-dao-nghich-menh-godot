extends Node2D
class_name EntityVisual

const LightSourceScene : PackedScene = preload(Path.EffectsPst + "LightSource.tscn")

#
signal spriteOffsetUpdate
signal state_changed(state : ActorCommons.State)

#
@onready var entity : Entity				= get_parent()

var preset : Node2D							= null
var questHighlight : Node2D					= null
var animation : AnimationPlayer				= null
var animationTree : AnimationTree			= null
var animatedSprite : AnimatedSprite2D		= null
var currentAction : String					= "idle"
var currentDirection : String				= "south"
var isDodging : bool						= false
var isComboFinisher : bool					= false
var idleBreathTime : float					= 0.0
var afterimageTimer : float					= 0.0

const SWORDSMAN_FOOT_OFFSETS = {
	"idle": Vector2(20, 38),
	"walk": Vector2(20, 38),
	"attack": Vector2(36, 58),
	"hurt": Vector2(28, 48),
	"death": Vector2(28, 48),
	"qinggong": Vector2(36, 58),
	"combo": Vector2(36, 58)
}

const SWORDSMAN_DIRECTIONS = [
	"east", "south-east", "south", "south-west",
	"west", "north-west", "north", "north-east"
]

var sprites : Array[Sprite2D]				= []

var previousOrientation : Vector2			= Vector2.ZERO
var previousState : ActorCommons.State		= ActorCommons.State.UNKNOWN
var previousAnimState : ActorCommons.State	= ActorCommons.State.UNKNOWN

var blendSpacePaths : Array[String]			= []
var walkTimeScalePath : String				= ""
var attackTimeScalePath : String			= ""

var equipmentEffects : Array[Node2D]		= []
var skillCastID : int						= DB.UnknownHash
var attackAnimLength : float				= 1.0
var originalAnimationLib : AnimationLibrary	= null
var defaultHframes : Dictionary				= {}
var defaultVframes : Dictionary				= {}

#
func LoadSpriteSlot(slot : ActorCommons.Slot, sprite : Sprite2D):
	if sprites[slot] != sprite:
		if sprites[slot]:
			sprites[slot].queue_free()
			sprites[slot] = null

		if sprite:
			sprites[slot] = sprite
			if slot == ActorCommons.Slot.BODY:
				spriteOffsetUpdate.emit()

func ResetData():
	if preset:
		preset.queue_free()
	for effect in equipmentEffects:
		if effect:
			effect.queue_free()
	for spriteID in sprites.size():
		sprites[spriteID] = null
	equipmentEffects.fill(null)
	preset = null
	questHighlight = null
	originalAnimationLib = null
	animatedSprite = null
	currentAction = "idle"
	currentDirection = "south"

func AddPreset(presetNode : Node2D):
	if presetNode != preset:
		if is_instance_valid(presetNode) and not presetNode.is_queued_for_deletion():
			presetNode.queue_free()
		return
	if is_instance_valid(presetNode):
		add_child(presetNode)

func LoadData(data : EntityData):
	ResetData()

	# Sprite Preset
	if data._spritePreset:
		preset = data._spritePreset.instantiate()
		if preset:
			AddPreset.call_deferred(preset)

		# Animation
		if preset and preset.has_node("Animation"):
			animation = preset.get_node("Animation")

		# Animation Tree
		if animation and animation.has_node("AnimationTree"):
			animationTree = animation.get_node("AnimationTree")
			if animationTree:
				animationTree.set_active(true)

		# Animated Sprite (for 8-directional characters like Swordsman)
		if preset:
			if preset is AnimatedSprite2D:
				animatedSprite = preset
			elif preset.has_node("AnimatedSprite2D"):
				animatedSprite = preset.get_node("AnimatedSprite2D")
			if animatedSprite:
				UpdateSwordsmanVisual(Vector2.ZERO, entity.entityOrientation, entity.state, false)

		# Sprites
		if preset:
			for slot in ActorCommons.Slot.COUNT:
				if slot == ActorCommons.Slot.BODY:
					SetBody()
				elif slot == ActorCommons.Slot.FACE:
					SetFace()
				elif slot == ActorCommons.Slot.HAIR:
					SetHair(false)
				elif slot >= ActorCommons.Slot.FIRST_EQUIPMENT and slot < ActorCommons.Slot.LAST_EQUIPMENT:
					SetEquipment(slot, data, false)

			questHighlight = preset.get_node_or_null("QuestHighlight")
			RefreshQuestHighlight()

	ApplyAnimationOverrides()
	ResetAnimationValue()

func RefreshQuestHighlight():
	if not questHighlight:
		return

	var questState : int = Launcher.Player.progress.GetQuest(entity.data._questID) if Launcher.Player else ProgressCommons.UnknownProgress
	questHighlight.visible = entity.data.IsQuestStateVisible(questState)

func SetSkinSlot(slot : ActorCommons.Slot, raceData : RaceData, textures : Array[Texture2D]):
	var sprite : Sprite2D = preset.get_node_or_null(ActorCommons.GetSlotName(slot))
	if not sprite:
		return

	var slotTexture : Texture2D = sprite.get_texture()
	var slotMaterial : Material = null

	if not entity.stat.IsMorph():
		var hasOverrideTexture : bool = false
		var hasOverrideMaterial : bool = false

		if entity.data and slot == ActorCommons.Slot.BODY:
			if entity.data._customTexture:
				slotTexture = entity.data._customTexture
				hasOverrideTexture = true
			if entity.data._customMaterial:
				slotMaterial = entity.data._customMaterial
				hasOverrideMaterial = true

		if not hasOverrideTexture:
			slotTexture = textures[entity.stat.gender]
		if not hasOverrideMaterial:
			var skinMat : Material = raceData.GetSkinMaterial(entity.stat.skintone)
			if skinMat:
				slotMaterial = skinMat

	sprite.set_texture(slotTexture)
	sprite.set_material(slotMaterial)
	LoadSpriteSlot(slot, sprite)

func SetBody():
	if entity.stat.race == DB.UnknownHash:
		SetData(ActorCommons.Slot.BODY, entity.data)
	else:
		var raceData : RaceData = DB.GetRace(entity.stat.race)
		if raceData:
			SetSkinSlot(ActorCommons.Slot.BODY, raceData, raceData.bodies)

func SetFace():
	if entity.stat.race == DB.UnknownHash:
		return
	var raceData : RaceData = DB.GetRace(entity.stat.race)
	if raceData:
		SetSkinSlot(ActorCommons.Slot.FACE, raceData, raceData.faces)

func SetHair(applyOverrides : bool = true):
	var slotName : String = ActorCommons.GetSlotName(ActorCommons.Slot.HAIR)
	var sprite : Sprite2D = preset.get_node_or_null(slotName)
	if not sprite:
		return

	var slot : int = ActorCommons.Slot.HAIR
	if slot not in defaultHframes:
		defaultHframes[slot] = sprite.hframes
		defaultVframes[slot] = sprite.vframes

	var slotTexture : Texture2D = null
	var slotMaterial : Material = null
	var hairstyleData : HairstyleData = null

	if not entity.stat.IsMorph():
		hairstyleData = DB.GetHairstyle(entity.stat.hairstyle) if entity.stat.hairstyle != DB.UnknownHash else null
		var haircolorData : FileData = DB.GetPalette(DB.Palette.HAIR, entity.stat.haircolor) if entity.stat.haircolor != DB.UnknownHash else null
		if hairstyleData != null and haircolorData != null:
			slotTexture = hairstyleData.texture
			slotMaterial = haircolorData._resource as Material

	sprite.set_texture(slotTexture)
	sprite.set_material(slotMaterial)

	if hairstyleData and hairstyleData.spriteHframes > 0:
		sprite.hframes = hairstyleData.spriteHframes
		sprite.vframes = max(1, hairstyleData.spriteVframes)
	else:
		sprite.hframes = defaultHframes[slot]
		sprite.vframes = defaultVframes[slot]

	LoadSpriteSlot(slot, sprite)
	if applyOverrides:
		ApplyAnimationOverrides()

func SetEquipment(slot : int, data : EntityData = null, applyOverrides : bool = true):
	var slotName : String = ActorCommons.GetSlotName(slot)
	var sprite : Sprite2D = preset.get_node_or_null(slotName) if preset else null
	var cell : ItemCell = null
	if not entity.stat.IsMorph():
		if entity.inventory:
			cell = entity.inventory.GetEquipmentCell(slot)
		elif data and data._equipment.has(slot):
			cell = data._equipment[slot]

	# Swordsman (AnimatedSprite2D) has no paperdoll slots — show weapon/shield overlay + tint.
	if not sprite and animatedSprite:
		_ApplySwordsmanEquipOverlay(slot, cell)
		return

	if not sprite:
		return

	if slot not in defaultHframes:
		defaultHframes[slot] = sprite.hframes
		defaultVframes[slot] = sprite.vframes

	var slotTexture : Texture2D = null
	var slotMaterial : Material = null

	if cell != null:
		slotTexture = cell.textures[entity.stat.gender]
		slotMaterial = cell.shader

	sprite.set_texture(slotTexture)
	sprite.set_material(slotMaterial)

	if cell and cell.spriteHframes > 0:
		sprite.hframes = cell.spriteHframes
		sprite.vframes = max(1, cell.spriteVframes)
	else:
		sprite.hframes = defaultHframes[slot]
		sprite.vframes = defaultVframes[slot]

	SetEquipmentMetadata(slot, cell)
	LoadSpriteSlot(slot, sprite)
	if applyOverrides:
		ApplyAnimationOverrides()

## Minimal paperdoll bridge for Swordsman: weapon/shield icon overlay + body tint when armed.
func _ApplySwordsmanEquipOverlay(slot : int, cell : ItemCell) -> void:
	if slot != ActorCommons.Slot.WEAPON and slot != ActorCommons.Slot.SHIELD:
		return
	var overlayName := "SwordsmanEquip_%d" % slot
	var overlay : Sprite2D = get_node_or_null(overlayName) as Sprite2D
	if cell == null:
		if overlay:
			overlay.queue_free()
		if slot == ActorCommons.Slot.WEAPON and animatedSprite:
			animatedSprite.modulate = Color.WHITE
		SetEquipmentMetadata(slot, null)
		return
	if overlay == null:
		overlay = Sprite2D.new()
		overlay.name = overlayName
		overlay.z_index = 6
		overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(overlay)
	var tex : Texture2D = null
	if cell.textures.size() > entity.stat.gender:
		tex = cell.textures[entity.stat.gender]
	if tex == null and cell.textures.size() > 0:
		tex = cell.textures[0]
	overlay.texture = tex
	overlay.scale = Vector2(0.45, 0.45)
	overlay.position = Vector2(14, -6) if slot == ActorCommons.Slot.WEAPON else Vector2(-12, -4)
	overlay.visible = tex != null
	if slot == ActorCommons.Slot.WEAPON and animatedSprite:
		# Soft jade/metal tint so equip is readable even when item has no gender texture
		animatedSprite.modulate = Color(1.08, 1.05, 0.92, 1.0)
	SetEquipmentMetadata(slot, cell)

func AddEquipmentEffect(slot : int, light : Node2D):
	if slot < 0 or slot >= equipmentEffects.size() or equipmentEffects[slot] != light:
		if is_instance_valid(light) and not light.is_queued_for_deletion():
			light.queue_free()
		return
	if is_instance_valid(light):
		add_child(light)

func SetEquipmentMetadata(slot : int, cell : ItemCell):
	if equipmentEffects[slot]:
		equipmentEffects[slot].queue_free()
		equipmentEffects[slot] = null
	if cell and cell.has_meta("light_radius"):
		var light : LightSource = LightSourceScene.instantiate()
		if light:
			light.radius = cell.get_meta("light_radius")
			if cell.has_meta("light_color"):
				light.color = cell.get_meta("light_color")
			equipmentEffects[slot] = light
			AddEquipmentEffect.call_deferred(slot, light)

func SetData(slot : int, data : EntityData):
	var slotName : String = ActorCommons.GetSlotName(slot)
	var sprite : Sprite2D = preset.get_node_or_null(slotName)
	if not sprite:
		return

	if data and slot == ActorCommons.Slot.BODY:
		if data._customTexture:
			sprite.set_texture(data._customTexture)
		if data._customMaterial:
			sprite.set_material(data._customMaterial)

	LoadSpriteSlot(slot, sprite)

func LoadAnimationPaths():
	if animation.has_animation("AttackDown"):
		var attackAnim : Animation = animation.get_animation("AttackDown")
		attackAnimLength = attackAnim.length if attackAnim else 1.0

	blendSpacePaths.resize(ActorCommons.State.COUNT)
	blendSpacePaths.fill("")
	walkTimeScalePath = ""
	attackTimeScalePath = ""

	for i in ActorCommons.State.COUNT:
		var stateName : String		= ActorCommons.GetStateName(i)
		var blendSpace : String		= "parameters/%s/BlendSpace2D/blend_position" % [stateName]

		if blendSpace in animationTree:
			blendSpacePaths[i] = blendSpace

		# Only set dynamic time scale for attack and walk as other can stay static
		if i == ActorCommons.State.WALK:
			var timeScale : String = "parameters/%s/TimeScale/scale" % [stateName]
			if timeScale in animationTree:
				walkTimeScalePath = timeScale
		elif i == ActorCommons.State.ATTACK:
			var timeScale : String = "parameters/%s/TimeScale/scale" % [stateName]
			if timeScale in animationTree:
				attackTimeScalePath = timeScale

func UpdateScale():
	if not animationTree:
		return

	if not walkTimeScalePath.is_empty():
		animationTree[walkTimeScalePath] = Formula.GetWalkRatio(entity.stat)
	if not attackTimeScalePath.is_empty() and entity.stat.current.castAttackDelay > 0:
		animationTree[attackTimeScalePath] = attackAnimLength / entity.stat.current.castAttackDelay

func OnAnimationStarted(animName : StringName):
	for stateIdx in ActorCommons.State.COUNT:
		if animName == ActorCommons.STATE_NAMES[stateIdx]:
			var stateId : ActorCommons.State = stateIdx as ActorCommons.State
			if stateId != previousAnimState:
				previousAnimState = stateId
				state_changed.emit(stateId)
			return

func ResetAnimationValue():
	if not animationTree:
		return

	LoadAnimationPaths()
	UpdateScale()
	RefreshTree()
	Refresh.call_deferred()

	if not animationTree.animation_started.is_connected(OnAnimationStarted):
		animationTree.animation_started.connect(OnAnimationStarted)

func GetPlayerOffset() -> int:
	var spriteOffset : int = ActorCommons.interactionDisplayOffset
	if animatedSprite:
		spriteOffset = int(SWORDSMAN_FOOT_OFFSETS.get(currentAction, Vector2(20, 38)).y)
	elif sprites[ActorCommons.Slot.BODY]:
		spriteOffset = -1 * int(sprites[ActorCommons.Slot.BODY].offset.y)
	return spriteOffset

#
func Init(data : EntityData):
	Callback.PlugCallback(entity.stat.entity_stats_updated, self.UpdateScale)
	LoadData(data)

func GetSwordsmanDirection(vec : Vector2) -> String:
	if vec.length_squared() < 0.001:
		return currentDirection
	var angle : float = vec.angle()
	var octant : int = int(round(angle / (PI / 4.0)))
	if octant < 0:
		octant += 8
	var idx : int = octant % 8
	return SWORDSMAN_DIRECTIONS[idx]

func GetSwordsmanAction(st : ActorCommons.State, isMoving : bool) -> String:
	if isDodging or (entity and (entity.has_meta("is_dodging") or entity.has_meta("dap_phong_bo_active"))):
		return "qinggong"
	if isMoving:
		return "walk"
	match st:
		ActorCommons.State.WALK:
			return "walk"
		ActorCommons.State.ATTACK:
			if isComboFinisher or (entity and entity.has_meta("combo_finisher_active")):
				return "combo"
			return "attack"
		ActorCommons.State.DEATH:
			return "death"
		_:
			return "idle"

func _process(delta : float):
	# 1. Subtle idle breathing secondary motion
	if currentAction == "idle":
		idleBreathTime += delta * 2.8
		var breathScale = 1.0 + sin(idleBreathTime) * 0.015
		var targetNode = animatedSprite if animatedSprite else (preset if preset is CanvasItem else null)
		if targetNode and is_instance_valid(targetNode):
			targetNode.scale = Vector2(1.0 / breathScale, breathScale)
	elif animatedSprite:
		animatedSprite.scale = Vector2.ONE

	# 2. Phantom afterimage trail during Qinggong / Dodge / Đạp Phong Bộ
	var hasQinggongMeta = entity and (entity.has_meta("is_dodging") or entity.has_meta("dap_phong_bo_active"))
	if (isDodging or hasQinggongMeta) and entity and entity.entityVelocity.length_squared() > 10.0:
		afterimageTimer += delta
		if afterimageTimer >= 0.08:
			afterimageTimer = 0.0
			var targetNode = animatedSprite if animatedSprite else preset
			if targetNode and is_instance_valid(targetNode):
				var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
				CombatVisualSystemClass.SpawnPhantomAfterimage(targetNode, Color(0.35, 0.85, 1.0, 0.6), 0.25)

func UpdateSwordsmanVisual(vel : Vector2, orientation : Vector2, st : ActorCommons.State, isMoving : bool):
	if not animatedSprite or not animatedSprite.sprite_frames:
		return

	var action : String = GetSwordsmanAction(st, isMoving)
	var dir : String = GetSwordsmanDirection(orientation)

	currentAction = action
	currentDirection = dir

	var animName : String = action + "_" + dir
	if animatedSprite.sprite_frames.has_animation(animName):
		if animatedSprite.animation != animName or not animatedSprite.is_playing():
			animatedSprite.play(animName)
		var foot : Vector2 = SWORDSMAN_FOOT_OFFSETS.get(action, Vector2(20, 38))
		animatedSprite.offset = -foot

		# Dynamic foot sync with movement speed
		if isMoving:
			var curSpeed = vel.length()
			if curSpeed > 10.0:
				animatedSprite.speed_scale = clampf(curSpeed / 120.0, 0.75, 1.8)
		else:
			animatedSprite.speed_scale = 1.0

func TriggerHurtFeedback():
	var flashNode : CanvasItem = animatedSprite if animatedSprite else (preset if preset is CanvasItem else null)
	if flashNode:
		var originalModulate = flashNode.modulate
		flashNode.modulate = Color(2.5, 0.4, 0.4, 1.0)
		var tween = flashNode.create_tween()
		if tween:
			tween.tween_property(flashNode, "modulate", originalModulate, 0.15)
	if animatedSprite and animatedSprite.sprite_frames:
		var hurtAnim = "hurt_" + currentDirection
		if animatedSprite.sprite_frames.has_animation(hurtAnim):
			animatedSprite.play(hurtAnim)
			
	# Micro Hitstop on impacted entity
	var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
	CombatVisualSystemClass.TriggerHitstopOnEntity(self, 0.04)

	# Camera shake on impact when player is involved
	var isLocalInvolved : bool = (entity == Launcher.Player) or (Entities.target == entity)
	if isLocalInvolved:
		CombatVisualSystemClass.TriggerCameraShake(CombatVisualSystemClass.ShakeLevel.MEDIUM)

func RefreshTree(resetOnTeleport : bool = true):
	if previousState > ActorCommons.State.UNKNOWN:
		var blendPath : String = blendSpacePaths[previousState]
		if not blendPath.is_empty():
			animationTree[blendPath] = previousOrientation

		if resetOnTeleport:
			animationTree[ActorCommons.playbackParameter].travel(ActorCommons.STATE_NAMES[previousState], true)

			# Random default offset for IDLE state of [0;1] second, need to call twice for the AnimationTree to properly apply it
			if previousState == ActorCommons.State.IDLE or previousState == ActorCommons.State.SIT:
				var randValue : float = randf()
				animationTree.advance(randValue)
				animationTree.advance(randValue)

func Refresh():
	var currentVelocity : Vector2 = entity.entityVelocity
	var isMoving : bool = currentVelocity.length_squared() > 1
	var newOrientation : Vector2 = currentVelocity.normalized() if isMoving else entity.entityOrientation
	var newState : ActorCommons.State = ActorCommons.State.WALK if isMoving else entity.state
	var differentState : bool = previousState != newState

	if animatedSprite:
		UpdateSwordsmanVisual(currentVelocity, newOrientation, newState, isMoving)
		if differentState or previousOrientation != newOrientation:
			previousState = newState
			previousOrientation = newOrientation
			if differentState:
				state_changed.emit(newState)
		return

	if not animationTree or not animationTree.is_inside_tree():
		return

	if previousOrientation != newOrientation or differentState:
		previousState = newState
		previousOrientation = newOrientation
		RefreshTree(differentState)

#
func CollectAnimationOverrides() -> Array[AnimationLibrary]:
	var allOverrides : Array[AnimationLibrary] = []

	for slot in range(ActorCommons.Slot.FIRST_EQUIPMENT, ActorCommons.Slot.LAST_EQUIPMENT):
		var cell : ItemCell = null
		if entity.inventory:
			cell = entity.inventory.GetEquipmentCell(slot)
		elif entity.data:
			cell = entity.data._equipment[slot]
		if cell and cell.animationOverrides:
			allOverrides.append(cell.animationOverrides)

	if entity.stat.hairstyle != DB.UnknownHash:
		var hairstyleData : HairstyleData = DB.GetHairstyle(entity.stat.hairstyle)
		if hairstyleData and hairstyleData.animationOverrides:
			allOverrides.append(hairstyleData.animationOverrides)

	return allOverrides

func ApplyAnimationOverrides():
	if not animation:
		return

	var allOverrides : Array[AnimationLibrary] = CollectAnimationOverrides()

	if allOverrides.is_empty():
		if originalAnimationLib:
			animation.remove_animation_library("")
			animation.add_animation_library("", originalAnimationLib)
			originalAnimationLib = null
	else:
		if not originalAnimationLib:
			originalAnimationLib = animation.get_animation_library("")

		var lib : AnimationLibrary = originalAnimationLib.duplicate(true)

		for overrideLib in allOverrides:
			for animName in overrideLib.get_animation_list():
				if not lib.has_animation(animName):
					continue

				var baseAnim : Animation = lib.get_animation(animName)
				var overrideAnim : Animation = overrideLib.get_animation(animName)
				for trackIdx in overrideAnim.get_track_count():
					var trackPath : NodePath = overrideAnim.track_get_path(trackIdx)
					var trackType : Animation.TrackType = overrideAnim.track_get_type(trackIdx)
					var baseTrackIdx : int = baseAnim.find_track(trackPath, trackType)
					if baseTrackIdx < 0:
						continue

					while baseAnim.track_get_key_count(baseTrackIdx) > 0:
						baseAnim.track_remove_key(baseTrackIdx, 0)
					for keyIdx in overrideAnim.track_get_key_count(trackIdx):
						baseAnim.track_insert_key(
							baseTrackIdx,
							overrideAnim.track_get_key_time(trackIdx, keyIdx),
							overrideAnim.track_get_key_value(trackIdx, keyIdx),
							overrideAnim.track_get_key_transition(trackIdx, keyIdx)
						)

		animation.remove_animation_library("")
		animation.add_animation_library("", lib)

#
func _notification(what : int):
	if what == NOTIFICATION_ENTER_TREE and (animationTree or animatedSprite):
		Refresh.call_deferred()

func _init():
	sprites.resize(ActorCommons.SlotEquipmentCount + ActorCommons.SlotModifierCount)
	equipmentEffects.resize(ActorCommons.State.COUNT)
