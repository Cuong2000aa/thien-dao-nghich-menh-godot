extends Node
class_name QuestGuideController

## Owns in-world quest waypoints + HUD compass line. Refresh on quest/map changes.

const QuestGuidanceClass = preload("res://sources/quest/QuestGuidance.gd")

var hudLabel : RichTextLabel = null
var waypointRoot : Node2D = null
var _lastSignature : String = ""

func _ready() -> void:
	name = "QuestGuideController"
	set_process(true)
	_EnsureHud()
	if Launcher.Map:
		if not Launcher.Map.PlayerWarped.is_connected(_OnMapChanged):
			Launcher.Map.PlayerWarped.connect(_OnMapChanged)
		if not Launcher.Map.MapLoaded.is_connected(_OnMapChanged):
			Launcher.Map.MapLoaded.connect(_OnMapChanged)
		if not Launcher.Map.MapUnloaded.is_connected(_OnMapUnloaded):
			Launcher.Map.MapUnloaded.connect(_OnMapUnloaded)
	Refresh()

func _exit_tree() -> void:
	if Launcher.Map:
		if Launcher.Map.PlayerWarped.is_connected(_OnMapChanged):
			Launcher.Map.PlayerWarped.disconnect(_OnMapChanged)
		if Launcher.Map.MapLoaded.is_connected(_OnMapChanged):
			Launcher.Map.MapLoaded.disconnect(_OnMapChanged)
		if Launcher.Map.MapUnloaded.is_connected(_OnMapUnloaded):
			Launcher.Map.MapUnloaded.disconnect(_OnMapUnloaded)
	_ClearWaypoints()

func _process(_delta : float) -> void:
	# Light refresh for live monster positions (~4 Hz)
	if Engine.get_process_frames() % 15 == 0:
		Refresh(false)

func _OnMapChanged() -> void:
	Refresh(true)

func _OnMapUnloaded() -> void:
	_ClearWaypoints()
	waypointRoot = null

func Refresh(force : bool = true) -> void:
	QuestGuidanceClass.EnsureIndex()
	var steps : Array = QuestGuidanceClass.GetActiveSteps()
	var signature : String = _Signature(steps)
	if not force and signature == _lastSignature:
		_UpdateWaypointPositions(steps)
		return
	_lastSignature = signature
	_RefreshHud(steps)
	_RefreshWaypoints(steps)
	if Launcher.GUI and Launcher.GUI.minimapWindow and Launcher.GUI.minimapWindow.has_method("RefreshQuestMarkers"):
		Launcher.GUI.minimapWindow.RefreshQuestMarkers(steps)

func _Signature(steps : Array) -> String:
	var parts : PackedStringArray = PackedStringArray()
	for s in steps:
		parts.append("%s:%s:%d:%d:%d" % [
			s.get("quest_id", 0),
			s.get("nick", ""),
			s.get("map_id", 0),
			int(s.get("position", Vector2.ZERO).x),
			int(s.get("position", Vector2.ZERO).y),
		])
	if Launcher.Map:
		parts.append("map:%d" % Launcher.Map.currentMapID)
	return "|".join(parts)

func _EnsureHud() -> void:
	if hudLabel and is_instance_valid(hudLabel):
		return
	if Launcher.GUI == null:
		return
	var info = Launcher.GUI.get_node_or_null("Overlay/VSections/Indicators/Info")
	if info == null:
		return
	hudLabel = info.get_node_or_null("QuestGuideHud") as RichTextLabel
	if hudLabel == null:
		hudLabel = RichTextLabel.new()
		hudLabel.name = "QuestGuideHud"
		hudLabel.bbcode_enabled = true
		hudLabel.fit_content = true
		hudLabel.scroll_active = false
		hudLabel.custom_minimum_size = Vector2(280, 0)
		hudLabel.mouse_filter = Control.MOUSE_FILTER_STOP
		info.add_child(hudLabel)
		# Place above progression tracker if possible
		if Launcher.GUI.progressionTracker:
			info.move_child(hudLabel, Launcher.GUI.progressionTracker.get_index())
	else:
		hudLabel.mouse_filter = Control.MOUSE_FILTER_STOP

	if not hudLabel.meta_clicked.is_connected(_OnHudMetaClicked):
		hudLabel.meta_clicked.connect(_OnHudMetaClicked)

	if Launcher.GUI and Launcher.GUI.questAutoController:
		if not Launcher.GUI.questAutoController.auto_toggled.is_connected(_OnAutoToggled):
			Launcher.GUI.questAutoController.auto_toggled.connect(_OnAutoToggled)

	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.AccentRichText(hudLabel)

