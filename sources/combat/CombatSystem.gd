extends RefCounted
class_name CombatSystem

## TDNM — BUILD 05: COMBAT EVOLUTION, MARTIAL ARTS & SWORD CULTIVATION
## Master Combat Engine unifying Martial Arts, Combo, Sword Qi, Five Elements,
## Equipment Tiers, Telegraphed Boss Mechanics, and SQLite Persistence.

# ==============================================================================
# 1. ENUMS & TAXONOMY
# ==============================================================================
enum Category {
	SWORD = 0,    # Kiếm Quyết
	PALM = 1,     # Chưởng Pháp
	FIST = 2,     # Quyền Pháp
	FINGER = 3,   # Chỉ Pháp
	MOVEMENT = 4, # Thân Pháp
	BODY = 5,     # Luyện Thể
	SECRET = 6    # Bí Thuật / Pháp Thuật
}

enum Element {
	NONE = 0,
	METAL = 1, # Kim
	WOOD = 2,  # Mộc
	WATER = 3, # Thủy
	FIRE = 4,  # Hỏa
	EARTH = 5  # Thổ
}

enum Grade {
	MORTAL = 0, # Phàm Giai
	YELLOW = 1, # Hoàng Giai
	MYSTIC = 2, # Huyền Giai
	EARTH = 3,  # Địa Giai
	HEAVEN = 4  # Thiên Giai
}

enum MasteryLevel {
	INITIATE = 1,     # Sơ Khởi (1 Sao)
	ADEPT = 2,        # Thuần Thục (2 Sao)
	EXPERT = 3,       # Tinh Thông (3 Sao)
	MASTER = 4,       # Đại Thành (4 Sao)
	GRANDMASTER = 5   # Viên Mãn (5 Sao)
}

enum EquipTier {
	MORTAL = 0,  # Phàm Phẩm
	LOW = 1,     # Hạ Phẩm
	MID = 2,     # Trung Phẩm
	HIGH = 3,    # Thượng Phẩm
	SUPREME = 4, # Cực Phẩm
	ARTIFACT = 5 # Linh Bảo / Pháp Bảo
}

# ==============================================================================
# 2. STATE STORAGE & TRACKING
# ==============================================================================
# Sword Qi state per agent RID: int -> int (0 to 5)
static var swordQiStorage : Dictionary = {}

# Combo state per agent RID: int -> Dictionary { "step": int, "lastTime": float }
static var comboStorage : Dictionary = {}

# Active status effects per agent RID: int -> Dictionary of effects
static var statusEffects : Dictionary = {}

# Invulnerability tracking per agent RID: int -> float (time expiry)
static var invulnerableUntil : Dictionary = {}

# Debounce tracker to prevent double damage: String (attacker_target_skill) -> float
static var lastHitTimestamps : Dictionary = {}

# Signals for UI & gameplay feedback
# (Since static signals in GDScript 4 can be accessed or we can emit on an instance or via Network)
signal sword_qi_changed(agentRID: int, currentQi: int, maxQi: int)
signal combo_stepped(agentRID: int, step: int, comboName: String)
signal combat_feedback_emitted(targetRID: int, text: String, color: Color)

# ==============================================================================
# 3. MARTIAL ARTS DEFINITION CATALOG
# ==============================================================================
## SkillCell.id (presets/cells/skills/*.tres) → martial catalog key.
## Fixes Interactive/combat looking up MARTIAL_CATALOG with the wrong id space.
const SKILL_CELL_TO_MARTIAL : Dictionary = {
	182736401: 1002, # Thanh Phong Kiếm Khí
	182736402: 1003, # Trúc Sơn Kiếm Trận
	182736403: 1004, # Đạp Phong Bộ
	182736404: 1005, # Bát Hoang Liệt Không Quyền
	182736405: 1006, # Quy Nguyên Hộ Thể Thuẫn
	182736406: 1008, # Vạn Kiếm Quy Tông
	182736407: 1009, # Nhất Kiếm Trảm Thiên Môn
	182736408: 1010, # Hỏa Long Phun Tức
	182736409: 1011, # Hàn Băng Thiên Kiếm
	182736410: 1012, # Lôi Phạt Cửu Thiên
	182736411: 1013, # Huyền Âm Thôn Hồn
	182736412: 1014, # Thánh Quang Hộ Đạo
	182736413: 1015, # Địa Long Phá Sơn
	182736414: 1016, # Tử Lôi Liên Hoàn
	182736415: 1017, # Hư Không Hấp Tinh
	# Legacy SoM skills (tres id when preserved)
	2089110122: 1020, # Flar
	3219153995: 1021, # Spitfire
	2089220490: 1022, # Inma
	193463731: 1023, # Lum
	2393790290: 1024, # Mana Burst
	2814726266: 1028, # Archer
	2089264065: 1029, # Jump
	123697108: 1027, # Sonic Wave
	229218829: 1034, # Melee (cast skipped)
}

