extends Node2D

## Headless Integration & Quality-Gate Test Suite for TDNM Build 06:
## Sect System, Disciple Progression & Cultivation Society
## Validates all 13 core sect systems, SQLite persistence, and live in-process gameplay.

const SectSystemClass = preload("res://sources/sect/SectSystem.gd")
const SectWindowClass = preload("res://sources/gui/SectWindow.gd")
const CultivationClass = preload("res://sources/actor/Cultivation.gd")
const Localization = preload("res://sources/system/Localization.gd")

var test_results : Dictionary = {
	"system1_sect_registry": false,
	"system2_disciple_ranks": false,
	"system3_initiation_package": false,
	"system4_contribution_economy": false,
	"system5_resource_donation": false,
	"system6_promotion_lifecycle": false,
	"system7_sect_exchange": false,
	"system8_tang_kinh_cac": false,
	"system9_tu_linh_tran": false,
	"system10_leaderboard": false,
	"system11_sqlite_persistence": false,
	"live_step1_connected": false,
	"live_step2_login": false,
	"live_step3_spawn": false,
	"live_step4_sect_progression": false,
	"live_step5_sect_window_ui": false
}

var timer : float = 0.0
var step : int = 0
var charNick : String = ""
var sectWindowInstance = null

class DummyAgent extends Node:
	var stat : Dictionary = { "level": 1 }

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
	print("=== TDNM — BUILD 06: SECT SYSTEM & DISCIPLE PROGRESSION ===")
	print("==================================================================")
	
	# Execute Unit & Integration Systems 1 - 11
	_RunSectRegistryTests()
	_RunDiscipleRanksTests()
	_RunInitiationPackageTests()
	_RunContributionEconomyTests()
	_RunResourceDonationTests()
	_RunPromotionLifecycleTests()
	_RunSectExchangeTests()
	_RunTangKinhCacTests()
	_RunTuLinhTranTests()
	_RunLeaderboardTests()
	_RunSQLitePersistenceTests()

	# Start Live In-Process Server & Client for Systems 12 & 13
	print("\n[Integration] Starting offline in-process engine for live Sect gameplay...")
	NetworkCommons.IsLocal = true
	Launcher.Mode(true, true)

# ==============================================================================
# SYSTEM 1: SECT REGISTRY & D-03 CANON COMPLIANCE
# ==============================================================================
func _RunSectRegistryTests():
	print("\n--- [SYSTEM 1: SECT REGISTRY & D-03 CANON COMPLIANCE] ---")
	assert(SectSystemClass.SECT_REGISTRY.has(SectSystemClass.DEFAULT_SECT_ID), "Registry must contain default sect")
	var sect = SectSystemClass.SECT_REGISTRY[SectSystemClass.DEFAULT_SECT_ID]
	
	assert(sect["id"] == 995840901, "Sect ID must match SacredSectHub hash 995840901")
	assert(sect["display_name"] == "Trúc Sơn Tông", "Display name: Trúc Sơn Tông")
	assert(sect["canon_status"].contains("D-03"), "Must strictly record D-03 pending status")
	assert(sect.has("treasury"), "Must have treasury storage")
	assert(sect["treasury"]["spirit_stones"] > 0, "Treasury must contain spirit stones")
	assert(sect["treasury"]["herbs"] > 0, "Treasury must contain herbs")
	print("  ✔ Tông Môn: %s (ID: %d)" % [sect["display_name"], sect["id"]])
	print("  ✔ Canon Status: %s" % sect["canon_status"])
	print("  ✔ Kho Tài Nguyên: %d Linh Thạch, %d Linh Thảo, %d Linh Khoáng" % [
		sect["treasury"]["spirit_stones"], sect["treasury"]["herbs"], sect["treasury"]["ores"]
	])
	test_results["system1_sect_registry"] = true
	print("[PASS] System 1: Sect registry verified!")

