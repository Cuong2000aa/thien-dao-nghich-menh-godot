extends WindowPanel

const Cultivation = preload("res://sources/actor/Cultivation.gd")
const Localization = preload("res://sources/system/Localization.gd")
const QuestGuidanceClass = preload("res://sources/quest/QuestGuidance.gd")

# Control accessors
@onready var activeQuestContainer : Container		= $Layout/Margin/TabBar/QuestLog/QuestScroll/QuestList/Active
@onready var completedQuestContainer : Container	= $Layout/Margin/TabBar/QuestLog/QuestScroll/QuestList/Completed
@onready var questSeparator : Separator				= $Layout/Margin/TabBar/QuestLog/QuestScroll/QuestList/HSeparator
@onready var questDescription : RichTextLabel		= $Layout/Margin/TabBar/QuestLog/Description
@onready var bestiaryContainer : Container			= $Layout/Margin/TabBar/Manapedia/BestiaryList/Monsters
@onready var bestiaryLabel : RichTextLabel			= $Layout/Margin/TabBar/Manapedia/BestiaryList/BestiaryLabel


# Quest variables
var quests : Dictionary[int, MenuLine]				= {}
var activeQuests : Dictionary[int, bool]			= {}
var completedQuests : Dictionary[int, bool]			= {}
var currentQuest : int								= DB.UnknownHash

# Bestiary variables
var bestiaries : Dictionary[int, MenuLine]			= {}

# Common progress functions
func Clear():
	for questID in activeQuests.keys():
		activeQuestContainer.remove_child.call_deferred(quests[questID])
		quests[questID].queue_free()
	activeQuests.clear()
	for questID in completedQuests.keys():
		completedQuestContainer.remove_child.call_deferred(quests[questID])
		quests[questID].queue_free()
	completedQuests.clear()
	quests.clear()
	questSeparator.set_visible(false)
	questDescription.set_text("")
	currentQuest = DB.UnknownHash

	for monster in bestiaries.keys():
		bestiaryContainer.remove_child.call_deferred(bestiaries[monster])
		bestiaries[monster].queue_free()
	bestiaries.clear()
	bestiaryLabel.set_visible(false)

# Bestiary
func RefreshBestiary(mobID : int, count : int):
	var entityData : EntityData = DB.GetEntity(mobID)
	if not entityData:
		return

	var menuLine : MenuLine = bestiaries.get(mobID)
	if not menuLine:
		menuLine = MenuLine.new(mobID, entityData._name)
		menuLine.set_pressed(false)
		menuLine.set_disabled(true)
		bestiaries[mobID] = menuLine
		bestiaryContainer.add_child.call_deferred(menuLine)

	var mobDisplayName : String = Cultivation.GetItemDisplayName(entityData._name)
	menuLine.set_text("%s (Trảm sát: %d)" % [mobDisplayName, count])

	if not bestiaryLabel.is_visible():
		bestiaryLabel.set_visible(true)

# Quest Log
func RefreshQuest(questID : int, state : int):
	var questData : QuestData = DB.GetQuest(questID)
	if not questData:
		return

	var isComplete : bool = state == ProgressCommons.CompletedProgress
	var questTitle : String = Localization.Get(questData.name, questData.name)
	var menuLine : MenuLine = quests.get(questID)
	if not menuLine:
		menuLine = MenuLine.new(questID, questTitle)
		menuLine.set_pressed(true)
		menuLine.line_selected.connect(RefreshQuestDescription)
		quests[questID] = menuLine

	if isComplete:
		if activeQuests.get(questID, false):
			activeQuestContainer.remove_child.call_deferred(menuLine)
			activeQuests.erase(questID)
		if not completedQuests.get(questID, false):
			completedQuestContainer.add_child.call_deferred(menuLine)
			completedQuests[questID] = true
			menuLine.set_text("%s (Hoàn Thành)" % questTitle)
	else:
		if completedQuests.get(questID, false):
			completedQuestContainer.remove_child.call_deferred(menuLine)
			completedQuests.erase(questID)
		if not activeQuests.get(questID, false):
			activeQuestContainer.add_child.call_deferred(menuLine)
			activeQuests[questID] = true
			menuLine.set_text("%s" % questTitle)

	questSeparator.set_visible(not activeQuests.is_empty() and not completedQuests.is_empty())
	menuLine.Enable(not isComplete)

	if currentQuest == DB.UnknownHash:
		RefreshQuestDescription(questID)
	elif currentQuest == questID:
		# Force redraw current quest description to reflect updated progress
		currentQuest = DB.UnknownHash
		RefreshQuestDescription(questID)

