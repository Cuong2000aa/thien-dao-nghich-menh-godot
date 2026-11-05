extends RefCounted
class_name ExplorationSystem

## TDNM — BUILD 10: WORLD EXPANSION, EXPLORATION & ANCIENT MYSTERIES
## Autonomous Engine for World Zones, Exploration Points, Ancient Ruins, Secret Areas,
## Dynamic Encounters, Exploration Instances, Resources & Journey Journal.
## Strictly preserves Builds 01-09, Source of Mana architecture, and offline SQLite persistence.

const Localization = preload("res://sources/system/Localization.gd")
const ProgressCommonsClass = preload("res://sources/actor/ProgressCommons.gd")

# ==============================================================================
# 1. 5 EXPLORATION ZONES CATALOG
# ==============================================================================
const ZONES : Dictionary = {
	"ZONE_TRUC_SON": {
		"id": "ZONE_TRUC_SON",
		"map_id": 995840901,
		"name": "Trúc Sơn Tiên Cảnh",
		"type": "Tông Môn Sơn Vũ",
		"danger": "Cấp 1 • An Toàn",
		"danger_color": Color(0.3, 0.9, 0.3),
		"realmReq": "Phàm Thân • Sơ Nhập",
		"desc": "Sơn môn thanh tịnh của Trúc Sơn Tông, địa linh nhân kiệt, ngập tràn thiên địa linh khí, nơi khởi đầu con đường vấn đạo cầu trường sinh.",
		"resources": ["Ngân Linh Thảo", "Trúc Mộc Tinh Hoa", "Tuyền Thủy"],
		"monsters": ["Linh Khí Hạc Điểu (Ôn hòa)", "Đạo Đồng Luyện Kiếm"],
		"npcs": ["Đạo Huyền Trưởng Lão", "Liễu Thanh Y", "Hà Thiết Thủ", "Tiếp Dẫn Chấp Sự"],
		"secrets": ["SECRET_HOAC_LINH_DIA"],
		"pois": ["POI_TRAN_PHAP_NGU_HANH", "POI_LINH_TUYEN_CO_LAC"],
		"firstDiscoveryTuVi": 30
	},
	"ZONE_SON_LAM_NGOAI_VI": {
		"id": "ZONE_SON_LAM_NGOAI_VI",
		"map_id": 1841251538,
		"name": "Sơn Lâm Ngoại Vi",
		"type": "Lâm Uyên Dã Ngoại",
		"danger": "Cấp 1-5 • Nguy Hiểm",
		"danger_color": Color(0.9, 0.8, 0.2),
		"realmReq": "Tụ Khí • Tầng 1",
		"desc": "Dãy đồi rừng rậm rạp dưới chân núi Trúc Sơn. Nơi sinh sống của dã thú và yêu trùng hấp thu nguyệt hoa dị hóa, đồng thời ẩn chứa nhiều dược thảo quý.",
		"resources": ["Ngân Linh Thảo", "U Hồn Thảo", "Huyền Thiết Khoáng", "Cuu Diep Ngoc Chi", "U Hon Huyet Dang"],
		"monsters": ["Huyết Tinh Trùng", "Thảo Nguyên Lang Yêu", "Xích Viêm Linh Trùng"],
		"npcs": ["Diệp Tử Lăng (Liệp Thú Sư)", "Dấu vết tu sĩ ngã xuống"],
		"secrets": ["SECRET_HANG_DONG_AN"],
		"pois": ["POI_CUU_DIEP_NGOC_CHI", "POI_LINH_KHOANG_CO_LINH_THIET", "POI_DAU_VET_CHIEN_DAU"],
		"firstDiscoveryTuVi": 45
	},
	"ZONE_CO_DAO_PHE_TICH": {
		"id": "ZONE_CO_DAO_PHE_TICH",
		"map_id": 1967386498,
		"name": "Cổ Đạo Phế Tích",
		"type": "Động Quật Cổ Xưa",
		"danger": "Cấp 5-8 • Hiểm Địa",
		"danger_color": Color(0.95, 0.5, 0.2),
		"realmReq": "Tụ Khí • Tầng 5",
		"desc": "Di tích động quật ẩn sâu trong lòng núi, tàn tích của một kiếm tông thượng cổ từng bị đại kiếp tàn phá, lưu lại kiếm ý và bảo rương phong ấn.",
		"resources": ["Co Linh Thiet", "Huyen Hoang Thach", "U Minh Thạch"],
		"monsters": ["Cổ Thạch Khôi Lỗi", "Oán Hồn Kiếm Nô"],
		"npcs": ["Cổ Di Hài Tiền Nhân", "Trận Linh Tàn Phách"],
		"secrets": ["SECRET_MAT_THAT_KIEM_Y"],
		"pois": ["POI_BIA_DA_MINH_VAN", "POI_RUONG_BAU_CO_TICH", "POI_CO_CO_QUAN_THACH_MON"],
		"firstDiscoveryTuVi": 60
	},
	"ZONE_LINH_KHI_BI_CANH": {
		"id": "ZONE_LINH_KHI_BI_CANH",
		"map_id": 4111682275,
		"name": "Linh Khí Bí Cảnh (Hỏa Vực Xích Viêm)",
		"type": "Bí Cảnh Thử Thách",
		"danger": "Cấp 8-15 • Cấm Địa",
		"danger_color": Color(0.95, 0.2, 0.2),
		"realmReq": "Tụ Khí • Tầng 8",
		"desc": "Không gian bí cảnh dị giới ngập tràn hỏa khí nung nấu và linh tuyền sôi sục, sào huyệt của Xích Viêm Thú Hậu hung hãn bảo vệ linh tuyền.",
		"resources": ["Xích Viêm Khoáng", "Yêu Thú Huyết Tinh", "Xích Viêm Yêu Đan"],
		"monsters": ["Xích Viêm Thú Hậu (BOSS)", "Xích Viêm Ấu Thú", "Viêm Nham Ma Viên"],
		"npcs": ["Thượng Cổ Trận Cột"],
		"secrets": ["SECRET_PHONG_AN_HOA_HO"],
		"pois": ["Trận Nhãn Phong Ấn", "Hỏa Vực Cổ Đài"],
		"firstDiscoveryTuVi": 80
	},
	"ZONE_THANH_SA_CANG": {
		"id": "ZONE_THANH_SA_CANG",
		"map_id": 2608626462,
		"name": "Thanh Sa Cảng",
		"type": "Thương Cảng Nhập Thế",
		"danger": "Cấp 1 • An Toàn",
		"danger_color": Color(0.3, 0.9, 0.3),
		"realmReq": "Phàm Thân • Sơ Nhập",
		"desc": "Thành phố cảng giao thương sầm uất ven bờ biển, nơi các tu sĩ nhập thế trao đổi tài nguyên và nghe ngóng phong vân thiên hạ.",
		"resources": ["Hải Hồn Thạch", "Trầm Hương Sa", "Bạch Ngân Khoáng"],
		"monsters": ["Sa Hải Bọ", "Hải Đạo Tán Tu"],
		"npcs": ["Thành Chủ Phủ Chấp Sự", "Hải Vực Thương Nhân"],
		"secrets": ["SECRET_CHIEN_TRUONG_CO"],
		"pois": ["Cổ Vận Linh Chu", "Bia Đá Cảng Khẩu"],
		"firstDiscoveryTuVi": 25
	}
}

