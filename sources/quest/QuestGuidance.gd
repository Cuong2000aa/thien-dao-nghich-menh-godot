extends RefCounted
class_name QuestGuidance

## Resolves EVERY quest objective to map + world coordinates.
## Sources (priority): live entity → spawn nick/entity name → explicit anchors.

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

## Extra name aliases → index key (entity English ↔ Vietnamese nick).
const NAME_ALIASES : Dictionary = {
	"Xich Viem Thu Hau": "Xích Viêm Thú Hậu",
	"Boss Arena Controller": "Xích Viêm Thú Hậu",
}

## Hard anchors when no spawn nick exists (still exact map + coords from design).
const ANCHORS : Array = [
	{"nick": "Xích Viêm Thú Hậu", "map": "Candor Arena", "pos": Vector2(1744, 1851)},
	{"nick": "Thiefs Chest", "map": "Snake Pit", "pos": Vector2(2725, 1007)},
	{"nick": "Hiên Viên Cổ Động", "map": "Tulimshar Western Cave", "pos": Vector2(1794, 1543)},
	{"nick": "Ngũ Hành Thạch Trận", "map": "SacredSectHub", "pos": Vector2(1000, 1350)},
	{"nick": "Huyết Sâm", "map": "SacredSectHub", "pos": Vector2(1150, 1400)},
	{"nick": "Xích Viêm Khoáng", "map": "Candor Arena", "pos": Vector2(1680, 1800)},
	{"nick": "Thanh Phong Tinh Thiết", "map": "Tulimshar Eastern Hills", "pos": Vector2(2600, 1300)},
	{"nick": "U Hồn Đầm Lầy", "map": "Manayir Beach", "pos": Vector2(3108, 2557)},
	{"nick": "Hầm Ngục Cổ Xưa", "map": "Artis Sewer", "pos": Vector2(2023, 1599)},
	{"nick": "Di Tích Tiền Nhân", "map": "Tulimshar Eastern Hills", "pos": Vector2(2206, 1018)},
	{"nick": "Yêu Thú", "map": "Tulimshar Eastern Hills", "pos": Vector2(2000, 1374)},
	{"nick": "Yêu Thú Cuồng Bạo", "map": "Tulimshar Eastern Hills", "pos": Vector2(2000, 1374)},
	{"nick": "Dị Thú", "map": "Tulimshar Eastern Hills", "pos": Vector2(1330, 3884)},
	{"nick": "Ratto Ship", "map": "Ship Alige Hide", "pos": Vector2(1200, 1000)},
	# Kael field cleanup (Tutorial KAEL_MET) — north cactus field
	{"nick": "Peyote", "map": "Tulimshar", "pos": Vector2(2912, 1312)},
	{"nick": "Maggot", "map": "Tulimshar", "pos": Vector2(2912, 1312)},

	{"nick": "Tinh Hoa Linh Khí", "map": "Tulimshar Eastern Hills", "pos": Vector2(2450, 2342)},
	{"nick": "Chest Outskirts", "map": "Tulimshar Eastern Hills", "pos": Vector2(2206, 1018)},
	{"nick": "Veteran Cave", "map": "Tulimshar Western Cave", "pos": Vector2(1854, 1221)},
	{"nick": "Bản Đồ Chỉ Dẫn", "map": "Tulimshar Eastern Hills", "pos": Vector2(2650, 1200)},
	{"nick": "Lời Đồn Tán Tu", "map": "SacredSectHub", "pos": Vector2(1050, 1460)},
]

static var _nickIndex : Dictionary = {} # nick -> Array[Dictionary]
static var _nicksLongestFirst : PackedStringArray = PackedStringArray()
static var _indexBuilt : bool = false
static var _objectiveTable : Dictionary = {} # questID -> {do, return, kind, need}