## Display / fallback name → martial id (when only SkillCell.name is known).
const SKILL_NAME_TO_MARTIAL : Dictionary = {
	"Thanh Phong Kiếm Quyết": 1001,
	"Thanh Phong Kiếm Khí": 1002,
	"Trúc Sơn Kiếm Trận": 1003,
	"Đạp Phong Bộ": 1004,
	"Bát Hoang Liệt Không Quyền": 1005,
	"Quy Nguyên Hộ Thể Thuẫn": 1006,
	"Bản Nguyên Kiếm Ý": 1007,
	"Vạn Kiếm Quy Tông": 1008,
	"Nhất Kiếm Trảm Thiên Môn": 1009,
	"Hỏa Long Phun Tức": 1010,
	"Hàn Băng Thiên Kiếm": 1011,
	"Lôi Phạt Cửu Thiên": 1012,
	"Huyền Âm Thôn Hồn": 1013,
	"Thánh Quang Hộ Đạo": 1014,
	"Địa Long Phá Sơn": 1015,
	"Tử Lôi Liên Hoàn": 1016,
	"Hư Không Hấp Tinh": 1017,
	# Legacy SoM
	"Flar": 1020,
	"Spitfire": 1021,
	"Inma": 1022,
	"Lum": 1023,
	"Mana Burst": 1024,
	"Leaf Blades": 1025,
	"Sonic Scream": 1026,
	"Sonic Wave": 1027,
	"Archer": 1028,
	"Jump": 1029,
	"Morph": 1030,
	"Poison": 1031,
	"Run": 1032,
	"Betsanc": 1033,
	"Melee": 1034,
}

## Resolve martial data from SkillCell.id, martial id, or skill display name.
static func GetMartialForSkill(skillID : int, skillName : String = "") -> Dictionary:
	if MARTIAL_CATALOG.has(skillID):
		return MARTIAL_CATALOG[skillID]
	if SKILL_CELL_TO_MARTIAL.has(skillID):
		var mid : int = int(SKILL_CELL_TO_MARTIAL[skillID])
		return MARTIAL_CATALOG.get(mid, {})
	if not skillName.is_empty() and SKILL_NAME_TO_MARTIAL.has(skillName):
		var mid2 : int = int(SKILL_NAME_TO_MARTIAL[skillName])
		return MARTIAL_CATALOG.get(mid2, {})
	return {}

static func GetMartialIdForSkill(skillID : int, skillName : String = "") -> int:
	var data : Dictionary = GetMartialForSkill(skillID, skillName)
	return int(data.get("id", 0))