# ==============================================================================
# 2. 8 EXPLORATION POINTS CATALOG (UNIQUE STATES & BEHAVIORS)
# ==============================================================================
const EXPLORATION_POINTS : Dictionary = {
	"POI_BIA_DA_MINH_VAN": {
		"id": "POI_BIA_DA_MINH_VAN",
		"name": "Bia Đá Minh Văn Cổ Xưa",
		"zone_id": "ZONE_CO_DAO_PHE_TICH",
		"type": "STELE",
		"desc": "Bia đá khắc cổ ngữ: 'Thái sơ hữu đạo, vạn vật giai không. Mộc hỏa tương sinh, cơ quan tự phá.'",
		"rewardTuVi": 60,
		"rewardClue": "CLUE_CO_DAO_CO_QUAN",
		"isOneTime": true
	},
	"POI_RUONG_BAU_CO_TICH": {
		"id": "POI_RUONG_BAU_CO_TICH",
		"name": "Cổ Tích Bảo Rương",
		"zone_id": "ZONE_CO_DAO_PHE_TICH",
		"type": "CHEST",
		"desc": "Chiếc rương bằng đồng cổ ngàn năm khóa chặt bởi phù văn phong ấn.",
		"reqItem": "Co Dao Chi Khoa",
		"isOneTime": true,
		"rewardItems": ["Thanh Phong Co Kiem", "Linh Thach Thuong Pham"],
		"rewardTuVi": 100
	},
	"POI_TRAN_PHAP_NGU_HANH": {
		"id": "POI_TRAN_PHAP_NGU_HANH",
		"name": "Trận Pháp Ngũ Hành Khuyết Thiếu",
		"zone_id": "ZONE_TRUC_SON",
		"type": "ARRAY",
		"desc": "Trận bàn cổ đại gồm 5 thạch đài ngũ hành. Cần kích hoạt theo đúng thứ tự tương sinh: Mộc -> Hỏa -> Thổ -> Kim -> Thủy.",
		"sequence": ["MOC", "HOA", "THO", "KIM", "THUY"],
		"rewardTuVi": 80,
		"rewardItem": "Co Tran Bi Quyen",
		"isOneTime": true
	},
	"POI_LINH_KHOANG_CO_LINH_THIET": {
		"id": "POI_LINH_KHOANG_CO_LINH_THIET",
		"name": "Mạch Khoáng Cổ Linh Thiết",
		"zone_id": "ZONE_SON_LAM_NGOAI_VI",
		"type": "MINE",
		"desc": "Mạch khoáng lộ thiên phát ra kim quang lấp lánh, cần búa hoặc khí kình để khai thác.",
		"reqProfession": "Khai Khoáng Sư",
		"rewardItem": "Co Linh Thiet",
		"count": 2,
		"cooldownSec": 20
	},
	"POI_CUU_DIEP_NGOC_CHI": {
		"id": "POI_CUU_DIEP_NGOC_CHI",
		"name": "Cửu Diệp Ngọc Chi Bụi Cây",
		"zone_id": "ZONE_SON_LAM_NGOAI_VI",
		"type": "HERB",
		"desc": "Linh chi 9 cánh tỏa hương thơm ngát giữa vách đá hiểm trở.",
		"reqProfession": "Linh Thuc Su",
		"rewardItem": "Cuu Diep Ngoc Chi",
		"count": 1,
		"cooldownSec": 25
	},
	"POI_DAU_VET_CHIEN_DAU": {
		"id": "POI_DAU_VET_CHIEN_DAU",
		"name": "Dấu Vết Kiếm Khí Tiền Nhân",
		"zone_id": "ZONE_SON_LAM_NGOAI_VI",
		"type": "BATTLE_TRACE",
		"desc": "Vết chém kiếm ý sâu vào vách đá hoa cương, lưu lại đạo vận sắc bén ngàn năm chưa tan.",
		"reqComprehension": 15,
		"rewardTuVi": 50,
		"rewardClue": "CLUE_TIEN_NHAN_KIEM_Y",
		"isOneTime": true
	},
	"POI_CO_CO_QUAN_THACH_MON": {
		"id": "POI_CO_CO_QUAN_THACH_MON",
		"name": "Thạch Môn Cơ Quan Tỏa",
		"zone_id": "ZONE_CO_DAO_PHE_TICH",
		"type": "CONTRAPTION",
		"desc": "Cửa đá khổng lồ khóa kín lối vào mật thất, yêu cầu kích hoạt đủ 2 cơ quan tả - hữu.",
		"leversNeeded": 2,
		"rewardTuVi": 70,
		"unlocksSecret": "SECRET_MAT_THAT_KIEM_Y",
		"isOneTime": true
	},
	"POI_LINH_TUYEN_CO_LAC": {
		"id": "POI_LINH_TUYEN_CO_LAC",
		"name": "Linh Tuyền Thạch Nhũ",
		"zone_id": "ZONE_TRUC_SON",
		"type": "SPRING",
		"desc": "Suối nước linh khí ngàn năm tích tụ từ thạch nhũ, uống vào gột rửa kinh mạch hồi phục sinh lực.",
		"buffEffect": "Linh Tuyền Hộ Thể (+20% Tốc Độ Tu Luyện)",
		"restoreHp": 9999,
		"restoreMp": 9999,
		"cooldownSec": 30
	}
}

# ==============================================================================
# 3. 5 DISCOVERABLE SECRETS CATALOG
# ==============================================================================
const SECRET_AREAS : Dictionary = {
	"SECRET_HANG_DONG_AN": {
		"id": "SECRET_HANG_DONG_AN",
		"name": "Sơn Lâm Ẩn Động",
		"zone_id": "ZONE_SON_LAM_NGOAI_VI",
		"conditionType": "PERCEPTION",
		"reqStat": "concentration",
		"reqVal": 12,
		"desc": "Khe nứt tự nhiên ẩn sau khóm trúc rậm rạp, bên trong có mỏ Huyền Thiết và rương cổ tàn tu.",
		"rewardTuVi": 60,
		"rewardItems": ["Huyen Thiet Khoang", "Co Dao Chi Khoa"]
	},
	"SECRET_MAT_THAT_KIEM_Y": {
		"id": "SECRET_MAT_THAT_KIEM_Y",
		"name": "Mật Thất Kiếm Ý Tiền Nhân",
		"zone_id": "ZONE_CO_DAO_PHE_TICH",
		"conditionType": "CONTRAPTION",
		"reqContraption": "POI_CO_CO_QUAN_THACH_MON",
		"desc": "Gian mật thất cổ kính lưu giữ tàn quyển kiếm tông và pháp bảo kiếm đạo thượng cổ.",
		"rewardTuVi": 100,
		"rewardItems": ["Thanh Phong Co Kiem"]
	},
	"SECRET_HOAC_LINH_DIA": {
		"id": "SECRET_HOAC_LINH_DIA",
		"name": "Khu Vực Linh Khí Dị Thường",
		"zone_id": "ZONE_TRUC_SON",
		"conditionType": "REALM",
		"reqLevel": 3,
		"desc": "Khe nứt địa mạch tỏa ra linh vụ dày đặc, là nơi tuyệt hảo để đả tọa đột phá bình cảnh.",
		"rewardTuVi": 90,
		"rewardItems": ["Linh Thach Thuong Pham"]
	},
	"SECRET_CHIEN_TRUONG_CO": {
		"id": "SECRET_CHIEN_TRUONG_CO",
		"name": "Tàn Tích Cổ Chiến Trường Dưới Cát",
		"zone_id": "ZONE_THANH_SA_CANG",
		"conditionType": "LEVEL",
		"reqLevel": 5,
		"desc": "Bãi phế tích binh khí vùi sâu dưới cát trắng, lưu lại dấu tích trận đại kiếp cổ xưa.",
		"rewardTuVi": 70,
		"rewardItems": ["Huyen Hoang Thach", "Bone"]
	},
	"SECRET_PHONG_AN_HOA_HO": {
		"id": "SECRET_PHONG_AN_HOA_HO",
		"name": "Nơi Phong Ấn Hỏa Hồ Cổ Đại",
		"zone_id": "ZONE_LINH_KHI_BI_CANH",
		"conditionType": "ITEM",
		"reqItem": "Xich Viem Bao Chau",
		"desc": "Động nham thạch sâu dưới lòng đất, nơi từng phong ấn yêu hồ thượng cổ.",
		"rewardTuVi": 120,
		"rewardItems": ["Xich Viem Yeu Dan", "Yeu Thu Huyet Tinh"]
	}
}

