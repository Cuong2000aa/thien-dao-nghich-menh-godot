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

func _init():
	name = "PreviewGalleryWindow"
	# Compact default; FitToViewport tightens further on open
	custom_minimum_size = Vector2(380, 300)
	size = Vector2(420, 340)
	maxSize = Vector2(520, 420)
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
	Refresh()

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

func FitToViewport():
	var avail := Vector2(960, 540)
	if Launcher.GUI and Launcher.GUI.windows:
		avail = Launcher.GUI.windows.size
	elif get_viewport():
		avail = get_viewport().get_visible_rect().size
	# Leave margin so the panel never eats the whole screen / goes off-edge
	var target := Vector2(
		clampf(avail.x * 0.55, 340.0, 480.0),
		clampf(avail.y * 0.62, 280.0, 400.0)
	)
	if maxSize.x > 0:
		target.x = minf(target.x, maxSize.x)
	if maxSize.y > 0:
		target.y = minf(target.y, maxSize.y)
	custom_minimum_size = Vector2(minf(340.0, target.x), minf(260.0, target.y))
	size = target
	position = Vector2(
		clampf((avail.x - size.x) * 0.5, 4.0, maxf(4.0, avail.x - size.x - 4.0)),
		clampf((avail.y - size.y) * 0.35, 4.0, maxf(4.0, avail.y - size.y - 4.0))
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
	for skillID in DB.SkillsDB:
		var cell : SkillCell = DB.SkillsDB[skillID]
		if cell:
			skillEntries.append(cell)
	skillEntries.sort_custom(func(a, b): return String(a.name) < String(b.name))
	_skillsAll = skillEntries

	_entitiesAll.clear()
	var entityEntries : Array = []
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
	detailLabel.text = "[b]%s[/b]  ·  id %d  ·  r=%d\nMượn hình tạm — nhớ Trả hình." % [
		data._name, data._id, data._radius
	]

func _OnEntityActivated(index : int):
	_OnEntitySelected(index)
	_PreviewEntity(index)

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
				_PreviewEntity(i3[0])

func _PlayFx(index : int):
	if index < 0 or index >= _fxKeys.size():
		return
	var key : String = _fxKeys[index]
	var parent := _FxParent()
	var pos := _PlayerPos()
	if parent == null:
		_SetStatus("Chưa vào map — không phát được hiệu ứng.")
		return
	CombatVisualSystemClass.SpawnPixelFx(parent, key, pos, -1.0, false, true)
	_SetStatus("Đã phát: %s" % key)

func _PlaySkill(index : int):
	if index < 0 or index >= _skills.size():
		return
	var cell : SkillCell = _skills[index]
	var parent := _FxParent()
	var pos := _PlayerPos()
	if parent == null:
		_SetStatus("Chưa vào map — không thử được chiêu.")
		return

	# Prefer real cast path (Interactive.DisplaySkill) — already wires martial FX.
	# Extra guessed PixelFX + mana_burst used to stack 2–3 layers (looked like spam/jumble).
	var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
	var martial : Dictionary = CombatSystemClass.GetMartialForSkill(cell.id, cell.name)
	var hasMartialFx : bool = not martial.is_empty() and int(martial.get("id", 0)) >= 1002

	var player = _ActiveEntity()
	if player and player.interactive:
		player.interactive.DisplayCast(cell.id)
		player.interactive.DisplaySkill(player, cell.id, 0.0)
		_SetStatus("Thử chiêu: %s (cast path)" % cell.name)
		return

	# Fallback when no player entity: single PixelFX only
	var key := _GuessFxForSkill(cell)
	if hasMartialFx and martial.has("fxKey"):
		key = String(martial.get("fxKey"))
	CombatVisualSystemClass.SpawnPixelFx(parent, key, pos, -1.0, false, true)
	_SetStatus("Thử chiêu: %s → FX [%s]" % [cell.name, key])

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
