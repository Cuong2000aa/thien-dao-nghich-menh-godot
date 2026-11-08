extends Node
class_name QuestAutoController

signal auto_toggled(enabled : bool)

## Client-side auto quest: path → interact → auto-advance dialogue & pick choices.
## Toggle from Progress window. Does not cheat-complete quests (rewards still via NPC/combat).

const QuestGuidanceClass = preload("res://sources/quest/QuestGuidance.gd")

var enabled : bool = false
var _tick : float = 0.0
var _lastNotifyMap : int = DB.UnknownHash
var _preferQuestID : int = DB.UnknownHash
var _lastChoiceAt : float = 0.0
var _lastNpcTalkAt : float = 0.0
var _lastNpcNick : String = ""
var _killProgressCheckAt : float = 0.0
## Local kill tallies for current auto session: entityName → count
var _killCounts : Dictionary = {}
var _killQuestID : int = DB.UnknownHash
var _noTargetSince : float = 0.0
var _lastPickedChoice : String = ""
var _sameChoiceStreak : int = 0
var _dialogueStuckTicks : int = 0
## questID|state|nick → true after a finished talk (advance to next_do)
var _talkedKeys : Dictionary = {}
var _lastWarpAt : float = 0.0
var _wasInDialogue : bool = false
var _dialogueQuestID : int = DB.UnknownHash
var _dialogueQuestState : int = ProgressCommons.UnknownProgress
var _pendingInteractNick : String = ""
var _lastPos : Vector2 = Vector2.ZERO
var _stuckTicks : int = 0
var _currentAutoStatus : String = ""
var _lastEngagedTargetPos : Vector2 = Vector2.ZERO
var _lastAttackAt : float = 0.0

const TICK_SEC : float = 0.25
const DIALOGUE_TICK_SEC : float = 0.08
const INTERACT_RANGE : float = 280.0
const KILL_RANGE : float = 520.0
const CHOICE_COOLDOWN_SEC : float = 0.10
const NPC_REINTERACT_COOLDOWN_SEC : float = 1.5
const KILL_PROGRESS_CHECK_SEC : float = 6.0
const NO_TARGET_RETURN_SEC : float = 4.0
const DIALOGUE_STUCK_TICKS : int = 3
const WARP_COOLDOWN_SEC : float = 1.2
const SAME_MAP_WARP_DIST : float = 500.0

## Decline / leave early — avoid while accepting a quest.
const AVOID_CHOICE_KEYS : PackedStringArray = [
	"cáo từ", "cao tu", "hẹn gặp", "hen gap", "để lần khác", "de lan khac",
	"đi ngang", "di ngang", "thêm thời gian", "them thoi gian", "không cần",
	"khong can", "từ chối", "tu choi", "rời đi", "roi di", "để sau", "de sau",
	"hẹn gặp lại", "hen gap lai", "ngươi là ai", "nguoi la ai", "chuyện cũ", "chuyen cu",
	"hủy", "huy", "cancel", "goodbye", "later",
	# Lore / reminder loops (Ekinu / Gilgames gate menus)
	"nhắc lại", "nhac lai", "kể về", "ke ve", "red queen", "nguy hiểm thì",
	"nguy hiem thi", "mạnh hơn", "manh hon", "lạc đường thì", "lac duong",
	"truy cập đồ", "truy cap do", "sao phải đi hướng", "cha nàng",
	# Mana Tree lore loops (ManaTree.gd OnTreeBranch & OnWhatNext)
	"sống sót dưới đây thế nào", "song sot duoi day",
	"sao ngươi lại ở hang này", "ở hang này", "o hang nay",
	"từ đó đến nay", "tu do den nay",
	"ngươi biết gì về hắn", "nguoi biet gi ve han",
]

## Quest progress accept / continue.
const PREFER_CHOICE_KEYS : PackedStringArray = [
	"nhận", "nhan", "đồng ý", "dong y", "giúp", "giup", "xin", "khảo", "khao",
	"khảo nghiệm", "khao nghiem", "bắt đầu", "bat dau", "gia nhập", "gia nhap",
	"hoàn tất", "hoan tat", "giao", "mang", "đủ", "du ", "tiếp", "tiep",
	"chỉ điểm", "chi diem", "accept", "quest", "nhiệm vụ", "nhiem vu",
	"giết", "giet", "ngay", "kael bảo", "làm tốt", "thám hiểm",
	"ta phải làm gì?", # first-time job ask (exact-ish); "nhắc lại" is avoided above
	"đi gặp", "di gap", "ryan", "tệ hại", "te hai", "ta làm", "ta lam",
	"bái kiến", "bai kien", "xin chỉ giáo", "xin chi giao", "luyện đan", "luyen dan",
	"thảo phạt", "thao phat", "tuần tra", "tuan tra", "tiếp nhận", "tiep nhan",
	"đi ngay", "di ngay", "xuất phát", "xuat phat", "đưa", "dua", "trao",
	"được, ta đi", "duoc, ta di", "ta đi", "ta di",
	# Mana Tree dialogue progression (ManaTree.gd)
	"ngươi... là cây", "nguoi... la cay", "ngươi là cây", "nguoi la cay",
	"giờ ta nên làm gì", "gio ta nen lam gi", "nên làm gì", "nen lam gi",
	"ta sẽ đến gặp", "ta se den gap", "đến gặp nina", "den gap nina",
	"gặp nina", "gap nina",
	# Ryan turn-in & Nickos dialog
	"tầng dưới ngập nước", "tang duoi ngap nuoc", "ngập nước", "ngap nuoc",
	"hắn còn sống", "han con song", "choáng váng", "choang vang",
	"tuần phòng ryan cử", "tuan phong ryan cu", "chuyện gì đã xảy ra", "chuyen gi da xay ra",
	"ngươi thấy hắn đi đâu", "nguoi thay han di dau",
	# Nina & Hommer Desert Seed
	"cậu sẽ không tin", "cau se khong tin", "tìm thấy cái này", "tim thay cai nay",
	"có cây mana", "co cay mana", "cây mana đáy mỏ", "cay mana day mo",
	"nó bảo mang đến ngươi", "no bao mang den nguoi",
	"nina ở tulimshar cử", "nina o tulimshar cu", "nina cử ta đến", "nina cu ta den",
	"nina bảo có thể tin", "nina bao co the tin", "là gì", "la gi",
]

