extends WindowPanel
class_name WorldMapWindow

## TDNM — BUILD 10: WORLD EXPANSION, EXPLORATION & JOURNEY JOURNAL
## 4 Xianxia Tabs:
## Tab 1: Bản Đồ Sơn Hà (World Map with Fog-of-War)
## Tab 2: Sổ Tay Hành Trình (Journey Journal chronological exploration log)
## Tab 3: Cổ Tích & Phụ Bản (Ancient Ruins & Dungeons progression)
## Tab 4: Điểm Khám Phá & Kỳ Duyên (8 Special POIs & 5 Secret Areas)

const ExplorationSystemClass = preload("res://sources/world/ExplorationSystem.gd")

# UI Node references (preserved for backward compatibility with Build 03)
var regionListContainer : VBoxContainer = null
var currentLocLabel : Label = null
var detailTitle : Label = null
var detailRegion : Label = null
var detailDanger : Label = null
var detailDesc : RichTextLabel = null
var detailPOIs : Label = null

# Tab 2, 3, 4 Containers
var journalContainer : VBoxContainer = null
var ruinsContainer : VBoxContainer = null
var poisContainer : VBoxContainer = null

const REGION_DATA : Array[Dictionary] = [
	{
		"zone_id": "ZONE_TRUC_SON",
		"name": "Trúc Sơn Tiên Cảnh",
		"internal_name": "SacredSectHub",
		"map_id": 995840901,
		"type": "Tông Môn Sơn Vũ",
		"danger": "Cấp 1 • An Toàn",
		"danger_color": Color(0.3, 0.9, 0.3),
		"status": "ĐÃ KHÁM PHÁ",
		"desc": "Sơn môn thanh tịnh của Trúc Sơn Tông, ngập tràn thiên địa linh khí, nơi các đệ tử bước đầu đốn ngộ tiên đạo.",
		"pois": "Đạo Huyền Trưởng Lão, Dược Đường Chấp Sự, Luyện Đan Lô, Cổng Linh Khí Bí Cảnh"
	},
	{
		"zone_id": "ZONE_SON_LAM_NGOAI_VI",
		"name": "Sơn Lâm Ngoại Vi",
		"internal_name": "Tulimshar Eastern Hills",
		"map_id": 1841251538,
		"type": "Lâm Uyên Dã Ngoại",
		"danger": "Cấp 1-5 • Nguy Hiểm",
		"danger_color": Color(0.9, 0.8, 0.2),
		"status": "ĐÃ KHÁM PHÁ",
		"desc": "Dãy đồi rừng rậm rạp dưới chân núi Trúc Sơn. Nơi đây dã thú và yêu trùng sinh sôi, đồng thời có nhiều linh thảo phát sáng.",
		"pois": "Linh Trùng Bầy Đàn, Ngân Linh Thảo Bụi, Huyền Thiết Mạch Khai Thác"
	},
	{
		"zone_id": "ZONE_CO_DAO_PHE_TICH",
		"name": "Cổ Đạo Phế Tích",
		"internal_name": "Tulimshar Western Cave",
		"map_id": 1967386498,
		"type": "Động Quật Cổ Xưa",
		"danger": "Cấp 5-8 • Hiểm Địa",
		"danger_color": Color(0.95, 0.5, 0.2),
		"status": "ĐÃ KHÁM PHÁ",
		"desc": "Khu di tích động quật ẩn sâu trong lòng núi, tương truyền là nơi tọa hóa của các vị tiền bối ngàn năm trước để lại kiếm ý truyền thừa.",
		"pois": "Trúc Sơn Cổ Bi Ngàn Năm, Thạch Môn Bí Mật, Yêu Quái Canh Giữ"
	},
	{
		"zone_id": "ZONE_LINH_KHI_BI_CANH",
		"name": "Linh Khí Bí Cảnh",
		"internal_name": "Candor Arena",
		"map_id": 4111682275,
		"type": "Bí Cảnh Thử Thách",
		"danger": "Cấp 8-15 • Cấm Địa",
		"danger_color": Color(0.95, 0.2, 0.2),
		"status": "CẤM ĐỊA MỞ",
		"desc": "Vùng không gian dị giới bị phong ấn, linh khí cuồng bạo. Đây là sào huyệt của Xích Viêm Thú Hậu hung hãn bảo vệ linh tuyền bảo vật.",
		"pois": "Xích Viêm Thú Hậu (BOSS), Trận Pháp Truyền Tống Trở Về"
	},
	{
		"zone_id": "ZONE_THANH_SA_CANG",
		"name": "Thanh Sa Cảng",
		"internal_name": "Tulimshar",
		"map_id": 2608626462,
		"type": "Thương Cảng Nhập Thế",
		"danger": "Cấp 1 • An Toàn",
		"danger_color": Color(0.3, 0.9, 0.3),
		"status": "ĐÃ KHÁM PHÁ",
		"desc": "Thành phố cảng giao thương sầm uất ven bờ biển, nơi các tu sĩ nhập thế giao lưu buôn bán và tìm kiếm linh chuỗi tin tức.",
		"pois": "Thành Chủ Phủ, Khu Buôn Bán Linh Thạch, Bến Linh Thuyền"
	},
	{
		"zone_id": "ZONE_VAN_XA_KHANH",
		"name": "Vạn Xà Khanh",
		"internal_name": "Snake Pit",
		"map_id": 1284567890,
		"type": "Tử Địa Hung Hiểm",
		"danger": "Cấp 15-25 • Cực Nguy Hiểm",
		"danger_color": Color(0.8, 0.1, 0.1),
		"status": "CHƯA KHÁM PHÁ",
		"desc": "Vực sâu lòng đất ngập tràn chướng khí và độc xà hung bạo. Cần tu vi Thông Mạch trở lên mới có thể thám hiểm.",
		"pois": "Linh Xà Yêu Đan, Vực Thẳm Cấm Kỵ"
	}
]