static func _EnsureObjectiveTable() -> void:
	if not _objectiveTable.is_empty():
		return
	var Q = ProgressCommons.Quest
	_objectiveTable = {
		# --- Core TDNM loop ---
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
		Q.KHAO_HACH_NOI_MON: {"do": "Xích Viêm Thú Hậu", "return": "Đạo Huyền Trưởng Lão", "kind": "kill", "need": 1},
		Q.TRUYEN_THUA_TONG_MON: {"do": "Đạo Huyền Trưởng Lão", "return": "Đạo Huyền Trưởng Lão", "kind": "talk", "need": 1},
		Q.TUAN_TRA_SON_MON: {"do": "Chấp Sự Nhiệm Vụ Đường", "return": "Chấp Sự Nhiệm Vụ Đường", "kind": "go", "need": 1},
		# --- Main story ---
		Q.MQ_CHUONG_1_TINH_LAC_DI_GIOI: {"do": "Tiếp Dẫn Chấp Sự", "return": "Tiếp Dẫn Chấp Sự", "kind": "talk", "need": 1},
		Q.MQ_CHUONG_2_CON_DUONG_TU_DAO: {"do": "Trúc Sơn Cổ Bi", "return": "Đạo Huyền Trưởng Lão", "kind": "talk", "need": 1},
		Q.MQ_CHUONG_3_DAU_VET_DI_BIEN: {"do": "Diệp Tử Lăng", "return": "Diệp Tử Lăng", "kind": "talk", "need": 1},
		Q.MQ_CHUONG_4_BI_MAT_CO_TICH: {"do": "Mặc Lão Nhân", "return": "Mặc Lão Nhân", "kind": "talk", "need": 1},
		Q.MQ_CHUONG_5_THIEN_DAO_CO_KHUYET: {"do": "Đạo Huyền Trưởng Lão", "return": "Đạo Huyền Trưởng Lão", "kind": "talk", "need": 1},
		# --- NPC chains ---
		Q.NQ_LIEU_THANH_Y_1: {"do": "Ngân Linh Thảo", "return": "Liễu Thanh Y", "kind": "gather", "need": 3},
		Q.NQ_LIEU_THANH_Y_2: {"do": "Tiếp Dẫn Chấp Sự", "return": "Liễu Thanh Y", "kind": "go", "need": 1},
		Q.NQ_HA_THIET_THU_1: {"do": "Huyền Thiết Khoáng", "return": "Hà Thiết Thủ", "kind": "gather", "need": 5},
		Q.NQ_HA_THIET_THU_2: {"do": "Xích Viêm Khoáng", "return": "Hà Thiết Thủ", "kind": "gather", "need": 3},
		Q.NQ_DIEP_TU_LANG_1: {"do": "Yêu Thú Cuồng Bạo", "return": "Diệp Tử Lăng", "kind": "kill", "need": 3},
		Q.NQ_DIEP_TU_LANG_2: {"do": "Dị Thú", "return": "Diệp Tử Lăng", "kind": "kill", "need": 1},
		Q.NQ_MAC_LAO_NHAN_1: {"do": "Trúc Sơn Cổ Bi", "return": "Mặc Lão Nhân", "kind": "gather", "need": 3},
		Q.NQ_MAC_LAO_NHAN_2: {"do": "Ngũ Hành Thạch Trận", "return": "Mặc Lão Nhân", "kind": "go", "need": 1},
		Q.NQ_TRAN_PHUONG_1: {"do": "Trần Phương", "return": "Trần Phương", "kind": "talk", "need": 1},
		Q.NQ_TRAN_PHUONG_2: {"do": "Trần Phương", "return": "Trần Phương", "kind": "talk", "need": 1},
		# --- Side / exploration ---
		Q.SQ_HIEN_VIEN_BI_MAT: {"do": "Hiên Viên Cổ Động", "return": "Bản Đồ Chỉ Dẫn", "kind": "go", "need": 1},
		Q.SQ_U_HON_TRAM_BAO: {"do": "U Hồn Đầm Lầy", "return": "Lời Đồn Tán Tu", "kind": "go", "need": 1},
		Q.SQ_NGU_HANH_THACH_TRAN: {"do": "Ngũ Hành Thạch Trận", "return": "Mặc Lão Nhân", "kind": "go", "need": 1},
		Q.SQ_BIET_VIEN_DUOC_DIEN: {"do": "Huyết Sâm", "return": "Liễu Thanh Y", "kind": "gather", "need": 2},
		Q.SQ_LIEN_HOA_CO_THIET: {"do": "Thanh Phong Tinh Thiết", "return": "Hà Thiết Thủ", "kind": "gather", "need": 2},
		Q.SQ_PHONG_AN_DIA_HA: {"do": "Hầm Ngục Cổ Xưa", "return": "Bạch Hạc Chân Nhân", "kind": "go", "need": 1},
		Q.SQ_TIEN_NHAN_DI_THU: {"do": "Di Tích Tiền Nhân", "return": "Di Tích Tiền Nhân", "kind": "go", "need": 1},
		Q.SQ_DU_PHUONG_GIAO_THUONG: {"do": "Khang Vạn Kim", "return": "Khang Vạn Kim", "kind": "talk", "need": 1},
		# --- Events ---
		Q.EQ_YEU_THU_TRIEU: {"do": "Yêu Thú", "return": "Chấp Sự Nhiệm Vụ Đường", "kind": "kill", "need": 10},
		Q.EQ_LINH_KHI_DI_TUONG: {"do": "Tinh Hoa Linh Khí", "return": "Liễu Thanh Y", "kind": "gather", "need": 3},
		Q.EQ_CO_TRAN_BAT_ON: {"do": "Thanh Phong Tinh Thiết", "return": "Đạo Huyền Trưởng Lão", "kind": "gather", "need": 3},
		# --- SoM legacy ---
		Q.NINA_HUNGRY: {"do": "Nina", "return": "Nina", "kind": "talk", "need": 1},
		# Maggot drops slime; turn-in is inventory-gated at Elanore (not state>need).
		Q.ELANORE_POTION: {"do": "Maggot", "return": "Elanore", "kind": "kill", "need": 6, "turn_state": -1},
		Q.GRAIN_IN_THE_SAND: {"do": "Flour Barrel", "return": "Riskim", "kind": "go", "need": 1},
		# Multi-phase — resolved in _ResolvePhaseOverride (do/return here = early/late defaults).
		Q.TUTORIAL: {"do": "Elanore", "return": "Kael", "kind": "talk", "need": 1, "turn_state": -1},
		Q.TULIMSHAR_OLD_FRIENDSHIP: {"do": "Ben", "return": "Frost", "kind": "talk", "need": 1},
		Q.TULIMSHAR_GLASSMAKING: {"do": "Eridu", "return": "Eridu", "kind": "talk", "need": 1},
		Q.TULIMSHAR_EASTERN_HILLS_CHEST: {"do": "Chest Outskirts", "return": "Chest Outskirts", "kind": "go", "need": 1},
		Q.MINE_EXPLORATION: {"do": "Ekinu", "return": "Ekinu", "kind": "talk", "need": 1, "turn_state": -1},
		Q.SANDSTORM_NATHAN_WATER: {"do": "Nathan", "return": "Nathan", "kind": "talk", "need": 1},
		Q.SANDSTORM_NAEM_HELMET: {"do": "Naem", "return": "Naem", "kind": "talk", "need": 1},
		Q.SANDSTORM_MINE_ABANDONED_TREASURE: {"do": "SandstormMineKey", "return": "Chest", "kind": "go", "need": 1},
		Q.DESERT_SEED: {"do": "Mana Tree", "return": "Mana Tree", "kind": "talk", "need": 1},
		Q.SHIP_PETER_BOUNTY: {"do": "Ratto Ship", "return": "Peter", "kind": "kill", "need": 1},

		Q.SNAKE_PIT_THIEF: {"do": "Snake Pit Clue", "return": "Thiefs Chest", "kind": "go", "need": 1},
		Q.SNAKE_PIT_BITING_THIRST: {"do": "Snake Pit Pond", "return": "Mauro", "kind": "go", "need": 1},
		Q.SPLATYNA_OFFERING: {"do": "Splatyna", "return": "Bicies", "kind": "talk", "need": 1},
		Q.VETERAN_CAVE_EXPLORER: {"do": "Veteran Cave", "return": "Veteran Cave", "kind": "go", "need": 1},
	}

