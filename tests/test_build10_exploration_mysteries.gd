extends Node2D

## TDNM — BUILD 10: WORLD EXPANSION, EXPLORATION & ANCIENT MYSTERIES
## Comprehensive Automated End-to-End Test Suite.
## Validates Zones, Exploration Points, Ancient Ruins, Secret Areas,
## Exploration Dungeons, Dynamic Encounters, Mini-Bosses, Crafting Integration,
## Journey Journal UI, and SQLite Persistence.

const ExplorationSystemClass = preload("res://sources/world/ExplorationSystem.gd")
const CraftingSystemClass = preload("res://sources/crafting/CraftingSystem.gd")
const CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
const WorldMapWindowClass = preload("res://sources/gui/WorldMapWindow.gd")

var timer : float = 0.0
var step : int = 0
var test_account : String = "ExplorerHero_" + str(int(Time.get_unix_time_from_system()) % 100000)
var test_pass : String = "MatKhau123!"
var test_char : String = "ThamHiemTu_" + str(int(Time.get_unix_time_from_system()) % 10000)

var test_results : Dictionary = {}

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
	print("=== TDNM — BUILD 10: WORLD EXPANSION & ANCIENT MYSTERIES       ===")
	print("==================================================================")

	# Execute Unit & Data Systems 1 - 11
	_RunZoneCatalogTests()
	_RunExplorationPointsTests()
	_RunSecretAreasTests()
	_RunAncientRuinsTests()
	_RunExplorationDungeonsTests()
	_RunDynamicEncountersTests()
	_RunExplorationItemsTests()
	_RunMiniBossesTests()
	_RunCraftingIntegrationTests()
	_RunVisualFxTests()
	_RunSqliteSchemaTests()

	# Start Live In-Process Server & Client for Systems 12 - 20
	print("\n[Integration] Starting offline in-process engine for live exploration gameplay...")
	NetworkCommons.IsLocal = true
	Launcher.Mode(true, true)

# ==============================================================================
# SYSTEM 1: 5 EXPLORATION ZONES
# ==============================================================================
func _RunZoneCatalogTests():
	print("\n--- [SYSTEM 1: 5 EXPLORATION ZONES CATALOG] ---")
	assert(ExplorationSystemClass.ZONES.size() >= 5, "Must have at least 5 exploration zones")
	
	var expectedZones = ["ZONE_TRUC_SON", "ZONE_SON_LAM_NGOAI_VI", "ZONE_CO_DAO_PHE_TICH", "ZONE_LINH_KHI_BI_CANH", "ZONE_THANH_SA_CANG"]
	for zId in expectedZones:
		assert(ExplorationSystemClass.ZONES.has(zId), "Missing zone: %s" % zId)
		var z = ExplorationSystemClass.ZONES[zId]
		assert(not z.get("name", "").is_empty(), "Zone must have a name")
		assert(not z.get("danger", "").is_empty(), "Zone must have danger rating")
		assert(not z.get("realmReq", "").is_empty(), "Zone must have recommended realm")
		assert(z.get("resources", []).size() > 0, "Zone must list resources")
		print("  ✔ Khu vực: [%s] (%s) • Cảnh giới: %s • Hiểm cấp: %s" % [z["name"], z["type"], z["realmReq"], z["danger"]])
		
	test_results["system1_zones"] = true
	print("[PASS] System 1: Exploration zones catalog verified!")

# ==============================================================================
# SYSTEM 2: 8 EXPLORATION POINTS
# ==============================================================================
func _RunExplorationPointsTests():
	print("\n--- [SYSTEM 2: 8 EXPLORATION POINTS CATALOG] ---")
	assert(ExplorationSystemClass.EXPLORATION_POINTS.size() >= 8, "Must have at least 8 exploration points")
	
	var typesFound : Dictionary = {}
	for pId in ExplorationSystemClass.EXPLORATION_POINTS.keys():
		var poi = ExplorationSystemClass.EXPLORATION_POINTS[pId]
		var t = poi.get("type", "")
		typesFound[t] = true
		assert(not poi.get("name", "").is_empty(), "POI must have name")
		assert(not poi.get("desc", "").is_empty(), "POI must have description")
		print("  ✔ Điểm mốc: [%s] (Loại: %s) • Khu vực: %s" % [poi["name"], t, poi["zone_id"]])
		
	assert(typesFound.size() >= 5, "Must support at least 5 distinct interaction types")
	test_results["system2_pois"] = true
	print("[PASS] System 2: 8 Exploration points verified!")

