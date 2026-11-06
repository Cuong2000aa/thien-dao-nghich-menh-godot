extends WindowPanel
class_name CultivationWindow

const Cultivation = preload("res://sources/actor/Cultivation.gd")
const Localization = preload("res://sources/system/Localization.gd")

# UI Nodes
var realmLabel : Label = null
var charNameLabel : Label = null
var tuViProgressBar : TextureProgressBar = null
var tuViTextLabel : Label = null
var bottleneckLabel : Label = null
var bottleneckDescLabel : Label = null
var techniqueLabel : Label = null
var spiritualRootLabel : Label = null
var comprehensionLabel : Label = null
var feedbackBox : RichTextLabel = null

var btnMeditate : Button = null
var btnBreakthrough : Button = null
var btnClose : Button = null

# Meditation state
var isMeditating : bool = false
var meditateTimer : Timer = null
var feedbackTick : int = 0

func _init():
	name = "CultivationWindow"
	custom_minimum_size = Vector2(560, 480)
	size = Vector2(560, 480)
	floating = true
	draggable = true
	visible = false

func _ready():
	_BuildUI()
	_InitTimer()
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.AttachJadeFrame(self)
	if realmLabel:
		ThemeClass.AccentLabel(realmLabel, true)
	if btnMeditate:
		ThemeClass.AccentButton(btnMeditate)
	if btnBreakthrough:
		ThemeClass.AccentButton(btnBreakthrough)
	Refresh()

func _InitTimer():
	meditateTimer = Timer.new()
	meditateTimer.wait_time = 1.0
	meditateTimer.one_shot = false
	meditateTimer.autostart = false
	meditateTimer.timeout.connect(_OnMeditateTick)
	add_child(meditateTimer)