# ==============================================================================
# 4. 3 ANCIENT RUINS CATALOG (WITH STEP-BY-STEP CONTRAPTIONS)
# ==============================================================================
const ANCIENT_RUINS : Dictionary = {
	"RUIN_TRUC_SON_CO_DONG": {
		"id": "RUIN_TRUC_SON_CO_DONG",
		"name": "Trúc Sơn Cổ Đạo Di Tích",
		"zone_id": "ZONE_CO_DAO_PHE_TICH",
		"map_id": 1967386498,
		"stepsTotal": 5,
		"stepsDesc": [
			"Đọc và giải mã Bia Đá Minh Văn Cổ Xưa",
			"Kích hoạt cơ quan Tả - Hữu Thạch Trụ đối xứng",
			"Đánh bại Cổ Thạch Khôi Lỗi canh giữ lối đi",
			"Mở cửa Thạch Môn Mật Thất Kiếm Ý",
			"Mở Cổ Tích Bảo Rương đoạt bảo vật truyền thừa"
		],
		"rewardTuVi": 200,
		"rewardItems": ["Thanh Phong Co Kiem", "Co Dao Chi Khoa"],
		"titleReward": "Cổ Đạo Kiếm Ý Khám Phá Giả"
	},
	"RUIN_HIEN_VIEN_CO_TRAN": {
		"id": "RUIN_HIEN_VIEN_CO_TRAN",
		"name": "Hiên Viên Phong Ấn Cổ Trận",
		"zone_id": "ZONE_TRUC_SON",
		"map_id": 995840901,
		"stepsTotal": 4,
		"stepsDesc": [
			"Thu thập đủ 3 Tàn Thạch Trận Kỳ phân tán quanh sơn môn",
			"Đặt Trận Kỳ vào Trận Bàn Ngũ Hành theo luật tương sinh",
			"Đánh bại Lôi Quang Linh Thể thức tỉnh canh trận",
			"Kích hoạt Tụ Linh Đại Trận hồi phục linh mạch sơn môn"
		],
		"rewardTuVi": 180,
		"rewardItems": ["Co Tran Bi Quyen"],
		"sectContribution": 50
	},
	"RUIN_XICH_VIEM_DI_QUAT": {
		"id": "RUIN_XICH_VIEM_DI_QUAT",
		"name": "Xích Viêm Cổ Tích Địa Quật",
		"zone_id": "ZONE_LINH_KHI_BI_CANH",
		"map_id": 4111682275,
		"stepsTotal": 4,
		"stepsDesc": [
			"Cân bằng cơ quan nhiệt độ Hỏa - Thủy tại Thạch Bi",
			"Băng qua vùng nham thạch nguy hiểm",
			"Tiêu diệt Viêm Nham Tinh Anh hộ vệ",
			"Khai mở cơ quan thạch thất đoạt Cổ Đan Phương"
		],
		"rewardTuVi": 250,
		"rewardItems": ["Huyen Hoang Thach", "Cuu Diep Ngoc Chi"]
	}
}

# ==============================================================================
# 5. 3 EXPLORATION DUNGEONS / INSTANCES CATALOG
# ==============================================================================
const DUNGEONS : Dictionary = {
	"DUNGEON_CO_DAO_PHE_TICH": {
		"id": "DUNGEON_CO_DAO_PHE_TICH",
		"name": "Cổ Đạo Phế Tích (Di Tích Khám Phá)",
		"type": "ANCIENT_RUIN",
		"map_id": 1967386498,
		"minLevel": 4,
		"bossOrElite": "Cổ Thạch Khôi Lỗi",
		"target": "Vượt qua cạm bẫy, giải cơ quan thạch môn và đoạt bảo rương",
		"clearRewardExp": 150,
		"clearRewardItems": ["Co Linh Thiet", "Co Dao Chi Khoa"]
	},
	"DUNGEON_U_MINH_KHOANG_QUAT": {
		"id": "DUNGEON_U_MINH_KHOANG_QUAT",
		"name": "U Minh Phế Khoáng Quật (Hang Động Nguy Hiểm)",
		"type": "DANGEROUS_CAVE",
		"map_id": 1841251538,
		"minLevel": 3,
		"bossOrElite": "U Minh Trùng Vương",
		"target": "Đột phá vòng vây yêu trùng, tiêu diệt Trùng Vương và thu thập Cổ Linh Khoáng",
		"clearRewardExp": 130,
		"clearRewardItems": ["U Hon Huyet Dang", "Huyen Thiet Khoang"]
	},
	"DUNGEON_LINH_KHI_BI_CANH": {
		"id": "DUNGEON_LINH_KHI_BI_CANH",
		"name": "Linh Khí Bí Cảnh (Hỏa Vực Xích Viêm)",
		"type": "SPIRIT_REALM",
		"map_id": 4111682275,
		"minLevel": 7,
		"bossOrElite": "Xích Viêm Thú Hậu",
		"target": "Trấn áp hỏa vực cuồng bạo, trảm sát Thú Hậu đoạt Yêu Đan",
		"clearRewardExp": 300,
		"clearRewardItems": ["Xich Viem Yeu Dan", "Yeu Thu Huyet Tinh", "Huyen Hoang Thach"]
	}
}