const MARTIAL_CATALOG : Dictionary = {
	1001: {
		"id": 1001,
		"name": "Thanh Phong Kiếm Quyết",
		"category": Category.SWORD,
		"element": Element.WOOD,
		"grade": Grade.YELLOW,
		"reqRealm": 1,
		"description": "Kiếm quyết trấn sơn của ngoại môn Trúc Sơn Tông. Kiếm phong linh động, kiếm khí như gió thoảng vờn mây, ngưng tụ kiếm ý sắc bén.",
		"qiCost": 0,
		"cooldown": 0.8,
		"subSkills": ["Thanh Phong Sơ Thức", "Lạc Diệp Nhị Thức", "Phá Không Tam Thức"]
	},
	1002: {
		"id": 1002,
		"name": "Thanh Phong Kiếm Khí",
		"category": Category.SWORD,
		"element": Element.WOOD,
		"grade": Grade.YELLOW,
		"reqRealm": 1,
		"description": "Súc tích kiếm khí chém ra một đường kiếm mang tầm xa, xuyên thấu chướng ngại và làm chậm kẻ địch.",
		"qiCost": 8,
		"cooldown": 2.5,
		"range": 220,
		"fxKey": "sword_combo",
		"hitFx": "slash",
		"forceHitFx": true,
		"flipFacing": true
	},
	1003: {
		"id": 1003,
		"name": "Trúc Sơn Kiếm Trận",
		"category": Category.SWORD,
		"element": Element.WOOD,
		"grade": Grade.MYSTIC,
		"reqRealm": 2,
		"description": "Cắm kiếm chỉ thiên, triệu hoán 6 đạo kiếm quang xoay tròn tạo thành Tru Ma Kiếm Trận diện rộng, phá giáp địch thủ.",
		"qiCost": 20,
		"cooldown": 6.0,
		"radius": 100,
		"fxKey": "spin_slash",
		"hitFx": "slash",
		"forceHitFx": true
	},
	1004: {
		"id": 1004,
		"name": "Đạp Phong Bộ",
		"category": Category.MOVEMENT,
		"element": Element.WOOD,
		"grade": Grade.YELLOW,
		"reqRealm": 1,
		"description": "Thân pháp đạp gió lướt nhanh, tiến vào trạng thái Vô Địch trong khoảnh khắc và tăng vọt tốc độ di chuyển.",
		"qiCost": 6,
		"cooldown": 3.0,
		"invulnDuration": 0.35,
		"dashSpeed": 180.0,
		"fxKey": "dash_strike",
		"flipFacing": true
	},
	1005: {
		"id": 1005,
		"name": "Bát Hoang Liệt Không Quyền",
		"category": Category.FIST,
		"element": Element.METAL,
		"grade": Grade.MYSTIC,
		"reqRealm": 2,
		"description": "Quyền kình cương mãnh như núi lửa bộc phát, áp sát oanh kích gây choáng váng địch thủ trong 1.5 giây.",
		"qiCost": 12,
		"cooldown": 4.5,
		"stunDuration": 1.5,
		"fxKey": "ground_pound",
		"hitFx": "ground_slam"
	},
	1006: {
		"id": 1006,
		"name": "Quy Nguyên Hộ Thể Thuẫn",
		"category": Category.SECRET,
		"element": Element.EARTH,
		"grade": Grade.YELLOW,
		"reqRealm": 2,
		"description": "Dẫn dắt linh khí Thổ hệ ngưng tụ kim quang hộ thể, hấp thu thương tổn và kiên cố kinh mạch.",
		"qiCost": 10,
		"cooldown": 8.0,
		"shieldAmount": 80,
		"duration": 6.0,
		"fxKey": "divine_shield",
		"fxPlace": "body",
		"shieldVfx": true
	},
	1007: {
		"id": 1007,
		"name": "Bản Nguyên Kiếm Ý",
		"category": Category.SWORD,
		"element": Element.WOOD,
		"grade": Grade.MYSTIC,
		"reqRealm": 2,
		"description": "Tâm pháp kiếm đạo thụ động. Mỗi tầng Kiếm Khí tích lũy gia tăng 4% Bạo Kích và 6 điểm Công Kích.",
		"qiCost": 0,
		"cooldown": 0.0,
		"isPassive": true
	},
	1008: {
		"id": 1008,
		"name": "Vạn Kiếm Quy Tông",
		"category": Category.SWORD,
		"element": Element.METAL,
		"grade": Grade.EARTH,
		"reqRealm": 3,
		"description": "Triệu trận kiếm quang, vạn kiếm xoay không rồi đồng quy điểm trung tâm — kiếm vũ tuyệt học sát phạt diện rộng.",
		"qiCost": 28,
		"cooldown": 12.0,
		"radius": 140,
		"fxKey": "van_kiem_quy_tong",
		"fxPlace": "floor",
		"hitFx": "slash",
		"forceHitFx": true
	},
	1009: {
		"id": 1009,
		"name": "Nhất Kiếm Trảm Thiên Môn",
		"category": Category.SWORD,
		"element": Element.METAL,
		"grade": Grade.HEAVEN,
		"reqRealm": 4,
		"description": "Ngưng kiếm ý xé mở thiên môn — một kiếm trảm xuống, lôi quang kim sát phạt diện rộng.",
		"qiCost": 36,
		"cooldown": 16.0,
		"radius": 160,
		"fxKey": "nhat_kiem_tram_thien_mon",
		"hitFx": "slash",
		"forceHitFx": true
	},
	1010: {
		"id": 1010,
		"name": "Hỏa Long Phun Tức",
		"category": Category.SECRET,
		"element": Element.FIRE,
		"grade": Grade.MYSTIC,
		"reqRealm": 2,
		"description": "Ngưng hóa long tức phun lửa — pháp thuật Hỏa hệ tu tiên, thiêu đốt diện rộng.",
		"qiCost": 12,
		"cooldown": 5.0,
		"radius": 120,
		"fxKey": "fire_breath",
		"fxPlace": "body_dir",
		"hitFx": "hit_flash",
		"flipFacing": true
	},
	1011: {
		"id": 1011,
		"name": "Hàn Băng Thiên Kiếm",
		"category": Category.SWORD,
		"element": Element.WATER,
		"grade": Grade.MYSTIC,
		"reqRealm": 2,
		"description": "Ngưng băng thành kiếm khí xuyên thấu — Thủy hệ kiếm pháp kết hợp hàn băng pháp thuật.",
		"qiCost": 10,
		"cooldown": 4.0,
		"range": 180,
		"fxKey": "ice_lance_throw",
		"hitFx": "ice_spikes",
		"flipFacing": true
	},
	1012: {
		"id": 1012,
		"name": "Lôi Phạt Cửu Thiên",
		"category": Category.SECRET,
		"element": Element.METAL,
		"grade": Grade.EARTH,
		"reqRealm": 3,
		"description": "Triệu cửu thiên lôi phạt giáng xuống — Kim lôi pháp quyết sát phạt diện rộng.",
		"qiCost": 18,
		"cooldown": 8.0,
		"radius": 150,
		"fxKey": "lightning_call",
		"hitFx": "zap_hit"
	},
	1013: {
		"id": 1013,
		"name": "Huyền Âm Thôn Hồn",
		"category": Category.SECRET,
		"element": Element.WATER,
		"grade": Grade.EARTH,
		"reqRealm": 3,
		"description": "Huyền âm nuốt hồn, bóng tối rút linh khí địch — âm pháp bí thuật.",
		"qiCost": 15,
		"cooldown": 6.0,
		"range": 100,
		"fxKey": "hex_sigil",
		"fxPlace": "body",
		"hitFx": "life_steal"
	},
	1014: {
		"id": 1014,
		"name": "Thánh Quang Hộ Đạo",
		"category": Category.SECRET,
		"element": Element.WOOD,
		"grade": Grade.MYSTIC,
		"reqRealm": 2,
		"description": "Thánh quang hộ đạo — hồi phục khí huyết và thanh tẩy ngoại ma.",
		"qiCost": 8,
		"cooldown": 7.0,
		"fxKey": "holy_smite",
		"hitFx": "heal"
	},
	1015: {
		"id": 1015,
		"name": "Địa Long Phá Sơn",
		"category": Category.FIST,
		"element": Element.EARTH,
		"grade": Grade.EARTH,
		"reqRealm": 3,
		"description": "Địa long trồi lên phá núi — Thổ hệ quyền pháp kết hợp pháp trận chấn địa.",
		"qiCost": 14,
		"cooldown": 6.5,
		"radius": 110,
		"fxKey": "earth_stomp",
		"hitFx": "ground_slam"
	},
	1016: {
		"id": 1016,
		"name": "Tử Lôi Liên Hoàn",
		"category": Category.SECRET,
		"element": Element.METAL,
		"grade": Grade.MYSTIC,
		"reqRealm": 2,
		"description": "Tử lôi nhảy giữa các mục tiêu — liên hoàn lôi pháp Kim hệ.",
		"qiCost": 9,
		"cooldown": 3.5,
		"range": 200,
		"fxKey": "chain_lightning",
		"fxPlace": "body_dir",
		"hitFx": "zap_hit"
	},
	1017: {
		"id": 1017,
		"name": "Hư Không Hấp Tinh",
		"category": Category.SECRET,
		"element": Element.FIRE,
		"grade": Grade.HEAVEN,
		"reqRealm": 4,
		"description": "Mở hư không hấp tinh trận — nuốt linh khí vào điểm vô cực.",
		"qiCost": 24,
		"cooldown": 14.0,
		"radius": 130,
		"fxKey": "black_hole",
		"fxPlace": "floor",
		"hitFx": "implosion"
	},
	# Legacy SoM → PixelFX (single cast, optional hitFx)
	1020: {"id": 1020, "name": "Flar", "category": Category.SECRET, "element": Element.FIRE, "grade": Grade.YELLOW, "fxKey": "fireball_throw", "hitFx": "crit_hit", "flipFacing": true},
	1021: {"id": 1021, "name": "Spitfire", "category": Category.SECRET, "element": Element.FIRE, "grade": Grade.YELLOW, "fxKey": "fire_breath", "hitFx": "hit_spark", "flipFacing": true},
	1022: {"id": 1022, "name": "Inma", "category": Category.SECRET, "element": Element.WATER, "grade": Grade.YELLOW, "fxKey": "ice_lance_throw", "hitFx": "ice_spikes", "flipFacing": true},
	1023: {"id": 1023, "name": "Lum", "category": Category.SECRET, "element": Element.WOOD, "grade": Grade.YELLOW, "fxKey": "heal"},
	1024: {"id": 1024, "name": "Mana Burst", "category": Category.SECRET, "element": Element.METAL, "grade": Grade.YELLOW, "fxKey": "mana_burst", "hitFx": "hit_flash"},
	1025: {"id": 1025, "name": "Leaf Blades", "category": Category.SECRET, "element": Element.WOOD, "grade": Grade.YELLOW, "fxKey": "leaf_storm", "hitFx": "thorns"},
	1026: {"id": 1026, "name": "Sonic Scream", "category": Category.SECRET, "element": Element.METAL, "grade": Grade.YELLOW, "fxKey": "thunderclap", "hitFx": "blunt_hit"},
	1027: {"id": 1027, "name": "Sonic Wave", "category": Category.SECRET, "element": Element.METAL, "grade": Grade.YELLOW, "fxKey": "thunderclap", "hitFx": "blunt_hit"},
	1028: {"id": 1028, "name": "Archer", "category": Category.SECRET, "element": Element.WOOD, "grade": Grade.YELLOW, "fxKey": "arrow_shot", "hitFx": "hit_spark", "flipFacing": true},
	1029: {"id": 1029, "name": "Jump", "category": Category.MOVEMENT, "element": Element.WOOD, "grade": Grade.MORTAL, "fxKey": "dash_strike"},
	1030: {"id": 1030, "name": "Morph", "category": Category.SECRET, "element": Element.WATER, "grade": Grade.YELLOW, "fxKey": "blink_out"},
	1031: {"id": 1031, "name": "Poison", "category": Category.SECRET, "element": Element.WOOD, "grade": Grade.YELLOW, "fxKey": "poison_cloud", "hitFx": "hit_spark"},
	1032: {"id": 1032, "name": "Run", "category": Category.MOVEMENT, "element": Element.WOOD, "grade": Grade.MORTAL, "fxKey": "haste"},
	1033: {"id": 1033, "name": "Betsanc", "category": Category.SECRET, "element": Element.METAL, "grade": Grade.YELLOW, "fxKey": "arcane_orb", "hitFx": "zap_hit"},
	1034: {"id": 1034, "name": "Melee", "category": Category.SWORD, "element": Element.METAL, "grade": Grade.MORTAL, "skipCastFx": true, "hitFx": "slash", "flipFacing": true},
}