func _BuildUI():
	for c in get_children():
		if not c is Timer:
			c.queue_free()

	var mainMargin = MarginContainer.new()
	mainMargin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mainMargin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mainMargin.add_theme_constant_override("margin_left", 14)
	mainMargin.add_theme_constant_override("margin_right", 14)
	mainMargin.add_theme_constant_override("margin_top", 12)
	mainMargin.add_theme_constant_override("margin_bottom", 14)
	add_child(mainMargin)

	var vBox = VBoxContainer.new()
	vBox.set("theme_override_constants/separation", 10)
	mainMargin.add_child(vBox)

	# 1. Window Header
	var title = Label.new()
	title.text = "VẬN CÔNG TU LUYỆN & ĐỘT PHÁ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	vBox.add_child(title)

	# 2. Realm & Name Header Box
	var headerHBox = HBoxContainer.new()
	headerHBox.alignment = BoxContainer.ALIGNMENT_CENTER
	headerHBox.set("theme_override_constants/separation", 16)
	vBox.add_child(headerHBox)

	charNameLabel = Label.new()
	charNameLabel.text = "Đạo Hiệu: [Đạo Hữu]"
	charNameLabel.add_theme_font_size_override("font_size", 14)
	charNameLabel.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	headerHBox.add_child(charNameLabel)

	realmLabel = Label.new()
	realmLabel.text = "Cảnh Giới: [Phàm Thân • Sơ Nhập]"
	realmLabel.add_theme_font_size_override("font_size", 14)
	realmLabel.add_theme_color_override("font_color", Color(0.3, 0.85, 0.4))
	headerHBox.add_child(realmLabel)

	vBox.add_child(HSeparator.new())

	# 3. Tu Vi Progress Section
	var tuViBox = VBoxContainer.new()
	tuViBox.set("theme_override_constants/separation", 4)
	vBox.add_child(tuViBox)

	var tuViTitle = Label.new()
	tuViTitle.text = "Tu Vi Tích Lũy (Chân Khí Đan Điền):"
	tuViTitle.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	tuViBox.add_child(tuViTitle)

	tuViTextLabel = Label.new()
	tuViTextLabel.text = "Tu Vi: 0 / 100 (0.0%)"
	tuViTextLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tuViTextLabel.add_theme_color_override("font_color", Color(1.0, 1.0, 0.8))
	tuViBox.add_child(tuViTextLabel)

	# 4. Bottleneck Section
	var bottleneckPanel = PanelContainer.new()
	vBox.add_child(bottleneckPanel)
	var bMargin = MarginContainer.new()
	bMargin.add_theme_constant_override("margin_left", 8)
	bMargin.add_theme_constant_override("margin_right", 8)
	bMargin.add_theme_constant_override("margin_top", 6)
	bMargin.add_theme_constant_override("margin_bottom", 6)
	bottleneckPanel.add_child(bMargin)

	var bVBox = VBoxContainer.new()
	bVBox.set("theme_override_constants/separation", 4)
	bMargin.add_child(bVBox)

	bottleneckLabel = Label.new()
	bottleneckLabel.text = "Bình Cảnh: Chưa tới bình cảnh"
	bottleneckLabel.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	bVBox.add_child(bottleneckLabel)

	bottleneckDescLabel = Label.new()
	bottleneckDescLabel.text = "Linh khí đang được bồi đắp vào đan điền, tích lũy chân khí."
	bottleneckDescLabel.add_theme_font_size_override("font_size", 12)
	bottleneckDescLabel.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	bottleneckDescLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bVBox.add_child(bottleneckDescLabel)

	# 5. Technique & Root Grid
	var grid = GridContainer.new()
	grid.columns = 2
	grid.set("theme_override_constants/h_separation", 16)
	grid.set("theme_override_constants/v_separation", 6)
	vBox.add_child(grid)

	techniqueLabel = Label.new()
	techniqueLabel.text = "Công Pháp: Trúc Sơn Dẫn Khí Quyết"
	techniqueLabel.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
	grid.add_child(techniqueLabel)

	spiritualRootLabel = Label.new()
	spiritualRootLabel.text = "Linh Căn: Thiên Linh Căn (Mộc • Phong)"
	spiritualRootLabel.add_theme_color_override("font_color", Color(0.4, 0.85, 0.95))
	grid.add_child(spiritualRootLabel)

	comprehensionLabel = Label.new()
	comprehensionLabel.text = "Ngộ Tính: 88  |  Tư Chất: 92"
	comprehensionLabel.add_theme_color_override("font_color", Color(0.8, 0.9, 0.6))
	grid.add_child(comprehensionLabel)

	vBox.add_child(HSeparator.new())

	# 6. Cultivation Feedback Console
	var fbTitle = Label.new()
	fbTitle.text = "Cảm Ngộ Tu Luyện (Phản Hồi Vận Công):"
	fbTitle.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	vBox.add_child(fbTitle)

	feedbackBox = RichTextLabel.new()
	feedbackBox.bbcode_enabled = true
	feedbackBox.custom_minimum_size = Vector2(0, 75)
	feedbackBox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	feedbackBox.text = "[color=#a0e0a0]• Tâm thần tĩnh lặng, cảm ứng linh khí thiên địa quanh sơn môn.[/color]"
	vBox.add_child(feedbackBox)

	# 7. Action Buttons
	var btnHBox = HBoxContainer.new()
	btnHBox.alignment = BoxContainer.ALIGNMENT_CENTER
	btnHBox.set("theme_override_constants/separation", 16)
	vBox.add_child(btnHBox)

	btnMeditate = Button.new()
	btnMeditate.text = "Vận Công"
	btnMeditate.custom_minimum_size = Vector2(140, 36)
	btnMeditate.pressed.connect(ToggleMeditation)
	btnHBox.add_child(btnMeditate)

	btnBreakthrough = Button.new()
	btnBreakthrough.text = "Chuẩn Bị Đột Phá"
	btnBreakthrough.custom_minimum_size = Vector2(170, 36)
	btnBreakthrough.pressed.connect(AttemptBreakthrough)
	btnHBox.add_child(btnBreakthrough)

	var btnSkillTree := Button.new()
	btnSkillTree.text = "Cây Kỹ Năng"
	btnSkillTree.custom_minimum_size = Vector2(130, 36)
	btnSkillTree.pressed.connect(func():
		if Launcher.GUI and Launcher.GUI.has_method("ToggleSkillTree"):
			Launcher.GUI.ToggleSkillTree()
	)
	btnHBox.add_child(btnSkillTree)

	btnClose = Button.new()
	btnClose.text = "Thu Công"
	btnClose.custom_minimum_size = Vector2(100, 36)
	btnClose.pressed.connect(func(): Launcher.GUI.ToggleControl(self))
	btnHBox.add_child(btnClose)

## Helper to get local player entity or server agent fallback
func GetActivePlayer():
	if Launcher.Player:
		return Launcher.Player
	for agent in WorldAgent.agents.values():
		if agent is PlayerAgent:
			return agent
	return null

