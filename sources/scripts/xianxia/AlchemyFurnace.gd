extends NpcScript
class_name AlchemyFurnace

var selectedRecipe : String = ""

func OnStart():
	if not IsPlayer():
		return
	Mes("Trước mặt đạo hữu là Bát Quái Luyện Đan Lô của Trúc Sơn Tông. Lửa linh hỏa đang bập bùng cháy, tỏa ra hương thảo mộc thanh khiết.")
	Mes("Hãy chọn công thức muốn luyện chế:")
	
	Choice("Luyện Hồi Xuân Dược (2 Linh Trùng Tương, 1 Ngân Linh Thảo)", ChooseRecipe.bind("HOI_XUAN"))
	Choice("Luyện Bổ Khí Đan (1 Linh Trùng Tương, 2 Ngân Linh Thảo)", ChooseRecipe.bind("BO_KHI"))
	Choice("Rèn Thanh Phong Tinh Thiết (2 Huyền Thiết Khoáng)", ChooseRecipe.bind("TINH_THIET"))
	Choice("Rời đi")

func ChooseRecipe(recipe : String):
	selectedRecipe = recipe
	var slimeID : int = DB.GetCellHash("Maggot Slime")
	var herbID : int = DB.GetCellHash("Ngan Linh Thao")
	var oreID : int = DB.GetCellHash("Huyen Thiet Khoang")
	
	var slimeCell : ItemCell = DB.GetItem(slimeID)
	var herbCell : ItemCell = DB.GetItem(herbID)
	var oreCell : ItemCell = DB.GetItem(oreID)
	
	match recipe:
		"HOI_XUAN":
			var slimeCount : int = own.inventory.GetItemCount(slimeCell) if slimeCell else 0
			var herbCount : int = own.inventory.GetItemCount(herbCell) if herbCell else 0
			if slimeCount < 2 or herbCount < 1:
				Mes("Nguyên liệu không đủ! Cần 2 Linh Trùng Tương (có: %d) và 1 Ngân Linh Thảo (có: %d)." % [slimeCount, herbCount])
				return
			StartCrafting("Hồi Xuân Dược", 25)
		"BO_KHI":
			var slimeCount : int = own.inventory.GetItemCount(slimeCell) if slimeCell else 0
			var herbCount : int = own.inventory.GetItemCount(herbCell) if herbCell else 0
			if slimeCount < 1 or herbCount < 2:
				Mes("Nguyên liệu không đủ! Cần 1 Linh Trùng Tương (có: %d) và 2 Ngân Linh Thảo (có: %d)." % [slimeCount, herbCount])
				return
			StartCrafting("Bổ Khí Đan", 25)
		"TINH_THIET":
			var oreCount : int = own.inventory.GetItemCount(oreCell) if oreCell else 0
			if oreCount < 2:
				Mes("Nguyên liệu không đủ! Cần 2 Huyền Thiết Khoáng (có: %d)." % oreCount)
				return
			StartCrafting("Thanh Phong Tinh Thiết", 30)

func StartCrafting(resultName : String, expGain : int):
	DisplayTracker("Đang ngưng đan %s..." % resultName, 0, 5, "")
	AddTimer(own, 0.3, OnCraftTick.bind(resultName, expGain, 0), "crafting_tick")

func OnCraftTick(resultName : String, expGain : int, tick : int):
	if not own or not is_instance_valid(own):
		return
	if tick >= 5:
		ClearTracker()
		CompleteCrafting(resultName, expGain)
	else:
		DisplayTracker("Đang ngưng đan %s..." % resultName, tick + 1, 5, "")
		AddTimer(own, 0.3, OnCraftTick.bind(resultName, expGain, tick + 1), "crafting_tick")

func CompleteCrafting(resultName : String, expGain : int):
	var slimeID : int = DB.GetCellHash("Maggot Slime")
	var herbID : int = DB.GetCellHash("Ngan Linh Thao")
	var oreID : int = DB.GetCellHash("Huyen Thiet Khoang")
	
	match selectedRecipe:
		"HOI_XUAN":
			NpcCommons.RemoveItem(own, slimeID, 2)
			NpcCommons.RemoveItem(own, herbID, 1)
			var resultID : int = DB.GetCellHash("Hoi Xuan Dan")
			NpcCommons.AddItem(own, resultID, 1)
			_CheckAlchemyQuest()
		"BO_KHI":
			NpcCommons.RemoveItem(own, slimeID, 1)
			NpcCommons.RemoveItem(own, herbID, 2)
			var resultID : int = DB.GetCellHash("Bo Khi Dan")
			NpcCommons.AddItem(own, resultID, 1)
		"TINH_THIET":
			NpcCommons.RemoveItem(own, oreID, 2)
			var resultID : int = DB.GetCellHash("Thanh Phong Tinh Thiet")
			NpcCommons.AddItem(own, resultID, 1)

	NpcCommons.AddExp(own, expGain)
	var CraftingSystemClass = preload("res://sources/crafting/CraftingSystem.gd")
	if selectedRecipe == "TINH_THIET":
		CraftingSystemClass.AddProfessionExp(own, CraftingSystemClass.Profession.FORGEMASTER, expGain)
	else:
		CraftingSystemClass.AddProfessionExp(own, CraftingSystemClass.Profession.ALCHEMIST, expGain)
	Notification("Luyện chế thành công: %s x1 (+%d Tu Vi)!" % [resultName, expGain])
	Mes("Lò luyện đan mở nắp, đan hương ngào ngạt! %s đã được thu vào túi trữ vật." % resultName)

func _CheckAlchemyQuest():
	var qID : int = ProgressCommons.Quest.LUYEN_DAN_NHAP_MON
	var state : int = own.progress.GetQuest(qID)
	if state == ProgressCommons.LUYEN_DAN_NHAP_MON.STARTED:
		NpcCommons.SetQuest(own, qID, ProgressCommons.LUYEN_DAN_NHAP_MON.OBJECTIVE_MET)
		Notification("Nhiệm vụ hoàn thành: Đã luyện thành công Hồi Xuân Dược! Hãy đến gặp Đạo Huyền Trưởng Lão.")
		NpcCommons.PushTracker(own, "Luyện Đan Nhập Môn", 1, 1)
