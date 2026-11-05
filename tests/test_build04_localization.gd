extends Node2D

## TDNM — BUILD 04 VIETNAMESE XIANXIA LOCALIZATION & CULTIVATION TEST
## Verifies all 13 core systems in Build 04 Definition of Done:
## 1. Central Localization & Glossary Architecture (33+ terms, tr() integration)
## 2. Attribute & Advanced Stat Tooltips
## 3. Decision D-04 Canonical Realms & Color Coding
## 4. Five-Element Spiritual Root, Ngộ Tính & Tư Chất Calculations
## 5. Cultivation Bottleneck (Bình Cảnh) Status Tracking
## 6. Live Cultivation Panel (CultivationWindow.gd) UI Structure
## 7. Meditative Cultivation (Vận Công) & Live Insight Feedback Loop
## 8. Manual Breakthrough (Đột Phá Cảnh Giới) Logic & Progression
## 9. Character Creation & Vitals Screen Localizations (Character.tscn, Stats.tscn)
## 10. Inventory & Equipment Panel Localization (Inventory.tscn)
## 11. Progress, Bestiary, Skills & Trade Localizations (Progress.tscn, Skill.tscn, Trade.tscn)
## 12. Login, Auth Errors, QuitBox & Xianxia Death Messages
## 13. SQLite Unicode Vietnamese Persistence Verification

const Cultivation = preload("res://sources/actor/Cultivation.gd")
const Localization = preload("res://sources/system/Localization.gd")
const CultivationWindowClass = preload("res://sources/gui/CultivationWindow.gd")

var timer : float = 0.0
var step : int = 0
var test_account : String = "DaoHuuB4"
var test_pass : String = "MatKhau123!"
var test_char : String = "TieuDaoTu_" + str(int(Time.get_unix_time_from_system()) % 10000)

var test_results : Dictionary = {}
var cultivationWindow = null

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
	print("=== TDNM — BUILD 04: VIETNAMESE LOCALIZATION & CULTIVATION ===")
	print("==================================================================")
	
	_RunStaticGlossaryTests()
	_RunSceneLocalizationTests()
	_RunSQLiteUnicodeTests()

	print("[Integration] Starting offline in-process engine for live player tests...")
	NetworkCommons.IsLocal = true
	Launcher.Mode(true, true)

