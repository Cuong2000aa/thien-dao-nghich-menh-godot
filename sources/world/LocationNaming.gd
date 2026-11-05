extends RefCounted
class_name LocationNaming

## Status constants for location naming approval
const STATUS_APPROVED : String = "APPROVED"
const STATUS_PROPOSED : String = "PROPOSED"
const STATUS_PENDING : String = "PENDING"

## Centralized registry mapping internal map names to Xianxia display names and metadata
const REGISTRY : Dictionary = {
	# --- TONORI: TULIMSHAR REGION (THANH SA REGION) ---
	"Tulimshar": {
		"display_name": "Thanh Sa Cảng",
		"region": "Thanh Sa Vực",
		"status": STATUS_APPROVED,
		"description": "Thành phố cảng sầm uất trên bờ biển phía nam, khởi đầu của mọi tu sĩ nhập thế."
	},
	"Tulimshar Center": {
		"display_name": "Thanh Sa Trấn",
		"region": "Thanh Sa Vực",
		"status": STATUS_APPROVED,
		"description": "Khu trung tâm giao thương náo nhiệt của Thanh Sa Cảng."
	},
	"Tulimshar Bay": {
		"display_name": "Thanh Sa Vịnh",
		"region": "Thanh Sa Vực",
		"status": STATUS_APPROVED,
		"description": "Vịnh biển đón các chuyến linh thuyền cập bến Thanh Sa."
	},
	"Tulimshar Castle": {
		"display_name": "Thành Chủ Phủ",
		"region": "Thanh Sa Vực",
		"status": STATUS_APPROVED,
		"description": "Phủ đệ của Thành chủ cai quản toàn cõi Thanh Sa Cảng."
	},
	"Tulimshar Castle Corridors": {
		"display_name": "Thành Chủ Phủ - Hành Lang",
		"region": "Thanh Sa Vực",
		"status": STATUS_APPROVED,
		"description": "Hành lang bên trong Thành Chủ Phủ."
	},
	"Tulimshar West Chamber": {
		"display_name": "Thành Chủ Phủ - Tây Sương Phòng",
		"region": "Thanh Sa Vực",
		"status": STATUS_APPROVED,
		"description": "Tây sương phòng yên tĩnh bên trong Thành Chủ Phủ."
	},
	"Tulimshar West Wall Pathway": {
		"display_name": "Thanh Sa Cảng - Tây Thành Tường",
		"region": "Thanh Sa Vực",
		"status": STATUS_APPROVED,
		"description": "Đoạn thành tường phòng thủ kiên cố phía tây Thanh Sa Cảng."
	},

	# --- TONORI: TULIMSHAR OUTSKIRTS (THANH SA NGOẠI VI) ---
	"Tulimshar Beach": {
		"display_name": "Nguyệt Sa Hải Than",
		"region": "Thanh Sa Ngoại Vi",
		"status": STATUS_APPROVED,
		"description": "Bãi cát trắng trải dài phản chiếu ánh trăng bên ngoài Thanh Sa Cảng."
	},
	"Tulimshar Eastern Hills": {
		"display_name": "Sơn Lâm Ngoại Vi",
		"region": "Trúc Sơn Ngoại Vi",
		"status": STATUS_APPROVED,
		"description": "Dãy đồi rừng rậm ngoại vi rải rác linh thảo, dã thú và linh trùng yêu vật.",
		"danger": "Cấp 1-5 • Nguy Hiểm"
	},
	"Tulimshar Southern Hills": {
		"display_name": "Nam Sơn Hiểm Lĩnh",
		"region": "Trúc Sơn Ngoại Vi",
		"status": STATUS_APPROVED,
		"description": "Vùng đồi phía nam hiểm trở nối liền các sơn cốc yêu thú.",
		"danger": "Cấp 5-8 • Nguy Hiểm"
	},
	"Tulimshar Western Hills": {
		"display_name": "Tây Nham Lĩnh",
		"region": "Trúc Sơn Ngoại Vi",
		"status": STATUS_APPROVED,
		"description": "Dãy đồi phía tây bao bọc bãi biển và các hang động đá ngầm.",
		"danger": "Cấp 3-6 • Nguy Hiểm"
	},
	"Tulimshar Western Cave": {
		"display_name": "Cổ Đạo Phế Tích",
		"region": "Trúc Sơn Ngoại Vi",
		"status": STATUS_APPROVED,
		"description": "Động đá cổ xưa ẩm ướt ẩn giấu bia đá truyền thừa và bảo vật tiên nhân.",
		"danger": "Cấp 5-8 • Hiểm Địa"
	},

	# --- TONORI: SANDSTORM (CUỒNG SA HOANG MẠC) ---
	"Sandstorm": {
		"display_name": "Cuồng Sa Hoang Địa",
		"region": "Cuồng Sa Hoang Mạc",
		"status": STATUS_APPROVED,
		"description": "Vùng hoang mạc khô cằn nơi bão cát cuồng phong gầm thét ngày đêm."
	},
	"Desert Mines": {
		"display_name": "Cuồng Sa Khoáng Quật",
		"region": "Cuồng Sa Hoang Mạc",
		"status": STATUS_APPROVED,
		"description": "Khu mỏ khai thác linh thạch cổ xưa bị bỏ hoang trong sa mạc."
	},
	"Desert Abandoned Level": {
		"display_name": "Phế Khoáng Đạo",
		"region": "Cuồng Sa Hoang Mạc",
		"status": STATUS_PROPOSED,
		"description": "Các tầng hầm mỏ bỏ hoang đầy rẫy hiểm nguy."
	},
	"Desert Deep Level": {
		"display_name": "U Minh Thâm Tầng",
		"region": "Cuồng Sa Hoang Mạc",
		"status": STATUS_APPROVED,
		"description": "Tầng sâu nhất của hầm mỏ, nơi linh khí biến đổi kỳ dị."
	},

	# --- TONORI: DESERT PIT (XÍCH NHAM HIỂM ĐỊA) ---
	"Desert Mountains": {
		"display_name": "Xích Nham Sơn Mạch",
		"region": "Xích Nham Hiểm Địa",
		"status": STATUS_APPROVED,
		"description": "Dãy núi đá đỏ hiểm trở nhô lên giữa lòng hoang mạc."
	},
	"Desert Mountain Cave": {
		"display_name": "Xích Nham Thạch Động",
		"region": "Xích Nham Hiểm Địa",
		"status": STATUS_PROPOSED,
		"description": "Động quật ngoằn ngoèo xuyên qua lòng núi đá đỏ."
	},
	"Desert Pit": {
		"display_name": "Xích Sa Hãm Cốc",
		"region": "Xích Nham Hiểm Địa",
		"status": STATUS_PROPOSED,
		"description": "Hố sâu sa mạc nơi lưu chuyển dòng cát lún nguy hiểm."
	},
	"Snake Pit": {
		"display_name": "Vạn Xà Khanh",
		"region": "Xích Nham Hiểm Địa",
		"status": STATUS_APPROVED,
		"description": "Hiểm địa dưới lòng đất, nơi cư ngụ của vô số linh xà độc vật."
	},

	# --- TONORI: MANAYIR (LINH SA HẢI TÂN) ---
	"Manayir": {
		"display_name": "Linh Sa Cổ Trấn",
		"region": "Linh Sa Hải Tân",
		"status": STATUS_APPROVED,
		"description": "Thị trấn ốc đảo sa mạc thanh bình với các kiến trúc cổ xưa."
	},
	"Manayir Beach": {
		"display_name": "Linh Sa Hải Than",
		"region": "Linh Sa Hải Tân",
		"status": STATUS_PROPOSED,
		"description": "Bờ biển êm đềm ven ốc đảo Linh Sa."
	},

	# --- CANDOR (HÀN BĂNG ĐẢO) ---
	"Candor Cave": {
		"display_name": "Hàn Thạch Động",
		"region": "Hàn Băng Đảo",
		"status": STATUS_APPROVED,
		"description": "Động băng giá buốt vĩnh cửu quanh năm phủ tuyết trắng."
	},
	"Candor Arena": {
		"display_name": "Linh Khí Bí Cảnh",
		"region": "Bí Cảnh Thử Thách",
		"status": STATUS_APPROVED,
		"description": "Bí cảnh thượng cổ nơi phong ấn Yêu Vương và ẩn chứa cơ duyên nghịch thiên.",
		"danger": "Cấp 8-15 • Cấm Địa"
	},

	# --- ARTIS & SEWER (CỔ THÀNH VÂN CHÂU) ---
	"Artis": {
		"display_name": "Cổ Thành Vân Châu",
		"region": "Vân Châu Vực",
		"status": STATUS_APPROVED,
		"description": "Đô thành phồn hoa tráng lệ bậc nhất đại lục tu tiên."
	},
	"Artis Sewer": {
		"display_name": "Địa Đạo Cổ Thành",
		"region": "Vân Châu Vực",
		"status": STATUS_APPROVED,
		"description": "Hệ thống đường ngầm cổ xưa chằng chịt dưới chân Vân Châu."
	},

	# --- OVERWORLD (TRUNG THỔ) ---
	"Overworld": {
		"display_name": "Trung Thổ Bình Nguyên",
		"region": "Trung Thổ Đại Lục",
		"status": STATUS_APPROVED,
		"description": "Bình nguyên bao la kết nối các tông môn, thành trấn và bí cảnh."
	},

	# --- OCEAN & SHIP (ĐÔNG HẢI & LINH THUYỀN) ---
	"Ocean": {
		"display_name": "Đông Hải",
		"region": "Đông Hải Vực",
		"status": STATUS_APPROVED,
		"description": "Biển lớn mênh mông ngàn trùng sóng vỗ giữa các đại lục."
	},
	"Ship First Deck": {
		"display_name": "Linh Thuyền - Thượng Tầng Giáp Bản",
		"region": "Đông Hải Vực",
		"status": STATUS_APPROVED,
		"description": "Boong trên của Linh Thuyền vượt biển đón gió mây."
	},
	"Ship Second Deck": {
		"display_name": "Linh Thuyền - Hạ Tầng Giáp Bản",
		"region": "Đông Hải Vực",
		"status": STATUS_APPROVED,
		"description": "Boong dưới của Linh Thuyền nơi hành khách nghỉ ngơi."
	},
	"Ship Hold": {
		"display_name": "Linh Thuyền - Để Thương",
		"region": "Đông Hải Vực",
		"status": STATUS_APPROVED,
		"description": "Khoang đáy chở hàng hóa và linh tài bảo vật."
	},
	"Ship Alige Hide": {
		"display_name": "Linh Thuyền - Mật Thất",
		"region": "Đông Hải Vực",
		"status": STATUS_PROPOSED,
		"description": "Gian phòng bí mật ẩn sâu trong khoang tàu."
	},
	"Ship Nard's Room": {
		"display_name": "Linh Thuyền - Thuyền Trưởng Thất",
		"region": "Đông Hải Vực",
		"status": STATUS_APPROVED,
		"description": "Căn phòng riêng của vị thuyền trưởng lão luyện."
	},

	# --- SPLATYNA (VẠN YÊU QUẬT) ---
	"Splatyna Cave Entrance": {
		"display_name": "Vạn Yêu Quật - Động Khẩu",
		"region": "Vạn Yêu Quật",
		"status": STATUS_APPROVED,
		"description": "Lối vào u ám của hang động đầy rẫy yêu thú hung hãn."
	},
	"Splatyna's Corridor": {
		"display_name": "Vạn Yêu Quật - Huyết Lang Đạo",
		"region": "Vạn Yêu Quật",
		"status": STATUS_APPROVED,
		"description": "Hành lang dài ẩm thấp dẫn sâu vào sào huyệt yêu quái."
	},
	"Splatyna's Chamber": {
		"display_name": "Vạn Yêu Quật - Yêu Vương Điện",
		"region": "Vạn Yêu Quật",
		"status": STATUS_APPROVED,
		"description": "Đại điện trung tâm nơi ngự trị của chúa tể Vạn Yêu Quật."
	},
	"Splatyna's Dorian Dead End": {
		"display_name": "Vạn Yêu Quật - Tuyệt Bích",
		"region": "Vạn Yêu Quật",
		"status": STATUS_PROPOSED,
		"description": "Ngõ cụt vách đá hiểm trở với luồng tà khí nồng nặc."
	},
	"Splatyna's Gabriel Pit": {
		"display_name": "Vạn Yêu Quật - U Minh Uyên Khanh",
		"region": "Vạn Yêu Quật",
		"status": STATUS_PROPOSED,
		"description": "Vực sâu tăm tối chứa đựng nhiều bí ẩn chưa khai mở."
	},
	"Splatyna's Marvin Hole": {
		"display_name": "Vạn Yêu Quật - Dị Linh Bí Quật",
		"region": "Vạn Yêu Quật",
		"status": STATUS_PROPOSED,
		"description": "Hốc đá kỳ lạ nơi yêu thú tụ tập luyện ma công."
	},

	# --- DRAZIL (DRAZIL MA VỰC) ---
	"Drazil": {
		"display_name": "U Minh Di Tích",
		"region": "Ma Giới Di Tích",
		"status": STATUS_PROPOSED,
		"description": "Vùng đất u ám hoang tàn ngập tràn ma khí và cấm chế tàn tích."
	},

	# --- EXPANSION MAPS (TIER 3 EXPANSION) ---
	"TanThuThon": {
		"display_name": "Thanh Vân Thôn",
		"region": "Thanh Vân Sơn Ngoại Vi",
		"status": STATUS_APPROVED,
		"description": "Ngôi làng tân thủ cổ kính thanh bình ẩn mình dưới rặng tre và hoa đào.",
		"danger": "Cấp 1 • An Toàn"
	},
	"SacredSectHub": {
		"display_name": "Trúc Sơn Tiên Cảnh",
		"region": "Trúc Sơn Tông Đàn",
		"status": STATUS_APPROVED,
		"description": "Sơn môn thanh tịnh của Trúc Sơn Tông, nơi đệ tử khởi đầu hành trình tu tiên.",
		"danger": "Cấp 1 • An Toàn"
	}
}

