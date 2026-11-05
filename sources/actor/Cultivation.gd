extends RefCounted
class_name Cultivation

## Centralized Cultivation and Progression System for TDNM
## Maps numerical character levels and statistics to Xianxia realms and concepts
## strictly adhering to Decision D-04 Hybrid Progression Canon (docs/world/CULTIVATION_SYSTEM.md).

const Localization = preload("res://sources/system/Localization.gd")

const REALMS = [
	# 1. Giai đoạn Tiền Tu Luyện: Phàm Thân (Mortal Stage)
	{ "min_level": 1, "max_level": 1, "realm": "Phàm Thân", "stage": "Sơ Nhập" },

	# 2. Cảnh giới thứ nhất: Tụ Khí Cửu Trọng Thiên (Qi Gathering: Tầng 1 đến Tầng 9)
	{ "min_level": 2, "max_level": 2, "realm": "Tụ Khí", "stage": "Tầng 1" },
	{ "min_level": 3, "max_level": 3, "realm": "Tụ Khí", "stage": "Tầng 2" },
	{ "min_level": 4, "max_level": 4, "realm": "Tụ Khí", "stage": "Tầng 3 (Sơ Kỳ)" },
	{ "min_level": 5, "max_level": 5, "realm": "Tụ Khí", "stage": "Tầng 4" },
	{ "min_level": 6, "max_level": 6, "realm": "Tụ Khí", "stage": "Tầng 5" },
	{ "min_level": 7, "max_level": 7, "realm": "Tụ Khí", "stage": "Tầng 6 (Trung Kỳ)" },
	{ "min_level": 8, "max_level": 8, "realm": "Tụ Khí", "stage": "Tầng 7" },
	{ "min_level": 9, "max_level": 9, "realm": "Tụ Khí", "stage": "Tầng 8" },
	{ "min_level": 10, "max_level": 10, "realm": "Tụ Khí", "stage": "Tầng 9 (Viên Mãn)" },

	# 3. Cảnh giới thứ hai: Thông Mạch (Meridian Opening: 4 Giai đoạn)
	{ "min_level": 11, "max_level": 12, "realm": "Thông Mạch", "stage": "Sơ Kỳ" },
	{ "min_level": 13, "max_level": 14, "realm": "Thông Mạch", "stage": "Trung Kỳ" },
	{ "min_level": 15, "max_level": 16, "realm": "Thông Mạch", "stage": "Hậu Kỳ" },
	{ "min_level": 17, "max_level": 18, "realm": "Thông Mạch", "stage": "Đại Viên Mãn" },

	# 4. Cảnh giới thứ ba: Đạo Cơ (Dao Foundation: 4 Giai đoạn)
	{ "min_level": 19, "max_level": 20, "realm": "Đạo Cơ", "stage": "Sơ Kỳ" },
	{ "min_level": 21, "max_level": 22, "realm": "Đạo Cơ", "stage": "Trung Kỳ" },
	{ "min_level": 23, "max_level": 24, "realm": "Đạo Cơ", "stage": "Hậu Kỳ" },
	{ "min_level": 25, "max_level": 26, "realm": "Đạo Cơ", "stage": "Đại Viên Mãn" },

	# 5. Cảnh giới thứ tư: Huyền Đan (Mystic Core: 4 Giai đoạn)
	{ "min_level": 27, "max_level": 28, "realm": "Huyền Đan", "stage": "Sơ Kỳ" },
	{ "min_level": 29, "max_level": 30, "realm": "Huyền Đan", "stage": "Trung Kỳ" },
	{ "min_level": 31, "max_level": 32, "realm": "Huyền Đan", "stage": "Hậu Kỳ" },
	{ "min_level": 33, "max_level": 34, "realm": "Huyền Đan", "stage": "Đại Viên Mãn" },

	# 6. Cảnh giới thứ năm: Nguyên Thần (Spirit Soul: 4 Giai đoạn)
	{ "min_level": 35, "max_level": 36, "realm": "Nguyên Thần", "stage": "Sơ Kỳ" },
	{ "min_level": 37, "max_level": 38, "realm": "Nguyên Thần", "stage": "Trung Kỳ" },
	{ "min_level": 39, "max_level": 40, "realm": "Nguyên Thần", "stage": "Hậu Kỳ" },
	{ "min_level": 41, "max_level": 42, "realm": "Nguyên Thần", "stage": "Đại Viên Mãn" },

	# 7. Cảnh giới thứ sáu: Thiên Nhân (Heavenly Unity: 4 Giai đoạn)
	{ "min_level": 43, "max_level": 44, "realm": "Thiên Nhân", "stage": "Sơ Kỳ" },
	{ "min_level": 45, "max_level": 46, "realm": "Thiên Nhân", "stage": "Trung Kỳ" },
	{ "min_level": 47, "max_level": 48, "realm": "Thiên Nhân", "stage": "Hậu Kỳ" },
	{ "min_level": 49, "max_level": 50, "realm": "Thiên Nhân", "stage": "Đại Viên Mãn" },

	# 8. Cảnh giới thứ bảy: Quy Hư (Void Return: 4 Giai đoạn)
	{ "min_level": 51, "max_level": 53, "realm": "Quy Hư", "stage": "Sơ Kỳ" },
	{ "min_level": 54, "max_level": 56, "realm": "Quy Hư", "stage": "Trung Kỳ" },
	{ "min_level": 57, "max_level": 58, "realm": "Quy Hư", "stage": "Hậu Kỳ" },
	{ "min_level": 59, "max_level": 60, "realm": "Quy Hư", "stage": "Đại Viên Mãn" },

	# 9. Cảnh giới thứ tám: Độ Kiếp (Tribulation Crossing: 4 Giai đoạn)
	{ "min_level": 61, "max_level": 69, "realm": "Độ Kiếp", "stage": "Sơ Kỳ" },
	{ "min_level": 70, "max_level": 79, "realm": "Độ Kiếp", "stage": "Trung Kỳ" },
	{ "min_level": 80, "max_level": 89, "realm": "Độ Kiếp", "stage": "Hậu Kỳ" },
	{ "min_level": 90, "max_level": 99, "realm": "Độ Kiếp", "stage": "Đại Viên Mãn" }
]

