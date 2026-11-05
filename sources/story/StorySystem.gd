extends RefCounted
class_name StorySystem

## TDNM — BUILD 08: HEAVENLY FATE, MAIN STORY & LIVING WORLD ENGINE
## Autonomous Engine for Story Chapters, NPC Affinity, Choices, Living World Events & Clues.
## Strictly follows Owner Decisions D-01 (Transmigration), D-02 (Damaged Dao), D-03 (Pending Hub), D-04 (Realms).

const Localization = preload("res://sources/system/Localization.gd")
const ProgressCommonsClass = preload("res://sources/actor/ProgressCommons.gd")

# ==============================================================================
# 1. ENUMS & CONSTANTS
# ==============================================================================

# 5 Main Story Chapters
enum StoryChapter {
	CHAPTER_1_STRANGER = 1,      # Người Lạ Tại Dị Giới
	CHAPTER_2_PATH = 2,          # Con Đường Tu Đạo
	CHAPTER_3_MUTATION = 3,      # Dấu Vết Dị Biến
	CHAPTER_4_ANCIENT_SECRETS = 4, # Bí Mật Trong Cổ Tích
	CHAPTER_5_DAMAGED_DAO = 5     # Thiên Đạo Có Khuyết
}

# NPC Relationship Tiers (5 Tiers)
enum RelationshipRank {
	STRANGER = 0,    # Xa Lạ (0 - 99)
	ACQUAINTANCE = 1,# Quen Biết (100 - 299)
	FRIENDLY = 2,    # Thiện Cảm (300 - 599)
	TRUSTED = 3,     # Tin Tưởng (600 - 999)
	CONFIDANT = 4    # Tri Kỷ (1000+)
}

# 5 Dynamic World Events
enum WorldEventType {
	BEAST_TIDE = 1,       # Yêu Thú Triều Tịch Tập Kích
	QI_ANOMALY = 2,       # Linh Khí Triều Tịch Dị Thường
	SECRET_REALM = 3,     # Huyền Không Bí Cảnh Lâm Thế
	MERCHANT_CARAVAN = 4, # Du Phương Thương Đội Quá Cảnh
	ARRAY_INSTABILITY = 5 # Cổ Trận Linh Mạch Ba Động
}

# ==============================================================================
# 2. 8 NPC PROFILES & DOSSIERS
# ==============================================================================
const NPC_DOSSIERS : Dictionary = {
	"DAO_HUYEN": {
		"id": "DAO_HUYEN",
		"name": "Đạo Huyền Trưởng Lão",
		"title": "Thủ Tịch Trưởng Lão Chưởng Quản Sơn Môn",
		"location": "Thánh Điện Trúc Sơn (350, 200)",
		"personality": "Trầm ổn, nghiêm cẩn, cẩn trọng, gánh vác đại cục tông môn.",
		"bio": "Tu vi Đạo Cơ hậu kỳ, một đời tận tụy vì sơn môn. Mặc dù bảo thủ trước những ghi chép cổ dị giáo, ông luôn coi trọng sự an nguy của đệ tử.",
		"defaultAffinity": 50,
		"favoredItems": ["Hoi Xuan Dan", "Truc Co Dan", "Bach Ngan Kiem"],
		"discountMax": 0.0
	},
	"LIEU_THANH_Y": {
		"id": "LIEU_THANH_Y",
		"name": "Liễu Thanh Y",
		"title": "Y Sư Dược Đường",
		"location": "Dược Đường (150, 180)",
		"personality": "Nhân hậu, dịu dàng, tinh tế, tận tâm cứu chữa thương bệnh.",
		"bio": "Xuất thân y đạo thế gia, say mê nghiên cứu dược lý thảo mộc. Nàng đặc biệt nhạy cảm với những biến dị kỳ lạ trong dược tính linh thảo gần đây.",
		"defaultAffinity": 100,
		"favoredItems": ["Ngan Linh Thao", "Huyet Sam", "U Hon Thao"],
		"discountMax": 0.15
	},
	"HA_THIET_THU": {
		"id": "HA_THIET_THU",
		"name": "Hà Thiết Thủ",
		"title": "Luyện Khí Chấp Sự",
		"location": "Luyện Khí Đường (480, 220)",
		"personality": "Bộc trực, hào sảng, trọng thực tài, ghét thói giả tạo.",
		"bio": "Tay nghề rèn đúc đứng đầu ngoại môn, cả đời bầu bạn với búa và đe sắt. Khao khát lớn nhất là rèn ra một thanh cực phẩm phi kiếm lưu danh thế gian.",
		"defaultAffinity": 80,
		"favoredItems": ["Huyen Thiet Khoang", "Bach Ngan Khoang", "Xich Viem Khoang"],
		"discountMax": 0.15
	},
	"DIEP_TU_LANG": {
		"id": "DIEP_TU_LANG",
		"name": "Diệp Tử Lăng",
		"title": "Tán Tu Liệp Thú Sư",
		"location": "Sơn Lâm Ngoại Vi (120, 420)",
		"personality": "Đa nghi, cô độc, thực dụng, tôn trọng kẻ có năng lực thực chiến.",
		"bio": "Một tán tu dạn dày phong sương sống sót nơi rừng sâu hiểm ác. Hắn nắm rõ tập tính của từng loài yêu thú và là người đầu tiên phát hiện sự điên loạn bất thường của đàn dã thú.",
		"defaultAffinity": 30,
		"favoredItems": ["Xich Viem Dan", "Yeu Thu Huyet Tinh", "Xich Viem Yeu Dan"],
		"discountMax": 0.10
	},
	"MAC_LAO_NHAN": {
		"id": "MAC_LAO_NHAN",
		"name": "Mặc Lão Nhân",
		"title": "Cổ Trận Kỳ Nhân",
		"location": "Trúc Sơn Cổ Bi (600, 120)",
		"personality": "Lập dị, uyên thấu, bất chấp thế tục, khao khát vén màn bí mật lịch sử.",
		"bio": "Từng là trưởng lão trận pháp một đại môn phái cổ xưa, sau khi phát hiện sự sai lệch trong thiên địa quy tắc liền thoái ẩn đi tìm di tích thất truyền.",
		"defaultAffinity": 40,
		"favoredItems": ["Co Bi Bi Kip", "Linh Thach Thuong Pham", "Huyen Quy Kinh"],
		"discountMax": 0.0
	},
	"TRAN_PHUONG": {
		"id": "TRAN_PHUONG",
		"name": "Trần Phương",
		"title": "Đồng Môn Ngoại Đệ Tử",
		"location": "Diễn Võ Trường (280, 320)",
		"personality": "Nhiệt huyết, trượng nghĩa, có phần nóng nảy nhưng trọng tình nghĩa.",
		"bio": "Cùng nhập môn với nguyên chủ, mang tư chất tam linh căn bình thường. Luôn cố gắng khổ luyện để chứng minh bản thân không thua kém con nhà vọng tộc.",
		"defaultAffinity": 120,
		"favoredItems": ["Thanh Phong Kiem", "Bo Khi Dan", "Tap Dich Lenh Bai"],
		"discountMax": 0.0
	},
	"BACH_HAC": {
		"id": "BACH_HAC",
		"name": "Bạch Hạc Chân Nhân",
		"title": "Tàng Kinh Các Lão",
		"location": "Tàng Kinh Các (520, 150)",
		"personality": "Tiêu sái, điềm đạm, yêu thích đàm đạo huyền lý và cổ tịch.",
		"bio": "Trông coi hàng vạn điển tịch võ học của sơn môn. Người duy nhất trong tông môn không coi thường Ngũ Hành Tạp Căn, cho rằng Đạo tại tâm ngộ.",
		"defaultAffinity": 60,
		"favoredItems": ["Thanh Phong Bi Kip", "Ngung Than Dan", "Can Khon Tu Linh Dinh"],
		"discountMax": 0.0
	},
	"KHANG_VAN_KIM": {
		"id": "KHANG_VAN_KIM",
		"name": "Khang Vạn Kim",
		"title": "Du Phương Thương Nhân",
		"location": "Tiếp Dẫn Đài (200, 380)",
		"personality": "Tinh ranh, khôn khéo, sành sỏi giao thương, tuyệt đối giữ chữ tín.",
		"bio": "Lái buôn qua lại giữa các đại châu lục tiên vực. Nơi nào có cơ hội kiếm lời và săn tìm bảo vật lạ, nơi đó có dấu chân của Khang Vạn Kim.",
		"defaultAffinity": 50,
		"favoredItems": ["Linh Thach Thuong Pham", "Kim Cang Dan", "Bao Nguyen Dan"],
		"discountMax": 0.15
	}
}

