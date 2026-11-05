extends RefCounted
class_name SectSystem

## Master Sect System & Disciple Progression Engine
## Thiên Đạo Nghịch Mệnh — Build 06: Sect Foundation, Disciple Ranks & Cultivation Society
## Adheres to Owner Decision D-03 (SacredSectHub internal ID 995840901, official sect name PENDING).

# ==============================================================================
# 1. ENUMS & CONSTANTS
# ==============================================================================
const DEFAULT_SECT_ID : int = 995840901 # SacredSectHub.hash()

enum DiscipleRank {
	NONE = 0,        # Chưa Nhập Môn / Tán Tu
	TAP_DICH = 1,    # Tạp Dịch Đệ Tử
	NGOAI_MON = 2,   # Ngoại Môn Đệ Tử
	NOI_MON = 3,     # Nội Môn Đệ Tử
	CHAN_TRUYEN = 4, # Chân Truyền Đệ Tử
	THAN_TRUYEN = 5  # Thân Truyền Đệ Tử
}

enum Facility {
	MAIN_HALL = 1,        # Đại Điện
	PHARMACY = 2,         # Dược Đường
	FURNACE = 4,          # Luyện Đan Lô
	STELE = 8,            # Trúc Sơn Cổ Bi
	FORGE = 16,           # Luyện Khí Đường
	GATHERING_ARRAY = 32, # Tụ Linh Trận
	MARTIAL_GROUND = 64,  # Diễn Võ Đường
	LIBRARY_T1 = 128,     # Tàng Kinh Các Tầng 1
	LIBRARY_T2 = 256,     # Tàng Kinh Các Tầng 2
	SECRET_REALM = 512    # Cấm Địa Bí Cảnh
}

# ==============================================================================
# 2. SECT REGISTRY & METADATA (DATA-DRIVEN)
# ==============================================================================
const SECT_REGISTRY : Dictionary = {
	DEFAULT_SECT_ID: {
		"id": DEFAULT_SECT_ID,
		"internal_name": "SacredSectHub",
		"display_name": "Trúc Sơn Tông",
		"canon_status": "D-03 PENDING (Định danh phát triển thử nghiệm)",
		"tenet": "Thuận Ứng Thiên Đạo, Trúc Tiết Kiên Cương, Dĩ Khí Ngự Kiếm.",
		"leader": "Đạo Huyền Trưởng Lão (Tạm Quyền Sơn Môn)",
		"location": "Trúc Sơn Tiên Cảnh",
		"level": 2,
		"reputation": "Danh Môn Chính Phái",
		"description": "Thánh địa tu tiên ngàn năm tọa lạc tại Trúc Sơn. Nơi đệ tử rèn luyện gân cốt, cảm ứng linh khí thiên địa và tu tập kiếm đạo chính tông.",
		"treasury": {
			"spirit_stones": 85000,
			"herbs": 3200,
			"ores": 2100,
			"pills": 650
		}
	}
}