## Cached lookup by hash id
static var _hash_cache : Dictionary = {}
static var _is_cache_built : bool = false

static func _EnsureCache():
	if _is_cache_built:
		return
	_hash_cache.clear()
	for internal_name in REGISTRY:
		var h : int = internal_name.hash()
		_hash_cache[h] = internal_name
	_is_cache_built = true

## Get player-facing Vietnamese display name with automatic fallback
static func GetDisplayName(identifier: Variant) -> String:
	_EnsureCache()
	
	if identifier == null:
		return ""
		
	# If FileData or MapData object
	if identifier is FileData:
		var md = identifier
		if "displayName" in md and not md.displayName.is_empty():
			return md.displayName
		return GetDisplayName(md._name)
		
	# If String
	if identifier is String:
		var name_str : String = identifier
		if REGISTRY.has(name_str):
			return REGISTRY[name_str].get("display_name", name_str)
		# Fallback to internal name
		return name_str
		
	# If Int (Hash ID)
	if identifier is int:
		var int_id : int = identifier
		if _hash_cache.has(int_id):
			return GetDisplayName(_hash_cache[int_id])
		if DB.isInitialized and DB.MapsDB.has(int_id):
			var md : MapData = DB.MapsDB[int_id]
			return GetDisplayName(md)
		return str(int_id)
		
	return str(identifier)

## Get complete location metadata
static func GetLocationInfo(identifier: Variant) -> Dictionary:
	_EnsureCache()
	var internal_name : String = ""
	
	if identifier is FileData:
		internal_name = identifier._name
	elif identifier is String:
		internal_name = identifier
	elif identifier is int:
		if _hash_cache.has(identifier):
			internal_name = _hash_cache[identifier]
		elif DB.isInitialized and DB.MapsDB.has(identifier):
			internal_name = DB.MapsDB[identifier]._name
			
	if not internal_name.is_empty() and REGISTRY.has(internal_name):
		var info = REGISTRY[internal_name].duplicate()
		info["internal_name"] = internal_name
		info["id"] = internal_name.hash()
		return info
		
	return {
		"internal_name": internal_name,
		"display_name": internal_name,
		"region": "Unknown",
		"status": STATUS_PROPOSED,
		"description": "",
		"id": internal_name.hash() if not internal_name.is_empty() else DB.UnknownHash
	}

## Get status (APPROVED / PROPOSED)
static func GetStatus(identifier: Variant) -> String:
	var info = GetLocationInfo(identifier)
	return info.get("status", STATUS_PROPOSED)
