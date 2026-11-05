extends WindowPanel
class_name StoryWindow

## Master Story & Living World Interface (Sổ Tay Hành Trình & Thế Giới Tu Tiên)
## Thiên Đạo Nghịch Mệnh — Build 08: Heavenly Fate, Main Story & Living World
## Complies with Owner Decisions D-01, D-02, D-03, D-04. 100% Vietnamese Xianxia.

const StorySystemClass = preload("res://sources/story/StorySystem.gd")
const Localization = preload("res://sources/system/Localization.gd")

# Tab container & controls
var tabContainer : TabContainer = null
var mainStoryTab : VBoxContainer = null
var questLogTab : VBoxContainer = null
var npcDossierTab : VBoxContainer = null
var cluesTab : VBoxContainer = null
var eventsTab : VBoxContainer = null

# Main Story Tab Controls
var chapterTitleLabel : Label = null
var chapterSynopsisLabel : RichTextLabel = null
var chapterGoalLabel : Label = null
var btnAdvanceStory : Button = null

# Quest Log Controls
var questCategoryOption : OptionButton = null
var questItemList : ItemList = null
var questDetailLabel : RichTextLabel = null

# NPC Dossier Controls
var npcItemList : ItemList = null
var npcDetailLabel : RichTextLabel = null
var npcAffinityBar : ProgressBar = null
var npcAffinityText : Label = null

# Clues Controls
var clueItemList : ItemList = null
var clueDetailLabel : RichTextLabel = null

# Events Controls
var eventsList : ItemList = null
var eventDetailLabel : RichTextLabel = null
var btnTriggerEvent : Button = null

var boundPlayer : Node = null
var selectedNpcId : String = "DAO_HUYEN"
var selectedClueId : String = "CLUE_1_QI_FLUCTUATION"
var selectedEventId : String = "YEU_THU_TRIEU"

func _init():
	name = "StoryWindow"
	custom_minimum_size = Vector2(680, 560)
	size = Vector2(680, 560)
	floating = true
	draggable = true
	visible = false

func _ready():
	_BuildUI()
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.PolishWindow(self)
	if DB.isInitialized:
		Refresh()
	elif not Launcher.dbInitialized.is_connected(Refresh):
		Launcher.dbInitialized.connect(Refresh, CONNECT_ONE_SHOT)

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

	# Header Title
	var title = Label.new()
	title.text = "SỔ TAY HÀNH TRÌNH — THIÊN ĐẠO NGHỊCH MỆNH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	rootVBox.add_child(title)

	# Tab Container
	tabContainer = TabContainer.new()
	tabContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rootVBox.add_child(tabContainer)

	# 1. Main Story Tab
	mainStoryTab = VBoxContainer.new()
	mainStoryTab.name = "Cốt Truyện Chính"
	tabContainer.add_child(mainStoryTab)
	_BuildMainStoryTab(mainStoryTab)

	# 2. Quest Log Tab
	questLogTab = VBoxContainer.new()
	questLogTab.name = "Sổ Nhiệm Vụ"
	tabContainer.add_child(questLogTab)
	_BuildQuestLogTab(questLogTab)

	# 3. NPC Dossier Tab
	npcDossierTab = VBoxContainer.new()
	npcDossierTab.name = "Hồ Sơ & Hảo Cảm"
	tabContainer.add_child(npcDossierTab)
	_BuildNpcDossierTab(npcDossierTab)

	# 4. Clues & Deductions Tab
	cluesTab = VBoxContainer.new()
	cluesTab.name = "Nhật Ký Manh Mối"
	tabContainer.add_child(cluesTab)
	_BuildCluesTab(cluesTab)

	# 5. Living World Events Tab
	eventsTab = VBoxContainer.new()
	eventsTab.name = "Thế Giới Sự Kiện"
	tabContainer.add_child(eventsTab)
	_BuildEventsTab(eventsTab)