const RANK_METADATA : Dictionary = {
	DiscipleRank.NONE: {
		"id": DiscipleRank.NONE,
		"name": "Chưa Nhập Môn",
		"title": "Tán Tu Hồng Trần",
		"reqRealmLevel": 1,
		"reqRealmName": "Phàm Thân • Sơ Nhập",
		"reqContribution": 0,
		"stipend": 0,
		"facilities": Facility.MAIN_HALL,
		"description": "Tu sĩ tự do phiêu bạt chốn giang hồ, chưa bái nhập sơn môn."
	},
	DiscipleRank.TAP_DICH: {
		"id": DiscipleRank.TAP_DICH,
		"name": "Tạp Dịch Đệ Tử",
		"title": "Trúc Sơn Tạp Dịch",
		"reqRealmLevel": 1,
		"reqRealmName": "Phàm Thân • Sơ Nhập",
		"reqContribution": 0,
		"stipend": 20,
		"facilities": Facility.MAIN_HALL | Facility.PHARMACY | Facility.STELE,
		"description": "Mới bái nhập môn phái, phụ trách việc vặt, quét dọn sơn môn và thu gom tài nguyên ngoại vi."
	},
	DiscipleRank.NGOAI_MON: {
		"id": DiscipleRank.NGOAI_MON,
		"name": "Ngoại Môn Đệ Tử",
		"title": "Trúc Sơn Ngoại Môn",
		"reqRealmLevel": 2,
		"reqRealmName": "Tụ Khí • Tầng 1",
		"reqContribution": 100,
		"stipend": 50,
		"facilities": Facility.MAIN_HALL | Facility.PHARMACY | Facility.FURNACE | Facility.STELE | Facility.GATHERING_ARRAY | Facility.MARTIAL_GROUND | Facility.LIBRARY_T1,
		"description": "Đệ tử chính thức thuộc Ngoại Vi, được phép tu luyện tại Tụ Linh Trận và tham ngộ công pháp Hoàng Giai tại Tàng Kinh Các."
	},
	DiscipleRank.NOI_MON: {
		"id": DiscipleRank.NOI_MON,
		"name": "Nội Môn Đệ Tử",
		"title": "Trúc Sơn Kiếm Lữ",
		"reqRealmLevel": 6,
		"reqRealmName": "Tụ Khí • Tầng 5",
		"reqContribution": 500,
		"stipend": 150,
		"facilities": Facility.MAIN_HALL | Facility.PHARMACY | Facility.FURNACE | Facility.STELE | Facility.FORGE | Facility.GATHERING_ARRAY | Facility.MARTIAL_GROUND | Facility.LIBRARY_T1 | Facility.LIBRARY_T2 | Facility.SECRET_REALM,
		"description": "Cột trụ cốt cán của môn phái. Được quyền tiến nhập tầng 2 Tàng Kinh Các, tinh luyện pháp bảo tại Luyện Khí Đường và thâm nhập Linh Khí Bí Cảnh."
	},
	DiscipleRank.CHAN_TRUYEN: {
		"id": DiscipleRank.CHAN_TRUYEN,
		"name": "Chân Truyền Đệ Tử",
		"title": "Trúc Sơn Kiếm Tử",
		"reqRealmLevel": 10,
		"reqRealmName": "Tụ Khí • Tầng 9 (Viên Mãn)",
		"reqContribution": 1500,
		"stipend": 350,
		"facilities": 1023, # Toàn bộ công trình
		"description": "Đệ tử chân truyền đích thực được Trưởng lão đích thân chỉ điểm, nắm giữ các tuyệt học bí truyền của tông môn."
	},
	DiscipleRank.THAN_TRUYEN: {
		"id": DiscipleRank.THAN_TRUYEN,
		"name": "Thân Truyền Đệ Tử",
		"title": "Thủ Tịch Đại Đệ Tử",
		"reqRealmLevel": 19,
		"reqRealmName": "Đạo Cơ • Sơ Kỳ",
		"reqContribution": 3000,
		"stipend": 800,
		"facilities": 1023,
		"description": "Đệ tử y bát của Chưởng môn hoặc Thái Thượng Trưởng Lão, tương lai kế thừa đại thống tông môn."
	}
}