# ==============================================================================
# 4. FIVE ELEMENTS (NGŨ HÀNH) RELATION ENGINE
# ==============================================================================
static func GetElementName(elem : Element) -> String:
	match elem:
		Element.METAL: return "Kim"
		Element.WOOD:  return "Mộc"
		Element.WATER: return "Thủy"
		Element.FIRE:  return "Hỏa"
		Element.EARTH: return "Thổ"
		_:             return "Vô Thuộc Tính"

static func GetElementColor(elem : Element) -> Color:
	match elem:
		Element.METAL: return Color(1.0, 0.85, 0.3) # Kim sắc hoàng kim
		Element.WOOD:  return Color(0.3, 0.9, 0.4)  # Mộc sắc thanh lục
		Element.WATER: return Color(0.25, 0.7, 1.0) # Thủy sắc lam ngọc
		Element.FIRE:  return Color(1.0, 0.35, 0.2) # Hỏa sắc xích hồng
		Element.EARTH: return Color(0.85, 0.65, 0.35)# Thổ sắc hoàng thổ
		_:             return Color(0.8, 0.8, 0.8)

## Computes Elemental Counter (Tương Khắc & Tương Sinh)
## Returns { "multiplier": float, "status": String, "isCounter": bool, "isResisted": bool, "feedback": String }
static func EvaluateElementalInteraction(attackerElem : Element, defenderElem : Element) -> Dictionary:
	var res : Dictionary = {
		"multiplier": 1.0,
		"status": "",
		"isCounter": false,
		"isResisted": false,
		"feedback": ""
	}
	if attackerElem == Element.NONE or defenderElem == Element.NONE or attackerElem == defenderElem:
		return res

	# Tương Khắc: Thủy khắc Hỏa, Hỏa khắc Kim, Kim khắc Mộc, Mộc khắc Thổ, Thổ khắc Thủy
	var isCounter : bool = (
		(attackerElem == Element.WATER and defenderElem == Element.FIRE) or
		(attackerElem == Element.FIRE and defenderElem == Element.METAL) or
		(attackerElem == Element.METAL and defenderElem == Element.WOOD) or
		(attackerElem == Element.WOOD and defenderElem == Element.EARTH) or
		(attackerElem == Element.EARTH and defenderElem == Element.WATER)
	)

	# Bị Khắc: Kẻ phòng ngự khắc lại kẻ tấn công
	var isResisted : bool = (
		(defenderElem == Element.WATER and attackerElem == Element.FIRE) or
		(defenderElem == Element.FIRE and attackerElem == Element.METAL) or
		(defenderElem == Element.METAL and attackerElem == Element.WOOD) or
		(defenderElem == Element.WOOD and attackerElem == Element.EARTH) or
		(defenderElem == Element.EARTH and attackerElem == Element.WATER)
	)

	if isCounter:
		res["multiplier"] = 1.25 # +25% sát thương khắc chế
		res["isCounter"] = true
		res["feedback"] = "Ngũ Hành Khắc Chế!"
		match attackerElem:
			Element.FIRE:  res["status"] = "burn"
			Element.WATER: res["status"] = "slow"
			Element.WOOD:  res["status"] = "poison"
			Element.METAL: res["status"] = "paralyze"
			Element.EARTH: res["status"] = "heavy_pressure"
	elif isResisted:
		res["multiplier"] = 0.80 # -20% sát thương khi bị khắc
		res["isResisted"] = true
		res["feedback"] = "Ngũ Hành Bị Khắc"

	return res