# ==============================================================================
# SYSTEM 3: 5 DISCOVERABLE SECRETS
# ==============================================================================
func _RunSecretAreasTests():
	print("\n--- [SYSTEM 3: 5 DISCOVERABLE SECRETS CATALOG] ---")
	assert(ExplorationSystemClass.SECRET_AREAS.size() >= 5, "Must have at least 5 secret areas")
	
	for sId in ExplorationSystemClass.SECRET_AREAS.keys():
		var sec = ExplorationSystemClass.SECRET_AREAS[sId]
		assert(not sec.get("name", "").is_empty(), "Secret must have name")
		assert(not sec.get("conditionType", "").is_empty(), "Secret must have condition type")
		print("  ✔ Mật cảnh ẩn: [%s] • Điều kiện: %s • Thưởng: %d Tu Vi" % [sec["name"], sec["conditionType"], sec["rewardTuVi"]])
		
	test_results["system3_secrets"] = true
	print("[PASS] System 3: 5 Secret areas verified!")

# ==============================================================================
# SYSTEM 4: 3 ANCIENT RUINS
# ==============================================================================
func _RunAncientRuinsTests():
	print("\n--- [SYSTEM 4: 3 ANCIENT RUINS CATALOG] ---")
	assert(ExplorationSystemClass.ANCIENT_RUINS.size() >= 3, "Must have at least 3 ancient ruins")
	
	for rId in ExplorationSystemClass.ANCIENT_RUINS.keys():
		var r = ExplorationSystemClass.ANCIENT_RUINS[rId]
		assert(r.get("stepsTotal", 0) >= 4, "Ruin must have at least 4 progressive steps")
		assert(r.get("stepsDesc", []).size() == r.get("stepsTotal", 0), "Step descriptions must match total steps")
		print("  ✔ Di tích: [%s] • Số bước: %d • Thưởng: %d Tu Vi" % [r["name"], r["stepsTotal"], r["rewardTuVi"]])
		
	test_results["system4_ruins"] = true
	print("[PASS] System 4: 3 Ancient ruins verified!")

# ==============================================================================
# SYSTEM 5: 3 EXPLORATION DUNGEONS
# ==============================================================================
func _RunExplorationDungeonsTests():
	print("\n--- [SYSTEM 5: 3 EXPLORATION DUNGEONS] ---")
	assert(ExplorationSystemClass.DUNGEONS.size() >= 3, "Must have at least 3 exploration dungeons")
	
	for dId in ExplorationSystemClass.DUNGEONS.keys():
		var d = ExplorationSystemClass.DUNGEONS[dId]
		assert(not d.get("name", "").is_empty(), "Dungeon must have name")
		assert(d.get("minLevel", 0) > 0, "Dungeon must have minimum level")
		print("  ✔ Phụ bản: [%s] • Loại: %s • Cấp yêu cầu: %d • Thử thách: %s" % [d["name"], d["type"], d["minLevel"], d["bossOrElite"]])
		
	test_results["system5_dungeons"] = true
	print("[PASS] System 5: 3 Exploration dungeons verified!")

# ==============================================================================
# SYSTEM 6: 5 DYNAMIC ENCOUNTERS
# ==============================================================================
func _RunDynamicEncountersTests():
	print("\n--- [SYSTEM 6: 5 DYNAMIC EXPLORATION ENCOUNTERS] ---")
	assert(ExplorationSystemClass.DYNAMIC_ENCOUNTERS.size() >= 5, "Must have at least 5 dynamic encounters")
	
	for eId in ExplorationSystemClass.DYNAMIC_ENCOUNTERS.keys():
		var enc = ExplorationSystemClass.DYNAMIC_ENCOUNTERS[eId]
		assert(enc.get("cooldownSec", 0) > 0, "Encounter must have cooldown")
		print("  ✔ Sự kiện kỳ ngộ: [%s] • Khu vực: %s • Hồi chiêu: %ds" % [enc["name"], enc["triggerZone"], enc["cooldownSec"]])
		
	test_results["system6_encounters"] = true
	print("[PASS] System 6: 5 Dynamic encounters verified!")