# ==============================================================================
# 3. SECT EXCHANGE CATALOG (BÁCH BẢO CÁC)
# ==============================================================================
const EXCHANGE_CATALOG : Array[Dictionary] = [
	{
		"id": 1,
		"name": "Hồi Xuân Đan",
		"itemCell": "Hoi Xuan Dan",
		"category": "Đan Dược",
		"cost": 15,
		"reqRank": DiscipleRank.TAP_DICH,
		"description": "Đan dược sơ cấp giúp phục hồi nhanh 80 điểm Khí Huyết (HP)."
	},
	{
		"id": 2,
		"name": "Bổ Khí Đan",
		"itemCell": "Bo Khi Dan",
		"category": "Đan Dược",
		"cost": 20,
		"reqRank": DiscipleRank.TAP_DICH,
		"description": "Đan dược giúp tĩnh tâm hồi phục 60 điểm Linh Lực (MP)."
	},
	{
		"id": 3,
		"name": "Thanh Phong Tinh Thiết",
		"itemCell": "Thanh Phong Tinh Thiet",
		"category": "Linh Tài",
		"cost": 45,
		"reqRank": DiscipleRank.NGOAI_MON,
		"description": "Linh khoáng đã qua tinh luyện, nguyên liệu chế tạo phi kiếm và đạo bào."
	},
	{
		"id": 4,
		"name": "Trúc Sơn Đạo Bào",
		"itemCell": "Truc Son Dao Bao",
		"category": "Trang Bị",
		"cost": 120,
		"reqRank": DiscipleRank.NGOAI_MON,
		"description": "Đạo bào tông môn dệt từ tơ trúc tiên thiên, tăng 16 Phòng Ngự và 40 HP."
	},
	{
		"id": 5,
		"name": "Thanh Phong Kiếm",
		"itemCell": "Thanh Phong Kiem",
		"category": "Vũ Khí",
		"cost": 180,
		"reqRank": DiscipleRank.NGOAI_MON,
		"description": "Bảo kiếm sắc bén của đệ tử kiếm phái, tăng 24 Công Kích và 5% Bạo Kích."
	},
	{
		"id": 6,
		"name": "Thanh Phong Bí Kíp",
		"itemCell": "Thanh Phong Bi Kip",
		"category": "Bí Tịch",
		"cost": 250,
		"reqRank": DiscipleRank.NOI_MON,
		"description": "Bí kíp chân truyền mở khóa Thanh Phong Kiếm Khí, Trúc Sơn Kiếm Trận và Đạp Phong Bộ."
	}
]

# ==============================================================================
# 4. TÀNG KINH CÁC CATALOG (MARTIAL SCRIPTURES)
# ==============================================================================
const SCRIPTURE_CATALOG : Array[Dictionary] = [
	{
		"id": 101,
		"name": "Trúc Sơn Dẫn Khí Quyết",
		"category": "Tâm Pháp",
		"martialId": 1000,
		"skillCell": "Truc Son Dan Khi Quyet",
		"cost": 0,
		"reqRank": DiscipleRank.TAP_DICH,
		"reqRealm": 1,
		"description": "Tâm pháp cơ bản dẫn dắt linh khí vào kinh mạch, nền tảng của mọi đệ tử Trúc Sơn."
	},
	{
		"id": 102,
		"name": "Thanh Phong Kiếm Quyết",
		"category": "Kiếm Quyết",
		"martialId": 1001,
		"skillCell": "Thanh Phong Kiem Khí",
		"cost": 60,
		"reqRank": DiscipleRank.NGOAI_MON,
		"reqRealm": 2,
		"description": "Kiếm pháp cơ bản ngưng tụ kiếm khí gió lốc, gia tăng uy lực đòn đánh thường và liên kích."
	},
	{
		"id": 103,
		"name": "Đạp Phong Bộ",
		"category": "Thân Pháp",
		"martialId": 1004,
		"skillCell": "Đạp Phong Bộ",
		"cost": 80,
		"reqRank": DiscipleRank.NGOAI_MON,
		"reqRealm": 2,
		"description": "Thân pháp đạp gió lướt nhanh, nhận trạng thái Vô Địch khoảnh khắc và né tránh đòn công sát."
	},
	{
		"id": 104,
		"name": "Quy Nguyên Hộ Thể Thuẫn",
		"category": "Bí Thuật",
		"martialId": 1006,
		"skillCell": "Quy Nguyên Thuẫn",
		"cost": 120,
		"reqRank": DiscipleRank.NGOAI_MON,
		"reqRealm": 3,
		"description": "Tụ linh hộ thuẫn thổ hệ, tăng mạnh phòng ngự vật lý và kháng ma pháp."
	},
	{
		"id": 105,
		"name": "Trúc Sơn Kiếm Trận",
		"category": "Kiếm Trận",
		"martialId": 1003,
		"skillCell": "Trúc Sơn Kiếm Trận",
		"cost": 300,
		"reqRank": DiscipleRank.NOI_MON,
		"reqRealm": 5,
		"description": "Tuyệt kỹ nội môn triệu hoán kiếm trận vạn kiếm quy tông oanh tạc toàn bộ phạm vi địch thủ."
	}
]

