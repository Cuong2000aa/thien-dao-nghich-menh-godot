extends WindowPanel
class_name PreviewGalleryWindow

## In-game preview: PixelFX, skills cast FX, temporary character morph (2A).
## Compact panel — lists scroll inside a viewport-clamped window so items stay clickable.

const PixelFxLibraryClass = preload("res://sources/effects/PixelFxLibrary.gd")
const CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
const ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")

var tabs : TabContainer = null
var fxList : ItemList = null
var skillList : ItemList = null
var entityList : ItemList = null
var filterEdit : LineEdit = null
var detailLabel : RichTextLabel = null
var statusLabel : Label = null

var _fxKeysAll : PackedStringArray = []
var _skillsAll : Array = []
var _entitiesAll : Array = []
var _fxKeys : PackedStringArray = []
var _skills : Array = []
var _entities : Array = []
var _previewShapeBackup : int = DB.UnknownHash
var btnAim : Button = null
## Client-only dummy NPC/monster for aim review (not from server)
const PREVIEW_DUMMY_RID : int = -910001
const DUMMY_PATROL_HALF : float = 70.0
const DUMMY_PATROL_SPEED : float = 44.0
var _previewDummy : Entity = null
var _dummyPatrolOrigin : Vector2 = Vector2.ZERO
var _dummyPatrolDir : float = 1.0

func _init():
	name = "PreviewGalleryWindow"
	# Compact corner panel; FitToViewport docks top-right on open
	custom_minimum_size = Vector2(300, 260)
	size = Vector2(340, 320)
	maxSize = Vector2(380, 380)
	floating = true
	draggable = true
	visible = false
	blockActions = false
	clip_contents = true
	allowAutomaticResize = false

func _ready():
	_BuildUI()
	ThemeClass.AttachJadeFrame(self)
	visibility_changed.connect(_OnVisibilityChanged)
	set_process(true)
	Refresh()

func _process(delta : float) -> void:
	_TickDummyPatrol(delta)

func EnableControl(state : bool):
	super.EnableControl(state)
	if state:
		FitToViewport()
		Refresh()
		if filterEdit:
			filterEdit.grab_focus()

func _OnVisibilityChanged():
	if visible:
		FitToViewport()
	else:
		_ClearPreviewDummy()

func FitToViewport():
	var avail := Vector2(960, 540)
	if Launcher.GUI and Launcher.GUI.windows:
		avail = Launcher.GUI.windows.size
	elif get_viewport():
		avail = get_viewport().get_visible_rect().size
	# Compact panel — keep character (center) clear
	var target := Vector2(
		clampf(avail.x * 0.38, 300.0, 360.0),
		clampf(avail.y * 0.55, 260.0, 360.0)
	)
	if maxSize.x > 0:
		target.x = minf(target.x, maxSize.x)
	if maxSize.y > 0:
		target.y = minf(target.y, maxSize.y)
	custom_minimum_size = Vector2(minf(300.0, target.x), minf(240.0, target.y))
	size = target
	# Top-right corner with margin (was centered and covered the player)
	var margin := 8.0
	position = Vector2(
		clampf(avail.x - size.x - margin, margin, maxf(margin, avail.x - size.x - margin)),
		margin
	)

