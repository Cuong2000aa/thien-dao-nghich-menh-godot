extends RefCounted
class_name CraftingSystem

## TDNM — BUILD 07: IMMERSIVE CULTIVATION ECONOMY, ALCHEMY, FORGING & TREASURE ARTIFACTS
## Authoritative Master Crafting Engine unifying Alchemy, Forging, Refinement, 
## Spiritual Treasures, 4 Cultivation Professions, Sect Economy, and SQLite Persistence.

# ==============================================================================
# 1. TAXONOMY & ENUMS
# ==============================================================================
enum Profession {
	ALCHEMIST = 0,   # Luyện Đan Sư
	FORGEMASTER = 1, # Luyện Khí Sư
	HERBALIST = 2,   # Linh Thực Sư
	MINER = 3        # Khai Khoáng Sư
}

enum ProfessionRank {
	INITIATE = 1,    # Nhập Môn (Exp 0 - 100)
	ADEPT = 2,       # Thành Thạo (Exp 100 - 300)
	EXPERT = 3,      # Tinh Thông (Exp 300 - 700)
	MASTER = 4,      # Đại Sư (Exp 700 - 1500)
	GRANDMASTER = 5  # Tông Sư (Exp 1500+)
}

enum FurnaceTier {
	THANH_DONG = 0,  # Thanh Đồng Đỉnh (Cơ bản)
	BAT_QUAI = 1,    # Bát Quái Luyện Đan Lô (Trung cấp)
	TU_NGOC = 2      # Tử Ngọc Lô (Thượng cấp)
}

enum ItemQuality {
	MORTAL = 0,      # Phàm Phẩm
	LOW = 1,         # Hạ Phẩm
	MID = 2,         # Trung Phẩm
	HIGH = 3,        # Thượng Phẩm
	SUPREME = 4      # Cực Phẩm
}

const PROF_RANKS_EXP = {
	ProfessionRank.INITIATE: 0,
	ProfessionRank.ADEPT: 100,
	ProfessionRank.EXPERT: 300,
	ProfessionRank.MASTER: 700,
	ProfessionRank.GRANDMASTER: 1500
}

# Cooldown tracking for Spiritual Treasures: String (agentRid_treasureId) -> float expiry
static var treasureCooldowns : Dictionary = {}

# Active Spiritual Treasure shield values: int (agentRid) -> float remainingShield
static var activeShields : Dictionary = {}

# Active Cultivation Speed Multipliers: int (agentRid) -> { "multiplier": float, "expires": float }
static var cultivationSpeedBuffs : Dictionary = {}

# In-memory item refinement cache: String ("charId_itemId_custom") -> Dictionary
static var itemRefinements : Dictionary = {}

# In-memory player professions cache: int (charId) -> Dictionary { profId: { "rank": int, "exp": int } }
static var playerProfessions : Dictionary = {}

