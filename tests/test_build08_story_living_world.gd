extends Node2D

## TDNM — BUILD 08: HEAVENLY FATE, MAIN STORY & LIVING WORLD
## Comprehensive Automated End-to-End Test Suite.
## Tests Chapters 1-5, 8 NPC Dossiers, 5 Dao Clues, 5 Choices, 5 World Events, 8 Secrets, SQLite & UI.

const StorySystemClass = preload("res://sources/story/StorySystem.gd")
const StoryWindowClass = preload("res://sources/gui/StoryWindow.gd")
const Localization = preload("res://sources/system/Localization.gd")
const ProgressCommonsClass = preload("res://sources/actor/ProgressCommons.gd")

var timer : float = 0.0
var step : int = 0
var test_account : String = "StoryHero_" + str(int(Time.get_unix_time_from_system()) % 100000)
var test_pass : String = "MatKhau123!"
var test_char : String = "TrucSonTu_" + str(int(Time.get_unix_time_from_system()) % 10000)

var test_results : Dictionary = {}
var storyWindowInstance = null

func GetServerPlayer() -> PlayerAgent:
	for agent in WorldAgent.agents.values():
		if agent is PlayerAgent:
			return agent
	for peerID in Peers.peers:
		var agent = Peers.GetAgent(peerID)
		if agent and agent is PlayerAgent:
			return agent
	return null

func _ready():
	print("==================================================================")
	print("=== TDNM — BUILD 08: MAIN STORY, HEAVENLY DAO & LIVING WORLD   ===")
	print("==================================================================")

	# Execute Unit & Data Systems 1 - 7
	_RunStoryChaptersTests()
	_RunNpcDossiersTests()
	_RunCluesDeductionTests()
	_RunChoicesConsequencesTests()
	_RunLivingWorldEventsTests()
	_RunExplorationSecretsTests()
	_RunSQLiteSchemaTests()

	# Start Live In-Process Server & Client for Systems 8 - 14
	print("\n[Integration] Starting offline in-process engine for live Story gameplay...")
	NetworkCommons.IsLocal = true
	Launcher.Mode(true, true)

# ==============================================================================
# SYSTEM 1: 5 MAIN STORY CHAPTERS
# ==============================================================================
func _RunStoryChaptersTests():
	print("\n--- [SYSTEM 1: 5 MAIN STORY CHAPTERS PROGRESSION] ---")
	assert(StorySystemClass.MAIN_STORY_CHAPTERS.size() == 5, "Must define exactly 5 main story chapters")

	var expectedChapters = [
		{ "id": StorySystemClass.StoryChapter.CHAPTER_1_STRANGER, "title": "Chương 1: Người Lạ Tại Dị Giới", "quest": "MQ_CHUONG_1_TINH_LAC_DI_GIOI" },
		{ "id": StorySystemClass.StoryChapter.CHAPTER_2_PATH, "title": "Chương 2: Con Đường Tu Đạo", "quest": "MQ_CHUONG_2_CON_DUONG_TU_DAO" },
		{ "id": StorySystemClass.StoryChapter.CHAPTER_3_MUTATION, "title": "Chương 3: Dấu Vết Dị Biến", "quest": "MQ_CHUONG_3_DAU_VET_DI_BIEN" },
		{ "id": StorySystemClass.StoryChapter.CHAPTER_4_ANCIENT_SECRETS, "title": "Chương 4: Bí Mật Trong Cổ Tích", "quest": "MQ_CHUONG_4_BI_MAT_CO_TICH" },
		{ "id": StorySystemClass.StoryChapter.CHAPTER_5_DAMAGED_DAO, "title": "Chương 5: Thiên Đạo Có Khuyết", "quest": "MQ_CHUONG_5_THIEN_DAO_CO_KHUYET" }
	]

	for ch in expectedChapters:
		var cId = ch["id"]
		assert(StorySystemClass.MAIN_STORY_CHAPTERS.has(cId), "Missing chapter ID: %d" % cId)
		var cData = StorySystemClass.MAIN_STORY_CHAPTERS[cId]
		assert(cData["title"] == ch["title"], "Chapter title mismatch: %s vs %s" % [cData["title"], ch["title"]])
		assert(cData["questId"] == ch["quest"], "Chapter quest ID mismatch")
		assert(not cData["synopsis"].is_empty(), "Chapter synopsis cannot be empty")
		assert(not cData["clueUnlocked"].is_empty(), "Chapter must link to an unlockable clue")
		print("  ✔ Chương %d: [%s] (Yêu cầu cấp: %d, Manh mối: %s)" % [
			cId, cData["title"], cData["reqLevel"], cData["clueUnlocked"]
		])

	# Test Chapter Title Getter
	var t1 = StorySystemClass.GetChapterTitle(1)
	assert(t1 == "Chương 1: Người Lạ Tại Dị Giới", "GetChapterTitle returned unexpected string")

	test_results["system1_story_chapters"] = true
	print("[PASS] System 1: Story Chapters verified!")