## Evaluates Spiritual Root Synergy for player casting a skill of given element
## Returns { "damageBonus": float, "qiCostDiscount": float, "matched": bool }
static func EvaluateRootSynergy(player : Actor, skillElem : Element) -> Dictionary:
	var res : Dictionary = {
		"damageBonus": 0.0,
		"qiCostDiscount": 0.0,
		"matched": false
	}
	if not player or skillElem == Element.NONE:
		return res

	var CultivationClass = preload("res://sources/actor/Cultivation.gd")
	var rootInfo = CultivationClass.CalculateSpiritualRoot(player)
	var rootName : String = rootInfo.get("name", "")
	var elemName : String = GetElementName(skillElem)

	if rootName.contains(elemName) or rootName.contains("Hỗn Độn") or rootName.contains("Thiên Linh Căn"):
		res["damageBonus"] = 0.15      # +15% sát thương do linh căn tương hợp
		res["qiCostDiscount"] = 0.10   # Giảm 10% tiêu hao Linh Lực
		res["matched"] = true

	return res

# ==============================================================================
# 5. SWORD CULTIVATION (KIẾM TU & KIẾM KHÍ)
# ==============================================================================
const MAX_SWORD_QI : int = 5

static func GetSwordQi(agent : Node) -> int:
	if not agent: return 0
	var id : int = agent.get_instance_id()
	return swordQiStorage.get(id, 0)