# ==============================================================================
# 5. IN-MEMORY RUNTIME STATE STORAGE (KEYED BY AGENT INSTANCE ID)
# ==============================================================================
static var sectStorage : Dictionary = {}         # agent_id -> { "sect_id", "rank", "contribution", "total", "facilities" }
static var reputationStorage : Dictionary = {}   # agent_id -> { npc_id -> { "affinity": int, "trust": int } }
static var donationHistory : Array[Dictionary] = [] # Recent donation transaction logs

# ==============================================================================
# 6. SECT MEMBERSHIP & RANK MANAGEMENT
# ==============================================================================
static func GetSectData(agent : Node) -> Dictionary:
	if not agent:
		return _GetDefaultData()
	var id : int = agent.get_instance_id()
	if not sectStorage.has(id):
		sectStorage[id] = _GetDefaultData()
	return sectStorage[id]

static func _GetDefaultData() -> Dictionary:
	return {
		"sect_id": DEFAULT_SECT_ID,
		"rank": DiscipleRank.NONE,
		"contribution": 0,
		"total_contribution": 0,
		"facilities": Facility.MAIN_HALL,
		"joined_time": 0
	}

static func GetDiscipleRank(agent : Node) -> int:
	return GetSectData(agent).get("rank", DiscipleRank.NONE)

static func GetDiscipleRankName(rank : int) -> String:
	var meta = RANK_METADATA.get(rank, null)
	return meta["name"] if meta else "Chưa Nhập Môn"

static func GetDiscipleTitle(rank : int) -> String:
	var meta = RANK_METADATA.get(rank, null)
	return meta["title"] if meta else "Tán Tu"

static func SetDiscipleRank(agent : Node, rank : int):
	if not agent: return
	var id : int = agent.get_instance_id()
	var data : Dictionary = GetSectData(agent)
	data["rank"] = rank
	# Unlock facilities corresponding to rank
	var meta = RANK_METADATA.get(rank, {})
	var rankFacilities : int = meta.get("facilities", Facility.MAIN_HALL)
	data["facilities"] = data.get("facilities", 0) | rankFacilities
	if data["joined_time"] == 0 and rank > DiscipleRank.NONE:
		data["joined_time"] = int(Time.get_unix_time_from_system())
	sectStorage[id] = data

static func HasFacilityAccess(agent : Node, facility : int) -> bool:
	var data : Dictionary = GetSectData(agent)
	var flags : int = data.get("facilities", Facility.MAIN_HALL)
	return (flags & facility) != 0

static func GrantFacilityAccess(agent : Node, facility : int):
	if not agent: return
	var id : int = agent.get_instance_id()
	var data : Dictionary = GetSectData(agent)
	data["facilities"] = data.get("facilities", 0) | facility
	sectStorage[id] = data

# ==============================================================================
# 7. SECT CONTRIBUTION SYSTEM
# ==============================================================================
static func GetContribution(agent : Node) -> int:
	return GetSectData(agent).get("contribution", 0)

static func GetTotalContribution(agent : Node) -> int:
	return GetSectData(agent).get("total_contribution", 0)

static func AddContribution(agent : Node, amount : int, reason : String = "") -> int:
	if not agent or amount <= 0:
		return GetContribution(agent)
	var id : int = agent.get_instance_id()
	var data : Dictionary = GetSectData(agent)
	var current : int = data.get("contribution", 0)
	var total : int = data.get("total_contribution", 0)
	
	data["contribution"] = current + amount
	data["total_contribution"] = total + amount
	sectStorage[id] = data
	
	donationHistory.append({
		"agent_id": id,
		"type": "EARN",
		"amount": amount,
		"balance": data["contribution"],
		"reason": reason,
		"time": Time.get_unix_time_from_system()
	})
	return data["contribution"]

static func SpendContribution(agent : Node, amount : int, reason : String = "") -> bool:
	if not agent or amount <= 0:
		return false
	var id : int = agent.get_instance_id()
	var data : Dictionary = GetSectData(agent)
	var current : int = data.get("contribution", 0)
	
	if current < amount:
		return false # Insufficient contribution balance
		
	data["contribution"] = current - amount
	sectStorage[id] = data
	
	donationHistory.append({
		"agent_id": id,
		"type": "SPEND",
		"amount": amount,
		"balance": data["contribution"],
		"reason": reason,
		"time": Time.get_unix_time_from_system()
	})
	return true