# ------------------------------------------------------------------------------
# TAB 1: MAIN STORY
# ------------------------------------------------------------------------------
func _BuildMainStoryTab(parent : VBoxContainer):
	parent.set("theme_override_constants/separation", 10)
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	parent.add_child(margin)

	var v = VBoxContainer.new()
	v.set("theme_override_constants/separation", 10)
	margin.add_child(v)

	chapterTitleLabel = Label.new()
	chapterTitleLabel.text = "Chương 1: Người Lạ Tại Dị Giới"
	chapterTitleLabel.add_theme_font_size_override("font_size", 15)
	chapterTitleLabel.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	v.add_child(chapterTitleLabel)

	chapterSynopsisLabel = RichTextLabel.new()
	chapterSynopsisLabel.bbcode_enabled = true
	chapterSynopsisLabel.fit_content = false
	chapterSynopsisLabel.custom_minimum_size = Vector2(0, 140)
	v.add_child(chapterSynopsisLabel)

	chapterGoalLabel = Label.new()
	chapterGoalLabel.text = "Mục Tiêu Hiện Tại: Nói chuyện với Tiếp Dẫn Chấp Sự và kiểm tra Đan Điền"
	chapterGoalLabel.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	v.add_child(chapterGoalLabel)

	btnAdvanceStory = Button.new()
	btnAdvanceStory.text = "Tiến Bước Cốt Truyện"
	btnAdvanceStory.custom_minimum_size = Vector2(180, 36)
	btnAdvanceStory.pressed.connect(_OnAdvanceStoryPressed)
	v.add_child(btnAdvanceStory)

# ------------------------------------------------------------------------------
# TAB 2: QUEST LOG
# ------------------------------------------------------------------------------
func _BuildQuestLogTab(parent : VBoxContainer):
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.set("theme_override_constants/separation", 10)
	parent.add_child(hbox)

	# Left Column: Category filter & Quest List
	var leftVBox = VBoxContainer.new()
	leftVBox.custom_minimum_size = Vector2(250, 0)
	hbox.add_child(leftVBox)

	questCategoryOption = OptionButton.new()
	questCategoryOption.add_item("Tất Cả Nhiệm Vụ", 0)
	questCategoryOption.add_item("Chính Tuyến (Main)", 1)
	questCategoryOption.add_item("Quan Hệ (NPC)", 2)
	questCategoryOption.add_item("Khám Phá (Side)", 3)
	questCategoryOption.add_item("Sự Kiện (Events)", 4)
	questCategoryOption.item_selected.connect(_OnQuestCategorySelected)
	leftVBox.add_child(questCategoryOption)

	questItemList = ItemList.new()
	questItemList.size_flags_vertical = Control.SIZE_EXPAND_FILL
	questItemList.item_selected.connect(_OnQuestSelected)
	leftVBox.add_child(questItemList)

	# Right Column: Details
	questDetailLabel = RichTextLabel.new()
	questDetailLabel.bbcode_enabled = true
	questDetailLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	questDetailLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(questDetailLabel)

# ------------------------------------------------------------------------------
# TAB 3: NPC DOSSIER & RELATIONSHIPS
# ------------------------------------------------------------------------------
func _BuildNpcDossierTab(parent : VBoxContainer):
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.set("theme_override_constants/separation", 10)
	parent.add_child(hbox)

	# Left Column: NPC List
	npcItemList = ItemList.new()
	npcItemList.custom_minimum_size = Vector2(220, 0)
	npcItemList.size_flags_vertical = Control.SIZE_EXPAND_FILL
	npcItemList.item_selected.connect(_OnNpcSelected)
	hbox.add_child(npcItemList)

	# Right Column: Dossier Details & Affinity
	var rightVBox = VBoxContainer.new()
	rightVBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rightVBox.set("theme_override_constants/separation", 8)
	hbox.add_child(rightVBox)

	npcDetailLabel = RichTextLabel.new()
	npcDetailLabel.bbcode_enabled = true
	npcDetailLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rightVBox.add_child(npcDetailLabel)

	var affHBox = HBoxContainer.new()
	affHBox.set("theme_override_constants/separation", 10)
	rightVBox.add_child(affHBox)

	npcAffinityText = Label.new()
	npcAffinityText.text = "Mức Độ Hảo Cảm:"
	affHBox.add_child(npcAffinityText)

	npcAffinityBar = ProgressBar.new()
	npcAffinityBar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	npcAffinityBar.max_value = 1000
	npcAffinityBar.step = 1
	affHBox.add_child(npcAffinityBar)