# ==============================================================================
# SYSTEM 2: DISCIPLE RANKS & METADATA
# ==============================================================================
func _RunDiscipleRanksTests():
	print("\n--- [SYSTEM 2: DISCIPLE RANKS & METADATA] ---")
	var ranks = [
		SectSystemClass.DiscipleRank.NONE,
		SectSystemClass.DiscipleRank.TAP_DICH,
		SectSystemClass.DiscipleRank.NGOAI_MON,
		SectSystemClass.DiscipleRank.NOI_MON,
		SectSystemClass.DiscipleRank.CHAN_TRUYEN,
		SectSystemClass.DiscipleRank.THAN_TRUYEN
	]
	for r in ranks:
		assert(SectSystemClass.RANK_METADATA.has(r), "Metadata must exist for rank %d" % r)
		var meta = SectSystemClass.RANK_METADATA[r]
		assert(not meta["name"].is_empty(), "Rank name must not be empty")
		assert(not meta["title"].is_empty(), "Rank title must not be empty")
		print("  ✔ Bậc %d: [%s] • Danh hiệu: %s • Yêu cầu: Cấp %d (%s), %d Cống Hiến" % [
			r, meta["name"], meta["title"], meta["reqRealmLevel"], meta["reqRealmName"], meta["reqContribution"]
		])
	test_results["system2_disciple_ranks"] = true
	print("[PASS] System 2: Disciple rank hierarchy verified!")

# ==============================================================================
# SYSTEM 3: INITIATION PACKAGE & TOKENS
# ==============================================================================
func _RunInitiationPackageTests():
	print("\n--- [SYSTEM 3: INITIATION PACKAGE & TOKENS] ---")
	var tokenFiles = [
		"TapDichLenhBai",
		"NgoaiMonLenhBai",
		"NoiMonLenhBai",
		"ChanTruyenLenhBai"
	]
	for tFile in tokenFiles:
		var itemCell = load("res://presets/cells/items/neck/%s.tres" % tFile)
		assert(itemCell != null, "Item cell must exist for %s" % tFile)
		assert(itemCell.slot == 5, "Identity token must equip in accessory slot 5")
		assert(itemCell.modifiers.HasAny(), "Identity token must provide stat bonuses")
		print("  ✔ Lệnh Bài: %s (Slot: %d, Giá mua: %d)" % [itemCell.name, itemCell.slot, itemCell.buyPrice])
	test_results["system3_initiation_package"] = true
	print("[PASS] System 3: Initiation package & tokens verified!")

# ==============================================================================
# SYSTEM 4: SECT CONTRIBUTION ECONOMY
# ==============================================================================
func _RunContributionEconomyTests():
	print("\n--- [SYSTEM 4: SECT CONTRIBUTION ECONOMY] ---")
	var dummyNode = Node.new()
	add_child(dummyNode)

	# Initial contribution
	assert(SectSystemClass.GetContribution(dummyNode) == 0, "Initial contribution must be 0")
	
	# Add contribution
	SectSystemClass.AddContribution(dummyNode, 150, "Hoàn thành nhiệm vụ")
	assert(SectSystemClass.GetContribution(dummyNode) == 150, "Contribution must equal 150")
	assert(SectSystemClass.GetTotalContribution(dummyNode) == 150, "Total contribution must equal 150")
	print("  ✔ Nhận Cống Hiến: 0 -> 150 (+150)")

	# Spend valid contribution
	var spendOk = SectSystemClass.SpendContribution(dummyNode, 50, "Đổi đan dược")
	assert(spendOk == true, "Must spend contribution successfully")
	assert(SectSystemClass.GetContribution(dummyNode) == 100, "Remaining contribution must be 100")
	assert(SectSystemClass.GetTotalContribution(dummyNode) == 150, "Total contribution must preserve historical earnings")
	print("  ✔ Tiêu Hao Cống Hiến: 150 -> 100 (-50)")

	# Reject overdraft
	var overdraftOk = SectSystemClass.SpendContribution(dummyNode, 500, "Vượt quá số dư")
	assert(overdraftOk == false, "Must reject transaction when balance insufficient")
	assert(SectSystemClass.GetContribution(dummyNode) == 100, "Balance must remain unchanged after rejected transaction")
	print("  ✔ Chống thâm hụt: Giao dịch 500/100 bị từ chối chính xác")

	dummyNode.queue_free()
	test_results["system4_contribution_economy"] = true
	print("[PASS] System 4: Contribution economy verified!")

