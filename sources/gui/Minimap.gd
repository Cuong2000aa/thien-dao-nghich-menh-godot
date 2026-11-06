extends WindowPanel

const QuestGuidanceClass = preload("res://sources/quest/QuestGuidance.gd")

@onready var textureRect : TextureRect				= $ScrollContainer/TextureRect
@onready var scrollContainer : ScrollContainer		= $ScrollContainer
@onready var playerPoint : TextureRect				= $ScrollContainer/TextureRect/PlayerPoint

var textureSize : Vector2							= Vector2.ZERO
var questMarkerRoot : Control						= null
var _questMarkers : Array[Control]					= []
var _cachedSteps : Array							= []

#
func Warped():
	if not textureRect or not Launcher.Map:
		return
	if Launcher.Map.currentMapID == DB.UnknownHash:
		assert(false, "Could not fetch the active map name")
		return
	var mapData : MapData = DB.MapsDB.get(Launcher.Map.currentMapID, null)
	if not mapData:
		assert(false, "Could not retrieve the map ID from our map daabase")
		return
	if mapData.minimapPath.is_empty():
		assert(false, "Could not load the minimap resource")
		return
	var resource : Texture2D = ResourceLoader.load(mapData.minimapPath) as Texture2D
	textureRect.set_texture(resource)
	textureSize = textureRect.texture.get_size()
	if textureSize != Vector2.ZERO:
		maxSize = textureSize
	if size.x > maxSize.x:
		size.x = maxSize.x
	if size.y > maxSize.y:
		size.y = maxSize.y
	RefreshQuestMarkers()

func Moved():
	if not Launcher.Map or not Launcher.Map.currentMapNode:
		return

	var mapSize : Vector2 = Launcher.Map.GetMapBoundaries()
	if mapSize.x != 0 and mapSize.y != 0:
		var posRatio : Vector2 = Launcher.Player.position / mapSize
		var minimapPlayerPos : Vector2 = posRatio * textureRect.size - Vector2(5, 5)
		if minimapPlayerPos.is_equal_approx(playerPoint.get_position()):
			_RefreshOffMapArrows()
			return
		var scrollPos : Vector2i = Vector2i(minimapPlayerPos - scrollContainer.size / 2)
		scrollPos.x = clampi(scrollPos.x, 0, int(textureSize.x - scrollContainer.size.x))
		scrollPos.y = clampi(scrollPos.y, 0, int(textureSize.y - scrollContainer.size.y))

		scrollContainer.set_h_scroll(scrollPos.x)
		scrollContainer.set_v_scroll(scrollPos.y)
		playerPoint.set_position(minimapPlayerPos)
		_RefreshOffMapArrows()

func RefreshQuestMarkers(steps : Array = []):
	_EnsureMarkerRoot()
	_ClearMarkers()
	if steps.is_empty():
		steps = QuestGuidanceClass.GetActiveSteps()
	_cachedSteps = steps
	if not Launcher.Map or textureRect == null:
		return
	var mapSize : Vector2 = Launcher.Map.GetMapBoundaries()
	if mapSize.x == 0 or mapSize.y == 0 or textureRect.size.x == 0:
		return
	var currentMap : int = Launcher.Map.currentMapID
	for step in steps:
		var mapID : int = int(step.get("map_id", DB.UnknownHash))
		if mapID != currentMap:
			continue
		if not step.get("resolved", false):
			continue
		var worldPos : Vector2 = step.get("position", Vector2.ZERO)
		var ratio : Vector2 = worldPos / mapSize
		var miniPos : Vector2 = ratio * textureRect.size
		var marker : Control = _MakeMarker(step)
		questMarkerRoot.add_child(marker)
		marker.position = miniPos - marker.size * 0.5
		_questMarkers.append(marker)
	_RefreshOffMapArrows()

