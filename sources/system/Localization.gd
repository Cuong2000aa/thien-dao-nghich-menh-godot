extends RefCounted
class_name Localization

## Centralized Vietnamese Xianxia Localization & Glossary Module for TDNM
## Adheres strictly to BUILD 04 requirements:
## - Full Unicode Vietnamese support
## - Standard Xianxia Cultivation Terminology (Glossary)
## - Built-in integration with Godot's TranslationServer (tr() fallback)
## - Attribute and stat tooltips & explanations
## - Cultivation and breakthrough feedback messages

const LOCALE_VI : String = "vi"

## 1. BẢNG THUẬT NGỮ CHUẨN (STANDARD GLOSSARY)
const GLOSSARY : Dictionary = {
	# Core Cultivation Concepts
	"Cultivation": "Tu Luyện",
	"Realm": "Cảnh Giới",
	"Cultivation Progress": "Tu Vi",
	"Breakthrough": "Đột Phá",
	"Spiritual Root": "Linh Căn",
	"Five Elements": "Ngũ Hành",
	"Spiritual Energy": "Linh Khí",
	"Refined Energy": "Chân Khí",
	"Qi Capacity": "Dung Lượng Linh Lực",
	"Meridian": "Kinh Mạch",
	"Dantian": "Đan Điền",
	"Technique": "Công Pháp",
	"Mind Method": "Tâm Pháp",
	"Sword Art": "Kiếm Quyết",
	"Body Refinement": "Luyện Thể",
	"Secret Art": "Bí Thuật",
	"Comprehension": "Ngộ Tính",
	"Aptitude": "Tư Chất",
	"Technique Mastery": "Mức Độ Lĩnh Hội",
	"Tribulation": "Thiên Kiếp",
	"Alchemy": "Luyện Đan",
	"Elixir": "Đan Dược",
	"Inventory": "Túi Trữ Vật",
	"Equipment": "Trang Bị",
	"Quest": "Nhiệm Vụ / Ủy Thác",
	"Bestiary": "Yêu Thú Đồ Giám",
	"World Map": "Bản Đồ Sơn Hà",
	"Dungeon": "Bí Cảnh",
	"HP": "Khí Huyết",
	"MP": "Linh Lực",
	"Stamina": "Thể Lực",
	"Attack": "Công Kích",
	"Defense": "Phòng Ngự",

	# Combat & Sword Cultivation (Chiến Đấu & Kiếm Tu)
	"Sword Qi": "Kiếm Khí",
	"Sword Intent": "Kiếm Ý",
	"Sword Stance": "Kiếm Thế",
	"Sword Array": "Kiếm Trận",
	"Combo": "Liên Kích",
	"Stun": "Choáng Váng",
	"Knockback": "Đánh Văng",
	"Interrupt": "Gián Đoạn",
	"Parry": "Đỡ Đòn",
	"Counter": "Phản Kích",
	"Invulnerable": "Vô Địch",
	"Elemental Counter": "Ngũ Hành Khắc Chế",
	"Burn": "Thiêu Đốt",
	"Freeze": "Hàn Băng",
	"Poison": "Trúng Độc",
	"Paralyze": "Tê Liệt",
	"Heavy Pressure": "Trọng Áp",
	"Palm Art": "Chưởng Pháp",
	"Fist Art": "Quyền Pháp",
	"Finger Art": "Chỉ Pháp",
	"Movement Art": "Thân Pháp",
	"Artifact": "Pháp Bảo",
	"Mortal Grade": "Phàm Phẩm",
	"Low Grade": "Hạ Phẩm",
	"Mid Grade": "Trung Phẩm",
	"High Grade": "Thượng Phẩm",
	"Supreme Grade": "Cực Phẩm",
	"Spirit Treasure": "Linh Bảo",

	# Sect & Cultivation Society (Hệ Thống Môn Phái & Tông Môn)
	"Sect": "Môn Phái",
	"Sect Contribution": "Cống Hiến Môn Phái",
	"Disciple": "Đệ Tử",
	"Disciple Rank": "Thân Phận Đệ Tử",
	"Handyman Disciple": "Tạp Dịch Đệ Tử",
	"Outer Disciple": "Ngoại Môn Đệ Tử",
	"Inner Disciple": "Nội Môn Đệ Tử",
	"Core Disciple": "Chân Truyền Đệ Tử",
	"Direct Disciple": "Thân Truyền Đệ Tử",
	"Elder": "Trưởng Lão",
	"Sect Leader": "Chưởng Môn",
	"Deacon": "Chấp Sự",
	"Main Hall": "Đại Điện",
	"Scripture Pavilion": "Tàng Kinh Các",
	"Alchemy Hall": "Dược Đường",
	"Forge Hall": "Luyện Khí Đường",
	"Spirit Gathering Array": "Tụ Linh Trận",
	"Martial Ground": "Diễn Võ Đường",
	"Mission Hall": "Nhiệm Vụ Đường",
	"Sect Ranking": "Phong Vân Bảng",
	"Sect Exchange": "Bách Bảo Các",

	# Build 07: Cultivation Economy, Crafting, Refining & Professions
	"Crafting": "Bách Nghệ Luyện Chế",
	"Forging": "Luyện Khí",
	"Refinement": "Tinh Luyện",
	"Enhance": "Cường Hóa",
	"Dismantle": "Phân Giải",
	"Spiritual Treasure": "Pháp Bảo",
	"Professions": "Nghề Nghiệp Tu Tiên",
	"Alchemist": "Luyện Đan Sư",
	"Forgemaster": "Luyện Khí Sư",
	"Herbalist": "Linh Thực Sư",
	"Miner": "Khai Khoáng Sư",
	"Furnace": "Lò Luyện Đan",
	"Anvil": "Luyện Khí Đài",
	"Recipe": "Đan Phương / Công Thức",
	"Resonance": "Độ Cộng Hưởng",
	"ItemLock": "Khóa Bảo Vệ",
	"Unlock": "Mở Khóa",
	"Purity": "Độ Tinh Thuần",
	"Success Rate": "Tỷ Lệ Thành Công",

	# BUILD 08: Main Story, NPC Relationships & Living World
	"Main Story": "Cốt Truyện Chính",
	"Quest Journal": "Sổ Tay Hành Trình",
	"NPC Dossier": "Hồ Sơ Nhân Vật",
	"Affinity": "Hảo Cảm",
	"Relationship": "Mối Quan Hệ",
	"Stranger": "Xa Lạ",
	"Acquaintance": "Quen Biết",
	"Friendly": "Thiện Cảm",
	"Trusted": "Tin Tưởng",
	"Confidant": "Tri Kỷ",
	"Heavenly Dao": "Thiên Đạo",
	"World Event": "Sự Kiện Thế Giới",
	"Clue": "Manh Mối",
	"Deduction": "Suy Luận Hiện Đại",
	"Secret": "Kỳ Duyên / Bí Mật Ẩn",
	"Choice": "Quyết Định",
	"Consequence": "Hậu Quả",
	"Transmigrator": "Xuyên Không Giả",
	"Five Elements Impure Root": "Ngũ Hành Tạp Căn",

	# Attributes (Tư Chất Bẩm Sinh)
	"Strength": "Lực Lượng",
	"Vitality": "Thể Chất",
	"Agility": "Thân Pháp",
	"Endurance": "Định Lực",
	"Concentration": "Thần Thức",

	# Advanced Stats (Thuộc Tính Cao Cấp)
	"M. Attack": "Pháp Công",
	"M. Defense": "Pháp Phòng",
	"Attack Range": "Cự Ly",
	"Cast Delay": "Niệm Chú",
	"Cooldown Delay": "Hồi Chiêu",
	"Crit Rate": "Bạo Kích",
	"Dodge Rate": "Né Tránh",
	"Accuracy": "Chuẩn Xác",
	"Walk Speed": "Di Tốc",
	"Weight": "Tải Trọng",
	"Money": "Linh Thạch",
	"GP": "Linh Thạch",
	"Experience": "Tu Vi",
	"Level": "Cảnh Giới",
	"Available points": "Điểm Tiềm Năng",

	# Window Titles & Tabs
	"Stats": "Tu Chân Thuộc Tính",
	"Skills": "Công Pháp & Bí Thuật",
	"Progress": "Sổ Tay Nhiệm Vụ & Đồ Giám",
	"Social": "Đạo Hữu Đồng Tu",
	"Emotes": "Biểu Cảm & Động Tác",
	"Settings": "Cài Đặt Hệ Thống",
	"Minimap": "Bản Đồ Sơn Hà",
	"Chat": "Đạo Âm Trò Chuyện",
	"Trade": "Giao Thương Tu Tiên",
	"QuestLog": "Ủy Thác Tông Môn",
	"Manapedia": "Yêu Thú Đồ Giám",
	"Spells": "Linh Kỹ & Pháp Thuật",
	"Physical": "Kiếm Quyết & Thể Thuật",
	"Abilities": "Tâm Pháp & Thần Thông",

	# Common UI Actions
	"Save": "Xác Nhận",
	"Reset": "Hoàn Nguyên",
	"Equip": "Trang Bị",
	"Unequip": "Tháo Xuống",
	"Use": "Sử Dụng",
	"Drop": "Bỏ Lại",
	"Cancel": "Hủy Bỏ",
	"Confirm": "Xác Nhận",
	"Done": "Hoàn Tất",
	"Lock": "Khóa Giao Dịch",
	"Capacity": "Dung Tích Túi",
	"Slots": "Ngăn Chứa",
	"Modifiers": "Gia Trì Thuộc Tính",
	"Close": "Đóng",
	"Back": "Trở Lại",
	"Next": "Tiếp Theo",
	"Previous": "Trước Đó",

	# Character Creation & Login
	"Enter Character Name": "Nhập Đạo Hiệu Nhân Vật",
	"Attributes": "Tư Chất Bẩm Sinh",
	"Traits": "Tướng Mạo & Căn Cốt",
	"Hairstyle": "Kiểu Tóc",
	"Hair Color": "Màu Tóc",
	"Gender": "Giới Tính",
	"Race": "Thân Phận",
	"Skin Tone": "Sắc Diện",
	"Location": "Nơi Sinh Trưởng",
	"Name": "Tên Đạo Hào",
	"Password": "Mật Khẩu",
	"Confirm Password": "Xác Nhận Mật Khẩu",
	"Remember me": "Ghi Nhớ Đạo Hào",
	"Reset Code": "Mã Khôi Phục",
	"Connecting...": "Đang Kết Nối...",

	# Breakthrough & Feedback Messages
	"Breakthrough Failed": "Đột Phá Thất Bại.",
	"Insufficient Cultivation": "Tu Vi Chưa Đủ, Chưa Thể Phá Cảnh.",
	"Breakthrough Successful": "Chúc Mừng Đạo Hữu, Cảnh Giới Đã Được Đột Phá!",

	# Side quests (English name hash → Vietnamese display title)
	"Desert Seed": "Hạt Giống Mana",
	"Elanore's Potions": "Đan Dược Elanore",
	"Grain in the desert": "Lúa Mì Sa Mạc",
	"Mine Exploration": "Thám Sát Khoáng Trường",
	"Nina's Snack": "Bánh cho Nina",
	"A Drop of Relief": "Giọt Nước Giải Khát",
	"A Miner's Helping Hand": "Giúp Tay Khai Khoáng",
	"Sandstorm Mine Abandoned Treasure": "Bảo Vật Mỏ Hoang",
	"Peter's Bounty": "Ủy Thác Peter",
	"A Biting Thirst": "Khát Đến Cháy Ruột",
	"Snake Pit Thief": "Đạo Tặc Hố Rắn",
	"Splatyna's Offering": "Cống Phẩm Splatyna",
	"Found a Chest in the Outskirts": "Rương Ngoại Thành",
	"When the desert gives you sand...": "Sa mạc cho cát...",
	"An Old Friendship": "Cũ Duyên Tri Kỷ",
	"Tutorial": "Nhập Môn",
	"Veteran Cave Explorer": "Tiền Bối Thám Hang"
}