# ==============================================================================
# SYSTEM 5: RESOURCE DONATION & TREASURY
# ==============================================================================
func _RunResourceDonationTests():
	print("\n--- [SYSTEM 5: RESOURCE DONATION & TREASURY] ---")
	assert(SectSystemClass.GetDonationValue("Ngan Linh Thao") == 15, "Ngân Linh Thảo value must be 15")
	assert(SectSystemClass.GetDonationValue("Huyen Thiet Khoang") == 20, "Huyền Thiết Khoáng value must be 20")
	assert(SectSystemClass.GetDonationValue("Slime") == 10, "Slime value must be 10")
	assert(SectSystemClass.GetDonationValue("Thanh Phong Tinh Thiet") == 35, "Tinh Thiết value must be 35")
	print("  ✔ Giá trị cống hiến nguyên liệu: Linh Thảo=15, Khoáng Thạch=20, Tinh Thiết=35")
	test_results["system5_resource_donation"] = true
	print("[PASS] System 5: Resource donation rates verified!")

# ==============================================================================
# SYSTEM 6: DISCIPLE PROMOTION LIFECYCLE
# ==============================================================================
func _RunPromotionLifecycleTests():
	print("\n--- [SYSTEM 6: DISCIPLE PROMOTION LIFECYCLE] ---")
	var dummyNode = DummyAgent.new()
	add_child(dummyNode)

	# Initially NONE -> TAP_DICH
	SectSystemClass.SetDiscipleRank(dummyNode, SectSystemClass.DiscipleRank.TAP_DICH)
	assert(SectSystemClass.GetDiscipleRank(dummyNode) == SectSystemClass.DiscipleRank.TAP_DICH, "Must be Tạp Dịch")
	assert(SectSystemClass.HasFacilityAccess(dummyNode, SectSystemClass.Facility.MAIN_HALL), "Tạp dịch must access Main Hall")

	# Promotion to Ngoại Môn with low level & contribution -> Rejected
	var checkFail = SectSystemClass.CanPromote(dummyNode)
	assert(checkFail["canPromote"] == false, "Must reject promotion when conditions unmet")
	assert(checkFail["missingRealm"] == true, "Must flag missing realm")
	assert(checkFail["missingContribution"] == true, "Must flag missing contribution")

	# Meet conditions: Level 2 (Tụ Khí tầng 1) and 100 contribution
	dummyNode.stat["level"] = 2
	SectSystemClass.AddContribution(dummyNode, 100)
	var checkPass = SectSystemClass.CanPromote(dummyNode)
	assert(checkPass["canPromote"] == true, "Must approve promotion when conditions met")
	
	# Execute promotion
	var promoRes = SectSystemClass.PromoteDisciple(dummyNode)
	assert(promoRes["promoted"] == true, "Must execute promotion")
	assert(SectSystemClass.GetDiscipleRank(dummyNode) == SectSystemClass.DiscipleRank.NGOAI_MON, "Rank must be Ngoại Môn")
	assert(SectSystemClass.HasFacilityAccess(dummyNode, SectSystemClass.Facility.GATHERING_ARRAY), "Ngoại môn must access Tụ Linh Trận")
	assert(SectSystemClass.HasFacilityAccess(dummyNode, SectSystemClass.Facility.LIBRARY_T1), "Ngoại môn must access Tàng Kinh Các T1")
	print("  ✔ Tấn thăng Ngoại Môn Đệ Tử: Cấp 2, 100 Cống Hiến -> Thành công!")

	# Advance to Nội Môn
	dummyNode.stat["level"] = 6
	SectSystemClass.AddContribution(dummyNode, 400) # Total 500
	var checkInner = SectSystemClass.CanPromote(dummyNode)
	assert(checkInner["canPromote"] == true, "Must approve promotion to Nội Môn")
	SectSystemClass.PromoteDisciple(dummyNode)
	assert(SectSystemClass.GetDiscipleRank(dummyNode) == SectSystemClass.DiscipleRank.NOI_MON, "Rank must be Nội Môn")
	assert(SectSystemClass.HasFacilityAccess(dummyNode, SectSystemClass.Facility.LIBRARY_T2), "Nội môn must access Tàng Kinh Các T2")
	assert(SectSystemClass.HasFacilityAccess(dummyNode, SectSystemClass.Facility.FORGE), "Nội môn must access Luyện Khí Đường")
	assert(SectSystemClass.HasFacilityAccess(dummyNode, SectSystemClass.Facility.SECRET_REALM), "Nội môn must access Linh Khí Bí Cảnh")
	print("  ✔ Tấn thăng Nội Môn Đệ Tử: Cấp 6, 500 Cống Hiến -> Mở khóa Tàng Kinh Các T2 & Luyện Khí Đường!")

	dummyNode.queue_free()
	test_results["system6_promotion_lifecycle"] = true
	print("[PASS] System 6: Disciple promotion lifecycle verified!")