# ==============================================================================
# 3. 5 CHAPTERS OF MAIN STORY
# ==============================================================================
const MAIN_STORY_CHAPTERS : Dictionary = {
	StoryChapter.CHAPTER_1_STRANGER: {
		"id": StoryChapter.CHAPTER_1_STRANGER,
		"title": "Chương 1: Người Lạ Tại Dị Giới",
		"questId": "MQ_CHUONG_1_TINH_LAC_DI_GIOI",
		"reqLevel": 1,
		"synopsis": "Tỉnh lại nơi thế giới tu tiên xa lạ, nhận ra bản thân xuyên không vào thân xác một đệ tử kiệt sức mang Ngũ Hành Tạp Căn. Bằng tư duy quan sát và phân tích hiện đại, nhân vật chính phát hiện những hiện tượng linh khí bất thường đầu tiên.",
		"clueUnlocked": "CLUE_1_QI_FLUCTUATION"
	},
	StoryChapter.CHAPTER_2_PATH: {
		"id": StoryChapter.CHAPTER_2_PATH,
		"title": "Chương 2: Con Đường Tu Đạo",
		"questId": "MQ_CHUONG_2_CON_DUONG_TU_DAO",
		"reqLevel": 2,
		"synopsis": "Khám phá quy luật tu luyện, làm quen các chấp sự và sư đồ trong sơn môn. Vận dụng kiến thức khoa học phân tích cơ chế hấp thụ linh khí và tìm thấy manh mối đầu tiên từ bia đá cổ.",
		"clueUnlocked": "CLUE_2_MUTATED_CORES"
	},
	StoryChapter.CHAPTER_3_MUTATION: {
		"id": StoryChapter.CHAPTER_3_MUTATION,
		"title": "Chương 3: Dấu Vết Dị Biến",
		"questId": "MQ_CHUONG_3_DAU_VET_DI_BIEN",
		"reqLevel": 5,
		"synopsis": "Yêu thú vùng ngoại vi bỗng nhiên cuồng bạo dị biến. Nhân vật chính cùng đồng môn điều tra và phải đối diện với lựa chọn đạo đức có ảnh hưởng trực tiếp đến tính mạng đệ tử và việc bảo toàn bí mật.",
		"clueUnlocked": "CLUE_3_ANCIENT_CONFLICT"
	},
	StoryChapter.CHAPTER_4_ANCIENT_SECRETS: {
		"id": StoryChapter.CHAPTER_4_ANCIENT_SECRETS,
		"title": "Chương 4: Bí Mật Trong Cổ Tích",
		"questId": "MQ_CHUONG_4_BI_MAT_CO_TICH",
		"reqLevel": 8,
		"synopsis": "Thâm nhập cổ động di tích bị lãng quên. Khám phá những tài liệu mâu thuẫn hoàn toàn với lịch sử chính thống, nhận ra các trận pháp phong ấn đang trượt dần khỏi quỹ đạo ban đầu.",
		"clueUnlocked": "CLUE_4_ARRAY_DRIFT"
	},
	StoryChapter.CHAPTER_5_DAMAGED_DAO: {
		"id": StoryChapter.CHAPTER_5_DAMAGED_DAO,
		"title": "Chương 5: Thiên Đạo Có Khuyết",
		"questId": "MQ_CHUONG_5_THIEN_DAO_CO_KHUYET",
		"reqLevel": 10,
		"synopsis": "Đối mặt với sự cố chấn động linh mạch cổ trận. Sự thật về 'Thiên Đạo Tổn Thương' hé lộ: Thiên Đạo không phải ác nhân, mà là quy tắc vũ trụ từng chịu vết rạn nứt khổng lồ. Mở ra bước ngoặt nghịch mệnh tu chân.",
		"clueUnlocked": "CLUE_5_DAMAGED_DAO"
	}
}