static func AddSwordQi(agent : Node, amount : int = 1) -> int:
	if not agent: return 0
	var id : int = agent.get_instance_id()
	var current : int = swordQiStorage.get(id, 0)
	var updated : int = clampi(current + amount, 0, MAX_SWORD_QI)
	swordQiStorage[id] = updated
	return updated

static func ConsumeSwordQi(agent : Node, amount : int) -> bool:
	if not agent: return false
	var id : int = agent.get_instance_id()
	var current : int = swordQiStorage.get(id, 0)
	if current >= amount:
		swordQiStorage[id] = current - amount
		return true
	return false

## Returns sword intent attack and crit bonus from accumulated Sword Qi
static func GetSwordIntentBonus(agent : Node) -> Dictionary:
	var qi : int = GetSwordQi(agent)
	return {
		"qi": qi,
		"attackBonus": qi * 6,
		"critRateBonus": qi * 0.04,
		"isMax": (qi >= MAX_SWORD_QI)
	}

# ==============================================================================
# 6. COMBO SYSTEM (LIÊN KÍCH)
# ==============================================================================
const COMBO_WINDOW : float = 1.3 # 1.3 seconds window to connect next combo hit

static func GetComboStep(agent : Node) -> int:
	if not agent: return 1
	var id : int = agent.get_instance_id()
	var data : Dictionary = comboStorage.get(id, {})
	var lastTime : float = data.get("lastTime", 0.0)
	var currentTime : float = Time.get_ticks_msec() / 1000.0

	if currentTime - lastTime > COMBO_WINDOW:
		return 1
	return data.get("step", 1)

## Advances combo step upon attack execution, returns { "step": int, "name": String, "damageRatio": float, "knockback": float }
static func AdvanceCombo(agent : Node) -> Dictionary:
	var id : int = agent.get_instance_id()
	var currentStep : int = GetComboStep(agent)
	var currentTime : float = Time.get_ticks_msec() / 1000.0
	
	var comboInfo : Dictionary = {
		"step": currentStep,
		"name": "",
		"damageRatio": 1.0,
		"knockback": 0.0,
		"gainsSwordQi": 1
	}

	match currentStep:
		1:
			comboInfo["name"] = "Thanh Phong Sơ Thức"
			comboInfo["damageRatio"] = 1.0
			comboInfo["knockback"] = 10.0
			comboStorage[id] = { "step": 2, "lastTime": currentTime }
		2:
			comboInfo["name"] = "Lạc Diệp Nhị Thức"
			comboInfo["damageRatio"] = 1.25
			comboInfo["knockback"] = 25.0
			comboStorage[id] = { "step": 3, "lastTime": currentTime }
		3:
			comboInfo["name"] = "Phá Không Tam Thức (Đoạn Không)"
			comboInfo["damageRatio"] = 1.60
			comboInfo["knockback"] = 65.0
			comboInfo["gainsSwordQi"] = 2 # Finisher grants bonus Sword Qi!
			# Combo finished, loop back to step 1
			comboStorage[id] = { "step": 1, "lastTime": currentTime }

	# Accumulate Sword Qi on sword attacks
	AddSwordQi(agent, comboInfo["gainsSwordQi"])
	return comboInfo

static func ResetCombo(agent : Node):
	if agent:
		var id : int = agent.get_instance_id()
		comboStorage.erase(id)

# ==============================================================================
# 7. INVULNERABILITY & STATUS EFFECTS
# ==============================================================================
static func SetInvulnerable(agent : Node, duration : float):
	if agent:
		var id : int = agent.get_instance_id()
		var expiry : float = (Time.get_ticks_msec() / 1000.0) + duration
		invulnerableUntil[id] = expiry

static func IsInvulnerable(agent : Node) -> bool:
	if not agent: return false
	var id : int = agent.get_instance_id()
	var expiry : float = invulnerableUntil.get(id, 0.0)
	return (Time.get_ticks_msec() / 1000.0) < expiry