func _BuildUI():
	for c in get_children():
		c.queue_free()

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 6)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(root)

	var title := Label.new()
	title.text = "Xem Trước"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	root.add_child(title)

	filterEdit = LineEdit.new()
	filterEdit.placeholder_text = "Lọc tên…"
	filterEdit.clear_button_enabled = true
	filterEdit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filterEdit.custom_minimum_size = Vector2(0, 28)
	filterEdit.text_changed.connect(_OnFilterChanged)
	root.add_child(filterEdit)

	tabs = TabContainer.new()
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.clip_contents = true
	# Do NOT set a large custom_minimum_size — that was blowing the window past the viewport
	root.add_child(tabs)

	fxList = _MakeList()
	fxList.item_selected.connect(_OnFxSelected)
	fxList.item_activated.connect(_OnFxActivated)
	tabs.add_child(fxList)
	tabs.set_tab_title(0, "FX")

	skillList = _MakeList()
	skillList.item_selected.connect(_OnSkillSelected)
	skillList.item_activated.connect(_OnSkillActivated)
	tabs.add_child(skillList)
	tabs.set_tab_title(1, "Chiêu")

	entityList = _MakeList()
	entityList.item_selected.connect(_OnEntitySelected)
	entityList.item_activated.connect(_OnEntityActivated)
	tabs.add_child(entityList)
	tabs.set_tab_title(2, "NV")

	detailLabel = RichTextLabel.new()
	detailLabel.bbcode_enabled = true
	detailLabel.fit_content = false
	detailLabel.scroll_active = true
	detailLabel.clip_contents = true
	detailLabel.custom_minimum_size = Vector2(0, 56)
	detailLabel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	detailLabel.add_theme_font_size_override("normal_font_size", 11)
	root.add_child(detailLabel)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(actions)

	var btnPlay := Button.new()
	btnPlay.text = "Phát"
	btnPlay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btnPlay.custom_minimum_size = Vector2(0, 32)
	btnPlay.pressed.connect(_OnPlayPressed)
	ThemeClass.AccentButton(btnPlay)
	actions.add_child(btnPlay)

	btnAim = Button.new()
	btnAim.text = "Nhắm NPC"
	btnAim.tooltip_text = "Spawn NPC giả cạnh phải (đi qua lại) và nhắm vào chúng"
	btnAim.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btnAim.custom_minimum_size = Vector2(0, 32)
	btnAim.pressed.connect(_OnAimNearestPressed)
	actions.add_child(btnAim)

	var btnRestore := Button.new()
	btnRestore.text = "Trả hình"
	btnRestore.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btnRestore.custom_minimum_size = Vector2(0, 32)
	btnRestore.pressed.connect(RestoreOriginalShape)
	actions.add_child(btnRestore)

	var btnClose := Button.new()
	btnClose.text = "Đóng"
	btnClose.custom_minimum_size = Vector2(72, 32)
	btnClose.pressed.connect(func(): set_visible(false))
	actions.add_child(btnClose)

	statusLabel = Label.new()
	statusLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	statusLabel.add_theme_font_size_override("font_size", 10)
	statusLabel.add_theme_color_override("font_color", Color(0.55, 0.9, 0.65))
	statusLabel.custom_minimum_size = Vector2(0, 18)
	root.add_child(statusLabel)

func _MakeList() -> ItemList:
	var list := ItemList.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.allow_reselect = true
	list.same_column_width = true
	list.clip_contents = true
	list.focus_mode = Control.FOCUS_ALL
	list.mouse_filter = Control.MOUSE_FILTER_STOP
	# Keep intrinsic min tiny so hundreds of entities don't inflate the WindowPanel
	list.custom_minimum_size = Vector2(120, 80)
	return list

func Refresh():
	if not DB.isInitialized:
		return
	_LoadCatalogs()
	_ApplyFilter(filterEdit.text if filterEdit else "")
	if detailLabel:
		detailLabel.text = "[color=#c8d0c0]Chọn mục trong danh sách (cuộn được). Lọc bằng ô phía trên.[/color]"
	_SetStatus("V · Start (≡) · cửa sổ giữ trong màn hình.")

func _LoadCatalogs():
	_fxKeysAll.clear()
	var keys : Array = PixelFxLibraryClass.CATALOG.keys()
	keys.sort()
	for key in keys:
		_fxKeysAll.append(String(key))

	_skillsAll.clear()
	var skillEntries : Array = []
	if DB.SkillsDB:
		for skillID in DB.SkillsDB:
			var cell : SkillCell = DB.SkillsDB[skillID]
			if cell:
				skillEntries.append(cell)
		skillEntries.sort_custom(func(a, b): return String(a.name) < String(b.name))
	_skillsAll = skillEntries

	_entitiesAll.clear()
	var entityEntries : Array = []
	if DB.EntitiesDB:
		for eid in DB.EntitiesDB:
			var data : EntityData = DB.EntitiesDB[eid]
			if data and data._spritePreset:
				entityEntries.append(data)
		entityEntries.sort_custom(func(a, b): return String(a._name) < String(b._name))
	_entitiesAll = entityEntries

func _OnFilterChanged(text : String):
	_ApplyFilter(text)

func _ApplyFilter(text : String):
	var q := text.strip_edges().to_lower()

	_fxKeys.clear()
	if fxList:
		fxList.clear()
		for key in _fxKeysAll:
			if q.is_empty() or q in key.to_lower():
				_fxKeys.append(key)
				fxList.add_item(key)

	_skills.clear()
	if skillList:
		skillList.clear()
		for cell in _skillsAll:
			var label := "%s  [%s]" % [cell.name, _SkillCategoryName(cell.category)]
			if q.is_empty() or q in String(cell.name).to_lower() or q in label.to_lower():
				_skills.append(cell)
				skillList.add_item(label)

	_entities.clear()
	if entityList:
		entityList.clear()
		for data in _entitiesAll:
			var displayName : String = String(data._name)
			if displayName.is_empty():
				displayName = "#%d" % data._id
			if q.is_empty() or q in displayName.to_lower():
				_entities.append(data)
				entityList.add_item(displayName)

