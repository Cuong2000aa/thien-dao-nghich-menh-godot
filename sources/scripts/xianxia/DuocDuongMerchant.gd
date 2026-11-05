extends MerchantScript
class_name DuocDuongMerchant

func GetStock() -> PackedStringArray:
	return ["Hoi Xuan Dan", "Bo Khi Dan", "Thanh Tam Dan", "U Hon Thao", "Bottle"]

func GetBuyPrice(cell : ItemCell) -> int:
	match cell.name:
		"Hoi Xuan Dan": return 100
		"Bo Khi Dan": return 80
		"Thanh Tam Dan": return 300
		"U Hon Thao": return 80
		"Bottle": return 20
		_: return cell.buyPrice

func GetSellPrice(cell : ItemCell) -> int:
	match cell.name:
		"Maggot Slime": return 15
		"Ngan Linh Thao": return 25
		"Huyen Thiet Khoang": return 35
		"Thanh Phong Tinh Thiet": return 80
		"Short Sword": return 150
		_: return mini(cell.sellPrice, 20)

func OnStart():
	if not IsPlayer():
		return
	Mes("Bần đạo là Dược Đường Chấp Sự của Trúc Sơn Tông. Nơi đây chuyên cung ứng đan dược trị thương, bổ khí và thu mua linh thảo, khoáng thạch do đệ tử lịch luyện mang về.")
	
	Choice("Mở Dược Các giao thương", OpenShop)
	
	var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
	var herbQID : int = ProgressCommons.Quest.CONG_HIEN_DUOC_THAO
	var herbState : int = own.progress.GetQuest(herbQID)
	if herbState == ProgressCommons.UnknownProgress:
		Choice("Nhận nhiệm vụ: Cống Hiến Dược Thảo (0/3 Ngân Linh Thảo)", OnAcceptHerbSectQuest)
	elif herbState >= ProgressCommons.CONG_HIEN_DUOC_THAO.STARTED and herbState < ProgressCommons.CONG_HIEN_DUOC_THAO.OBJECTIVE_MET:
		Choice("Giao nộp 3 Ngân Linh Thảo cho Dược Đường", OnTurnInHerbSectQuest)
	elif herbState == ProgressCommons.CONG_HIEN_DUOC_THAO.OBJECTIVE_MET:
		Choice("Nhận thưởng Cống Hiến Dược Thảo (+45 Cống Hiến, +50 Tu Vi)", OnCompleteHerbSectQuest)

	Choice("Quyên góp Ngân Linh Thảo đổi lấy Điểm Cống Hiến Tông Môn (+15/cây)", OnDonateHerb)
	Choice("Quyên góp Hồi Xuân Đan đổi Điểm Cống Hiến Tông Môn (+10/viên)", OnDonatePill)
	Choice("Thỉnh giáo thuật Luyện Đan (Nghề Luyện Đan Sư)", OnAlchemistMentorship)
	
	var oreQuestID : int = ProgressCommons.Quest.THU_THAP_KHOANG_THACH
	var oreState : int = own.progress.GetQuest(oreQuestID)
	
	if oreState == ProgressCommons.UnknownProgress:
		Choice("Hỏi thăm nhu cầu linh khoáng", AcceptOreQuest)
	elif oreState == ProgressCommons.THU_THAP_KHOANG_THACH.OBJECTIVE_MET:
		Choice("Giao nộp 2 Huyền Thiết Khoáng", TurnInOreQuest)
		
	Choice("Cáo từ")

func AcceptOreQuest():
	var oreQuestID : int = ProgressCommons.Quest.THU_THAP_KHOANG_THACH
	NpcCommons.SetQuest(own, oreQuestID, ProgressCommons.THU_THAP_KHOANG_THACH.STARTED)
	Notification("Đã nhận nhiệm vụ: Thu Thập Khoáng Thạch!")
	NpcCommons.PushTracker(own, "Khai thác Huyền Thiết", 0, 2)
	Mes("Gần đây Khí Các đang rèn thêm phi kiếm cho đệ tử mới nhập môn, rất thiếu Huyền Thiết Khoáng. Đạo hữu nếu có thể khai thác 2 khối mang về, bần đạo sẽ thưởng 1 khối Thanh Phong Tinh Thiết và linh thạch thỏa đáng.")