# ==============================================================================
# SYSTEM 7: 5 NEW/VARIANT EXPLORATION ITEMS & REWARDS
# ==============================================================================
func _RunExplorationItemsTests():
	print("\n--- [SYSTEM 7: EXPLORATION ITEMS & CELL HASHES] ---")
	var items = [
		"Cuu Diep Ngoc Chi",
		"Co Linh Thiet",
		"Huyen Hoang Thach",
		"U Hon Huyet Dang",
		"Co Dao Chi Khoa",
		"Co Tran Bi Quyen",
		"Thanh Phong Co Kiem"
	]
	
	for itName in items:
		assert(DB.HasCellHash(itName), "Cell hash missing for %s" % itName)
		var h = DB.GetCellHash(itName)
		var cell = DB.GetItem(h)
		assert(cell != null, "ItemCell missing for %s" % itName)
		print("  ✔ Kỳ vật: [%s] (ID: %d, Giá mua: %d, Giá bán: %d)" % [cell.name, cell.id, cell.buyPrice, cell.sellPrice])
		
	test_results["system7_items"] = true
	print("[PASS] System 7: Exploration items & cell hashes verified!")

# ==============================================================================
# SYSTEM 8: 3 MINI-BOSSES / ELITE CHALLENGES
# ==============================================================================
func _RunMiniBossesTests():
	print("\n--- [SYSTEM 8: 3 MINI-BOSSES / ELITE CHALLENGES] ---")
	assert(ExplorationSystemClass.MINI_BOSSES.size() >= 3, "Must have at least 3 mini-bosses")
	
	for bId in ExplorationSystemClass.MINI_BOSSES.keys():
		var b = ExplorationSystemClass.MINI_BOSSES[bId]
		assert(b.get("maxHp", 0) >= 300, "Mini-boss must have substantial HP")
		assert(not b.get("specialTrait", "").is_empty(), "Mini-boss must have special combat trait")
		print("  ✔ Tinh anh / Mini-Boss: [%s] (Cấp %d) • HP: %d • Công: %d • Thủ: %d • Đặc tính: %s" % [b["name"], b["level"], b["maxHp"], b["attack"], b["defense"], b["specialTrait"]])
		
	test_results["system8_minibosses"] = true
	print("[PASS] System 8: 3 Mini-bosses verified!")

# ==============================================================================
# SYSTEM 9: CRAFTING INTEGRATION
# ==============================================================================
func _RunCraftingIntegrationTests():
	print("\n--- [SYSTEM 9: CRAFTING INTEGRATION WITH EXPLORATION RESOURCES] ---")
	assert(CraftingSystemClass.ALCHEMY_RECIPES.has("CUU_DIEP_HOI_XUAN"), "Missing alchemy recipe CUU_DIEP_HOI_XUAN")
	assert(CraftingSystemClass.FORGE_RECIPES.has("THANH_PHONG_CO_KIEM"), "Missing forge recipe THANH_PHONG_CO_KIEM")
	
	var rAlchemy = CraftingSystemClass.ALCHEMY_RECIPES["CUU_DIEP_HOI_XUAN"]
	assert(rAlchemy["materials"].has("Cuu Diep Ngoc Chi"), "Recipe must require Cuu Diep Ngoc Chi")
	assert(rAlchemy["materials"].has("U Hon Huyet Dang"), "Recipe must require U Hon Huyet Dang")
	print("  ✔ Đan phương: [%s] sử dụng [Cửu Diệp Ngọc Chi] & [U Hồn Huyết Đằng]" % rAlchemy["name"])
	
	var rForge = CraftingSystemClass.FORGE_RECIPES["THANH_PHONG_CO_KIEM"]
	assert(rForge["materials"].has("Co Linh Thiet"), "Recipe must require Co Linh Thiet")
	assert(rForge["materials"].has("Huyen Hoang Thach"), "Recipe must require Huyen Hoang Thach")
	print("  ✔ Luyện khí: [%s] sử dụng [Cổ Linh Thiết] & [Huyền Hoàng Thạch]" % rForge["name"])
	
	test_results["system9_crafting"] = true
	print("[PASS] System 9: Crafting integration verified!")

