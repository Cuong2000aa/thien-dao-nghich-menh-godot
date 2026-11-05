extends NpcScript

## NPC Script: Luyện Khí Chấp Sự (Sect Forge Master Deacon)
## Manages ore donation, refining and equipment enhancement for sect disciples.

const SectSystemClass = preload("res://sources/sect/SectSystem.gd")

const QUEST_ORE : int = ProgressCommons.Quest.CONG_HIEN_KHOANG_THACH

func OnStart():
	if not own or not own.stat:
		Farewell()
		return
		
	var rank : int = SectSystemClass.GetDiscipleRank(own)
	var rankName : String = SectSystemClass.GetDiscipleRankName(rank)
	var contrib : int = SectSystemClass.GetContribution(own)
	
	Mes("Chào %s. Lò rèn Luyện Khí Đường luôn rực lửa để đúc kiếm và giáp trụ cho tông môn." % rankName)
	Mes("Điểm Cống Hiến hiện tại của ngươi: [%d Điểm]." % contrib)
	
	var qState : int = GetQuest(QUEST_ORE)
	if qState == ProgressCommons.UnknownProgress:
		Choice("Nhận nhiệm vụ: Cống Hiến Khoáng Thạch (0/2 Huyền Thiết Khoáng)", OnAcceptOreQuest)
	elif qState >= ProgressCommons.CONG_HIEN_KHOANG_THACH.STARTED and qState < ProgressCommons.CONG_HIEN_KHOANG_THACH.OBJECTIVE_MET:
		Choice("Giao nộp 2 Huyền Thiết Khoáng cho Luyện Khí Đường", OnTurnInOreQuest)
	elif qState == ProgressCommons.CONG_HIEN_KHOANG_THACH.OBJECTIVE_MET:
		Choice("Nhận thưởng nhiệm vụ Cống Hiến Khoáng Thạch", OnCompleteOreQuest)
		
	Choice("Quyên góp khoáng thạch đổi lấy Điểm Cống Hiến.", OnDonateOre)
	Choice("Quyên góp Thanh Phong Kiếm cho Tông Môn (+50 Cống Hiến)", OnDonateWeapon)
	Choice("Thỉnh giáo thuật Luyện Khí (Nghề Luyện Khí Sư).", OnExplainForging)
	Choice("Cáo từ Luyện Khí Chấp Sự.", Farewell)

func OnAcceptOreQuest():
	SetQuest(QUEST_ORE, ProgressCommons.CONG_HIEN_KHOANG_THACH.STARTED)
	Mes("Lò rèn đang thiếu Huyền Thiết Khoáng để nung chảy. Hãy mang 2 quặng Huyền Thiết Khoáng lại đây.")
	NpcCommons.PushNotification(own, "ĐÃ NHẬN NHIỆM VỤ: [Cống Hiến Khoáng Thạch]!")
	Choice("Đệ tử sẽ đi khai thác ngay.", Farewell)

func OnTurnInOreQuest():
	var res = SectSystemClass.DonateResource(own, "Huyen Thiet Khoang", 2)
	if res["success"]:
		SetQuest(QUEST_ORE, ProgressCommons.CONG_HIEN_KHOANG_THACH.OBJECTIVE_MET)
		Mes("Tốt lắm! 2 khối Huyền Thiết Khoáng này phẩm chất rất đặc, thích hợp rèn đúc phi kiếm.")
		Choice("Nhận thưởng hoàn thành", OnCompleteOreQuest)
	else:
		Mes("Chưa đủ khoáng thạch: %s" % res["message"])
		Choice("Đệ tử sẽ tìm thêm.", Farewell)

func OnCompleteOreQuest():
	SetQuest(QUEST_ORE, ProgressCommons.CompletedProgress)
	SectSystemClass.AddContribution(own, 40, "Hoàn thành Cống Hiến Khoáng Thạch")
	if own.get("stat"):
		own.stat.SetExperience(60)
	var ingotCell = DB.GetItem(DB.GetCellHash("Thanh Phong Tinh Thiet"))
	if ingotCell and own.get("inventory"):
		own.inventory.AddItem(ingotCell, 1)
	Mes("HOÀN THÀNH NHIỆM VỤ! Ngươi nhận được 40 Điểm Cống Hiến, 60 Tu Vi và 1 Thanh Phong Tinh Thiết.")
	NpcCommons.PushNotification(own, "+40 CỐNG HIẾN & 1 TINH THIẾT!")
	Choice("Đa tạ Chấp sự!", Farewell)

func OnDonateOre():
	var res = SectSystemClass.DonateResource(own, "Huyen Thiet Khoang", 1)
	if res["success"]:
		Mes(res["message"])
		NpcCommons.PushNotification(own, "+20 CỐNG HIẾN MÔN PHÁI!")
	else:
		Mes(res["message"])
	Choice("Trở lại.", OnStart)
	Choice("Cáo từ.", Farewell)

func OnDonateWeapon():
	var CraftingSystemClass = preload("res://sources/crafting/CraftingSystem.gd")
	var weaponCell = DB.GetItem(DB.GetCellHash("Thanh Phong Kiem"))
	var res = CraftingSystemClass.DonateCraftedItem(own, weaponCell, 1)
	Mes(res["message"])
	Choice("Trở lại.", OnStart)
	Choice("Cáo từ.", Farewell)

func OnExplainForging():
	var CraftingSystemClass = preload("res://sources/crafting/CraftingSystem.gd")
	var pData = CraftingSystemClass.GetProfessionData(own, CraftingSystemClass.Profession.FORGEMASTER)
	var rName = CraftingSystemClass.GetRankName(pData["rank"])
	Mes("Luyện Khí chi đạo: Tụ hỏa chi tinh, dung luyện phàm thiết thành linh thiết, khắc nhập kiếm ý và linh trận. Cấp bậc Luyện Khí Sư hiện tại: [%s] (EXP: %d)." % [rName, pData["exp"]])
	Mes("Rèn đúc phi kiếm và chiến giáp sẽ tăng trưởng trình độ, mở khóa Bạch Ngân Kiếm, Huyền Thiết Giáp và các pháp bảo thượng cổ như Huyền Quy Kính.")
	Choice("Đệ tử đã hiểu rõ.", OnStart)