## End conversation / leave NPC after objective done (Gilgames "Ổn hết!", Ekinu "đi thôi").
const EXIT_CHOICE_KEYS : PackedStringArray = [
	"đi thôi", "di thoi", "ổn hết", "on het", "ta đi", "ta di",
	"được, ta đi", "duoc, ta di", "cảm ơn. ta đi", "farewell",
	"thôi, ta tưởng", "giữ tinh thần",
	"đi gặp ryan", "di gap ryan", "gặp ryan", "gap ryan",
	"ta sẽ đến gặp nina", "đến gặp nina",
]

func QueueInteractionWithNick(nick : String) -> void:
	_pendingInteractNick = nick
	_lastNpcNick = ""
	_lastNpcTalkAt = 0.0

func SetAutoStatus(text : String) -> void:
	if _currentAutoStatus == text:
		return
	_currentAutoStatus = text
	if Launcher.GUI and Launcher.GUI.notificationLabel and enabled:
		Launcher.GUI.notificationLabel.AddNotification("⚡ [AUTO] " + text)

func SetEnabled(on : bool) -> void:
	enabled = on
	_tick = TICK_SEC if on else 0.0
	_lastNotifyMap = DB.UnknownHash
	_lastChoiceAt = 0.0
	_lastNpcTalkAt = 0.0
	_lastNpcNick = ""
	_killProgressCheckAt = 0.0
	_killCounts.clear()
	_killQuestID = DB.UnknownHash
	_noTargetSince = 0.0
	_lastPickedChoice = ""
	_sameChoiceStreak = 0
	_dialogueStuckTicks = 0
	_talkedKeys.clear()
	_lastWarpAt = 0.0
	_wasInDialogue = false
	_dialogueQuestID = DB.UnknownHash
	_dialogueQuestState = ProgressCommons.UnknownProgress
	_pendingInteractNick = ""
	_lastPos = Vector2.ZERO
	_stuckTicks = 0
	_currentAutoStatus = ""
	_lastEngagedTargetPos = Vector2.ZERO
	if on:
		if _preferQuestID == DB.UnknownHash:
			_preferQuestID = _ResolveActiveQuest()
		SetAutoStatus("Auto nhiệm vụ: ĐÃ BẬT")
	else:
		SetAutoStatus("Auto nhiệm vụ: ĐÃ TẮT")
	if Launcher.GUI and Launcher.GUI.notificationLabel:
		if on:
			Launcher.GUI.notificationLabel.AddNotification("Auto nhiệm vụ: BẬT — Tự bay, tự nhận & trả chuỗi nhiệm vụ.")
		else:
			Launcher.GUI.notificationLabel.AddNotification("Auto nhiệm vụ: TẮT.")
	auto_toggled.emit(enabled)
	if on:
		call_deferred("_Step")

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

func _IsPlayerInCombat() -> bool:
	if Launcher.Player == null:
		return false
	if Launcher.Player.state == ActorCommons.State.ATTACK:
		return true
	if Entities.target != null and is_instance_valid(Entities.target):
		if Entities.target.type == ActorCommons.Type.MONSTER and ActorCommons.IsAlive(Entities.target):
			return true
	return false