static func ApplyStatusEffect(target : Node, effectName : String, duration : float, potency : float = 1.0):
	if not target or not ActorCommons.IsAlive(target): return
	var id : int = target.get_instance_id()
	if not statusEffects.has(id):
		statusEffects[id] = {}
	
	statusEffects[id][effectName] = {
		"expiry": (Time.get_ticks_msec() / 1000.0) + duration,
		"potency": potency
	}

static func HasStatusEffect(target : Node, effectName : String) -> bool:
	if not target: return false
	var id : int = target.get_instance_id()
	if not statusEffects.has(id) or not statusEffects[id].has(effectName):
		return false
	var effect = statusEffects[id][effectName]
	return (Time.get_ticks_msec() / 1000.0) < effect["expiry"]

# ==============================================================================
# 8. ADVANCED DAMAGE & COMBAT CALCULATION (DOUBLE-DAMAGE SHIELDED)
# ==============================================================================
## Calculates comprehensive combat result with Debounce & Full Xianxia Mechanics
static func CalculateAdvancedCombat(
	attacker : Node,
	target : Node,
	skill : SkillCell,
	martialId : int = 1001,
	isComboAttack : bool = false
) -> Dictionary:
	var result : Dictionary = {
		"damage": 0,
		"alteration": ActorCommons.Alteration.HIT,
		"isCrit": false,
		"isDodge": false,
		"isInvulnerable": false,
		"elementalCounter": false,
		"elementalResisted": false,
		"knockbackVector": Vector2.ZERO,
		"statusApplied": "",
		"feedbackText": ""
	}

	if not attacker or not target or not ActorCommons.IsAlive(target):
		return result

	var aRID : int = attacker.get_instance_id()
	var tRID : int = target.get_instance_id()
	var currentTime : float = Time.get_ticks_msec() / 1000.0

	# 1. Double-Damage Debounce Protection (0.15s cooldown per hit pair)
	var hitKey : String = "%d_%d_%d" % [aRID, tRID, martialId]
	if lastHitTimestamps.has(hitKey) and (currentTime - lastHitTimestamps[hitKey]) < 0.15:
		return result # Silently ignore repeated duplicate call
	lastHitTimestamps[hitKey] = currentTime

	# 2. Check Target Invulnerability (e.g. Đạp Phong Bộ / Dodge iframe)
	if IsInvulnerable(target):
		result["isInvulnerable"] = true
		result["alteration"] = ActorCommons.Alteration.DODGE
		result["feedbackText"] = "Vô Địch!"
		return result

	# 3. Check Hit / Dodge Rate
	var evadeRate : float = Formula.GetEvadeRate(attacker.stat, target.stat)
	if randf() < evadeRate:
		result["isDodge"] = true
		result["alteration"] = ActorCommons.Alteration.DODGE
		result["feedbackText"] = "Né Tránh"
		return result

	# 4. Resolve Martial Art Data & Elements
	var martialData : Dictionary = MARTIAL_CATALOG.get(martialId, {})
	var skillElem : Element = martialData.get("element", Element.NONE)
	
	# Determine target element (Boss is Fire, Forest monsters Wood/Earth, etc.)
	var targetElem : Element = Element.NONE
	if target.data:
		if target.data._isBoss:
			targetElem = Element.FIRE # Xích Viêm Thú Hậu là Hỏa hệ
		elif target.data._id == 3264333316: # Maggot / Sâu độc
			targetElem = Element.WOOD # Mộc hệ / Độc
		else:
			targetElem = Element.EARTH

	# 5. Base Damage Calculation
	var rawAtk : int = attacker.stat.current.attack
	var rawDef : int = target.stat.current.defense
	var baseDmg : float = maxf(1.0, float(rawAtk - rawDef))

	# 6. Combo Scaling
	var comboKnockbackDist : float = 15.0
	if isComboAttack:
		var comboRes = AdvanceCombo(attacker)
		baseDmg *= comboRes["damageRatio"]
		comboKnockbackDist = comboRes["knockback"]
		if not comboRes["name"].is_empty():
			result["feedbackText"] = comboRes["name"]

	# 7. Sword Intent Bonus
	var swordIntent = GetSwordIntentBonus(attacker)
	baseDmg += swordIntent["attackBonus"]

	# 8. Elemental Counter & Root Synergy
	var elemEval = EvaluateElementalInteraction(skillElem, targetElem)
	baseDmg *= elemEval["multiplier"]
	if elemEval["isCounter"]:
		result["elementalCounter"] = true
		result["statusApplied"] = elemEval["status"]
	elif elemEval["isResisted"]:
		result["elementalResisted"] = true

	var rootSynergy = EvaluateRootSynergy(attacker, skillElem)
	if rootSynergy["matched"]:
		baseDmg *= (1.0 + rootSynergy["damageBonus"])

	# 9. Critical Hit Calculation
	var critChance : float = attacker.stat.current.critRate + swordIntent["critRateBonus"]
	if randf() < critChance:
		result["isCrit"] = true
		result["alteration"] = ActorCommons.Alteration.CRIT
		baseDmg *= 2.0
		result["feedbackText"] = "Bạo Kích!"

	# 10. Final Clamp & Knockback
	var finalDmg : int = maxi(1, int(round(baseDmg)))

	# Check Spiritual Treasure Shield (Huyền Quy Kính)
	var targetId = target.get_instance_id()
	var CraftingSystemClass = preload("res://sources/crafting/CraftingSystem.gd")
	if CraftingSystemClass.activeShields.has(targetId) and CraftingSystemClass.activeShields[targetId] > 0:
		var shield = CraftingSystemClass.activeShields[targetId]
		if shield >= finalDmg:
			CraftingSystemClass.activeShields[targetId] -= finalDmg
			finalDmg = 0
			result["feedbackText"] = "Huyền Quy Khiên Chắn!"
		else:
			finalDmg -= int(shield)
			CraftingSystemClass.activeShields[targetId] = 0
			result["feedbackText"] = "Khiên Vỡ!"

	# Check Tị Hỏa Đan elemental fire resistance
	if skillElem == Element.FIRE and target.has_meta("fire_resist_until") and Time.get_unix_time_from_system() < target.get_meta("fire_resist_until"):
		finalDmg = maxi(1, int(finalDmg * 0.5))
		result["feedbackText"] = "Tị Hỏa Kháng Hỏa!"

	# Check Xích Viêm Đan burn enhancement
	if attacker.has_meta("xich_viem_burn_attack") and attacker.get_meta("xich_viem_burn_attack"):
		result["statusApplied"] = "burn"

	result["damage"] = finalDmg

	var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
	result["element"] = skillElem
	result["knockbackVector"] = CombatVisualSystemClass.CalculateControlledKnockback(attacker.position, target.position, comboKnockbackDist)

	# Apply damage & update attacker agro
	target.stat.SetHealth(-finalDmg)
	if target is AIAgent and target.aiTimer and is_instance_valid(target.aiTimer) and target.aiTimer.timeout.get_connections().size() > 0:
		target.AddAttacker(attacker, finalDmg)
		AI.Refresh(target)

	# Apply Knockback physically if target can move
	if target is CharacterBody2D:
		target.position += result["knockbackVector"] * 0.2

	return result