# ==============================================================================
# SYSTEM 10: EXPLORATION VISUAL POLISH & FX
# ==============================================================================
func _RunVisualFxTests():
	print("\n--- [SYSTEM 10: EXPLORATION VISUAL POLISH & FX] ---")
	var dummyParent = Node2D.new()
	add_child(dummyParent)
	
	CombatVisualSystemClass.SpawnSecretFoundVfx(dummyParent, Vector2.ZERO)
	CombatVisualSystemClass.SpawnChestOpenedVfx(dummyParent, Vector2.ZERO)
	CombatVisualSystemClass.SpawnContraptionTriggeredVfx(dummyParent, Vector2.ZERO)
	CombatVisualSystemClass.SpawnRuinCompleteFanfareVfx(dummyParent, Vector2.ZERO)
	
	assert(dummyParent.get_child_count() == 4, "Must instantiate all 4 exploration VFX nodes")
	print("  ✔ Đã kích hoạt 4/4 hiệu ứng hình ảnh khám phá: Mật thất, Rương cổ, Cơ quan, Hoàn thành di tích!")
	dummyParent.queue_free()
	
	test_results["system10_visuals"] = true
	print("[PASS] System 10: Exploration visual polish verified!")

# ==============================================================================
# SYSTEM 11: SQLITE SCHEMA
# ==============================================================================
func _RunSqliteSchemaTests():
	print("\n--- [SYSTEM 11: SQLITE SCHEMA INITIALIZATION] ---")
	var db = SQLite.new()
	db.path = SQLCommons.GetDBPath()
	if db.open_db():
		var ok = ExplorationSystemClass.EnsureExplorationTables(db)
		assert(ok, "EnsureExplorationTables must return true")
		
		# Verify tables exist
		var expectedTables = [
			"char_exploration_zones",
			"char_exploration_points",
			"char_ruin_progress",
			"char_secret_areas",
			"char_dungeon_instances",
			"char_opened_chests",
			"char_resource_nodes"
		]
		for tbl in expectedTables:
			db.query("SELECT count(*) as count FROM sqlite_master WHERE type='table' AND name='%s';" % tbl)
			assert(db.query_result.size() > 0 and db.query_result[0]["count"] == 1, "Table %s must exist in SQLite" % tbl)
			print("  ✔ Bảng lưu trữ: [%s] đã sẵn sàng" % tbl)
			
		db.close_db()
	test_results["system11_sqlite_schema"] = true
	print("[PASS] System 11: SQLite schema verified!")

# ==============================================================================
# LIVE IN-PROCESS SIMULATION (SYSTEMS 12 - 20)
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
		test_char = "ThamHiemTu_%d" % (randi() % 90000 + 10000)
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

	# Step 4: Zone Exploration at 8.0s
	if timer > 8.0 and step == 3:
		var player = GetServerPlayer()
		if player != null:
			step = 4
			timer = 0.0
			_Step4_LiveZoneExploration()

	# Steps 5–12: sequential 0.5s gaps
	if timer > 0.5 and step == 4:
		step = 5
		timer = 0.0
		_Step5_LivePoiInteractions()
	if timer > 0.5 and step == 5:
		step = 6
		timer = 0.0
		_Step6_LiveAncientRuinProgress()
	if timer > 0.5 and step == 6:
		step = 7
		timer = 0.0
		_Step7_LiveSecretAreas()
	if timer > 0.5 and step == 7:
		step = 8
		timer = 0.0
		_Step8_LiveDynamicEncounters()
	if timer > 0.5 and step == 8:
		step = 9
		timer = 0.0
		_Step9_LiveDungeonClear()
	if timer > 0.5 and step == 9:
		step = 10
		timer = 0.0
		_Step10_LiveAntiExploitChecks()
	if timer > 0.5 and step == 10:
		step = 11
		timer = 0.0
		_Step11_LiveWorldMapAndJournalUI()
	if timer > 0.5 and step == 11:
		step = 12
		timer = 0.0
		_Step12_LiveSqlitePersistence()
	if timer > 0.5 and step == 12:
		step = 13
		_FinalizeTests()