func TurnInOreQuest():
	var oreID : int = DB.GetCellHash("Huyen Thiet Khoang")
	var oreCell : ItemCell = DB.GetItem(oreID)
	var count : int = own.inventory.GetItemCount(oreCell) if oreCell else 0
	if count < 2:
		Mes("Trong túi đạo hữu dường như không đủ 2 Huyền Thiết Khoáng.")
		return
		
	NpcCommons.RemoveItem(own, oreID, 2)
	var oreQuestID : int = ProgressCommons.Quest.THU_THAP_KHOANG_THACH
	NpcCommons.SetQuest(own, oreQuestID, ProgressCommons.CompletedProgress)
	
	NpcCommons.AddExp(own, 120)
	NpcCommons.AddGP(own, 180)
	var refinedID : int = DB.GetCellHash("Thanh Phong Tinh Thiet")
	NpcCommons.AddItem(own, refinedID, 1)
	
	Notification("Hoàn thành nhiệm vụ: Thu Thập Khoáng Thạch! (+120 Tu Vi, +180 Linh Thạch, nhận 1 Thanh Phong Tinh Thiết)")
	NpcCommons.ClearTracker(own)
	Mes("Đa tạ đạo hữu! Hai khối Huyền Thiết Khoáng này chất lượng cực tốt, Khí Các chắc chắn sẽ rất hài lòng.")

func OnAcceptHerbSectQuest():
	var herbQID : int = ProgressCommons.Quest.CONG_HIEN_DUOC_THAO
	NpcCommons.SetQuest(own, herbQID, ProgressCommons.CONG_HIEN_DUOC_THAO.STARTED)
	Notification("Đã nhận nhiệm vụ môn phái: Cống Hiến Dược Thảo!")
	Mes("Dược Đường rất cần Ngân Linh Thảo tươi để tinh luyện Hồi Xuân Đan. Đạo hữu hãy thu thập 3 cọng mang lại đây.")

func OnTurnInHerbSectQuest():
	var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
	var res = SectSystemClass.DonateResource(own, "Ngan Linh Thao", 3)
	if res["success"]:
		var herbQID : int = ProgressCommons.Quest.CONG_HIEN_DUOC_THAO
		NpcCommons.SetQuest(own, herbQID, ProgressCommons.CONG_HIEN_DUOC_THAO.OBJECTIVE_MET)
		Mes("Tốt lắm! 3 cọng Ngân Linh Thảo này phẩm chất thanh khiết, nguyệt hoa chi khí nồng đậm.")
		OnCompleteHerbSectQuest()
	else:
		Mes("Chưa đủ dược thảo: %s" % res["message"])

func OnCompleteHerbSectQuest():
	var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
	var herbQID : int = ProgressCommons.Quest.CONG_HIEN_DUOC_THAO
	NpcCommons.SetQuest(own, herbQID, ProgressCommons.CompletedProgress)
	SectSystemClass.AddContribution(own, 45, "Hoàn thành Cống Hiến Dược Thảo")
	NpcCommons.AddExp(own, 50)
	var pillCell = DB.GetItem(DB.GetCellHash("Hoi Xuan Dan"))
	if pillCell and own.get("inventory"):
		own.inventory.AddItem(pillCell, 1)
	Notification("Hoàn thành Cống Hiến Dược Thảo! (+45 Cống Hiến, +50 Tu Vi, 1 Hồi Xuân Đan)")
	Mes("Đa tạ đạo hữu đã đóng góp dược thảo quý giá cho kho thuốc của tông môn!")

func OnDonateHerb():
	var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
	var res = SectSystemClass.DonateResource(own, "Ngan Linh Thao", 1)
	if res["success"]:
		Mes(res["message"])
		Notification("+15 CỐNG HIẾN MÔN PHÁI!")
	else:
		Mes(res["message"])

func OnDonatePill():
	var CraftingSystemClass = preload("res://sources/crafting/CraftingSystem.gd")
	var pillCell = DB.GetItem(DB.GetCellHash("Hoi Xuan Dan"))
	var res = CraftingSystemClass.DonateCraftedItem(own, pillCell, 1)
	Mes(res["message"])

func OnAlchemistMentorship():
	var CraftingSystemClass = preload("res://sources/crafting/CraftingSystem.gd")
	var pData = CraftingSystemClass.GetProfessionData(own, CraftingSystemClass.Profession.ALCHEMIST)
	var rName = CraftingSystemClass.GetRankName(pData["rank"])
	Mes("Luyện Đan Sư chi đạo: Nhất tâm thấu triệt dược tính, nhị tâm khống chế hỏa hầu, tam tâm thủ hộ đan phách. Cấp bậc hiện tại của đạo hữu: [%s] (EXP: %d)." % [rName, pData["exp"]])
	Mes("Luyện chế càng nhiều đan dược thì kinh nghiệm nghề càng thăng hoa, mở khóa các phương thuốc cao cấp như Trúc Cơ Đan và Xích Viêm Đan.")
