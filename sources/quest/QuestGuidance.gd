extends RefCounted
class_name QuestGuidance

## Resolves active quest objectives to exact map + world coordinates from MapServerData spawns.
## Prefer live entity positions when the target is already spawned on the current map.

enum Action {
	UNKNOWN = 0,
	TALK = 1,
	KILL = 2,
	GATHER = 3,
	RETURN = 4,
	GO = 5,
}

const ACTION_LABEL : Dictionary = {
	Action.TALK: "Gặp / Nói chuyện",
	Action.KILL: "Tiêu diệt",
	Action.GATHER: "Thu thập",
	Action.RETURN: "Trở về giao nộp",
	Action.GO: "Đến",
	Action.UNKNOWN: "Mục tiêu",
}

## Explicit nick overrides for multi-stage TDNM quests (spawn nick must match MapServerData).
const QUEST_OBJECTIVE : Dictionary = {
	# questID filled at runtime via ProgressCommons.Quest.* — see _EnsureObjectiveTable()
}

static var _nickIndex : Dictionary = {} # nick -> Array[Dictionary]
static var _nicksLongestFirst : PackedStringArray = PackedStringArray()
static var _indexBuilt : bool = false
static var _objectiveTable : Dictionary = {} # questID -> {do, return, kind, need}

static func _EnsureObjectiveTable() -> void:
	if not _objectiveTable.is_empty():
		return
	var Q = ProgressCommons.Quest
	_objectiveTable = {
		Q.THANH_TRU_LINH_TRUNG: {"do": "Linh Trùng", "return": "Đạo Huyền Trưởng Lão", "kind": "kill", "need": 5},
		Q.THU_THAP_LINH_THAO: {"do": "Ngân Linh Thảo", "return": "Đạo Huyền Trưởng Lão", "kind": "gather", "need": 3},
		Q.THU_THAP_KHOANG_THACH: {"do": "Huyền Thiết Khoáng", "return": "Dược Đường Chấp Sự", "kind": "gather", "need": 2},
		Q.CONG_HIEN_DUOC_THAO: {"do": "Ngân Linh Thảo", "return": "Dược Đường Chấp Sự", "kind": "gather", "need": 3},
		Q.CONG_HIEN_KHOANG_THACH: {"do": "Huyền Thiết Khoáng", "return": "Luyện Khí Chấp Sự", "kind": "gather", "need": 2},
		Q.DIET_TRU_MA_VAT: {"do": "Linh Trùng", "return": "Chấp Sự Nhiệm Vụ Đường", "kind": "kill", "need": 3},
		Q.KHAM_PHA_CO_BI: {"do": "Trúc Sơn Cổ Bi", "return": "Đạo Huyền Trưởng Lão", "kind": "talk", "need": 1},
		Q.LUYEN_DAN_NHAP_MON: {"do": "Luyện Đan Lô", "return": "Đạo Huyền Trưởng Lão", "kind": "go", "need": 1},
		Q.NHAP_MON_KHAO_NGHIEM: {"do": "Tiếp Dẫn Chấp Sự", "return": "Đạo Huyền Trưởng Lão", "kind": "talk", "need": 1},
		Q.THAO_PHAT_THU_VUONG: {"do": "Xích Viêm Thú Hậu", "return": "Đạo Huyền Trưởng Lão", "kind": "kill", "need": 1},
		Q.KHAO_HACH_NGOAI_MON: {"do": "Diễn Võ Giáo Đầu", "return": "Đạo Huyền Trưởng Lão", "kind": "talk", "need": 1},
		Q.MQ_CHUONG_1_TINH_LAC_DI_GIOI: {"do": "Tiếp Dẫn Chấp Sự", "return": "Tiếp Dẫn Chấp Sự", "kind": "talk", "need": 1},
		Q.MQ_CHUONG_2_CON_DUONG_TU_DAO: {"do": "Trúc Sơn Cổ Bi", "return": "Đạo Huyền Trưởng Lão", "kind": "talk", "need": 1},
		Q.NQ_HA_THIET_THU_1: {"do": "Huyền Thiết Khoáng", "return": "Hà Thiết Thủ", "kind": "gather", "need": 5},
		Q.NQ_LIEU_THANH_Y_2: {"do": "Tiếp Dẫn Chấp Sự", "return": "Liễu Thanh Y", "kind": "go", "need": 1},
	}

static func InvalidateIndex() -> void:
	_indexBuilt = false
	_nickIndex.clear()
	_nicksLongestFirst = PackedStringArray()

