extends WindowPanel
class_name SkillTreeWindow

## Xem cây kỹ năng theo Hình Thể / cảnh giới tu luyện.

const HeroLib = preload("res://sources/actor/HeroLibrary.gd")
const SkillTree = preload("res://sources/actor/HeroSkillTree.gd")
const Cultivation = preload("res://sources/actor/Cultivation.gd")

var heroIndex : int = 0
var previewOnly : bool = false

var titleLabel : Label = null
var summaryLabel : Label = null
var heroNavLabel : Label = null
var scroll : ScrollContainer = null
var listBox : VBoxContainer = null
var btnPrev : Button = null
var btnNext : Button = null
var btnClose : Button = null

func _init():
	name = "SkillTreeWindow"
	custom_minimum_size = Vector2(560, 560)
	size = Vector2(560, 560)
	floating = true
	draggable = true
	visible = false

func _ready():
	_BuildUI()
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.AttachJadeFrame(self)
	if btnPrev:
		ThemeClass.AccentButton(btnPrev)
	if btnNext:
		ThemeClass.AccentButton(btnNext)
	Refresh()

func OpenForHero(index : int, asPreview : bool = false) -> void:
	heroIndex = clampi(index, 0, HeroLib.Count() - 1)
	previewOnly = asPreview
	Refresh()
	EnableControl(true)

func OpenForPlayer() -> void:
	previewOnly = false
	if Launcher.Player and Launcher.Player.stat:
		var shape : int = Launcher.Player.stat.shape
		if shape == DB.UnknownHash:
			shape = Launcher.Player.stat.currentShape
		var idx : int = HeroLib.FindIndexByShape(shape)
		heroIndex = idx if idx >= 0 else 0
	Refresh()
	EnableControl(true)

func _BuildUI() -> void:
	for c in get_children():
		c.queue_free()

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	titleLabel = Label.new()
	titleLabel.text = "CÂY KỸ NĂNG"
	titleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titleLabel.add_theme_font_size_override("font_size", 16)
	titleLabel.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	root.add_child(titleLabel)

	var nav := HBoxContainer.new()
	nav.alignment = BoxContainer.ALIGNMENT_CENTER
	nav.add_theme_constant_override("separation", 12)
	root.add_child(nav)

	btnPrev = Button.new()
	btnPrev.text = "<"
	btnPrev.custom_minimum_size = Vector2(36, 28)
	btnPrev.pressed.connect(_OnPrev)
	nav.add_child(btnPrev)

	heroNavLabel = Label.new()
	heroNavLabel.custom_minimum_size = Vector2(180, 0)
	heroNavLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heroNavLabel.add_theme_font_size_override("font_size", 14)
	heroNavLabel.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
	nav.add_child(heroNavLabel)

	btnNext = Button.new()
	btnNext.text = ">"
	btnNext.custom_minimum_size = Vector2(36, 28)
	btnNext.pressed.connect(_OnNext)
	nav.add_child(btnNext)

	summaryLabel = Label.new()
	summaryLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summaryLabel.add_theme_font_size_override("font_size", 12)
	summaryLabel.add_theme_color_override("font_color", Color(0.75, 0.8, 0.85))
	root.add_child(summaryLabel)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	listBox = VBoxContainer.new()
	listBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	listBox.add_theme_constant_override("separation", 10)
	scroll.add_child(listBox)

	btnClose = Button.new()
	btnClose.text = "Đóng"
	btnClose.pressed.connect(func(): EnableControl(false))
	root.add_child(btnClose)

func Refresh() -> void:
	if listBox == null:
		return
	for c in listBox.get_children():
		c.queue_free()

	var hero : Dictionary = HeroLib.Get(heroIndex)
	var heroId : String = String(hero.get("id", "swordsman"))
	var tree : Dictionary = SkillTree.GetTree(heroId)
	if heroNavLabel:
		heroNavLabel.text = String(tree.get("label", hero.get("name", "—")))
	if summaryLabel:
		summaryLabel.text = String(tree.get("summary", ""))

	var playerLevel : int = 1
	var owned : Dictionary = {}
	if not previewOnly and Launcher.Player and Launcher.Player.stat:
		playerLevel = Launcher.Player.stat.level
		if Launcher.Player.progress:
			owned = Launcher.Player.progress.skills

	for node in tree.get("nodes", []):
		listBox.add_child(_MakeRealmBlock(node, playerLevel, owned, previewOnly))

func _MakeRealmBlock(node : Dictionary, playerLevel : int, owned : Dictionary, preview : bool) -> Control:
	var minLv : int = int(node.get("min_level", 1))
	var unlocked : bool = preview or playerLevel >= minLv

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.14, 0.85) if unlocked else Color(0.06, 0.06, 0.08, 0.7)
	style.set_border_width_all(1)
	style.border_color = Color(0.35, 0.75, 0.45, 0.7) if unlocked else Color(0.35, 0.35, 0.4, 0.4)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", style)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	panel.add_child(v)

	var head := Label.new()
	var realmName : String = String(node.get("realm_label", "?"))
	var lockTxt : String = "" if unlocked else "  [Khóa]"
	head.text = "%s  ·  cấp %d%s" % [realmName, minLv, lockTxt]
	head.add_theme_font_size_override("font_size", 13)
	head.add_theme_color_override("font_color", Color(0.45, 0.95, 0.55) if unlocked else Color(0.55, 0.55, 0.6))
	v.add_child(head)

	for sk in node.get("skills", []):
		v.add_child(_MakeSkillRow(sk, unlocked, owned, preview))

	return panel