# ==============================================================================
# SYSTEM 7: SECT EXCHANGE (BÁCH BẢO CÁC)
# ==============================================================================
func _RunSectExchangeTests():
	print("\n--- [SYSTEM 7: SECT EXCHANGE (BÁCH BẢO CÁC)] ---")
	assert(SectSystemClass.EXCHANGE_CATALOG.size() >= 5, "Catalog must have at least 5 exchange items")
	for item in SectSystemClass.EXCHANGE_CATALOG:
		assert(item["cost"] > 0, "Cost must be > 0")
		assert(not item["name"].is_empty(), "Item name must not be empty")
		assert(not item["itemCell"].is_empty(), "ItemCell name must not be empty")
		print("  ✔ Vật phẩm đổi: [%s] (%s) - Giá: %d Cống Hiến, Yêu cầu: Bậc %d" % [
			item["name"], item["category"], item["cost"], item["reqRank"]
		])
	test_results["system7_sect_exchange"] = true
	print("[PASS] System 7: Sect Exchange catalog verified!")

# ==============================================================================
# SYSTEM 8: TÀNG KINH CÁC (MARTIAL SCRIPTURES)
# ==============================================================================
func _RunTangKinhCacTests():
	print("\n--- [SYSTEM 8: TÀNG KINH CÁC (MARTIAL SCRIPTURES)] ---")
	assert(SectSystemClass.SCRIPTURE_CATALOG.size() >= 5, "Scripture catalog must have at least 5 martial arts")
	for sc in SectSystemClass.SCRIPTURE_CATALOG:
		assert(not sc["name"].is_empty(), "Scripture name must not be empty")
		assert(not sc["category"].is_empty(), "Category must not be empty")
		print("  ✔ Bí tịch: [%s] (%s) - Cần Cấp %d, Bậc %d, %d Cống Hiến" % [
			sc["name"], sc["category"], sc["reqRealm"], sc["reqRank"], sc["cost"]
		])
	test_results["system8_tang_kinh_cac"] = true
	print("[PASS] System 8: Scripture Pavilion catalog verified!")

# ==============================================================================
# SYSTEM 9: TỤ LINH TRẬN ACCELERATED CULTIVATION
# ==============================================================================
func _RunTuLinhTranTests():
	print("\n--- [SYSTEM 9: TỤ LINH TRẬN ACCELERATED CULTIVATION] ---")
	var dummyNode = Node.new()
	add_child(dummyNode)
	
	# Tap dich denied
	SectSystemClass.SetDiscipleRank(dummyNode, SectSystemClass.DiscipleRank.TAP_DICH)
	assert(not SectSystemClass.HasFacilityAccess(dummyNode, SectSystemClass.Facility.GATHERING_ARRAY), "Tạp dịch denied access")
	
	# Ngoai mon granted
	SectSystemClass.SetDiscipleRank(dummyNode, SectSystemClass.DiscipleRank.NGOAI_MON)
	assert(SectSystemClass.HasFacilityAccess(dummyNode, SectSystemClass.Facility.GATHERING_ARRAY), "Ngoại môn granted access")
	print("  ✔ Tụ Linh Trận quyền hạn: Tạp Dịch = Từ chối, Ngoại Môn = Cho phép")

	dummyNode.queue_free()
	test_results["system9_tu_linh_tran"] = true
	print("[PASS] System 9: Spirit Gathering Array access verified!")