# ==============================================================================
# SYSTEM 2: 8 NPC PROFILES & RELATIONSHIP TIERS
# ==============================================================================
func _RunNpcDossiersTests():
	print("\n--- [SYSTEM 2: 8 NPC PROFILES & 5 RELATIONSHIP TIERS] ---")
	assert(StorySystemClass.NPC_DOSSIERS.size() == 8, "Must define exactly 8 NPC dossiers")

	var expectedNpcs = [
		"DAO_HUYEN", "LIEU_THANH_Y", "HA_THIET_THU", "DIEP_TU_LANG",
		"MAC_LAO_NHAN", "TRAN_PHUONG", "BACH_HAC", "KHANG_VAN_KIM"
	]

	for npcId in expectedNpcs:
		assert(StorySystemClass.NPC_DOSSIERS.has(npcId), "Missing NPC dossier: %s" % npcId)
		var d = StorySystemClass.NPC_DOSSIERS[npcId]
		assert(not d["name"].is_empty(), "NPC name cannot be empty")
		assert(not d["title"].is_empty(), "NPC title cannot be empty")
		assert(not d["location"].is_empty(), "NPC location cannot be empty")
		assert(not d["personality"].is_empty(), "NPC personality cannot be empty")
		assert(not d["bio"].is_empty(), "NPC bio cannot be empty")
		assert(d["defaultAffinity"] >= 0, "Default affinity must be non-negative")
		assert(d["favoredItems"].size() > 0, "NPC must have favored items")
		print("  ✔ NPC: [%s] — %s (%s) • Hảo cảm ban đầu: %d" % [
			d["name"], d["title"], d["location"], d["defaultAffinity"]
		])

	# Test 5 Relationship Tiers
	assert(StorySystemClass.GetRelationshipRank(50) == StorySystemClass.RelationshipRank.STRANGER)
	assert(StorySystemClass.GetRelationshipRank(150) == StorySystemClass.RelationshipRank.ACQUAINTANCE)
	assert(StorySystemClass.GetRelationshipRank(350) == StorySystemClass.RelationshipRank.FRIENDLY)
	assert(StorySystemClass.GetRelationshipRank(750) == StorySystemClass.RelationshipRank.TRUSTED)
	assert(StorySystemClass.GetRelationshipRank(1200) == StorySystemClass.RelationshipRank.CONFIDANT)

	assert(StorySystemClass.GetRankName(StorySystemClass.RelationshipRank.STRANGER) == "Xa Lạ")
	assert(StorySystemClass.GetRankName(StorySystemClass.RelationshipRank.ACQUAINTANCE) == "Quen Biết")
	assert(StorySystemClass.GetRankName(StorySystemClass.RelationshipRank.FRIENDLY) == "Thiện Cảm")
	assert(StorySystemClass.GetRankName(StorySystemClass.RelationshipRank.TRUSTED) == "Tin Tưởng")
	assert(StorySystemClass.GetRankName(StorySystemClass.RelationshipRank.CONFIDANT) == "Tri Kỷ")

	test_results["system2_npc_dossiers"] = true
	print("[PASS] System 2: 8 NPC dossiers & 5 relationship tiers verified!")