func _Step() -> void:
	if Entities.target != null and (not is_instance_valid(Entities.target) or not ActorCommons.IsAlive(Entities.target)):
		Entities.ClearTarget()

	var inDialogue : bool = _IsDialogueOpen()
	if _wasInDialogue and not inDialogue:
		_OnDialogueClosed()
	_wasInDialogue = inDialogue
	if _TryAdvanceDialogue():
		return

	# 1. Hàng đợi tương tác ưu tiên (ví dụ vừa bay tới trước mặt NPC mới)
	if not _pendingInteractNick.is_empty():
		var pendingEnt : Entity = _FindEntityByNick(_pendingInteractNick, false, INTERACT_RANGE * 1.5)
		if pendingEnt:
			_lastNpcNick = _pendingInteractNick
			_lastNpcTalkAt = Time.get_ticks_msec() / 1000.0
			_pendingInteractNick = ""
			Entities.InteractHovered(pendingEnt)
			return

	# 2. Xử lý nhiệm vụ ưu tiên được chọn (chưa nhận -> tới gặp NPC nhận, đã nhận -> tiếp tục làm)
	if _preferQuestID != DB.UnknownHash and Launcher.Player and Launcher.Player.progress:
		var preferSt : int = Launcher.Player.progress.GetQuest(_preferQuestID)
		if preferSt >= ProgressCommons.CompletedProgress:
			_preferQuestID = DB.UnknownHash
		elif preferSt <= ProgressCommons.UnknownProgress:
			var startStep : Dictionary = QuestGuidanceClass.BuildStartStep(_preferQuestID)
			if startStep.get("resolved", false):
				SetAutoStatus("Bay tới gặp [%s] nhận nhiệm vụ [%s]" % [str(startStep.get("nick", "")), str(startStep.get("quest_name", ""))])
				if _EnsureNearObjective(startStep):
					_pendingInteractNick = str(startStep.get("nick", ""))
					var ent : Entity = _FindEntityByNick(_pendingInteractNick, false, INTERACT_RANGE * 1.5)
					if ent:
						_lastNpcNick = _pendingInteractNick
						_lastNpcTalkAt = Time.get_ticks_msec() / 1000.0
						_pendingInteractNick = ""
						Entities.InteractHovered(ent)
					return
				_DoTalkStep(str(startStep.get("nick", "")), startStep.get("position", Vector2.ZERO))
				return
			else:
				_preferQuestID = DB.UnknownHash

	var questID : int = _ResolveActiveQuest()
	if questID == DB.UnknownHash:
		# Không còn active quest -> Tự động tìm nhiệm vụ tiếp theo trong chuỗi hoặc game
		var nextAvailable : int = QuestGuidanceClass.FindNextAvailableQuest()
		if nextAvailable != DB.UnknownHash:
			_preferQuestID = nextAvailable
			var startStep : Dictionary = QuestGuidanceClass.BuildStartStep(nextAvailable)
			if startStep.get("resolved", false):
				SetAutoStatus("Bay tới gặp [%s] nhận nhiệm vụ mới [%s]" % [str(startStep.get("nick", "")), str(startStep.get("quest_name", ""))])
				if _EnsureNearObjective(startStep):
					_pendingInteractNick = str(startStep.get("nick", ""))
					var ent : Entity = _FindEntityByNick(_pendingInteractNick, false, INTERACT_RANGE * 1.5)
					if ent:
						_lastNpcNick = _pendingInteractNick
						_lastNpcTalkAt = Time.get_ticks_msec() / 1000.0
						_pendingInteractNick = ""
						Entities.InteractHovered(ent)
					return
				_DoTalkStep(str(startStep.get("nick", "")), startStep.get("position", Vector2.ZERO))
				return
		SetAutoStatus("Đã hoàn thành toàn bộ chuỗi nhiệm vụ khả dụng.")
		return

	var state : int = Launcher.Player.progress.GetQuest(questID) if Launcher.Player.progress else ProgressCommons.UnknownProgress
	if state <= ProgressCommons.UnknownProgress or state >= ProgressCommons.CompletedProgress:
		# Current done — hop to next active quest if any
		_preferQuestID = DB.UnknownHash
		questID = _ResolveActiveQuest()
		if questID == DB.UnknownHash:
			var nextAvail : int = QuestGuidanceClass.FindNextAvailableQuest()
			if nextAvail != DB.UnknownHash:
				_preferQuestID = nextAvail
				var sStep : Dictionary = QuestGuidanceClass.BuildStartStep(nextAvail)
				if sStep.get("resolved", false):
					SetAutoStatus("Bay tới gặp [%s] nhận nhiệm vụ [%s]" % [str(sStep.get("nick", "")), str(sStep.get("quest_name", ""))])
					if _EnsureNearObjective(sStep):
						_pendingInteractNick = str(sStep.get("nick", ""))
						var ent : Entity = _FindEntityByNick(_pendingInteractNick, false, INTERACT_RANGE * 1.5)
						if ent:
							_lastNpcNick = _pendingInteractNick
							_lastNpcTalkAt = Time.get_ticks_msec() / 1000.0
							_pendingInteractNick = ""
							Entities.InteractHovered(ent)
						return
					_DoTalkStep(str(sStep.get("nick", "")), sStep.get("position", Vector2.ZERO))
			return
		state = Launcher.Player.progress.GetQuest(questID) if Launcher.Player.progress else ProgressCommons.UnknownProgress
		if state <= ProgressCommons.UnknownProgress or state >= ProgressCommons.CompletedProgress:
			return

	if questID != _killQuestID:
		_killCounts.clear()
		_killQuestID = questID
		_noTargetSince = 0.0

	var step : Dictionary = QuestGuidanceClass.BuildStep(questID, state)
	if step.is_empty() or not step.get("resolved", false):
		return
	step = _ApplyTalkAdvance(questID, state, step)
	if step.is_empty() or not step.get("resolved", false):
		return

	_dialogueQuestID = questID
	_dialogueQuestState = state

	var mapID : int = int(step.get("map_id", DB.UnknownHash))
	var targetPos : Vector2 = step.get("position", Vector2.ZERO)
	var nick : String = str(step.get("nick", ""))
	var action : int = int(step.get("action", QuestGuidanceClass.Action.UNKNOWN))

	# Cập nhật trạng thái hiển thị
	var qData : QuestData = DB.GetQuest(questID)
	var qName : String = Localization.Get(qData.name, qData.name) if qData else str(questID)
	match action:
		QuestGuidanceClass.Action.TALK:
			SetAutoStatus("Gặp [%s] (NV: %s)" % [nick, qName])
		QuestGuidanceClass.Action.RETURN:
			SetAutoStatus("Hoàn thành! Trở về gặp [%s] trả [%s]" % [nick, qName])
		QuestGuidanceClass.Action.KILL:
			SetAutoStatus("Đang săn diệt mục tiêu [%s] (%s)" % [nick, qName])
		QuestGuidanceClass.Action.GATHER:
			SetAutoStatus("Đang thu thập [%s] (%s)" % [nick, qName])

	# Chống kẹt địa hình
	if Launcher.Player:
		var curPos : Vector2 = Launcher.Player.position
		if _IsPlayerInCombat() or _IsDialogueOpen():
			_stuckTicks = 0
		elif _lastPos != Vector2.ZERO and curPos.distance_to(targetPos) > 64.0:
			if curPos.distance_to(_lastPos) < 4.0:
				_stuckTicks += 1
				if _stuckTicks >= 16:
					_stuckTicks = 0
					_WarpToStep(step, "Auto NV: Gỡ kẹt — bay thẳng tới mục tiêu.")
			else:
				_stuckTicks = 0
		else:
			_stuckTicks = 0
		_lastPos = curPos

	# Fly/warp to objective map or far same-map points (no more “đứng không biết làm gì”).
	if _EnsureNearObjective(step):
		return

	var returnNick : String = str(step.get("return_nick", ""))

	# If kill quota is already satisfied, advance directly to return NPC (avoid wandering or rubberbanding)
	if action == QuestGuidanceClass.Action.KILL:
		var killTargets : Array = step.get("kill_targets", [])
		var need : int = maxi(1, int(step.get("need", 1)))
		var needEach : bool = bool(step.get("need_each", false))
		var quotaMet : bool = _KillQuotaMet(killTargets, need, needEach) or _HasTurnItems(step.get("turn_items", []))
		if quotaMet and not returnNick.is_empty():
			var npcStep : Dictionary = QuestGuidanceClass.BuildNickStep(returnNick, step)
			if npcStep.get("resolved", false):
				if _EnsureNearObjective(npcStep):
					return
				_DoTalkStep(returnNick, npcStep.get("position", targetPos))
				return

	match action:
		QuestGuidanceClass.Action.TALK, QuestGuidanceClass.Action.RETURN:
			_DoTalkStep(nick, targetPos)
		QuestGuidanceClass.Action.KILL:
			_DoKillStep(step, targetPos, returnNick)
		_:
			if Launcher.Player.position.distance_to(targetPos) > 48.0:
				Launcher.Action.MoveTo(targetPos)