## Refresh dynamic cultivation state from Player data
func Refresh():
	var player = GetActivePlayer()
	if not player or not player.stat:
		return

	var level : int = player.stat.level
	var curExp : int = player.stat.experience
	var nextExp : int = Experience.GetNeededExperienceForNextLevel(level)

	if charNameLabel:
		charNameLabel.text = "Đạo Hiệu: [%s]" % player.nick

	if realmLabel:
		var realmName = Cultivation.GetRealmName(level)
		realmLabel.text = "Cảnh Giới: [%s]" % realmName
		realmLabel.add_theme_color_override("font_color", Cultivation.GetRealmColor(level))

	if tuViTextLabel:
		var pct : float = float(curExp) / float(nextExp) * 100.0 if nextExp > 0 else 100.0
		tuViTextLabel.text = "Tu Vi: %d / %d (%.1f%%)" % [curExp, nextExp, pct]

	var bStatus = Cultivation.GetBottleneckStatus(level, curExp, nextExp)
	if bottleneckLabel:
		bottleneckLabel.text = "Bình Cảnh: %s" % bStatus["status"]
		bottleneckLabel.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4) if bStatus["hasBottleneck"] else Color(0.4, 0.9, 1.0))
	if bottleneckDescLabel:
		bottleneckDescLabel.text = bStatus["description"]

	var tech = Cultivation.GetActiveTechnique(player)
	if techniqueLabel:
		techniqueLabel.text = "Công Pháp: %s (%s) · Lĩnh Hội: %s" % [tech["name"], tech["grade"], tech.get("mastery", "—")]

	var sRoot = Cultivation.CalculateSpiritualRoot(player)
	if spiritualRootLabel:
		spiritualRootLabel.text = "Linh Căn: %s" % sRoot["name"]

	var comp : int = Cultivation.CalculateComprehension(player)
	var apt : int = Cultivation.CalculateAptitude(player)
	if comprehensionLabel:
		comprehensionLabel.text = "Ngộ Tính: %d  |  Tư Chất: %d" % [comp, apt]

	if btnBreakthrough:
		var canBreak : bool = Cultivation.CanAttemptBreakthrough(level, curExp, nextExp)
		btnBreakthrough.text = "Đột Phá Cảnh Giới" if canBreak else "Chuẩn Bị Đột Phá"
		btnBreakthrough.set("theme_override_colors/font_color", Color(1.0, 0.9, 0.2) if canBreak else Color(0.8, 0.8, 0.8))

## Toggle live Meditative Cultivation
func ToggleMeditation():
	isMeditating = not isMeditating
	if isMeditating:
		btnMeditate.text = "Tạm Dừng Tu Luyện"
		btnMeditate.set("theme_override_colors/font_color", Color(1.0, 0.5, 0.4))
		meditateTimer.start()
		AddFeedback("Ngồi xuống, bắt đầu vận công...")
		if Launcher.GUI and Launcher.GUI.notificationLabel:
			Launcher.GUI.notificationLabel.AddNotification("Đang tu luyện — linh khí đang tụ lại.")
	else:
		btnMeditate.text = "Vận Công"
		btnMeditate.set("theme_override_colors/font_color", Color(1.0, 1.0, 1.0))
		meditateTimer.stop()
		AddFeedback("Thu công. Nghỉ một nhịp.")

## Periodic meditation tick: gain Tu Vi and cycle feedback
func _OnMeditateTick():
	var player = GetActivePlayer()
	if not player or not player.stat:
		return

	# Gain 12 Tu Vi per tick during meditation
	player.stat.experience += 12
	player.stat.vital_stats_updated.emit()
	feedbackTick += 1
	var msg = Cultivation.GetCultivationFeedback(feedbackTick)
	AddFeedback(msg)
	Refresh()

## Add feedback entry to console
func AddFeedback(msg: String):
	if feedbackBox:
		feedbackBox.append_text("\n[color=#c0f0c0]• %s[/color]" % msg)

## Trigger Breakthrough Attempt
func AttemptBreakthrough():
	var player = GetActivePlayer()
	if not player:
		return

	var res = Cultivation.AttemptBreakthrough(player)
	if res["success"]:
		AddFeedback("[color=#ffff60]★ %s Cảnh giới đột phá: [%s] -> [%s]![/color]" % [res["message"], res["oldRealm"], res["newRealm"]])
		if Launcher.GUI and Launcher.GUI.notificationLabel:
			Launcher.GUI.notificationLabel.AddNotification("Đột phá thành công: %s → %s" % [res["oldRealm"], res["newRealm"]])
		if Launcher.Map and Launcher.Map.currentFringe and player:
			var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
			CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, "dragon_golden_spiral", player.global_position, -1.0, false, true)
			CombatVisualSystemClass.SpawnPixelFx(Launcher.Map.currentFringe, "level_up", player.global_position, -1.0, false, true)
	else:
		AddFeedback("[color=#ff8080]✗ %s[/color]" % res["message"])
		if Launcher.GUI and Launcher.GUI.notificationLabel:
			Launcher.GUI.notificationLabel.AddNotification(res["message"])

	Refresh()
	return res