# ==============================================================================
# 2. ALCHEMY RECIPES CATALOG (12 RECIPES)
# ==============================================================================
const ALCHEMY_RECIPES : Dictionary = {
	"HOI_XUAN": {
		"id": "HOI_XUAN",
		"name": "Hồi Xuân Đan",
		"category": "Hồi Phục",
		"professionReq": ProfessionRank.INITIATE,
		"levelReq": 1,
		"materials": { "Maggot Slime": 2, "Ngan Linh Thao": 1 },
		"resultItem": "Hoi Xuan Dan",
		"baseSuccessRate": 0.90,
		"expGain": 25,
		"effectDesc": "Hồi phục ngay 120 điểm Khí Huyết."
	},
	"DAI_HOI_XUAN": {
		"id": "DAI_HOI_XUAN",
		"name": "Đại Hồi Xuân Đan",
		"category": "Hồi Phục",
		"professionReq": ProfessionRank.ADEPT,
		"levelReq": 3,
		"materials": { "Ngan Linh Thao": 3, "U Hon Thao": 1, "Huyet Sam": 1 },
		"resultItem": "Dai Hoi Xuan Dan",
		"baseSuccessRate": 0.80,
		"expGain": 45,
		"effectDesc": "Hồi phục ngay 350 điểm Khí Huyết."
	},
	"BO_KHI": {
		"id": "BO_KHI",
		"name": "Bổ Khí Đan",
		"category": "Hồi Phục",
		"professionReq": ProfessionRank.INITIATE,
		"levelReq": 1,
		"materials": { "Maggot Slime": 1, "Ngan Linh Thao": 2 },
		"resultItem": "Bo Khi Dan",
		"baseSuccessRate": 0.90,
		"expGain": 25,
		"effectDesc": "Hồi phục ngay 80 điểm Linh Lực (MP)."
	},
	"NGUNG_THAN": {
		"id": "NGUNG_THAN",
		"name": "Ngưng Thần Đan",
		"category": "Hồi Phục",
		"professionReq": ProfessionRank.ADEPT,
		"levelReq": 3,
		"materials": { "Ngan Linh Thao": 2, "U Hon Thao": 2 },
		"resultItem": "Ngung Than Dan",
		"baseSuccessRate": 0.80,
		"expGain": 45,
		"effectDesc": "Hồi phục ngay 200 điểm Linh Lực (MP)."
	},
	"TU_KHI": {
		"id": "TU_KHI",
		"name": "Tụ Khí Đan",
		"category": "Tu Luyện",
		"professionReq": ProfessionRank.ADEPT,
		"levelReq": 2,
		"materials": { "Ngan Linh Thao": 3, "Linh Thach Thuong Pham": 1 },
		"resultItem": "Tu Khi Dan",
		"baseSuccessRate": 0.75,
		"expGain": 50,
		"effectDesc": "Gia tăng lập tức +150 điểm Tu Vi."
	},
	"KIM_CANG": {
		"id": "KIM_CANG",
		"name": "Kim Cang Đan",
		"category": "Phòng Ngự",
		"professionReq": ProfessionRank.EXPERT,
		"levelReq": 5,
		"materials": { "Huyen Thiet Khoang": 2, "Ngan Linh Thao": 2, "Bach Ngan Khoang": 1 },
		"resultItem": "Kim Cang Dan",
		"baseSuccessRate": 0.70,
		"expGain": 60,
		"effectDesc": "Tăng 15 điểm Phòng Ngự trong 120 giây."
	},
	"BAO_NGUYEN": {
		"id": "BAO_NGUYEN",
		"name": "Bạo Nguyên Đan",
		"category": "Công Kích",
		"professionReq": ProfessionRank.EXPERT,
		"levelReq": 5,
		"materials": { "Xich Viem Khoang": 1, "Ngan Linh Thao": 2, "Huyet Sam": 1 },
		"resultItem": "Bao Nguyen Dan",
		"baseSuccessRate": 0.70,
		"expGain": 60,
		"effectDesc": "Tăng 20 điểm Công Kích trong 120 giây."
	},
	"THANH_TAM": {
		"id": "THANH_TAM",
		"name": "Thanh Tâm Đan",
		"category": "Giải Độc",
		"professionReq": ProfessionRank.ADEPT,
		"levelReq": 4,
		"materials": { "U Hon Thao": 2, "Ngan Linh Thao": 2 },
		"resultItem": "Thanh Tam Dan",
		"baseSuccessRate": 0.80,
		"expGain": 40,
		"effectDesc": "Hóa giải toàn bộ trúng độc và miễn nhiễm độc trong 60 giây."
	},
	"TI_HOA": {
		"id": "TI_HOA",
		"name": "Tị Hỏa Đan",
		"category": "Kháng Thuộc Tính",
		"professionReq": ProfessionRank.EXPERT,
		"levelReq": 6,
		"materials": { "U Hon Thao": 2, "Bach Ngan Khoang": 1, "Ngan Linh Thao": 2 },
		"resultItem": "Ti Hoa Dan",
		"baseSuccessRate": 0.70,
		"expGain": 55,
		"effectDesc": "Giảm 50% sát thương Hỏa hệ và thiêu đốt trong 120 giây."
	},
	"TRUC_CO": {
		"id": "TRUC_CO",
		"name": "Trúc Cơ Đan",
		"category": "Đột Phá",
		"professionReq": ProfessionRank.MASTER,
		"levelReq": 9,
		"materials": { "U Hon Thao": 3, "Huyet Sam": 2, "Linh Thach Thuong Pham": 2 },
		"resultItem": "Truc Co Dan",
		"baseSuccessRate": 0.55,
		"expGain": 120,
		"effectDesc": "Gia tăng 30% tỷ lệ đột phá cảnh giới và hộ mệnh chống phản phệ."
	},
	"TOI_THE": {
		"id": "TOI_THE",
		"name": "Tôi Thể Đan",
		"category": "Luyện Thể",
		"professionReq": ProfessionRank.MASTER,
		"levelReq": 7,
		"materials": { "Yeu Thu Huyet Tinh": 3, "Huyen Thiet Khoang": 3, "Huyet Sam": 1 },
		"resultItem": "Toi The Dan",
		"baseSuccessRate": 0.60,
		"expGain": 90,
		"effectDesc": "Tôi luyện gân cốt, tăng vĩnh viễn +50 Khí Huyết Tối Đa."
	},
	"XICH_VIEM": {
		"id": "XICH_VIEM",
		"name": "Xích Viêm Đan",
		"category": "Dị Đan Boss",
		"professionReq": ProfessionRank.GRANDMASTER,
		"levelReq": 10,
		"materials": { "Xich Viem Yeu Dan": 1, "Huyet Sam": 2, "Xich Viem Khoang": 2 },
		"resultItem": "Xich Viem Dan",
		"baseSuccessRate": 0.50,
		"expGain": 180,
		"effectDesc": "Tăng 40 Công Kích và gây Thiêu Đốt đối thủ trong 120 giây."
	},
	"CUU_DIEP_HOI_XUAN": {
		"id": "CUU_DIEP_HOI_XUAN",
		"name": "Cửu Diệp Hồi Xuân Đan",
		"category": "Cổ Đan Phá Cảnh",
		"professionReq": ProfessionRank.MASTER,
		"levelReq": 8,
		"materials": { "Cuu Diep Ngoc Chi": 1, "U Hon Huyet Dang": 2, "Linh Thach Thuong Pham": 1 },
		"resultItem": "Dai Hoi Xuan Dan",
		"baseSuccessRate": 0.75,
		"expGain": 140,
		"effectDesc": "Cổ đan luyện từ Cửu Diệp Ngọc Chi và U Hồn Huyết Đằng, hồi phục tức thì 500 Khí Huyết và tăng mạnh tu vi."
	}
}

