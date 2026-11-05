extends WindowPanel
class_name CraftingWindow

## TDNM — BUILD 07: CULTIVATION ECONOMY & CRAFTING GUI
## Comprehensive Xianxia Crafting Interface unifying Alchemy (Luyện Đan), 
## Forging (Luyện Khí), Refinement (Cường Hóa), Spiritual Treasures (Pháp Bảo),
## and the 4 Cultivation Professions (Nghề Nghiệp).

const CraftingSystemClass = preload("res://sources/crafting/CraftingSystem.gd")
const CultivationClass = preload("res://sources/actor/Cultivation.gd")
const Localization = preload("res://sources/system/Localization.gd")

var tabContainer : TabContainer = null

# Tabs
var alchemyTab : VBoxContainer = null
var forgeTab : VBoxContainer = null
var refineTab : VBoxContainer = null
var treasureTab : VBoxContainer = null
var profTab : VBoxContainer = null

# Alchemy Controls
var furnaceOption : OptionButton = null
var alchemyRecipeList : ItemList = null
var alchemyDetailLabel : RichTextLabel = null
var btnBrew : Button = null
var selectedAlchemyId : String = "HOI_XUAN"

# Forging Controls
var forgeRecipeList : ItemList = null
var forgeDetailLabel : RichTextLabel = null
var btnForge : Button = null
var selectedForgeId : String = "THANH_PHONG_KIEM"

# Refine Controls
var refineItemList : ItemList = null
var refineDetailLabel : RichTextLabel = null
var btnEnhance : Button = null
var btnRefineAffix : Button = null
var btnToggleLock : Button = null
var btnDismantle : Button = null
var selectedEquipmentCell : ItemCell = null
var selectedEquipmentIndex : int = -1

# Spiritual Treasure Controls
var treasureDetailLabel : RichTextLabel = null
var btnActivateQuyKinh : Button = null
var btnActivateHoaHo : Button = null
var btnActivateTuLinhDinh : Button = null

# Professions Controls
var profContainer : VBoxContainer = null

var boundPlayer : Actor = null

func _init():
	name = "CraftingWindow"
	custom_minimum_size = Vector2(660, 560)
	size = Vector2(660, 560)
	floating = true
	draggable = true
	visible = false

func _ready():
	_BuildUI()
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

	# Header
	var title = Label.new()
	title.text = "BÁCH NGHỆ TU TIÊN & LUYỆN CHẾ BẢO VẬT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	rootVBox.add_child(title)

	# Tab Container
	tabContainer = TabContainer.new()
	tabContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rootVBox.add_child(tabContainer)

	# Tab 1: Luyện Đan
	alchemyTab = VBoxContainer.new()
	alchemyTab.name = "Luyện Đan"
	tabContainer.add_child(alchemyTab)
	_BuildAlchemyTab()

	# Tab 2: Luyện Khí
	forgeTab = VBoxContainer.new()
	forgeTab.name = "Luyện Khí"
	tabContainer.add_child(forgeTab)
	_BuildForgeTab()

	# Tab 3: Cường Hóa & Tinh Luyện
	refineTab = VBoxContainer.new()
	refineTab.name = "Cường Hóa"
	tabContainer.add_child(refineTab)
	_BuildRefineTab()

	# Tab 4: Pháp Bảo
	treasureTab = VBoxContainer.new()
	treasureTab.name = "Pháp Bảo"
	tabContainer.add_child(treasureTab)
	_BuildTreasureTab()

	# Tab 5: Nghề Nghiệp
	profTab = VBoxContainer.new()
	profTab.name = "Nghề Nghiệp"
	tabContainer.add_child(profTab)
	_BuildProfTab()

	# Close Button
	var btnClose = Button.new()
	btnClose.text = "Đóng Cửa Sổ"
	btnClose.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btnClose.custom_minimum_size = Vector2(140, 32)
	btnClose.pressed.connect(ToggleControl)
	rootVBox.add_child(btnClose)

