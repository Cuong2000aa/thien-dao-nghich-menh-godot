extends RefCounted
class_name ProgressCommons

const UnknownProgress : int						= 0
const CompletedProgress : int					= 255

# Quest ID list
class Quest:
	static var SPLATYNA_OFFERING : int = "Splatyna's Offering".hash()
	static var GRAIN_IN_THE_SAND : int = "Grain in the desert".hash()
	static var SNAKE_PIT_THIEF : int = "Snake Pit Thief".hash()
	static var SNAKE_PIT_BITING_THIRST : int = "A Biting Thirst".hash()
	static var SANDSTORM_MINE_ABANDONED_TREASURE : int = "Sandstorm Mine Abandoned Treasure".hash()
	static var TULIMSHAR_OLD_FRIENDSHIP : int = "An Old Friendship".hash()
	static var TUTORIAL : int = "Tutorial".hash()
	static var ELANORE_POTION : int = "Elanore's Potions".hash()
	static var NINA_HUNGRY : int = "Nina's Snack".hash()
	static var MINE_EXPLORATION : int = "Mine Exploration".hash()
	static var SANDSTORM_NATHAN_WATER : int = "A Drop of Relief".hash()
	static var SANDSTORM_NAEM_HELMET : int = "A Miner's Helping Hand".hash()
	static var DESERT_SEED : int = "Desert Seed".hash()
	static var TULIMSHAR_EASTERN_HILLS_CHEST : int = "Found a Chest in the Outskirts".hash()
	static var TULIMSHAR_GLASSMAKING : int = "When the desert gives you sand...".hash()
	static var SHIP_PETER_BOUNTY : int = "Peter's Bounty".hash()
	static var VETERAN_CAVE_EXPLORER : int = "Veteran Cave Explorer".hash()
	static var THANH_TRU_LINH_TRUNG : int = "Thanh Trừ Linh Trùng".hash()
	static var THU_THAP_LINH_THAO : int = "Thu Thập Linh Thảo".hash()
	static var LUYEN_DAN_NHAP_MON : int = "Luyện Đan Nhập Môn".hash()
	static var KHAM_PHA_CO_BI : int = "Khám Phá Cổ Bi".hash()
	static var THAO_PHAT_THU_VUONG : int = "Thảo Phạt Thú Vương".hash()
	static var THU_THAP_KHOANG_THACH : int = "Thu Thập Khoáng Thạch".hash()
	static var NHAP_MON_KHAO_NGHIEM : int = "Khảo Nghiệm Nhập Môn".hash()
	static var TUAN_TRA_SON_MON : int = "Tuần Tra Sơn Môn".hash()
	static var CONG_HIEN_DUOC_THAO : int = "Cống Hiến Dược Thảo".hash()
	static var CONG_HIEN_KHOANG_THACH : int = "Cống Hiến Khoáng Thạch".hash()
	static var DIET_TRU_MA_VAT : int = "Diệt Trừ Ma Vật".hash()
	static var KHAO_HACH_NGOAI_MON : int = "Khảo Hạch Ngoại Môn".hash()
	static var KHAO_HACH_NOI_MON : int = "Khảo Hạch Nội Môn".hash()
	static var TRUYEN_THUA_TONG_MON : int = "Truyền Thừa Tông Môn".hash()

	# BUILD 08: Main Story Chapters
	static var MQ_CHUONG_1_TINH_LAC_DI_GIOI : int = "Tỉnh Lạc Dị Giới".hash()
	static var MQ_CHUONG_2_CON_DUONG_TU_DAO : int = "Con Đường Tu Đạo".hash()
	static var MQ_CHUONG_3_DAU_VET_DI_BIEN : int = "Dấu Vết Dị Biến".hash()
	static var MQ_CHUONG_4_BI_MAT_CO_TICH : int = "Bí Mật Trong Cổ Tích".hash()
	static var MQ_CHUONG_5_THIEN_DAO_CO_KHUYET : int = "Thiên Đạo Có Khuyết".hash()

	# BUILD 08: NPC Relationship Chains
	static var NQ_LIEU_THANH_Y_1 : int = "Dược Điển Tầm Thảo".hash()
	static var NQ_LIEU_THANH_Y_2 : int = "Cứu Trợ Thương Binh".hash()
	static var NQ_HA_THIET_THU_1 : int = "Khoáng Thạch Thí Luyện".hash()
	static var NQ_HA_THIET_THU_2 : int = "Bí Quyết Truốt Kiếm".hash()
	static var NQ_DIEP_TU_LANG_1 : int = "Huyết Tích Dã Ngoại".hash()
	static var NQ_DIEP_TU_LANG_2 : int = "Săn Bắt Dị Thú".hash()
	static var NQ_MAC_LAO_NHAN_1 : int = "Minh Văn Trận Phù".hash()
	static var NQ_MAC_LAO_NHAN_2 : int = "Cổ Trận Thăm Dò".hash()
	static var NQ_TRAN_PHUONG_1 : int = "Đồng Môn Tương Trợ".hash()
	static var NQ_TRAN_PHUONG_2 : int = "Tâm Ma Thử Thách".hash()

	# BUILD 08: Side, Exploration & Hidden Discoveries
	static var SQ_HIEN_VIEN_BI_MAT : int = "Thám Hiểm Hiên Viên Động".hash()
	static var SQ_U_HON_TRAM_BAO : int = "Tìm Kiếm U Hồn Trầm Bảo".hash()
	static var SQ_NGU_HANH_THACH_TRAN : int = "Giải Mã Trận Pháp Ngũ Hành".hash()
	static var SQ_BIET_VIEN_DUOC_DIEN : int = "Bí Cảnh Thảo Dược".hash()
	static var SQ_LIEN_HOA_CO_THIET : int = "Khai Thác Liên Hoa Cổ Thiết".hash()
	static var SQ_PHONG_AN_DIA_HA : int = "Điều Tra Hầm Ngục Cổ Xưa".hash()
	static var SQ_TIEN_NHAN_DI_THU : int = "Bức Thư Của Tiền Nhân Xuyên Không".hash()
	static var SQ_DU_PHUONG_GIAO_THUONG : int = "Tiếp Đón Du Phương Thương Đội".hash()

	# BUILD 08: World Events Quests
	static var EQ_YEU_THU_TRIEU : int = "Đẩy Lùi Yêu Thú Triều Tịch".hash()
	static var EQ_LINH_KHI_DI_TUONG : int = "Thu Thập Tinh Hoa Dị Tượng".hash()
	static var EQ_CO_TRAN_BAT_ON : int = "Ổn Định Linh Mạch Cổ Trận".hash()

