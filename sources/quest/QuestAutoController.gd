extends Node
class_name QuestAutoController

## Client-side auto quest: path → interact → auto-advance dialogue & pick choices.
## Toggle from Progress window. Does not cheat-complete quests (rewards still via NPC/combat).

const QuestGuidanceClass = preload("res://sources/quest/QuestGuidance.gd")

var enabled : bool = false
var _tick : float = 0.0
var _lastNotifyMap : int = DB.UnknownHash
var _preferQuestID : int = DB.UnknownHash
var _lastChoiceAt : float = 0.0

const TICK_SEC : float = 0.45
const DIALOGUE_TICK_SEC : float = 0.28
const INTERACT_RANGE : float = 160.0
const CHOICE_COOLDOWN_SEC : float = 0.35

## Prefer quest-progress lines; avoid farewell / decline.
const AVOID_CHOICE_KEYS : PackedStringArray = [
	"cáo từ", "cao tu", "hẹn gặp", "hen gap", "để lần khác", "de lan khac",
	"đi ngang", "di ngang", "thêm thời gian", "them thoi gian", "không cần",
	"khong can", "từ chối", "tu choi", "thôi", "thoi", "đóng", "dong",
	"hủy", "huy", "cancel", "farewell", "goodbye", "later",
]

const PREFER_CHOICE_KEYS : PackedStringArray = [
	"nhận", "nhan", "đồng ý", "dong y", "giúp", "giup", "xin", "khảo", "khao",
	"hoàn tất", "hoan tat", "giao", "mang", "đủ", "du ", "tiếp", "tiep",
	"chỉ điểm", "chi diem", "làm", "lam", "accept", "quest", "nhiệm vụ",
]

func SetEnabled(on : bool) -> void:
	enabled = on
	_tick = 0.0
	_lastNotifyMap = DB.UnknownHash
	_lastChoiceAt = 0.0
	if Launcher.GUI and Launcher.GUI.notificationLabel:
		if on:
			Launcher.GUI.notificationLabel.AddNotification("Auto nhiệm vụ: BẬT — tìm đường, tương tác & tự chọn đối thoại.")
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
	var need : float = DIALOGUE_TICK_SEC if _IsDialogueOpen() else TICK_SEC
	if _tick < need:
		return
	_tick = 0.0
	_Step()

func _IsDialogueOpen() -> bool:
	return Launcher.GUI != null and Launcher.GUI.IsDialogueContextOpened()

func _Step() -> void:
	# 1) Dialogue first — continue text / pick choice before walking again
	if _TryAdvanceDialogue():
		return

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

## Advance dialogue UI: finish typewriter → Continue → pick best choice.
func _TryAdvanceDialogue() -> bool:
	if Launcher.GUI == null or not Launcher.GUI.IsDialogueContextOpened():
		return false
	var dialogue = Launcher.GUI.dialoguePanel
	if dialogue == null:
		return false

	# Finish typewriter so Continue / choices appear
	if dialogue.get("lastTween") and dialogue.lastTween:
		dialogue.lastTween.custom_step(INF)
		return true

	var choiceMenu = Launcher.GUI.choiceContext
	if choiceMenu and choiceMenu.is_visible() and choiceMenu.contextList and choiceMenu.contextList.get_child_count() > 0:
		return _PickDialogueChoice(choiceMenu)

	# "Tiếp tục" / continue button
	if dialogue.button and dialogue.button.is_visible():
		var btnText : String = str(dialogue.buttonLabel.get_text()) if dialogue.buttonLabel else ""
		var lower : String = btnText.to_lower()
		if lower.contains("tiếp") or lower.contains("tiep") or lower == "continue" or lower.contains("next"):
			dialogue.ButtonPressed()
			return true
		# "Đóng" — only if no active quest progress needed; still click to clear stuck UI
		if lower.contains("đóng") or lower.contains("dong") or lower == "close":
			dialogue.ButtonPressed()
			return true

	return false

func _PickDialogueChoice(choiceMenu : ContextMenu) -> bool:
	var now : float = Time.get_ticks_msec() / 1000.0
	if now - _lastChoiceAt < CHOICE_COOLDOWN_SEC:
		return true
	var bestIdx : int = -1
	var bestScore : int = -9999
	var children : Array = choiceMenu.contextList.get_children()
	for i in children.size():
		var child = children[i]
		var title : String = ""
		if child.get("_data") and child._data:
			title = str(child._data._title)
		elif child.has_node("Label"):
			title = str(child.get_node("Label").get_text())
		var score : int = _ScoreChoice(title, i)
		if score > bestScore:
			bestScore = score
			bestIdx = i
	if bestIdx < 0:
		bestIdx = 0
	_lastChoiceAt = now
	# Prefer calling the bound callback (hides menu) — same as player pressing the tip key
	var pick = children[bestIdx]
	if pick and pick.has_method("_on_trigger"):
		pick._on_trigger()
	else:
		Network.TriggerChoice(bestIdx)
		choiceMenu.Hide()
	return true

func _ScoreChoice(title : String, index : int) -> int:
	var t : String = title.to_lower()
	var score : int = 10 - index  # slight preference for earlier options
	for key in AVOID_CHOICE_KEYS:
		if t.contains(key):
			score -= 50
	for key in PREFER_CHOICE_KEYS:
		if t.contains(key):
			score += 25
	return score

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