# ==============================================================================
# TAB 1: LUYỆN ĐAN (ALCHEMY)
# ==============================================================================
func _BuildAlchemyTab():
	var hTop = HBoxContainer.new()
	hTop.set("theme_override_constants/separation", 10)
	alchemyTab.add_child(hTop)

	var lblFurnace = Label.new()
	lblFurnace.text = "Lò Luyện Đan:"
	lblFurnace.add_theme_color_override("font_color", Color(0.9, 0.9, 0.6))
	hTop.add_child(lblFurnace)

	furnaceOption = OptionButton.new()
	furnaceOption.add_item("Thanh Đồng Đỉnh (Cơ bản)", CraftingSystemClass.FurnaceTier.THANH_DONG)
	furnaceOption.add_item("Bát Quái Luyện Đan Lô (+15% Tỷ lệ)", CraftingSystemClass.FurnaceTier.BAT_QUAI)
	furnaceOption.add_item("Tử Ngọc Lô (+30% Tỷ lệ, x2 Cực Phẩm)", CraftingSystemClass.FurnaceTier.TU_NGOC)
	furnaceOption.selected = 1
	furnaceOption.item_selected.connect(func(_idx): _UpdateAlchemyDetails())
	hTop.add_child(furnaceOption)

	var hSplit = HBoxContainer.new()
	hSplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hSplit.set("theme_override_constants/separation", 10)
	alchemyTab.add_child(hSplit)

	alchemyRecipeList = ItemList.new()
	alchemyRecipeList.custom_minimum_size = Vector2(220, 0)
	alchemyRecipeList.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for rId in CraftingSystemClass.ALCHEMY_RECIPES:
		var rec = CraftingSystemClass.ALCHEMY_RECIPES[rId]
		alchemyRecipeList.add_item("%s (%s)" % [rec["name"], rec["category"]])
	alchemyRecipeList.item_selected.connect(_OnAlchemySelected)
	hSplit.add_child(alchemyRecipeList)

	var vRight = VBoxContainer.new()
	vRight.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vRight.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hSplit.add_child(vRight)

	alchemyDetailLabel = RichTextLabel.new()
	alchemyDetailLabel.bbcode_enabled = true
	alchemyDetailLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vRight.add_child(alchemyDetailLabel)

	btnBrew = Button.new()
	btnBrew.text = "Bắt Đầu Luyện Đan"
	btnBrew.custom_minimum_size = Vector2(0, 36)
	btnBrew.pressed.connect(_OnBrewPressed)
	vRight.add_child(btnBrew)

func _OnAlchemySelected(index : int):
	var keys = CraftingSystemClass.ALCHEMY_RECIPES.keys()
	if index >= 0 and index < keys.size():
		selectedAlchemyId = keys[index]
		_UpdateAlchemyDetails()