# ------------------------------------------------------------------------------
# TAB 4: CLUES & DEDUCTIONS
# ------------------------------------------------------------------------------
func _BuildCluesTab(parent : VBoxContainer):
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.set("theme_override_constants/separation", 10)
	parent.add_child(hbox)

	clueItemList = ItemList.new()
	clueItemList.custom_minimum_size = Vector2(240, 0)
	clueItemList.size_flags_vertical = Control.SIZE_EXPAND_FILL
	clueItemList.item_selected.connect(_OnClueSelected)
	hbox.add_child(clueItemList)

	clueDetailLabel = RichTextLabel.new()
	clueDetailLabel.bbcode_enabled = true
	clueDetailLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clueDetailLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(clueDetailLabel)

# ------------------------------------------------------------------------------
# TAB 5: WORLD EVENTS
# ------------------------------------------------------------------------------
func _BuildEventsTab(parent : VBoxContainer):
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.set("theme_override_constants/separation", 10)
	parent.add_child(hbox)

	var leftVBox = VBoxContainer.new()
	leftVBox.custom_minimum_size = Vector2(240, 0)
	hbox.add_child(leftVBox)

	eventsList = ItemList.new()
	eventsList.size_flags_vertical = Control.SIZE_EXPAND_FILL
	eventsList.item_selected.connect(_OnEventSelected)
	leftVBox.add_child(eventsList)

	btnTriggerEvent = Button.new()
	btnTriggerEvent.text = "Kích Hoạt Thử Nghiệm"
	btnTriggerEvent.pressed.connect(_OnTriggerEventPressed)
	leftVBox.add_child(btnTriggerEvent)

	eventDetailLabel = RichTextLabel.new()
	eventDetailLabel.bbcode_enabled = true
	eventDetailLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	eventDetailLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(eventDetailLabel)

# ==============================================================================
# DATA REFRESH & BINDINGS
# ==============================================================================

func Refresh(playerNode : Node = null):
	if playerNode:
		boundPlayer = playerNode
	elif not boundPlayer and Launcher.Player:
		boundPlayer = Launcher.Player

	_RefreshMainStory()
	_RefreshQuestList()
	_RefreshNpcDossier()
	_RefreshClues()
	_RefreshWorldEvents()

func _RefreshMainStory():
	if not chapterTitleLabel: return
	var curCh = StorySystemClass.GetCurrentChapter(boundPlayer)
	var chData = StorySystemClass.MAIN_STORY_CHAPTERS.get(curCh, {})
	chapterTitleLabel.text = chData.get("title", "Chương 1")
	chapterSynopsisLabel.text = "[color=#d8d8d8]%s[/color]" % chData.get("synopsis", "")
	var questId = chData.get("questId", "")
	chapterGoalLabel.text = "Mục Tiêu Cốt Truyện: Nhiệm vụ chính [%s]" % questId

func _RefreshQuestList():
	if not questItemList: return
	questItemList.clear()

	var cat = questCategoryOption.get_selected_id() if questCategoryOption else 0

	for qHash in DB.QuestsDB:
		var qData = DB.QuestsDB[qHash]
		var qName = qData.name
		var include = false
		match cat:
			0: include = true # All
			1: include = qName.contains("Chương") or qName.contains("Tỉnh Lạc") or qName.contains("Con Đường") or qName.contains("Dấu Vết") or qName.contains("Bí Mật Trong") or qName.contains("Thiên Đạo Có")
			2: include = qName.contains("Dược Điển") or qName.contains("Cứu Trợ") or qName.contains("Khoáng Thạch Thí") or qName.contains("Bí Quyết Truốt") or qName.contains("Huyết Tích") or qName.contains("Săn Bắt Dị") or qName.contains("Minh Văn") or qName.contains("Cổ Trận Thăm") or qName.contains("Đồng Môn") or qName.contains("Tâm Ma")
			3: include = qName.contains("Thám Hiểm") or qName.contains("Tìm Kiếm") or qName.contains("Giải Mã") or qName.contains("Bí Cảnh") or qName.contains("Khai Thác") or qName.contains("Điều Tra") or qName.contains("Bức Thư") or qName.contains("Tiếp Đón")
			4: include = qName.contains("Đẩy Lùi") or qName.contains("Thu Thập Tinh") or qName.contains("Ổn Định")
			_: include = true

		if include:
			var idx = questItemList.add_item(qName)
			questItemList.set_item_metadata(idx, qHash)

	if questItemList.item_count > 0:
		questItemList.select(0)
		_OnQuestSelected(0)