static func GetRealmData(level: int) -> Dictionary:
	var lvl = clampi(level, 1, 99)
	for r in REALMS:
		if lvl >= r["min_level"] and lvl <= r["max_level"]:
			return r
	return { "realm": "Độ Kiếp", "stage": "Phi Thăng" }

static func GetRealmName(level: int) -> String:
	var data = GetRealmData(level)
	if data["stage"].is_empty():
		return data["realm"]
	return "%s • %s" % [data["realm"], data["stage"]]

static func GetShortRealm(level: int) -> String:
	var data = GetRealmData(level)
	return data["realm"]

static func GetRealmColor(level: int) -> Color:
	if level <= 1:
		return Color(0.75, 0.75, 0.75) # Phàm Thân (Mortal gray)
	elif level <= 10:
		return Color(0.3, 0.85, 0.4) # Tụ Khí (Qi Gathering green)
	elif level <= 18:
		return Color(0.3, 0.75, 0.9) # Thông Mạch (Meridian Opening cyan)
	elif level <= 26:
		return Color(0.35, 0.55, 1.0) # Đạo Cơ (Dao Foundation deep blue)
	elif level <= 34:
		return Color(0.95, 0.8, 0.2) # Huyền Đan (Mystic Core gold)
	elif level <= 42:
		return Color(0.8, 0.35, 0.95) # Nguyên Thần (Spirit Soul purple)
	elif level <= 50:
		return Color(1.0, 0.45, 0.7) # Thiên Nhân (Heavenly Unity rose)
	elif level <= 60:
		return Color(0.95, 0.5, 0.2) # Quy Hư (Void Return orange)
	else:
		return Color(1.0, 0.25, 0.25) # Độ Kiếp (Tribulation Crossing crimson)

## -------------------------------------------------------------
## CULTIVATION ATTRIBUTES & MECHANICS (BUILD 04)
## -------------------------------------------------------------

