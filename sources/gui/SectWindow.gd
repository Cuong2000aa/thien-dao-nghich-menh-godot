extends WindowPanel
class_name SectWindow

## Master Sect Interface (Giao Diện Tông Môn & Đệ Tử)
## Thiên Đạo Nghịch Mệnh — Build 06: Sect System & Disciple Progression
## Complies with Owner Decision D-03. All UI is 100% Vietnamese Xianxia.

const SectSystemClass = preload("res://sources/sect/SectSystem.gd")
const CultivationClass = preload("res://sources/actor/Cultivation.gd")
const Localization = preload("res://sources/system/Localization.gd")

# Tab container & controls
var tabContainer : TabContainer = null
var overviewTab : VBoxContainer = null
var profileTab : VBoxContainer = null
var missionsTab : VBoxContainer = null
var exchangeTab : VBoxContainer = null
var libraryTab : VBoxContainer = null
var rankingTab : VBoxContainer = null

# Profile UI bindings
var rankLabel : Label = null
var contribLabel : Label = null
var totalContribLabel : Label = null
var facilitiesLabel : Label = null
var promoConditionLabel : Label = null
var btnPromote : Button = null

# Treasury UI
var treasuryLabel : Label = null

func _init():
	name = "SectWindow"
	custom_minimum_size = Vector2(620, 520)
	size = Vector2(620, 520)
	floating = true
	draggable = true
	visible = false

func _ready():
	_BuildUI()
	Refresh()

func _BuildUI():
	for c in get_children():
		c.queue_free()

	var mainMargin = MarginContainer.new()
	mainMargin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mainMargin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mainMargin.add_theme_constant_override("margin_left", 12)
	mainMargin.add_theme_constant_override("margin_right", 12)
	mainMargin.add_theme_constant_override("margin_top", 10)
	mainMargin.add_theme_constant_override("margin_bottom", 12)
	add_child(mainMargin)

	var rootVBox = VBoxContainer.new()
	rootVBox.set("theme_override_constants/separation", 8)
	mainMargin.add_child(rootVBox)

	# Window Header
	var title = Label.new()
	title.text = "TÔNG MÔN THÁNH ĐỊA & HỒ SƠ ĐỆ TỬ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	rootVBox.add_child(title)

	# Tab Container
	tabContainer = TabContainer.new()
	tabContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rootVBox.add_child(tabContainer)

	# 1. Tab Tổng Quan
	overviewTab = VBoxContainer.new()
	overviewTab.name = "Tổng Quan"
	overviewTab.set("theme_override_constants/separation", 8)
	tabContainer.add_child(overviewTab)
	_BuildOverviewTab()

	# 2. Tab Hồ Sơ Đệ Tử
	profileTab = VBoxContainer.new()
	profileTab.name = "Hồ Sơ Đệ Tử"
	profileTab.set("theme_override_constants/separation", 8)
	tabContainer.add_child(profileTab)
	_BuildProfileTab()

	# 3. Tab Nhiệm Vụ Tông Môn
	missionsTab = VBoxContainer.new()
	missionsTab.name = "Nhiệm Vụ"
	missionsTab.set("theme_override_constants/separation", 8)
	tabContainer.add_child(missionsTab)
	_BuildMissionsTab()

	# 4. Tab Bách Bảo Các (Sect Exchange)
	exchangeTab = VBoxContainer.new()
	exchangeTab.name = "Bách Bảo Các"
	exchangeTab.set("theme_override_constants/separation", 8)
	tabContainer.add_child(exchangeTab)
	_BuildExchangeTab()

	# 5. Tab Tàng Kinh Các
	libraryTab = VBoxContainer.new()
	libraryTab.name = "Tàng Kinh Các"
	libraryTab.set("theme_override_constants/separation", 8)
	tabContainer.add_child(libraryTab)
	_BuildLibraryTab()

	# 6. Tab Phong Vân Bảng (Ranking)
	rankingTab = VBoxContainer.new()
	rankingTab.name = "Phong Vân Bảng"
	rankingTab.set("theme_override_constants/separation", 8)
	tabContainer.add_child(rankingTab)
	_BuildRankingTab()

	# Bottom Close Button
	var btnClose = Button.new()
	btnClose.text = "Đóng Cửa Sổ"
	btnClose.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btnClose.custom_minimum_size = Vector2(140, 32)
	btnClose.pressed.connect(ToggleControl)
	rootVBox.add_child(btnClose)