func _RefreshNpcDossier():
	if not npcItemList: return
	npcItemList.clear()
	var keys = StorySystemClass.NPC_DOSSIERS.keys()
	for i in keys.size():
		var nId = keys[i]
		var d = StorySystemClass.NPC_DOSSIERS[nId]
		var idx = npcItemList.add_item(d["name"])
		npcItemList.set_item_metadata(idx, nId)
		if nId == selectedNpcId:
			npcItemList.select(idx)

	_UpdateNpcDetail()

func _UpdateNpcDetail():
	if not npcDetailLabel: return
	var d = StorySystemClass.NPC_DOSSIERS.get(selectedNpcId, {})
	if d.is_empty(): return

	var aff = StorySystemClass.GetAffinity(boundPlayer, selectedNpcId)
	var rank = StorySystemClass.GetRelationshipRank(aff)
	var rankName = StorySystemClass.GetRankName(rank)
	var disc = StorySystemClass.GetNpcDiscount(boundPlayer, selectedNpcId)

	var text = "[b][color=#ffd700]%s[/color][/b] — [color=#66cdaa]%s[/color]\n" % [d["name"], d["title"]]
	text += "[color=#a0a0a0]Vị trí:[/color] %s\n" % d["location"]
	text += "[color=#a0a0a0]Tính cách:[/color] %s\n\n" % d["personality"]
	text += "[color=#dcdcdc]%s[/color]\n\n" % d["bio"]
	text += "[color=#ffd700]Mức độ quan hệ:[/color] [b]%s[/b] (%d Điểm Hảo Cảm)\n" % [rankName, aff]
	if disc > 0:
		text += "[color=#90ee90]Đặc quyền Tri Kỷ: Giảm giá giao thương %.0f%%![/color]\n" % (disc * 100)
	text += "[color=#ffa07a]Vật phẩm ưa thích:[/color] %s" % ", ".join(d.get("favoredItems", []))

	npcDetailLabel.text = text
	if npcAffinityBar:
		npcAffinityBar.value = aff
	if npcAffinityText:
		npcAffinityText.text = "Hảo Cảm: %s (%d/1000)" % [rankName, aff]

func _RefreshClues():
	if not clueItemList: return
	clueItemList.clear()
	var keys = StorySystemClass.STORY_CLUES.keys()
	var disc = StorySystemClass.GetDiscoveredClues(boundPlayer)

	for i in keys.size():
		var cId = keys[i]
		var cData = StorySystemClass.STORY_CLUES[cId]
		var isFound = (cId in disc)
		var label = cData["title"] if isFound else "??? (Chưa Lĩnh Ngộ)"
		var idx = clueItemList.add_item(label)
		clueItemList.set_item_metadata(idx, cId)
		if cId == selectedClueId:
			clueItemList.select(idx)

	_UpdateClueDetail()

func _UpdateClueDetail():
	if not clueDetailLabel: return
	var cData = StorySystemClass.STORY_CLUES.get(selectedClueId, {})
	if cData.is_empty(): return

	var disc = StorySystemClass.GetDiscoveredClues(boundPlayer)
	var isFound = (selectedClueId in disc)

	if not isFound:
		clueDetailLabel.text = "[center][color=#808080]\n\nManh mối này hiện chưa được khám phá.\nHãy tiếp tục theo dõi biến dị linh khí và di tích cổ trong các chương tiếp theo.[/color][/center]"
		return

	var text = "[b][color=#00e5ff]%s[/color][/b]\n" % cData["title"]
	text += "[color=#e0e0e0]Hiện Tượng Quan Sát:[/color]\n%s\n\n" % cData["content"]
	text += "[color=#ffd700]Góc Nhìn Suy Luận Hiện Đại:[/color]\n[color=#b4eeb4]%s[/color]" % cData["deduction"]
	clueDetailLabel.text = text

