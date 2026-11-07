extends Node
class_name QuestAutoController

## Client-side auto quest: path to guidance target + interact/attack when in range.
## Toggle from Progress window. Does not cheat-complete quests (rewards still via NPC/combat).

const QuestGuidanceClass = preload("res://sources/quest/QuestGuidance.gd")

var enabled : bool = false
var _tick : float = 0.0
var _lastNotifyMap : int = DB.UnknownHash
var _preferQuestID : int = DB.UnknownHash

const TICK_SEC : float = 0.55
const INTERACT_RANGE : float = 160.0

func SetEnabled(on : bool) -> void:
	enabled = on
	_tick = 0.0
	_lastNotifyMap = DB.UnknownHash
	if Launcher.GUI and Launcher.GUI.notificationLabel:
		if on:
			Launcher.GUI.notificationLabel.AddNotification("Auto nhiệm vụ: BẬT — tự tìm đường & tương tác mục tiêu.")
		else:
			Launcher.GUI.notificationLabel.AddNotification("Auto nhiệm vụ: TẮT.")

func Toggle() -> void:
	SetEnabled(not enabled)

func PreferQuest(questID : int) -> void:
	_preferQuestID = questID

func _process(delta : float) -> void:
	if not enabled:
		return
	if Launcher.Player == null or Launcher.Map == null or Launcher.Action == null:
		return
	if FSM and FSM.has_method("IsGameState") and not FSM.IsGameState():
		return
	_tick += delta
	if _tick < TICK_SEC:
		return
	_tick = 0.0
	_Step()

func _Step() -> void:
	var questID : int = _ResolveActiveQuest()
	if questID == DB.UnknownHash:
		return
	var state : int = Launcher.Player.progress.GetQuest(questID) if Launcher.Player.progress else ProgressCommons.UnknownProgress
	if state <= ProgressCommons.UnknownProgress or state >= ProgressCommons.CompletedProgress:
		return
	var step : Dictionary = QuestGuidanceClass.BuildStep(questID, state)
	if step.is_empty() or not step.get("resolved", false):
		return
	var mapID : int = int(step.get("map_id", DB.UnknownHash))
	var targetPos : Vector2 = step.get("position", Vector2.ZERO)
	var nick : String = str(step.get("nick", ""))

	if mapID != DB.UnknownHash and mapID != Launcher.Map.currentMapID:
		if _lastNotifyMap != mapID:
			_lastNotifyMap = mapID
			var mapName : String = str(step.get("map_display", mapID))
			if Launcher.GUI and Launcher.GUI.notificationLabel:
				Launcher.GUI.notificationLabel.AddNotification("Auto NV: hãy dịch chuyển tới [%s]." % mapName)
		return

	# Prefer live entity with matching nick
	var targetEnt : Entity = _FindEntityByNick(nick)
	if targetEnt:
		Entities.InteractHovered(targetEnt)
		return

	# Walk toward spawn marker
	if Launcher.Player.position.distance_to(targetPos) > 48.0:
		Launcher.Action.MoveTo(targetPos)

func _ResolveActiveQuest() -> int:
	if _preferQuestID != DB.UnknownHash and Launcher.Player and Launcher.Player.progress:
		var st : int = Launcher.Player.progress.GetQuest(_preferQuestID)
		if st > ProgressCommons.UnknownProgress and st < ProgressCommons.CompletedProgress:
			return _preferQuestID
	if Launcher.GUI and Launcher.GUI.progressWindow:
		var cur : int = Launcher.GUI.progressWindow.currentQuest
		if cur != DB.UnknownHash and Launcher.Player and Launcher.Player.progress:
			var st2 : int = Launcher.Player.progress.GetQuest(cur)
			if st2 > ProgressCommons.UnknownProgress and st2 < ProgressCommons.CompletedProgress:
				return cur
	# Fallback: first active in Progress UI dictionary
	if Launcher.GUI and Launcher.GUI.progressWindow and Launcher.GUI.progressWindow.activeQuests:
		for qid in Launcher.GUI.progressWindow.activeQuests.keys():
			return int(qid)
	return DB.UnknownHash

func _FindEntityByNick(nick : String) -> Entity:
	if nick.is_empty() or Launcher.Player == null:
		return null
	var best : Entity = null
	var bestDist : float = INTERACT_RANGE
	for ent in Entities.entities.values():
		if ent == null or ent == Launcher.Player:
			continue
		var n : String = str(ent.nick) if ent.get("nick") else ""
		if n.is_empty() and ent.data:
			n = str(ent.data._name)
		if n != nick and Localization.Get(n, n) != nick:
			continue
		var d : float = Launcher.Player.position.distance_to(ent.position)
		if d < bestDist:
			bestDist = d
			best = ent
	return best