static func RebuildIndex() -> void:
	_nickIndex.clear()
	_nicksLongestFirst = PackedStringArray()
	if not DB.isInitialized:
		_indexBuilt = false
		return
	for mapID in DB.MapsDB:
		var mapData : MapData = DB.MapsDB[mapID]
		if mapData == null or mapData.serverData == null:
			continue
		var mapInternal : String = mapData._name
		var mapDisplay : String = LocationNaming.GetDisplayName(mapData)
		for spawn in mapData.serverData.spawns:
			if spawn == null:
				continue
			var nick : String = spawn.nick.strip_edges()
			if nick.is_empty() and spawn.id != DB.UnknownHash:
				# Soft lookup — some warp/object ids are not in EntitiesDB
				var ent : EntityData = DB.EntitiesDB.get(spawn.id, null)
				if ent:
					nick = ent._name
			if nick.is_empty():
				continue

			var entry : Dictionary = {
				"nick": nick,
				"map_id": mapID,
				"map_internal": mapInternal,
				"map_display": mapDisplay,
				"position": Vector2(spawn.spawn_position),
				"offset": Vector2(spawn.spawn_offset),
				"type": spawn.type,
				"count": spawn.count,
				"entity_id": spawn.id,
			}
			if not _nickIndex.has(nick):
				_nickIndex[nick] = []
			_nickIndex[nick].append(entry)
	var keys : Array = _nickIndex.keys()
	keys.sort_custom(func(a, b): return str(a).length() > str(b).length())
	for k in keys:
		_nicksLongestFirst.append(str(k))
	_indexBuilt = true

static func EnsureIndex() -> void:
	if not _indexBuilt:
		RebuildIndex()
	_EnsureObjectiveTable()

static func FindSpawns(nick : String) -> Array:
	EnsureIndex()
	if nick.is_empty():
		return []
	if _nickIndex.has(nick):
		return _nickIndex[nick]
	# Case-insensitive / partial: exact nick first among longest-first
	var lower : String = nick.to_lower()
	for key in _nicksLongestFirst:
		if key.to_lower() == lower:
			return _nickIndex[key]
	for key in _nicksLongestFirst:
		if key.to_lower().contains(lower) or lower.contains(key.to_lower()):
			return _nickIndex[key]
	return []

static func MatchNickInText(text : String) -> String:
	EnsureIndex()
	if text.is_empty():
		return ""
	for nick in _nicksLongestFirst:
		if text.contains(nick):
			return nick
	return ""

static func ResolveLivePosition(nick : String, preferMapID : int = DB.UnknownHash) -> Vector2:
	if nick.is_empty() or Entities.entities.is_empty():
		return Vector2.INF
	var sum : Vector2 = Vector2.ZERO
	var count : int = 0
	for entity in Entities.entities.values():
		if entity == null or not is_instance_valid(entity):
			continue
		if entity.nick != nick:
			continue
		if preferMapID != DB.UnknownHash and Launcher.Map and Launcher.Map.currentMapID != preferMapID:
			continue
		sum += entity.position
		count += 1
	if count > 0:
		return sum / float(count)
	return Vector2.INF

static func IsReadyToTurnIn(questID : int, state : int) -> bool:
	if state <= ProgressCommons.UnknownProgress or state >= ProgressCommons.CompletedProgress:
		return false
	_EnsureObjectiveTable()
	# Explicit counters: STARTED=1 … OBJECTIVE_MET = need+1 for most TDNM quests
	var override : Dictionary = _objectiveTable.get(questID, {})
	if not override.is_empty():
		var need : int = maxi(1, int(override.get("need", 1)))
		if state > need:
			return true
	# Named state constants (direct enum access — .get on enum Variant is unreliable)
	match questID:
		ProgressCommons.Quest.THANH_TRU_LINH_TRUNG:
			return state >= ProgressCommons.THANH_TRU_LINH_TRUNG.OBJECTIVE_MET
		ProgressCommons.Quest.THU_THAP_LINH_THAO:
			return state >= ProgressCommons.THU_THAP_LINH_THAO.OBJECTIVE_MET
		ProgressCommons.Quest.THAO_PHAT_THU_VUONG:
			return state >= ProgressCommons.THAO_PHAT_THU_VUONG.BOSS_SLAIN
		ProgressCommons.Quest.KHAO_HACH_NGOAI_MON:
			return state >= ProgressCommons.KHAO_HACH_NGOAI_MON.SPARRING_WON
		ProgressCommons.Quest.KHAO_HACH_NOI_MON:
			return state >= ProgressCommons.KHAO_HACH_NOI_MON.TRIAL_BEAST_SLAIN
		ProgressCommons.Quest.TRUYEN_THUA_TONG_MON:
			return state >= ProgressCommons.TRUYEN_THUA_TONG_MON.COMPREHENDED
		ProgressCommons.Quest.SHIP_PETER_BOUNTY:
			return state >= ProgressCommons.SHIP_PETER_BOUNTY.ALL_DONE
	return false