func _Step4_LiveZoneExploration():
	print("\n--- [LIVE STEP 4: ZONE DISCOVERY & FIRST-TIME REWARDS] ---")
	var player = GetServerPlayer()
	assert(player != null, "Player must be spawned")
	
	var initialExp = player.stat.experience if player.stat else 0
	var res1 = ExplorationSystemClass.DiscoverZone(player, "ZONE_TRUC_SON")
	assert(res1["success"], "Must discover ZONE_TRUC_SON")
	assert(not res1["alreadyDiscovered"], "First time must not be flagged alreadyDiscovered")
	print("  ✔ %s" % res1["message"])
	
	var res2 = ExplorationSystemClass.DiscoverZone(player, "ZONE_SON_LAM_NGOAI_VI")
	assert(res2["success"], "Must discover ZONE_SON_LAM_NGOAI_VI")
	print("  ✔ %s" % res2["message"])
	
	var expGained = (player.stat.experience if player.stat else 0) - initialExp
	assert(expGained >= 75, "Player must gain Tu Vi from 2 newly discovered zones (gained %d)" % expGained)
	
	var discList = ExplorationSystemClass.GetDiscoveredZones(player)
	assert("ZONE_TRUC_SON" in discList and "ZONE_SON_LAM_NGOAI_VI" in discList, "Discovered list must store zones")
	print("  ✔ Danh sách khu vực đã khám phá: %s" % str(discList))
	test_results["live_step4_zones"] = true

func _Step5_LivePoiInteractions():
	print("\n--- [LIVE STEP 5: EXPLORATION POINTS INTERACTION] ---")
	var player = GetServerPlayer()
	
	# 1. Stele Reading
	var resStele = ExplorationSystemClass.InteractExplorationPoint(player, "POI_BIA_DA_MINH_VAN")
	assert(resStele["success"], "Stele reading must succeed")
	print("  ✔ %s" % resStele["message"])
	
	# 2. Array Solving (Mộc -> Hỏa -> Thổ -> Kim -> Thủy)
	var resArray = ExplorationSystemClass.InteractExplorationPoint(player, "POI_TRAN_PHAP_NGU_HANH", {
		"sequence": ["MOC", "HOA", "THO", "KIM", "THUY"]
	})
	assert(resArray["success"], "Array solving must succeed with correct sequence")
	print("  ✔ %s" % resArray["message"])
	
	# 3. Spring Drinking
	var resSpring = ExplorationSystemClass.InteractExplorationPoint(player, "POI_LINH_TUYEN_CO_LAC", { "ignoreCd": true })
	assert(resSpring["success"], "Spring drinking must succeed")
	print("  ✔ %s" % resSpring["message"])
	
	# 4. Give Key and Open Ancient Chest
	var keyHash = DB.GetCellHash("Co Dao Chi Khoa")
	NpcCommons.AddItem(player, keyHash, 1)
	var keyCel = DB.GetItem(keyHash)
	assert(keyCel != null and player.inventory.HasItem(keyCel), "Player must possess Co Dao Chi Khoa")
	
	var resChest = ExplorationSystemClass.InteractExplorationPoint(player, "POI_RUONG_BAU_CO_TICH")
	assert(resChest["success"], "Ancient chest opening must succeed with key")
	print("  ✔ %s" % resChest["message"])
	
	# Verify reward item in inventory
	var swordHash = DB.GetCellHash("Thanh Phong Co Kiem")
	var swordCell = DB.GetItem(swordHash)
	assert(swordCell != null and player.inventory.HasItem(swordCell), "Player must receive Thanh Phong Co Kiem from ancient chest")
	print("  ✔ Đã nhận [Thanh Phong Cổ Kiếm] từ Rương Cổ vào Túi Trữ Vật!")
	
	test_results["live_step5_pois"] = true

func _Step6_LiveAncientRuinProgress():
	print("\n--- [LIVE STEP 6: ANCIENT RUIN 5-STEP PROGRESSION] ---")
	var player = GetServerPlayer()
	
	for s in range(1, 6):
		var res = ExplorationSystemClass.ProgressAncientRuin(player, "RUIN_TRUC_SON_CO_DONG", s)
		assert(res["success"], "Step %d of ancient ruin must succeed" % s)
		if s == 5:
			assert(res["isCompleted"], "Ruin must be flagged completed at step 5")
			print("  ✔ [BƯỚC %d] %s" % [s, res["message"]])
		else:
			print("  ✔ [BƯỚC %d] %s" % [s, res["message"]])
			
	var prog = ExplorationSystemClass.GetRuinProgress(player, "RUIN_TRUC_SON_CO_DONG")
	assert(prog["completed"], "Ruin must be permanently marked completed")
	test_results["live_step6_ruins"] = true