func _TalkKey(questID : int, state : int, nick : String) -> String:
	return "%d|%d|%s" % [questID, state, nick]

func _HasTalked(questID : int, state : int, nick : String) -> bool:
	return bool(_talkedKeys.get(_TalkKey(questID, state, nick), false))

func _MarkTalked(questID : int, state : int, nick : String) -> void:
	if nick.is_empty() or questID == DB.UnknownHash:
		return
	_talkedKeys[_TalkKey(questID, state, nick)] = true

func _OnDialogueClosed() -> void:
	if _lastNpcNick.is_empty():
		return
	_MarkTalked(_dialogueQuestID, _dialogueQuestState, _lastNpcNick)
	# Immediately fly to next_do if this talk phase has a follow-up.
	var step : Dictionary = QuestGuidanceClass.BuildStep(_dialogueQuestID, _dialogueQuestState)
	if step.is_empty():
		return
	var nextNick : String = str(step.get("next_nick", ""))
	if nextNick.is_empty():
		return
	if str(step.get("nick", "")) != _lastNpcNick and not _HasTalked(_dialogueQuestID, _dialogueQuestState, str(step.get("nick", ""))):
		return
	var nextStep : Dictionary = QuestGuidanceClass.BuildNickStep(nextNick, step)
	if nextStep.get("resolved", false):
		_WarpToStep(nextStep, "Auto NV: bay tới [%s]." % nextNick)

func _ApplyTalkAdvance(questID : int, state : int, step : Dictionary) -> Dictionary:
	var nick : String = str(step.get("nick", ""))
	var nextNick : String = str(step.get("next_nick", ""))
	if nextNick.is_empty() or nick.is_empty():
		return step
	if not _HasTalked(questID, state, nick):
		return step
	# Already finished this talk NPC → chase next objective (e.g. Dausen → Ryan).
	var advanced : Dictionary = QuestGuidanceClass.BuildNickStep(nextNick, step)
	if advanced.get("resolved", false):
		advanced["action"] = step.get("action", QuestGuidanceClass.Action.TALK)
		# If next is a kill target name, switch action
		var killTargets : Array = step.get("kill_targets", [])
		for t in killTargets:
			if str(t) == nextNick:
				advanced["action"] = QuestGuidanceClass.Action.KILL
				break
		return advanced
	return step

func _EnsureNearObjective(step : Dictionary) -> bool:
	if Launcher.Player == null or Launcher.Map == null:
		return false
	var mapID : int = int(step.get("map_id", DB.UnknownHash))
	var targetPos : Vector2 = step.get("position", Vector2.ZERO)
	var action : int = int(step.get("action", QuestGuidanceClass.Action.UNKNOWN))

	# 1. Map switch
	if mapID != DB.UnknownHash and mapID != Launcher.Map.currentMapID:
		return _WarpToStep(step, "Auto NV: bay tới [%s]." % str(step.get("map_display", mapID)))

	# 2. Never warp on same map while actively fighting or in dialogue
	if _IsPlayerInCombat() or _IsDialogueOpen():
		return false

	# 3. For KILL and GATHER objectives, the hunting ground is large (e.g. cactus farm).
	# Warp if player is farther than 420.0px from the hunting ground
	if action == QuestGuidanceClass.Action.KILL or action == QuestGuidanceClass.Action.GATHER:
		if targetPos != Vector2.ZERO and Launcher.Player.position.distance_to(targetPos) > 420.0:
			return _WarpToStep(step, "Auto NV: bay tới bãi quái.")
		return false

	# 4. For TALK / RETURN objectives: warp if far from target
	if targetPos != Vector2.ZERO and Launcher.Player.position.distance_to(targetPos) > SAME_MAP_WARP_DIST:
		return _WarpToStep(step, "Auto NV: bay tới mục tiêu.")
	return false

