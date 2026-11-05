extends Control

const Cultivation = preload("res://sources/actor/Cultivation.gd")
const ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
const HudFeedbackClass = preload("res://sources/gui/HudFeedback.gd")

@onready var hpStat : Control			= $HP
@onready var manaStat : Control			= $Mana
@onready var staminaStat : Control		= $Stamina
@onready var expStat : Control			= $Exp
@onready var button : TouchScreenButton	= $TouchButton

var realmLabel : Label					= null
var swordQiLabel : Label				= null
var coopLabel : Label					= null
var _lastHp : int						= -1

func _init_realm_label():
	if realmLabel == null:
		realmLabel = Label.new()
		realmLabel.name = "RealmLabel"
		realmLabel.position = Vector2(52, -2)
		realmLabel.set("theme_override_colors/font_shadow_color", Color(0, 0, 0, 0.8))
		realmLabel.set("theme_override_constants/shadow_offset_x", 1)
		realmLabel.set("theme_override_constants/shadow_offset_y", 1)
		realmLabel.set("theme_override_font_sizes/font_size", 11)
		ThemeClass.AccentLabel(realmLabel, true)
		add_child(realmLabel)

func _init_sword_qi_label():
	if swordQiLabel == null:
		swordQiLabel = Label.new()
		swordQiLabel.name = "SwordQiLabel"
		swordQiLabel.position = Vector2(52, 62)
		swordQiLabel.set("theme_override_colors/font_shadow_color", Color(0, 0, 0, 0.8))
		swordQiLabel.set("theme_override_constants/shadow_offset_x", 1)
		swordQiLabel.set("theme_override_constants/shadow_offset_y", 1)
		swordQiLabel.set("theme_override_font_sizes/font_size", 10)
		add_child(swordQiLabel)

func _init_coop_label():
	if coopLabel == null:
		coopLabel = Label.new()
		coopLabel.name = "CoopStatusLabel"
		coopLabel.position = Vector2(52, 76)
		coopLabel.set("theme_override_font_sizes/font_size", 10)
		coopLabel.set("theme_override_colors/font_shadow_color", Color(0, 0, 0, 0.75))
		coopLabel.set("theme_override_constants/shadow_offset_x", 1)
		coopLabel.set("theme_override_constants/shadow_offset_y", 1)
		add_child(coopLabel)

#
func Refresh():
	if Launcher.Player:
		_init_realm_label()
		_init_sword_qi_label()
		_init_coop_label()
		if realmLabel:
			var realmName = Cultivation.GetRealmName(Launcher.Player.stat.level)
			realmLabel.text = "[%s] %s" % [realmName, Launcher.Player.nick]
			realmLabel.set("theme_override_colors/font_color", Cultivation.GetRealmColor(Launcher.Player.stat.level))
		
		if swordQiLabel:
			var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
			var qi : int = CombatSystemClass.GetSwordQi(Launcher.Player)
			if qi == 0:
				swordQiLabel.text = "Kiếm Khí: [ ○ ○ ○ ○ ○ ]"
				swordQiLabel.set("theme_override_colors/font_color", Color(0.7, 0.7, 0.7, 0.8))
			elif qi >= 5:
				swordQiLabel.text = "Kiếm Khí: [ ⚔ ⚔ ⚔ ⚔ ⚔ ] (Viên Mãn)"
				swordQiLabel.set("theme_override_colors/font_color", Color(1.0, 0.9, 0.2))
			else:
				var pips : String = ""
				for i in range(5):
					pips += "⚔ " if i < qi else "○ "
				swordQiLabel.text = "Kiếm Khí: [ %s]" % pips.strip_edges()
				swordQiLabel.set("theme_override_colors/font_color", Color(0.4, 0.95, 0.5))

		var maxHp : float = float(Launcher.Player.stat.current.maxHealth)
		var hp : float = float(Launcher.Player.stat.health)
		var hpRatio : float = hp / maxHp if maxHp > 0.0 else 1.0
		hpStat.SetStat(hp, maxHp)
		ThemeClass.TintProgressLowHp(hpStat, hpRatio)
		HudFeedbackClass.PulseLowHp(hpRatio)
		if _lastHp >= 0 and int(hp) < _lastHp and Launcher.Player == Launcher.Player:
			HudFeedbackClass.FlashHit()
		_lastHp = int(hp)

		manaStat.SetStat(Launcher.Player.stat.mana, Launcher.Player.stat.current.maxMana)
		staminaStat.SetStat(Launcher.Player.stat.stamina, Launcher.Player.stat.current.maxStamina)
		expStat.SetStat(Launcher.Player.stat.experience, Experience.GetNeededExperienceForNextLevel(Launcher.Player.stat.level))

		if coopLabel:
			match SessionManager.currentMode:
				SessionManager.Mode.HOST:
					coopLabel.text = "Đồng Đạo: Chủ Phòng (%d/%d)" % [SessionManager.GetMemberCount(), SessionManager.maxPlayers]
					coopLabel.add_theme_color_override("font_color", ThemeClass.GOLD_SOFT)
					coopLabel.visible = true
				SessionManager.Mode.CLIENT:
					coopLabel.text = "Đồng Đạo: Đạo Lữ · %s:%d" % [SessionManager.targetHost, SessionManager.targetPort]
					coopLabel.add_theme_color_override("font_color", ThemeClass.JADE)
					coopLabel.visible = true
				_:
					coopLabel.visible = false

func Connect():
	if Launcher.Player:
		if not Launcher.Player.stat.vital_stats_updated.is_connected(Refresh):
			Launcher.Player.stat.vital_stats_updated.connect(Refresh)

func SetBarsVisible(isVisible : bool):
	hpStat.set_visible(isVisible)
	manaStat.set_visible(isVisible)
	staminaStat.set_visible(isVisible)
	expStat.set_visible(isVisible)
	button.set_visible(isVisible)

#
func _post_launch():
	if Launcher.Map:
		if not Launcher.Map.PlayerWarped.is_connected(Connect):
			Launcher.Map.PlayerWarped.connect(Connect)

func _ready():
	_post_launch()

func _on_button_pressed():
	Launcher.GUI.ToggleControl(Launcher.GUI.statWindow)