static func InvalidateIndex() -> void:
	_indexBuilt = false
	_nickIndex.clear()
	_nicksLongestFirst = PackedStringArray()
	_objectiveTable.clear()

static func _AddIndexEntry(nick : String, entry : Dictionary) -> void:
	if nick.is_empty():
		return
	if not _nickIndex.has(nick):
		_nickIndex[nick] = []
	_nickIndex[nick].append(entry)
	# Alias chain
	if NAME_ALIASES.has(nick):
		var alias : String = str(NAME_ALIASES[nick])
		if alias != nick:
			if not _nickIndex.has(alias):
				_nickIndex[alias] = []
			_nickIndex[alias].append(entry)

static func _RegisterAnchor(nick : String, mapInternal : String, pos : Vector2) -> void:
	var mapID : int = mapInternal.hash()
	var mapDisplay : String = LocationNaming.GetDisplayName(mapInternal)
	if DB.isInitialized and DB.MapsDB.has(mapID):
		mapDisplay = LocationNaming.GetDisplayName(DB.MapsDB[mapID])
	var entry : Dictionary = {
		"nick": nick,
		"map_id": mapID,
		"map_internal": mapInternal,
		"map_display": mapDisplay,
		"position": pos,
		"offset": Vector2.ZERO,
		"type": ActorCommons.Type.NPC,
		"count": 1,
		"entity_id": DB.UnknownHash,
		"anchor": true,
	}
	_AddIndexEntry(nick, entry)

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
			var ent : EntityData = DB.EntitiesDB.get(spawn.id, null) if spawn.id != DB.UnknownHash else null
			var entName : String = ent._name if ent else ""
			if nick.is_empty():
				nick = entName
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
				"anchor": false,
			}
			_AddIndexEntry(nick, entry)
			if not entName.is_empty() and entName != nick:
				_AddIndexEntry(entName, entry)

	for a in ANCHORS:
		# Only fill gaps — real spawns win if already present
		var nick : String = str(a.get("nick", ""))
		if nick.is_empty():
			continue
		if _nickIndex.has(nick) and not _nickIndex[nick].is_empty():
			var hasReal : bool = false
			for e in _nickIndex[nick]:
				if not e.get("anchor", false):
					hasReal = true
					break
			if hasReal:
				continue
		_RegisterAnchor(nick, str(a.get("map", "")), a.get("pos", Vector2.ZERO))

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
	var lower : String = nick.to_lower()
	for key in _nicksLongestFirst:
		if key.to_lower() == lower:
			return _nickIndex[key]
	# Alias reverse
	if NAME_ALIASES.has(nick):
		var alias : String = str(NAME_ALIASES[nick])
		if _nickIndex.has(alias):
			return _nickIndex[alias]
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
	var alias : String = str(NAME_ALIASES.get(nick, nick))
	for entity in Entities.entities.values():
		if entity == null or not is_instance_valid(entity):
			continue
		var en : String = entity.nick
		var matchNick : bool = (en == nick or en == alias)
		if not matchNick and entity.data:
			matchNick = (entity.data._name == nick or entity.data._name == alias)
		if not matchNick:
			continue
		if preferMapID != DB.UnknownHash and Launcher.Map and Launcher.Map.currentMapID != preferMapID:
			continue
		sum += entity.position
		count += 1
	if count > 0:
		return sum / float(count)
	return Vector2.INF