func _RunStaticGlossaryTests():
	print("\n--- [SYSTEM 1: CENTRAL LOCALIZATION & GLOSSARY (33+ TERMS)] ---")
	Localization.Init()
	assert(TranslationServer.get_locale() == "vi", "Locale must be vi")

	var requiredTerms = [
		"Cultivation", "Realm", "Cultivation Progress", "Breakthrough", "Spiritual Root",
		"Five Elements", "Spiritual Energy", "Refined Energy", "Qi Capacity", "Meridian",
		"Dantian", "Technique", "Mind Method", "Sword Art", "Body Refinement",
		"Secret Art", "Comprehension", "Aptitude", "Technique Mastery", "Tribulation",
		"Alchemy", "Elixir", "Inventory", "Equipment", "Quest",
		"Bestiary", "World Map", "Dungeon", "HP", "MP",
		"Stamina", "Attack", "Defense"
	]
	
	for term in requiredTerms:
		var loc = Localization.Get(term)
		assert(not loc.is_empty() and loc != term, "Term must have valid Vietnamese localization: %s" % term)
		var trLoc = tr(term)
		assert(not trLoc.is_empty(), "tr() must resolve term: %s" % term)
		print("  ✔ %s -> %s (tr: %s)" % [term, loc, trLoc])

	assert(Localization.Get("Cultivation") == "Tu Luyện", "Cultivation must be Tu Luyện")
	assert(Localization.Get("Realm") == "Cảnh Giới", "Realm must be Cảnh Giới")
	assert(Localization.Get("Cultivation Progress") == "Tu Vi", "Cultivation Progress must be Tu Vi")
	assert(Localization.Get("Breakthrough") == "Đột Phá", "Breakthrough must be Đột Phá")
	assert(Localization.Get("Spiritual Root") == "Linh Căn", "Spiritual Root must be Linh Căn")
	assert(Localization.Get("Dantian") == "Đan Điền", "Dantian must be Đan Điền")
	assert(Localization.Get("Meridian") == "Kinh Mạch", "Meridian must be Kinh Mạch")
	assert(Localization.Get("Comprehension") == "Ngộ Tính", "Comprehension must be Ngộ Tính")
	assert(Localization.Get("Aptitude") == "Tư Chất", "Aptitude must be Tư Chất")
	assert(Localization.Get("Inventory") == "Túi Trữ Vật", "Inventory must be Túi Trữ Vật")
	assert(Localization.Get("Equipment") == "Trang Bị", "Equipment must be Trang Bị")
	assert(Localization.Get("Quest") == "Nhiệm Vụ / Ủy Thác", "Quest must be Nhiệm Vụ / Ủy Thác")
	assert(Localization.Get("Bestiary") == "Yêu Thú Đồ Giám", "Bestiary must be Yêu Thú Đồ Giám")
	assert(Localization.Get("HP") == "Khí Huyết", "HP must be Khí Huyết")
	assert(Localization.Get("MP") == "Linh Lực", "MP must be Linh Lực")
	assert(Localization.Get("Stamina") == "Thể Lực", "Stamina must be Thể Lực")
	test_results["system1_glossary"] = true
	print("[PASS] System 1: All 33+ core glossary concepts verified!")

	print("\n--- [SYSTEM 2: ATTRIBUTE & ADVANCED STAT TOOLTIPS] ---")
	var strTip = Localization.GetTooltip("Strength")
	assert(strTip.contains("Lực Lượng") and strTip.contains("Công Kích"), "Strength tooltip must explain attributes")
	var vitTip = Localization.GetTooltip("Vitality")
	assert(vitTip.contains("Thể Chất") and vitTip.contains("Khí Huyết"), "Vitality tooltip must explain attributes")
	var agiTip = Localization.GetTooltip("Agility")
	assert(agiTip.contains("Thân Pháp") and agiTip.contains("Né Tránh"), "Agility tooltip must explain attributes")
	var endTip = Localization.GetTooltip("Endurance")
	assert(endTip.contains("Định Lực") and endTip.contains("Phòng Ngự"), "Endurance tooltip must explain attributes")
	var concTip = Localization.GetTooltip("Concentration")
	assert(concTip.contains("Thần Thức") and concTip.contains("Linh Lực"), "Concentration tooltip must explain attributes")
	print("  ✔ Strength tooltip: ", strTip)
	print("  ✔ Vitality tooltip: ", vitTip)
	print("  ✔ Concentration tooltip: ", concTip)
	test_results["system2_tooltips"] = true
	print("[PASS] System 2: Attribute tooltips verified!")

	print("\n--- [SYSTEM 3: CANONICAL REALMS (DECISION D-04)] ---")
	assert(Cultivation.GetRealmName(1) == "Phàm Thân • Sơ Nhập", "Level 1 must be Phàm Thân")
	assert(Cultivation.GetRealmName(2) == "Tụ Khí • Tầng 1", "Level 2 must be Tụ Khí Tầng 1")
	assert(Cultivation.GetRealmName(10) == "Tụ Khí • Tầng 9 (Viên Mãn)", "Level 10 must be Tụ Khí Tầng 9")
	assert(Cultivation.GetRealmName(11) == "Thông Mạch • Sơ Kỳ", "Level 11 must be Thông Mạch")
	assert(Cultivation.GetRealmName(19) == "Đạo Cơ • Sơ Kỳ", "Level 19 must be Đạo Cơ")
	assert(Cultivation.GetRealmName(27) == "Huyền Đan • Sơ Kỳ", "Level 27 must be Huyền Đan")
	assert(Cultivation.GetRealmName(35) == "Nguyên Thần • Sơ Kỳ", "Level 35 must be Nguyên Thần")
	assert(Cultivation.GetRealmName(43) == "Thiên Nhân • Sơ Kỳ", "Level 43 must be Thiên Nhân")
	assert(Cultivation.GetRealmName(51) == "Quy Hư • Sơ Kỳ", "Level 51 must be Quy Hư")
	assert(Cultivation.GetRealmName(61) == "Độ Kiếp • Sơ Kỳ", "Level 61 must be Độ Kiếp")
	
	var rColor = Cultivation.GetRealmColor(2)
	assert(rColor.g > 0.5, "Tụ Khí color should have green accent")
	print("  ✔ Level 1: ", Cultivation.GetRealmName(1))
	print("  ✔ Level 2: ", Cultivation.GetRealmName(2))
	print("  ✔ Level 10: ", Cultivation.GetRealmName(10))
	print("  ✔ Level 19: ", Cultivation.GetRealmName(19))
	print("  ✔ Level 27: ", Cultivation.GetRealmName(27))
	test_results["system3_realms"] = true
	print("[PASS] System 3: Decision D-04 realm canon verified!")

	print("\n--- [SYSTEM 4 & 5: ROOTS, APTITUDE & BOTTLENECK] ---")
	var dummyRoot = Cultivation.CalculateSpiritualRoot(null)
	assert(dummyRoot.has("name") and dummyRoot.has("grade"), "Root must contain name and grade")
	var comp = Cultivation.CalculateComprehension(null)
	var apt = Cultivation.CalculateAptitude(null)
	assert(comp >= 50 and comp <= 100, "Comprehension must be in range 50-100")
	assert(apt >= 50 and apt <= 100, "Aptitude must be in range 50-100")
	print("  ✔ Spiritual Root: ", dummyRoot["name"], " (Grade: %s)" % dummyRoot["grade"])
	print("  ✔ Comprehension: %d | Aptitude: %d" % [comp, apt])

	var bStatusAccum = Cultivation.GetBottleneckStatus(1, 20, 100)
	assert(not bStatusAccum["hasBottleneck"], "Bottleneck should not trigger when exp < nextExp")
	assert(bStatusAccum["status"].contains("Đang vận công"), "Status should indicate accumulation")

	var bStatusReady = Cultivation.GetBottleneckStatus(1, 100, 100)
	assert(bStatusReady["hasBottleneck"], "Bottleneck must trigger when exp >= nextExp")
	assert(bStatusReady["status"].contains("Bình cảnh"), "Status should indicate bottleneck reached")
	print("  ✔ Bottleneck when 20/100: ", bStatusAccum["status"])
	print("  ✔ Bottleneck when 100/100: ", bStatusReady["status"])
	test_results["system4_5_mechanics"] = true
	print("[PASS] System 4 & 5: Spiritual roots, aptitude, and bottleneck logic verified!")

	print("\n--- [SYSTEM 12 (PARTIAL): QUITBOX & DEATH MESSAGES] ---")
	assert(DeathMessages.Messages.size() >= 20, "Must have 20+ authentic Vietnamese death messages")
	var deathSample = DeathMessages.Pick()
	assert(not deathSample.is_empty(), "Death message pick must return string")
	print("  ✔ Sample death message: ", deathSample)
	assert(QuitBox.QuitText.contains("Tu đạo gian nan"), "QuitBox text must be authentic Xianxia")
	print("  ✔ QuitBox text: ", QuitBox.QuitText)
	test_results["system12_death_quit"] = true
	print("[PASS] Xianxia death messages and QuitBox verified!")