# ==============================================================================
# 3. FORGING RECIPES CATALOG (10 RECIPES)
# ==============================================================================
const FORGE_RECIPES : Dictionary = {
	"THANH_PHONG_KIEM": {
		"id": "THANH_PHONG_KIEM",
		"name": "Thanh Phong Kiếm",
		"category": "Vũ Khí",
		"slot": ActorCommons.Slot.WEAPON,
		"professionReq": ProfessionRank.INITIATE,
		"levelReq": 1,
		"materials": { "Huyen Thiet Khoang": 3, "Thanh Phong Tinh Thiet": 1 },
		"resultItem": "Thanh Phong Kiem",
		"baseSuccessRate": 0.90,
		"expGain": 40,
		"effectDesc": "Kiếm hạ phẩm (+24 Công Kích, +5% Bạo Kích)."
	},
	"BACH_NGAN_KIEM": {
		"id": "BACH_NGAN_KIEM",
		"name": "Bạch Ngân Kiếm",
		"category": "Vũ Khí",
		"slot": ActorCommons.Slot.WEAPON,
		"professionReq": ProfessionRank.ADEPT,
		"levelReq": 4,
		"materials": { "Bach Ngan Khoang": 3, "Thanh Phong Tinh Thiet": 2 },
		"resultItem": "Bach Ngan Kiem",
		"baseSuccessRate": 0.80,
		"expGain": 70,
		"effectDesc": "Kiếm trung phẩm (+38 Công Kích, +8% Bạo Kích)."
	},
	"XICH_VIEM_KIEM": {
		"id": "XICH_VIEM_KIEM",
		"name": "Xích Viêm Kiếm",
		"category": "Vũ Khí",
		"slot": ActorCommons.Slot.WEAPON,
		"professionReq": ProfessionRank.EXPERT,
		"levelReq": 8,
		"materials": { "Xich Viem Khoang": 2, "Xich Viem Yeu Dan": 1, "Thanh Phong Tinh Thiet": 2 },
		"resultItem": "Xich Viem Kiem",
		"baseSuccessRate": 0.65,
		"expGain": 120,
		"effectDesc": "Kiếm thượng phẩm Hỏa hệ (+58 Công Kích, +12% Bạo Kích)."
	},
	"TRUC_SON_DAO_BAO": {
		"id": "TRUC_SON_DAO_BAO",
		"name": "Trúc Sơn Đạo Bào",
		"category": "Phòng Cụ",
		"slot": ActorCommons.Slot.CHEST,
		"professionReq": ProfessionRank.INITIATE,
		"levelReq": 1,
		"materials": { "Ngan Linh Thao": 4, "U Hon Thao": 2 },
		"resultItem": "Truc Son Dao Bao",
		"baseSuccessRate": 0.90,
		"expGain": 40,
		"effectDesc": "Đạo bào tông môn (+8 Phòng Ngự, +30 HP)."
	},
	"HUYEN_THIET_GIAP": {
		"id": "HUYEN_THIET_GIAP",
		"name": "Huyền Thiết Giáp",
		"category": "Phòng Cụ",
		"slot": ActorCommons.Slot.CHEST,
		"professionReq": ProfessionRank.ADEPT,
		"levelReq": 4,
		"materials": { "Huyen Thiet Khoang": 5, "Bach Ngan Khoang": 2 },
		"resultItem": "Huyen Thiet Giap",
		"baseSuccessRate": 0.75,
		"expGain": 80,
		"effectDesc": "Chiến giáp kiên cố (+26 Phòng Ngự, +120 HP)."
	},
	"XICH_VIEM_BAO_CHAU": {
		"id": "XICH_VIEM_BAO_CHAU",
		"name": "Xích Viêm Bảo Châu",
		"category": "Phụ Kiện",
		"slot": ActorCommons.Slot.NECK,
		"professionReq": ProfessionRank.INITIATE,
		"levelReq": 2,
		"materials": { "Xich Viem Khoang": 2, "Maggot Slime": 2 },
		"resultItem": "Xich Viem Bao Chau",
		"baseSuccessRate": 0.85,
		"expGain": 50,
		"effectDesc": "Bội châu tỏa nhiệt (+8 Công Kích, +4 Phòng Ngự)."
	},
	"THANH_NGOC_BOI": {
		"id": "THANH_NGOC_BOI",
		"name": "Thanh Ngọc Bội",
		"category": "Phụ Kiện",
		"slot": ActorCommons.Slot.NECK,
		"professionReq": ProfessionRank.ADEPT,
		"levelReq": 5,
		"materials": { "Bach Ngan Khoang": 2, "U Hon Thao": 2 },
		"resultItem": "Thanh Ngoc Boi",
		"baseSuccessRate": 0.80,
		"expGain": 60,
		"effectDesc": "Ngọc bội dưỡng thần (+14 Phòng Ngự, +80 MP)."
	},
	"HUYEN_QUY_KINH": {
		"id": "HUYEN_QUY_KINH",
		"name": "Huyền Quy Kính",
		"category": "Pháp Bảo",
		"slot": ActorCommons.Slot.NECK,
		"professionReq": ProfessionRank.MASTER,
		"levelReq": 8,
		"materials": { "Huyen Thiet Khoang": 4, "Bach Ngan Khoang": 2, "Yeu Thu Huyet Tinh": 2 },
		"resultItem": "Huyen Quy Kinh",
		"baseSuccessRate": 0.60,
		"expGain": 150,
		"effectDesc": "Pháp bảo phòng thủ (+35 Phòng Ngự, kỹ năng tạo khiên chắn 200 HP)."
	},
	"XICH_VIEM_HOA_HO": {
		"id": "XICH_VIEM_HOA_HO",
		"name": "Xích Viêm Hỏa Hồ",
		"category": "Pháp Bảo",
		"slot": ActorCommons.Slot.NECK,
		"professionReq": ProfessionRank.MASTER,
		"levelReq": 9,
		"materials": { "Xich Viem Khoang": 3, "Xich Viem Yeu Dan": 1, "Thanh Phong Tinh Thiet": 2 },
		"resultItem": "Xich Viem Hoa Ho",
		"baseSuccessRate": 0.55,
		"expGain": 160,
		"effectDesc": "Pháp bảo công kích (+45 Công Kích, kỹ năng phun lửa 180 sát thương)."
	},
	"CAN_KHON_TU_LINH_DINH": {
		"id": "CAN_KHON_TU_LINH_DINH",
		"name": "Càn Khôn Tụ Linh Đỉnh",
		"category": "Pháp Bảo",
		"slot": ActorCommons.Slot.NECK,
		"professionReq": ProfessionRank.GRANDMASTER,
		"levelReq": 10,
		"materials": { "Bach Ngan Khoang": 3, "U Hon Thao": 3, "Linh Thach Thuong Pham": 2 },
		"resultItem": "Can Khon Tu Linh Dinh",
		"baseSuccessRate": 0.50,
		"expGain": 200,
		"effectDesc": "Pháp bảo tu luyện (+150 MP, hồi 100 MP, +50 Tu Vi, +50% tốc độ tu luyện)."
	},
	"THANH_PHONG_CO_KIEM": {
		"id": "THANH_PHONG_CO_KIEM",
		"name": "Thanh Phong Cổ Kiếm",
		"category": "Vũ Khí Cổ",
		"slot": ActorCommons.Slot.WEAPON,
		"professionReq": ProfessionRank.MASTER,
		"levelReq": 6,
		"materials": { "Co Linh Thiet": 2, "Huyen Hoang Thach": 1, "Thanh Phong Tinh Thiet": 1 },
		"resultItem": "Thanh Phong Co Kiem",
		"baseSuccessRate": 0.70,
		"expGain": 130,
		"effectDesc": "Cổ kiếm đúc từ Cổ Linh Thiết và Huyền Hoàng Thạch (+32 Công Kích, +8% Bạo Kích)."
	}
}