# ==============================================================================
# SYSTEM 10: SECT RANKING / LEADERBOARD
# ==============================================================================
func _RunLeaderboardTests():
	print("\n--- [SYSTEM 10: SECT RANKING / LEADERBOARD] ---")
	var board = SectSystemClass.GetLeaderboard()
	assert(board.size() >= 5, "Leaderboard must contain simulated disciple peers")
	for entry in board:
		assert(entry.has("name"), "Entry must have name")
		assert(entry.has("contribution"), "Entry must have contribution")
		assert(entry.has("label"), "Entry must have label")
		assert(entry["label"] == "[Đồng Môn NPC]", "Simulated peers must carry explicit [Đồng Môn NPC] label")
	print("  ✔ Top 1: %s (%s, %d Cống Hiến, Cảnh giới: %s) %s" % [
		board[0]["name"], board[0]["title"], board[0]["contribution"], board[0]["realm"], board[0]["label"]
	])
	print("  ✔ Top 2: %s (%s, %d Cống Hiến) %s" % [
		board[1]["name"], board[1]["title"], board[1]["contribution"], board[1]["label"]
	])
	test_results["system10_leaderboard"] = true
	print("[PASS] System 10: Sect Leaderboard verified!")

# ==============================================================================
# SYSTEM 11: SQLITE PERSISTENCE
# ==============================================================================
func _RunSQLitePersistenceTests():
	print("\n--- [SYSTEM 11: SQLITE PERSISTENCE & ROUND-TRIP] ---")
	var dbPath = SQLCommons.GetDBPath()
	var db = SQLite.new()
	db.path = dbPath
	assert(db.open_db(), "Failed to open SQLite database")

	assert(SectSystemClass.EnsureSectTables(db) == true, "Must ensure sect tables")
	
	var charId : int = 7777
	var testData : Dictionary = {
		"sect_id": SectSystemClass.DEFAULT_SECT_ID,
		"rank": SectSystemClass.DiscipleRank.NOI_MON,
		"contribution": 320,
		"total_contribution": 720,
		"facilities": 255,
		"joined_time": 1700000000
	}
	
	assert(SectSystemClass.SaveSectData(db, charId, testData) == true, "Must save sect data")
	var loaded = SectSystemClass.LoadSectData(db, charId)
	assert(not loaded.is_empty(), "Must load saved sect data")
	assert(loaded["rank"] == SectSystemClass.DiscipleRank.NOI_MON, "Loaded rank must match")
	assert(loaded["contribution"] == 320, "Loaded contribution must match")
	assert(loaded["total_contribution"] == 720, "Loaded total contribution must match")
	print("  ✔ SQLite Đã lưu & Tải: CharID=%d, Thân phận=%d, Cống Hiến=%d, Tổng=%d" % [
		charId, loaded["rank"], loaded["contribution"], loaded["total_contribution"]
	])

	db.close_db()
	test_results["system11_sqlite_persistence"] = true
	print("[PASS] System 11: SQLite Sect persistence verified!")

