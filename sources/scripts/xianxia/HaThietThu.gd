extends NpcScript

## NPC Script: Hà Thiết Thủ (Luyện Khí Chấp Sự)
## Thiên Đạo Nghịch Mệnh — Build 08: Main Story & NPC Relationship

const StorySystemClass = preload("res://sources/story/StorySystem.gd")

func OnStart():
	var aff = StorySystemClass.GetAffinity(own, "HA_THIET_THU")
	var rank = StorySystemClass.GetRelationshipRank(aff)
	var rankName = StorySystemClass.GetRankName(rank)

	Mes("Hà Thiết Thủ gõ mạnh chiếc búa rèn xuống đe sắt, tiếng kêu vang dội gian phòng.")
	Mes("Quan hệ hiện tại: [%s] (Hảo cảm: %d điểm)." % [rankName, aff])

	if rank == StorySystemClass.RelationshipRank.STRANGER:
		Mes("Ngươi là đệ tử mới? Có mang khoáng thạch tốt đến đây rèn đúc không, hay chỉ đến ngắm nghía?")
	elif rank >= StorySystemClass.RelationshipRank.FRIENDLY:
		Mes("Khá lắm tiểu tử! Lại tới thảo luận về rèn binh khí hả? Lò lửa của ta lúc nào cũng sẵn sàng cho ngươi!")

	Choice("Nhận nhiệm vụ: Khoáng Thạch Thí Luyện (Cần 5 Huyền Thiết Khoáng)", OnQuest1)
	Choice("Nhận nhiệm vụ: Bí Quyết Truốt Kiếm (Cần 3 Xích Viêm Khoáng)", OnQuest2)
	Choice("Tặng khoáng thạch kết giao hảo cảm.", OnGiveGift)
	Choice("Thỉnh giáo kỹ thuật cường hóa vũ khí an toàn.", OnAskRefineAdvice)
	Choice("Cáo từ chấp sự.", Farewell)

func OnQuest1():
	var qId = ProgressCommons.Quest.NQ_HA_THIET_THU_1
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Tốt! Đi đào 5 khối Huyền Thiết Khoáng về đây. Để lão phu xem ngươi có phân biệt được tạp chất hay không!")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		var hasOre = HasItem(DB.GetCellHash("Huyen Thiet Khoang"), 5)
		if hasOre:
			RemoveItem(DB.GetCellHash("Huyen Thiet Khoang"), 5)
			SetQuest(qId, ProgressCommons.CompletedProgress)
			AddExp(150)
			AddGP(100)
			StorySystemClass.AddAffinity(own, "HA_THIET_THU", 50)
			Mes("Quặng sắt rất tinh thuần! Không tệ chút nào! Hà Thiết Thủ cười lớn vỗ vai đạo hữu (+50 Hảo Cảm)!")
		else:
			Mes("Vẫn chưa đủ 5 khối Huyền Thiết Khoáng. Hãy cầm cuốc ra các vách đá ngoài sơn môn mà gõ!")
	else:
		Mes("Ngươi đã hoàn thành thí luyện quặng sắt rồi, tay nghề phân loại quặng ngày càng tiến bộ.")

func OnQuest2():
	var qId = ProgressCommons.Quest.NQ_HA_THIET_THU_2
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Ta muốn rèn một thanh kiếm chứa hỏa khí mãnh liệt. Đi tìm 3 khối Xích Viêm Khoáng từ ổ quái thú về đây!")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		var hasOre = HasItem(DB.GetCellHash("Xich Viem Khoang"), 3)
		if hasOre:
			RemoveItem(DB.GetCellHash("Xich Viem Khoang"), 3)
			SetQuest(qId, ProgressCommons.CompletedProgress)
			AddExp(250)
			AddGP(150)
			StorySystemClass.AddAffinity(own, "HA_THIET_THU", 100)
			Mes("Xích Viêm Khoáng tỏa nhiệt rực lửa! Lão phu sẽ rèn thanh kiếm này thật uy mãnh (+100 Hảo Cảm)!")
		else:
			Mes("Vẫn thiếu Xích Viêm Khoáng. Loại quặng này chỉ rơi khi trảm sát yêu thú hoặc đào tại mỏ quặng sâu.")
	else:
		Mes("Thanh kiếm rèn bằng Xích Viêm Khoáng đợt trước sắc bén phi thường, lão phu rất hài lòng.")

func OnGiveGift():
	var oreHash = DB.GetCellHash("Huyen Thiet Khoang")
	var oreCell = DB.GetItem(oreHash)
	if oreCell and HasItem(oreHash, 1):
		StorySystemClass.GiveGiftToNpc(own, "HA_THIET_THU", oreCell)
		Mes("Hà Thiết Thủ ngắm nghía thỏi quặng sáng mắt: 'Quà tặng đúng ý ta! Đa tạ tiểu tử!'")
	else:
		Mes("Trong túi trữ vật không có quặng sắt phù hợp để tặng.")

func OnAskRefineAdvice():
	Mes("Hà Thiết Thủ gật gù giảng giải:")
	Mes("'Cường hóa trang bị từ +1 đến +3 chắc chắn thành công 100%. Lên đến +4 trở đi phải cẩn trọng, nếu thất bại dưới +4 sẽ không mất cấp, nhưng từ +4 trở lên thất bại sẽ tụt 1 cấp. Nhớ dùng nút Khóa Bảo Vệ để khỏi tay nhanh hơn não!'")