# ==============================================================================
# 4. PROFESSION MANAGEMENT & PROGRESSION
# ==============================================================================
static func GetProfessionName(prof : Profession) -> String:
	match prof:
		Profession.ALCHEMIST:   return "Luyện Đan Sư"
		Profession.FORGEMASTER: return "Luyện Khí Sư"
		Profession.HERBALIST:   return "Linh Thực Sư"
		Profession.MINER:       return "Khai Khoáng Sư"
		_:                      return "Bách Nghệ"

static func GetRankName(rank : ProfessionRank) -> String:
	match rank:
		ProfessionRank.INITIATE:    return "Nhập Môn"
		ProfessionRank.ADEPT:       return "Thành Thạo"
		ProfessionRank.EXPERT:      return "Tinh Thông"
		ProfessionRank.MASTER:      return "Đại Sư"
		ProfessionRank.GRANDMASTER: return "Tông Sư"
		_:                          return "Vô Phẩm"

static func GetProfessionData(actor : Node, prof : Profession) -> Dictionary:
	var charId : int = _GetCharId(actor)
	if not playerProfessions.has(charId):
		playerProfessions[charId] = {}
	
	if not playerProfessions[charId].has(prof):
		playerProfessions[charId][prof] = { "rank": ProfessionRank.INITIATE, "exp": 0 }
	
	return playerProfessions[charId][prof]

static func AddProfessionExp(actor : Node, prof : Profession, amount : int) -> Dictionary:
	var data = GetProfessionData(actor, prof)
	var oldRank = data["rank"]
	data["exp"] += amount
	
	# Check rank upgrade
	var newRank = oldRank
	if data["exp"] >= PROF_RANKS_EXP[ProfessionRank.GRANDMASTER]:
		newRank = ProfessionRank.GRANDMASTER
	elif data["exp"] >= PROF_RANKS_EXP[ProfessionRank.MASTER]:
		newRank = ProfessionRank.MASTER
	elif data["exp"] >= PROF_RANKS_EXP[ProfessionRank.EXPERT]:
		newRank = ProfessionRank.EXPERT
	elif data["exp"] >= PROF_RANKS_EXP[ProfessionRank.ADEPT]:
		newRank = ProfessionRank.ADEPT
	else:
		newRank = ProfessionRank.INITIATE
	
	data["rank"] = newRank
	var charId : int = _GetCharId(actor)
	playerProfessions[charId][prof] = data
	
	var isPromoted : bool = (newRank > oldRank)
	if isPromoted and actor is PlayerAgent:
		Network.PushNotification("Chúc mừng đạo hữu! Nghề [%s] đã đột phá lên cấp bậc [%s]!" % [GetProfessionName(prof), GetRankName(newRank)], actor.peerID)
	
	# SQLite persistence if available
	if Launcher.SQL and Launcher.SQL.db:
		SaveProfession(Launcher.SQL.db, charId, prof, newRank, data["exp"])
		
	return { "rank": newRank, "exp": data["exp"], "promoted": isPromoted }

# ==============================================================================
# 5. ALCHEMY ENGINE (LUYỆN ĐAN)
# ==============================================================================
static func GetFurnaceBonus(tier : FurnaceTier) -> Dictionary:
	match tier:
		FurnaceTier.THANH_DONG:
			return { "name": "Thanh Đồng Đỉnh", "bonusRate": 0.0, "purityBonus": 0.0 }
		FurnaceTier.BAT_QUAI:
			return { "name": "Bát Quái Luyện Đan Lô", "bonusRate": 0.15, "purityBonus": 0.10 }
		FurnaceTier.TU_NGOC:
			return { "name": "Tử Ngọc Lô", "bonusRate": 0.30, "purityBonus": 0.25 }
		_:
			return { "name": "Thanh Đồng Đỉnh", "bonusRate": 0.0, "purityBonus": 0.0 }

static func CanBrewElixir(actor : Node, recipeId : String, furnaceTier : FurnaceTier = FurnaceTier.BAT_QUAI) -> Dictionary:
	var res = { "canCraft": false, "reason": "", "successRate": 0.0, "missingMaterials": {} }
	if not ALCHEMY_RECIPES.has(recipeId):
		res["reason"] = "Công thức luyện đan không tồn tại!"
		return res
		
	var recipe = ALCHEMY_RECIPES[recipeId]
	var profData = GetProfessionData(actor, Profession.ALCHEMIST)
	if profData["rank"] < recipe["professionReq"]:
		res["reason"] = "Trình độ Luyện Đan chưa đủ! Yêu cầu cấp bậc: [%s]." % GetRankName(recipe["professionReq"])
		return res
		
	var playerLevel = actor.stat.level if actor and actor.stat else 1
	if playerLevel < recipe["levelReq"]:
		res["reason"] = "Cảnh giới chưa đủ để điều khiển hỏa hầu! Yêu cầu cấp độ: %d." % recipe["levelReq"]
		return res
		
	# Check materials in inventory
	var missing = {}
	for matName in recipe["materials"]:
		var reqCount : int = recipe["materials"][matName]
		var matHash : int = DB.GetCellHash(matName)
		var matCell : ItemCell = DB.ItemsDB.get(matHash, null)
		var hasCount : int = actor.inventory.GetItemCount(matCell) if matCell and actor and actor.inventory else 0
		if hasCount < reqCount:
			missing[matName] = { "required": reqCount, "owned": hasCount }
			
	if not missing.is_empty():
		res["reason"] = "Nguyên liệu không đủ!"
		res["missingMaterials"] = missing
		return res
		
	# Success rate formula: Base + (Rank * 5%) + (Concentration / 200.0) + FurnaceBonus
	var furnace = GetFurnaceBonus(furnaceTier)
	var concentration = actor.stat.concentration if actor and actor.stat else 10
	var calculatedRate = recipe["baseSuccessRate"] + (profData["rank"] * 0.05) + (float(concentration) * 0.005) + furnace["bonusRate"]
	res["successRate"] = clampf(calculatedRate, 0.20, 0.98)
	res["canCraft"] = true
	return res