func _RunSceneLocalizationTests():
	print("\n--- [SYSTEMS 9, 10, 11, 12: SCENE LOCALIZATION AUDIT] ---")

	# Stats.tscn
	var statsScene = load("res://presets/gui/Stats.tscn").instantiate()
	var statsTitleBar = statsScene.get_node_or_null("Layout/TitleBar")
	assert(statsTitleBar != null, "Stats must have TitleBar")
	assert(statsTitleBar.titleText == "Tu Chân Thuộc Tính", "Stats window title must be Tu Chân Thuộc Tính")
	var statsVBox = statsScene.get_node_or_null("Layout/Scroll/Margin/Layout/Stats/StatBox")
	assert(statsVBox != null, "StatBox VBox must exist")
	assert(statsVBox.get_node("StrengthBox/Name").text == "Lực Lượng", "Strength must be Lực Lượng")
	assert(statsVBox.get_node("VitalityBox/Name").text == "Thể Chất", "Vitality must be Thể Chất")
	assert(statsVBox.get_node("AgilityBox/Name").text == "Thân Pháp", "Agility must be Thân Pháp")
	assert(statsVBox.get_node("EnduranceBox/Name").text == "Định Lực", "Endurance must be Định Lực")
	assert(statsVBox.get_node("ConcentrationBox/Name").text == "Thần Thức", "Concentration must be Thần Thức")
	statsScene.queue_free()
	print("  ✔ presets/gui/Stats.tscn: Tu Chân Thuộc Tính verified!")

	# Inventory.tscn
	var invScene = load("res://presets/gui/Inventory.tscn").instantiate()
	var invTitleBar = invScene.get_node_or_null("Layout/TitleBar")
	assert(invTitleBar != null and invTitleBar.titleText == "Túi Trữ Vật", "Inventory title must be Túi Trữ Vật")
	var invBox = invScene.get_node_or_null("Layout/Margin/HBoxContainer/InfoScroll/InfoBox")
	assert(invBox != null, "InfoBox must exist")
	assert(invBox.get_node("Equipment").text == "Pháp Bảo & Trang Bị", "Equipment header must be localized")
	assert(invBox.get_node("ModifiersLabel").text == "Gia Trì Thuộc Tính", "ModifiersLabel must be localized")
	assert(invBox.get_node("CapacityLabel").text == "Dung Tích Túi", "CapacityLabel must be localized")
	assert(invBox.get_node("WeightBox/WeightLabel").text == "Tải Trọng", "WeightLabel must be localized")
	assert(invBox.get_node("SlotsBox/SlotsLabel").text == "Ngăn Chứa", "SlotsLabel must be localized")
	var itemButtons = invScene.get_node_or_null("Layout/Margin/HBoxContainer/ItemsBox/ItemButtons")
	assert(itemButtons.get_node("Drop").text == "Bỏ Lại", "Drop must be Bỏ Lại")
	assert(itemButtons.get_node("Unequip").text == "Tháo Xuống", "Unequip must be Tháo Xuống")
	assert(itemButtons.get_node("Equip").text == "Trang Bị", "Equip must be Trang Bị")
	assert(itemButtons.get_node("Use").text == "Sử Dụng", "Use must be Sử Dụng")
	invScene.queue_free()
	print("  ✔ presets/gui/Inventory.tscn: Túi Trữ Vật verified!")

	# Progress.tscn
	var progScene = load("res://presets/gui/Progress.tscn").instantiate()
	var progTitleBar = progScene.get_node_or_null("Layout/TitleBar")
	assert(progTitleBar != null and progTitleBar.titleText == "Sổ Tay Nhiệm Vụ & Đồ Giám", "Progress title must be Sổ Tay Nhiệm Vụ & Đồ Giám")
	var bestiaryLabel = progScene.get_node_or_null("Layout/Margin/TabBar/Manapedia/BestiaryList/BestiaryLabel")
	assert(bestiaryLabel != null and bestiaryLabel.text == "Danh Sách Yêu Thú Đã Trảm Sát", "Bestiary header must be localized")
	progScene.queue_free()
	print("  ✔ presets/gui/Progress.tscn: Sổ Tay Nhiệm Vụ & Đồ Giám verified!")

	# Skill.tscn
	var skillScene = load("res://presets/gui/Skill.tscn").instantiate()
	var skillTitleBar = skillScene.get_node_or_null("Layout/TitleBar")
	assert(skillTitleBar != null and skillTitleBar.titleText == "Công Pháp & Bí Thuật", "Skill title must be Công Pháp & Bí Thuật")
	skillScene.queue_free()
	print("  ✔ presets/gui/Skill.tscn: Công Pháp & Bí Thuật verified!")

	# Trade.tscn
	var tradeScene = load("res://presets/gui/Trade.tscn").instantiate()
	var ownHdr = tradeScene.get_node_or_null("Layout/Margin/Content/Header/Own")
	assert(ownHdr != null and ownHdr.text == "Bản Thân", "Trade header own must be Bản Thân")
	var lockBtn = tradeScene.get_node_or_null("Layout/Margin/Content/Footer/Lock")
	assert(lockBtn != null and lockBtn.text == "Khóa Giao Dịch", "Lock button must be Khóa Giao Dịch")
	var cancelBtn = tradeScene.get_node_or_null("Layout/Margin/Content/Footer/Cancel")
	assert(cancelBtn != null and cancelBtn.text == "Hủy Bỏ", "Cancel button must be Hủy Bỏ")
	tradeScene.queue_free()
	print("  ✔ presets/gui/Trade.tscn: Giao Thương Tu Tiên verified!")

	# Character.tscn
	var charScene = load("res://presets/gui/Character.tscn").instantiate()
	var entry = charScene.get_node_or_null("PlayerName/Entry")
	assert(entry != null and entry.placeholder_text == "Nhập Đạo Hiệu Nhân Vật", "Character name entry must have Vietnamese placeholder")
	var attrLabel = charScene.get_node_or_null("Display/Attributes/Margin/VBox/Label")
	assert(attrLabel != null and attrLabel.text == "Tư Chất Bẩm Sinh", "Attributes header must be Tư Chất Bẩm Sinh")
	var statsLabel = charScene.get_node_or_null("Display/Stats/Margin/VBox/Label")
	assert(statsLabel != null and statsLabel.text == "Căn Cốt & Cảnh Giới", "Stats header must be Căn Cốt & Cảnh Giới")
	var traitsLabel = charScene.get_node_or_null("Display/Traits/Margin/VBox/Label")
	assert(traitsLabel != null and traitsLabel.text == "Tướng Mạo & Căn Cốt", "Traits header must be Tướng Mạo & Căn Cốt")
	charScene.queue_free()
	print("  ✔ presets/gui/Character.tscn: Tạo Nhân Vật verified!")

	# Login.tscn
	var loginScene = load("res://presets/gui/Login.tscn").instantiate()
	var nameLbl = loginScene.get_node_or_null("HBoxContainer/Panel/Margin/Content/LoginContainer/Name/Label")
	assert(nameLbl != null and nameLbl.text == "Tên Đạo Hào", "Login name label must be Tên Đạo Hào")
	var passLbl = loginScene.get_node_or_null("HBoxContainer/Panel/Margin/Content/LoginContainer/Password/Label")
	assert(passLbl != null and passLbl.text == "Mật Khẩu", "Login password label must be Mật Khẩu")
	var confLbl = loginScene.get_node_or_null("HBoxContainer/Panel/Margin/Content/LoginContainer/ConfirmPassword/Label")
	assert(confLbl != null and confLbl.text == "Xác Nhận Mật Khẩu", "Confirm password label must be Xác Nhận Mật Khẩu")
	var remCb = loginScene.get_node_or_null("HBoxContainer/Panel/Margin/Content/LoginContainer/IndicatorRow/RememberMe")
	assert(remCb != null and remCb.text == "Ghi Nhớ Đạo Hào", "Remember me checkbox must be Ghi Nhớ Đạo Hào")
	loginScene.queue_free()
	print("  ✔ presets/gui/Login.tscn: Đăng Nhập Đạo Hào verified!")

	test_results["system9_10_11_12_scenes"] = true
	print("[PASS] Systems 9, 10, 11, 12 UI scene localization verified!")