func _SkillCategoryName(cat : int) -> String:
	match cat:
		SkillCell.Category.SPELL: return "Pháp"
		SkillCell.Category.PHYSICAL: return "Thể"
		SkillCell.Category.ABILITY: return "Tâm"
		_: return "?"

func _OnFxSelected(index : int):
	if index < 0 or index >= _fxKeys.size():
		return
	var key : String = _fxKeys[index]
	var path : String = PixelFxLibraryClass.ResolvePath(key)
	detailLabel.text = "[b]%s[/b]  ·  scale %.2f\n[color=#9ab]%s[/color]" % [
		key, PixelFxLibraryClass.GetScale(key), path
	]

func _OnFxActivated(index : int):
	_OnFxSelected(index)
	_PlayFx(index)

func _OnSkillSelected(index : int):
	if index < 0 or index >= _skills.size():
		return
	var cell : SkillCell = _skills[index]
	detailLabel.text = "[b]%s[/b]  ·  %s  ·  tầm %d\nHồi %.1fs · niệm %.1fs" % [
		cell.name, _SkillCategoryName(cell.category), cell.skillRange, cell.cooldownTime, cell.castTime
	]

func _OnSkillActivated(index : int):
	_OnSkillSelected(index)
	_PlaySkill(index)

func _OnEntitySelected(index : int):
	if index < 0 or index >= _entities.size():
		return
	var data : EntityData = _entities[index]
	detailLabel.text = "[b]%s[/b]  ·  id %d  ·  r=%d\nDouble-click / Phát = spawn NPC giả cạnh bạn để nhắm chiêu.\n(Giữ Shift+Phát = chỉ mượn hình.)" % [
		data._name, data._id, data._radius
	]

func _OnEntityActivated(index : int):
	_OnEntitySelected(index)
	# Spawn dummy to aim at (main review path) — not morph
	_SpawnPreviewDummy(index)

func _OnPlayPressed():
	match tabs.current_tab:
		0:
			var i := fxList.get_selected_items()
			if i.size() > 0:
				_PlayFx(i[0])
		1:
			var i2 := skillList.get_selected_items()
			if i2.size() > 0:
				_PlaySkill(i2[0])
		2:
			var i3 := entityList.get_selected_items()
			if i3.size() > 0:
				# Shift = morph only; default = spawn NPC giả để nhắm
				if Input.is_key_pressed(KEY_SHIFT):
					_PreviewEntity(i3[0])
				else:
					_SpawnPreviewDummy(i3[0])

func _OnAimNearestPressed():
	# Spawn MONSTER dummy + Entities.SetTarget — same target type Entity.Cast accepts
	var aim := _EnsureReviewDummy()
	if aim == null:
		_SetStatus("Không spawn được NPC review — kiểm tra đã vào map.")
		return
	Entities.SetTarget(aim, false)
	var caster = _ActiveEntity()
	if caster is Entity:
		CombatVisualSystemClass.LookAtEntity(caster, aim)
	_SetStatus("Target combat: %s (MONSTER) — chiêu SINGLE sẽ LookAt như Skill.Cast." % _EntityDisplayName(aim), true)

func _EntityDisplayName(ent : Entity) -> String:
	if ent == null:
		return "không"
	if ent.data and not String(ent.data._name).is_empty():
		return String(ent.data._name)
	return ent.nick if not ent.nick.is_empty() else ent.name

func _AimNearestNpc() -> Entity:
	var player = _ActiveEntity()
	if player == null:
		return null
	if _previewDummy and is_instance_valid(_previewDummy) and ActorCommons.IsAlive(_previewDummy):
		return _previewDummy
	if Entities.target and is_instance_valid(Entities.target) and Entities.target != player:
		if Entities.target.type == ActorCommons.Type.NPC or Entities.target.type == ActorCommons.Type.MONSTER:
			return Entities.target
	var best : Entity = null
	var bestD : float = 999999.0
	for ent in Entities.entities.values():
		if ent == null or not is_instance_valid(ent) or ent == player:
			continue
		if ent.type != ActorCommons.Type.NPC and ent.type != ActorCommons.Type.MONSTER:
			continue
		if not ActorCommons.IsAlive(ent):
			continue
		# Skip other preview leftovers
		if ent.agentRID == PREVIEW_DUMMY_RID:
			continue
		var d : float = player.global_position.distance_squared_to(ent.global_position)
		if d < bestD:
			bestD = d
			best = ent
	return best