## Determine Five-Element Spiritual Root (Ngũ Hành Linh Căn)
static func CalculateSpiritualRoot(player: Actor) -> Dictionary:
	if not player or not player.stat:
		return { "name": "Thiên Linh Căn (Mộc • Phong)", "element": "Mộc / Phong", "grade": "Thiên Phẩm", "purity": 95 }
	
	var conc : int = player.stat.concentration
	var vit : int = player.stat.vitality
	var strg : int = player.stat.strength
	var agi : int = player.stat.agility
	var endu : int = player.stat.endurance
	
	if conc >= 10:
		return { "name": "Thiên Linh Căn (Phong Lôi)", "element": "Phong / Lôi", "grade": "Thiên Phẩm", "purity": 98 }
	elif agi >= 10:
		return { "name": "Chân Linh Căn (Thanh Mộc)", "element": "Mộc", "grade": "Địa Phẩm", "purity": 88 }
	elif vit >= 10:
		return { "name": "Chân Linh Căn (Hậu Thổ)", "element": "Thổ", "grade": "Địa Phẩm", "purity": 85 }
	else:
		return { "name": "Thiên Linh Căn (Mộc • Phong)", "element": "Mộc / Phong", "grade": "Thiên Phẩm", "purity": 95 }

## Calculate Comprehension (Ngộ Tính)
static func CalculateComprehension(player: Actor) -> int:
	if not player or not player.stat:
		return 80
	var conc : int = player.stat.concentration
	var level : int = player.stat.level
	return clampi(60 + conc * 3 + level * 2, 50, 100)

## Calculate Aptitude (Tư Chất Căn Cốt)
static func CalculateAptitude(player: Actor) -> int:
	if not player or not player.stat:
		return 80
	var vit : int = player.stat.vitality
	var strg : int = player.stat.strength
	return clampi(60 + vit * 3 + strg * 2, 50, 100)

## Get Active Cultivation Technique (Công Pháp Đang Tu Luyện)
static func GetActiveTechnique(player: Actor) -> Dictionary:
	var level : int = player.stat.level if player and player.stat else 1
	if level < 11:
		return {
			"name": "Trúc Sơn Dẫn Khí Quyết",
			"grade": "Hoàng Giai Thượng Phẩm",
			"mastery": "Đại Thành",
			"description": "Tâm pháp nhập môn của Trúc Sơn Tông, dẫn linh khí thiên địa tôi luyện kinh mạch và đan điền."
		}
	elif level < 27:
		return {
			"name": "Thanh Phong Kiếm Điển",
			"grade": "Huyền Giai Trung Phẩm",
			"mastery": "Tiểu Thành",
			"description": "Kiếm quyết bổn tông kết hợp linh khí phong hệ, khai thông kinh mạch bộc phát kiếm khí."
		}
	else:
		return {
			"name": "Thiên Đạo Nghịch Mệnh Quyết",
			"grade": "Địa Giai Cực Phẩm",
			"mastery": "Nhập Môn",
			"description": "Nghịch chuyển càn khôn, dĩ thân vi đỉnh, câu thông quy tắc thiên địa."
		}

## Check Bottleneck Status (Bình Cảnh)
static func GetBottleneckStatus(level: int, currentExp: int, nextExp: int) -> Dictionary:
	if level >= 99:
		return {
			"hasBottleneck": true,
			"status": "Phi Thăng Thiên Kiếp",
			"description": "Đã đạt đỉnh phong giới này, chỉ chờ độ kiếp phi thăng thượng giới!"
		}
		
	if currentExp >= nextExp:
		return {
			"hasBottleneck": true,
			"status": "Bình cảnh đã xuất hiện",
			"description": "Chân khí trong đan điền đã tràn đầy! Cơ duyên đã đến, hãy chuẩn bị đột phá phá cảnh."
		}
	else:
		var percent : float = float(currentExp) / float(nextExp) * 100.0 if nextExp > 0 else 0.0
		return {
			"hasBottleneck": false,
			"status": "Đang vận công tích lũy",
			"description": "Chân khí tích lũy: %.1f%%. Tiếp tục đả tọa hoặc lịch luyện để bồi đắp tu vi." % percent
		}