func _WarpToStep(step : Dictionary, notify : String = "") -> bool:
	var now : float = Time.get_ticks_msec() / 1000.0
	if now - _lastWarpAt < WARP_COOLDOWN_SEC:
		return true
	if QuestGuidanceClass.WarpLocalPlayerToStep(step, notify):
		_lastWarpAt = now
		_lastNotifyMap = int(step.get("map_id", DB.UnknownHash))
		return true
	# Fallback: notify manual travel if warp unavailable
	var mapID : int = int(step.get("map_id", DB.UnknownHash))
	if mapID != DB.UnknownHash and _lastNotifyMap != mapID:
		_lastNotifyMap = mapID
		if Launcher.GUI and Launcher.GUI.notificationLabel:
			Launcher.GUI.notificationLabel.AddNotification("Auto NV: hãy tới [%s]." % str(step.get("map_display", mapID)))
	return mapID != DB.UnknownHash and Launcher.Map and mapID != Launcher.Map.currentMapID

func _DoTalkStep(nick : String, targetPos : Vector2) -> void:
	var now : float = Time.get_ticks_msec() / 1000.0
	if nick == _lastNpcNick and (now - _lastNpcTalkAt) < NPC_REINTERACT_COOLDOWN_SEC:
		return
	var targetEnt : Entity = _FindEntityByNick(nick, false, 1500.0)
	# Proximity fallback for tile-based / invisible NPCs (e.g. Mana Tree)
	if targetEnt == null and targetPos != Vector2.ZERO:
		targetEnt = _FindEntityNearPosition(targetPos, INTERACT_RANGE, false)
	if targetEnt:
		var d : float = Launcher.Player.position.distance_to(targetEnt.position)
		if d <= INTERACT_RANGE:
			_lastNpcNick = nick
			_lastNpcTalkAt = now
			Entities.InteractHovered(targetEnt)
			return
		else:
			Launcher.Action.MoveTo(targetEnt.position)
			return
	if Launcher.Player.position.distance_to(targetPos) > 48.0:
		Launcher.Action.MoveTo(targetPos)
	elif targetEnt == null and Launcher.Player.position.distance_to(targetPos) <= 120.0:
		Entities.JustInteract()

func _DoKillStep(step : Dictionary, targetPos : Vector2, returnNick : String) -> void:
	var killTargets : Array = step.get("kill_targets", [])
	if killTargets.is_empty():
		var n : String = str(step.get("nick", ""))
		var alt : String = str(step.get("alt_nick", ""))
		if not n.is_empty():
			killTargets.append(n)
		if not alt.is_empty():
			killTargets.append(alt)

	# Inventory turn-in (Elanore potion): enough mats → go return NPC
	if _HasTurnItems(step.get("turn_items", [])):
		_GoReturnNpc(returnNick, targetPos)
		return

	# Quest state already OBJECTIVE_MET handled by BuildStep → RETURN.
	# Local / tracker completion for kill quotas:
	var need : int = maxi(1, int(step.get("need", 1)))
	var needEach : bool = bool(step.get("need_each", false))
	if _KillQuotaMet(killTargets, need, needEach):
		_GoReturnNpc(returnNick, targetPos)
		return

	# Only engage monsters that match remaining kill targets — never random mobs.
	var focusTargets : Array = _IncompleteKillTargets(killTargets, need, needEach)
	if focusTargets.is_empty():
		focusTargets = killTargets

	# 1. Retain and maintain engagement on current target if alive & matching
	if _IsMatchingKillTarget(Entities.target, focusTargets):
		_noTargetSince = 0.0
		_MaintainKillTarget(Entities.target)
		return

	# 2. Search nearest matching monster in normal range (520px)
	var targetEnt : Entity = null
	for tName in focusTargets:
		targetEnt = _FindKillTarget(str(tName), KILL_RANGE)
		if targetEnt:
			break

	# 3. If none in 520px, search broader area (up to 1200px across field)
	if targetEnt == null:
		for tName in focusTargets:
			targetEnt = _FindKillTarget(str(tName), 1200.0)
			if targetEnt:
				break

	# 3b. Search any live matching monster in loaded entities on map
	if targetEnt == null:
		for tName in focusTargets:
			targetEnt = _FindKillTarget(str(tName), INF)
			if targetEnt:
				break

	if targetEnt:
		_noTargetSince = 0.0
		_MaintainKillTarget(targetEnt)
		return

	# 4. If no monster found, check if target is currently an NPC (boss waiting for dialogue)
	for tName in focusTargets:
		var npcEnt : Entity = _FindEntityByNick(str(tName), false, 1200.0)
		if npcEnt:
			var d : float = Launcher.Player.position.distance_to(npcEnt.position)
			if d <= INTERACT_RANGE:
				_lastNpcNick = str(tName)
				_lastNpcTalkAt = Time.get_ticks_msec() / 1000.0
				Entities.InteractHovered(npcEnt)
			else:
				Launcher.Action.MoveTo(npcEnt.position)
			return

	# 5. No monsters in view: do NOT return to NPC early!
	# Patrol towards center of hunting zone to await respawns.
	var now : float = Time.get_ticks_msec() / 1000.0
	if _noTargetSince <= 0.0:
		_noTargetSince = now

	# If focus targets are incomplete, patrol towards their spawn position
	var huntPos : Vector2 = targetPos
	if not focusTargets.is_empty():
		var firstFocus : String = str(focusTargets[0])
		var spawns : Array = QuestGuidanceClass.FindSpawns(firstFocus)
		if not spawns.is_empty():
			huntPos = spawns[0].get("position", targetPos)

	if Launcher.Player.position.distance_to(huntPos) > 120.0:
		if Launcher.Player.state != ActorCommons.State.WALK:
			Launcher.Action.MoveTo(huntPos)