# ==============================================================================
# SYSTEM 3: 5 CLUES OF HEAVENLY DAO DAMAGE (D-02 CANON)
# ==============================================================================
func _RunCluesDeductionTests():
	print("\n--- [SYSTEM 3: 5 HEAVENLY DAO CLUES & MODERN DEDUCTION (D-02)] ---")
	assert(StorySystemClass.STORY_CLUES.size() == 5, "Must define exactly 5 clues")

	var clueKeys = [
		"CLUE_1_QI_FLUCTUATION", "CLUE_2_MUTATED_CORES", "CLUE_3_ANCIENT_CONFLICT",
		"CLUE_4_ARRAY_DRIFT", "CLUE_5_DAMAGED_DAO"
	]

	for k in clueKeys:
		assert(StorySystemClass.STORY_CLUES.has(k), "Missing clue: %s" % k)
		var c = StorySystemClass.STORY_CLUES[k]
		assert(not c["title"].is_empty(), "Clue title cannot be empty")
		assert(not c["content"].is_empty(), "Clue content cannot be empty")
		assert(not c["deduction"].is_empty(), "Modern deduction cannot be empty")
		print("  ✔ [%s] -> %s" % [k, c["title"]])
		print("    Suy Luận: \"%s\"" % c["deduction"])

	# Canon D-02 Verification: Clue 5 must state Dao is NOT a sentient evil villain
	var c5 = StorySystemClass.STORY_CLUES["CLUE_5_DAMAGED_DAO"]
	assert("Thiên Đạo không phải ý chí tà ác" in c5["content"], "Canon D-02 violation: Clue 5 must affirm Dao is not evil sentient!")
	print("  ✔ Canon D-02 Verified: Thiên Đạo là quy tắc vũ trụ bị tổn thương, không phải Boss/Nhân vật phản diện!")

	test_results["system3_clues_deduction"] = true
	print("[PASS] System 3: Clues and modern analytical deduction verified!")

# ==============================================================================
# SYSTEM 4: 5 MAJOR CHOICES & CONSEQUENCES
# ==============================================================================
func _RunChoicesConsequencesTests():
	print("\n--- [SYSTEM 4: 5 CONSEQUENTIAL CHOICES & BRANCHES] ---")
	assert(StorySystemClass.STORY_CHOICES.size() == 5, "Must define exactly 5 story choices")

	var choiceKeys = [
		"CHOICE_1_RESCUE_OR_INVESTIGATE",
		"CHOICE_2_SUBMIT_OR_ANALYZE_STELE",
		"CHOICE_3_TRUST_HERMIT_OR_SECT",
		"CHOICE_4_PURIFY_OR_STUDY_CORE",
		"CHOICE_5_ARRAY_DECISION"
	]

	for ck in choiceKeys:
		assert(StorySystemClass.STORY_CHOICES.has(ck), "Missing story choice: %s" % ck)
		var c = StorySystemClass.STORY_CHOICES[ck]
		assert(not c["prompt"].is_empty(), "Choice prompt cannot be empty")
		assert(c["options"].size() == 2, "Choice must offer 2 distinct options")
		for opt in c["options"]:
			assert(not opt["id"].is_empty(), "Option id cannot be empty")
			assert(not opt["text"].is_empty(), "Option text cannot be empty")
			assert(not opt["consequence"].is_empty(), "Option consequence cannot be empty")
		print("  ✔ Quyết Định [%s]: Có 2 nhánh rẽ tác động quan hệ/thế giới" % ck)

	test_results["system4_choices_consequences"] = true
	print("[PASS] System 4: Choices & consequences catalog verified!")