func _ready():
	_BuildUI()
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.PolishWindow(self)
	if currentLocLabel:
		ThemeClass.AccentLabel(currentLocLabel)

func _BuildUI():
	custom_minimum_size = Vector2(640, 480)
	size = Vector2(640, 480)
	
	var mainMargin = MarginContainer.new()
	mainMargin.add_theme_constant_override("margin_left", 12)
	mainMargin.add_theme_constant_override("margin_right", 12)
	mainMargin.add_theme_constant_override("margin_top", 12)
	mainMargin.add_theme_constant_override("margin_bottom", 12)
	add_child(mainMargin)
	
	var vBox = VBoxContainer.new()
	vBox.set("theme_override_constants/separation", 8)
	mainMargin.add_child(vBox)
	
	# Header
	var title = Label.new()
	title.text = "BẢN ĐỒ THẾ GIỚI & SỔ TAY HÀNH TRÌNH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	vBox.add_child(title)
	
	# Current Location
	currentLocLabel = Label.new()
	currentLocLabel.text = "Vị trí hiện tại: [Trúc Sơn Tiên Cảnh]"
	currentLocLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	currentLocLabel.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	vBox.add_child(currentLocLabel)
	
	var sep = HSeparator.new()
	vBox.add_child(sep)
	
	# TabContainer for 4 Exploration Tabs
	var tabContainer = TabContainer.new()
	tabContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vBox.add_child(tabContainer)
	
	# TAB 1: Bản Đồ Sơn Hà (World Map)
	var tab1 = MarginContainer.new()
	tab1.name = "Bản Đồ Sơn Hà"
	tabContainer.add_child(tab1)
	
	var contentHBox = HBoxContainer.new()
	contentHBox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contentHBox.set("theme_override_constants/separation", 14)
	tab1.add_child(contentHBox)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(250, 270)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contentHBox.add_child(scroll)
	
	regionListContainer = VBoxContainer.new()
	regionListContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	regionListContainer.set("theme_override_constants/separation", 6)
	scroll.add_child(regionListContainer)
	
	var detailPanel = PanelContainer.new()
	detailPanel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detailPanel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contentHBox.add_child(detailPanel)
	
	var detailMargin = MarginContainer.new()
	detailMargin.add_theme_constant_override("margin_left", 8)
	detailMargin.add_theme_constant_override("margin_right", 8)
	detailMargin.add_theme_constant_override("margin_top", 8)
	detailMargin.add_theme_constant_override("margin_bottom", 8)
	detailPanel.add_child(detailMargin)
	
	var detailVBox = VBoxContainer.new()
	detailVBox.set("theme_override_constants/separation", 6)
	detailMargin.add_child(detailVBox)
	
	detailTitle = Label.new()
	detailTitle.text = "Trúc Sơn Tiên Cảnh"
	detailTitle.add_theme_font_size_override("font_size", 15)
	detailTitle.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	detailVBox.add_child(detailTitle)
	
	detailRegion = Label.new()
	detailRegion.text = "Loại hình: Tông Môn Sơn Vũ"
	detailRegion.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	detailVBox.add_child(detailRegion)
	
	detailDanger = Label.new()
	detailDanger.text = "Nguy hiểm: Cấp 1 • An Toàn"
	detailDanger.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	detailVBox.add_child(detailDanger)
	
	detailPOIs = Label.new()
	detailPOIs.text = "Điểm quan trọng: Đạo Huyền Trưởng Lão, Dược Đường, Luyện Đan Lô"
	detailPOIs.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detailPOIs.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	detailVBox.add_child(detailPOIs)
	
	var descSep = HSeparator.new()
	detailVBox.add_child(descSep)
	
	detailDesc = RichTextLabel.new()
	detailDesc.bbcode_enabled = true
	detailDesc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detailDesc.text = "Sơn môn thanh tịnh của Trúc Sơn Tông..."
	detailVBox.add_child(detailDesc)
	
	# TAB 2: Sổ Tay Hành Trình (Journey Journal)
	var tab2 = MarginContainer.new()
	tab2.name = "Sổ Tay Hành Trình"
	tabContainer.add_child(tab2)
	
	var journalScroll = ScrollContainer.new()
	journalScroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab2.add_child(journalScroll)
	
	journalContainer = VBoxContainer.new()
	journalContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journalContainer.set("theme_override_constants/separation", 6)
	journalScroll.add_child(journalContainer)
	
	# TAB 3: Cổ Tích & Phụ Bản (Ruins & Dungeons)
	var tab3 = MarginContainer.new()
	tab3.name = "Cổ Tích & Phụ Bản"
	tabContainer.add_child(tab3)
	
	var ruinsScroll = ScrollContainer.new()
	ruinsScroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab3.add_child(ruinsScroll)
	
	ruinsContainer = VBoxContainer.new()
	ruinsContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ruinsContainer.set("theme_override_constants/separation", 8)
	ruinsScroll.add_child(ruinsContainer)
	
	# TAB 4: Điểm Khám Phá & Kỳ Duyên (POIs & Secrets)
	var tab4 = MarginContainer.new()
	tab4.name = "Điểm Khám Phá & Kỳ Duyên"
	tabContainer.add_child(tab4)
	
	var poisScroll = ScrollContainer.new()
	poisScroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab4.add_child(poisScroll)
	
	poisContainer = VBoxContainer.new()
	poisContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	poisContainer.set("theme_override_constants/separation", 8)
	poisScroll.add_child(poisContainer)
	
	# Close button at bottom
	var closeBtn = Button.new()
	closeBtn.text = "Đóng Bản Đồ"
	closeBtn.custom_minimum_size = Vector2(120, 32)
	closeBtn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	closeBtn.pressed.connect(func(): set_visible(false))
	vBox.add_child(closeBtn)
	
	_PopulateRegions()