# ==============================================================================
# TAB 1: TỔNG QUAN TÔNG MÔN
# ==============================================================================
func _BuildOverviewTab():
	var sectData = SectSystemClass.SECT_REGISTRY.get(SectSystemClass.DEFAULT_SECT_ID, {})
	
	var sectNameLabel = Label.new()
	sectNameLabel.text = "Tông Môn: %s" % sectData.get("display_name", "")
	sectNameLabel.add_theme_font_size_override("font_size", 15)
	sectNameLabel.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	overviewTab.add_child(sectNameLabel)

	var canonNote = Label.new()
	canonNote.text = "• Lưu ý thiết lập: %s" % sectData.get("canon_status", "")
	canonNote.add_theme_font_size_override("font_size", 11)
	canonNote.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	overviewTab.add_child(canonNote)

	var tenetLabel = Label.new()
	tenetLabel.text = "• Tông Chỉ: \"%s\"" % sectData.get("tenet", "")
	tenetLabel.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	overviewTab.add_child(tenetLabel)

	var leaderLabel = Label.new()
	leaderLabel.text = "• Người Đứng Đầu: %s" % sectData.get("leader", "")
	overviewTab.add_child(leaderLabel)

	var locLabel = Label.new()
	locLabel.text = "• Thánh Địa: %s" % sectData.get("location", "")
	overviewTab.add_child(locLabel)

	var repLabel = Label.new()
	repLabel.text = "• Uy Danh Thiên Hạ: %s" % sectData.get("reputation", "")
	overviewTab.add_child(repLabel)

	treasuryLabel = Label.new()
	var t = sectData.get("treasury", {})
	treasuryLabel.text = "• Kho Tài Nguyên Tông Môn: %d Linh Thạch | %d Linh Thảo | %d Linh Khoáng | %d Linh Đan" % [
		t.get("spirit_stones", 0), t.get("herbs", 0), t.get("ores", 0), t.get("pills", 0)
	]
	treasuryLabel.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	overviewTab.add_child(treasuryLabel)

	var desc = RichTextLabel.new()
	desc.bbcode_enabled = true
	desc.text = "[color=#cccccc]%s[/color]" % sectData.get("description", "")
	desc.custom_minimum_size = Vector2(0, 100)
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	overviewTab.add_child(desc)

# ==============================================================================
# TAB 2: HỒ SƠ ĐỆ TỬ
# ==============================================================================
func _BuildProfileTab():
	rankLabel = Label.new()
	rankLabel.text = "Thân Phận Hiện Tại: Chưa Nhập Môn"
	rankLabel.add_theme_font_size_override("font_size", 14)
	rankLabel.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	profileTab.add_child(rankLabel)

	contribLabel = Label.new()
	contribLabel.text = "Điểm Cống Hiến Khả Dụng: 0 Điểm"
	contribLabel.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	profileTab.add_child(contribLabel)

	totalContribLabel = Label.new()
	totalContribLabel.text = "Tổng Cống Hiến Tích Lũy: 0 Điểm"
	profileTab.add_child(totalContribLabel)

	facilitiesLabel = Label.new()
	facilitiesLabel.text = "Quyền Truy Cập Công Trình: Đại Điện"
	facilitiesLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profileTab.add_child(facilitiesLabel)

	var sep = HSeparator.new()
	profileTab.add_child(sep)

	promoConditionLabel = Label.new()
	promoConditionLabel.text = "Điều Kiện Thăng Cấp: Đang kiểm tra..."
	promoConditionLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profileTab.add_child(promoConditionLabel)

	btnPromote = Button.new()
	btnPromote.text = "Tiến Hành Thăng Cấp Thân Phận"
	btnPromote.custom_minimum_size = Vector2(220, 36)
	btnPromote.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btnPromote.pressed.connect(_OnPromotePressed)
	profileTab.add_child(btnPromote)

# ==============================================================================
# TAB 3: NHIỆM VỤ TÔNG MÔN
# ==============================================================================
func _BuildMissionsTab():
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	missionsTab.add_child(scroll)

	var vBox = VBoxContainer.new()
	vBox.set("theme_override_constants/separation", 8)
	vBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vBox)

	var missionNames = [
		"Khảo Nghiệm Nhập Môn",
		"Tuần Tra Sơn Môn",
		"Cống Hiến Dược Thảo",
		"Cống Hiến Khoáng Thạch",
		"Diệt Trừ Ma Vật",
		"Khảo Hạch Ngoại Môn",
		"Khảo Hạch Nội Môn",
		"Truyền Thừa Tông Môn"
	]

	for mName in missionNames:
		var card = PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vBox.add_child(card)

		var cardVBox = VBoxContainer.new()
		cardVBox.set("theme_override_constants/separation", 3)
		card.add_child(cardVBox)

		var lblName = Label.new()
		lblName.text = "• " + mName
		lblName.add_theme_font_size_override("font_size", 13)
		lblName.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		cardVBox.add_child(lblName)

		var qHash = mName.hash()
		var qCell = DB.QuestsDB.get(qHash, null) if DB.QuestsDB else null
		var descText = qCell.description if qCell else "Ủy thác rèn luyện và bảo hộ sơn môn."
		var lblDesc = Label.new()
		lblDesc.text = descText
		lblDesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lblDesc.add_theme_font_size_override("font_size", 11)
		lblDesc.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
		cardVBox.add_child(lblDesc)