func _GoReturnNpc(returnNick : String, fallbackPos : Vector2) -> void:
	var now : float = Time.get_ticks_msec() / 1000.0
	if returnNick.is_empty():
		return
	if returnNick == _lastNpcNick and (now - _lastNpcTalkAt) < NPC_REINTERACT_COOLDOWN_SEC:
		return
	if (now - _killProgressCheckAt) < KILL_PROGRESS_CHECK_SEC and returnNick == _lastNpcNick:
		return
	var returnEnt : Entity = _FindEntityByNick(returnNick, false, INTERACT_RANGE * 3.0)
	if returnEnt:
		_killProgressCheckAt = now
		_lastNpcNick = returnNick
		_lastNpcTalkAt = now
		Entities.InteractHovered(returnEnt)
		return
	# Walk toward return NPC spawn if known via guidance nick index
	var spawns : Array = QuestGuidanceClass.FindSpawns(returnNick)
	if not spawns.is_empty():
		var pos : Vector2 = spawns[0].get("position", fallbackPos)
		if Launcher.Player.position.distance_to(pos) > 48.0:
			Launcher.Action.MoveTo(pos)

func _HasTurnItems(turnItems : Array) -> bool:
	if turnItems.is_empty() or Launcher.Player == null or Launcher.Player.inventory == null:
		return false
	for entry in turnItems:
		if entry is Array and entry.size() >= 2:
			var cell : ItemCell = DB.GetItem(DB.GetCellHash(str(entry[0])))
			if cell == null or not Launcher.Player.inventory.HasItem(cell, int(entry[1])):
				return false
		else:
			return false
	return true

func _KillQuotaMet(killTargets : Array, need : int, needEach : bool) -> bool:
	if killTargets.is_empty():
		return false
	# Tracker complete for the active target + local counts
	var tracker = Launcher.GUI.progressionTracker if Launcher.GUI else null
	if needEach:
		for tName in killTargets:
			if _CountForTarget(str(tName), tracker) < need:
				return false
		return true
	# Single pool: sum counts across targets OR any one reaching need
	var total : int = 0
	for tName in killTargets:
		total += _CountForTarget(str(tName), tracker)
	return total >= need

func _IncompleteKillTargets(killTargets : Array, need : int, needEach : bool) -> Array:
	var out : Array = []
	var tracker = Launcher.GUI.progressionTracker if Launcher.GUI else null
	for tName in killTargets:
		var n : String = str(tName)
		if needEach:
			if _CountForTarget(n, tracker) < need:
				out.append(n)
		else:
			out.append(n)
	if not needEach:
		# Prefer target that tracker currently tracks if incomplete
		if tracker and tracker.has_method("IsComplete") and not tracker.IsComplete():
			for tName in killTargets:
				if tracker.MatchesTarget(str(tName)):
					return [str(tName)]
	return out

func _CountForTarget(tName : String, tracker) -> int:
	var local : int = int(_killCounts.get(tName, 0))
	# Also accept localized / case variants as keys
	for k in _killCounts.keys():
		if str(k).to_lower() == tName.to_lower():
			local = maxi(local, int(_killCounts[k]))
	var fromTracker : int = 0
	if tracker and tracker.has_method("MatchesTarget") and tracker.MatchesTarget(tName):
		fromTracker = int(tracker.lastValue)
	return maxi(local, fromTracker)

func _IsMatchingKillTarget(ent : Entity, focusTargets : Array) -> bool:
	if ent == null or not is_instance_valid(ent):
		return false
	if ent.type != ActorCommons.Type.MONSTER or ent.state == ActorCommons.State.DEATH or not ActorCommons.IsAlive(ent):
		return false
	for tName in focusTargets:
		var n : String = str(tName)
		var expectID : int = n.hash()
		if _MatchesKillNick(ent, n, expectID):
			return true
	return false