# ==============================================================================
# 6. 5 DYNAMIC EXPLORATION ENCOUNTERS CATALOG
# ==============================================================================
const DYNAMIC_ENCOUNTERS : Dictionary = {
	"ENCOUNTER_YEU_THU_PHUC_KICH": {
		"id": "ENCOUNTER_YEU_THU_PHUC_KICH",
		"name": "Yêu Thú Phục Kích",
		"triggerZone": "ZONE_SON_LAM_NGOAI_VI",
		"desc": "Bụi cây xào xạc, đàn linh trùng và dã lang bị linh khí kích động lao ra phục kích!",
		"rewardExp": 40,
		"rewardItem": "Maggot Slime",
		"cooldownSec": 30
	},
	"ENCOUNTER_LINH_THAO_XUAT_THE": {
		"id": "ENCOUNTER_LINH_THAO_XUAT_THE",
		"name": "Linh Thảo Dị Biến Xuất Hiện",
		"triggerZone": "ZONE_SON_LAM_NGOAI_VI",
		"desc": "Tử khí bốc lên ngùn ngụt, một đóa Cửu Diệp Ngọc Chi vừa đâm chồi nở rộ trong 60 giây!",
		"rewardExp": 60,
		"rewardItem": "Cuu Diep Ngoc Chi",
		"cooldownSec": 45
	},
	"ENCOUNTER_THUONG_NHAN_BI_AN": {
		"id": "ENCOUNTER_THUONG_NHAN_BI_AN",
		"name": "Du Phương Cổ Thương Nhân",
		"triggerZone": "ZONE_THANH_SA_CANG",
		"desc": "Một lão nhân bí ẩn đội nón lá xuất hiện bên tảng đá lớn, mang theo kỳ trân dị bảo.",
		"rewardExp": 20,
		"rewardItem": "Co Dao Chi Khoa",
		"cooldownSec": 60
	},
	"ENCOUNTER_DAU_VET_TU_SI": {
		"id": "ENCOUNTER_DAU_VET_TU_SI",
		"name": "Tàn Cốt Tán Tu",
		"triggerZone": "ZONE_CO_DAO_PHE_TICH",
		"desc": "Phát hiện di vật của một vị tiền bối ngã xuống, bên trong chứa tàn quyển và linh thạch.",
		"rewardExp": 50,
		"rewardItem": "Linh Thach Thuong Pham",
		"cooldownSec": 40
	},
	"ENCOUNTER_CO_QUAN_DONG_LOAN": {
		"id": "ENCOUNTER_CO_QUAN_DONG_LOAN",
		"name": "Cơ Quan Cổ Đột Nhiên Kích Hoạt",
		"triggerZone": "ZONE_CO_DAO_PHE_TICH",
		"desc": "Trận văn dưới chân phát sáng, kiếm khí cạm bẫy bắn ra, cần phản xạ thân pháp né tránh!",
		"rewardExp": 55,
		"rewardItem": "Co Linh Thiet",
		"cooldownSec": 50
	}
}

# ==============================================================================
# 7. 3 MINI-BOSSES / ELITE CHALLENGES CATALOG
# ==============================================================================
const MINI_BOSSES : Dictionary = {
	"MINI_BOSS_KHOI_LOI_THU_VE": {
		"id": "MINI_BOSS_KHOI_LOI_THU_VE",
		"name": "Cổ Thạch Khôi Lỗi",
		"zone_id": "ZONE_CO_DAO_PHE_TICH",
		"level": 6,
		"maxHp": 320,
		"attack": 28,
		"defense": 20,
		"specialTrait": "Kháng Vật Lý Cao, Dậm Đất Chấn Động",
		"dropItem": "Co Linh Thiet",
		"dropExp": 120
	},
	"MINI_BOSS_TRUNG_VUONG": {
		"id": "MINI_BOSS_TRUNG_VUONG",
		"name": "U Minh Trùng Vương",
		"zone_id": "ZONE_SON_LAM_NGOAI_VI",
		"level": 7,
		"maxHp": 380,
		"attack": 32,
		"defense": 14,
		"specialTrait": "Nọc Độc Mộc Hệ, Triệu Hồi Ấu Trùng",
		"dropItem": "U Hon Huyet Dang",
		"dropExp": 150
	},
	"MINI_BOSS_VIEM_NHAM_TINH_ANH": {
		"id": "MINI_BOSS_VIEM_NHAM_TINH_ANH",
		"name": "Viêm Nham Ma Viên",
		"zone_id": "ZONE_LINH_KHI_BI_CANH",
		"level": 9,
		"maxHp": 450,
		"attack": 40,
		"defense": 18,
		"specialTrait": "Hỏa Diễm Hộ Thể, Đòn Đánh Thiêu Đốt",
		"dropItem": "Huyen Hoang Thach",
		"dropExp": 200
	}
}

# ==============================================================================
# 8. RUNTIME MEMORY STATE (PER CHARACTER)
# ==============================================================================
static var runtimeDiscoveredZones : Dictionary = {}       # charId -> Array[String] (zone_id)
static var runtimeExplorationPoints : Dictionary = {}     # charId -> Dictionary (point_id -> state int)
static var runtimeRuinProgress : Dictionary = {}          # charId -> Dictionary (ruin_id -> { "step": int, "completed": bool })
static var runtimeFoundSecrets : Dictionary = {}          # charId -> Array[String] (secret_id)
static var runtimeClearedDungeons : Dictionary = {}       # charId -> Dictionary (dungeon_id -> { "clears": int, "bestTime": int })
static var runtimeOpenedChests : Dictionary = {}          # charId -> Array[String] (chest_id)
static var runtimeHarvestedNodes : Dictionary = {}        # charId -> Dictionary (node_id -> timestamp)
static var runtimeDynamicEncounters : Dictionary = {}     # charId -> Dictionary (encounter_id -> timestamp)
static var runtimeJourneyLog : Dictionary = {}            # charId -> Array[Dictionary] (entry: { "text": String, "time": int, "type": String })

# ==============================================================================
# 9. HELPER FUNCTIONS
# ==============================================================================
static func _GetCharId(actor : Node) -> int:
	if not actor: return 1
	if "charID" in actor and actor.charID > 0:
		return actor.charID
	if "id" in actor and actor.id > 0:
		return actor.id
	if "peerID" in actor and actor.peerID > 0:
		return actor.peerID
	return 1

static func _AddJournalEntry(charId : int, text : String, entryType : String = "EXPLORATION"):
	if not runtimeJourneyLog.has(charId):
		runtimeJourneyLog[charId] = []
	var now = int(Time.get_unix_time_from_system())
	runtimeJourneyLog[charId].append({
		"text": text,
		"time": now,
		"type": entryType
	})

static func _AddExpSafe(actor : Node, value : int):
	if not actor or value <= 0: return
	if actor is BaseAgent:
		_AddExpSafe(actor, value)
	elif "stat" in actor and actor.stat:
		if actor.stat.has_method("AddExperience"):
			actor.stat.AddExperience(value)

static func _AddItemSafe(actor : Node, itemHash : int, count : int = 1):
	if not actor or count <= 0: return
	if actor is BaseAgent:
		_AddItemSafe(actor, itemHash, count)
	elif "inventory" in actor and actor.inventory:
		var cell = DB.GetItem(itemHash)
		if cell:
			actor.inventory.AddItem(cell, count)

static func HasItem(actor : Node, itemHash : int, count : int = 1) -> bool:
	if not actor or not actor.inventory:
		return false
	var cell = DB.GetItem(itemHash)
	return actor.inventory.HasItem(cell, count) if cell else false

static func TakeItem(actor : Node, itemHash : int, count : int = 1) -> bool:
	if not actor:
		return false
	if actor is BaseAgent:
		return NpcCommons.RemoveItem(actor, itemHash, count)
	if "inventory" in actor and actor.inventory:
		var cell = DB.GetItem(itemHash)
		return actor.inventory.RemoveItem(cell, count) if cell else false
	return false