# ==============================================================================
# 4. 5 CLUES OF HEAVENLY DAO DAMAGE (D-02 CANON)
# ==============================================================================
const STORY_CLUES : Dictionary = {
	"CLUE_1_QI_FLUCTUATION": {
		"id": "CLUE_1_QI_FLUCTUATION",
		"title": "Manh Mối 1: Linh Khí Triều Tịch Đảo Nghịch",
		"chapter": 1,
		"content": "Linh khí quanh chân núi Trúc Sơn không tuần hoàn điều hòa theo ngũ hành mà xuất hiện các đợt sóng xung kích ngắt quãng như nhịp thở của một sinh thể bị thương.",
		"deduction": "Theo nguyên lý bảo toàn năng lượng hiện đại, có một điểm rò rỉ hoặc khe nứt vô hình đang phát tán tạp khí vào môi trường tự nhiên."
	},
	"CLUE_2_MUTATED_CORES": {
		"id": "CLUE_2_MUTATED_CORES",
		"title": "Manh Mối 2: Yêu Đan Dị Chủng",
		"chapter": 2,
		"content": "Các mẫu yêu đan thu được từ Yêu Thú Ngoại Vi chứa các vân hoa hỗn loạn, tính chất hỏa - mộc xung đột nhưng không phát nổ mà đông kết kỳ dị.",
		"deduction": "Quy luật tương sinh tương khắc ngũ hành đã bị một ngoại lực làm sai lệch hằng số cơ bản."
	},
	"CLUE_3_ANCIENT_CONFLICT": {
		"id": "CLUE_3_ANCIENT_CONFLICT",
		"title": "Manh Mối 3: Minh Văn Cổ Bi Mâu Thuẫn",
		"chapter": 3,
		"content": "Minh văn tại Trúc Sơn Cổ Bi ghi rõ niên đại 'Đại Kiếp Liệt Thiên' vạn năm trước, trái ngược hoàn toàn với ghi chép của tông môn rằng trời đất vốn thái bình.",
		"deduction": "Lịch sử tu chân hiện tại đã bị các thế lực thượng cổ cố tình chỉnh sửa để che giấu sự sụp đổ của một phần thiên tắc."
	},
	"CLUE_4_ARRAY_DRIFT": {
		"id": "CLUE_4_ARRAY_DRIFT",
		"title": "Manh Mối 4: Thiên Địa Trận Văn Sai Lệch",
		"chapter": 4,
		"content": "Các trụ đá trận pháp thời cổ đại không còn căn chỉnh đúng với các chòm sao trên bầu trời. Chu kỳ vận hành trận pháp bị lệch 7.3 độ.",
		"deduction": "Không phải trận pháp bị sai, mà bản thân cấu trúc không gian và quỹ đạo vận hành của giới vực này đã bị dịch chuyển sau biến cố cổ đại."
	},
	"CLUE_5_DAMAGED_DAO": {
		"id": "CLUE_5_DAMAGED_DAO",
		"title": "Manh Mối 5: Thiên Đạo Vốn Có Khuyết",
		"chapter": 5,
		"content": "Thiên Đạo không phải ý chí tà ác trừng phạt sinh linh, mà là một hệ thống quy tắc tối cao đang bị rạn nứt, không thể tự hồi phục hoàn toàn.",
		"deduction": "Con đường 'Nghịch Mệnh' không phải chống lại một vị thần linh, mà là dùng trí tuệ và thực lực để vá lại quy tắc, nghịch chuyển vận mệnh sụp đổ của thế giới."
	}
}