static func BrewElixir(actor : Node, recipeId : String, furnaceTier : FurnaceTier = FurnaceTier.BAT_QUAI) -> Dictionary:
	var check = CanBrewElixir(actor, recipeId, furnaceTier)
	if not check["canCraft"]:
		return { "success": false, "message": check["reason"], "product": "", "quality": "" }
		
	var recipe = ALCHEMY_RECIPES[recipeId]
	# Deduct materials atomically
	for matName in recipe["materials"]:
		var reqCount : int = recipe["materials"][matName]
		var matHash : int = DB.GetCellHash(matName)
		NpcCommons.RemoveItem(actor, matHash, reqCount)
		
	var roll = randf()
	var isSuccess = (roll <= check["successRate"])
	var charId = _GetCharId(actor)
	
	if isSuccess:
		var resultHash = DB.GetCellHash(recipe["resultItem"])
		NpcCommons.AddItem(actor, resultHash, 1)
		
		# Quality calculation
		var quality = ItemQuality.MID
		var furnace = GetFurnaceBonus(furnaceTier)
		var purityRoll = randf() + furnace["purityBonus"]
		if purityRoll > 0.85:
			quality = ItemQuality.SUPREME
		elif purityRoll > 0.60:
			quality = ItemQuality.HIGH
		elif purityRoll > 0.30:
			quality = ItemQuality.MID
		else:
			quality = ItemQuality.LOW
			
		var exp = recipe["expGain"]
		NpcCommons.AddExp(actor, exp)
		AddProfessionExp(actor, Profession.ALCHEMIST, exp)
		
		var msg = "Luyện đan thành công! Thu được [%s] (Phẩm chất: %s), nhận +%d Tu Vi!" % [recipe["name"], _GetQualityName(quality), exp]
		if actor is PlayerAgent:
			Network.PushNotification(msg, actor.peerID)
			
		if Launcher.SQL and Launcher.SQL.db:
			RecordCraftHistory(Launcher.SQL.db, charId, "ALCHEMY", recipeId, resultHash, 1)
			
		return { "success": true, "product": recipe["resultItem"], "quality": _GetQualityName(quality), "exp": exp, "message": msg }
	else:
		var pityExp = maxi(5, int(recipe["expGain"] * 0.2))
		NpcCommons.AddExp(actor, pityExp)
		AddProfessionExp(actor, Profession.ALCHEMIST, pityExp)
		var failMsg = "Đan lô chấn động, hỏa hầu mất khống chế, ngưng đan thất bại! Lĩnh hội được +%d Tu Vi từ sai lầm." % pityExp
		if actor is PlayerAgent:
			Network.PushNotification(failMsg, actor.peerID)
			
		if Launcher.SQL and Launcher.SQL.db:
			RecordCraftHistory(Launcher.SQL.db, charId, "ALCHEMY", recipeId, 0, 0)
			
		return { "success": false, "product": "", "quality": "", "exp": pityExp, "message": failMsg }

# ==============================================================================
# 6. FORGING ENGINE (LUYỆN KHÍ)
# ==============================================================================
static func CanForge(actor : Node, recipeId : String) -> Dictionary:
	var res = { "canForge": false, "reason": "", "missingMaterials": {} }
	if not FORGE_RECIPES.has(recipeId):
		res["reason"] = "Công thức rèn đúc không tồn tại!"
		return res
		
	var recipe = FORGE_RECIPES[recipeId]
	var profData = GetProfessionData(actor, Profession.FORGEMASTER)
	if profData["rank"] < recipe["professionReq"]:
		res["reason"] = "Cấp bậc Luyện Khí Sư chưa đủ! Yêu cầu: [%s]." % GetRankName(recipe["professionReq"])
		return res
		
	var playerLevel = actor.stat.level if actor and actor.stat else 1
	if playerLevel < recipe["levelReq"]:
		res["reason"] = "Cảnh giới chưa đủ để điều khiển thần hỏa tôi khí! Yêu cầu cấp độ: %d." % recipe["levelReq"]
		return res
		
	var missing = {}
	for matName in recipe["materials"]:
		var reqCount : int = recipe["materials"][matName]
		var matHash : int = DB.GetCellHash(matName)
		var matCell : ItemCell = DB.ItemsDB.get(matHash, null)
		var hasCount : int = actor.inventory.GetItemCount(matCell) if matCell and actor and actor.inventory else 0
		if hasCount < reqCount:
			missing[matName] = { "required": reqCount, "owned": hasCount }
			
	if not missing.is_empty():
		res["reason"] = "Khoáng thạch và vật liệu không đủ!"
		res["missingMaterials"] = missing
		return res
		
	res["canForge"] = true
	return res

static func ForgeEquipment(actor : Node, recipeId : String) -> Dictionary:
	var check = CanForge(actor, recipeId)
	if not check["canForge"]:
		return { "success": false, "message": check["reason"], "product": "" }
		
	var recipe = FORGE_RECIPES[recipeId]
	for matName in recipe["materials"]:
		var reqCount : int = recipe["materials"][matName]
		var matHash : int = DB.GetCellHash(matName)
		NpcCommons.RemoveItem(actor, matHash, reqCount)
		
	var resultHash = DB.GetCellHash(recipe["resultItem"])
	NpcCommons.AddItem(actor, resultHash, 1)
	
	var exp = recipe["expGain"]
	NpcCommons.AddExp(actor, exp)
	AddProfessionExp(actor, Profession.FORGEMASTER, exp)
	
	var charId = _GetCharId(actor)
	var msg = "Rèn đúc thành công [%s]! Nhận được bảo vật vào Túi Trữ Vật (+%d Tu Vi)!" % [recipe["name"], exp]
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)
		
	if Launcher.SQL and Launcher.SQL.db:
		RecordCraftHistory(Launcher.SQL.db, charId, "FORGING", recipeId, resultHash, 1)
		
	return { "success": true, "product": recipe["resultItem"], "exp": exp, "message": msg }

# ==============================================================================
# 7. EQUIPMENT REFINEMENT ENGINE (CƯỜNG HÓA & TINH LUYỆN)
# ==============================================================================
static func GetItemRefinementKey(charId : int, cellId : int, customfield : String) -> String:
	return "%d_%d_%s" % [charId, cellId, customfield]

