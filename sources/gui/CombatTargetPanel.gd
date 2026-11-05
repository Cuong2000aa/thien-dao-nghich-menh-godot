extends Control
class_name CombatTargetPanel

## TDNM — Target Information Panel for Enemies & Monsters
## Displays Target Name, Realm, Elemental Affinity, HP Bar & Active Status

var panelBox : PanelContainer		= null
var nameLabel : Label				= null
var realmLabel : Label				= null
var elemBadge : Label				= null
var hpBar : ProgressBar				= null
var hpText : Label					= null

var currentTarget : Entity			= null

func _ready():
	custom_minimum_size = Vector2(280, 56)
	size = Vector2(280, 56)
	anchors_preset = Control.PRESET_CENTER_TOP
	offset_left = -140
	offset_top = 16
	offset_right = 140
	offset_bottom = 72
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Background style
	panelBox = PanelContainer.new()
	panelBox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panelBox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.12, 0.85)
	style.border_color = Color(0.4, 0.7, 0.6, 0.7)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	panelBox.add_theme_stylebox_override("panel", style)
	add_child(panelBox)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panelBox.add_child(vbox)
	
	var topHBox = HBoxContainer.new()
	vbox.add_child(topHBox)
	
	elemBadge = Label.new()
	elemBadge.text = "[Mộc]"
	elemBadge.set("theme_override_colors/font_color", Color(0.3, 0.9, 0.4))
	elemBadge.set("theme_override_font_sizes/font_size", 11)
	topHBox.add_child(elemBadge)
	
	nameLabel = Label.new()
	nameLabel.text = "Yêu Thú Mục Tiêu"
	nameLabel.set("theme_override_colors/font_color", Color(1.0, 0.95, 0.85))
	nameLabel.set("theme_override_font_sizes/font_size", 11)
	nameLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topHBox.add_child(nameLabel)
	
	realmLabel = Label.new()
	realmLabel.text = "Cấp 1"
	realmLabel.set("theme_override_colors/font_color", Color(0.8, 0.8, 0.8))
	realmLabel.set("theme_override_font_sizes/font_size", 10)
	topHBox.add_child(realmLabel)
	
	# HP Bar
	hpBar = ProgressBar.new()
	hpBar.custom_minimum_size = Vector2(0, 14)
	hpBar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hpBar.show_percentage = false
	
	var barBg = StyleBoxFlat.new()
	barBg.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	barBg.set_corner_radius_all(2)
	hpBar.add_theme_stylebox_override("background", barBg)
	
	var barFill = StyleBoxFlat.new()
	barFill.bg_color = Color(0.85, 0.2, 0.2, 0.95)
	barFill.set_corner_radius_all(2)
	hpBar.add_theme_stylebox_override("fill", barFill)
	
	vbox.add_child(hpBar)
	
	hpText = Label.new()
	hpText.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hpText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hpText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hpText.set("theme_override_font_sizes/font_size", 9)
	hpText.set("theme_override_colors/font_color", Color.WHITE)
	hpBar.add_child(hpText)
	
	set_visible(false)

func _process(_delta : float):
	var target : Entity = Entities.target
	if target and is_instance_valid(target) and target.type == ActorCommons.Type.MONSTER and target.state != ActorCommons.State.DEATH:
		UpdateTarget(target)
		set_visible(true)
	else:
		set_visible(false)

func UpdateTarget(target : Entity):
	if not target or not target.stat:
		return
	currentTarget = target
	
	var CultivationClass = preload("res://sources/actor/Cultivation.gd")
	var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
	
	var localizedName : String = CultivationClass.GetItemDisplayName(target.nick)
	nameLabel.text = localizedName
	
	# Determine element
	var elem : int = CombatSystemClass.Element.EARTH
	if target.data and target.data._isBoss:
		elem = CombatSystemClass.Element.FIRE
	elif target.nick.contains("Trùng") or target.nick.contains("Maggot"):
		elem = CombatSystemClass.Element.WOOD
		
	elemBadge.text = "[%s]" % CombatSystemClass.GetElementName(elem)
	elemBadge.set("theme_override_colors/font_color", CombatSystemClass.GetElementColor(elem))
	
	var lvl : int = target.stat.level
	realmLabel.text = CultivationClass.GetRealmName(lvl)
	
	var hp : int = target.stat.health
	var maxHp : int = target.stat.current.maxHealth
	hpBar.max_value = maxHp
	hpBar.value = hp
	hpText.text = "%d / %d" % [hp, maxHp]