func _RefreshWorldEvents():
	if not eventsList: return
	eventsList.clear()
	var keys = StorySystemClass.WORLD_EVENTS_CATALOG.keys()
	for i in keys.size():
		var eId = keys[i]
		var ev = StorySystemClass.WORLD_EVENTS_CATALOG[eId]
		var active = StorySystemClass.IsEventActive(eId)
		var statusText = "[Đang Diễn Ra]" if active else "[Bình Thường]"
		var idx = eventsList.add_item("%s %s" % [ev["name"], statusText])
		eventsList.set_item_metadata(idx, eId)
		if eId == selectedEventId:
			eventsList.select(idx)

	_UpdateEventDetail()

func _UpdateEventDetail():
	if not eventDetailLabel: return
	var ev = StorySystemClass.WORLD_EVENTS_CATALOG.get(selectedEventId, {})
	if ev.is_empty(): return

	var active = StorySystemClass.IsEventActive(selectedEventId)
	var text = "[b][color=#ff6347]%s[/color][/b]\n" % ev["name"]
	text += "[color=#a0a0a0]Địa điểm:[/color] %s\n" % ev["location"]
	text += "[color=#a0a0a0]Trạng thái:[/color] %s\n\n" % ("[color=#00ff7f]ĐANG DIỄN RA[/color]" if active else "[color=#808080]Chờ Kích Hoạt[/color]")
	text += "[color=#dcdcdc]%s[/color]\n\n" % ev["description"]
	text += "[color=#ffd700]Phần Thưởng Chiến Tích:[/color]\n"
	text += "• Tu Vi: +%d  • Linh Thạch: +%d" % [ev.get("rewardExp", 0), ev.get("rewardGp", 0)]
	if ev.has("rewardContrib"):
		text += "  • Tông Môn Cống Hiến: +%d" % ev["rewardContrib"]
	if ev.has("rewardItem"):
		text += "\n• Kỳ Bảo: [%s] x%d" % [ev["rewardItem"], ev.get("rewardCount", 1)]

	eventDetailLabel.text = text

# ==============================================================================
# UI EVENT HANDLERS
# ==============================================================================

func _OnAdvanceStoryPressed():
	StorySystemClass.AdvanceStory(boundPlayer)
	_RefreshMainStory()
	_RefreshClues()

func _OnQuestCategorySelected(_index : int):
	_RefreshQuestList()

func _OnQuestSelected(index : int):
	var qHash = questItemList.get_item_metadata(index)
	var qData = DB.QuestsDB.get(qHash, null)
	if not qData: return

	var text = "[b][color=#ffd700]%s[/color][/b]\n" % qData.name
	text += "[color=#a0a0a0]Người giao:[/color] %s (%s)\n" % [qData.giver, qData.giverLocation]
	text += "[color=#a0a0a0]Mục tiêu:[/color] %s (%s)\n\n" % [qData.target, qData.targetLocation]
	text += "[color=#dcdcdc]%s[/color]\n\n" % qData.description
	text += "[color=#00ff7f]Phần thưởng:[/color] %s" % qData.reward
	questDetailLabel.text = text

func _OnNpcSelected(index : int):
	selectedNpcId = npcItemList.get_item_metadata(index)
	_UpdateNpcDetail()

func _OnClueSelected(index : int):
	selectedClueId = clueItemList.get_item_metadata(index)
	_UpdateClueDetail()

func _OnEventSelected(index : int):
	selectedEventId = eventsList.get_item_metadata(index)
	_UpdateEventDetail()

func _OnTriggerEventPressed():
	StorySystemClass.TriggerWorldEvent(selectedEventId, 1800)
	_RefreshWorldEvents()