## Check if player can attempt breakthrough
static func CanAttemptBreakthrough(level: int, currentExp: int, nextExp: int) -> bool:
	return currentExp >= nextExp and level < 99

## Perform Breakthrough (Đột Phá Cảnh Giới)
static func AttemptBreakthrough(player: Actor) -> Dictionary:
	if not player or not player.stat:
		return { "success": false, "message": "Nhân vật không hợp lệ." }
		
	var currentExp : int = player.stat.experience
	var nextExp : int = Experience.GetNeededExperienceForNextLevel(player.stat.level)
	
	if currentExp < nextExp:
		return {
			"success": false,
			"message": Localization.Get("Insufficient Cultivation"),
			"realm": GetRealmName(player.stat.level)
		}
		
	var oldRealm : String = GetRealmName(player.stat.level)
	player.stat.level += 1
	player.stat.experience = maxi(0, currentExp - nextExp)
	player.stat.RefreshAttributes()
	player.stat.vital_stats_updated.emit()
	
	var newRealm : String = GetRealmName(player.stat.level)
	var successMsg : String = Localization.Get("Breakthrough Successful")
	if player is BaseAgent:
		NpcCommons.PushNotification(player, "%s [%s] -> [%s]" % [successMsg, oldRealm, newRealm])
	
	return {
		"success": true,
		"message": successMsg,
		"oldRealm": oldRealm,
		"newRealm": newRealm,
		"level": player.stat.level
	}

## Get cultivation feedback message by tick index
static func GetCultivationFeedback(tick: int) -> String:
	return Localization.GetFeedback(tick)

## -------------------------------------------------------------
## LOCALIZATION COMPATIBILITY HELPERS
## -------------------------------------------------------------

static func GetStatLocalization() -> Dictionary:
	return Localization.GLOSSARY