func _UpdateAlchemyDetails():
	var p = _GetPlayer()
	if not p or not CraftingSystemClass.ALCHEMY_RECIPES.has(selectedAlchemyId):
		return
	var rec = CraftingSystemClass.ALCHEMY_RECIPES[selectedAlchemyId]
	var fTier = furnaceOption.get_selected_id() if furnaceOption else CraftingSystemClass.FurnaceTier.BAT_QUAI
	var check = CraftingSystemClass.CanBrewElixir(p, selectedAlchemyId, fTier)

	var txt = "[b][color=#ffd700]%s[/color][/b] [color=#88ccff][%s][/color]\n" % [rec["name"], rec["category"]]
	txt += "[color=#cccccc]%s[/color]\n\n" % rec["effectDesc"]
	txt += "• Cấp bậc yêu cầu: [color=#88ff88]%s[/color] • Cảnh giới: [color=#88ff88]Cấp %d[/color]\n" % [CraftingSystemClass.GetRankName(rec["professionReq"]), rec["levelReq"]]
	txt += "• Tỷ lệ thành công dự kiến: [b][color=%s]%.1f%%[/color][/b]\n\n" % ["#55ff55" if check["successRate"] >= 0.7 else "#ffaa44", check["successRate"] * 100.0]

	txt += "[b]Nguyên Liệu Yêu Cầu:[/b]\n"
	for matName in rec["materials"]:
		var req = rec["materials"][matName]
		var matHash = DB.GetCellHash(matName)
		var matCell = DB.ItemsDB.get(matHash, null)
		var has = p.inventory.GetItemCount(matCell) if matCell and p and p.inventory else 0
		var col = "#88ff88" if has >= req else "#ff5555"
		txt += "  - %s: [color=%s]%d/%d[/color]\n" % [matName, col, has, req]

	if not check["canCraft"]:
		txt += "\n[color=#ff5555]Chưa thể luyện chế: %s[/color]" % check["reason"]
		btnBrew.disabled = true
	else:
		btnBrew.disabled = false

	alchemyDetailLabel.text = txt

func _OnBrewPressed():
	var p = _GetPlayer()
	var fTier = furnaceOption.get_selected_id() if furnaceOption else CraftingSystemClass.FurnaceTier.BAT_QUAI
	var res = CraftingSystemClass.BrewElixir(p, selectedAlchemyId, fTier)
	Refresh()

# ==============================================================================
# TAB 2: LUYỆN KHÍ (FORGING)
# ==============================================================================
func _BuildForgeTab():
	var hSplit = HBoxContainer.new()
	hSplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hSplit.set("theme_override_constants/separation", 10)
	forgeTab.add_child(hSplit)

	forgeRecipeList = ItemList.new()
	forgeRecipeList.custom_minimum_size = Vector2(220, 0)
	forgeRecipeList.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for rId in CraftingSystemClass.FORGE_RECIPES:
		var rec = CraftingSystemClass.FORGE_RECIPES[rId]
		forgeRecipeList.add_item("%s (%s)" % [rec["name"], rec["category"]])
	forgeRecipeList.item_selected.connect(_OnForgeSelected)
	hSplit.add_child(forgeRecipeList)

	var vRight = VBoxContainer.new()
	vRight.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vRight.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hSplit.add_child(vRight)

	forgeDetailLabel = RichTextLabel.new()
	forgeDetailLabel.bbcode_enabled = true
	forgeDetailLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vRight.add_child(forgeDetailLabel)

	btnForge = Button.new()
	btnForge.text = "Bắt Đầu Rèn Đúc"
	btnForge.custom_minimum_size = Vector2(0, 36)
	btnForge.pressed.connect(_OnForgePressed)
	vRight.add_child(btnForge)

func _OnForgeSelected(index : int):
	var keys = CraftingSystemClass.FORGE_RECIPES.keys()
	if index >= 0 and index < keys.size():
		selectedForgeId = keys[index]
		_UpdateForgeDetails()

func _UpdateForgeDetails():
	var p = _GetPlayer()
	if not p or not CraftingSystemClass.FORGE_RECIPES.has(selectedForgeId):
		return
	var rec = CraftingSystemClass.FORGE_RECIPES[selectedForgeId]
	var check = CraftingSystemClass.CanForge(p, selectedForgeId)

	var txt = "[b][color=#ffd700]%s[/color][/b] [color=#88ccff][%s][/color]\n" % [rec["name"], rec["category"]]
	txt += "[color=#cccccc]%s[/color]\n\n" % rec["effectDesc"]
	txt += "• Cấp bậc yêu cầu: [color=#88ff88]%s[/color] • Cảnh giới: [color=#88ff88]Cấp %d[/color]\n\n" % [CraftingSystemClass.GetRankName(rec["professionReq"]), rec["levelReq"]]

	txt += "[b]Khoáng Thạch & Vật Liệu Yêu Cầu:[/b]\n"
	for matName in rec["materials"]:
		var req = rec["materials"][matName]
		var matHash = DB.GetCellHash(matName)
		var matCell = DB.ItemsDB.get(matHash, null)
		var has = p.inventory.GetItemCount(matCell) if matCell and p and p.inventory else 0
		var col = "#88ff88" if has >= req else "#ff5555"
		txt += "  - %s: [color=%s]%d/%d[/color]\n" % [matName, col, has, req]

	if not check["canForge"]:
		txt += "\n[color=#ff5555]Chưa thể rèn: %s[/color]" % check["reason"]
		btnForge.disabled = true
	else:
		btnForge.disabled = false

	forgeDetailLabel.text = txt