static func InferActionFromText(targetText : String) -> int:
	var t : String = targetText.to_lower()
	if t.contains("tiêu diệt") or t.contains("trảm") or t.contains("săn bắt") or t.contains("thảo phạt"):
		return Action.KILL
	if t.contains("thu thập") or t.contains("thu hoạch") or t.contains("khai thác") or t.contains("khai khoáng") or t.contains("gom"):
		return Action.GATHER
	if t.contains("nói chuyện") or t.contains("gặp") or t.contains("bái kiến") or t.contains("diện kiến") or t.contains("giao nộp"):
		return Action.TALK
	return Action.GO

static func ActionFromKind(kind : String) -> int:
	match kind:
		"kill": return Action.KILL
		"gather": return Action.GATHER
		"talk": return Action.TALK
		"return": return Action.RETURN
		_: return Action.GO

static func BuildStep(questID : int, state : int) -> Dictionary:
	EnsureIndex()
	var empty : Dictionary = {}
	if state <= ProgressCommons.UnknownProgress or state >= ProgressCommons.CompletedProgress:
		return empty
	var questData : QuestData = DB.GetQuest(questID)
	if questData == null:
		return empty

	var turnIn : bool = IsReadyToTurnIn(questID, state)
	var override : Dictionary = _objectiveTable.get(questID, {})
	var action : int = Action.UNKNOWN
	var nick : String = ""

	if turnIn:
		action = Action.RETURN
		nick = str(override.get("return", ""))
		if nick.is_empty():
			nick = questData.giver
	elif not override.is_empty():
		action = ActionFromKind(str(override.get("kind", "go")))
		nick = str(override.get("do", ""))
	else:
		action = InferActionFromText(questData.target)
		nick = MatchNickInText(questData.target)
		if nick.is_empty():
			nick = MatchNickInText(questData.giver)
		if nick.is_empty():
			nick = questData.giver

	var spawns : Array = FindSpawns(nick)
	# Prefer spawn on current map when multiple
	var chosen : Dictionary = {}
	if not spawns.is_empty():
		chosen = spawns[0]
		if Launcher.Map:
			for s in spawns:
				if s.get("map_id", DB.UnknownHash) == Launcher.Map.currentMapID:
					chosen = s
					break

	var mapID : int = int(chosen.get("map_id", DB.UnknownHash)) if not chosen.is_empty() else DB.UnknownHash
	var pos : Vector2 = chosen.get("position", Vector2.ZERO) if not chosen.is_empty() else Vector2.ZERO
	var live : Vector2 = ResolveLivePosition(nick, mapID)
	if live != Vector2.INF:
		pos = live
		if Launcher.Map:
			mapID = Launcher.Map.currentMapID

	var mapDisplay : String = str(chosen.get("map_display", "")) if not chosen.is_empty() else ""
	var mapInternal : String = str(chosen.get("map_internal", "")) if not chosen.is_empty() else ""
	if mapDisplay.is_empty():
		# Fallback: resolve region name from quest location strings (no fake coords)
		var locHint : String = questData.targetLocation if not turnIn else questData.giverLocation
		mapDisplay = locHint
		mapID = _ResolveMapIdFromLocationLabel(locHint)

	var progressText : String = _BuildProgressText(questID, state, override)
	var actionLabel : String = ACTION_LABEL.get(action, "Mục tiêu")
	var hint : String = "%s [%s]" % [actionLabel, nick]
	if not progressText.is_empty():
		hint += " — %s" % progressText

	var resolved : bool = not chosen.is_empty() or live != Vector2.INF
	return {
		"quest_id": questID,
		"quest_name": questData.name,
		"action": action,
		"action_label": actionLabel,
		"nick": nick,
		"map_id": mapID,
		"map_display": mapDisplay if not mapDisplay.is_empty() else LocationNaming.GetDisplayName(mapID),
		"map_internal": mapInternal,
		"position": pos,
		"resolved": resolved,
		"hint": hint,
		"progress": progressText,
		"giver": questData.giver,
		"target": questData.target,
		"turn_in": turnIn,
	}

