extends WindowPanel
class_name PreviewGalleryWindow

## In-game preview: PixelFX, skills cast FX, temporary character morph (2A).

const PixelFxLibraryClass = preload("res://sources/effects/PixelFxLibrary.gd")
const CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
const ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")

var tabs : TabContainer = null
var fxList : ItemList = null
var skillList : ItemList = null
var entityList : ItemList = null
var detailLabel : RichTextLabel = null
var statusLabel : Label = null

var _fxKeys : PackedStringArray = []
var _skills : Array = []
var _entities : Array = []
var _previewShapeBackup : int = DB.UnknownHash

func _init():
	name = "PreviewGalleryWindow"
	custom_minimum_size = Vector2(640, 520)
	size = Vector2(640, 520)
	floating = true
	draggable = true
	visible = false
	blockActions = false

func _ready():
	_BuildUI()
	ThemeClass.AttachJadeFrame(self)
	Refresh()

func _BuildUI():
	for c in get_children():
		c.queue_free()

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	var title := Label.new()
	title.text = "Xem Trước — Hiệu Ứng · Chiêu Thức · Nhân Vật"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	root.add_child(title)

	var hint := Label.new()
	hint.text = "Chọn mục rồi bấm Phát / Thử / Mượn hình. Morph chỉ xem tạm — bấm Trả hình để về dạng gốc."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.75, 0.78, 0.72))
	root.add_child(hint)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	root.add_child(body)

	tabs = TabContainer.new()
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.custom_minimum_size = Vector2(300, 320)
	body.add_child(tabs)

	fxList = _MakeList()
	fxList.item_selected.connect(_OnFxSelected)
	fxList.item_activated.connect(_OnFxActivated)
	tabs.add_child(fxList)
	tabs.set_tab_title(0, "Hiệu ứng")

	skillList = _MakeList()
	skillList.item_selected.connect(_OnSkillSelected)
	skillList.item_activated.connect(_OnSkillActivated)
	tabs.add_child(skillList)
	tabs.set_tab_title(1, "Chiêu thức")

	entityList = _MakeList()
	entityList.item_selected.connect(_OnEntitySelected)
	entityList.item_activated.connect(_OnEntityActivated)
	tabs.add_child(entityList)
	tabs.set_tab_title(2, "Nhân vật")

	var side := VBoxContainer.new()
	side.custom_minimum_size = Vector2(260, 0)
	side.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_theme_constant_override("separation", 8)
	body.add_child(side)

	detailLabel = RichTextLabel.new()
	detailLabel.bbcode_enabled = true
	detailLabel.fit_content = false
	detailLabel.scroll_active = true
	detailLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detailLabel.custom_minimum_size = Vector2(0, 220)
	detailLabel.add_theme_font_size_override("normal_font_size", 12)
	side.add_child(detailLabel)

	var btnPlay := Button.new()
	btnPlay.text = "Phát / Thử mục đang chọn"
	btnPlay.pressed.connect(_OnPlayPressed)
	ThemeClass.AccentButton(btnPlay)
	side.add_child(btnPlay)

	var btnRestore := Button.new()
	btnRestore.text = "Trả hình gốc"
	btnRestore.pressed.connect(RestoreOriginalShape)
	side.add_child(btnRestore)

	var btnClose := Button.new()
	btnClose.text = "Đóng"
	btnClose.pressed.connect(func(): set_visible(false))
	side.add_child(btnClose)

	statusLabel = Label.new()
	statusLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	statusLabel.add_theme_font_size_override("font_size", 11)
	statusLabel.add_theme_color_override("font_color", Color(0.55, 0.9, 0.65))
	root.add_child(statusLabel)

func _MakeList() -> ItemList:
	var list := ItemList.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.allow_reselect = true
	return list

func Refresh():
	_FillFx()
	_FillSkills()
	_FillEntities()
	detailLabel.text = "[color=#c8d0c0]Chọn một mục bên trái để xem chi tiết.[/color]"
	_SetStatus("Sẵn sàng. Phím: V · Tay cầm Xbox: Start (≡).")