static func GetRefinementData(actor : Node, itemCell : ItemCell, customfield : String = "") -> Dictionary:
	var charId = _GetCharId(actor)
	var key = GetItemRefinementKey(charId, itemCell.id, customfield)
	if not itemRefinements.has(key):
		itemRefinements[key] = {
			"enhanceLevel": 0,
			"refineGrade": 0,
			"isLocked": false,
			"affixes": {}
		}
	return itemRefinements[key]

static func GetEnhanceSuccessRate(currentLevel : int) -> float:
	match currentLevel:
		0, 1, 2: return 1.00 # +1..+3: 100%
		3:       return 0.75 # +4: 75%
		4:       return 0.70 # +5: 70%
		5:       return 0.60 # +6: 60%
		6:       return 0.50 # +7: 50%
		7:       return 0.40 # +8: 40%
		8:       return 0.30 # +9: 30%
		_:       return 0.20

static func EnhanceEquipment(actor : Node, itemCell : ItemCell, customfield : String = "") -> Dictionary:
	if not itemCell or itemCell.slot == ActorCommons.Slot.NONE:
		return { "success": false, "message": "Vật phẩm này không thể cường hóa!" }
		
	var refData = GetRefinementData(actor, itemCell, customfield)
	if refData["isLocked"]:
		return { "success": false, "message": "Trang bị đang bị KHÓA! Hãy mở khóa trước khi thao tác." }
		
	var curLevel = refData["enhanceLevel"]
	if curLevel >= 9:
		return { "success": false, "message": "Trang bị đã đạt cảnh giới cường hóa tối đa (+9)!" }
		
	var reqOre = curLevel + 1
	var reqGP = (curLevel + 1) * 50
	
	var oreHash = DB.GetCellHash("Huyen Thiet Khoang")
	var oreCell = DB.ItemsDB.get(oreHash, null)
	var hasOre = actor.inventory.GetItemCount(oreCell) if oreCell and actor.inventory else 0
	var hasGP = actor.stat.gp if actor and actor.stat else 0
	
	if hasOre < reqOre:
		return { "success": false, "message": "Thiếu Huyền Thiết Khoáng! Cần %d, hiện có %d." % [reqOre, hasOre] }
	if hasGP < reqGP:
		return { "success": false, "message": "Thiếu Linh Thạch! Cần %d GP, hiện có %d GP." % [reqGP, hasGP] }
		
	# Deduct materials atomically
	NpcCommons.RemoveItem(actor, oreHash, reqOre)
	if actor and actor.stat:
		actor.stat.SpendGP(reqGP)
	
	var successRate = GetEnhanceSuccessRate(curLevel)
	var roll = randf()
	var isSuccess = (roll <= successRate)
	var charId = _GetCharId(actor)
	
	if isSuccess:
		refData["enhanceLevel"] += 1
		AddProfessionExp(actor, Profession.FORGEMASTER, 15)
		var newLevel = refData["enhanceLevel"]
		var msg = "Cường hóa THÀNH CÔNG! Trang bị thăng lên +%d (Thuộc tính cơ bản +%d%%)!" % [newLevel, newLevel * 10]
		if actor is PlayerAgent:
			Network.PushNotification(msg, actor.peerID)
			
		if Launcher.SQL and Launcher.SQL.db:
			SaveItemRefinement(Launcher.SQL.db, charId, itemCell.id, customfield, newLevel, refData["affixes"], refData["isLocked"])
			
		return { "success": true, "level": newLevel, "message": msg }
	else:
		# Safe failure: never breaks item! Only demotes if level >= 4
		if curLevel >= 4:
			refData["enhanceLevel"] -= 1
		var safeLevel = refData["enhanceLevel"]
		var failMsg = "Cường hóa thất bại! Cấp cường hóa hiện tại: +%d. Trang bị được bảo toàn nguyên vẹn." % safeLevel
		if actor is PlayerAgent:
			Network.PushNotification(failMsg, actor.peerID)
			
		if Launcher.SQL and Launcher.SQL.db:
			SaveItemRefinement(Launcher.SQL.db, charId, itemCell.id, customfield, safeLevel, refData["affixes"], refData["isLocked"])
			
		return { "success": false, "level": safeLevel, "message": failMsg }

static func RefineAffixes(actor : Node, itemCell : ItemCell, customfield : String = "") -> Dictionary:
	var refData = GetRefinementData(actor, itemCell, customfield)
	if refData["isLocked"]:
		return { "success": false, "message": "Trang bị đang bị KHÓA!" }
		
	var matHash = DB.GetCellHash("Thanh Phong Tinh Thiet")
	var matCell = DB.ItemsDB.get(matHash, null)
	var hasMat = actor.inventory.GetItemCount(matCell) if matCell and actor.inventory else 0
	if hasMat < 1:
		return { "success": false, "message": "Cần 1 Thanh Phong Tinh Thiết để tinh luyện!" }
		
	NpcCommons.RemoveItem(actor, matHash, 1)
	
	# Roll random Xianxia secondary affix
	var affixes = [
		{ "key": "critRate", "name": "Bạo Kích", "value": 0.04 },
		{ "key": "dodgeRate", "name": "Né Tránh", "value": 0.03 },
		{ "key": "woodSynergy", "name": "Mộc Khí Tương Sinh", "value": 0.06 },
		{ "key": "fireResist", "name": "Kháng Hỏa Chi Lực", "value": 0.08 }
	]
	var picked = affixes[randi() % affixes.size()]
	refData["affixes"][picked["key"]] = picked["value"]
	
	var charId = _GetCharId(actor)
	if Launcher.SQL and Launcher.SQL.db:
		SaveItemRefinement(Launcher.SQL.db, charId, itemCell.id, customfield, refData["enhanceLevel"], refData["affixes"], refData["isLocked"])
		
	var msg = "Tinh luyện thành công! Nhận được từ điều phụ: [%s +%d%%]!" % [picked["name"], int(picked["value"] * 100)]
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)
	return { "success": true, "affix": picked, "message": msg }