## 2. GIẢI THÍCH THUỘC TÍNH (ATTRIBUTE & STAT TOOLTIPS)
const TOOLTIPS : Dictionary = {
	"Strength": "Lực Lượng: Tăng cường sức mạnh gân cốt, tăng sát thương Công Kích vật lý và uy lực đòn đánh.",
	"Vitality": "Thể Chất: Bồi bổ sinh cơ bản nguyên, tăng lượng Khí Huyết (HP) tối đa và sức chịu đựng nhục thân.",
	"Agility": "Thân Pháp: Gia tăng độ linh hoạt, tốc độ di chuyển, phản xạ Né Tránh và độ Chuẩn Xác khi xuất chiêu.",
	"Endurance": "Định Lực: Cố thủ tâm thần và thể phách, tăng Thể Lực (Stamina), khả năng kháng hiệu ứng và Phòng Ngự.",
	"Concentration": "Thần Thức: Khai mở thức hải tâm thần, tăng Linh Lực (MP) tối đa, uy lực Pháp Công và cự ly thi triển.",
	"Attack": "Công Kích: Sức sát thương vật lý trực tiếp lên đối thủ.",
	"Defense": "Phòng Ngự: Khả năng ngăn chặn và giảm thiểu sát thương vật lý nhận vào.",
	"M. Attack": "Pháp Công: Uy lực sát chiêu linh kỹ, pháp thuật và phù chú.",
	"M. Defense": "Pháp Phòng: Khả năng chống chịu trước các luồng linh lực và pháp thuật của địch.",
	"Attack Range": "Cự Ly: Tầm với hoặc khoảng cách thi triển chiêu thức.",
	"Cast Delay": "Niệm Chú: Thời gian dẫn khí tụ lực để hoàn tất một pháp thuật.",
	"Cooldown Delay": "Hồi Chiêu: Thời gian tĩnh dưỡng kinh mạch trước khi có thể tái thi triển chiêu thức.",
	"Crit Rate": "Bạo Kích: Tỷ lệ kích phát đòn đánh trí mạng với uy lực tăng gấp bội.",
	"Dodge Rate": "Né Tránh: Tỷ lệ hóa giải đòn đánh của đối phương bằng bộ pháp.",
	"Accuracy": "Chuẩn Xác: Tỷ lệ chiêu thức đánh trúng yếu điểm mục tiêu.",
	"Walk Speed": "Di Tốc: Tốc độ hành tẩu và phi hành của nhân vật.",
	"Experience": "Tu Vi: Điểm tích lũy tu hành từ đả tọa, chiến đấu và lịch luyện, dùng để phá quan đột phá.",
	"Health": "Khí Huyết: Sinh mạng căn bản, tổn hao khi trúng đòn, cạn kiệt sẽ dẫn đến đạo tiêu thân vong.",
	"Mana": "Linh Lực: Chân nguyên tích tụ tại đan điền, tiêu hao khi thi triển linh thuật và kiếm quyết.",
	"Stamina": "Thể Lực: Sức bền của cơ thể, dùng cho chạy nhanh và thi triển thân pháp né tránh.",
	"Weight": "Tải Trọng: Trọng lượng đồ vật trong túi trữ vật so với giới hạn mang vác của bản thân.",
	"Money": "Linh Thạch: Tiền tệ giao thương thông dụng trong giới tu chân, dùng mua đan dược và pháp bảo."
}