# Quest enums
enum SPLATYNA_OFFERING
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum GRAIN_IN_THE_SAND
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED,
	SEARCHED_CRATES,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum SNAKE_PIT_THIEF
{
	INACTIVE = ProgressCommons.UnknownProgress,
	# Bits 0 to 4 [1; 31] are reserved to finding clues
	ALL_CLUES_FOUND = 31,
	RIDDLE_SOLVED = 32,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum SNAKE_PIT_BITING_THIRST
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum SANDSTORM_MINE_ABANDONED_TREASURE
{
	INACTIVE = ProgressCommons.UnknownProgress,
	KEY_FOUND,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum TULIMSHAR_OLD_FRIENDSHIP
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED,
	ENVELOPES_FOUND,
	LETTERS_DELIVERED,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum TUTORIAL
{
	INACTIVE = ProgressCommons.UnknownProgress,
	INTRO_ITEMS_GIVEN,
	POTION_GIVEN,
	CLOTHES_GIVEN,
	UI_EXPLAINED,
	ELANORE_DONE,
	KAEL_MET,
	KAEL_DONE,
	EKINU_DONE = ProgressCommons.CompletedProgress,
}
enum ELANORE_POTION
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED,
	BREWED = ProgressCommons.CompletedProgress,
}
enum NINA_HUNGRY
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum MINE_EXPLORATION
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED,
	FIND_NICKOS,
	STRANGER_SPOTTED,
	FIGHTING,
	DEFEATED,
	MANA_TREE_MET,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum SANDSTORM_NATHAN_WATER
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum SANDSTORM_NAEM_HELMET
{
	INACTIVE = ProgressCommons.UnknownProgress,
	GIVEN = ProgressCommons.CompletedProgress,
}
enum DESERT_SEED
{
	INACTIVE = ProgressCommons.UnknownProgress,
	SEEK_NINA,
	SEEK_MANAYIR,
}
enum TULIMSHAR_EASTERN_HILLS_CHEST
{
	INACTIVE = ProgressCommons.UnknownProgress,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum TULIMSHAR_GLASSMAKING
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum SHIP_PETER_BOUNTY
{
	INACTIVE = ProgressCommons.UnknownProgress,
	WAVE_ONE_DONE = 1,
	WAVE_TWO_DONE = 2,
	ALL_DONE = ProgressCommons.CompletedProgress,
}
enum VETERAN_CAVE_EXPLORER
{
	INACTIVE = ProgressCommons.UnknownProgress,
	UNCLAIMED,
	REWARDS_WITHDREW = ProgressCommons.CompletedProgress,
}
enum THANH_TRU_LINH_TRUNG
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	KILLED_1 = 2,
	KILLED_2 = 3,
	KILLED_3 = 4,
	KILLED_4 = 5,
	OBJECTIVE_MET = 6,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum THU_THAP_LINH_THAO
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	GATHERED_1 = 2,
	GATHERED_2 = 3,
	OBJECTIVE_MET = 4,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum LUYEN_DAN_NHAP_MON
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	OBJECTIVE_MET = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum KHAM_PHA_CO_BI
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	OBJECTIVE_MET = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum THAO_PHAT_THU_VUONG
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	BOSS_SLAIN = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum THU_THAP_KHOANG_THACH
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	OBJECTIVE_MET = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum NHAP_MON_KHAO_NGHIEM
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	OBJECTIVE_MET = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum TUAN_TRA_SON_MON
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	PATROL_STEP_1 = 2,
	PATROL_STEP_2 = 3,
	OBJECTIVE_MET = 4,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum CONG_HIEN_DUOC_THAO
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	OBJECTIVE_MET = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum CONG_HIEN_KHOANG_THACH
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	OBJECTIVE_MET = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum DIET_TRU_MA_VAT
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	OBJECTIVE_MET = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum KHAO_HACH_NGOAI_MON
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	SPARRING_WON = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum KHAO_HACH_NOI_MON
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	TRIAL_BEAST_SLAIN = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}
enum TRUYEN_THUA_TONG_MON
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	COMPREHENDED = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}