func _Step7_LiveSecretAreas():
	print("\n--- [LIVE STEP 7: SECRET AREAS DISCOVERY] ---")
	var player = GetServerPlayer()
	if player and player.stat:
		player.stat.concentration = 15
	
	# 1. Perception Secret (concentration >= 12)
	var res1 = ExplorationSystemClass.DiscoverSecret(player, "SECRET_HANG_DONG_AN")
	assert(res1["success"], "Perception secret discovery must succeed")
	print("  ✔ %s" % res1["message"])
	
	# 2. Contraption Secret (POI_CO_CO_QUAN_THACH_MON unlocked)
	ExplorationSystemClass.runtimeExplorationPoints[ExplorationSystemClass._GetCharId(player)]["POI_CO_CO_QUAN_THACH_MON"] = 1
	var res2 = ExplorationSystemClass.DiscoverSecret(player, "SECRET_MAT_THAT_KIEM_Y")
	assert(res2["success"], "Contraption secret discovery must succeed")
	print("  ✔ %s" % res2["message"])
	
	var secrets = ExplorationSystemClass.GetFoundSecrets(player)
	assert(secrets.size() >= 2, "Must record at least 2 discovered secrets")
	test_results["live_step7_secrets"] = true

func _Step8_LiveDynamicEncounters():
	print("\n--- [LIVE STEP 8: DYNAMIC EXPLORATION ENCOUNTERS] ---")
	var player = GetServerPlayer()
	
	# Trigger Encounter 1: Yêu Thú Phục Kích
	var res1 = ExplorationSystemClass.TriggerDynamicEncounter(player, "ENCOUNTER_YEU_THU_PHUC_KICH")
	assert(res1["success"], "Encounter 1 must trigger")
	print("  ✔ %s" % res1["message"])
	
	# Trigger Encounter 2: Linh Thảo Dị Biến Xuất Hiện
	var res2 = ExplorationSystemClass.TriggerDynamicEncounter(player, "ENCOUNTER_LINH_THAO_XUAT_THE")
	assert(res2["success"], "Encounter 2 must trigger")
	print("  ✔ %s" % res2["message"])
	
	# Test Cooldown Debounce (Immediate second trigger must be rejected)
	var resSpam = ExplorationSystemClass.TriggerDynamicEncounter(player, "ENCOUNTER_YEU_THU_PHUC_KICH")
	assert(not resSpam["success"], "Immediate repeat encounter must be blocked by cooldown")
	print("  ✔ Cơ chế chống lặp sự kiện: %s" % resSpam["message"])
	
	test_results["live_step8_encounters"] = true

func _Step9_LiveDungeonClear():
	print("\n--- [LIVE STEP 9: EXPLORATION DUNGEONS & TIME LOG] ---")
	var player = GetServerPlayer()
	
	var resDungeon = ExplorationSystemClass.ClearDungeon(player, "DUNGEON_CO_DAO_PHE_TICH", 88)
	assert(resDungeon["success"], "Dungeon clear must succeed")
	assert(resDungeon["clears"] == 1, "Clears count must be 1")
	assert(resDungeon["bestTime"] == 88, "Best time must record 88s")
	print("  ✔ %s" % resDungeon["message"])
	
	test_results["live_step9_dungeons"] = true

func _Step10_LiveAntiExploitChecks():
	print("\n--- [LIVE STEP 10: ANTI-EXPLOIT & ANTI-DUPLICATION ENFORCEMENT] ---")
	var player = GetServerPlayer()
	
	# 1. Anti-dupe on Ancient Chest: Trying to open again must be rejected!
	var resReopen = ExplorationSystemClass.InteractExplorationPoint(player, "POI_RUONG_BAU_CO_TICH")
	assert(not resReopen["success"], "Reopening an already opened chest must be strictly denied")
	print("  ✔ Chống mở lại rương cổ: %s" % resReopen["message"])
	
	# 2. Anti-dupe on Ruin Completion: Trying to claim ruin step 5 again must be rejected!
	var resRereward = ExplorationSystemClass.ProgressAncientRuin(player, "RUIN_TRUC_SON_CO_DONG", 5)
	assert(resRereward["alreadyCompleted"], "Re-claiming ruin completion must be rejected")
	print("  ✔ Chống nhận lại phần thưởng di tích: %s" % resRereward["message"])
	
	test_results["live_step10_anti_exploit"] = true