# ==============================================================================
# 10. ZONE EXPLORATION ENGINE
# ==============================================================================
static func DiscoverZone(actor : Node, zoneId : String) -> Dictionary:
	var charId = _GetCharId(actor)
	if not runtimeDiscoveredZones.has(charId):
		runtimeDiscoveredZones[charId] = []
		
	if not ZONES.has(zoneId):
		return { "success": false, "message": "Khu vực không tồn tại: %s" % zoneId }
		
	var zone = ZONES[zoneId]
	if zoneId in runtimeDiscoveredZones[charId]:
		return { "success": true, "alreadyDiscovered": true, "zone": zone, "message": "Đã từng khám phá khu vực này." }
		
	# First discovery
	runtimeDiscoveredZones[charId].append(zoneId)
	var tuViReward = zone.get("firstDiscoveryTuVi", 30)
	if actor:
		_AddExpSafe(actor, tuViReward)
		
	var msg = "Khám phá khu vực mới: [%s]! (+%d Tu Vi). Sổ Tay Hành Trình đã được cập nhật!" % [zone["name"], tuViReward]
	_AddJournalEntry(charId, "Lần đầu đặt chân tới khu vực [%s] (%s)." % [zone["name"], zone["type"]], "ZONE")
	
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)
		
	return {
		"success": true,
		"alreadyDiscovered": false,
		"zone": zone,
		"tuViReward": tuViReward,
		"message": msg
	}

static func GetDiscoveredZones(actor : Node) -> Array:
	var charId = _GetCharId(actor)
	return runtimeDiscoveredZones.get(charId, [])

static func IsZoneDiscovered(actor : Node, zoneId : String) -> bool:
	var charId = _GetCharId(actor)
	return zoneId in runtimeDiscoveredZones.get(charId, [])

static func GetZoneByMapId(mapId : int) -> Dictionary:
	for z in ZONES.values():
		if z.get("map_id") == mapId:
			return z
	return {}

# ==============================================================================
# 11. EXPLORATION POINTS INTERACTION ENGINE
# ==============================================================================
static func InteractExplorationPoint(actor : Node, pointId : String, paramData : Dictionary = {}) -> Dictionary:
	var charId = _GetCharId(actor)
	if not runtimeExplorationPoints.has(charId):
		runtimeExplorationPoints[charId] = {}
		
	if not EXPLORATION_POINTS.has(pointId):
		return { "success": false, "message": "Điểm tương tác không tồn tại: %s" % pointId }
		
	var poi = EXPLORATION_POINTS[pointId]
	var currentState = runtimeExplorationPoints[charId].get(pointId, 0)
	
	# One-time check
	if poi.get("isOneTime", false) and currentState > 0:
		return { "success": false, "alreadyInteracted": true, "message": "Cơ quan hoặc di tích này đã được hoàn tất trước đó." }
		
	var poiType = poi.get("type", "STELE")
	var now = int(Time.get_unix_time_from_system())
	
	match poiType:
		"STELE":
			# Solve / Read Stele
			runtimeExplorationPoints[charId][pointId] = 1
			var tuVi = poi.get("rewardTuVi", 50)
			if actor:
				_AddExpSafe(actor, tuVi)
			var msg = "Lĩnh ngộ minh văn cổ: [%s]! (+%d Tu Vi)." % [poi["name"], tuVi]
			_AddJournalEntry(charId, "Lĩnh ngộ minh văn cổ tại [%s]." % poi["name"], "STELE")
			if actor is PlayerAgent:
				Network.PushNotification(msg, actor.peerID)
			return { "success": true, "type": "STELE", "message": msg, "clue": poi.get("rewardClue", "") }
			
		"CHEST":
			# Ancient Chest requiring Key Item
			var reqKey = poi.get("reqItem", "")
			if not reqKey.is_empty():
				var keyHash = DB.GetCellHash(reqKey)
				var hasKey = HasItem(actor, keyHash) if actor else false
				if not hasKey and not paramData.get("forceUnlock", false):
					return { "success": false, "message": "Rương cổ bị phù văn phong ấn khóa chặt! Cần có [%s] để mở." % reqKey }
				if hasKey and actor:
					TakeItem(actor, keyHash, 1)
					
			runtimeExplorationPoints[charId][pointId] = 1
			if not runtimeOpenedChests.has(charId):
				runtimeOpenedChests[charId] = []
			runtimeOpenedChests[charId].append(pointId)
			
			var tuVi = poi.get("rewardTuVi", 100)
			if actor:
				_AddExpSafe(actor, tuVi)
			var rewards = poi.get("rewardItems", [])
			for itName in rewards:
				if actor and DB.HasCellHash(itName):
					var itHash = DB.GetCellHash(itName)
					_AddItemSafe(actor, itHash, 1)
					
			var msg = "Mở thành công [%s]! Nhận bảo vật cổ xưa và (+%d Tu Vi)!" % [poi["name"], tuVi]
			_AddJournalEntry(charId, "Khai mở bảo rương cổ tại [%s], thu được bảo vật." % poi["name"], "CHEST")
			if actor is PlayerAgent:
				Network.PushNotification(msg, actor.peerID)
			return { "success": true, "type": "CHEST", "items": rewards, "tuVi": tuVi, "message": msg }
			
		"ARRAY":
			# Five Elements Array Puzzle
			var submittedSeq = paramData.get("sequence", [])
			var expectedSeq = poi.get("sequence", ["MOC", "HOA", "THO", "KIM", "THUY"])
			if submittedSeq != expectedSeq and not paramData.get("autoSolve", false):
				return { "success": false, "message": "Trận pháp ba động hỗn loạn! Thứ tự trận nhãn không hợp luật tương sinh." }
				
			runtimeExplorationPoints[charId][pointId] = 1
			var tuVi = poi.get("rewardTuVi", 80)
			if actor:
				_AddExpSafe(actor, tuVi)
			var rewItem = poi.get("rewardItem", "")
			if not rewItem.is_empty() and actor:
				var hId = DB.GetCellHash(rewItem)
				_AddItemSafe(actor, hId, 1)
				
			var msg = "Trận pháp ngũ hành hoàn tất tương sinh! Tụ linh quang giáng thế, nhận [%s] (+%d Tu Vi)!" % [rewItem, tuVi]
			_AddJournalEntry(charId, "Giải mã thành công [%s] theo quy luật ngũ hành tương sinh." % poi["name"], "ARRAY")
			if actor is PlayerAgent:
				Network.PushNotification(msg, actor.peerID)
			return { "success": true, "type": "ARRAY", "message": msg, "rewardItem": rewItem }
			
		"MINE", "HERB":
			# Gathering resource node with cooldown
			var lastHarvest = runtimeHarvestedNodes.get(charId, {}).get(pointId, 0)
			var cd = poi.get("cooldownSec", 20)
			if now - lastHarvest < cd and not paramData.get("ignoreCd", false):
				var remain = cd - (now - lastHarvest)
				return { "success": false, "message": "Tài nguyên nơi này chưa hồi phục, vui lòng chờ %d giây." % remain }
				
			if not runtimeHarvestedNodes.has(charId):
				runtimeHarvestedNodes[charId] = {}
			runtimeHarvestedNodes[charId][pointId] = now
			
			var itName = poi.get("rewardItem", "")
			var count = poi.get("count", 1)
			if not itName.is_empty() and actor:
				var hId = DB.GetCellHash(itName)
				_AddItemSafe(actor, hId, count)
				_AddExpSafe(actor, 15 * count)
				
			var msg = "Thu hoạch thành công %dx [%s] từ [%s]!" % [count, itName, poi["name"]]
			_AddJournalEntry(charId, "Thu hoạch tài nguyên [%s] tại [%s]." % [itName, poi["name"]], "RESOURCE")
			if actor is PlayerAgent:
				Network.PushNotification(msg, actor.peerID)
			return { "success": true, "type": poiType, "item": itName, "count": count, "message": msg }
			
		"CONTRAPTION":
			# Lever / Switch contraption
			var activatedLevers = paramData.get("levers", 2)
			var leversNeeded = poi.get("leversNeeded", 2)
			if activatedLevers < leversNeeded:
				return { "success": false, "message": "Cơ quan thạch trụ chưa mở đủ (Đã kích hoạt %d/%d)!" % [activatedLevers, leversNeeded] }
				
			runtimeExplorationPoints[charId][pointId] = 1
			var tuVi = poi.get("rewardTuVi", 70)
			if actor:
				_AddExpSafe(actor, tuVi)
			var secUnlock = poi.get("unlocksSecret", "")
			if not secUnlock.is_empty():
				DiscoverSecret(actor, secUnlock)
				
			var msg = "Thạch Môn ầm ầm mở ra! Mật thất kiếm ý cổ xưa đã lộ diện!"
			_AddJournalEntry(charId, "Kích hoạt cơ quan mở Thạch Môn cổ phế tích.", "CONTRAPTION")
			if actor is PlayerAgent:
				Network.PushNotification(msg, actor.peerID)
			return { "success": true, "type": "CONTRAPTION", "message": msg, "secretUnlocked": secUnlock }
			
		"BATTLE_TRACE":
			# Battle traces / sword intent
			runtimeExplorationPoints[charId][pointId] = 1
			var tuVi = poi.get("rewardTuVi", 50)
			if actor:
				_AddExpSafe(actor, tuVi)
			var msg = "Cảm ngộ vết kiếm tiền nhân, kiếm ý bản thân ngưng tụ thêm một bậc (+%d Tu Vi)!" % tuVi
			_AddJournalEntry(charId, "Quan sát vết kiếm khí tàn tích tại [%s]." % poi["name"], "TRACE")
			if actor is PlayerAgent:
				Network.PushNotification(msg, actor.peerID)
			return { "success": true, "type": "BATTLE_TRACE", "message": msg }
			
		"SPRING":
			# Spirit spring
			var lastDrink = runtimeHarvestedNodes.get(charId, {}).get(pointId, 0)
			var cd = poi.get("cooldownSec", 30)
			if now - lastDrink < cd and not paramData.get("ignoreCd", false):
				return { "success": false, "message": "Linh dịch đang ngưng tụ trở lại, hãy đợi %d giây." % (cd - (now - lastDrink)) }
				
			if not runtimeHarvestedNodes.has(charId):
				runtimeHarvestedNodes[charId] = {}
			runtimeHarvestedNodes[charId][pointId] = now
			
			if actor and actor.stat:
				actor.stat.health = actor.stat.current.maxHealth
				actor.stat.mana = actor.stat.current.maxMana
				_AddExpSafe(actor, 40)
				
			var msg = "Uống nước linh tuyền tẩy tủy kinh mạch! Khí Huyết & Linh Lực hồi phục 100%, nhận buff [Linh Tuyền Hộ Thể]!"
			_AddJournalEntry(charId, "Thanh tẩy kinh mạch tại Linh Tuyền Thạch Nhũ.", "SPRING")
			if actor is PlayerAgent:
				Network.PushNotification(msg, actor.peerID)
			return { "success": true, "type": "SPRING", "message": msg }
			
	return { "success": false, "message": "Loại tương tác chưa được hỗ trợ." }