# ==============================================================================
# 8. DISCIPLE PROMOTION CRITERIA & EXECUTION
# ==============================================================================
static func CanPromote(agent : Node) -> Dictionary:
	var result : Dictionary = {
		"canPromote": false,
		"currentRank": DiscipleRank.NONE,
		"nextRank": DiscipleRank.NONE,
		"reqRealmLevel": 1,
		"reqContribution": 0,
		"missingRealm": false,
		"missingContribution": false,
		"message": ""
	}
	if not agent:
		result["message"] = "Đối tượng không hợp lệ."
		return result
		
	var curRank : int = GetDiscipleRank(agent)
	result["currentRank"] = curRank
	
	if curRank >= DiscipleRank.THAN_TRUYEN:
		result["message"] = "Đạo hữu đã đạt đến thân phận Thân Truyền Đệ Tử cao quý nhất!"
		return result
		
	var nextRank : int = curRank + 1
	result["nextRank"] = nextRank
	
	var nextMeta : Dictionary = RANK_METADATA.get(nextRank, {})
	var reqRealmLevel : int = nextMeta.get("reqRealmLevel", 1)
	var reqContrib : int = nextMeta.get("reqContribution", 0)
	
	result["reqRealmLevel"] = reqRealmLevel
	result["reqContribution"] = reqContrib
	
	var playerLevel : int = 1
	var st = agent.get("stat")
	if st != null:
		if st is Dictionary:
			playerLevel = st.get("level", 1)
		elif "level" in st:
			playerLevel = st.level
		
	var playerContrib : int = GetTotalContribution(agent)
	
	if playerLevel < reqRealmLevel:
		result["missingRealm"] = true
	if playerContrib < reqContrib:
		result["missingContribution"] = true
		
	if not result["missingRealm"] and not result["missingContribution"]:
		result["canPromote"] = true
		result["message"] = "Đủ điều kiện khảo hạch thăng cấp lên [%s]!" % nextMeta.get("name", "")
	else:
		var reasons : Array[String] = []
		if result["missingRealm"]:
			reasons.append("Cảnh giới chưa đạt (%s)" % nextMeta.get("reqRealmName", ""))
		if result["missingContribution"]:
			reasons.append("Tổng cống hiến thiếu (%d/%d)" % [playerContrib, reqContrib])
		result["message"] = "Chưa thể thăng cấp: " + ", ".join(reasons)
		
	return result

static func PromoteDisciple(agent : Node) -> Dictionary:
	var check : Dictionary = CanPromote(agent)
	if not check["canPromote"]:
		return check
		
	var nextRank : int = check["nextRank"]
	SetDiscipleRank(agent, nextRank)
	check["promoted"] = true
	check["newRankName"] = GetDiscipleRankName(nextRank)
	return check

# ==============================================================================
# 9. RESOURCE DONATION & TREASURY
# ==============================================================================
static func GetDonationValue(itemName : String) -> int:
	match itemName:
		"Ngan Linh Thao":
			return 15 # 15 Sect contribution per herb
		"Huyen Thiet Khoang":
			return 20 # 20 Sect contribution per ore
		"Slime": # Linh Trùng Tương
			return 10
		"Thanh Phong Tinh Thiet":
			return 35
		_:
			return 0