func _EnsureMarkerRoot() -> void:
	if questMarkerRoot and is_instance_valid(questMarkerRoot):
		return
	if textureRect == null:
		return
	questMarkerRoot = textureRect.get_node_or_null("QuestMarkers") as Control
	if questMarkerRoot == null:
		questMarkerRoot = Control.new()
		questMarkerRoot.name = "QuestMarkers"
		questMarkerRoot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		textureRect.add_child(questMarkerRoot)
		# Keep player point on top
		if playerPoint:
			textureRect.move_child(playerPoint, textureRect.get_child_count() - 1)

func _ClearMarkers() -> void:
	for m in _questMarkers:
		if m and is_instance_valid(m):
			m.queue_free()
	_questMarkers.clear()
	if questMarkerRoot:
		for c in questMarkerRoot.get_children():
			c.queue_free()

func _MakeMarker(step : Dictionary) -> Control:
	var btn : Button = Button.new()
	btn.custom_minimum_size = Vector2(14, 14)
	btn.size = Vector2(14, 14)
	btn.focus_mode = Control.FOCUS_NONE
	btn.tooltip_text = QuestGuidanceClass.FormatStepOneLine(step)
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	var action : int = int(step.get("action", 0))
	match action:
		QuestGuidanceClass.Action.KILL:
			btn.modulate = Color(1.0, 0.35, 0.25)
			btn.text = "⚔"
		QuestGuidanceClass.Action.GATHER:
			btn.modulate = Color(0.35, 0.95, 0.45)
			btn.text = "❀"
		QuestGuidanceClass.Action.RETURN:
			btn.modulate = Color(1.0, 0.85, 0.2)
			btn.text = "?"
		QuestGuidanceClass.Action.TALK:
			btn.modulate = Color(0.4, 0.8, 1.0)
			btn.text = "!"
		_:
			btn.modulate = Color(0.95, 0.95, 1.0)
			btn.text = "•"
	btn.add_theme_font_size_override("font_size", 10)
	var worldPos : Vector2 = step.get("position", Vector2.ZERO)
	btn.pressed.connect(func():
		if Launcher.Action:
			Launcher.Action.MoveTo(worldPos)
	)
	return btn

func _RefreshOffMapArrows() -> void:
	# Edge hints for quests on other maps — reuse tooltip on player point
	if playerPoint == null:
		return
	var offMap : PackedStringArray = PackedStringArray()
	if Launcher.Map:
		for step in _cachedSteps:
			if int(step.get("map_id", DB.UnknownHash)) == Launcher.Map.currentMapID:
				continue
			offMap.append("%s → %s" % [step.get("quest_name", ""), step.get("map_display", "?")])
	if offMap.is_empty():
		playerPoint.tooltip_text = "Bạn"
	else:
		playerPoint.tooltip_text = "Ủy thác khác map:\n" + "\n".join(offMap)

#
func _on_texture_rect_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if textureSize.x != 0 and textureSize.y != 0:
				Launcher.Action.MoveTo(event.position / textureSize * Launcher.Map.GetMapBoundaries())

func _ready():
	var HBar : HScrollBar = scrollContainer.get_h_scroll_bar()
	HBar.set_scale(Vector2.ZERO)
	HBar.set_allow_greater(false)

	var VBar : VScrollBar = scrollContainer.get_v_scroll_bar()
	VBar.set_scale(Vector2.ZERO)
	VBar.set_allow_greater(false)
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.PolishWindow(self)
	_post_launch()

func _post_launch():
	if Launcher.Map:
		Launcher.Map.PlayerWarped.connect(Warped)
		Launcher.Map.PlayerMoved.connect(Moved)

func Destroy():
	if Launcher.Map:
		if Launcher.Map.PlayerWarped.is_connected(Warped):
			Launcher.Map.PlayerWarped.disconnect(Warped)
		if Launcher.Map.PlayerMoved.is_connected(Moved):
			Launcher.Map.PlayerMoved.disconnect(Moved)