# ==============================================================================
# 12. SECRET AREAS DISCOVERY ENGINE
# ==============================================================================
static func DiscoverSecret(actor : Node, secretId : String) -> Dictionary:
	var charId = _GetCharId(actor)
	if not runtimeFoundSecrets.has(charId):
		runtimeFoundSecrets[charId] = []
		
	if not SECRET_AREAS.has(secretId):
		return { "success": false, "message": "Mật thất/Bí cảnh không tồn tại: %s" % secretId }
		
	var sec = SECRET_AREAS[secretId]
	if secretId in runtimeFoundSecrets[charId]:
		return { "success": true, "alreadyFound": true, "secret": sec, "message": "Bí mật này đã được phát hiện trước đó." }
		
	# Check conditions
	var cType = sec.get("conditionType", "PERCEPTION")
	match cType:
		"PERCEPTION":
			var reqVal = sec.get("reqVal", 10)
			var curVal = 15
			if actor and actor.stat:
				curVal = actor.stat.concentration
			if curVal < reqVal:
				return { "success": false, "message": "Thần thức chưa đủ nhạy bén để phát giác dị thường (Cần Thần Thức %d)!" % reqVal }
		"REALM", "LEVEL":
			var reqLvl = sec.get("reqLevel", 1)
			var curLvl = actor.stat.level if actor and actor.stat else 1
			if curLvl < reqLvl:
				return { "success": false, "message": "Tu vi cảnh giới chưa đủ để cảm ứng bí cảnh (Cần Cấp %d)!" % reqLvl }
		"ITEM":
			var reqIt = sec.get("reqItem", "")
			if not reqIt.is_empty():
				var hId = DB.GetCellHash(reqIt)
				var has = HasItem(actor, hId) if actor else false
				if not has:
					return { "success": false, "message": "Cần mang theo kỳ bảo [%s] để cộng hưởng mở kết giới!" % reqIt }
		"CONTRAPTION":
			var reqCont = sec.get("reqContraption", "")
			var state = runtimeExplorationPoints.get(charId, {}).get(reqCont, 0)
			if state <= 0:
				return { "success": false, "message": "Cơ quan đối ứng chưa được kích hoạt hoàn toàn!" }
				
	runtimeFoundSecrets[charId].append(secretId)
	var tuVi = sec.get("rewardTuVi", 60)
	if actor:
		_AddExpSafe(actor, tuVi)
		
	var items = sec.get("rewardItems", [])
	for itName in items:
		if actor and DB.HasCellHash(itName):
			var itHash = DB.GetCellHash(itName)
			_AddItemSafe(actor, itHash, 1)
			
	var msg = "Phát hiện bí cảnh ẩn: [%s]! Nhận (+%d Tu Vi) và kỳ bảo!" % [sec["name"], tuVi]
	_AddJournalEntry(charId, "Phát hiện khu vực bí mật ẩn: [%s]." % sec["name"], "SECRET")
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)
		
	return { "success": true, "alreadyFound": false, "secret": sec, "tuVi": tuVi, "items": items, "message": msg }

static func GetFoundSecrets(actor : Node) -> Array:
	var charId = _GetCharId(actor)
	return runtimeFoundSecrets.get(charId, [])