static func DonateResource(agent : Node, itemName : String, count : int = 1) -> Dictionary:
	var result = { "success": false, "contributionGained": 0, "message": "" }
	if not agent or not agent.get("inventory") or count <= 0:
		result["message"] = "Thao tác không hợp lệ."
		return result
		
	var valPerItem : int = GetDonationValue(itemName)
	if valPerItem <= 0:
		result["message"] = "Vật phẩm này không thể cống hiến vào kho tông môn."
		return result
		
	var itemHash : int = DB.GetCellHash(itemName)
	var idx : int = agent.inventory.FindItemIndex(itemHash)
	if idx < 0:
		result["message"] = "Đạo hữu không có vật phẩm [%s] trong Túi Trữ Vật." % itemName
		return result
		
	var currentCount : int = agent.inventory.items[idx].count
	if currentCount < count:
		result["message"] = "Số lượng không đủ (hiện có: %d)." % currentCount
		return result
		
	# Deduct item from player inventory safely
	agent.inventory.RemoveItem(idx, count)
	
	# Grant sect contribution
	var gained : int = valPerItem * count
	AddContribution(agent, gained, "Cống hiến vật phẩm: %s x%d" % [itemName, count])
	
	# Update treasury in memory
	var sectData = SECT_REGISTRY.get(DEFAULT_SECT_ID, {})
	if sectData.has("treasury"):
		if itemName == "Ngan Linh Thao":
			sectData["treasury"]["herbs"] += count
		elif itemName == "Huyen Thiet Khoang":
			sectData["treasury"]["ores"] += count
			
	result["success"] = true
	result["contributionGained"] = gained
	result["message"] = "Quyên góp thành công %d [%s], nhận được %d Điểm Cống Hiến!" % [count, itemName, gained]
	return result

# ==============================================================================
# 10. TÀNG KINH CÁC & EXCHANGE TRANSACTIONS
# ==============================================================================
static func ExchangeItem(agent : Node, exchangeId : int) -> Dictionary:
	var result = { "success": false, "message": "" }
	if not agent or not agent.get("inventory"):
		result["message"] = "Nhân vật không hợp lệ."
		return result
		
	var entry : Dictionary = {}
	for item in EXCHANGE_CATALOG:
		if item["id"] == exchangeId:
			entry = item
			break
			
	if entry.is_empty():
		result["message"] = "Vật phẩm quy đổi không tồn tại."
		return result
		
	var rank : int = GetDiscipleRank(agent)
	if rank < entry["reqRank"]:
		var reqRankName : String = GetDiscipleRankName(entry["reqRank"])
		result["message"] = "Thân phận chưa đủ. Yêu cầu tối thiểu [%s]." % reqRankName
		return result
		
	var cost : int = entry["cost"]
	if GetContribution(agent) < cost:
		result["message"] = "Điểm Cống Hiến không đủ (%d/%d)." % [GetContribution(agent), cost]
		return result
		
	# Find cell in DB
	var cellHash : int = DB.GetCellHash(entry["itemCell"])
	var cell = DB.GetItem(cellHash)
	if not cell:
		result["message"] = "Lỗi dữ liệu: Không tìm thấy vật phẩm %s." % entry["itemCell"]
		return result
		
	# Spend contribution
	if not SpendContribution(agent, cost, "Đổi Bách Bảo Các: " + entry["name"]):
		result["message"] = "Giao dịch thất bại."
		return result
		
	# Add item to inventory
	agent.inventory.AddItem(cell, 1)
	result["success"] = true
	result["message"] = "Đổi thành công [%s] (-%d Cống Hiến)!" % [entry["name"], cost]
	return result

static func LearnScripture(agent : Node, scriptureId : int) -> Dictionary:
	var result = { "success": false, "message": "", "skillLearned": "" }
	if not agent:
		result["message"] = "Nhân vật không hợp lệ."
		return result
		
	var entry : Dictionary = {}
	for sc in SCRIPTURE_CATALOG:
		if sc["id"] == scriptureId:
			entry = sc
			break
			
	if entry.is_empty():
		result["message"] = "Bí tịch không tồn tại."
		return result
		
	var rank : int = GetDiscipleRank(agent)
	if rank < entry["reqRank"]:
		result["message"] = "Cần đạt thân phận [%s] mới được tham ngộ bí tịch này." % GetDiscipleRankName(entry["reqRank"])
		return result
		
	var playerLevel : int = agent.stat.level if agent.get("stat") else 1
	if playerLevel < entry["reqRealm"]:
		result["message"] = "Cảnh giới chưa đủ để lĩnh ngộ bí kíp này."
		return result
		
	var cost : int = entry["cost"]
	if cost > 0 and GetContribution(agent) < cost:
		result["message"] = "Điểm Cống Hiến không đủ (%d/%d)." % [GetContribution(agent), cost]
		return result
		
	# Deduct contribution if any
	if cost > 0:
		if not SpendContribution(agent, cost, "Tàng Kinh Các: " + entry["name"]):
			result["message"] = "Giao dịch cống hiến thất bại."
			return result
			
	# Learn skill into progress
	var skillHash : int = DB.GetCellHash(entry["skillCell"])
	var skillCell = DB.GetSkill(skillHash)
	if skillCell and agent.get("progress"):
		agent.progress.AddSkill(skillCell, 1, true)
		result["skillLearned"] = skillCell.name
		
	result["success"] = true
	result["message"] = "Tham ngộ thành công bí tịch [%s]!" % entry["name"]
	return result