func _MaintainKillTarget(ent : Entity) -> void:
	if ent == null or not is_instance_valid(ent) or not ActorCommons.IsAlive(ent):
		_lastEngagedTargetPos = Vector2.ZERO
		if Entities.target == ent:
			Entities.ClearTarget()
		return

	if ent.has_signal("entity_died"):
		if not ent.entity_died.is_connected(_OnKillTargetDied):
			ent.entity_died.connect(_OnKillTargetDied.bind(ent), ConnectFlags.CONNECT_ONE_SHOT)

	var baseAtkRange : float = 32.0
	if Launcher.Player and Launcher.Player.stat and Launcher.Player.stat.current:
		baseAtkRange = maxf(32.0, float(Launcher.Player.stat.current.attackRange))
	var attackRange : float = maxf(72.0, baseAtkRange + 36.0)
	var walkToDistance : int = maxi(36, int(attackRange * 0.55))

	var playerPos : Vector2 = Launcher.Player.position
	var targetPos : Vector2 = ent.position
	var dist : float = playerPos.distance_to(targetPos)
	var inAttackRange : bool = ActorCommons.IsActorNear(Launcher.Player, ent, walkToDistance)

	if Entities.target != ent:
		Entities.SetTarget(ent)

	if inAttackRange or dist <= attackRange:
		# Halt movement so player does not run into colliders or cause client/server position drift
		if Launcher.Player.state == ActorCommons.State.WALK:
			Launcher.Action.MoveTo(playerPos)
			Launcher.Player.velocity = Vector2.ZERO
		if Launcher.Player.has_method("LookAt"):
			Launcher.Player.LookAt(ent)

		var now : float = Time.get_ticks_msec() / 1000.0
		if (now - _lastAttackAt) >= 0.28:
			_lastAttackAt = now
			Entities.Interact()
	else:
		var isWalking : bool = (Launcher.Player.state == ActorCommons.State.WALK)
		var targetMoved : bool = (_lastEngagedTargetPos == Vector2.ZERO or _lastEngagedTargetPos.distance_to(targetPos) > 28.0)
		if not isWalking or targetMoved:
			_lastEngagedTargetPos = targetPos
			var targetPosition : Vector2 = targetPos
			if dist > walkToDistance:
				targetPosition = playerPos + playerPos.direction_to(targetPos) * (dist - walkToDistance)
			Launcher.Action.MoveTo(targetPosition)

func _EngageKillTarget(ent : Entity) -> void:
	_MaintainKillTarget(ent)

func _OnKillTargetDied(ent : Entity) -> void:
	if ent == null:
		return
	var key : String = _EntityKillKey(ent)
	if key.is_empty():
		return
	_killCounts[key] = int(_killCounts.get(key, 0)) + 1
	_lastEngagedTargetPos = Vector2.ZERO
	if Entities.target == ent:
		Entities.ClearTarget()
	if Launcher.GUI and Launcher.GUI.notificationLabel and enabled:
		var needHint : String = ""
		# Light feedback every few kills
		var c : int = int(_killCounts[key])
		if c == 1 or c % 5 == 0:
			Launcher.GUI.notificationLabel.AddNotification("Auto NV: %s %d" % [key, c])

func _EntityKillKey(ent : Entity) -> String:
	if ent == null:
		return ""
	if ent.data and not str(ent.data._name).is_empty():
		return str(ent.data._name)
	return str(ent.nick)

func _FindKillTarget(nick : String, maxRange : float) -> Entity:
	if nick.is_empty() or Launcher.Player == null:
		return null
	var expectID : int = nick.hash()
	var best : Entity = null
	var bestDist : float = maxRange
	for ent in Entities.entities.values():
		if ent == null or ent == Launcher.Player:
			continue
		if ent.type != ActorCommons.Type.MONSTER:
			continue
		if ent.state == ActorCommons.State.DEATH:
			continue
		if not _MatchesKillNick(ent, nick, expectID):
			continue
		var d : float = Launcher.Player.position.distance_to(ent.position)
		if d < bestDist:
			bestDist = d
			best = ent
	return best

func _MatchesKillNick(ent : Entity, nick : String, expectID : int) -> bool:
	if _NickMatches(ent, nick):
		return true
	if ent.data:
		if str(ent.data._name) == nick or str(ent.data._name).to_lower() == nick.to_lower():
			return true
		if ent.data._id == expectID:
			return true
	if ent.stat and ent.stat.currentShape == expectID:
		return true
	return false

## Advance dialogue UI: finish typewriter → Continue → pick best choice.
func _TryAdvanceDialogue() -> bool:
	if Launcher.GUI == null or not Launcher.GUI.IsDialogueContextOpened():
		_dialogueStuckTicks = 0
		return false
	var dialogue = Launcher.GUI.dialoguePanel
	if dialogue == null:
		return false

	# 1. Typewriter fast-forward: finish text animation and yield a tick so buttons / choices mount cleanly
	if dialogue.get("lastTween") and dialogue.lastTween and is_instance_valid(dialogue.lastTween) and dialogue.lastTween.is_running():
		dialogue.lastTween.custom_step(INF)
		_dialogueStuckTicks = 0
		return true

	var choiceMenu = Launcher.GUI.choiceContext
	if choiceMenu and choiceMenu.is_visible() and choiceMenu.contextList and choiceMenu.contextList.get_child_count() > 0:
		_dialogueStuckTicks = 0
		return _PickDialogueChoice(choiceMenu)

	if dialogue.button and dialogue.button.is_visible():
		_dialogueStuckTicks = 0
		var btnText : String = str(dialogue.buttonLabel.get_text()) if dialogue.buttonLabel else ""
		var lower : String = btnText.to_lower()
		if lower.contains("đóng") or lower.contains("dong") or lower == "close":
			dialogue.ButtonPressed()
			_lastNpcTalkAt = Time.get_ticks_msec() / 1000.0
			_lastPickedChoice = ""
			_sameChoiceStreak = 0
			return true
		dialogue.ButtonPressed()
		return true

	# Stuck: panel open but no Continue / choices (HighlightUI / camera beat).
	_dialogueStuckTicks += 1
	if _dialogueStuckTicks >= DIALOGUE_STUCK_TICKS:
		_dialogueStuckTicks = 0
		Network.TriggerNextContext()
		return true
	return true