func _OnForgePressed():
	var p = _GetPlayer()
	var res = CraftingSystemClass.ForgeEquipment(p, selectedForgeId)
	Refresh()

# ==============================================================================
# TAB 3: CƯỜNG HÓA & TINH LUYỆN (REFINEMENT)
# ==============================================================================
func _BuildRefineTab():
	var hSplit = HBoxContainer.new()
	hSplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hSplit.set("theme_override_constants/separation", 10)
	refineTab.add_child(hSplit)

	refineItemList = ItemList.new()
	refineItemList.custom_minimum_size = Vector2(220, 0)
	refineItemList.size_flags_vertical = Control.SIZE_EXPAND_FILL
	refineItemList.item_selected.connect(_OnEquipmentSelected)
	hSplit.add_child(refineItemList)

	var vRight = VBoxContainer.new()
	vRight.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vRight.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hSplit.add_child(vRight)

	refineDetailLabel = RichTextLabel.new()
	refineDetailLabel.bbcode_enabled = true
	refineDetailLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vRight.add_child(refineDetailLabel)

	var hActions = HBoxContainer.new()
	hActions.set("theme_override_constants/separation", 6)
	vRight.add_child(hActions)

	btnEnhance = Button.new()
	btnEnhance.text = "Cường Hóa (+1)"
	btnEnhance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btnEnhance.pressed.connect(_OnEnhancePressed)
	hActions.add_child(btnEnhance)

	btnRefineAffix = Button.new()
	btnRefineAffix.text = "Tinh Luyện Từ Điều"
	btnRefineAffix.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btnRefineAffix.pressed.connect(_OnRefineAffixPressed)
	hActions.add_child(btnRefineAffix)

	btnToggleLock = Button.new()
	btnToggleLock.text = "Khóa Trang Bị"
	btnToggleLock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btnToggleLock.pressed.connect(_OnToggleLockPressed)
	hActions.add_child(btnToggleLock)

	btnDismantle = Button.new()
	btnDismantle.text = "Phân Giải"
	btnDismantle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btnDismantle.pressed.connect(_OnDismantlePressed)
	hActions.add_child(btnDismantle)

func _PopulateRefineItemList():
	refineItemList.clear()
	var p = _GetPlayer()
	if not p or not p.inventory:
		return
	var idx = 0
	for it in p.inventory.items:
		var c = DB.ItemsDB.get(it.cellID, null)
		if c and c.slot != ActorCommons.Slot.NONE:
			var ref = CraftingSystemClass.GetRefinementData(p, c, it.cellCustomfield)
			var lockStr = " [🔒]" if ref["isLocked"] else ""
			refineItemList.add_item("%s +%d%s" % [c.name, ref["enhanceLevel"], lockStr])
			refineItemList.set_item_metadata(refineItemList.item_count - 1, { "cell": c, "index": idx, "custom": it.cellCustomfield })
		idx += 1

func _OnEquipmentSelected(index : int):
	var meta = refineItemList.get_item_metadata(index)
	if meta:
		selectedEquipmentCell = meta["cell"]
		selectedEquipmentIndex = meta["index"]
		_UpdateRefineDetails()