func _OnAutoToggled(_on : bool) -> void:
	Refresh(true)

func _OnHudMetaClicked(meta : Variant) -> void:
	var action : String = str(meta)
	match action:
		"toggle_auto":
			if Launcher.GUI:
				Launcher.GUI.EnsureQuestAuto()
				if Launcher.GUI.questAutoController:
					Launcher.GUI.questAutoController.Toggle()
					Refresh(true)
		"skip_quest":
			if Launcher.GUI:
				var activeQ : int = QuestGuidanceClass.FindPrimaryActiveQuest()
				if activeQ != DB.UnknownHash and Launcher.GUI.progressWindow:
					Launcher.GUI.progressWindow.currentQuest = activeQ
					Launcher.GUI.progressWindow._PromptQuestAction(false)
		"open_progress":
			if Launcher.GUI and Launcher.GUI.progressWindow:
				Launcher.GUI.progressWindow.EnableControl(not Launcher.GUI.progressWindow.is_visible())
		"goto_quest":
			var steps : Array = QuestGuidanceClass.GetActiveSteps()
			if not steps.is_empty():
				var s : Dictionary = steps[0]
				if s.get("resolved", false) and Launcher.Action:
					Launcher.Action.MoveTo(s.get("position", Vector2.ZERO))

func _RefreshHud(steps : Array) -> void:
	_EnsureHud()
	if hudLabel == null:
		return

	var autoOn : bool = (Launcher.GUI and Launcher.GUI.questAutoController and Launcher.GUI.questAutoController.enabled)
	var autoBtnText : String = "[color=#55ff88][b][url=toggle_auto][ ⚡ Auto: BẬT ][/url][/b][/color]" if autoOn else "[color=#aaaaaa][url=toggle_auto][ ⚪ Auto: TẮT ][/url][/color]"
	var skipBtnText : String = "[color=#ffcc44][url=skip_quest][ ⏩ Bỏ qua ][/url][/color]"
	var logBtnText : String = "[color=#66ccff][url=open_progress][ 📜 Sổ tay ][/url][/color]"

	if steps.is_empty():
		var nextAvail : int = QuestGuidanceClass.FindNextAvailableQuest()
		var nextHint : String = ""
		if nextAvail != DB.UnknownHash:
			var nData : QuestData = DB.GetQuest(nextAvail)
			var nTitle : String = Localization.Get(nData.name, nData.name) if nData else str(nextAvail)
			nextHint = "\n[color=#88ccff]Có nhiệm vụ mới: [b]%s[/b][/color]" % nTitle
		else:
			nextHint = "\n[color=#888888]Tất cả nhiệm vụ đã hoàn tất[/color]"
		hudLabel.text = "[color=#ffd700]⚔ Ủy thác[/color]" + nextHint + "\n" + autoBtnText + "  " + logBtnText
		hudLabel.visible = true
		return

	var primary : Dictionary = steps[0]
	var extra : int = maxi(0, steps.size() - 1)
	var body : String = "[color=#ffd700]⚔ Ủy thác[/color]\n" + QuestGuidanceClass.FormatStepRich(primary)
	if extra > 0:
		body += "\n[color=#888888]+%d ủy thác khác[/color]" % extra
	body += "\n" + autoBtnText + "  " + skipBtnText + "  " + logBtnText
	hudLabel.text = body
	hudLabel.visible = true