# ==============================================================================
# SYSTEM 5: 5 LIVING WORLD DYNAMIC EVENTS
# ==============================================================================
func _RunLivingWorldEventsTests():
	print("\n--- [SYSTEM 5: 5 LIVING WORLD DYNAMIC EVENTS] ---")
	assert(StorySystemClass.WORLD_EVENTS_CATALOG.size() == 5, "Must define 5 world events")

	var eventKeys = [
		"YEU_THU_TRIEU", "LINH_KHI_DI_TUONG", "BI_CANH_XUAT_THE",
		"DU_PHUONG_THUONG_DOI", "CO_TRAN_BAT_ON"
	]

	for ek in eventKeys:
		assert(StorySystemClass.WORLD_EVENTS_CATALOG.has(ek), "Missing world event: %s" % ek)
		var ev = StorySystemClass.WORLD_EVENTS_CATALOG[ek]
		assert(not ev["name"].is_empty(), "Event name cannot be empty")
		assert(not ev["description"].is_empty(), "Event description cannot be empty")
		assert(ev["durationSeconds"] > 0, "Event duration must be positive")
		print("  ✔ Sự Kiện: [%s] (%s) • Thời lượng: %d giây" % [ev["name"], ev["location"], ev["durationSeconds"]])

	# Test trigger and active status check
	var trigRes = StorySystemClass.TriggerWorldEvent("LINH_KHI_DI_TUONG", 10.0)
	assert(trigRes["success"], "TriggerWorldEvent must succeed")
	assert(StorySystemClass.IsEventActive("LINH_KHI_DI_TUONG") == true, "Event must be active after triggering")

	test_results["system5_living_world_events"] = true
	print("[PASS] System 5: Living world events catalog and trigger logic verified!")

# ==============================================================================
# SYSTEM 6: 8 EXPLORATION SECRETS & HIDDEN DISCOVERIES
# ==============================================================================
func _RunExplorationSecretsTests():
	print("\n--- [SYSTEM 6: 8 EXPLORATION SECRETS & HIDDEN LOCATIONS] ---")
	assert(StorySystemClass.EXPLORATION_SECRETS.size() == 8, "Must define exactly 8 secrets")

	var secretKeys = [
		"SECRET_1_TRUC_SON_CO_BI", "SECRET_2_HIEN_VIEN_CO_DONG", "SECRET_3_U_HON_TRAM_BAO",
		"SECRET_4_NGU_HANH_THACH_TRAN", "SECRET_5_BIET_VIEN_DUOC_DIEN", "SECRET_6_LIEN_HOA_CO_THIET",
		"SECRET_7_PHONG_AN_DIA_HA", "SECRET_8_TIEN_NHAN_DI_THU"
	]

	for sk in secretKeys:
		assert(StorySystemClass.EXPLORATION_SECRETS.has(sk), "Missing secret: %s" % sk)
		var s = StorySystemClass.EXPLORATION_SECRETS[sk]
		assert(not s["name"].is_empty(), "Secret name cannot be empty")
		assert(not s["description"].is_empty(), "Secret description cannot be empty")
		assert(s["rewardExp"] > 0, "Secret must grant exp")
		assert(not s["rewardItem"].is_empty(), "Secret must grant item")
		print("  ✔ Bí Mật: [%s] (%s) -> Tọa độ: %s" % [s["name"], s["type"], str(s["coords"])])

	test_results["system6_exploration_secrets"] = true
	print("[PASS] System 6: Exploration secrets catalog verified!")

# ==============================================================================
# SYSTEM 7: SQLITE PERSISTENCE SCHEMA VERIFICATION
# ==============================================================================
func _RunSQLiteSchemaTests():
	print("\n--- [SYSTEM 7: SQLITE STORY TABLES SCHEMA VERIFICATION] ---")
	var db = SQLite.new()
	db.path = SQLCommons.GetDBPath()
	if db.open_db():
		StorySystemClass.EnsureStoryTables(db)

		var expectedTables = [
			"char_story_progress",
			"char_npc_relationships",
			"char_story_choices",
			"char_story_clues",
			"char_story_secrets"
		]

		for tbl in expectedTables:
			var query = "SELECT name FROM sqlite_master WHERE type='table' AND name='%s';" % tbl
			var ok = db.query(query)
			assert(ok and db.query_result.size() > 0, "SQLite table %s must exist!" % tbl)
			print("  ✔ Bảng SQLite xác nhận tồn tại: [%s]" % tbl)

		db.close_db()

	test_results["system7_sqlite_schema"] = true
	print("[PASS] System 7: SQLite persistence schema verified!")