func _MakeSkillRow(sk : Dictionary, realmUnlocked : bool, owned : Dictionary, preview : bool) -> Control:
	var skillName : String = String(sk.get("name", ""))
	var sid : int = SkillTree.ResolveSkillId(skillName)
	var learned : bool = preview or (sid != DB.UnknownHash and owned.get(sid, 0) >= 1)
	var cell : SkillCell = DB.SkillsDB.get(sid, null) as SkillCell

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var iconRect := TextureRect.new()
	iconRect.custom_minimum_size = Vector2(36, 36)
	iconRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	iconRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if cell and cell.icon:
		iconRect.texture = cell.icon
	else:
		iconRect.texture = _FallbackIcon(skillName)
	if not realmUnlocked and not preview:
		iconRect.modulate = Color(0.45, 0.45, 0.5, 0.85)
	elif learned:
		iconRect.modulate = Color(1.05, 1.02, 0.9, 1.0)
	row.add_child(iconRect)

	var textCol := VBoxContainer.new()
	textCol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textCol.add_theme_constant_override("separation", 1)
	row.add_child(textCol)

	var line := Label.new()
	var mark : String = "●" if learned else ("○" if realmUnlocked else "·")
	var vfxTag : String = "PixelFX" if String(sk.get("vfx", "")) == "pixel" else "SoM"
	line.text = "%s  %s  [%s]" % [mark, String(sk.get("title", skillName)), vfxTag]
	line.add_theme_font_size_override("font_size", 12)
	if learned:
		line.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55))
	elif realmUnlocked:
		line.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	else:
		line.add_theme_color_override("font_color", Color(0.45, 0.48, 0.52))
	textCol.add_child(line)

	var desc := Label.new()
	var lore : String = String(sk.get("desc", ""))
	if cell and not String(cell.description).is_empty():
		# Prefer tree lore; append cell description if different.
		var cellDesc : String = String(cell.description)
		if lore.is_empty():
			lore = cellDesc
		elif cellDesc != lore and not lore.contains(cellDesc.substr(0, mini(24, cellDesc.length()))):
			lore = lore + "\n" + cellDesc
	desc.text = lore
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75) if realmUnlocked else Color(0.4, 0.42, 0.45))
	textCol.add_child(desc)

	var statsLine := Label.new()
	var statsTxt : String = SkillTree.FormatSkillStats(cell)
	if statsTxt.is_empty():
		statsTxt = "(Chưa có số liệu modifier)"
	statsLine.text = statsTxt
	statsLine.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	statsLine.add_theme_font_size_override("font_size", 11)
	statsLine.add_theme_color_override("font_color", Color(0.95, 0.78, 0.35) if realmUnlocked else Color(0.5, 0.45, 0.35))
	textCol.add_child(statsLine)
	return row

func _FallbackIcon(skillName : String) -> Texture2D:
	var path := "res://data/graphics/items/skill/spell.png"
	match skillName:
		"Melee":
			path = "res://data/graphics/items/skill/melee.png"
		"Run":
			path = "res://data/graphics/items/skill/run.png"
		"Đạp Phong Bộ":
			path = "res://data/graphics/items/skill/jump.png"
		"Thanh Phong Kiếm Khí":
			path = "res://data/graphics/items/skill/leaf-blades.png"
		"Poison", "Betsanc":
			path = "res://data/graphics/items/skill/spell.png"
		"Morph":
			path = "res://data/graphics/items/skill/morph.png"
		"Inma", "Hàn Băng Thiên Kiếm":
			path = "res://data/graphics/items/skill/inma.png"
		_:
			path = "res://data/graphics/items/skill/spell.png"
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

func _OnPrev() -> void:
	heroIndex = heroIndex - 1 if heroIndex > 0 else HeroLib.Count() - 1
	_SyncPreviewFlagToSelection()
	Refresh()

func _OnNext() -> void:
	heroIndex = heroIndex + 1 if heroIndex < HeroLib.Count() - 1 else 0
	_SyncPreviewFlagToSelection()
	Refresh()

func _SyncPreviewFlagToSelection() -> void:
	# Own class → lock state theo cấp; class khác → xem catalog (preview).
	if Launcher.Player == null or Launcher.Player.stat == null:
		previewOnly = true
		return
	var shape : int = Launcher.Player.stat.shape
	if shape == DB.UnknownHash:
		shape = Launcher.Player.stat.currentShape
	var ownIdx : int = HeroLib.FindIndexByShape(shape)
	previewOnly = ownIdx < 0 or ownIdx != heroIndex