func _UpdateRefineDetails():
	var p = _GetPlayer()
	if not p or not selectedEquipmentCell:
		refineDetailLabel.text = "[color=#888888]Hãy chọn một trang bị từ danh sách bên trái để cường hóa hoặc tinh luyện.[/color]"
		btnEnhance.disabled = true
		btnRefineAffix.disabled = true
		btnToggleLock.disabled = true
		btnDismantle.disabled = true
		return

	var ref = CraftingSystemClass.GetRefinementData(p, selectedEquipmentCell)
	var curLvl = ref["enhanceLevel"]
	var rate = CraftingSystemClass.GetEnhanceSuccessRate(curLvl)
	var reqOre = curLvl + 1
	var reqGP = (curLvl + 1) * 50

	var oreHash = DB.GetCellHash("Huyen Thiet Khoang")
	var oreCell = DB.ItemsDB.get(oreHash, null)
	var hasOre = p.inventory.GetItemCount(oreCell) if oreCell and p and p.inventory else 0
	var hasGP = p.stat.current.gold if p and p.stat else 0

	var txt = "[b][color=#ffd700]%s +%d[/color][/b]\n" % [selectedEquipmentCell.name, curLvl]
	txt += "• Trạng thái: %s\n" % ("[color=#ff5555]ĐÃ KHÓA BẢO VỆ[/color]" if ref["isLocked"] else "[color=#55ff55]Bình thường[/color]")
	txt += "• Gia tăng thuộc tính cường hóa: [color=#88ff88]+%d%%[/color] (Cấp tiếp theo: +%d%%)\n" % [curLvl * 10, (curLvl + 1) * 10]
	txt += "• Tỷ lệ thành công: [b][color=%s]%.0f%%[/color][/b]\n\n" % ["#55ff55" if rate >= 0.7 else "#ffaa44", rate * 100]

	txt += "[b]Nguyên Liệu Cường Hóa:[/b]\n"
	txt += "  - Huyền Thiết Khoáng: [color=%s]%d/%d[/color]\n" % ["#88ff88" if hasOre >= reqOre else "#ff5555", hasOre, reqOre]
	txt += "  - Linh Thạch: [color=%s]%d/%d GP[/color]\n\n" % ["#88ff88" if hasGP >= reqGP else "#ff5555", hasGP, reqGP]

	if not ref["affixes"].is_empty():
		txt += "[b]Từ Điều Tinh Luyện:[/b]\n"
		for k in ref["affixes"]:
			txt += "  - [color=#88ccff]%s: +%.1f%%[/color]\n" % [k, ref["affixes"][k] * 100]

	refineDetailLabel.text = txt
	btnEnhance.disabled = ref["isLocked"] or curLvl >= 9
	btnRefineAffix.disabled = ref["isLocked"]
	btnDismantle.disabled = ref["isLocked"]
	btnToggleLock.text = "Mở Khóa" if ref["isLocked"] else "Khóa Trang Bị"

func _OnEnhancePressed():
	var p = _GetPlayer()
	CraftingSystemClass.EnhanceEquipment(p, selectedEquipmentCell)
	Refresh()

func _OnRefineAffixPressed():
	var p = _GetPlayer()
	CraftingSystemClass.RefineAffixes(p, selectedEquipmentCell)
	Refresh()

func _OnToggleLockPressed():
	var p = _GetPlayer()
	CraftingSystemClass.ToggleLockItem(p, selectedEquipmentCell)
	Refresh()

func _OnDismantlePressed():
	var p = _GetPlayer()
	CraftingSystemClass.DismantleEquipment(p, selectedEquipmentCell, selectedEquipmentIndex)
	selectedEquipmentCell = null
	Refresh()