static func _ResolveMapIdFromLocationLabel(label : String) -> int:
	if label.is_empty():
		return DB.UnknownHash
	# Match against LocationNaming display names and WorldMap aliases
	for mapID in DB.MapsDB:
		var display : String = LocationNaming.GetDisplayName(mapID)
		if display == label or label.contains(display) or display.contains(label):
			return mapID
	# Soft aliases used in quest tres
	var aliases : Dictionary = {
		"Trúc Sơn Tiên Cảnh": "SacredSectHub",
		"Sơn Môn Trúc Sơn": "SacredSectHub",
		"Tiếp Dẫn Đài": "SacredSectHub",
		"Đại Điện Trúc Sơn": "SacredSectHub",
		"Dược Đường": "SacredSectHub",
		"Luyện Khí Đường": "SacredSectHub",
		"Nhiệm Vụ Đường": "SacredSectHub",
		"Diễn Võ Đường": "SacredSectHub",
		"Diễn Võ Trường": "SacredSectHub",
		"Trúc Sơn Đan Các": "SacredSectHub",
		"Trúc Sơn Cổ Bi": "SacredSectHub",
		"Chân Núi Trúc Sơn": "SacredSectHub",
		"Trúc Sơn Ngoại Vi": "Tulimshar Eastern Hills",
		"Sơn Lâm Ngoại Vi": "Tulimshar Eastern Hills",
		"Rặng Trúc Ngoại Vi": "Tulimshar Eastern Hills",
		"Ngoại Vi Sơn Môn": "Tulimshar Eastern Hills",
		"Bãi Quặng Trúc Sơn": "Tulimshar Eastern Hills",
		"Linh Khí Bí Cảnh": "Candor Arena",
		"Cổ Đạo Phế Tích": "Tulimshar Western Cave",
	}
	if aliases.has(label):
		return aliases[label].hash()
	for key in aliases:
		if label.contains(key) or key.contains(label):
			return aliases[key].hash()
	return DB.UnknownHash

static func _BuildProgressText(questID : int, state : int, override : Dictionary) -> String:
	if override.is_empty():
		return ""
	var need : int = int(override.get("need", 0))
	if need <= 1:
		return ""
	if IsReadyToTurnIn(questID, state):
		return "%d/%d ✔" % [need, need]
	# Kill/gather counters: STARTED=1 → 0 done; each step +1
	var done : int = maxi(0, state - 1)
	done = mini(done, need)
	return "%d/%d" % [done, need]

static func GetActiveSteps(player = null) -> Array:
	EnsureIndex()
	var steps : Array = []
	var actor = player if player else Launcher.Player
	if actor == null or actor.progress == null:
		return steps
	for questID in actor.progress.quests.keys():
		var state : int = actor.progress.GetQuest(questID)
		var step : Dictionary = BuildStep(questID, state)
		if not step.is_empty():
			steps.append(step)
	# Prefer resolved + current-map first for HUD primary
	steps.sort_custom(func(a, b):
		var aCur : bool = Launcher.Map and a.get("map_id") == Launcher.Map.currentMapID
		var bCur : bool = Launcher.Map and b.get("map_id") == Launcher.Map.currentMapID
		if aCur != bCur:
			return aCur
		var aRes : bool = a.get("resolved", false)
		var bRes : bool = b.get("resolved", false)
		if aRes != bRes:
			return aRes
		return str(a.get("quest_name", "")) < str(b.get("quest_name", ""))
	)
	return steps

static func GetPrimaryStep(player = null) -> Dictionary:
	var steps : Array = GetActiveSteps(player)
	return steps[0] if not steps.is_empty() else {}

static func FormatStepRich(step : Dictionary) -> String:
	if step.is_empty():
		return ""
	var warn : String = UICommons.WarnTextColor.to_html(false)
	var text : String = UICommons.TextColor.to_html(false)
	var lines : PackedStringArray = PackedStringArray()
	lines.append("[b]%s[/b]" % step.get("quest_name", ""))
	lines.append("[color=#%s]%s[/color]" % [warn, step.get("hint", "")])
	var mapName : String = str(step.get("map_display", ""))
	var pos : Vector2 = step.get("position", Vector2.ZERO)
	if step.get("resolved", false):
		lines.append("[color=#%s]Bản đồ: %s @ (%d, %d)[/color]" % [text, mapName, int(pos.x), int(pos.y)])
	elif not mapName.is_empty():
		lines.append("[color=#%s]Khu vực: %s (chưa có mốc spawn chính xác)[/color]" % [text, mapName])
	else:
		lines.append("[color=#888888]Chưa gắn được tọa độ spawn[/color]")
	if Launcher.Map and step.get("map_id", DB.UnknownHash) != DB.UnknownHash:
		if Launcher.Map.currentMapID == step.get("map_id"):
			lines.append("[color=#66ff66]● Đang cùng bản đồ[/color]")
		else:
			var here : String = LocationNaming.GetDisplayName(Launcher.Map.currentMapID)
			lines.append("[color=#ffaa44]↪ Hiện tại: %s — hãy dịch chuyển tới %s[/color]" % [here, mapName])
	return "\n".join(lines)

static func FormatStepOneLine(step : Dictionary) -> String:
	if step.is_empty():
		return ""
	var pos : Vector2 = step.get("position", Vector2.ZERO)
	if step.get("resolved", false):
		return "%s · %s (%d,%d)" % [step.get("hint", ""), step.get("map_display", ""), int(pos.x), int(pos.y)]
	return "%s · %s" % [step.get("hint", ""), step.get("map_display", "")]