# ==============================================================================
# 5. 5 MAJOR CHOICES & CONSEQUENCES CATALOG
# ==============================================================================
const STORY_CHOICES : Dictionary = {
	"CHOICE_1_RESCUE_OR_INVESTIGATE": {
		"id": "CHOICE_1_RESCUE_OR_INVESTIGATE",
		"chapter": 1,
		"prompt": "Khi Trần Phương bị bầy linh trùng vây khốn tại bờ suối, đạo hữu sẽ lựa chọn thế nào?",
		"options": [
			{
				"id": "RESCUE",
				"text": "Lập tức xuất thủ cứu viện Trần Phương, chấp nhận bỏ lỡ dấu vết dị tượng linh khí.",
				"consequence": "Trần Phương hàm ơn sâu sắc (+150 Hảo Cảm), mở khóa danh hiệu [Trượng Nghĩa Đệ Tử].",
				"affinityReward": { "TRAN_PHUONG": 150 },
				"itemReward": "Hoi Xuan Dan",
				"itemCount": 2
			},
			{
				"id": "INVESTIGATE",
				"text": "Đứng từ xa quan sát đo lường dị biến linh khí để thu thập chứng cứ, sau đó mới trợ giúp.",
				"consequence": "Thu thập được [Manh Mối 1: Linh Khí Triều Tịch], tăng +20 Ngộ Tính nhưng Trần Phương có chút e dè.",
				"affinityReward": { "TRAN_PHUONG": 30 },
				"clueId": "CLUE_1_QI_FLUCTUATION",
				"statReward": "comprehension",
				"statValue": 20
			}
		]
	},
	"CHOICE_2_SUBMIT_OR_ANALYZE_STELE": {
		"id": "CHOICE_2_SUBMIT_OR_ANALYZE_STELE",
		"chapter": 2,
		"prompt": "Sau khi thu được Cổ Bi Tàn Quyển từ bia đá, đạo hữu xử lý tàn chương ra sao?",
		"options": [
			{
				"id": "SUBMIT_SECT",
				"text": "Giao nộp toàn bộ tàn quyển cho Đạo Huyền Trưởng Lão để bảo toàn tôn chỉ môn quy.",
				"consequence": "Nhận được +200 Hảo Cảm Đạo Huyền, +100 Cống Hiến Môn Phái và ban thưởng linh thạch.",
				"affinityReward": { "DAO_HUYEN": 200 },
				"contribution": 100,
				"gp": 300
			},
			{
				"id": "ANALYZE_MODERN",
				"text": "Giữ lại tự mình dùng tư duy giải mã hiện đại phân tích quy luật trước khi nộp bản sao.",
				"consequence": "Giải mã thành công [Manh Mối 2: Yêu Đan Dị Chủng], ngộ ra bí quyết rèn khí cổ truyền (+150 EXP Luyện Khí Sư).",
				"affinityReward": { "HA_THIET_THU": 100 },
				"clueId": "CLUE_2_MUTATED_CORES",
				"professionExp": 150
			}
		]
	},
	"CHOICE_3_TRUST_HERMIT_OR_SECT": {
		"id": "CHOICE_3_TRUST_HERMIT_OR_SECT",
		"chapter": 3,
		"prompt": "Mặc Lão Nhân cảnh báo khu rừng cấm đang sụp đổ quy tắc, trong khi Tông Môn ra lệnh phong tỏa nghiêm ngặt.",
		"options": [
			{
				"id": "TRUST_HERMIT",
				"text": "Tin tưởng nhận định của Mặc Lão Nhân, bí mật tiến vào Hiên Viên Cổ Động tìm chân tướng.",
				"consequence": "Mặc Lão Nhân coi như tri âm (+200 Hảo Cảm), mở khóa lối vào bí mật và cổ vật phòng hộ.",
				"affinityReward": { "MAC_LAO_NHAN": 200 },
				"itemReward": "Huyen Quy Kinh",
				"itemCount": 1
			},
			{
				"id": "OBEY_SECT",
				"text": "Tuân thủ nghiêm lệnh cấm của Tông Môn, phối hợp cùng chấp sự lập hàng rào cảnh giới.",
				"consequence": "Đạo Huyền và Chấp Sự khen ngợi tính kỷ luật (+150 Hảo Cảm Đạo Huyền), nhận hộ thân linh phù.",
				"affinityReward": { "DAO_HUYEN": 150 },
				"contribution": 150,
				"itemReward": "Kim Cang Dan",
				"itemCount": 3
			}
		]
	},
	"CHOICE_4_PURIFY_OR_STUDY_CORE": {
		"id": "CHOICE_4_PURIFY_OR_STUDY_CORE",
		"chapter": 4,
		"prompt": "Đoạt được Dị Biến Yêu Đan từ Thú Vương biến dị, đạo hữu định liệu thế nào?",
		"options": [
			{
				"id": "PURIFY",
				"text": "Hợp tác cùng Liễu Thanh Y dùng dược hỏa thanh tẩy tà khí, điều chế đan dược an toàn.",
				"consequence": "Liễu Thanh Y hết lòng cảm phục (+200 Hảo Cảm), điều chế thành công 3 viên [Thanh Tâm Đan] thượng phẩm.",
				"affinityReward": { "LIEU_THANH_Y": 200 },
				"itemReward": "Thanh Tam Dan",
				"itemCount": 3
			},
			{
				"id": "STUDY_MUTATION",
				"text": "Cùng Hà Thiết Thủ phân tích cấu trúc gãy nứt của yêu đan để rèn vũ khí cuồng bạo.",
				"consequence": "Hà Thiết Thủ phấn khích (+200 Hảo Cảm), rèn đúc thành công [Xích Viêm Kiếm] gia tăng sát thương hỏa hệ.",
				"affinityReward": { "HA_THIET_THU": 200 },
				"itemReward": "Xich Viem Kiem",
				"itemCount": 1
			}
		]
	},
	"CHOICE_5_ARRAY_DECISION": {
		"id": "CHOICE_5_ARRAY_DECISION",
		"chapter": 5,
		"prompt": "Khi Cổ Trận Linh Mạch đạt giới hạn quá tải đe dọa nổ tung toàn bộ chân núi, đạo hữu quyết định:",
		"options": [
			{
				"id": "SEAL_BURDEN",
				"text": "Dùng Càn Khôn Tụ Linh Đỉnh gánh chịu áp lực, cưỡng ép phong tỏa vết rách để bảo vệ sinh linh.",
				"consequence": "Cứu vãn cả ngàn đệ tử sơn môn, Đạo Huyền tôn sùng (+300 Hảo Cảm), phong danh hiệu [Sơn Môn Hộ Pháp].",
				"affinityReward": { "DAO_HUYEN": 300, "TRAN_PHUONG": 200 },
				"contribution": 500,
				"gp": 1000
			},
			{
				"id": "VENT_AND_ADAPT",
				"text": "Chủ động phân tán dòng linh khí hỗn loạn vào hư không, chấp nhận quy tắc thế giới có khuyết.",
				"consequence": "Liễu ngộ đại đạo chân lý, lĩnh ngộ [CLUE_5_DAMAGED_DAO], ngộ tính vĩnh viễn thăng hoa (+50 Ngộ Tính).",
				"affinityReward": { "MAC_LAO_NHAN": 300, "BACH_HAC": 200 },
				"clueId": "CLUE_5_DAMAGED_DAO",
				"statReward": "comprehension",
				"statValue": 50
			}
		]
	}
}

# ==============================================================================
# 6. 5 LIVING WORLD DYNAMIC EVENTS CATALOG
# ==============================================================================
const WORLD_EVENTS_CATALOG : Dictionary = {
	"YEU_THU_TRIEU": {
		"id": "YEU_THU_TRIEU",
		"name": "Yêu Thú Triều Tịch Tập Kích",
		"type": WorldEventType.BEAST_TIDE,
		"description": "Bầy yêu thú rừng ngoại vi bị luồng hỗn loạn linh khí kích động, đang tràn về hướng sơn môn!",
		"location": "Sơn Lâm Ngoại Vi",
		"durationSeconds": 1800, # 30 minutes
		"targetKillCount": 10,
		"rewardExp": 300,
		"rewardGp": 500,
		"rewardContrib": 80
	},
	"LINH_KHI_DI_TUONG": {
		"id": "LINH_KHI_DI_TUONG",
		"name": "Linh Khí Triều Tịch Dị Thường",
		"type": WorldEventType.QI_ANOMALY,
		"description": "Vùng trời phía đông xuất hiện vầng sáng ngũ sắc, nồng độ linh khí tăng vọt gấp 3 lần bình thường.",
		"location": "Trúc Sơn Ngoại Vi",
		"durationSeconds": 1200, # 20 minutes
		"cultivationBonus": 1.0, # +100% cultivation exp
		"rewardExp": 200,
		"rewardGp": 200
	},
	"BI_CANH_XUAT_THE": {
		"id": "BI_CANH_XUAT_THE",
		"name": "Huyền Không Bí Cảnh Lâm Thế",
		"type": WorldEventType.SECRET_REALM,
		"description": "Khe nứt không gian hé mở lối vào một mảnh vỡ bí cảnh thượng cổ đầy ắp bảo vật và nguy hiểm.",
		"location": "Hiên Viên Cổ Động",
		"durationSeconds": 2400, # 40 minutes
		"rewardItem": "Linh Thach Thuong Pham",
		"rewardCount": 2,
		"rewardExp": 400
	},
	"DU_PHUONG_THUONG_DOI": {
		"id": "DU_PHUONG_THUONG_DOI",
		"name": "Du Phương Thương Đội Quá Cảnh",
		"type": WorldEventType.MERCHANT_CARAVAN,
		"description": "Khang Vạn Kim dẫn đoàn lạc đà buôn mang theo nhiều dị bảo quý hiếm dừng chân tại Tiếp Dẫn Đài.",
		"location": "Tiếp Dẫn Đài",
		"durationSeconds": 1800,
		"specialStock": ["Xich Viem Khoang", "Bach Ngan Khoang", "Yeu Thu Huyet Tinh"],
		"discountRate": 0.20
	},
	"CO_TRAN_BAT_ON": {
		"id": "CO_TRAN_BAT_ON",
		"name": "Cổ Trận Linh Mạch Ba Động",
		"type": WorldEventType.ARRAY_INSTABILITY,
		"description": "Cổ trận ngầm dưới lòng đất rung chuyển dữ dội, cần đệ tử mang phù thạch đến trấn áp linh nhãn.",
		"location": "Đại Điện Trúc Sơn",
		"durationSeconds": 1500,
		"rewardContrib": 150,
		"rewardExp": 350,
		"rewardGp": 400
	}
}