## Spawn default review dummy if missing (Nhắm / Phát chiêu).
func _EnsureReviewDummy() -> Entity:
	if _previewDummy and is_instance_valid(_previewDummy) and _previewDummy.is_inside_tree():
		return _previewDummy
	if _entities.is_empty():
		_LoadCatalogs()
		_ApplyFilter(filterEdit.text if filterEdit else "")
	if _entities.is_empty():
		return null
	var idx := _PickDefaultDummyIndex()
	_SpawnPreviewDummy(idx)
	return _previewDummy if is_instance_valid(_previewDummy) else null

func _PickDefaultDummyIndex() -> int:
	for i in _entities.size():
		var n : String = String(_entities[i]._name).to_lower()
		# Prefer small visible critters / common mobs
		if "slime" in n or "nhầy" in n or "wolf" in n or "sói" in n \
				or "goblin" in n or "skeleton" in n or "xác" in n or "bat" in n:
			return i
	return 0

func _ClearPreviewDummy() -> void:
	if _previewDummy == null:
		return
	if Entities.target == _previewDummy:
		Entities.ClearTarget()
	Entities.Erase(PREVIEW_DUMMY_RID)
	if is_instance_valid(_previewDummy):
		_previewDummy.queue_free()
	_previewDummy = null
	_dummyPatrolDir = 1.0

func _TickDummyPatrol(delta : float) -> void:
	if _previewDummy == null or not is_instance_valid(_previewDummy):
		return
	if not _previewDummy.is_inside_tree():
		return
	var x : float = _previewDummy.position.x
	if x >= _dummyPatrolOrigin.x + DUMMY_PATROL_HALF:
		_dummyPatrolDir = -1.0
	elif x <= _dummyPatrolOrigin.x - DUMMY_PATROL_HALF:
		_dummyPatrolDir = 1.0
	var vel := Vector2(_dummyPatrolDir * DUMMY_PATROL_SPEED, 0.0)
	var nextPos := Vector2(_previewDummy.position.x + vel.x * delta, _dummyPatrolOrigin.y)
	var castId : int = 0
	if _previewDummy.visual:
		castId = _previewDummy.visual.skillCastID
	_previewDummy.Update(vel, nextPos, vel.normalized(), ActorCommons.State.WALK, castId, true, false)

func _SpawnPreviewDummy(index : int) -> void:
	if index < 0 or index >= _entities.size():
		return
	var data : EntityData = _entities[index]
	var player = _ActiveEntity()
	if player == null:
		_SetStatus("Chưa có nhân vật — vào map trước.")
		return
	if not Launcher.Map or not Launcher.Map.currentFringe:
		_SetStatus("Chưa vào map — không spawn được NPC review.")
		return
	_ClearPreviewDummy()
	var nick : String = "%s (xem)" % data._name
	var dummy : Entity = Instantiate.CreateEntity(ActorCommons.Type.MONSTER, data, nick, false)
	if dummy == null:
		_SetStatus("Spawn NPC review thất bại: %s" % data._name)
		return
	dummy.agentRID = PREVIEW_DUMMY_RID
	_dummyPatrolDir = 1.0
	if dummy.stat:
		dummy.stat.health = maxi(int(dummy.stat.health), 200)
		dummy.stat.shape = data._id
		dummy.stat.currentShape = data._id
	dummy.state = ActorCommons.State.WALK
	# Sync add — Map.AddChild deferred làm dummy không kịp hiện / nhắm
	Launcher.Map.currentFringe.add_child(dummy)
	# Bên phải player (cùng không gian position với fringe)
	dummy.global_position = player.global_position + Vector2(96, 0)
	_dummyPatrolOrigin = dummy.position
	dummy.SetData()
	if dummy.visual:
		dummy.visual.Refresh()
	Entities.Add(dummy, PREVIEW_DUMMY_RID)
	_previewDummy = dummy
	Entities.SetTarget(dummy, false)
	if player is Entity:
		CombatVisualSystemClass.LookAtEntity(player, dummy)
	_SetStatus("NPC review: %s — đi qua lại; SetTarget MONSTER (như combat)." % data._name, true)

func _AimLabel() -> String:
	var t = Entities.target
	if t and is_instance_valid(t) and t is Entity and t.data:
		return String(t.data._name)
	return "không"