# ==============================================================================
# 11. NPC REPUTATION & AFFINITY
# ==============================================================================
static func GetNpcAffinity(agent : Node, npcId : int) -> int:
	if not agent: return 0
	var id : int = agent.get_instance_id()
	var agentRep : Dictionary = reputationStorage.get(id, {})
	var npcData : Dictionary = agentRep.get(npcId, {})
	return npcData.get("affinity", 0)

static func AddNpcAffinity(agent : Node, npcId : int, amount : int) -> int:
	if not agent or amount == 0: return 0
	var id : int = agent.get_instance_id()
	if not reputationStorage.has(id):
		reputationStorage[id] = {}
	if not reputationStorage[id].has(npcId):
		reputationStorage[id][npcId] = { "affinity": 0, "trust": 0 }
		
	var current : int = reputationStorage[id][npcId]["affinity"]
	var updated : int = clampi(current + amount, -100, 100)
	reputationStorage[id][npcId]["affinity"] = updated
	return updated

# ==============================================================================
# 12. SECT RANKING / LEADERBOARD (PHONG VÂN BẢNG)
# ==============================================================================
static func GetLeaderboard(playerAgent : Node = null) -> Array[Dictionary]:
	var board : Array[Dictionary] = [
		{
			"rank": 1,
			"name": "Sở Hạo Thiên",
			"title": "Thủ Tịch Đại Đệ Tử",
			"discipleRank": DiscipleRank.THAN_TRUYEN,
			"contribution": 3850,
			"realm": "Đạo Cơ • Sơ Kỳ",
			"isPlayer": false,
			"label": "[Đồng Môn NPC]"
		},
		{
			"rank": 2,
			"name": "Bạch Tố Trinh",
			"title": "Trúc Sơn Kiếm Tử",
			"discipleRank": DiscipleRank.CHAN_TRUYEN,
			"contribution": 2420,
			"realm": "Tụ Khí • Tầng 9",
			"isPlayer": false,
			"label": "[Đồng Môn NPC]"
		},
		{
			"rank": 3,
			"name": "Lâm Phong",
			"title": "Trúc Sơn Kiếm Lữ",
			"discipleRank": DiscipleRank.NOI_MON,
			"contribution": 1350,
			"realm": "Tụ Khí • Tầng 7",
			"isPlayer": false,
			"label": "[Đồng Môn NPC]"
		},
		{
			"rank": 4,
			"name": "Diệp Thần",
			"title": "Trúc Sơn Ngoại Môn",
			"discipleRank": DiscipleRank.NGOAI_MON,
			"contribution": 450,
			"realm": "Tụ Khí • Tầng 4",
			"isPlayer": false,
			"label": "[Đồng Môn NPC]"
		},
		{
			"rank": 5,
			"name": "Lý Thanh Vân",
			"title": "Trúc Sơn Ngoại Môn",
			"discipleRank": DiscipleRank.NGOAI_MON,
			"contribution": 210,
			"realm": "Tụ Khí • Tầng 2",
			"isPlayer": false,
			"label": "[Đồng Môn NPC]"
		}
	]
	
	if playerAgent:
		var pName : String = "Đạo Hữu"
		if playerAgent.get("nick") and not str(playerAgent.nick).is_empty():
			pName = str(playerAgent.nick)
		elif playerAgent.get("entityName"):
			pName = str(playerAgent.entityName)
			
		var pRank : int = GetDiscipleRank(playerAgent)
		var pContrib : int = GetTotalContribution(playerAgent)
		var pRealm : String = "Phàm Thân • Sơ Nhập"
		if playerAgent.get("stat") and playerAgent.stat.get("level"):
			var CultivationClass = preload("res://sources/actor/Cultivation.gd")
			pRealm = CultivationClass.GetRealmName(playerAgent.stat.level)
			
		var playerEntry : Dictionary = {
			"rank": 0,
			"name": pName,
			"title": GetDiscipleTitle(pRank),
			"discipleRank": pRank,
			"contribution": pContrib,
			"realm": pRealm,
			"isPlayer": true,
			"label": "[Bản Thân]"
		}
		
		# Insert player into leaderboard by contribution
		board.append(playerEntry)
		board.sort_custom(func(a, b): return a["contribution"] > b["contribution"])
		for i in range(board.size()):
			board[i]["rank"] = i + 1
			
	return board