# ==============================================================================
# TAB 4: BÁCH BẢO CÁC (SECT EXCHANGE)
# ==============================================================================
func _BuildExchangeTab():
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	exchangeTab.add_child(scroll)

	var vBox = VBoxContainer.new()
	vBox.set("theme_override_constants/separation", 6)
	vBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vBox)

	for item in SectSystemClass.EXCHANGE_CATALOG:
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vBox.add_child(row)

		var infoVBox = VBoxContainer.new()
		infoVBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(infoVBox)

		var nameLbl = Label.new()
		nameLbl.text = "%s (%s)" % [item["name"], item["category"]]
		nameLbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		infoVBox.add_child(nameLbl)

		var descLbl = Label.new()
		var reqRankName : String = SectSystemClass.GetDiscipleRankName(item["reqRank"])
		descLbl.text = "%s | Yêu cầu: %s | Giá: %d Cống Hiến" % [item["description"], reqRankName, item["cost"]]
		descLbl.add_theme_font_size_override("font_size", 11)
		descLbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		infoVBox.add_child(descLbl)

		var btnExchange = Button.new()
		btnExchange.text = "Đổi (%d CH)" % item["cost"]
		btnExchange.custom_minimum_size = Vector2(100, 30)
		btnExchange.pressed.connect(_OnExchangePressed.bind(item["id"]))
		row.add_child(btnExchange)

# ==============================================================================
# TAB 5: TÀNG KINH CÁC
# ==============================================================================
func _BuildLibraryTab():
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	libraryTab.add_child(scroll)

	var vBox = VBoxContainer.new()
	vBox.set("theme_override_constants/separation", 6)
	vBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vBox)

	for sc in SectSystemClass.SCRIPTURE_CATALOG:
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vBox.add_child(row)

		var infoVBox = VBoxContainer.new()
		infoVBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(infoVBox)

		var nameLbl = Label.new()
		nameLbl.text = "%s [%s]" % [sc["name"], sc["category"]]
		nameLbl.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
		infoVBox.add_child(nameLbl)

		var descLbl = Label.new()
		var reqRankName : String = SectSystemClass.GetDiscipleRankName(sc["reqRank"])
		descLbl.text = "%s | Yêu cầu: %s, Cấp %d | Giá: %d Cống Hiến" % [sc["description"], reqRankName, sc["reqRealm"], sc["cost"]]
		descLbl.add_theme_font_size_override("font_size", 11)
		descLbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		infoVBox.add_child(descLbl)

		var btnLearn = Button.new()
		btnLearn.text = "Tham Ngộ"
		btnLearn.custom_minimum_size = Vector2(90, 30)
		btnLearn.pressed.connect(_OnLearnScripturePressed.bind(sc["id"]))
		row.add_child(btnLearn)

# ==============================================================================
# TAB 6: PHONG VÂN BẢNG (RANKING)
# ==============================================================================
func _BuildRankingTab():
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rankingTab.add_child(scroll)

	var vBox = VBoxContainer.new()
	vBox.name = "RankingList"
	vBox.set("theme_override_constants/separation", 6)
	vBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vBox)

# ==============================================================================
# REFRESH LOGIC
# ==============================================================================
var boundPlayer : Node = null