# ==============================================================================
# 7. 8 EXPLORATION SECRETS & HIDDEN DISCOVERIES CATALOG
# ==============================================================================
const EXPLORATION_SECRETS : Dictionary = {
	"SECRET_1_TRUC_SON_CO_BI": {
		"id": "SECRET_1_TRUC_SON_CO_BI",
		"name": "Trúc Sơn Cổ Bi",
		"coords": Vector2(600, 120),
		"type": "stele",
		"description": "Bia đá cổ bám đầy rêu xanh khắc ghi thiên địa tàn chương.",
		"reqComprehension": 30,
		"rewardExp": 50,
		"rewardItem": "Truc Son Co Bi Tan Quyen"
	},
	"SECRET_2_HIEN_VIEN_CO_DONG": {
		"id": "SECRET_2_HIEN_VIEN_CO_DONG",
		"name": "Hiên Viên Cổ Động",
		"coords": Vector2(180, 520),
		"type": "cave",
		"description": "Hang động ẩn giấu phía sau màn thác nước cuồn cuộn.",
		"reqLevel": 3,
		"rewardExp": 80,
		"rewardItem": "Bach Ngan Khoang"
	},
	"SECRET_3_U_HON_TRAM_BAO": {
		"id": "SECRET_3_U_HON_TRAM_BAO",
		"name": "U Hồn Trầm Bảo",
		"coords": Vector2(80, 300),
		"type": "chest",
		"description": "Rương bách bảo bị vùi dưới lớp bùn lầy chướng khí u uất.",
		"reqItem": "Thanh Tam Dan",
		"rewardExp": 60,
		"rewardItem": "U Hon Thao"
	},
	"SECRET_4_NGU_HANH_THACH_TRAN": {
		"id": "SECRET_4_NGU_HANH_THACH_TRAN",
		"name": "Ngũ Hành Thạch Trận",
		"coords": Vector2(450, 480),
		"type": "puzzle",
		"description": "5 trụ đá khắc phù văn ngũ hành tương sinh tương khắc.",
		"reqComprehension": 40,
		"rewardExp": 120,
		"rewardItem": "Kim Cang Dan"
	},
	"SECRET_5_BIET_VIEN_DUOC_DIEN": {
		"id": "SECRET_5_BIET_VIEN_DUOC_DIEN",
		"name": "Biệt Viện Dược Điền",
		"coords": Vector2(120, 150),
		"type": "herb_garden",
		"description": "Vườn thảo dược cổ xưa của tiền bối ẩn cư còn sót lại.",
		"reqLevel": 2,
		"rewardExp": 70,
		"rewardItem": "Huyet Sam"
	},
	"SECRET_6_LIEN_HOA_CO_THIET": {
		"id": "SECRET_6_LIEN_HOA_CO_THIET",
		"name": "Liên Hoa Cổ Thiết",
		"coords": Vector2(700, 250),
		"type": "mineral_vein",
		"description": "Mỏ khoáng thạch mang hình hoa sen ngưng kết trên vách núi.",
		"reqLevel": 4,
		"rewardExp": 90,
		"rewardItem": "Thanh Phong Tinh Thiet"
	},
	"SECRET_7_PHONG_AN_DIA_HA": {
		"id": "SECRET_7_PHONG_AN_DIA_HA",
		"name": "Phong Ấn Địa Hạ",
		"coords": Vector2(350, 580),
		"type": "dungeon_gate",
		"description": "Cửa hầm ngầm cổ xưa khóa chặt bằng cửu cung xích sắt.",
		"reqLevel": 6,
		"rewardExp": 150,
		"rewardItem": "Huyen Thiet Giap"
	},
	"SECRET_8_TIEN_NHAN_DI_THU": {
		"id": "SECRET_8_TIEN_NHAN_DI_THU",
		"name": "Tiền Nhân Di Thư",
		"coords": Vector2(550, 380),
		"type": "lore_scroll",
		"description": "Ghi chép của một vị học giả hiện đại từng xuyên không ngàn năm trước.",
		"reqComprehension": 50,
		"rewardExp": 200,
		"rewardItem": "Linh Thach Thuong Pham"
	}
}

# In-memory runtime state for live session
static var runtimeAffinity : Dictionary = {}     # char_id -> { npc_id: affinity_int }
static var runtimeStoryProgress : Dictionary = {} # char_id -> { chapter: int, progress: int }
static var runtimeChoices : Dictionary = {}       # char_id -> { choice_id: option_id }
static var runtimeActiveEvents : Dictionary = {}  # event_id -> { startTime: float, expiresAt: float, active: bool }
static var runtimeDiscoveredClues : Dictionary = {} # char_id -> Array[String]
static var runtimeSecretsFound : Dictionary = {}  # char_id -> Array[String]

# ==============================================================================
# 8. CORE API: STORY PROGRESSION
# ==============================================================================

static func GetCurrentChapter(actor : Node) -> int:
	var charId = _GetCharId(actor)
	if runtimeStoryProgress.has(charId):
		return runtimeStoryProgress[charId].get("chapter", 1)
	return 1

static func SetCurrentChapter(actor : Node, chapter : int, progress : int = 0) -> void:
	var charId = _GetCharId(actor)
	if not runtimeStoryProgress.has(charId):
		runtimeStoryProgress[charId] = {}
	runtimeStoryProgress[charId]["chapter"] = chapter
	runtimeStoryProgress[charId]["progress"] = progress

	# Auto-unlock chapter clue
	var chData = MAIN_STORY_CHAPTERS.get(chapter, null)
	if chData and chData.has("clueUnlocked"):
		UnlockClue(actor, chData["clueUnlocked"])

	var msg = "Tiến Trình Cốt Truyện: Đã bước vào [%s]!" % GetChapterTitle(chapter)
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)

