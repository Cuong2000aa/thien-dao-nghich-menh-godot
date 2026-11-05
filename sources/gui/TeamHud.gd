extends Control
class_name TeamHud

## TDNM — BUILD 11/13: TEAM HUD (ĐỒNG ĐẠO)
## Shows co-op allies from SessionManager — name, realm, HP, host/client role, map hint.

const ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")

var rootBox : VBoxContainer = null
var headerLabel : Label = null
var modeLabel : Label = null
var memberCardsBox : VBoxContainer = null

func _init():
	name = "TeamHud"
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2(16, 120)
	custom_minimum_size = Vector2(230, 50)

func _ready():
	_BuildUI()
	SessionManager.AddListener(_OnSessionUpdated)
	Refresh()

func _exit_tree():
	SessionManager.RemoveListener(_OnSessionUpdated)

func _BuildUI():
	rootBox = VBoxContainer.new()
	rootBox.add_theme_constant_override("separation", 4)
	add_child(rootBox)

	headerLabel = Label.new()
	headerLabel.text = "ĐỒNG ĐẠO ĐỒNG HÀNH"
	ThemeClass.AccentLabel(headerLabel, true)
	rootBox.add_child(headerLabel)

	modeLabel = Label.new()
	modeLabel.add_theme_font_size_override("font_size", 11)
	rootBox.add_child(modeLabel)

	memberCardsBox = VBoxContainer.new()
	memberCardsBox.add_theme_constant_override("separation", 4)
	rootBox.add_child(memberCardsBox)

func Refresh():
	for child in memberCardsBox.get_children():
		child.queue_free()

	var members = SessionManager.GetMembers()
	if members.size() <= 1 and SessionManager.currentMode == SessionManager.Mode.OFFLINE:
		visible = false
		return

	visible = true
	match SessionManager.currentMode:
		SessionManager.Mode.HOST:
			modeLabel.text = "Vai trò: Chủ Phòng · Cổng %d · %d/%d" % [SessionManager.listenPort, members.size(), SessionManager.maxPlayers]
			modeLabel.add_theme_color_override("font_color", ThemeClass.GOLD_SOFT)
		SessionManager.Mode.CLIENT:
			modeLabel.text = "Vai trò: Đạo Lữ · %s:%d" % [SessionManager.targetHost, SessionManager.targetPort]
			modeLabel.add_theme_color_override("font_color", ThemeClass.JADE)
		_:
			modeLabel.text = "Trạng thái: Độc Bộ Tu Chân"
			modeLabel.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

	var localNick = Launcher.Player.nick if Launcher.Player else ""
	var localMap := 0
	if Launcher.Map:
		localMap = Launcher.Map.currentMapID

	for m in members:
		if m.get("nick", "") == localNick and members.size() > 1:
			continue
		memberCardsBox.add_child(_CreateAllyCard(m, localMap))

func _CreateAllyCard(m : Dictionary, localMap : int) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(210, 42)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var vBox = VBoxContainer.new()
	vBox.add_theme_constant_override("separation", 2)
	margin.add_child(vBox)

	var hBox = HBoxContainer.new()
	var roleIcon = "Chủ " if m.get("isHost", false) else "Lữ "
	var lblName = Label.new()
	lblName.text = roleIcon + str(m.get("nick", "Đạo Hữu"))
	lblName.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ThemeClass.AccentLabel(lblName, m.get("isHost", false))
	hBox.add_child(lblName)

	var lblRealm = Label.new()
	lblRealm.text = str(m.get("realm", "Phàm Thân"))
	lblRealm.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0, 0.9))
	lblRealm.add_theme_font_size_override("font_size", 11)
	hBox.add_child(lblRealm)
	vBox.add_child(hBox)

	var mapId : int = int(m.get("mapId", 0))
	var mapHint := Label.new()
	mapHint.add_theme_font_size_override("font_size", 10)
	if mapId != 0 and localMap != 0 and mapId == localMap:
		mapHint.text = "Cùng bản đồ"
		mapHint.add_theme_color_override("font_color", ThemeClass.JADE)
	elif mapId != 0:
		mapHint.text = "Khác bản đồ"
		mapHint.add_theme_color_override("font_color", ThemeClass.WARN)
	else:
		mapHint.text = "Đang kết nối…"
		mapHint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vBox.add_child(mapHint)

	var curHp = m.get("hp", 100)
	var maxHp = max(1, m.get("maxHp", 100))
	var hpRatio = clampf(float(curHp) / float(maxHp), 0.0, 1.0)
	var pBar = ProgressBar.new()
	pBar.min_value = 0
	pBar.max_value = 100
	pBar.value = hpRatio * 100
	pBar.custom_minimum_size = Vector2(190, 6)
	pBar.show_percentage = false
	pBar.modulate = ThemeClass.DANGER if hpRatio <= 0.25 else (ThemeClass.WARN if hpRatio <= 0.45 else ThemeClass.JADE)
	vBox.add_child(pBar)

	return panel

func _OnSessionUpdated():
	Refresh()