# ==============================================================================
# 13. ANCIENT RUINS PROGRESSION ENGINE
# ==============================================================================
static func ProgressAncientRuin(actor : Node, ruinId : String, stepCompleted : int) -> Dictionary:
	var charId = _GetCharId(actor)
	if not runtimeRuinProgress.has(charId):
		runtimeRuinProgress[charId] = {}
		
	if not ANCIENT_RUINS.has(ruinId):
		return { "success": false, "message": "Di tích không tồn tại: %s" % ruinId }
		
	var ruin = ANCIENT_RUINS[ruinId]
	var currentInfo = runtimeRuinProgress[charId].get(ruinId, { "step": 0, "completed": false })
	
	if currentInfo.get("completed", false):
		return { "success": true, "alreadyCompleted": true, "message": "Di tích này đã được hoàn thành trước đó." }
		
	currentInfo["step"] = max(currentInfo.get("step", 0), stepCompleted)
	var totalSteps = ruin.get("stepsTotal", 5)
	
	if currentInfo["step"] >= totalSteps:
		currentInfo["completed"] = true
		runtimeRuinProgress[charId][ruinId] = currentInfo
		
		# Ruin Completion Rewards
		var tuVi = ruin.get("rewardTuVi", 200)
		if actor:
			_AddExpSafe(actor, tuVi)
			
		var items = ruin.get("rewardItems", [])
		for itName in items:
			if actor and DB.HasCellHash(itName):
				var itHash = DB.GetCellHash(itName)
				_AddItemSafe(actor, itHash, 1)
				
		var msg = "CHÚC MỪNG: Hoàn thành toàn diện di tích [%s]! Nhận đại lượng Tu Vi (+%d) và bảo vật!" % [ruin["name"], tuVi]
		_AddJournalEntry(charId, "Vượt qua toàn bộ thử thách của di tích cổ [%s]." % ruin["name"], "RUIN")
		if actor is PlayerAgent:
			Network.PushNotification(msg, actor.peerID)
			
		return {
			"success": true,
			"isCompleted": true,
			"step": currentInfo["step"],
			"totalSteps": totalSteps,
			"ruin": ruin,
			"tuVi": tuVi,
			"items": items,
			"message": msg
		}
	else:
		runtimeRuinProgress[charId][ruinId] = currentInfo
		var stepText = ruin["stepsDesc"][currentInfo["step"] - 1] if currentInfo["step"] <= ruin["stepsDesc"].size() else ""
		var msg = "Tiến độ di tích [%s]: Bước %d/%d hoàn tất (%s)!" % [ruin["name"], currentInfo["step"], totalSteps, stepText]
		_AddJournalEntry(charId, "Tiến độ di tích [%s]: Hoàn thành bước %d." % [ruin["name"], currentInfo["step"]], "RUIN")
		if actor is PlayerAgent:
			Network.PushNotification(msg, actor.peerID)
		return {
			"success": true,
			"isCompleted": false,
			"step": currentInfo["step"],
			"totalSteps": totalSteps,
			"ruin": ruin,
			"message": msg
		}

static func GetRuinProgress(actor : Node, ruinId : String) -> Dictionary:
	var charId = _GetCharId(actor)
	return runtimeRuinProgress.get(charId, {}).get(ruinId, { "step": 0, "completed": false })

# ==============================================================================
# 14. EXPLORATION INSTANCES & DUNGEONS ENGINE
# ==============================================================================
static func ClearDungeon(actor : Node, dungeonId : String, clearTimeSec : int = 120) -> Dictionary:
	var charId = _GetCharId(actor)
	if not runtimeClearedDungeons.has(charId):
		runtimeClearedDungeons[charId] = {}
		
	if not DUNGEONS.has(dungeonId):
		return { "success": false, "message": "Phụ bản không tồn tại: %s" % dungeonId }
		
	var dng = DUNGEONS[dungeonId]
	var cur = runtimeClearedDungeons[charId].get(dungeonId, { "clears": 0, "bestTime": 999999 })
	cur["clears"] = cur.get("clears", 0) + 1
	if clearTimeSec < cur.get("bestTime", 999999):
		cur["bestTime"] = clearTimeSec
	runtimeClearedDungeons[charId][dungeonId] = cur
	
	var tuVi = dng.get("clearRewardExp", 150)
	if actor:
		_AddExpSafe(actor, tuVi)
		
	var items = dng.get("clearRewardItems", [])
	for itName in items:
		var itHash = DB.GetCellHash(itName)
		if actor:
			_AddItemSafe(actor, itHash, 1)
			
	var msg = "Vượt qua phụ bản khám phá: [%s]! Thời gian: %d giây. Nhận (+%d Tu Vi) và chiến lợi phẩm!" % [dng["name"], clearTimeSec, tuVi]
	_AddJournalEntry(charId, "Thông quan phụ bản [%s] (Lần %d, Kỷ lục: %ds)." % [dng["name"], cur["clears"], cur["bestTime"]], "DUNGEON")
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)
		
	return {
		"success": true,
		"dungeon": dng,
		"clears": cur["clears"],
		"bestTime": cur["bestTime"],
		"tuVi": tuVi,
		"items": items,
		"message": msg
	}

static func GetDungeonInfo(actor : Node, dungeonId : String) -> Dictionary:
	var charId = _GetCharId(actor)
	return runtimeClearedDungeons.get(charId, {}).get(dungeonId, { "clears": 0, "bestTime": 0 })

# ==============================================================================
# 15. DYNAMIC WORLD ENCOUNTERS ENGINE
# ==============================================================================
static func TriggerDynamicEncounter(actor : Node, encounterId : String) -> Dictionary:
	var charId = _GetCharId(actor)
	if not runtimeDynamicEncounters.has(charId):
		runtimeDynamicEncounters[charId] = {}
		
	if not DYNAMIC_ENCOUNTERS.has(encounterId):
		return { "success": false, "message": "Sự kiện khám phá không tồn tại: %s" % encounterId }
		
	var enc = DYNAMIC_ENCOUNTERS[encounterId]
	var now = int(Time.get_unix_time_from_system())
	var lastTrigger = runtimeDynamicEncounters[charId].get(encounterId, 0)
	var cd = enc.get("cooldownSec", 30)
	
	if now - lastTrigger < cd:
		return { "success": false, "message": "Sự kiện này vừa diễn ra, cần thời gian để tái diễn." }
		
	runtimeDynamicEncounters[charId][encounterId] = now
	var tuVi = enc.get("rewardExp", 40)
	if actor:
		_AddExpSafe(actor, tuVi)
		
	var itName = enc.get("rewardItem", "")
	if not itName.is_empty() and actor and DB.HasCellHash(itName):
		var hId = DB.GetCellHash(itName)
		_AddItemSafe(actor, hId, 1)
		
	var msg = "SỰ KIỆN KHÁM PHÁ: [%s]! %s (+%d Tu Vi)" % [enc["name"], enc["desc"], tuVi]
	_AddJournalEntry(charId, "Trải nghiệm kỳ ngộ: [%s]." % enc["name"], "ENCOUNTER")
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)
		
	return { "success": true, "encounter": enc, "tuVi": tuVi, "item": itName, "message": msg }

# ==============================================================================
# 16. JOURNEY JOURNAL QUERY
# ==============================================================================
static func GetJourneyLog(actor : Node) -> Array:
	var charId = _GetCharId(actor)
	return runtimeJourneyLog.get(charId, [])