## 3. THÔNG ĐIỆP VẬN CÔNG TU LUYỆN (CULTIVATION FEEDBACK MESSAGES)
const CULTIVATION_FEEDBACK : Array[String] = [
	"Linh khí hội tụ quanh thân.",
	"Chân khí vận chuyển qua kinh mạch.",
	"Đan điền dần được bồi đắp.",
	"Tu vi có dấu hiệu viên mãn.",
	"Bình cảnh đã xuất hiện.",
	"Cơ duyên đã đến, có thể thử đột phá."
]

## Initialization flag & translation instance
static var _is_initialized : bool = false
static var _translation_instance : Translation = null

## Initialize Godot's TranslationServer with the Xianxia glossary
static func Init():
	if _is_initialized:
		return
		
	_translation_instance = Translation.new()
	_translation_instance.locale = LOCALE_VI
	
	for key in GLOSSARY:
		_translation_instance.add_message(key, GLOSSARY[key])
		
	TranslationServer.add_translation(_translation_instance)
	TranslationServer.set_locale(LOCALE_VI)
	_is_initialized = true
	print("[Localization] Xianxia Vietnamese Localization initialized successfully (%d terms loaded)." % GLOSSARY.size())

## Get localized string with automatic fallback
static func Get(key: String, fallback: String = "") -> String:
	Init()
	if GLOSSARY.has(key):
		return GLOSSARY[key]
	var tr_val = TranslationServer.translate(key)
	if not tr_val.is_empty() and tr_val != key:
		return tr_val
	return fallback if not fallback.is_empty() else key

## Alias for Get
static func GetTerm(term: String) -> String:
	return Get(term)

## Get tooltip text for attributes or stats
static func GetTooltip(stat_key: String) -> String:
	if TOOLTIPS.has(stat_key):
		return TOOLTIPS[stat_key]
	var localizedKey = Get(stat_key)
	if TOOLTIPS.has(localizedKey):
		return TOOLTIPS[localizedKey]
	return localizedKey

## Get formatted string using translation key
static func Format(key: String, args: Array) -> String:
	var template : String = Get(key)
	return template % args

## Get cultivation feedback by index
static func GetFeedback(index: int) -> String:
	var idx = index % CULTIVATION_FEEDBACK.size()
	return CULTIVATION_FEEDBACK[idx]