static func ToggleLockItem(actor : Node, itemCell : ItemCell, customfield : String = "") -> bool:
	var refData = GetRefinementData(actor, itemCell, customfield)
	refData["isLocked"] = not refData["isLocked"]
	var charId = _GetCharId(actor)
	if Launcher.SQL and Launcher.SQL.db:
		SaveItemRefinement(Launcher.SQL.db, charId, itemCell.id, customfield, refData["enhanceLevel"], refData["affixes"], refData["isLocked"])
	var stateStr = "ĐÃ KHÓA" if refData["isLocked"] else "ĐÃ MỞ KHÓA"
	if actor is PlayerAgent:
		Network.PushNotification("Trang bị [%s] %s bảo vệ." % [itemCell.name, stateStr], actor.peerID)
	return refData["isLocked"]

static func DismantleEquipment(actor : Node, itemCell : ItemCell, itemIndex : int, customfield : String = "") -> Dictionary:
	var refData = GetRefinementData(actor, itemCell, customfield)
	if refData["isLocked"]:
		return { "success": false, "message": "Trang bị bị KHÓA, không thể phân giải!" }
		
	if not actor.inventory.RemoveItem(itemCell, 1, itemIndex):
		return { "success": false, "message": "Không tìm thấy trang bị trong Túi Trữ Vật!" }
		
	# Recover 50% ores
	var recoveredOre = maxi(1, int(itemCell.buyPrice / 300))
	var oreHash = DB.GetCellHash("Huyen Thiet Khoang")
	NpcCommons.AddItem(actor, oreHash, recoveredOre)
	
	var msg = "Đã phân giải [%s], thu hồi được %d Huyền Thiết Khoáng!" % [itemCell.name, recoveredOre]
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)
	return { "success": true, "recovered": recoveredOre, "message": msg }

# ==============================================================================
# 8. SPIRITUAL TREASURE ENGINE (PHÁP BẢO)
# ==============================================================================
static func GetTreasureResonance(actor : Node, treasureId : String) -> float:
	var baseResonance = 1.0
	var playerElem = actor.get_meta("spiritual_root_element", 0) if actor else 0
	match treasureId:
		"XICH_VIEM_HOA_HO":
			if playerElem == 4: # Fire
				baseResonance = 1.25
		"HUYEN_QUY_KINH":
			if playerElem == 3 or playerElem == 5: # Water or Earth
				baseResonance = 1.25
		"CAN_KHON_TU_LINH_DINH":
			if playerElem == 2: # Wood
				baseResonance = 1.25
	return baseResonance

static func ActivateSpiritualTreasure(actor : Node, treasureId : String) -> Dictionary:
	if not actor or not is_instance_valid(actor):
		return { "success": false, "message": "Thực thể không hợp lệ!" }
		
	var agentId = actor.get_instance_id()
	var cdKey = "%d_%s" % [agentId, treasureId]
	var now = Time.get_unix_time_from_system()
	
	if treasureCooldowns.has(cdKey) and now < treasureCooldowns[cdKey]:
		var remain = treasureCooldowns[cdKey] - now
		return { "success": false, "message": "Pháp bảo đang hồi chiêu (còn %.1fs)!" % remain }
		
	var resonance = GetTreasureResonance(actor, treasureId)
	
	match treasureId:
		"HUYEN_QUY_KINH":
			var mpCost = 30
			var curMana = actor.stat.mana if actor and actor.stat else 0
			if curMana < mpCost:
				return { "success": false, "message": "Linh Lực không đủ để kích hoạt Huyền Quy Kính (cần 30 MP)!" }
			if actor and actor.stat:
				actor.stat.SetMana(-mpCost)
			
			var shieldAmount = 200.0 * resonance
			activeShields[agentId] = shieldAmount
			if actor and actor.stat:
				actor.stat.buffs.Apply(CellCommons.Modifier.Defense, 20.0, 10.0)
			treasureCooldowns[cdKey] = now + 25.0
			var msg = "Kích hoạt [Huyền Quy Kính]! Ngưng tụ hộ thể huyền giáp hấp thu %.0f sát thương (Cộng hưởng: %.0f%%)!" % [shieldAmount, resonance * 100]
			if actor is PlayerAgent:
				Network.PushNotification(msg, actor.peerID)
			return { "success": true, "message": msg, "shield": shieldAmount }
			
		"XICH_VIEM_HOA_HO":
			var mpCost = 45
			var curMana = actor.stat.mana if actor and actor.stat else 0
			if curMana < mpCost:
				return { "success": false, "message": "Linh Lực không đủ để tế xuất Xích Viêm Hỏa Hồ (cần 45 MP)!" }
			if actor and actor.stat:
				actor.stat.SetMana(-mpCost)
			
			var burstDmg = 180.0 * resonance
			treasureCooldowns[cdKey] = now + 18.0
			var msg = "Tế xuất [Xích Viêm Hỏa Hồ]! Hỏa long bùng cháy giáng hạ %.0f sát thương Hỏa diễm và thiêu đốt!" % burstDmg
			if actor is PlayerAgent:
				Network.PushNotification(msg, actor.peerID)
			return { "success": true, "message": msg, "damage": burstDmg }
			
		"CAN_KHON_TU_LINH_DINH":
			actor.stat.SetMana(100)
			NpcCommons.AddExp(actor, 50)
			cultivationSpeedBuffs[agentId] = { "multiplier": 1.5 * resonance, "expires": now + 60.0 }
			treasureCooldowns[cdKey] = now + 40.0
			var msg = "Vận chuyển [Càn Khôn Tụ Linh Đỉnh]! Lập tức hồi phục 100 MP, ban +50 Tu Vi và tăng 50%% tốc độ ngưng tụ Linh Khí!"
			if actor is PlayerAgent:
				Network.PushNotification(msg, actor.peerID)
			return { "success": true, "message": msg, "mp": 100, "tuVi": 50 }
			
		_:
			return { "success": false, "message": "Pháp bảo không xác định!" }