# ==============================================================================
# TAB 4: PHÁP BẢO (SPIRITUAL TREASURES)
# ==============================================================================
func _BuildTreasureTab():
	treasureDetailLabel = RichTextLabel.new()
	treasureDetailLabel.bbcode_enabled = true
	treasureDetailLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	treasureTab.add_child(treasureDetailLabel)

	var hBtns = HBoxContainer.new()
	hBtns.set("theme_override_constants/separation", 8)
	treasureTab.add_child(hBtns)

	btnActivateQuyKinh = Button.new()
	btnActivateQuyKinh.text = "Kích Hoạt: Huyền Quy Kính"
	btnActivateQuyKinh.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btnActivateQuyKinh.pressed.connect(func(): CraftingSystemClass.ActivateSpiritualTreasure(_GetPlayer(), "HUYEN_QUY_KINH"); Refresh())
	hBtns.add_child(btnActivateQuyKinh)

	btnActivateHoaHo = Button.new()
	btnActivateHoaHo.text = "Tế Xuất: Xích Viêm Hỏa Hồ"
	btnActivateHoaHo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btnActivateHoaHo.pressed.connect(func(): CraftingSystemClass.ActivateSpiritualTreasure(_GetPlayer(), "XICH_VIEM_HOA_HO"); Refresh())
	hBtns.add_child(btnActivateHoaHo)

	btnActivateTuLinhDinh = Button.new()
	btnActivateTuLinhDinh.text = "Vận Chuyển: Càn Khôn Đỉnh"
	btnActivateTuLinhDinh.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btnActivateTuLinhDinh.pressed.connect(func(): CraftingSystemClass.ActivateSpiritualTreasure(_GetPlayer(), "CAN_KHON_TU_LINH_DINH"); Refresh())
	hBtns.add_child(btnActivateTuLinhDinh)

func _UpdateTreasureTab():
	var p = _GetPlayer()
	if not p:
		return
	var txt = "[b][color=#ffd700]PHÁP BẢO BẢN MỆNH & THƯỢNG CỔ LINH KHÍ[/color][/b]\n"
	txt += "[color=#cccccc]Pháp bảo là bảo vật tối cao của người tu tiên, hấp thu thiên địa linh khí, ngưng kết linh tính tương thông với thức hải tu sĩ.[/color]\n\n"

	var resQuyKinh = CraftingSystemClass.GetTreasureResonance(p, "HUYEN_QUY_KINH")
	var resHoaHo = CraftingSystemClass.GetTreasureResonance(p, "XICH_VIEM_HOA_HO")
	var resDinh = CraftingSystemClass.GetTreasureResonance(p, "CAN_KHON_TU_LINH_DINH")

	txt += "1. [b][color=#88ccff]Huyền Quy Kính[/color][/b] [color=#aaaaaa](Pháp Bảo Phòng Ngự • Huyền Giai Thượng Phẩm)[/color]\n"
	txt += "   • Kỹ năng: [color=#88ff88]Huyền Quy Hộ Thể[/color] — Tạo khiên 200 HP, giảm 50% sát thương (30 MP, CD: 25s).\n"
	txt += "   • Độ cộng hưởng linh căn: [b][color=#ffd700]%.0f%%[/color][/b]\n\n" % [resQuyKinh * 100]

	txt += "2. [b][color=#ff8866]Xích Viêm Hỏa Hồ[/color][/b] [color=#aaaaaa](Pháp Bảo Công Kích • Địa Giai Sơ Kỳ)[/color]\n"
	txt += "   • Kỹ năng: [color=#88ff88]Xích Viêm Hỏa Long[/color] — Phun lửa 180 sát thương + thiêu đốt 15 dmg/s (45 MP, CD: 18s).\n"
	txt += "   • Độ cộng hưởng linh căn: [b][color=#ffd700]%.0f%%[/color][/b]\n\n" % [resHoaHo * 100]

	txt += "3. [b][color=#88ff88]Càn Khôn Tụ Linh Đỉnh[/color][/b] [color=#aaaaaa](Pháp Bảo Tu Luyện • Huyền Giai Cực Phẩm)[/color]\n"
	txt += "   • Bị động: +5 hồi phục MP/5s.\n"
	txt += "   • Kỹ năng: [color=#88ff88]Càn Khôn Thôn Hấp[/color] — Hồi 100 MP, +50 Tu Vi, tăng 50% tốc độ tu luyện trong 60s (CD: 40s).\n"
	txt += "   • Độ cộng hưởng linh căn: [b][color=#ffd700]%.0f%%[/color][/b]\n" % [resDinh * 100]

	treasureDetailLabel.text = txt

