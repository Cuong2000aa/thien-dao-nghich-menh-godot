extends NpcScript

## NPC Script: Khang Vạn Kim (Du Phương Thương Nhân)
## Thiên Đạo Nghịch Mệnh — Build 08: Main Story & NPC Relationship

const StorySystemClass = preload("res://sources/story/StorySystem.gd")

func OnStart():
	var aff = StorySystemClass.GetAffinity(own, "KHANG_VAN_KIM")
	var rank = StorySystemClass.GetRelationshipRank(aff)
	var rankName = StorySystemClass.GetRankName(rank)
	var disc = StorySystemClass.GetNpcDiscount(own, "KHANG_VAN_KIM")

	Mes("Khang Vạn Kim lắc chiếc bàn tính vàng lách cách, miệng cười tươi như hoa nở.")
	Mes("Quan hệ hiện tại: [%s] (Hảo cảm: %d điểm)." % [rankName, aff])
	if disc > 0:
		Mes("Ưu đãi hảo hữu: Giảm giá mua hàng [%.0f%%] cho đạo hữu!" % (disc * 100))

	if rank == StorySystemClass.RelationshipRank.STRANGER:
		Mes("Khách quan có mắt nhìn người thật tinh tường! Hàng hóa của Khang mỗ từ khắp cửu châu tụ hội, không thiếu kỳ trân dị bảo nào!")
	elif rank >= StorySystemClass.RelationshipRank.FRIENDLY:
		Mes("Chào cố nhân! Nhìn thấy đạo hữu là thấy tài lộc gõ cửa! Hôm nay ta có mấy món đồ quý vừa nhập về, xem qua chút nhé?")

	Choice("Nhận nhiệm vụ: Tiếp Đón Du Phương Thương Đội (Giao 2 Ngân Linh Thảo & 2 Huyền Thiết Khoáng)", OnQuest1)
	Choice("Tặng quà linh thạch / bảo châu kết giao hảo cảm.", OnGiveGift)
	Choice("Hỏi thăm tình hình tin tức dị tượng từ các đại lục khác.", OnAskWorldNews)
	Choice("Cáo từ chưởng quỹ.", Farewell)

func OnQuest1():
	var qId = ProgressCommons.Quest.SQ_DU_PHUONG_GIAO_THUONG
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Thương đội của ta đang cần gom gấp 2 cọng Ngân Linh Thảo và 2 khối Huyền Thiết Khoáng để chuyển hàng chuyến tới. Đạo hữu chia sẻ giúp ta nhé, giá thu mua bảo đảm cao nhất vùng!")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		var hasHerb = HasItem(DB.GetCellHash("Ngan Linh Thao"), 2)
		var hasOre = HasItem(DB.GetCellHash("Huyen Thiet Khoang"), 2)
		if hasHerb and hasOre:
			RemoveItem(DB.GetCellHash("Ngan Linh Thao"), 2)
			RemoveItem(DB.GetCellHash("Huyen Thiet Khoang"), 2)
			SetQuest(qId, ProgressCommons.CompletedProgress)
			AddExp(150)
			AddGP(200)
			StorySystemClass.AddAffinity(own, "KHANG_VAN_KIM", 60)
			Mes("Giao thương sảng khoái! Khang Vạn Kim trao túi linh thạch căng phồng cho đạo hữu (+60 Hảo Cảm)!")
		else:
			Mes("Vẫn thiếu nguyên liệu. Ta cần đủ 2 Ngân Linh Thảo và 2 Huyền Thiết Khoáng nguyên chất.")
	else:
		Mes("Chuyến hàng đợt trước giao thương rất thuận lợi, đa tạ đạo hữu đã giúp đỡ.")

func OnGiveGift():
	var gemHash = DB.GetCellHash("Linh Thach Thuong Pham")
	var gemCell = DB.GetItem(gemHash)
	if gemCell and HasItem(gemHash, 1):
		StorySystemClass.GiveGiftToNpc(own, "KHANG_VAN_KIM", gemCell)
		Mes("Khang Vạn Kim tròn xoe mắt: 'Linh Thạch Thượng Phẩm thuần khiết! Đạo hữu quả là hào sảng khôn cùng!'")
	else:
		Mes("Trong túi trữ vật không có linh thạch quý hay kỳ trân phù hợp để tặng Khang Vạn Kim.")

func OnAskWorldNews():
	Mes("Khang Vạn Kim nhìn trước ngó sau rồi thì thầm:")
	Mes("'Không chỉ riêng Trúc Sơn này đâu khách quan. Tại Đông Hải, linh tuyền ngàn năm cũng tự nhiên cạn kiệt; ở Bắc Hoang, lôi kiếp giáng xuống liên tục mà không có ai đột phá. Thiên hạ này... hình như quy tắc trời đất sắp biến đổi lớn rồi!'")