func _PlayFx(index : int):
	if index < 0 or index >= _fxKeys.size():
		return
	var key : String = _fxKeys[index]
	var parent := _FxParent()
	if parent == null:
		_SetStatus("Chưa vào map — không phát được hiệu ứng.")
		return
	var Lib = preload("res://sources/effects/PixelFxLibrary.gd")
	var place : String = Lib.GetPlacement(key)
	var caster = _ActiveEntity()
	# FX tab: treat as directed cast if a combat target exists
	var aimFx = _EnsureReviewDummy()
	if aimFx:
		Entities.SetTarget(aimFx, false)
	if caster:
		CombatVisualSystemClass.PlaySkillFx(parent, caster, key, "", -1.0, null, aimFx)
	else:
		CombatVisualSystemClass.SpawnPixelFx(parent, key, _PlayerPos(), -1.0, false, true)
	_SetStatus("Đã phát: %s [%s] → nhắm %s" % [key, place, _AimLabel()])

func _PlaySkill(index : int):
	if index < 0 or index >= _skills.size():
		return
	var cell : SkillCell = _skills[index]
	var parent := _FxParent()
	if parent == null:
		_SetStatus("Chưa vào map — không thử được chiêu.")
		return

	var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
	var martial : Dictionary = CombatSystemClass.GetMartialForSkill(cell.id, cell.name)
	var hasMartialFx : bool = not martial.is_empty() and int(martial.get("id", 0)) >= 1002

	# Mirror Entity.Cast: only SINGLE skills lock onto a MONSTER target
	if cell.mode == Skill.TargetMode.SINGLE:
		var aim = _EnsureReviewDummy()
		if aim:
			Entities.SetTarget(aim, false)
	elif Entities.target and Entities.target.agentRID < 0:
		# Clear preview dummy lock so ZONE/SELF don't inherit fake enemy aim
		pass

	var player = _ActiveEntity()
	if player and player.interactive:
		# DisplaySkill → PlaySkillFx(skill) uses ResolveCombatTarget + LookAt like Skill.Cast
		player.interactive.DisplayCast(cell.id)
		player.interactive.DisplaySkill(player, cell.id, 0.0)
		var aimNow = CombatVisualSystemClass.ResolveCombatTarget(player, cell)
		_SetStatus("Thử chiêu: %s [%s] → nhắm %s" % [
			cell.name,
			_SkillModeName(cell.mode),
			_EntityDisplayName(aimNow) if aimNow else "—"
		])
		return

	var key := _GuessFxForSkill(cell)
	if hasMartialFx and martial.has("fxKey"):
		key = String(martial.get("fxKey"))
	var placeOv : String = String(martial.get("fxPlace", ""))
	CombatVisualSystemClass.PlaySkillFx(parent, null, key, placeOv, -1.0, cell)
	if hasMartialFx and bool(martial.get("swordArrayVfx", false)):
		var arrR : float = float(martial.get("radius", 110.0)) * 0.85
		CombatVisualSystemClass.SpawnSwordArrayVfx(parent, _PlayerPos(), arrR, 2.2)
	_SetStatus("Thử chiêu: %s → FX [%s]" % [cell.name, key])

func _SkillModeName(mode : int) -> String:
	match mode:
		Skill.TargetMode.SINGLE: return "SINGLE"
		Skill.TargetMode.ZONE: return "ZONE"
		Skill.TargetMode.SELF: return "SELF"
		_: return "?"