static func GetChapterTitle(chapter : int) -> String:
	var chData = MAIN_STORY_CHAPTERS.get(chapter, null)
	return chData["title"] if chData else "Chương Không Xác Định"

static func AdvanceStory(actor : Node) -> Dictionary:
	var curCh = GetCurrentChapter(actor)
	if curCh < StoryChapter.CHAPTER_5_DAMAGED_DAO:
		var nextCh = curCh + 1
		SetCurrentChapter(actor, nextCh, 0)
		return { "success": true, "chapter": nextCh, "title": GetChapterTitle(nextCh) }
	return { "success": false, "chapter": curCh, "message": "Đã đạt đến cao trào cốt truyện hiện tại!" }

# ==============================================================================
# 9. CORE API: NPC RELATIONSHIPS & AFFINITY
# ==============================================================================

static func GetAffinity(actor : Node, npcId : String) -> int:
	var charId = _GetCharId(actor)
	if not runtimeAffinity.has(charId):
		runtimeAffinity[charId] = {}
	if not runtimeAffinity[charId].has(npcId):
		var dossier = NPC_DOSSIERS.get(npcId, {})
		runtimeAffinity[charId][npcId] = dossier.get("defaultAffinity", 50)
	return runtimeAffinity[charId][npcId]

static func AddAffinity(actor : Node, npcId : String, amount : int) -> Dictionary:
	var charId = _GetCharId(actor)
	var cur = GetAffinity(actor, npcId)
	var oldRank = GetRelationshipRank(cur)
	var updated = maxi(0, cur + amount)
	runtimeAffinity[charId][npcId] = updated
	var newRank = GetRelationshipRank(updated)

	var dossier = NPC_DOSSIERS.get(npcId, {})
	var npcName = dossier.get("name", npcId)

	var promoted = (newRank > oldRank)
	if promoted:
		var msg = "Quan hệ với [%s] đã thăng hoa lên mức [%s]!" % [npcName, GetRankName(newRank)]
		if actor is PlayerAgent:
			Network.PushNotification(msg, actor.peerID)

	return {
		"npcId": npcId,
		"affinity": updated,
		"rank": newRank,
		"promoted": promoted
	}

static func GetRelationshipRank(affinity : int) -> RelationshipRank:
	if affinity >= 1000: return RelationshipRank.CONFIDANT
	if affinity >= 600:  return RelationshipRank.TRUSTED
	if affinity >= 300:  return RelationshipRank.FRIENDLY
	if affinity >= 100:  return RelationshipRank.ACQUAINTANCE
	return RelationshipRank.STRANGER

static func GetRankName(rank : RelationshipRank) -> String:
	match rank:
		RelationshipRank.CONFIDANT:   return "Tri Kỷ"
		RelationshipRank.TRUSTED:     return "Tin Tưởng"
		RelationshipRank.FRIENDLY:    return "Thiện Cảm"
		RelationshipRank.ACQUAINTANCE:return "Quen Biết"
		_:                            return "Xa Lạ"

static func GetNpcDiscount(actor : Node, npcId : String) -> float:
	var dossier = NPC_DOSSIERS.get(npcId, {})
	var maxDisc = dossier.get("discountMax", 0.0)
	if maxDisc <= 0.0: return 0.0
	var aff = GetAffinity(actor, npcId)
	var rank = GetRelationshipRank(aff)
	match rank:
		RelationshipRank.CONFIDANT:   return maxDisc
		RelationshipRank.TRUSTED:     return maxDisc * 0.66
		RelationshipRank.FRIENDLY:    return maxDisc * 0.33
		_:                            return 0.0

static func GiveGiftToNpc(actor : Node, npcId : String, itemCell : ItemCell) -> Dictionary:
	if not itemCell:
		return { "success": false, "message": "Vật phẩm tặng không hợp lệ!" }
	var dossier = NPC_DOSSIERS.get(npcId, {})
	if dossier.is_empty():
		return { "success": false, "message": "NPC không tồn tại!" }

	var favored : Array = dossier.get("favoredItems", [])
	var isFavored = (itemCell.name in favored)
	var gainAffinity = 60 if isFavored else 20

	var itemIdx = actor.inventory.FindItemIndex(itemCell) if actor and actor.inventory else -1
	if itemIdx < 0 or not actor.inventory.RemoveItem(itemCell, 1, itemIdx):
		return { "success": false, "message": "Túi trữ vật không có vật phẩm này!" }

	var res = AddAffinity(actor, npcId, gainAffinity)
	var msg = "Tặng [%s] cho [%s]: Hảo Cảm +%d!" % [itemCell.name, dossier["name"], gainAffinity]
	if isFavored:
		msg += " (Đúng sở thích kỳ trân!)"
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)

	return { "success": true, "affinity": res["affinity"], "favored": isFavored, "message": msg }

# ==============================================================================
# 10. CORE API: CHOICES & CONSEQUENCES
# ==============================================================================

static func MakeStoryChoice(actor : Node, choiceId : String, optionId : String) -> Dictionary:
	var choiceDef = STORY_CHOICES.get(choiceId, {})
	if choiceDef.is_empty():
		return { "success": false, "message": "Lựa chọn không hợp lệ!" }

	var selectedOpt = null
	for opt in choiceDef["options"]:
		if opt["id"] == optionId:
			selectedOpt = opt
			break

	if not selectedOpt:
		return { "success": false, "message": "Nhánh lựa chọn không tồn tại!" }

	var charId = _GetCharId(actor)
	if not runtimeChoices.has(charId):
		runtimeChoices[charId] = {}
	runtimeChoices[charId][choiceId] = optionId

	# Apply Affinity Rewards
	if selectedOpt.has("affinityReward"):
		for npc in selectedOpt["affinityReward"]:
			AddAffinity(actor, npc, selectedOpt["affinityReward"][npc])

	# Apply Item Rewards
	if selectedOpt.has("itemReward") and actor:
		var hashId = DB.GetCellHash(selectedOpt["itemReward"])
		var cnt = selectedOpt.get("itemCount", 1)
		NpcCommons.AddItem(actor, hashId, cnt)

	# Apply Sect Contribution
	if selectedOpt.has("contribution") and actor:
		var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
		SectSystemClass.AddContribution(actor, selectedOpt["contribution"], "Quyết định cốt truyện")

	# Apply GP
	if selectedOpt.has("gp") and actor and actor.stat:
		actor.stat.AddGP(selectedOpt["gp"])

	# Apply Profession EXP
	if selectedOpt.has("professionExp") and actor:
		var CraftingSystemClass = preload("res://sources/crafting/CraftingSystem.gd")
		CraftingSystemClass.AddProfessionExp(actor, CraftingSystemClass.Profession.FORGEMASTER, selectedOpt["professionExp"])

	# Apply Clue
	if selectedOpt.has("clueId"):
		UnlockClue(actor, selectedOpt["clueId"])

	var msg = "Quyết Định Đã Khắc Sâu: %s" % selectedOpt["consequence"]
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)

	return {
		"success": true,
		"choiceId": choiceId,
		"optionId": optionId,
		"consequence": selectedOpt["consequence"]
	}