func Refresh(customPlayer : Node = null):
	if customPlayer:
		boundPlayer = customPlayer
	var player = boundPlayer
	if not player:
		player = Launcher.Player if Launcher.get("Player") else null
	if not player:
		return

	var rank : int = SectSystemClass.GetDiscipleRank(player)
	var rankName : String = SectSystemClass.GetDiscipleRankName(rank)
	var title : String = SectSystemClass.GetDiscipleTitle(rank)
	var contrib : int = SectSystemClass.GetContribution(player)
	var totalContrib : int = SectSystemClass.GetTotalContribution(player)

	if rankLabel:
		rankLabel.text = "Thân Phận: [%s] • Danh Hiệu: %s" % [rankName, title]
	if contribLabel:
		contribLabel.text = "Điểm Cống Hiến Khả Dụng: [%d Điểm]" % contrib
	if totalContribLabel:
		totalContribLabel.text = "Tổng Cống Hiến Tích Lũy: [%d Điểm]" % totalContrib

	# Facilities
	if facilitiesLabel:
		var facList : Array[String] = []
		if SectSystemClass.HasFacilityAccess(player, SectSystemClass.Facility.MAIN_HALL): facList.append("Đại Điện")
		if SectSystemClass.HasFacilityAccess(player, SectSystemClass.Facility.PHARMACY): facList.append("Dược Đường")
		if SectSystemClass.HasFacilityAccess(player, SectSystemClass.Facility.FURNACE): facList.append("Luyện Đan Lô")
		if SectSystemClass.HasFacilityAccess(player, SectSystemClass.Facility.GATHERING_ARRAY): facList.append("Tụ Linh Trận")
		if SectSystemClass.HasFacilityAccess(player, SectSystemClass.Facility.MARTIAL_GROUND): facList.append("Diễn Võ Đường")
		if SectSystemClass.HasFacilityAccess(player, SectSystemClass.Facility.LIBRARY_T1): facList.append("Tàng Kinh Các T1")
		if SectSystemClass.HasFacilityAccess(player, SectSystemClass.Facility.LIBRARY_T2): facList.append("Tàng Kinh Các T2")
		if SectSystemClass.HasFacilityAccess(player, SectSystemClass.Facility.FORGE): facList.append("Luyện Khí Đường")
		if SectSystemClass.HasFacilityAccess(player, SectSystemClass.Facility.SECRET_REALM): facList.append("Linh Khí Bí Cảnh")
		facilitiesLabel.text = "Quyền Truy Cập Công Trình: " + ", ".join(facList)

	# Check promotion
	var check : Dictionary = SectSystemClass.CanPromote(player)
	if promoConditionLabel:
		promoConditionLabel.text = "Trạng Thái Khảo Hạch: " + check["message"]
		if check["canPromote"]:
			promoConditionLabel.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		else:
			promoConditionLabel.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))

	if btnPromote:
		btnPromote.disabled = not check["canPromote"]

	# Refresh Leaderboard
	_RefreshLeaderboard(player)

func _RefreshLeaderboard(player : Node):
	var scroll = rankingTab.get_node_or_null("ScrollContainer")
	if not scroll: return
	var vBox = scroll.get_node_or_null("RankingList")
	if not vBox: return

	for c in vBox.get_children():
		c.queue_free()

	var board = SectSystemClass.GetLeaderboard(player)
	for entry in board:
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vBox.add_child(row)

		var rankNum = Label.new()
		rankNum.text = "Top %d" % entry["rank"]
		rankNum.custom_minimum_size = Vector2(50, 0)
		rankNum.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if entry["rank"] <= 3 else Color(0.8, 0.8, 0.8))
		row.add_child(rankNum)

		var nameLbl = Label.new()
		nameLbl.text = "%s %s" % [entry["name"], entry["label"]]
		nameLbl.custom_minimum_size = Vector2(180, 0)
		if entry["isPlayer"]:
			nameLbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		row.add_child(nameLbl)

		var realmLbl = Label.new()
		realmLbl.text = str(entry["realm"])
		realmLbl.custom_minimum_size = Vector2(140, 0)
		row.add_child(realmLbl)

		var contribLbl = Label.new()
		contribLbl.text = "%d Cống Hiến" % entry["contribution"]
		contribLbl.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
		row.add_child(contribLbl)

# ==============================================================================
# BUTTON HANDLERS
# ==============================================================================
func _OnPromotePressed():
	var player = Launcher.Player if Launcher.get("Player") else null
	if not player: return
	var promoRes = SectSystemClass.PromoteDisciple(player)
	if promoRes.get("promoted", false):
		Refresh()
		NpcCommons.PushNotification(player, "THĂNG CẤP THÀNH CÔNG: [%s]!" % promoRes.get("newRankName", ""))

func _OnExchangePressed(exchangeId : int):
	var player = Launcher.Player if Launcher.get("Player") else null
	if not player: return
	var res = SectSystemClass.ExchangeItem(player, exchangeId)
	Refresh()
	NpcCommons.PushNotification(player, res["message"])

func _OnLearnScripturePressed(scId : int):
	var player = Launcher.Player if Launcher.get("Player") else null
	if not player: return
	var res = SectSystemClass.LearnScripture(player, scId)
	Refresh()
	NpcCommons.PushNotification(player, res["message"])