func RefreshQuestDescription(questID : int):
	if questID == currentQuest:
		return

	currentQuest = questID
	questDescription.text = "\n"

	var questData : QuestData = DB.GetQuest(questID)
	if not questData:
		return

	var qState : int = 0
	if Launcher.Player and Launcher.Player.progress:
		qState = Launcher.Player.progress.GetQuest(questID)

	if not questData.description.is_empty():
		var questDesc : String = Localization.Get(questData.description, questData.description)
		questDescription.text += "Mô Tả:\n[color=#%s]%s[/color]\n\n" % [UICommons.TextColor.to_html(false), questDesc]
	if not questData.giver.is_empty():
		questDescription.text += "Người Giao:\n[color=#%s]%s" % [UICommons.WarnTextColor.to_html(false), questData.giver]
		if not questData.giverLocation.is_empty():
			questDescription.text += " (%s)" % questData.giverLocation
		questDescription.text += "[/color]\n\n"
	if not questData.target.is_empty():
		questDescription.text += "Mục Tiêu:\n[color=#%s]%s" % [UICommons.WarnTextColor.to_html(false), questData.target]
		if not questData.targetLocation.is_empty():
			questDescription.text += " (%s)" % questData.targetLocation
		questDescription.text += "[/color]\n\n"

	# Live progress indicator
	if qState == ProgressCommons.CompletedProgress:
		questDescription.text += "Tiến Độ:\n[color=#66ff66]✔ Đã hoàn thành[/color]\n\n"
	elif qState >= ProgressCommons.THANH_TRU_LINH_TRUNG.STARTED and questID == ProgressCommons.Quest.THANH_TRU_LINH_TRUNG:
		var kills : int = mini(qState - 1, 5)
		if kills >= 5:
			questDescription.text += "Tiến Độ:\n[color=#ffd700]✔ Đã tiêu diệt 5/5 Linh Trùng — Hãy trở về gặp Đạo Huyền Trưởng Lão[/color]\n\n"
		else:
			questDescription.text += "Tiến Độ:\n[color=#4db8ff]⚔ Đang thực hiện: %d/5 Linh Trùng[/color]\n\n" % kills

	# Precise map guidance (spawn-resolved)
	if qState > ProgressCommons.UnknownProgress and qState < ProgressCommons.CompletedProgress:
		var step : Dictionary = QuestGuidanceClass.BuildStep(questID, qState)
		if not step.is_empty():
			questDescription.text += "Chỉ Dẫn Bản Đồ:\n%s\n\n" % QuestGuidanceClass.FormatStepRich(step)
			if step.get("resolved", false) and Launcher.Map and int(step.get("map_id", -1)) == Launcher.Map.currentMapID:
				questDescription.text += "[url=goto_quest]▶ Đi tới mục tiêu trên map[/url]\n\n"

	if not questData.reward.is_empty():
		questDescription.text += "Phần Thưởng:\n[color=#%s]%s[/color]\n\n" % [UICommons.WarnTextColor.to_html(false), questData.reward]

func _ready():
	var tab = get_node_or_null("Layout/Margin/TabBar")
	if tab and tab is TabContainer:
		tab.set_tab_title(0, "Nhiệm Vụ / Ủy Thác")
		tab.set_tab_title(1, "Yêu Thú Đồ Giám")
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.PolishWindow(self)
	if questDescription:
		ThemeClass.AccentRichText(questDescription)
		if not questDescription.meta_clicked.is_connected(_OnQuestMetaClicked):
			questDescription.meta_clicked.connect(_OnQuestMetaClicked)

func _OnQuestMetaClicked(meta : Variant) -> void:
	if str(meta) != "goto_quest":
		return
	if currentQuest == DB.UnknownHash or Launcher.Player == null:
		return
	var state : int = Launcher.Player.progress.GetQuest(currentQuest) if Launcher.Player.progress else 0
	var step : Dictionary = QuestGuidanceClass.BuildStep(currentQuest, state)
	if step.is_empty() or not step.get("resolved", false):
		return
	if Launcher.Map and int(step.get("map_id", -1)) == Launcher.Map.currentMapID and Launcher.Action:
		Launcher.Action.MoveTo(step.get("position", Vector2.ZERO))