func _PopulateRegions():
	for child in regionListContainer.get_children():
		child.queue_free()
		
	for i in range(REGION_DATA.size()):
		var data = REGION_DATA[i]
		var btn = Button.new()
		btn.text = "%s [%s]" % [data["name"], data["status"]]
		btn.custom_minimum_size = Vector2(230, 36)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		if data["status"] == "CHƯA KHÁM PHÁ":
			btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		else:
			btn.add_theme_color_override("font_color", data["danger_color"])
			
		btn.pressed.connect(_SelectRegion.bind(i))
		regionListContainer.add_child(btn)

func _SelectRegion(index : int):
	if index < 0 or index >= REGION_DATA.size():
		return
	var data = REGION_DATA[index]
	detailTitle.text = data["name"]
	detailRegion.text = "Loại hình: %s [%s]" % [data["type"], data["status"]]
	detailDanger.text = "Độ nguy hiểm: %s" % data["danger"]
	detailDanger.add_theme_color_override("font_color", data["danger_color"])
	detailPOIs.text = "Điểm mốc: %s" % data["pois"]
	detailDesc.text = data["desc"]

func Refresh():
	var mapID : int = Launcher.Map.currentMapID if Launcher.Map else DB.UnknownHash
	var currentName : String = LocationNaming.GetDisplayName(mapID)
	if currentLocLabel:
		currentLocLabel.text = "Vị trí hiện tại: [%s]" % (currentName if not currentName.is_empty() else "Trúc Sơn Tiên Cảnh")
		
	_PopulateJournal()
	_PopulateRuins()
	_PopulatePois()

