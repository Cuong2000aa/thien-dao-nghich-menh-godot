extends Control
class_name TrackerBar

#
@onready var label : Label				= $MarginContainer/VBoxContainer/Label
@onready var bar : Control				= $MarginContainer/VBoxContainer/Bar

var tween : Tween						= null
var lastLabel : String					= ""
var lastValue : int						= 0
var lastMax : int						= 0

# Accessors
func Display(text : String, value : int, maxValue : int, unit : String = ""):
	lastLabel = text
	lastValue = value
	lastMax = maxValue
	label.text = text
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.AccentLabel(label, true)
	bar.SetUnit(unit)
	bar.SetStat(value, maxValue)
	if not is_visible() or modulate.a < 1.0:
		FadeIn()

func Clear():
	lastLabel = ""
	lastValue = 0
	lastMax = 0
	if is_visible():
		FadeOut()

func IsComplete() -> bool:
	return lastMax > 0 and lastValue >= lastMax

func MatchesTarget(nick : String) -> bool:
	if nick.is_empty() or lastLabel.is_empty():
		return false
	var a : String = lastLabel.to_lower()
	var b : String = nick.to_lower()
	return a == b or a.contains(b) or b.contains(a)

# Visibility
func FadeIn():
	if tween:
		tween.kill()
	modulate.a = 0.0
	show()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func FadeOut():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(hide)