# ==============================================================================
# 13. SQLITE PERSISTENCE ENGINE
# ==============================================================================
static func EnsureSectTables(db : SQLite) -> bool:
	if not db: return false
	
	# Table 1: Player Sect Data
	var q1 : String = """
CREATE TABLE IF NOT EXISTS char_sect (
	char_id INTEGER PRIMARY KEY,
	sect_id INTEGER NOT NULL DEFAULT 995840901,
	disciple_rank INTEGER NOT NULL DEFAULT 0,
	contribution INTEGER NOT NULL DEFAULT 0,
	total_contribution INTEGER NOT NULL DEFAULT 0,
	facility_flags INTEGER NOT NULL DEFAULT 1,
	joined_time INTEGER NOT NULL DEFAULT 0
);
"""
	# Table 2: Contribution Transactions Log
	var q2 : String = """
CREATE TABLE IF NOT EXISTS char_sect_transactions (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	char_id INTEGER NOT NULL,
	trans_type TEXT NOT NULL,
	amount INTEGER NOT NULL,
	balance INTEGER NOT NULL,
	details TEXT NOT NULL,
	created_at INTEGER NOT NULL
);
"""
	# Table 3: NPC Reputation
	var q3 : String = """
CREATE TABLE IF NOT EXISTS char_sect_reputation (
	char_id INTEGER NOT NULL,
	npc_id INTEGER NOT NULL,
	affinity INTEGER NOT NULL DEFAULT 0,
	trust INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (char_id, npc_id)
);
"""
	var ok1 = db.query(q1)
	var ok2 = db.query(q2)
	var ok3 = db.query(q3)
	return ok1 and ok2 and ok3

static func SaveSectData(db : SQLite, charId : int, data : Dictionary) -> bool:
	if not db or charId <= 0: return false
	var query : String = """
INSERT INTO char_sect (char_id, sect_id, disciple_rank, contribution, total_contribution, facility_flags, joined_time)
VALUES (%d, %d, %d, %d, %d, %d, %d)
ON CONFLICT(char_id) DO UPDATE SET
	sect_id = excluded.sect_id,
	disciple_rank = excluded.disciple_rank,
	contribution = excluded.contribution,
	total_contribution = excluded.total_contribution,
	facility_flags = excluded.facility_flags,
	joined_time = excluded.joined_time;
""" % [
		charId,
		data.get("sect_id", DEFAULT_SECT_ID),
		data.get("rank", 0),
		data.get("contribution", 0),
		data.get("total_contribution", 0),
		data.get("facilities", 1),
		data.get("joined_time", 0)
	]
	return db.query(query)

static func LoadSectData(db : SQLite, charId : int) -> Dictionary:
	if not db or charId <= 0: return {}
	var query : String = "SELECT * FROM char_sect WHERE char_id = %d LIMIT 1;" % charId
	if db.query(query) and not db.query_result.is_empty():
		var row = db.query_result[0]
		return {
			"sect_id": row.get("sect_id", DEFAULT_SECT_ID),
			"rank": row.get("disciple_rank", 0),
			"contribution": row.get("contribution", 0),
			"total_contribution": row.get("total_contribution", 0),
			"facilities": row.get("facility_flags", 1),
			"joined_time": row.get("joined_time", 0)
		}
	return {}