# ==============================================================================
# 9. SECT ECONOMY INTEGRATION (ĐÓNG GÓP TÔNG MÔN)
# ==============================================================================
static func DonateCraftedItem(actor : Node, itemCell : ItemCell, count : int = 1) -> Dictionary:
	if not itemCell or count <= 0:
		return { "success": false, "contribution": 0, "message": "Vật phẩm quyên góp không hợp lệ!" }
		
	var cellName = itemCell.name
	var contribPerItem = 0
	
	match cellName:
		"Hoi Xuan Dan":      contribPerItem = 10
		"Bo Khi Dan":        contribPerItem = 12
		"Kim Cang Dan":      contribPerItem = 25
		"Bao Nguyen Dan":    contribPerItem = 25
		"Truc Co Dan":       contribPerItem = 100
		"Thanh Phong Kiem":  contribPerItem = 50
		"Bach Ngan Kiem":    contribPerItem = 120
		"Truc Son Dao Bao":  contribPerItem = 60
		_:
			contribPerItem = maxi(5, int(itemCell.buyPrice / 30))
			
	var totalContrib = contribPerItem * count
	var itemIndex = actor.inventory.FindItemIndex(itemCell)
	if itemIndex < 0 or not actor.inventory.RemoveItem(itemCell, count, itemIndex):
		return { "success": false, "contribution": 0, "message": "Trong Túi Trữ Vật không có đủ số lượng!" }
		
	var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
	SectSystemClass.AddContribution(actor, totalContrib)
	
	var msg = "Quyên góp thành công %s x%d! Nhận được +%d Điểm Cống Hiến Môn Phái!" % [cellName, count, totalContrib]
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)
	return { "success": true, "contribution": totalContrib, "message": msg }

# ==============================================================================
# 10. SQLITE PERSISTENCE ENGINE
# ==============================================================================
static func EnsureCraftingTables(db : SQLite) -> bool:
	if not db: return false
	var query : String = """
CREATE TABLE IF NOT EXISTS char_professions (
	char_id INTEGER NOT NULL,
	profession_id INTEGER NOT NULL,
	rank_level INTEGER NOT NULL DEFAULT 1,
	current_exp INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (char_id, profession_id)
);

CREATE TABLE IF NOT EXISTS char_item_refinement (
	char_id INTEGER NOT NULL,
	item_id INTEGER NOT NULL,
	customfield TEXT NOT NULL,
	enhance_level INTEGER NOT NULL DEFAULT 0,
	refine_grade INTEGER NOT NULL DEFAULT 0,
	is_locked INTEGER NOT NULL DEFAULT 0,
	affixes_json TEXT NOT NULL DEFAULT '{}',
	PRIMARY KEY (char_id, item_id, customfield)
);

CREATE TABLE IF NOT EXISTS char_spiritual_treasures (
	char_id INTEGER NOT NULL,
	treasure_id TEXT NOT NULL,
	resonance_rate REAL NOT NULL DEFAULT 1.0,
	equipped_slot INTEGER NOT NULL DEFAULT 0,
	level INTEGER NOT NULL DEFAULT 1,
	PRIMARY KEY (char_id, treasure_id)
);

CREATE TABLE IF NOT EXISTS char_crafting_history (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	char_id INTEGER NOT NULL,
	craft_type TEXT NOT NULL,
	recipe_id TEXT NOT NULL,
	result_item_id INTEGER NOT NULL,
	success INTEGER NOT NULL,
	timestamp INTEGER NOT NULL
);
"""
	return db.query(query)

static func SaveProfession(db : SQLite, charId : int, profId : int, rankLevel : int, exp : int) -> bool:
	if not db: return false
	var query = """
INSERT INTO char_professions (char_id, profession_id, rank_level, current_exp)
VALUES (%d, %d, %d, %d)
ON CONFLICT (char_id, profession_id) DO UPDATE SET
	rank_level = excluded.rank_level,
	current_exp = excluded.current_exp;
""" % [charId, profId, rankLevel, exp]
	return db.query(query)

static func LoadProfessions(db : SQLite, charId : int) -> Dictionary:
	var result = {}
	if not db: return result
	if db.query("SELECT * FROM char_professions WHERE char_id = %d;" % charId):
		for row in db.query_result:
			result[int(row["profession_id"])] = {
				"rank": int(row["rank_level"]),
				"exp": int(row["current_exp"])
			}
	return result

static func SaveItemRefinement(db : SQLite, charId : int, itemId : int, customfield : String, level : int, affixes : Dictionary, isLocked : bool) -> bool:
	if not db: return false
	var affixesJson = JSON.stringify(affixes)
	var lockedInt = 1 if isLocked else 0
	var query = """
INSERT INTO char_item_refinement (char_id, item_id, customfield, enhance_level, refine_grade, is_locked, affixes_json)
VALUES (%d, %d, '%s', %d, 0, %d, '%s')
ON CONFLICT (char_id, item_id, customfield) DO UPDATE SET
	enhance_level = excluded.enhance_level,
	is_locked = excluded.is_locked,
	affixes_json = excluded.affixes_json;
""" % [charId, itemId, customfield, level, lockedInt, affixesJson]
	return db.query(query)

static func RecordCraftHistory(db : SQLite, charId : int, craftType : String, recipeId : String, resultId : int, success : int) -> bool:
	if not db: return false
	var now = int(Time.get_unix_time_from_system())
	var query = """
INSERT INTO char_crafting_history (char_id, craft_type, recipe_id, result_item_id, success, timestamp)
VALUES (%d, '%s', '%s', %d, %d, %d);
""" % [charId, craftType, recipeId, resultId, success, now]
	return db.query(query)

# ==============================================================================
# 11. INTERNAL HELPERS
# ==============================================================================
static func _GetCharId(actor : Node) -> int:
	if not actor: return 0
	if actor is PlayerAgent:
		var peer = Peers.GetPeer(actor.peerID)
		if peer: return peer.characterID
	return actor.get_instance_id()

static func _GetQualityName(q : ItemQuality) -> String:
	match q:
		ItemQuality.MORTAL:  return "Phàm Phẩm"
		ItemQuality.LOW:     return "Hạ Phẩm"
		ItemQuality.MID:     return "Trung Phẩm"
		ItemQuality.HIGH:    return "Thượng Phẩm"
		ItemQuality.SUPREME: return "Cực Phẩm"
		_:                   return "Thường"