static func HasMadeChoice(actor : Node, choiceId : String) -> bool:
	var charId = _GetCharId(actor)
	return runtimeChoices.has(charId) and runtimeChoices[charId].has(choiceId)

static func GetChosenOption(actor : Node, choiceId : String) -> String:
	var charId = _GetCharId(actor)
	if runtimeChoices.has(charId):
		return runtimeChoices[charId].get(choiceId, "")
	return ""

# ==============================================================================
# 11. CORE API: CLUES & DEDUCTION NOTEBOOK
# ==============================================================================

static func UnlockClue(actor : Node, clueId : String) -> bool:
	var charId = _GetCharId(actor)
	if not runtimeDiscoveredClues.has(charId):
		runtimeDiscoveredClues[charId] = []
	if not (clueId in runtimeDiscoveredClues[charId]):
		runtimeDiscoveredClues[charId].append(clueId)
		var cData = STORY_CLUES.get(clueId, {})
		var title = cData.get("title", clueId)
		var msg = "Lĩnh ngộ manh mối mới: [%s]!" % title
		if actor is PlayerAgent:
			Network.PushNotification(msg, actor.peerID)
		return true
	return false

static func GetDiscoveredClues(actor : Node) -> Array:
	var charId = _GetCharId(actor)
	if runtimeDiscoveredClues.has(charId):
		return runtimeDiscoveredClues[charId]
	return []

# ==============================================================================
# 12. CORE API: LIVING WORLD & DYNAMIC EVENTS
# ==============================================================================

static func TriggerWorldEvent(eventId : String, durationOverride : float = 0.0) -> Dictionary:
	var evData = WORLD_EVENTS_CATALOG.get(eventId, {})
	if evData.is_empty():
		return { "success": false, "message": "Sự kiện không tồn tại!" }

	var now = Time.get_unix_time_from_system()
	var dur = durationOverride if durationOverride > 0 else evData.get("durationSeconds", 1800)
	runtimeActiveEvents[eventId] = {
		"startTime": now,
		"expiresAt": now + dur,
		"active": true
	}

	var msg = "⚡ SỰ KIỆN THẾ GIỚI: [%s] đang diễn ra tại [%s]!" % [evData["name"], evData["location"]]
	print("[LivingWorld] %s" % msg)
	return { "success": true, "event": evData, "expiresAt": now + dur }

static func IsEventActive(eventId : String) -> bool:
	if not runtimeActiveEvents.has(eventId):
		return false
	var ev = runtimeActiveEvents[eventId]
	if not ev.get("active", false):
		return false
	var now = Time.get_unix_time_from_system()
	if now >= ev.get("expiresAt", 0):
		ev["active"] = false
		return false
	return true

static func CompleteWorldEvent(actor : Node, eventId : String) -> Dictionary:
	if not IsEventActive(eventId):
		return { "success": false, "message": "Sự kiện không còn hiệu lực!" }

	var evData = WORLD_EVENTS_CATALOG.get(eventId, {})
	runtimeActiveEvents[eventId]["active"] = false

	# Distribute Event Rewards
	if evData.has("rewardExp") and actor:
		NpcCommons.AddExp(actor, evData["rewardExp"])
	if evData.has("rewardGp") and actor and actor.stat:
		actor.stat.AddGP(evData["rewardGp"])
	if evData.has("rewardContrib") and actor:
		var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
		SectSystemClass.AddContribution(actor, evData["rewardContrib"], "Chiến tích sự kiện thế giới")
	if evData.has("rewardItem") and actor:
		var hId = DB.GetCellHash(evData["rewardItem"])
		var cnt = evData.get("rewardCount", 1)
		NpcCommons.AddItem(actor, hId, cnt)

	var msg = "Hoàn thành xuất sắc Sự Kiện Thế Giới [%s]!" % evData["name"]
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)

	return { "success": true, "message": msg }

# ==============================================================================
# 13. CORE API: EXPLORATION & HIDDEN SECRETS
# ==============================================================================

static func DiscoverSecret(actor : Node, secretId : String) -> Dictionary:
	var sec = EXPLORATION_SECRETS.get(secretId, {})
	if sec.is_empty():
		return { "success": false, "message": "Bí mật không xác định!" }

	var charId = _GetCharId(actor)
	if not runtimeSecretsFound.has(charId):
		runtimeSecretsFound[charId] = []

	if secretId in runtimeSecretsFound[charId]:
		return { "success": false, "alreadyFound": true, "message": "Địa điểm bí mật này đạo hữu đã từng khám phá!" }

	# Check Level / Item / Comprehension condition
	if sec.has("reqLevel") and actor and actor.stat and actor.stat.level < sec["reqLevel"]:
		return { "success": false, "message": "Tu vi chưa đủ sâu để lĩnh ngộ bí cảnh (Cần Cấp %d)!" % sec["reqLevel"] }

	runtimeSecretsFound[charId].append(secretId)

	# Deliver Rewards
	if sec.has("rewardExp") and actor:
		NpcCommons.AddExp(actor, sec["rewardExp"])
	if sec.has("rewardItem") and actor:
		var hId = DB.GetCellHash(sec["rewardItem"])
		NpcCommons.AddItem(actor, hId, 1)

	var msg = "Khám phá bí mật ẩn: [%s]! Nhận thưởng kỳ duyên!" % sec["name"]
	if actor is PlayerAgent:
		Network.PushNotification(msg, actor.peerID)

	return { "success": true, "secret": sec, "message": msg }

static func GetFoundSecrets(actor : Node) -> Array:
	var charId = _GetCharId(actor)
	if runtimeSecretsFound.has(charId):
		return runtimeSecretsFound[charId]
	return []

# ==============================================================================
# 14. SQLITE PERSISTENCE ENGINE
# ==============================================================================