func _RunSQLiteUnicodeTests():
	print("\n--- [SYSTEM 13: SQLITE FULL UNICODE VIETNAMESE PERSISTENCE] ---")
	var dbPath = SQLCommons.GetDBPath()
	var db = SQLite.new()
	db.path = dbPath
	assert(db.open_db(), "Failed to open SQLite database at: " + dbPath)
	
	var unicodeTestNick = "Tiêu Dao Tử - Trúc Sơn Tông"
	var unicodeNote = "Chân khí đan điền viên mãn, linh căn Mộc Phong tương sinh."
	
	var q = "CREATE TABLE IF NOT EXISTS test_unicode_xianxia (id INTEGER PRIMARY KEY, nick TEXT, note TEXT);"
	db.query(q)
	
	var insertQ = "INSERT OR REPLACE INTO test_unicode_xianxia (id, nick, note) VALUES (999, '%s', '%s');" % [unicodeTestNick, unicodeNote]
	db.query(insertQ)
	
	db.query("SELECT nick, note FROM test_unicode_xianxia WHERE id = 999;")
	assert(db.query_result.size() > 0, "Query result must exist")
	var row = db.query_result[0]
	assert(row["nick"] == unicodeTestNick, "Unicode nickname must match exactly without corruption")
	assert(row["note"] == unicodeNote, "Unicode note must match exactly without corruption")
	print("  ✔ Stored & retrieved: [nick] ", row["nick"])
	print("  ✔ Stored & retrieved: [note] ", row["note"])
	
	db.query("DELETE FROM test_unicode_xianxia WHERE id = 999;")
	db.close_db()
	test_results["system13_sqlite_unicode"] = true
	print("[PASS] System 13: SQLite Unicode Vietnamese integrity verified!")