func _EnsureWaypointRoot() -> Node2D:
	if waypointRoot and is_instance_valid(waypointRoot):
		return waypointRoot
	if Launcher.Map == null or Launcher.Map.currentMapNode == null:
		return null
	waypointRoot = Launcher.Map.currentMapNode.get_node_or_null("QuestWaypoints") as Node2D
	if waypointRoot == null:
		waypointRoot = Node2D.new()
		waypointRoot.name = "QuestWaypoints"
		waypointRoot.z_index = 50
		Launcher.Map.currentMapNode.add_child(waypointRoot)
	return waypointRoot

func _ClearWaypoints() -> void:
	if waypointRoot and is_instance_valid(waypointRoot):
		for c in waypointRoot.get_children():
			c.queue_free()

func _RefreshWaypoints(steps : Array) -> void:
	_ClearWaypoints()
	var root : Node2D = _EnsureWaypointRoot()
	if root == null or Launcher.Map == null:
		return
	var currentMap : int = Launcher.Map.currentMapID
	for step in steps:
		if int(step.get("map_id", DB.UnknownHash)) != currentMap:
			continue
		if not step.get("resolved", false):
			continue
		var marker : Node2D = _MakeWaypoint(step)
		root.add_child(marker)
		marker.position = step.get("position", Vector2.ZERO)
		_PulseWaypoint(marker)

func _UpdateWaypointPositions(steps : Array) -> void:
	if waypointRoot == null or not is_instance_valid(waypointRoot):
		return
	if Launcher.Map == null:
		return
	var currentMap : int = Launcher.Map.currentMapID
	var i : int = 0
	for step in steps:
		if int(step.get("map_id", DB.UnknownHash)) != currentMap:
			continue
		if not step.get("resolved", false):
			continue
		if i >= waypointRoot.get_child_count():
			break
		var child : Node2D = waypointRoot.get_child(i) as Node2D
		if child:
			child.position = step.get("position", child.position)
		i += 1

func _MakeWaypoint(step : Dictionary) -> Node2D:
	var root : Node2D = Node2D.new()
	root.name = "WP_%s" % str(step.get("quest_id", 0))

	var ring : Polygon2D = Polygon2D.new()
	ring.color = _ActionColor(int(step.get("action", 0)))
	ring.polygon = PackedVector2Array([
		Vector2(-10, -4), Vector2(0, -18), Vector2(10, -4),
		Vector2(6, -4), Vector2(6, 6), Vector2(-6, 6), Vector2(-6, -4),
	])
	root.add_child(ring)

	var label : Label = Label.new()
	label.text = str(step.get("nick", "?"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-48, -36)
	label.custom_minimum_size = Vector2(96, 14)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("outline_size", 3)
	root.add_child(label)
	return root

func _PulseWaypoint(marker : Node2D) -> void:
	if marker == null or not is_instance_valid(marker) or not marker.is_inside_tree():
		return
	var ring : Polygon2D = marker.get_child(0) as Polygon2D
	if ring == null:
		return
	var pulse : Tween = marker.create_tween().set_loops()
	pulse.tween_property(ring, "modulate:a", 0.45, 0.7)
	pulse.tween_property(ring, "modulate:a", 1.0, 0.7)

func _ActionColor(action : int) -> Color:
	match action:
		QuestGuidanceClass.Action.KILL:
			return Color(1.0, 0.35, 0.25, 0.9)
		QuestGuidanceClass.Action.GATHER:
			return Color(0.35, 0.9, 0.45, 0.9)
		QuestGuidanceClass.Action.RETURN:
			return Color(1.0, 0.85, 0.2, 0.95)
		QuestGuidanceClass.Action.TALK:
			return Color(0.35, 0.75, 1.0, 0.95)
		_:
			return Color(0.9, 0.9, 1.0, 0.9)