enum XIANXIA_STORY_QUEST
{
	INACTIVE = ProgressCommons.UnknownProgress,
	STARTED = 1,
	OBJECTIVE_MET = 2,
	COMPLETED = ProgressCommons.CompletedProgress,
}

# Quest state lookup
static var QuestStates : Dictionary[int, Variant] = {
	Quest.SPLATYNA_OFFERING: SPLATYNA_OFFERING,
	Quest.GRAIN_IN_THE_SAND: GRAIN_IN_THE_SAND,
	Quest.SNAKE_PIT_THIEF: SNAKE_PIT_THIEF,
	Quest.SNAKE_PIT_BITING_THIRST: SNAKE_PIT_BITING_THIRST,
	Quest.SANDSTORM_MINE_ABANDONED_TREASURE: SANDSTORM_MINE_ABANDONED_TREASURE,
	Quest.TULIMSHAR_OLD_FRIENDSHIP: TULIMSHAR_OLD_FRIENDSHIP,
	Quest.TUTORIAL: TUTORIAL,
	Quest.ELANORE_POTION: ELANORE_POTION,
	Quest.NINA_HUNGRY: NINA_HUNGRY,
	Quest.MINE_EXPLORATION: MINE_EXPLORATION,
	Quest.SANDSTORM_NATHAN_WATER: SANDSTORM_NATHAN_WATER,
	Quest.SANDSTORM_NAEM_HELMET: SANDSTORM_NAEM_HELMET,
	Quest.DESERT_SEED: DESERT_SEED,
	Quest.TULIMSHAR_EASTERN_HILLS_CHEST: TULIMSHAR_EASTERN_HILLS_CHEST,
	Quest.TULIMSHAR_GLASSMAKING: TULIMSHAR_GLASSMAKING,
	Quest.SHIP_PETER_BOUNTY: SHIP_PETER_BOUNTY,
	Quest.VETERAN_CAVE_EXPLORER: VETERAN_CAVE_EXPLORER,
	Quest.THANH_TRU_LINH_TRUNG: THANH_TRU_LINH_TRUNG,
	Quest.THU_THAP_LINH_THAO: THU_THAP_LINH_THAO,
	Quest.LUYEN_DAN_NHAP_MON: LUYEN_DAN_NHAP_MON,
	Quest.KHAM_PHA_CO_BI: KHAM_PHA_CO_BI,
	Quest.THAO_PHAT_THU_VUONG: THAO_PHAT_THU_VUONG,
	Quest.THU_THAP_KHOANG_THACH: THU_THAP_KHOANG_THACH,
	Quest.NHAP_MON_KHAO_NGHIEM: NHAP_MON_KHAO_NGHIEM,
	Quest.TUAN_TRA_SON_MON: TUAN_TRA_SON_MON,
	Quest.CONG_HIEN_DUOC_THAO: CONG_HIEN_DUOC_THAO,
	Quest.CONG_HIEN_KHOANG_THACH: CONG_HIEN_KHOANG_THACH,
	Quest.DIET_TRU_MA_VAT: DIET_TRU_MA_VAT,
	Quest.KHAO_HACH_NGOAI_MON: KHAO_HACH_NGOAI_MON,
	Quest.KHAO_HACH_NOI_MON: KHAO_HACH_NOI_MON,
	Quest.TRUYEN_THUA_TONG_MON: TRUYEN_THUA_TONG_MON,

	# Build 08 Main Story Quests
	Quest.MQ_CHUONG_1_TINH_LAC_DI_GIOI: XIANXIA_STORY_QUEST,
	Quest.MQ_CHUONG_2_CON_DUONG_TU_DAO: XIANXIA_STORY_QUEST,
	Quest.MQ_CHUONG_3_DAU_VET_DI_BIEN: XIANXIA_STORY_QUEST,
	Quest.MQ_CHUONG_4_BI_MAT_CO_TICH: XIANXIA_STORY_QUEST,
	Quest.MQ_CHUONG_5_THIEN_DAO_CO_KHUYET: XIANXIA_STORY_QUEST,

	# Build 08 NPC Relationship Quests
	Quest.NQ_LIEU_THANH_Y_1: XIANXIA_STORY_QUEST,
	Quest.NQ_LIEU_THANH_Y_2: XIANXIA_STORY_QUEST,
	Quest.NQ_HA_THIET_THU_1: XIANXIA_STORY_QUEST,
	Quest.NQ_HA_THIET_THU_2: XIANXIA_STORY_QUEST,
	Quest.NQ_DIEP_TU_LANG_1: XIANXIA_STORY_QUEST,
	Quest.NQ_DIEP_TU_LANG_2: XIANXIA_STORY_QUEST,
	Quest.NQ_MAC_LAO_NHAN_1: XIANXIA_STORY_QUEST,
	Quest.NQ_MAC_LAO_NHAN_2: XIANXIA_STORY_QUEST,
	Quest.NQ_TRAN_PHUONG_1: XIANXIA_STORY_QUEST,
	Quest.NQ_TRAN_PHUONG_2: XIANXIA_STORY_QUEST,

	# Build 08 Side & Exploration Quests
	Quest.SQ_HIEN_VIEN_BI_MAT: XIANXIA_STORY_QUEST,
	Quest.SQ_U_HON_TRAM_BAO: XIANXIA_STORY_QUEST,
	Quest.SQ_NGU_HANH_THACH_TRAN: XIANXIA_STORY_QUEST,
	Quest.SQ_BIET_VIEN_DUOC_DIEN: XIANXIA_STORY_QUEST,
	Quest.SQ_LIEN_HOA_CO_THIET: XIANXIA_STORY_QUEST,
	Quest.SQ_PHONG_AN_DIA_HA: XIANXIA_STORY_QUEST,
	Quest.SQ_TIEN_NHAN_DI_THU: XIANXIA_STORY_QUEST,
	Quest.SQ_DU_PHUONG_GIAO_THUONG: XIANXIA_STORY_QUEST,

	# Build 08 World Events Quests
	Quest.EQ_YEU_THU_TRIEU: XIANXIA_STORY_QUEST,
	Quest.EQ_LINH_KHI_DI_TUONG: XIANXIA_STORY_QUEST,
	Quest.EQ_CO_TRAN_BAT_ON: XIANXIA_STORY_QUEST,
}

static func GetQuestStateID(questID : int, stateName : String) -> int:
	var questState : Variant = QuestStates.get(questID)
	return questState.get(stateName, UnknownProgress) if questState else UnknownProgress