func _PopulateJournal():
	if not journalContainer: return
	for child in journalContainer.get_children():
		child.queue_free()
		
	var player = Launcher.Player if Launcher.Player else null
	var logs = ExplorationSystemClass.GetJourneyLog(player)
	if logs.is_empty():
		var lbl = Label.new()
		lbl.text = "Đạo hữu chưa ghi chép được hành trình nào. Hãy bước ra thế giới để khám phá!"
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		journalContainer.add_child(lbl)
		return
		
	for entry in logs:
		var p = PanelContainer.new()
		var l = Label.new()
		l.text = "• [%s] %s" % [entry.get("type", "HÀNH TRÌNH"), entry.get("text", "")]
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		p.add_child(l)
		journalContainer.add_child(p)

func _PopulateRuins():
	if not ruinsContainer: return
	for child in ruinsContainer.get_children():
		child.queue_free()
		
	var player = Launcher.Player if Launcher.Player else null
	for rId in ExplorationSystemClass.ANCIENT_RUINS.keys():
		var r = ExplorationSystemClass.ANCIENT_RUINS[rId]
		var prog = ExplorationSystemClass.GetRuinProgress(player, rId)
		var p = PanelContainer.new()
		var vb = VBoxContainer.new()
		p.add_child(vb)
		
		var titleLbl = Label.new()
		var stText = "[ĐÃ HOÀN THÀNH]" if prog.get("completed", false) else "[TIẾN ĐỘ: %d/%d]" % [prog.get("step", 0), r.get("stepsTotal", 5)]
		titleLbl.text = "Di Tích: %s %s" % [r.get("name", ""), stText]
		titleLbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if prog.get("completed", false) else Color(0.8, 0.8, 0.8))
		vb.add_child(titleLbl)
		
		var descLbl = Label.new()
		descLbl.text = "Thưởng: %d Tu Vi • Vật phẩm: %s" % [r.get("rewardTuVi", 0), str(r.get("rewardItems", []))]
		descLbl.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
		vb.add_child(descLbl)
		
		ruinsContainer.add_child(p)

func _PopulatePois():
	if not poisContainer: return
	for child in poisContainer.get_children():
		child.queue_free()
		
	var player = Launcher.Player if Launcher.Player else null
	for pId in ExplorationSystemClass.EXPLORATION_POINTS.keys():
		var poi = ExplorationSystemClass.EXPLORATION_POINTS[pId]
		var p = PanelContainer.new()
		var vb = VBoxContainer.new()
		p.add_child(vb)
		
		var l1 = Label.new()
		l1.text = "Điểm Mốc: %s (%s)" % [poi.get("name", ""), poi.get("type", "")]
		l1.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
		vb.add_child(l1)
		
		var l2 = Label.new()
		l2.text = poi.get("desc", "")
		l2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(l2)
		
		poisContainer.add_child(p)