# ==============================================================================
# 17. SQLITE PERSISTENCE SCHEMA & TRANSACTIONS
# ==============================================================================
static func EnsureExplorationTables(db : SQLite) -> bool:
	if not db: return false
	
	# 1. Discovered Zones Table
	var q1 = """
	CREATE TABLE IF NOT EXISTS char_exploration_zones (
		char_id INTEGER NOT NULL,
		zone_id TEXT NOT NULL,
		discovered_at INTEGER NOT NULL,
		PRIMARY KEY(char_id, zone_id)
	);
	"""
	db.query(q1)
	
	# 2. Exploration Points Table
	var q2 = """
	CREATE TABLE IF NOT EXISTS char_exploration_points (
		char_id INTEGER NOT NULL,
		point_id TEXT NOT NULL,
		state INTEGER NOT NULL DEFAULT 0,
		interacted_at INTEGER NOT NULL,
		PRIMARY KEY(char_id, point_id)
	);
	"""
	db.query(q2)
	
	# 3. Ruin Progress Table
	var q3 = """
	CREATE TABLE IF NOT EXISTS char_ruin_progress (
		char_id INTEGER NOT NULL,
		ruin_id TEXT NOT NULL,
		step INTEGER NOT NULL DEFAULT 0,
		is_completed INTEGER NOT NULL DEFAULT 0,
		completed_at INTEGER NOT NULL DEFAULT 0,
		PRIMARY KEY(char_id, ruin_id)
	);
	"""
	db.query(q3)
	
	# 4. Secret Areas Table
	var q4 = """
	CREATE TABLE IF NOT EXISTS char_secret_areas (
		char_id INTEGER NOT NULL,
		secret_id TEXT NOT NULL,
		discovered_at INTEGER NOT NULL,
		PRIMARY KEY(char_id, secret_id)
	);
	"""
	db.query(q4)
	
	# 5. Dungeon Instances Table
	var q5 = """
	CREATE TABLE IF NOT EXISTS char_dungeon_instances (
		char_id INTEGER NOT NULL,
		dungeon_id TEXT NOT NULL,
		clear_count INTEGER NOT NULL DEFAULT 0,
		best_time INTEGER NOT NULL DEFAULT 0,
		last_cleared_at INTEGER NOT NULL DEFAULT 0,
		PRIMARY KEY(char_id, dungeon_id)
	);
	"""
	db.query(q5)
	
	# 6. Opened Chests Table (Anti-dupe)
	var q6 = """
	CREATE TABLE IF NOT EXISTS char_opened_chests (
		char_id INTEGER NOT NULL,
		chest_id TEXT NOT NULL,
		opened_at INTEGER NOT NULL,
		PRIMARY KEY(char_id, chest_id)
	);
	"""
	db.query(q6)
	
	# 7. Resource Nodes Table
	var q7 = """
	CREATE TABLE IF NOT EXISTS char_resource_nodes (
		char_id INTEGER NOT NULL,
		node_id TEXT NOT NULL,
		last_harvested_at INTEGER NOT NULL,
		PRIMARY KEY(char_id, node_id)
	);
	"""
	db.query(q7)
	
	return true

static func SaveExplorationData(db : SQLite, charId : int) -> bool:
	if not db or charId <= 0: return false
	var now = int(Time.get_unix_time_from_system())
	
	# 1. Save Discovered Zones
	if runtimeDiscoveredZones.has(charId):
		for zId in runtimeDiscoveredZones[charId]:
			var q = "INSERT OR IGNORE INTO char_exploration_zones (char_id, zone_id, discovered_at) VALUES (%d, '%s', %d);" % [charId, zId, now]
			db.query(q)
			
	# 2. Save Exploration Points
	if runtimeExplorationPoints.has(charId):
		for pId in runtimeExplorationPoints[charId].keys():
			var st = runtimeExplorationPoints[charId][pId]
			var q = "INSERT OR REPLACE INTO char_exploration_points (char_id, point_id, state, interacted_at) VALUES (%d, '%s', %d, %d);" % [charId, pId, st, now]
			db.query(q)
			
	# 3. Save Ruin Progress
	if runtimeRuinProgress.has(charId):
		for rId in runtimeRuinProgress[charId].keys():
			var r = runtimeRuinProgress[charId][rId]
			var step = r.get("step", 0)
			var comp = 1 if r.get("completed", false) else 0
			var q = "INSERT OR REPLACE INTO char_ruin_progress (char_id, ruin_id, step, is_completed, completed_at) VALUES (%d, '%s', %d, %d, %d);" % [charId, rId, step, comp, now]
			db.query(q)
			
	# 4. Save Secret Areas
	if runtimeFoundSecrets.has(charId):
		for sId in runtimeFoundSecrets[charId]:
			var q = "INSERT OR IGNORE INTO char_secret_areas (char_id, secret_id, discovered_at) VALUES (%d, '%s', %d);" % [charId, sId, now]
			db.query(q)
			
	# 5. Save Dungeons
	if runtimeClearedDungeons.has(charId):
		for dId in runtimeClearedDungeons[charId].keys():
			var d = runtimeClearedDungeons[charId][dId]
			var clears = d.get("clears", 0)
			var best = d.get("bestTime", 0)
			var q = "INSERT OR REPLACE INTO char_dungeon_instances (char_id, dungeon_id, clear_count, best_time, last_cleared_at) VALUES (%d, '%s', %d, %d, %d);" % [charId, dId, clears, best, now]
			db.query(q)
			
	# 6. Save Opened Chests
	if runtimeOpenedChests.has(charId):
		for cId in runtimeOpenedChests[charId]:
			var q = "INSERT OR IGNORE INTO char_opened_chests (char_id, chest_id, opened_at) VALUES (%d, '%s', %d);" % [charId, cId, now]
			db.query(q)
			
	# 7. Save Resource Nodes
	if runtimeHarvestedNodes.has(charId):
		for nId in runtimeHarvestedNodes[charId].keys():
			var t = runtimeHarvestedNodes[charId][nId]
			var q = "INSERT OR REPLACE INTO char_resource_nodes (char_id, node_id, last_harvested_at) VALUES (%d, '%s', %d);" % [charId, nId, t]
			db.query(q)
			
	return true

static func LoadExplorationData(db : SQLite, charId : int) -> bool:
	if not db or charId <= 0: return false
	EnsureExplorationTables(db)
	
	# 1. Load Discovered Zones
	db.query("SELECT zone_id FROM char_exploration_zones WHERE char_id = %d;" % charId)
	runtimeDiscoveredZones[charId] = []
	for row in db.query_result:
		runtimeDiscoveredZones[charId].append(row["zone_id"])
		
	# 2. Load Exploration Points
	db.query("SELECT point_id, state FROM char_exploration_points WHERE char_id = %d;" % charId)
	runtimeExplorationPoints[charId] = {}
	for row in db.query_result:
		runtimeExplorationPoints[charId][row["point_id"]] = row["state"]
		
	# 3. Load Ruin Progress
	db.query("SELECT ruin_id, step, is_completed FROM char_ruin_progress WHERE char_id = %d;" % charId)
	runtimeRuinProgress[charId] = {}
	for row in db.query_result:
		runtimeRuinProgress[charId][row["ruin_id"]] = {
			"step": row["step"],
			"completed": (row["is_completed"] == 1)
		}
		
	# 4. Load Secret Areas
	db.query("SELECT secret_id FROM char_secret_areas WHERE char_id = %d;" % charId)
	runtimeFoundSecrets[charId] = []
	for row in db.query_result:
		runtimeFoundSecrets[charId].append(row["secret_id"])
		
	# 5. Load Dungeons
	db.query("SELECT dungeon_id, clear_count, best_time FROM char_dungeon_instances WHERE char_id = %d;" % charId)
	runtimeClearedDungeons[charId] = {}
	for row in db.query_result:
		runtimeClearedDungeons[charId][row["dungeon_id"]] = {
			"clears": row["clear_count"],
			"bestTime": row["best_time"]
		}
		
	# 6. Load Opened Chests
	db.query("SELECT chest_id FROM char_opened_chests WHERE char_id = %d;" % charId)
	runtimeOpenedChests[charId] = []
	for row in db.query_result:
		runtimeOpenedChests[charId].append(row["chest_id"])
		
	# 7. Load Resource Nodes
	db.query("SELECT node_id, last_harvested_at FROM char_resource_nodes WHERE char_id = %d;" % charId)
	runtimeHarvestedNodes[charId] = {}
	for row in db.query_result:
		runtimeHarvestedNodes[charId][row["node_id"]] = row["last_harvested_at"]
		
	return true
