extends PanelContainer

#
@onready var levelLabel : Label						= $Margin/VBox/Level/Value
@onready var locationLabel : Label					= $Margin/VBox/Location/Value
@onready var selection : Control					= $Margin/VBox/Selection
@onready var previousButton : Button				= $Margin/VBox/Selection/Previous
@onready var nextButton : Button					= $Margin/VBox/Selection/Next

const Cultivation = preload("res://sources/actor/Cultivation.gd")

#
func SetInfo(info : Dictionary):
	var lvl : int = info.get("level", 1)
	levelLabel.set_text("%s (Cấp %d)" % [Cultivation.GetRealmName(lvl), lvl])
	var mapData : MapData = DB.MapsDB.get(info["pos_map"], null)
	if mapData:
		locationLabel.set_text(LocationNaming.GetDisplayName(mapData))

#
func _input(event : InputEvent):
	if not visible or not event is InputEventKey or not Launcher.Action.IsEnabled():
		return

	if previousButton and previousButton.is_visible() and event.is_action("ui_left"):
		if Launcher.Action.TryPressed(event, "ui_left", true):
			previousButton.pressed.emit()
	elif nextButton and nextButton.is_visible() and event.is_action("ui_right"):
		if Launcher.Action.TryPressed(event, "ui_right", true):
			nextButton.pressed.emit()

func _unhandled_input(event : InputEvent):
	if not visible or not Launcher.Action.IsEnabled():
		return

	if previousButton and previousButton.is_visible() and event.is_action("ui_context_previous"):
		if Launcher.Action.TryPressed(event, "ui_context_previous", true):
			previousButton.pressed.emit()
	elif nextButton and nextButton.is_visible() and event.is_action("ui_context_next"):
		if Launcher.Action.TryPressed(event, "ui_context_next", true):
			nextButton.pressed.emit()