## Multi-phase quests: nick/kind change with state (avoids Auto re-talking giver mid-objective).
static func _ResolvePhaseOverride(questID : int, state : int) -> Dictionary:
	match questID:
		ProgressCommons.Quest.TUTORIAL:
			# Talk Elanore → talk Kael → kill field mobs → talk Kael → talk Ekinu
			if state < ProgressCommons.TUTORIAL.ELANORE_DONE:
				return {"do": "Elanore", "return": "Elanore", "kind": "talk", "need": 1, "force_turn_in": false}
			if state == ProgressCommons.TUTORIAL.ELANORE_DONE:
				return {"do": "Kael", "return": "Kael", "kind": "talk", "need": 1, "force_turn_in": false}
			if state == ProgressCommons.TUTORIAL.KAEL_MET:
				# Kill phase — NEVER treat as turn-in or Auto loops Kael dialogue.
				# need_each: 5 Peyote + 5 Maggot (KaelGlobal counters).
				return {
					"do": "Peyote", "return": "Kael", "kind": "kill", "need": 5,
					"force_turn_in": false, "alt_do": "Maggot", "need_each": true,
					"kill_targets": ["Peyote", "Maggot"],
				}
			if state == ProgressCommons.TUTORIAL.KAEL_DONE:
				return {"do": "Ekinu", "return": "Ekinu", "kind": "talk", "need": 1, "force_turn_in": false}
		ProgressCommons.Quest.ELANORE_POTION:
			# State stays STARTED until brew; turn-in when inventory has slime batches.
			if state == ProgressCommons.ELANORE_POTION.STARTED:
				return {
					"do": "Maggot", "return": "Elanore", "kind": "kill", "need": 6,
					"force_turn_in": false, "kill_targets": ["Maggot"],
					"turn_items": [["Maggot Slime", 6], ["Water Bottle", 1], ["Pitaya", 1]],
				}
		ProgressCommons.Quest.MINE_EXPLORATION:
			# After Ekinu accepts expedition — do NOT bounce back to Ekinu (dialogue menu loops).
			# Dausen = directions only (no state change); next_do Ryan at mine is the real advance.
			if state == ProgressCommons.MINE_EXPLORATION.STARTED:
				return {
					"do": "Dausen", "next_do": "Ryan", "return": "Ryan", "kind": "talk",
					"need": 1, "force_turn_in": false,
				}
			if state == ProgressCommons.MINE_EXPLORATION.FIND_NICKOS:
				return {"do": "Nickos", "next_do": "Xakelbael", "return": "Ryan", "kind": "talk", "need": 1, "force_turn_in": false}
			if state >= ProgressCommons.MINE_EXPLORATION.STRANGER_SPOTTED and state < ProgressCommons.MINE_EXPLORATION.DEFEATED:
				return {"do": "Xakelbael", "return": "Ryan", "kind": "kill", "need": 1, "force_turn_in": false, "kill_targets": ["Xakelbael"]}
			if state == ProgressCommons.MINE_EXPLORATION.DEFEATED:
				return {"do": "Mana Tree", "next_do": "Ryan", "return": "Ryan", "kind": "talk", "need": 1, "force_turn_in": false}
			if state == ProgressCommons.MINE_EXPLORATION.MANA_TREE_MET:
				return {"do": "Ryan", "return": "Ryan", "kind": "talk", "need": 1, "force_turn_in": true}
	return {}