func _GuessFxForSkill(cell : SkillCell) -> String:
	var n : String = String(cell.name).to_lower()
	if "vạn kiếm" in n or "quy tông" in n:
		return "van_kiem_quy_tong"
	if "nhất kiếm" in n or "thiên môn" in n or "trảm thiên" in n:
		return "nhat_kiem_tram_thien_mon"
	if "hỏa long" in n or "phun tức" in n:
		return "flamethrower"
	if "hàn băng" in n or "thiên kiếm" in n:
		return "ice_lance"
	if "lôi phạt" in n or "cửu thiên" in n:
		return "lightning_strike"
	if "huyền âm" in n or "thôn hồn" in n:
		return "soul_drain"
	if "thánh quang" in n or "hộ đạo" in n:
		return "holy_pillar"
	if "địa long" in n or "phá sơn" in n:
		return "earth_stomp"
	if "tử lôi" in n or "liên hoàn" in n:
		return "chain_lightning"
	if "hư không" in n or "hấp tinh" in n:
		return "black_hole"
	if "kiếm" in n or "slash" in n or "cleave" in n:
		return "slash"
	if "phong" in n or "leaf" in n or "mộc" in n:
		return "leaf_storm"
	if "hỏa" in n or "viêm" in n or "fire" in n or "flar" in n:
		return "fire_spirit"
	if "băng" in n or "hàn" in n or "ice" in n or "frost" in n:
		return "frost_nova"
	if "lôi" in n or "điện" in n or "sét" in n or "lightning" in n:
		return "lightning_strike"
	if "độc" in n or "poison" in n:
		return "poison_cloud"
	if "hộ" in n or "thuẫn" in n or "shield" in n:
		return "divine_shield"
	if "hồi" in n or "trị" in n or "heal" in n:
		return "heal"
	if "địa" in n or "thổ" in n or "earth" in n:
		return "earth_spike"
	match cell.category:
		SkillCell.Category.PHYSICAL:
			return "heavy_cleave"
		SkillCell.Category.ABILITY:
			return "magic_circle"
		_:
			return "arcane_orb"

func _PreviewEntity(index : int):
	if index < 0 or index >= _entities.size():
		return
	var data : EntityData = _entities[index]
	var player = _ActiveEntity()
	if player == null or player.stat == null:
		_SetStatus("Chưa có nhân vật để mượn hình.")
		return

	if _previewShapeBackup == DB.UnknownHash:
		_previewShapeBackup = player.stat.shape if player.stat.shape != DB.UnknownHash else player.stat.currentShape

	var agent = _ActiveAgent()
	if agent and agent.has_method("Morph"):
		agent.Morph(true, data._id)
	else:
		player.stat.Morph(data)
		player.SetVisual(data, true)

	_SetStatus("Đang mượn hình: %s — nhớ Trả hình." % data._name, true)

func RestoreOriginalShape():
	var player = _ActiveEntity()
	if player == null or player.stat == null:
		_SetStatus("Không có nhân vật để trả hình.")
		return

	var restoreID : int = _previewShapeBackup if _previewShapeBackup != DB.UnknownHash else player.stat.shape
	if restoreID == DB.UnknownHash:
		restoreID = player.stat.shape
	var data : EntityData = DB.EntitiesDB.get(restoreID, player.data)
	if data == null:
		_SetStatus("Không tìm thấy hình gốc.")
		return

	var baseData : EntityData = DB.EntitiesDB.get(player.stat.shape, data)
	var agent = _ActiveAgent()
	if agent and agent.has_method("Morph"):
		agent.Morph(true, agent.stat.shape)
		agent.stat.currentShape = agent.stat.shape
		if baseData:
			agent.stat.SetMorphStats(baseData._stats)
		var inst = WorldAgent.GetInstanceFromAgent(agent)
		if inst:
			Network.NotifyInstance(inst, "Morphed", [agent.get_rid().get_id(), agent.stat.shape, true])
	else:
		player.stat.currentShape = player.stat.shape
		if baseData:
			player.stat.SetMorphStats(baseData._stats)
			player.SetVisual(baseData, true)

	_previewShapeBackup = DB.UnknownHash
	_SetStatus("Đã trả về hình gốc.", true)

func _ActiveEntity() -> Entity:
	if Launcher.Player and Launcher.Player is Entity:
		return Launcher.Player
	if Launcher.GUI and Launcher.GUI.characterPanel and Launcher.GUI.characterPanel.has_method("GetSelectedEntity"):
		var selected = Launcher.GUI.characterPanel.GetSelectedEntity()
		if selected is Entity:
			return selected
	return null

func _ActiveAgent() -> PlayerAgent:
	if Launcher.Player and Launcher.Player is Entity and Launcher.Player.agentRID != DB.UnknownHash:
		var agent = WorldAgent.GetAgent(Launcher.Player.agentRID)
		if agent is PlayerAgent:
			return agent
	return null

func _FxParent() -> Node2D:
	if Launcher.Map and Launcher.Map.currentFringe:
		return Launcher.Map.currentFringe
	if Launcher.Map and Launcher.Map.currentMapNode:
		return Launcher.Map.currentMapNode
	return null

func _PlayerPos() -> Vector2:
	var p = _ActiveEntity()
	return p.global_position if p else Vector2.ZERO

func _SetStatus(msg : String, notify : bool = false):
	if statusLabel:
		statusLabel.text = msg
	if notify and Launcher.GUI and Launcher.GUI.notificationLabel:
		Launcher.GUI.notificationLabel.AddNotification(msg)