func _FillFx():
	fxList.clear()
	_fxKeys.clear()
	var keys : Array = PixelFxLibraryClass.CATALOG.keys()
	keys.sort()
	for key in keys:
		_fxKeys.append(key)
		fxList.add_item(str(key))

func _FillSkills():
	skillList.clear()
	_skills.clear()
	var entries : Array = []
	for skillID in DB.SkillsDB:
		var cell : SkillCell = DB.SkillsDB[skillID]
		if cell:
			entries.append(cell)
	entries.sort_custom(func(a, b): return String(a.name) < String(b.name))
	for cell in entries:
		_skills.append(cell)
		var cat := _SkillCategoryName(cell.category)
		skillList.add_item("%s  [%s]" % [cell.name, cat])

func _FillEntities():
	entityList.clear()
	_entities.clear()
	var entries : Array = []
	for eid in DB.EntitiesDB:
		var data : EntityData = DB.EntitiesDB[eid]
		if data and data._spritePreset:
			entries.append(data)
	entries.sort_custom(func(a, b): return String(a._name) < String(b._name))
	for data in entries:
		_entities.append(data)
		entityList.add_item(data._name if not data._name.is_empty() else ("#%d" % data._id))

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
	detailLabel.text = "[b]%s[/b]\n[color=#9ab]/nĐường:[/color] %s\n[color=#9ab]\nScale mặc định:[/color] %.2f\n\nNhấn đúp hoặc [b]Phát[/b] để xem trên nhân vật." % [
		key, path, PixelFxLibraryClass.GetScale(key)
	]

func _OnFxActivated(index : int):
	_OnFxSelected(index)
	_PlayFx(index)

func _OnSkillSelected(index : int):
	if index < 0 or index >= _skills.size():
		return
	var cell : SkillCell = _skills[index]
	detailLabel.text = "[b]%s[/b]\n[color=#9ab]\nLoại:[/color] %s\n[color=#9ab]Tầm:[/color] %d\n[color=#9ab]Niệm chú:[/color] %.2fs\n[color=#9ab]Hồi chiêu:[/color] %.2fs\n\nThử sẽ phát hiệu ứng gắn với chiêu (không tốn tài nguyên)." % [
		cell.name, _SkillCategoryName(cell.category), cell.skillRange, cell.castTime, cell.cooldownTime
	]

func _OnSkillActivated(index : int):
	_OnSkillSelected(index)
	_PlaySkill(index)

func _OnEntitySelected(index : int):
	if index < 0 or index >= _entities.size():
		return
	var data : EntityData = _entities[index]
	detailLabel.text = "[b]%s[/b]\n[color=#9ab]\nID:[/color] %d\n[color=#9ab]Bán kính:[/color] %d\n\n[b]Mượn hình[/b] sẽ morph tạm lên thân bạn. Bấm [b]Trả hình gốc[/b] khi xem xong." % [
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

	var key := _GuessFxForSkill(cell)
	CombatVisualSystemClass.SpawnPixelFx(parent, key, pos, -1.0, false, true)
	if key != "mana_burst":
		CombatVisualSystemClass.SpawnPixelFx(parent, "mana_burst", pos + Vector2(0, -12), 0.35, false, true)

	var player = _ActiveEntity()
	if player and player.interactive:
		player.interactive.DisplayCast(cell.id)
		player.interactive.DisplaySkill(player, cell.id, 0.0)

	_SetStatus("Thử chiêu: %s → FX [%s]" % [cell.name, key])

func _GuessFxForSkill(cell : SkillCell) -> String:
	var n : String = String(cell.name).to_lower()
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

	# Prefer server agent morph so peers see it; fallback to local visual.
	var agent = _ActiveAgent()
	if agent and agent.has_method("Morph"):
		agent.Morph(true, data._id)
	else:
		player.stat.Morph(data)
		player.SetVisual(data, true)

	_SetStatus("Đang mượn hình: %s — nhớ Trả hình gốc khi xong." % data._name, true)

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
	# Character setup screen: preview on the selected / creating sprite.
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