static func GetItemLocalization() -> Dictionary:
	return {
		"Maggot Slime": {
			"name": "Linh Trùng Tương",
			"description": "Dịch tinh hoa tiết ra từ Linh Trùng, ẩn chứa linh khí loãng, dùng để luyện đan hoặc giao nộp môn phái."
		},
		"Short Sword": {
			"name": "Thanh Phong Kiếm",
			"description": "Phi kiếm sơ cấp của đệ tử Trúc Sơn Tông, thân kiếm sắc bén tỏa ra linh khí thanh phong, tăng 20 điểm Công Kích."
		},
		"Cotton Shirt": {
			"name": "Thanh Phong Đạo Bào",
			"description": "Đạo bào đệ tử sơ nhập môn phái, dệt từ thiên linh miên, thanh nhã và tăng phòng ngự cơ bản."
		},
		"Apple": {
			"name": "Linh Quả",
			"description": "Linh quả hái trên núi Trúc Sơn, ăn vào bổ sung khí huyết và thể lực."
		},
		"Cactus Potion": {
			"name": "Hồi Xuân Dược",
			"description": "Dược dịch điều chế từ thảo dược linh sơn, có tác dụng trị thương phục hồi khí huyết."
		},
		"Hoi Xuan Dan": {
			"name": "Hồi Xuân Đan",
			"description": "Đan dược trị thương sơ cấp do đệ tử Trúc Sơn Tông luyện chế, phục hồi ngay 120 điểm Khí Huyết."
		},
		"Bo Khi Dan": {
			"name": "Bổ Khí Đan",
			"description": "Đan dược ôn dưỡng kinh mạch, ngưng tụ chân khí, phục hồi 60 điểm Linh Lực."
		},
		"Ngan Linh Thao": {
			"name": "Ngân Linh Thảo",
			"description": "Linh thảo hấp thu nguyệt hoa ngân quang, chứa linh khí nhu hòa, là dược liệu cơ bản để luyện chế Hồi Xuân Đan."
		},
		"Huyen Thiet Khoang": {
			"name": "Huyền Thiết Khoáng",
			"description": "Khoáng thạch huyền thiết chìm sâu dưới lòng đất ngàn năm, cứng rắn trầm trọng, dùng để rèn linh khí hoặc tinh luyện thiết tinh."
		},
		"Thanh Phong Tinh Thiet": {
			"name": "Thanh Phong Tinh Thiết",
			"description": "Thiết tinh được nung đúc từ Huyền Thiết Khoáng kết hợp linh phong, cực kỳ sắc bén."
		},
		"Truc Son Co Bi Tan Quyen": {
			"name": "Trúc Sơn Cổ Bi Tàn Quyển",
			"description": "Mảnh tàn đồ bí kíp ghi chép tâm pháp cổ xưa do tiền nhân Trúc Sơn Tông lưu lại trên bia đá ngàn năm."
		},
		"Xich Viem Thu Hau": {
			"name": "Xích Viêm Thú Hậu",
			"description": "Hung thú ngàn năm thống lĩnh yêu trùng trong Linh Khí Bí Cảnh, toàn thân tỏa ra xích viêm hỏa diễm thiêu đốt vạn vật."
		},
		"Bottle": {
			"name": "Ngọc Bình",
			"description": "Bình ngọc nhỏ dùng để đựng linh đan hoặc linh dịch."
		},
		"Thanh Phong Kiem": {
			"name": "Thanh Phong Kiếm",
			"description": "Thanh Phong Kiếm (Hạ Phẩm): Thân kiếm sắc bén lưu chuyển kiếm khí thanh phong, tăng 24 Công Kích và 5% Bạo Kích."
		},
		"Truc Son Dao Bao": {
			"name": "Trúc Sơn Đạo Bào",
			"description": "Trúc Sơn Đạo Bào (Hạ Phẩm): Đạo bào thêu trúc xanh thanh nhã, tăng 16 Phòng Ngự và 40 Khí Huyết."
		},
		"Xich Viem Bao Chau": {
			"name": "Xích Viêm Bảo Châu",
			"description": "Xích Viêm Bảo Châu (Thượng Phẩm Pháp Bảo): Yêu đan kết tinh ngàn năm của Xích Viêm Thú Hậu, tăng 35 Pháp Công và 20 Pháp Phòng."
		},
		"Thanh Phong Bi Kip": {
			"name": "Thanh Phong Kiếm Quyết Bí Tịch",
			"description": "Thanh Phong Kiếm Quyết Bí Tịch (Hoàng Giai): Ghi chép kiếm đạo chân truyền của Trúc Sơn Tông, khi đọc có thể lĩnh ngộ Thanh Phong Kiếm Khí và Trúc Sơn Kiếm Trận."
		},
		"Tap Dich Lenh Bai": {
			"name": "Tạp Dịch Lệnh Bài",
			"description": "Thân phận bài bằng đồng xanh khắc hình rặng trúc, chứng nhận tư cách Tạp Dịch Đệ Tử, tăng 10 Khí Huyết và 2 Phòng Ngự."
		},
		"Ngoai Mon Lenh Bai": {
			"name": "Ngoại Môn Lệnh Bài",
			"description": "Thân phận bài bằng bạch thiết khắc hoa văn Thái Cực, chứng nhận đệ tử Ngoại Môn chính thức, tăng 25 Khí Huyết, 6 Công Kích và 4 Phòng Ngự."
		},
		"Noi Mon Lenh Bai": {
			"name": "Nội Môn Lệnh Bài",
			"description": "Thân phận bài bằng tử ngọc lưu chuyển kiếm khí, chứng nhận đệ tử Nội Môn rường cột của tông môn, tăng 60 Khí Huyết, 16 Công Kích và 10 Phòng Ngự."
		},
		"Chan Truyen Lenh Bai": {
			"name": "Chân Truyền Lệnh Bài",
			"description": "Lệnh bài kim ngọc do đích thân Chưởng môn phong thưởng, chứa kiếm ý chân truyền hộ thể, tăng 120 Khí Huyết, 32 Công Kích và 20 Phòng Ngự."
		}
	}

static func GetItemDisplayName(rawName : String) -> String:
	var loc = GetItemLocalization()
	if loc.has(rawName):
		return loc[rawName]["name"]
	return rawName

static func GetItemDisplayDescription(rawName : String, defaultDesc : String = "") -> String:
	var loc = GetItemLocalization()
	if loc.has(rawName) and loc[rawName].has("description"):
		return loc[rawName]["description"]
	return defaultDesc