func _PickDialogueChoice(choiceMenu : ContextMenu) -> bool:
	var now : float = Time.get_ticks_msec() / 1000.0
	if now - _lastChoiceAt < CHOICE_COOLDOWN_SEC:
		return true
	var bestIdx : int = -1
	var bestScore : int = -9999
	var bestTitle : String = ""
	var children : Array = choiceMenu.contextList.get_children()
	var forceExit : bool = _sameChoiceStreak >= 2
	for i in children.size():
		var child = children[i]
		var title : String = ""
		if child.get("_data") and child._data and child._data.get("_title"):
			title = str(child._data._title)
		elif child.has_node("Label"):
			title = str(child.get_node("Label").get_text())
		var score : int = _ScoreChoice(title, i, forceExit)
		# Break loops: heavily penalize repeating the same line
		if not forceExit and title == _lastPickedChoice:
			score -= 80
		if score > bestScore:
			bestScore = score
			bestIdx = i
			bestTitle = title
	if bestIdx < 0:
		bestIdx = 0
		bestTitle = ""
	if bestTitle == _lastPickedChoice:
		_sameChoiceStreak += 1
	else:
		_sameChoiceStreak = 1
		_lastPickedChoice = bestTitle
	_lastChoiceAt = now
	var pick = children[bestIdx] if (bestIdx >= 0 and bestIdx < children.size()) else null
	if pick and pick.get("_data") and pick._data and pick._data.get("_callback") and not pick._data._callback.is_null():
		pick._data._callback.call()
	else:
		Network.TriggerChoice(bestIdx)
	choiceMenu.Hide()
	return true

func _ScoreChoice(title : String, index : int, forceExit : bool = false) -> int:
	var t : String = title.to_lower()
	var score : int = 10 - index
	for key in AVOID_CHOICE_KEYS:
		if t.contains(key):
			score -= 60
	for key in PREFER_CHOICE_KEYS:
		if t.contains(key):
			score += 25
	var isExit : bool = false
	for key in EXIT_CHOICE_KEYS:
		if t.contains(key):
			isExit = true
			# Prefer leaving once quest advanced; strong boost if looping
			score += 40 if forceExit else 15
			break
	# Generic short affirmations that end menus
	if t.contains("ổn") or t.begins_with("được,") or t.begins_with("duoc,"):
		score += 20 if forceExit else 8
		isExit = true
	if forceExit and not isExit:
		score -= 30
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
	if Launcher.GUI and Launcher.GUI.progressWindow and Launcher.GUI.progressWindow.activeQuests:
		for qid in Launcher.GUI.progressWindow.activeQuests.keys():
			return int(qid)
	if QuestGuidanceClass:
		var prim : int = QuestGuidanceClass.FindPrimaryActiveQuest(Launcher.Player)
		if prim != DB.UnknownHash:
			return prim
	return DB.UnknownHash

func _NickMatches(entity : Entity, nick : String) -> bool:
	if entity == null or nick.is_empty():
		return false
	var targetNickLower : String = nick.to_lower()
	var n : String = str(entity.nick) if entity.get("nick") else ""
	if n.is_empty() and entity.data:
		n = str(entity.data._name)
	if n == nick or n.to_lower() == targetNickLower:
		return true
	var locN : String = Localization.Get(n, n)
	if locN == nick or locN.to_lower() == targetNickLower:
		return true
	if Localization.Get(nick, nick).to_lower() == n.to_lower():
		return true
	if entity.data:
		var dn : String = str(entity.data._name)
		if dn == nick or dn.to_lower() == targetNickLower:
			return true
	if QuestGuidanceClass:
		var targetAlias : String = str(QuestGuidanceClass.NAME_ALIASES.get(nick, "")).to_lower()
		if not targetAlias.is_empty() and (n.to_lower() == targetAlias or locN.to_lower() == targetAlias):
			return true
		var entAlias : String = str(QuestGuidanceClass.NAME_ALIASES.get(n, "")).to_lower()
		if not entAlias.is_empty() and (targetNickLower == entAlias or Localization.Get(nick, nick).to_lower() == entAlias):
			return true
	return false

func _FindEntityByNick(nick : String, monstersOnly : bool, maxRange : float) -> Entity:
	if nick.is_empty() or Launcher.Player == null:
		return null
	var best : Entity = null
	var bestDist : float = maxRange
	for ent in Entities.entities.values():
		if ent == null or ent == Launcher.Player:
			continue
		if monstersOnly:
			if ent.type != ActorCommons.Type.MONSTER:
				continue
			if ent.state == ActorCommons.State.DEATH:
				continue
		else:
			if ent.type == ActorCommons.Type.MONSTER:
				continue
		if not _NickMatches(ent, nick):
			continue
		var d : float = Launcher.Player.position.distance_to(ent.position)
		if d < bestDist:
			bestDist = d
			best = ent
	return best

func _FindEntityNearPosition(pos : Vector2, maxDist : float, monstersOnly : bool = false) -> Entity:
	if Launcher.Player == null or Entities.entities.is_empty():
		return null
	var best : Entity = null
	var bestDist : float = maxDist
	for ent in Entities.entities.values():
		if ent == null or ent == Launcher.Player or not is_instance_valid(ent):
			continue
		if monstersOnly and ent.type != ActorCommons.Type.MONSTER:
			continue
		if not monstersOnly and ent.type != ActorCommons.Type.NPC:
			continue
		var d : float = ent.position.distance_to(pos)
		if d < bestDist:
			bestDist = d
			best = ent
	return best