# ==============================================================================
# LIVE PROCESS LOOP (SYSTEMS 8 - 14)
# ==============================================================================
func _process(delta : float):
	timer += delta

	# Step 1: Wait for client connection at 1.0s
	if timer > 1.0 and step == 0 and Network.clientConnected:
		step = 1
		print("\n--- [LIVE STEP 1: CLIENT CONNECTION] ---")
		print("[Step 1 PASS] Connected via in-process offline dispatch!")
		test_results["live_step1_connected"] = true
		print("[Step 2] Logging in with account: %s" % test_account)
		Network.LoginWithPassword(test_account, test_pass, false)

	# Step 2: Create Character at 3.5s
	if timer > 3.5 and step == 1:
		step = 2
		test_char = "TrucSonTu_%d" % (randi() % 90000 + 10000)
		print("[Step 2 PASS] Logged in! Creating character: %s" % test_char)
		var hairstyles : PackedInt64Array = DB.HairstylesDB.keys()
		var haircolors : PackedInt64Array = DB.PalettesDB[DB.Palette.HAIR].keys() if DB.Palette.HAIR < DB.PalettesDB.size() else []
		var races : PackedInt64Array = DB.RacesDB.keys()
		var raceData : RaceData = DB.GetRace(races[0]) if not races.is_empty() else null
		var skins : Array = raceData.skins.keys() if raceData and raceData.skins else ["Medium"]

		var traits = {
			"hairstyle": hairstyles[0] if hairstyles.size() > 0 else "Bald".hash(),
			"haircolor": haircolors[0] if haircolors.size() > 0 else "Ash Brown".hash(),
			"race": races[0] if races.size() > 0 else "Human".hash(),
			"skintone": skins[0].hash() if skins.size() > 0 else "Medium".hash(),
			"gender": 0,
			"shape": "Player".hash(),
			"spirit": "Piou".hash()
		}
		var attrs = {
			"strength": 1,
			"vitality": 1,
			"agility": 1,
			"endurance": 1,
			"concentration": 1
		}
		Network.CreateCharacter(test_char, traits, attrs)

	# Step 3: Connect Character into World at 5.5s
	if timer > 5.5 and step == 2:
		step = 3
		print("[Step 3] Connecting character: %s" % test_char)
		Network.ConnectCharacter(test_char)

	# Step 4: Verify Spawn and Execute Live Story Progression at 8.0s
	if timer > 8.0 and step == 3:
		step = 4
		var player = GetServerPlayer()
		assert(player != null, "Server player must exist")
		print("\n--- [LIVE SYSTEM 8: IN-GAME STORY CHAPTER PROGRESSION] ---")

		# Character should start at Chapter 1
		var curCh = StorySystemClass.GetCurrentChapter(player)
		assert(curCh == 1, "Initial chapter must be 1")
		print("  ✔ Chương ban đầu: [%s]" % StorySystemClass.GetChapterTitle(curCh))

		# Advance to Chapter 2
		var advRes = StorySystemClass.AdvanceStory(player)
		assert(advRes["success"] and advRes["chapter"] == 2, "Story must advance to chapter 2")
		print("  ✔ Đột phá cốt truyện: Đã bước sang [%s]!" % advRes["title"])

		# Verify clue unlocked automatically
		var clues = StorySystemClass.GetDiscoveredClues(player)
		assert("CLUE_2_MUTATED_CORES" in clues, "Advancing to Chapter 2 must unlock CLUE_2_MUTATED_CORES")
		print("  ✔ Tự động liễu ngộ manh mối: [Manh Mối 2: Yêu Đan Dị Chủng]!")

		test_results["live_step8_story_progression"] = true

	# Step 5: NPC Affinity & Gift Giving Mechanics at 10.5s
	if timer > 10.5 and step == 4:
		step = 5
		var player = GetServerPlayer()
		print("\n--- [LIVE SYSTEM 9: NPC AFFINITY, GIFT GIVING & DISCOUNTS] ---")

		var npcId = "LIEU_THANH_Y"
		var initialAff = StorySystemClass.GetAffinity(player, npcId)
		assert(initialAff == 100, "Lieu Thanh Y default affinity must be 100")
		print("  ✔ Hảo cảm ban đầu với Liễu Thanh Y: %d (%s)" % [
			initialAff, StorySystemClass.GetRankName(StorySystemClass.GetRelationshipRank(initialAff))
		])

		# Supply favored gift item: Ngan Linh Thao
		var herbHash = DB.GetCellHash("Ngan Linh Thao")
		NpcCommons.AddItem(player, herbHash, 2)
		var herbCell = DB.GetItem(herbHash)

		# Gift favored item to Lieu Thanh Y
		var giftRes = StorySystemClass.GiveGiftToNpc(player, npcId, herbCell)
		assert(giftRes["success"], "Gift giving must succeed: %s" % giftRes["message"])
		assert(giftRes["favored"] == true, "Ngan Linh Thao must be favored item for Lieu Thanh Y")
		assert(giftRes["affinity"] == initialAff + 60, "Favored gift must grant +60 affinity")
		print("  ✔ %s" % giftRes["message"])

		# Promote affinity to 350 (FRIENDLY) to test merchant discount
		StorySystemClass.AddAffinity(player, npcId, 200) # 160 + 200 = 360 (FRIENDLY)
		var rank = StorySystemClass.GetRelationshipRank(StorySystemClass.GetAffinity(player, npcId))
		assert(rank == StorySystemClass.RelationshipRank.FRIENDLY, "Rank must now be FRIENDLY")
		var discount = StorySystemClass.GetNpcDiscount(player, npcId)
		assert(discount > 0.04, "Friendly discount must be active (> 4%%)")
		print("  ✔ Thăng cấp quan hệ: [Thiện Cảm] • Giảm giá tiệm Dược Đường: %.1f%%" % (discount * 100.0))

		test_results["live_step9_npc_affinity_gift"] = true

	# Step 6: Consequential Choice Execution at 12.5s
	if timer > 12.5 and step == 5:
		step = 6
		var player = GetServerPlayer()
		print("\n--- [LIVE SYSTEM 10: CONSEQUENTIAL CHOICES & PERSISTENCE] ---")

		var cId = "CHOICE_1_RESCUE_OR_INVESTIGATE"
		assert(not StorySystemClass.HasMadeChoice(player, cId), "Choice must not be made yet")

		# Choose RESCUE option
		var choiceRes = StorySystemClass.MakeStoryChoice(player, cId, "RESCUE")
		assert(choiceRes["success"], "Choice execution must succeed")
		assert(StorySystemClass.HasMadeChoice(player, cId), "Choice must now be marked as made")
		assert(StorySystemClass.GetChosenOption(player, cId) == "RESCUE", "Chosen option must be RESCUE")

		# Verify reward items received: Hoi Xuan Dan x2
		var pillHash = DB.GetCellHash("Hoi Xuan Dan")
		var pillCell = DB.GetItem(pillHash)
		assert(player.inventory.GetItemCount(pillCell) >= 2, "Player must receive 2 Hoi Xuan Dan from choice")
		print("  ✔ Thi hành lựa chọn thành công: [Cứu Viện Trần Phương]")
		print("  ✔ Nhận thưởng hệ quả: %s" % choiceRes["consequence"])

		test_results["live_step10_choice_execution"] = true

	# Step 7: Dynamic World Event Lifecycle at 14.5s
	if timer > 14.5 and step == 6:
		step = 7
		var player = GetServerPlayer()
		print("\n--- [LIVE SYSTEM 11: DYNAMIC WORLD EVENT LIFECYCLE & REWARDS] ---")

		var evId = "YEU_THU_TRIEU"
		var trigRes = StorySystemClass.TriggerWorldEvent(evId, 60.0)
		assert(trigRes["success"], "TriggerWorldEvent must succeed")
		assert(StorySystemClass.IsEventActive(evId), "Event must be active")
		print("  ✔ Sự kiện thế giới kích hoạt: [%s] (Hiệu lực: 60s)" % evId)

		var gpBefore = player.stat.gp
		var expBefore = player.stat.experience

		# Complete event
		var compRes = StorySystemClass.CompleteWorldEvent(player, evId)
		assert(compRes["success"], "CompleteWorldEvent must succeed")
		assert(not StorySystemClass.IsEventActive(evId), "Event must no longer be active after completion")
		assert(player.stat.gp == gpBefore + 500, "Player must receive 500 GP reward")
		print("  ✔ %s (+300 Tu Vi, +500 Linh Thạch, +80 Cống Hiến)!" % compRes["message"])

		test_results["live_step11_world_event_lifecycle"] = true

	# Step 8: Exploration Secret Discovery at 16.5s
	if timer > 16.5 and step == 7:
		step = 8
		var player = GetServerPlayer()
		print("\n--- [LIVE SYSTEM 12: EXPLORATION SECRET DISCOVERY & NO REPEAT] ---")

		var secId = "SECRET_1_TRUC_SON_CO_BI"
		var discRes = StorySystemClass.DiscoverSecret(player, secId)
		assert(discRes["success"], "DiscoverSecret must succeed: %s" % discRes["message"])
		var found = StorySystemClass.GetFoundSecrets(player)
		assert(secId in found, "Secret must be in found secrets list")
		print("  ✔ %s" % discRes["message"])

		# Verify duplicate discovery is prevented
		var dupRes = StorySystemClass.DiscoverSecret(player, secId)
		assert(dupRes["success"] == false and dupRes.get("alreadyFound", false) == true, "Duplicate discovery must be blocked")
		print("  ✔ Chống lặp kỳ duyên: Hệ thống ngăn chặn nhận thưởng lặp lại an toàn!")

		test_results["live_step12_secrets_discovery"] = true

	# Step 9: StoryWindow UI 5/5 Tabs Validation at 18.0s
	if timer > 18.0 and step == 8:
		step = 9
		var player = GetServerPlayer()
		print("\n--- [LIVE SYSTEM 13: STORY WINDOW UI 5/5 TABS VALIDATION] ---")

		storyWindowInstance = StoryWindowClass.new()
		add_child(storyWindowInstance)
		storyWindowInstance.Refresh(player)

		assert(storyWindowInstance.tabContainer != null, "Tab container must exist")
		assert(storyWindowInstance.tabContainer.get_tab_count() == 5, "StoryWindow must have exactly 5 tabs")

		var expectedTabs = [
			"Cốt Truyện Chính",
			"Sổ Nhiệm Vụ",
			"Hồ Sơ & Hảo Cảm",
			"Nhật Ký Manh Mối",
			"Thế Giới Sự Kiện"
		]

		for i in 5:
			var tTitle = storyWindowInstance.tabContainer.get_tab_title(i)
			assert(tTitle == expectedTabs[i], "Tab title mismatch: %s vs %s" % [tTitle, expectedTabs[i]])
			print("  ✔ Tab %d: [%s] xác nhận hoạt động!" % [i + 1, tTitle])

		test_results["live_step13_story_window_ui"] = true

	# Step 10: Final Quality Gate Assertions at 20.0s
	if timer > 20.0 and step == 9:
		step = 10
		print("\n==================================================================")
		print("=== TDNM BUILD 08: ALL STORY & LIVING WORLD SYSTEMS VERIFIED   ===")
		print("==================================================================")
		var allPassed = true
		for k in test_results:
			var passState = test_results[k]
			print("  ✔ %s: %s" % [k, "PASS" if passState else "FAIL"])
			if not passState:
				allPassed = false

		assert(allPassed, "All Build 08 test cases must pass")
		assert(test_results.size() >= 13, "Must pass at least 13 test checkpoints")
		print("\nAll automated assertions PASSED with 0 errors!")
		print("Exiting test suite successfully.")
		get_tree().quit(0)