# ==============================================================================
# LIVE ENGINE GAMEPLAY PROCESS LOOP (SYSTEMS 12 & 13)
# ==============================================================================
func _process(delta : float):
	timer += delta

	# Step 1: Wait for client/server offline dispatch at 1.0s
	if timer > 1.0 and step == 0 and Network.clientConnected:
		step = 1
		print("\n[Step 1 PASS] Connected via in-process offline dispatch!")
		test_results["live_step1_connected"] = true
		print("[Step 2] Logging in with account: DeTuTrucSonB6")
		Network.LoginWithPassword("DeTuTrucSonB6", "matkhau123", false)

	# Step 2: Create character at 3.5s
	if timer > 3.5 and step == 1:
		step = 2
		charNick = "DeTuB6_%d" % (randi() % 9000 + 1000)
		print("[Step 2 PASS] Logged in! Creating character: %s" % charNick)
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
		Network.CreateCharacter(charNick, traits, attrs)

	# Step 3: Connect character at 5.5s
	if timer > 5.5 and step == 2:
		step = 3
		print("[Step 3] Connecting character: %s" % charNick)
		Network.ConnectCharacter(charNick)

	# Step 4: Verify Character Spawn & Sect Progression at 8.0s
	if timer > 8.0 and step == 3:
		step = 4
		var player = GetServerPlayer()
		assert(player != null, "Player must spawn in world")
		test_results["live_step2_login"] = true
		test_results["live_step3_spawn"] = true
		print("[Step 3 PASS] Player spawned! Nick: %s" % player.nick)

		# Live Sect Initiation
		print("\n--- [LIVE SYSTEM 12: IN-GAME SECT RECRUITMENT & PROGRESSION] ---")
		SectSystemClass.SetDiscipleRank(player, SectSystemClass.DiscipleRank.TAP_DICH)
		SectSystemClass.AddContribution(player, 50, "Bái nhập Trúc Sơn")
		assert(SectSystemClass.GetDiscipleRank(player) == SectSystemClass.DiscipleRank.TAP_DICH, "Must be Tạp Dịch")
		assert(SectSystemClass.GetContribution(player) == 50, "Contribution must equal 50")
		print("  ✔ Gia nhập sơn môn thành công! Thân phận: [Tạp Dịch Đệ Tử], Cống hiến: 50")

		# Add tokens to inventory
		var tokenCell = DB.GetItem(DB.GetCellHash("Tap Dich Lenh Bai"))
		assert(tokenCell != null, "Token cell must exist")
		player.inventory.AddItem(tokenCell, 1)
		print("  ✔ Đã nhận [Tạp Dịch Lệnh Bài] vào Túi Trữ Vật!")

		# Advance to Ngoại Môn
		player.stat.level = 2
		SectSystemClass.AddContribution(player, 60) # Total 110
		var check = SectSystemClass.CanPromote(player)
		assert(check["canPromote"] == true, "Must be able to promote to Ngoại Môn")
		SectSystemClass.PromoteDisciple(player)
		assert(SectSystemClass.GetDiscipleRank(player) == SectSystemClass.DiscipleRank.NGOAI_MON, "Must be Ngoại Môn")
		print("  ✔ Khảo hạch thành công! Tấn thăng: [Ngoại Môn Đệ Tử]!")

		test_results["live_step4_sect_progression"] = true

	# Step 5: Test Sect Window UI at 10.5s
	if timer > 10.5 and step == 4:
		step = 5
		print("\n--- [LIVE SYSTEM 13: SECT WINDOW UI VALIDATION] ---")
		var player = GetServerPlayer()
		assert(player != null, "Player must exist")
		sectWindowInstance = SectWindowClass.new()
		add_child(sectWindowInstance)
		sectWindowInstance._ready()
		sectWindowInstance.Refresh(player)

		assert(sectWindowInstance.tabContainer != null, "TabContainer must exist")
		assert(sectWindowInstance.tabContainer.get_tab_count() == 6, "Must contain exactly 6 sect tabs")
		assert(sectWindowInstance.rankLabel != null, "Rank label must exist")
		assert(sectWindowInstance.rankLabel.text.contains("Ngoại Môn"), "Rank label must display Ngoại Môn")
		assert(sectWindowInstance.contribLabel.text.contains("110"), "Contrib label must display 110")
		print("  ✔ SectWindow UI: 6/6 Tabs verified!")
		print("  ✔ Thân phận hiển thị trên UI: %s" % sectWindowInstance.rankLabel.text)
		print("  ✔ Cống hiến hiển thị trên UI: %s" % sectWindowInstance.contribLabel.text)

		test_results["live_step5_sect_window_ui"] = true

	# Step 6: Final Quality Gate Assessment at 12.5s
	if timer > 12.5 and step == 5:
		step = 6
		print("\n==================================================================")
		print("=== TDNM BUILD 06: ALL SECT SYSTEMS EMPIRICALLY VERIFIED ===")
		print("==================================================================")
		var allPassed : bool = true
		for k in test_results:
			var s : String = "PASS" if test_results[k] else "FAIL"
			print("  ✔ %s: %s" % [k, s])
			if not test_results[k]:
				allPassed = false

		assert(allPassed, "All test cases must pass")
		print("\nAll automated assertions PASSED with 0 errors!")
		print("Exiting test suite successfully.")
		
		if sectWindowInstance:
			sectWindowInstance.queue_free()
		get_tree().quit(0)