static func EnsureStoryTables(db : SQLite) -> bool:
	if not db: return false

	# 1. Story Progression Table
	var q1 = """
	CREATE TABLE IF NOT EXISTS char_story_progress (
		char_id INTEGER PRIMARY KEY,
		current_chapter INTEGER NOT NULL DEFAULT 1,
		chapter_progress INTEGER NOT NULL DEFAULT 0,
		updated_at INTEGER NOT NULL
	);
	"""
	db.query(q1)

	# 2. NPC Relationships Table
	var q2 = """
	CREATE TABLE IF NOT EXISTS char_npc_relationships (
		char_id INTEGER NOT NULL,
		npc_id TEXT NOT NULL,
		affinity INTEGER NOT NULL DEFAULT 0,
		relationship_rank INTEGER NOT NULL DEFAULT 0,
		updated_at INTEGER NOT NULL,
		PRIMARY KEY(char_id, npc_id)
	);
	"""
	db.query(q2)

	# 3. Story Choices Table
	var q3 = """
	CREATE TABLE IF NOT EXISTS char_story_choices (
		char_id INTEGER NOT NULL,
		choice_id TEXT NOT NULL,
		chosen_option TEXT NOT NULL,
		timestamp INTEGER NOT NULL,
		PRIMARY KEY(char_id, choice_id)
	);
	"""
	db.query(q3)

	# 4. Discovered Clues Table
	var q4 = """
	CREATE TABLE IF NOT EXISTS char_story_clues (
		char_id INTEGER NOT NULL,
		clue_id TEXT NOT NULL,
		discovered_at INTEGER NOT NULL,
		PRIMARY KEY(char_id, clue_id)
	);
	"""
	db.query(q4)

	# 5. Discovered Secrets Table
	var q5 = """
	CREATE TABLE IF NOT EXISTS char_story_secrets (
		char_id INTEGER NOT NULL,
		secret_id TEXT NOT NULL,
		discovered_at INTEGER NOT NULL,
		PRIMARY KEY(char_id, secret_id)
	);
	"""
	db.query(q5)

	return true

static func SaveStoryData(db : SQLite, charId : int) -> bool:
	if not db or charId <= 0: return false
	var now = int(Time.get_unix_time_from_system())

	# 1. Save Story Progress
	var ch = runtimeStoryProgress.get(charId, {}).get("chapter", 1)
	var prog = runtimeStoryProgress.get(charId, {}).get("progress", 0)
	var q1 = "INSERT OR REPLACE INTO char_story_progress (char_id, current_chapter, chapter_progress, updated_at) VALUES (%d, %d, %d, %d);" % [charId, ch, prog, now]
	db.query(q1)

	# 2. Save NPC Affinities
	if runtimeAffinity.has(charId):
		for npcId in runtimeAffinity[charId]:
			var aff = runtimeAffinity[charId][npcId]
			var rank = int(GetRelationshipRank(aff))
			var q2 = "INSERT OR REPLACE INTO char_npc_relationships (char_id, npc_id, affinity, relationship_rank, updated_at) VALUES (%d, '%s', %d, %d, %d);" % [charId, npcId, aff, rank, now]
			db.query(q2)

	# 3. Save Choices
	if runtimeChoices.has(charId):
		for cId in runtimeChoices[charId]:
			var opt = runtimeChoices[charId][cId]
			var q3 = "INSERT OR REPLACE INTO char_story_choices (char_id, choice_id, chosen_option, timestamp) VALUES (%d, '%s', '%s', %d);" % [charId, cId, opt, now]
			db.query(q3)

	# 4. Save Clues
	if runtimeDiscoveredClues.has(charId):
		for clueId in runtimeDiscoveredClues[charId]:
			var q4 = "INSERT OR IGNORE INTO char_story_clues (char_id, clue_id, discovered_at) VALUES (%d, '%s', %d);" % [charId, clueId, now]
			db.query(q4)

	# 5. Save Secrets
	if runtimeSecretsFound.has(charId):
		for secId in runtimeSecretsFound[charId]:
			var q5 = "INSERT OR IGNORE INTO char_story_secrets (char_id, secret_id, discovered_at) VALUES (%d, '%s', %d);" % [charId, secId, now]
			db.query(q5)

	return true

static func LoadStoryData(db : SQLite, charId : int) -> bool:
	if not db or charId <= 0: return false

	# 1. Load Progress
	var q1 = "SELECT current_chapter, chapter_progress FROM char_story_progress WHERE char_id = %d;" % charId
	if db.query(q1) and db.query_result.size() > 0:
		var row = db.query_result[0]
		if not runtimeStoryProgress.has(charId): runtimeStoryProgress[charId] = {}
		runtimeStoryProgress[charId]["chapter"] = row["current_chapter"]
		runtimeStoryProgress[charId]["progress"] = row["chapter_progress"]

	# 2. Load Relationships
	var q2 = "SELECT npc_id, affinity FROM char_npc_relationships WHERE char_id = %d;" % charId
	if db.query(q2):
		if not runtimeAffinity.has(charId): runtimeAffinity[charId] = {}
		for row in db.query_result:
			runtimeAffinity[charId][row["npc_id"]] = row["affinity"]

	# 3. Load Choices
	var q3 = "SELECT choice_id, chosen_option FROM char_story_choices WHERE char_id = %d;" % charId
	if db.query(q3):
		if not runtimeChoices.has(charId): runtimeChoices[charId] = {}
		for row in db.query_result:
			runtimeChoices[charId][row["choice_id"]] = row["chosen_option"]

	# 4. Load Clues
	var q4 = "SELECT clue_id FROM char_story_clues WHERE char_id = %d;" % charId
	if db.query(q4):
		runtimeDiscoveredClues[charId] = []
		for row in db.query_result:
			runtimeDiscoveredClues[charId].append(row["clue_id"])

	# 5. Load Secrets
	var q5 = "SELECT secret_id FROM char_story_secrets WHERE char_id = %d;" % charId
	if db.query(q5):
		runtimeSecretsFound[charId] = []
		for row in db.query_result:
			runtimeSecretsFound[charId].append(row["secret_id"])

	return true

# ==============================================================================
# 15. INTERNAL HELPERS
# ==============================================================================
static func _GetCharId(actor : Node) -> int:
	if not actor: return 0
	if actor is PlayerAgent:
		var peer = Peers.GetPeer(actor.peerID)
		if peer: return peer.characterID
	return actor.get_instance_id()