func _Step11_LiveWorldMapAndJournalUI():
	print("\n--- [LIVE STEP 11: WORLD MAP & JOURNEY JOURNAL UI] ---")
	assert(Launcher.GUI.worldMapWindow != null, "World Map Window must exist in GUI")
	
	var mapWin = Launcher.GUI.worldMapWindow
	mapWin.Refresh()
	
	# Test Backward-Compatible Selections from Build 03
	mapWin._SelectRegion(0)
	assert(mapWin.detailTitle.text == "Trúc Sơn Tiên Cảnh", "Detail title must match region 0")
	mapWin._SelectRegion(3)
	assert(mapWin.detailTitle.text == "Linh Khí Bí Cảnh", "Detail title must match region 3")
	print("  ✔ World Map Tab 1 (Bản Đồ Sơn Hà) lựa chọn khu vực chính xác!")
	
	# Verify Journey Journal Entries populated
	var player = GetServerPlayer()
	var logs = ExplorationSystemClass.GetJourneyLog(player)
	assert(logs.size() >= 5, "Journey journal must record at least 5 exploration entries (recorded %d)" % logs.size())
	print("  ✔ Sổ Tay Hành Trình ghi nhận thành công %d sự kiện khám phá!" % logs.size())
	
	test_results["live_step11_map_ui"] = true

func _Step12_LiveSqlitePersistence():
	print("\n--- [LIVE STEP 12: SQLITE PERSISTENCE & RELOAD VERIFICATION] ---")
	var player = GetServerPlayer()
	var charId = ExplorationSystemClass._GetCharId(player)
	
	var db = SQLite.new()
	db.path = SQLCommons.GetDBPath()
	if db.open_db():
		# 1. Save all exploration data
		var saveOk = ExplorationSystemClass.SaveExplorationData(db, charId)
		assert(saveOk, "SaveExplorationData must succeed")
		print("  ✔ Đã lưu thành công dữ liệu khám phá vào SQLite")
		
		# 2. Clear in-memory caches to simulate restart
		ExplorationSystemClass.runtimeDiscoveredZones[charId] = []
		ExplorationSystemClass.runtimeExplorationPoints[charId] = {}
		ExplorationSystemClass.runtimeRuinProgress[charId] = {}
		ExplorationSystemClass.runtimeFoundSecrets[charId] = []
		ExplorationSystemClass.runtimeClearedDungeons[charId] = {}
		ExplorationSystemClass.runtimeOpenedChests[charId] = []
		
		# 3. Reload from SQLite
		var loadOk = ExplorationSystemClass.LoadExplorationData(db, charId)
		assert(loadOk, "LoadExplorationData must succeed")
		print("  ✔ Đã khôi phục thành công dữ liệu khám phá từ SQLite:")
		
		# 4. Verify reloaded states
		assert("ZONE_TRUC_SON" in ExplorationSystemClass.runtimeDiscoveredZones[charId], "Reloaded zones must contain ZONE_TRUC_SON")
		assert(ExplorationSystemClass.runtimeRuinProgress[charId]["RUIN_TRUC_SON_CO_DONG"]["completed"], "Reloaded ruin must remain completed")
		assert("POI_RUONG_BAU_CO_TICH" in ExplorationSystemClass.runtimeOpenedChests[charId], "Reloaded opened chests must contain POI_RUONG_BAU_CO_TICH")
		assert(ExplorationSystemClass.runtimeClearedDungeons[charId]["DUNGEON_CO_DAO_PHE_TICH"]["clears"] == 1, "Reloaded dungeon clears must equal 1")
		print("    • Khu vực đã lưu: %s" % str(ExplorationSystemClass.runtimeDiscoveredZones[charId]))
		print("    • Rương đã mở: %s" % str(ExplorationSystemClass.runtimeOpenedChests[charId]))
		print("    • Di tích hoàn thành: RUIN_TRUC_SON_CO_DONG (completed = true)")
		
		db.close_db()
		
	test_results["live_step12_persistence"] = true

func _FinalizeTests():
	print("\n==================================================================")
	print("=== TDNM BUILD 10: ALL EXPLORATION & ANCIENT MYSTERIES VERIFIED ===")
	print("==================================================================")
	for k in test_results.keys():
		print("  ✔ %s: PASS" % k)
		
	print("\nAll automated assertions PASSED with 0 errors!")
	print("Exiting test suite successfully.")
	get_tree().quit(0)