# ==============================================================================
# 9. TELEGRAPHED DANGER ZONE (BOSS MECHANICS)
# ==============================================================================
## Spawns an animated visual circular danger telegraph zone before powerful Boss attacks
static func CreateDangerTelegraph(
	parent : Node2D,
	pos : Vector2,
	radius : float,
	duration : float,
	onDetonate : Callable
) -> Node2D:
	if not parent: return null
	
	var DangerZoneClass = preload("res://sources/combat/DangerTelegraphZone.gd")
	var telegraphNode : Node2D = DangerZoneClass.new()
	telegraphNode.position = pos
	telegraphNode.name = "DangerTelegraphZone"
	telegraphNode.set("radius", radius)
	telegraphNode.set("duration", duration)
	telegraphNode.set("onDetonate", onDetonate)
	
	parent.add_child(telegraphNode)
	return telegraphNode

# ==============================================================================
# 10. SQLITE PERSISTENCE FOR MARTIAL ARTS & COMBAT PROGRESSION
# ==============================================================================
static func EnsureMartialArtsTable(db : SQLite) -> bool:
	if not db: return false
	var query : String = """
CREATE TABLE IF NOT EXISTS char_martial_arts (
	char_id INTEGER NOT NULL,
	martial_id INTEGER NOT NULL,
	mastery_level INTEGER NOT NULL DEFAULT 1,
	mastery_exp INTEGER NOT NULL DEFAULT 0,
	equipped_slot INTEGER NOT NULL DEFAULT -1,
	PRIMARY KEY (char_id, martial_id)
);
"""
	return db.query(query)

static func SaveMartialArt(db : SQLite, charId : int, martialId : int, masteryLevel : int, exp : int, slot : int = -1) -> bool:
	if not db: return false
	var query : String = """
INSERT INTO char_martial_arts (char_id, martial_id, mastery_level, mastery_exp, equipped_slot)
VALUES (%d, %d, %d, %d, %d)
ON CONFLICT (char_id, martial_id) DO UPDATE SET
	mastery_level = excluded.mastery_level,
	mastery_exp = excluded.mastery_exp,
	equipped_slot = excluded.equipped_slot;
""" % [charId, martialId, masteryLevel, exp, slot]
	return db.query(query)

static func LoadMartialArts(db : SQLite, charId : int) -> Array[Dictionary]:
	if not db: return []
	var query : String = "SELECT * FROM char_martial_arts WHERE char_id = %d;" % charId
	if db.query(query):
		return db.query_result
	return []