static func IsReadyToTurnIn(questID : int, state : int) -> bool:
	if state <= ProgressCommons.UnknownProgress or state >= ProgressCommons.CompletedProgress:
		return false
	_EnsureObjectiveTable()
	var phase : Dictionary = _ResolvePhaseOverride(questID, state)
	if not phase.is_empty() and phase.has("force_turn_in"):
		return bool(phase.get("force_turn_in", false))

	# Explicit quest milestones first (before need heuristic — need≠turn-in for multi-phase).
	match questID:
		ProgressCommons.Quest.THANH_TRU_LINH_TRUNG:
			return state >= ProgressCommons.THANH_TRU_LINH_TRUNG.OBJECTIVE_MET
		ProgressCommons.Quest.THU_THAP_LINH_THAO:
			return state >= ProgressCommons.THU_THAP_LINH_THAO.OBJECTIVE_MET
		ProgressCommons.Quest.LUYEN_DAN_NHAP_MON:
			return state >= ProgressCommons.LUYEN_DAN_NHAP_MON.OBJECTIVE_MET
		ProgressCommons.Quest.KHAM_PHA_CO_BI:
			return state >= ProgressCommons.KHAM_PHA_CO_BI.OBJECTIVE_MET
		ProgressCommons.Quest.THAO_PHAT_THU_VUONG:
			return state >= ProgressCommons.THAO_PHAT_THU_VUONG.BOSS_SLAIN
		ProgressCommons.Quest.THU_THAP_KHOANG_THACH:
			return state >= ProgressCommons.THU_THAP_KHOANG_THACH.OBJECTIVE_MET
		ProgressCommons.Quest.NHAP_MON_KHAO_NGHIEM:
			return state >= ProgressCommons.NHAP_MON_KHAO_NGHIEM.OBJECTIVE_MET
		ProgressCommons.Quest.TUAN_TRA_SON_MON:
			return state >= ProgressCommons.TUAN_TRA_SON_MON.OBJECTIVE_MET
		ProgressCommons.Quest.CONG_HIEN_DUOC_THAO:
			return state >= ProgressCommons.CONG_HIEN_DUOC_THAO.OBJECTIVE_MET
		ProgressCommons.Quest.CONG_HIEN_KHOANG_THACH:
			return state >= ProgressCommons.CONG_HIEN_KHOANG_THACH.OBJECTIVE_MET
		ProgressCommons.Quest.DIET_TRU_MA_VAT:
			return state >= ProgressCommons.DIET_TRU_MA_VAT.OBJECTIVE_MET
		ProgressCommons.Quest.KHAO_HACH_NGOAI_MON:
			return state >= ProgressCommons.KHAO_HACH_NGOAI_MON.SPARRING_WON
		ProgressCommons.Quest.KHAO_HACH_NOI_MON:
			return state >= ProgressCommons.KHAO_HACH_NOI_MON.TRIAL_BEAST_SLAIN
		ProgressCommons.Quest.TRUYEN_THUA_TONG_MON:
			return state >= ProgressCommons.TRUYEN_THUA_TONG_MON.COMPREHENDED
		ProgressCommons.Quest.SHIP_PETER_BOUNTY:
			return state >= ProgressCommons.SHIP_PETER_BOUNTY.ALL_DONE
		ProgressCommons.Quest.TUTORIAL, ProgressCommons.Quest.ELANORE_POTION, ProgressCommons.Quest.MINE_EXPLORATION:
			return false

	var override : Dictionary = _objectiveTable.get(questID, {})
	if override.is_empty():
		return false
	# Optional explicit turn_state; -1 disables need heuristic.
	if override.has("turn_state"):
		var ts : int = int(override.get("turn_state", -1))
		return ts >= 0 and state >= ts
	var kind : String = str(override.get("kind", ""))
	# Only kill/gather counters use need as turn-in threshold (STARTED=1 → OBJECTIVE = need+1).
	if kind == "kill" or kind == "gather":
		var need : int = maxi(1, int(override.get("need", 1)))
		return state > need
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

	var phase : Dictionary = _ResolvePhaseOverride(questID, state)
	var override : Dictionary = _objectiveTable.get(questID, {})
	if not phase.is_empty():
		# Phase wins over static table for multi-step quests.
		override = override.duplicate()
		for k in phase.keys():
			override[k] = phase[k]

	var turnIn : bool = IsReadyToTurnIn(questID, state)
	var action : int = Action.UNKNOWN
	var nick : String = ""
	var altNick : String = str(override.get("alt_do", ""))

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
	if spawns.is_empty() and not altNick.is_empty():
		spawns = FindSpawns(altNick)
		if not spawns.is_empty():
			nick = altNick
	# If return nick missing, try giver nick from override
	if spawns.is_empty() and turnIn and not questData.giver.is_empty():
		spawns = FindSpawns(questData.giver)
		if not spawns.is_empty():
			nick = questData.giver

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
		var locHint : String = questData.targetLocation if not turnIn else questData.giverLocation
		mapDisplay = locHint
		mapID = _ResolveMapIdFromLocationLabel(locHint)

	var progressText : String = _BuildProgressText(questID, state, override)
	var actionLabel : String = ACTION_LABEL.get(action, "Mục tiêu")
	var hint : String = "%s [%s]" % [actionLabel, nick]
	if not progressText.is_empty():
		hint += " — %s" % progressText

	var returnNick : String = str(override.get("return", ""))
	if returnNick.is_empty():
		returnNick = questData.giver
	var nextNick : String = str(override.get("next_do", ""))
	var killTargets : Array = []
	if override.has("kill_targets"):
		killTargets = override.get("kill_targets", [])
	else:
		if not nick.is_empty() and action == Action.KILL:
			killTargets.append(nick)
		if not altNick.is_empty() and action == Action.KILL:
			killTargets.append(altNick)
	var resolved : bool = not chosen.is_empty() or live != Vector2.INF
	return {
		"quest_id": questID,
		"quest_name": questData.name,
		"action": action,
		"action_label": actionLabel,
		"nick": nick,
		"alt_nick": altNick,
		"next_nick": nextNick,
		"return_nick": returnNick,
		"kill_targets": killTargets,
		"need": int(override.get("need", 0)),
		"need_each": bool(override.get("need_each", false)),
		"turn_items": override.get("turn_items", []),
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

## Master Quest Chains: defines sequential progression between quests.
## When a quest completes or is skipped, game automatically chains to the next quest in the chain.
const QUEST_CHAINS : Array = [
	# 1. Main Story Chapters (Chính Tuyến Tiên Hiệp)
	[
		"Tỉnh Lạc Dị Giới",
		"Con Đường Tu Đạo",
		"Dấu Vết Dị Biến",
		"Bí Mật Trong Cổ Tích",
		"Thiên Đạo Có Khuyết",
	],
	# 2. Tông Môn Trúc Sơn (Sect Foundation & Discipleship)
	[
		"Khảo Nghiệm Nhập Môn",
		"Thanh Trừ Linh Trùng",
		"Thu Thập Linh Thảo",
		"Thu Thập Khoáng Thạch",
		"Cống Hiến Dược Thảo",
		"Cống Hiến Khoáng Thạch",
		"Diệt Trừ Ma Vật",
		"Luyện Đan Nhập Môn",
		"Khám Phá Cổ Bi",
		"Thảo Phạt Thú Vương",
		"Khảo Hạch Ngoại Môn",
		"Khảo Hạch Nội Môn",
		"Truyền Thừa Tông Môn",
		"Tuần Tra Sơn Môn",
	],
	# 3. Chuỗi Khởi Đầu & Cảng Thanh Sa (Tonori / Tulimshar Main Sequence)
	[
		"Tutorial",
		"Elanore's Potions",
		"Nina's Snack",
		"Mine Exploration",
		"A Drop of Relief",
		"A Miner's Helping Hand",
		"Sandstorm Mine Abandoned Treasure",
		"Desert Seed",
		"An Old Friendship",
		"When the desert gives you sand...",
		"Found a Chest in the Outskirts",
		"Grain in the desert",
		"Peter's Bounty",
		"Snake Pit Thief",
		"A Biting Thirst",
		"Splatyna's Offering",
		"Veteran Cave Explorer",
	],
	# 4. NPC Hảo Cảm Chains
	[
		"Dược Điển Tầm Thảo",
		"Cứu Trợ Thương Binh",
	],
	[
		"Khoáng Thạch Thí Luyện",
		"Bí Quyết Truốt Kiếm",
	],
	[
		"Huyết Tích Dã Ngoại",
		"Săn Bắt Dị Thú",
	],
	[
		"Minh Văn Trận Phù",
		"Cổ Trận Thăm Dò",
	],
	[
		"Đồng Môn Tương Trợ",
		"Tâm Ma Thử Thách",
	],
	# 5. Phụ Tuyến & Khám Phá
	[
		"Thám Hiểm Hiên Viên Động",
		"Tìm Kiếm U Hồn Trầm Bảo",
		"Giải Mã Trận Pháp Ngũ Hành",
		"Bí Cảnh Thảo Dược",
		"Khai Thác Liên Hoa Cổ Thiết",
		"Điều Tra Hầm Ngục Cổ Xưa",
		"Bức Thư Của Tiền Nhân Xuyên Không",
		"Tiếp Đón Du Phương Thương Đội",
	],
]

## Finds the next uncompleted quest in the same chain as questID.
## If the chain is completed, smoothly transitions to the next major story or sect chain.
static func GetNextQuestInChain(questID : int) -> int:
	var questProgress = Launcher.Player.progress if Launcher.Player else null
	for chain in QUEST_CHAINS:
		var foundIdx : int = -1
		for i in chain.size():
			var qName : String = str(chain[i])
			if qName.hash() == questID:
				foundIdx = i
				break
		if foundIdx >= 0:
			# Look for the first uncompleted quest further down this chain
			for j in range(foundIdx + 1, chain.size()):
				var nextQid : int = str(chain[j]).hash()
				if questProgress:
					var st : int = questProgress.GetQuest(nextQid)
					if st < ProgressCommons.CompletedProgress:
						return nextQid
				else:
					return nextQid
			break
	# Fallback: if chain is finished, find the first uncompleted quest in major chains
	return FindNextAvailableQuest()

## Finds the first uncompleted quest across all major chains in priority order.
static func FindNextAvailableQuest() -> int:
	var questProgress = Launcher.Player.progress if Launcher.Player else null
	for chain in QUEST_CHAINS:
		for qName in chain:
			var qid : int = str(qName).hash()
			if questProgress:
				var st : int = questProgress.GetQuest(qid)
				if st < ProgressCommons.CompletedProgress:
					return qid
			else:
				return qid
	return DB.UnknownHash

## Builds guidance step to the Quest GIVER NPC to receive an unstarted quest.
static func BuildStartStep(questID : int) -> Dictionary:
	EnsureIndex()
	_EnsureObjectiveTable()
	var questData : QuestData = DB.GetQuest(questID)
	if questData == null:
		return {}
	var giver : String = questData.giver
	if giver.is_empty():
		return {}
	var spawns : Array = FindSpawns(giver)
	if spawns.is_empty():
		return {}
	var chosen : Dictionary = spawns[0]
	return {
		"quest_id": questID,
		"nick": giver,
		"action": Action.TALK,
		"map_id": int(chosen.get("map_id", DB.UnknownHash)),
		"map_display": str(chosen.get("map_display", "")),
		"position": chosen.get("position", Vector2.ZERO),
		"resolved": true,
		"is_start_step": true,
		"quest_name": Localization.Get(questData.name, questData.name),
		"hint": "Gặp %s để nhận nhiệm vụ [%s]" % [giver, Localization.Get(questData.name, questData.name)]
	}

## Final turn-in / completion waypoint (Skip + Auto fly-to).
static func BuildCompletionStep(questID : int) -> Dictionary:
	EnsureIndex()
	_EnsureObjectiveTable()
	var questData : QuestData = DB.GetQuest(questID)
	if questData == null:
		return {}
	var override : Dictionary = _objectiveTable.get(questID, {}).duplicate()
	# Prefer highest phase return nick when known
	var phaseReturn : String = ""
	match questID:
		ProgressCommons.Quest.MINE_EXPLORATION:
			phaseReturn = "Ryan"
		ProgressCommons.Quest.TUTORIAL:
			phaseReturn = "Ekinu"
		ProgressCommons.Quest.ELANORE_POTION:
			phaseReturn = "Elanore"
	var nick : String = phaseReturn
	if nick.is_empty():
		nick = str(override.get("return", ""))
	if nick.is_empty():
		nick = questData.giver
	var spawns : Array = FindSpawns(nick)
	if spawns.is_empty():
		return {}
	var chosen : Dictionary = spawns[0]
	return {
		"quest_id": questID,
		"nick": nick,
		"map_id": int(chosen.get("map_id", DB.UnknownHash)),
		"map_display": str(chosen.get("map_display", "")),
		"position": chosen.get("position", Vector2.ZERO),
		"resolved": true,
	}

## Offline / listen-server warp to a guidance step (Auto + Skip).
static func WarpLocalPlayerToStep(step : Dictionary, notify : String = "") -> bool:
	if step.is_empty() or not bool(step.get("resolved", false)):
		return false
	var mapID : int = int(step.get("map_id", DB.UnknownHash))
	var pos : Vector2 = step.get("position", Vector2.ZERO)
	if mapID == DB.UnknownHash:
		return false

	var success : bool = false
	if Launcher.World:
		var agent : PlayerAgent = null
		if Peers:
			agent = Peers.GetAgent(NetworkCommons.PeerOfflineID)
			if agent == null:
				agent = Peers.GetAgent(NetworkCommons.PeerAuthorityID)
		if agent:
			NpcCommons.Warp(agent, mapID, pos, ActorCommons.Direction.SOUTH)
			success = true

	# Client local sync if in the same map or fallback
	if Launcher.Player and Launcher.Map:
		if Launcher.Map.currentMapID == mapID or success:
			Launcher.Player.position = pos
			if Launcher.Action:
				Launcher.Action.MoveTo(pos)
			success = true

	if success and not notify.is_empty() and Launcher.GUI and Launcher.GUI.notificationLabel:
		Launcher.GUI.notificationLabel.AddNotification(notify)
	return success

## Resolve spawn for an arbitrary nick (Auto next_do hop).
static func BuildNickStep(nick : String, fallback : Dictionary = {}) -> Dictionary:
	if nick.is_empty():
		return fallback
	EnsureIndex()
	var spawns : Array = FindSpawns(nick)
	if spawns.is_empty():
		return fallback
	var chosen : Dictionary = spawns[0]
	if Launcher.Map:
		for s in spawns:
			if s.get("map_id", DB.UnknownHash) == Launcher.Map.currentMapID:
				chosen = s
				break
	var mapID : int = int(chosen.get("map_id", DB.UnknownHash))
	var pos : Vector2 = chosen.get("position", Vector2.ZERO)
	var live : Vector2 = ResolveLivePosition(nick, mapID)
	if live != Vector2.INF:
		pos = live
		if Launcher.Map:
			mapID = Launcher.Map.currentMapID
	var out : Dictionary = fallback.duplicate() if not fallback.is_empty() else {}
	out["nick"] = nick
	out["map_id"] = mapID
	out["position"] = pos
	out["map_display"] = str(chosen.get("map_display", out.get("map_display", "")))
	out["resolved"] = true
	return out

static func _ResolveMapIdFromLocationLabel(label : String) -> int:
	if label.is_empty():
		return DB.UnknownHash
	for mapID in DB.MapsDB:
		var display : String = LocationNaming.GetDisplayName(mapID)
		if display == label or label.contains(display) or display.contains(label):
			return mapID
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
		"Cổng Thành Tulimshar": "Tulimshar",
		"Trung Tâm Tulimshar": "Tulimshar Center",
		"Chợ Tulimshar": "Tulimshar Center",
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
	var qTitle : String = Localization.Get(str(step.get("quest_name", "")), str(step.get("quest_name", "")))
	lines.append("[b]%s[/b]" % qTitle)
	lines.append("[color=#%s]%s[/color]" % [warn, step.get("hint", "")])
	var mapName : String = str(step.get("map_display", ""))
	var pos : Vector2 = step.get("position", Vector2.ZERO)
	var nickDisplay : String = Localization.Get(str(step.get("nick", "")), str(step.get("nick", "")))
	if step.get("resolved", false):
		if not nickDisplay.is_empty():
			lines.append("[color=#%s]Mốc: %s[/color]" % [text, nickDisplay])
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

## Coverage helper: every quest in DB must resolve STARTED.
static func AuditAllQuests() -> Dictionary:
	EnsureIndex()
	var ok : Array = []
	var bad : Array = []
	for questID in DB.QuestsDB:
		var q : QuestData = DB.QuestsDB[questID]
		var step : Dictionary = BuildStep(questID, 1) # STARTED-ish
		if step.get("resolved", false):
			ok.append(q.name)
		else:
			bad.append({"name": q.name, "nick": step.get("nick", ""), "step": step})
	return {"ok": ok, "bad": bad, "total": DB.QuestsDB.size()}