# ==============================================================================
# TAB 5: NGHỀ NGHIỆP TU TIÊN (PROFESSIONS)
# ==============================================================================
func _BuildProfTab():
	profContainer = VBoxContainer.new()
	profContainer.set("theme_override_constants/separation", 10)
	profTab.add_child(profContainer)

func _UpdateProfTab():
	for c in profContainer.get_children():
		c.queue_free()

	var p = _GetPlayer()
	if not p:
		return
	var profs = [
		{ "id": CraftingSystemClass.Profession.ALCHEMIST, "name": "Luyện Đan Sư", "desc": "Tinh thông dược lý, dung hợp thảo mộc ngưng kết thần đan bồi bổ tu vi." },
		{ "id": CraftingSystemClass.Profession.FORGEMASTER, "name": "Luyện Khí Sư", "desc": "Thấu triệt tính chất quặng sắt, tôi luyện thần binh phi kiếm và chiến giáp." },
		{ "id": CraftingSystemClass.Profession.HERBALIST, "name": "Linh Thực Sư", "desc": "Mắt sáng phân định thảo mộc, hái linh dược bảo tồn nguyên vẹn linh tính." },
		{ "id": CraftingSystemClass.Profession.MINER, "name": "Khai Khoáng Sư", "desc": "Khai phá thạch mạch cổ xưa, dò tìm khoáng thạch quý hiếm sâu trong lòng đất." }
	]

	for pr in profs:
		var pData = CraftingSystemClass.GetProfessionData(p, pr["id"])
		var rName = CraftingSystemClass.GetRankName(pData["rank"])

		var box = PanelContainer.new()
		var vb = VBoxContainer.new()
		vb.set("theme_override_constants/separation", 4)
		box.add_child(vb)

		var lblName = Label.new()
		lblName.text = "Nghề: %s — Cấp Bậc: [%s]" % [pr["name"], rName]
		lblName.add_theme_font_size_override("font_size", 14)
		lblName.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
		vb.add_child(lblName)

		var lblDesc = Label.new()
		lblDesc.text = pr["desc"]
		lblDesc.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		vb.add_child(lblDesc)

		var pBar = ProgressBar.new()
		pBar.min_value = 0
		pBar.max_value = 1500
		pBar.value = pData["exp"]
		pBar.custom_minimum_size = Vector2(0, 18)
		vb.add_child(pBar)

		var lblExp = Label.new()
		lblExp.text = "Kinh nghiệm nghề nghiệp: %d / 1500 Điểm Lĩnh Hội" % pData["exp"]
		lblExp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lblExp.add_theme_font_size_override("font_size", 11)
		lblExp.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
		vb.add_child(lblExp)

		profContainer.add_child(box)

# ==============================================================================
# REFRESH & BINDINGS
# ==============================================================================
func Refresh(customPlayer : Actor = null):
	if customPlayer:
		boundPlayer = customPlayer
	_UpdateAlchemyDetails()
	_UpdateForgeDetails()
	_PopulateRefineItemList()
	_UpdateRefineDetails()
	_UpdateTreasureTab()
	_UpdateProfTab()

func _GetPlayer() -> Actor:
	if boundPlayer and is_instance_valid(boundPlayer):
		return boundPlayer
	if Launcher.Player and is_instance_valid(Launcher.Player):
		return Launcher.Player
	return null