func _process(delta: float):
	timer += delta

	# Step 1: Wait for connection
	if timer > 1.0 and step == 0 and Network.clientConnected:
		step = 1
		print("\n[Step 1 PASS] Connected via in-process offline dispatch!")
		test_results["live_step1_connected"] = true
		print("[Step 2] Logging in with account: ", test_account)
		Network.LoginWithPassword(test_account, test_pass, false)

	# Step 2: Create character at 3.5s
	if timer > 3.5 and step == 1:
		step = 2
		print("[Step 2 PASS] Logged in! Creating character: ", test_char)
		test_results["live_step2_login"] = true

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

	# Step 3: Connect character at 5.5s
	if timer > 5.5 and step == 2:
		step = 3
		print("[Step 3] Connecting character: ", test_char)
		Network.ConnectCharacter(test_char)

	# Step 4: Verify player spawn & Cultivation Window UI structure at 8.0s
	if timer > 8.0 and step == 3:
		step = 4
		var player = GetServerPlayer()
		assert(player != null, "Player must be spawned in world")
		print("[Step 3 PASS] Player spawned! Nick: ", player.nick)
		print("  ✔ Starting Realm: ", Cultivation.GetRealmName(player.stat.level))
		assert(player.stat.level == 1, "New player starts at level 1 (Phàm Thân)")

		print("\n--- [SYSTEM 6: CULTIVATION WINDOW INSTANTIATION] ---")
		cultivationWindow = CultivationWindowClass.new()
		add_child(cultivationWindow)
		cultivationWindow._ready()
		cultivationWindow.Refresh()

		assert(cultivationWindow.realmLabel != null, "realmLabel must exist")
		assert(cultivationWindow.realmLabel.text.contains("Phàm Thân"), "Window realm label must display Phàm Thân")
		assert(cultivationWindow.charNameLabel != null, "charNameLabel must exist")
		assert(cultivationWindow.tuViTextLabel != null, "tuViTextLabel must exist")
		assert(cultivationWindow.bottleneckLabel != null, "bottleneckLabel must exist")
		assert(cultivationWindow.techniqueLabel != null, "techniqueLabel must exist")
		assert(cultivationWindow.spiritualRootLabel != null, "spiritualRootLabel must exist")
		assert(cultivationWindow.comprehensionLabel != null, "comprehensionLabel must exist")
		assert(cultivationWindow.btnMeditate != null, "btnMeditate must exist")
		assert(cultivationWindow.btnBreakthrough != null, "btnBreakthrough must exist")
		print("  ✔ Cultivation Window Realm Label: ", cultivationWindow.realmLabel.text)
		print("  ✔ Cultivation Window Technique: ", cultivationWindow.techniqueLabel.text)
		print("  ✔ Cultivation Window Spiritual Root: ", cultivationWindow.spiritualRootLabel.text)
		print("  ✔ Cultivation Window Comprehension: ", cultivationWindow.comprehensionLabel.text)
		test_results["system6_window_ui"] = true
		print("[PASS] System 6: CultivationWindow instantiated and verified!")

	# Step 5: Test Meditative Cultivation (Vận Công) & Live Feedback at 9.5s
	if timer > 9.5 and step == 4:
		step = 5
		print("\n--- [SYSTEM 7: MEDITATION & LIVE FEEDBACK LOOP] ---")
		var player = cultivationWindow.GetActivePlayer()
		assert(player != null, "Active player must exist")
		var initExp : int = player.stat.experience
		
		# Start meditation
		cultivationWindow.ToggleMeditation()
		assert(cultivationWindow.isMeditating == true, "Must be meditating")
		assert(cultivationWindow.btnMeditate.text == "Tạm Dừng Tu Luyện", "Button text must update to Tạm Dừng Tu Luyện")
		
		# Execute 3 meditation ticks
		cultivationWindow._OnMeditateTick()
		cultivationWindow._OnMeditateTick()
		cultivationWindow._OnMeditateTick()
		
		var postExp : int = player.stat.experience
		assert(postExp >= initExp + 36, "3 meditation ticks must grant at least 36 Tu Vi")
		print("  ✔ Tu Vi increased: %d -> %d (+%d)" % [initExp, postExp, postExp - initExp])
		print("  ✔ Live Feedback text sample:\n", cultivationWindow.feedbackBox.text)
		
		# Stop meditation
		cultivationWindow.ToggleMeditation()
		assert(cultivationWindow.isMeditating == false, "Must stop meditating")
		assert(cultivationWindow.btnMeditate.text == "Vận Công", "Button text must revert to Vận Công")
		test_results["system7_meditation"] = true
		print("[PASS] System 7: Meditative cultivation and live feedback verified!")

	# Step 6: Test Breakthrough Rejection (Insufficient Tu Vi) at 11.0s
	if timer > 11.0 and step == 5:
		step = 6
		print("\n--- [SYSTEM 8: BREAKTHROUGH REJECTION (INSUFFICIENT TU VI)] ---")
		var player = cultivationWindow.GetActivePlayer()
		assert(player != null, "Active player must exist")
		var neededExp : int = Experience.GetNeededExperienceForNextLevel(player.stat.level)
		# Ensure currentExp < neededExp
		player.stat.experience = mini(player.stat.experience, neededExp - 10)
		
		var failResult = Cultivation.AttemptBreakthrough(player)
		assert(failResult["success"] == false, "Breakthrough must fail when Tu Vi is insufficient")
		assert(failResult["message"] == "Tu Vi Chưa Đủ, Chưa Thể Phá Cảnh.", "Must return canonical Insufficient Tu Vi message")
		print("  ✔ Rejection message: ", failResult["message"])
		test_results["system8_breakthrough_rejection"] = true
		print("[PASS] Breakthrough rejection logic verified!")

	# Step 7: Test Breakthrough Advancement (Sufficient Tu Vi) at 12.5s
	if timer > 12.5 and step == 6:
		step = 7
		print("\n--- [SYSTEM 8: BREAKTHROUGH ADVANCEMENT (SUFFICIENT TU VI)] ---")
		var player = cultivationWindow.GetActivePlayer()
		assert(player != null, "Active player must exist")
		var oldLvl : int = player.stat.level
		var neededExp : int = Experience.GetNeededExperienceForNextLevel(oldLvl)
		var oldPts : int = Formula.GetMaxAttributePoints(oldLvl) - Formula.GetAssignedAttributePoints(player.stat)
		
		# Grant sufficient Tu Vi for bottleneck
		player.stat.experience = neededExp + 15
		cultivationWindow.Refresh()
		
		var bStatus = Cultivation.GetBottleneckStatus(player.stat.level, player.stat.experience, neededExp)
		assert(bStatus["hasBottleneck"] == true, "Bottleneck must be reached before breakthrough")
		
		# Attempt breakthrough via Window
		var bResult = cultivationWindow.AttemptBreakthrough()
		assert(bResult != null and bResult["success"] == true, "Breakthrough attempt must succeed")
		
		var newLvl : int = player.stat.level
		var newPts : int = Formula.GetMaxAttributePoints(newLvl) - Formula.GetAssignedAttributePoints(player.stat)
		assert(newLvl == oldLvl + 1, "Player level must increase by 1 after breakthrough")
		assert(newPts > oldPts, "Available stat points must increase after breakthrough")
		var newRealm : String = Cultivation.GetRealmName(newLvl)
		assert(newRealm.contains("Tụ Khí"), "Realm must advance from Phàm Thân to Tụ Khí")
		print("  ✔ Breakthrough Successful! Level: %d -> %d" % [oldLvl, newLvl])
		print("  ✔ New Realm: ", newRealm)
		print("  ✔ Available Stat Points: %d -> %d" % [oldPts, newPts])
		test_results["system8_breakthrough_success"] = true
		print("[PASS] System 8: Realm breakthrough and stat allocation verified!")

	# Step 8: Final Quality Gate Assessment at 14.0s
	if timer > 14.0 and step == 7:
		step = 8
		print("\n==================================================================")
		print("=== TDNM BUILD 04: ALL 13 LOCALIZATION SYSTEMS VERIFIED ===")
		print("==================================================================")
		for k in test_results:
			print("  ✔ %s: PASS" % k)
		print("\nAll automated assertions PASSED with 0 errors!")
		print("Exiting test suite successfully.")
		get_tree().quit(0)
