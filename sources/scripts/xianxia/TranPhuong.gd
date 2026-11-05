extends NpcScript

## NPC Script: Trần Phương (Đồng Môn Đệ Tử)
## Thiên Đạo Nghịch Mệnh — Build 08: Main Story & NPC Relationship

const StorySystemClass = preload("res://sources/story/StorySystem.gd")

func OnStart():
	var aff = StorySystemClass.GetAffinity(own, "TRAN_PHUONG")
	var rank = StorySystemClass.GetRelationshipRank(aff)
	var rankName = StorySystemClass.GetRankName(rank)

	Mes("Trần Phương đang lau thanh kiếm gỗ, thấy đạo hữu đến liền mừng rỡ chạy lại.")
	Mes("Quan hệ hiện tại: [%s] (Hảo cảm: %d điểm)." % [rankName, aff])

	if rank == StorySystemClass.RelationshipRank.STRANGER:
		Mes("Chào đạo hữu! Huynh đệ chúng ta cùng nhập môn một ngày, sau này phải cùng cố gắng nhé!")
	elif rank >= StorySystemClass.RelationshipRank.FRIENDLY:
		Mes("Huynh đệ! Ngươi đến đúng lúc lắm! Hôm nay ta vừa ngộ ra chiêu thức mới, đang muốn khoe với ngươi đây!")

	Choice("Nhận nhiệm vụ: Đồng Môn Tương Trợ (Giúp Trần Phương 1 viên Bổ Khí Đan)", OnQuest1)
	Choice("Nhận nhiệm vụ: Tâm Ma Thử Thách (Luận kiếm giao lưu tại Diễn Võ Đài)", OnQuest2)
	Choice("Tặng trang bị / đan dược kết giao hảo cảm.", OnGiveGift)
	Choice("Tâm sự về lý tưởng tu đạo của những đệ tử bình dân.", OnChatIdeals)
	Choice("Cáo từ đồng môn.", Farewell)

func OnQuest1():
	var qId = ProgressCommons.Quest.NQ_TRAN_PHUONG_1
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Huynh đệ ơi, ta đang bế quan xung kích Tụ Khí tầng 2 nhưng thiếu linh khí đan dược. Ngươi có dư 1 viên Bổ Khí Đan hay Hồi Xuân Đan không?")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		var hasBoKhi = HasItem(DB.GetCellHash("Bo Khi Dan"), 1)
		var hasHoiXuan = HasItem(DB.GetCellHash("Hoi Xuan Dan"), 1)
		if hasBoKhi or hasHoiXuan:
			if hasBoKhi:
				RemoveItem(DB.GetCellHash("Bo Khi Dan"), 1)
			else:
				RemoveItem(DB.GetCellHash("Hoi Xuan Dan"), 1)
			SetQuest(qId, ProgressCommons.CompletedProgress)
			AddExp(100)
			AddGP(50)
			StorySystemClass.AddAffinity(own, "TRAN_PHUONG", 60)
			Mes("Đa tạ huynh đệ! Tình nghĩa này Trần Phương ta khắc cốt ghi tâm (+60 Hảo Cảm)!")
		else:
			Mes("Chưa có đan dược bồi bổ à? Không sao, khi nào có mang cho ta cũng được!")
	else:
		Mes("Nhờ viên đan dược của ngươi mà ta đã đả thông kinh mạch thành công rồi!")

func OnQuest2():
	var qId = ProgressCommons.Quest.NQ_TRAN_PHUONG_2
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Gần đây kiếm tâm của ta có chút bế tắc, cần một trận luận kiếm giao hữu để phá trừ tâm ma. Huynh đệ cùng ta tỉ thí vài chiêu nhé!")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		SetQuest(qId, ProgressCommons.CompletedProgress)
		AddExp(200)
		AddGP(100)
		StorySystemClass.AddAffinity(own, "TRAN_PHUONG", 100)
		Mes("Kiếm pháp của ngươi sắc bén và khoáng đạt quá! Trần Phương khâm phục sát đất (+100 Hảo Cảm)!")
	else:
		Mes("Trận luận kiếm đợt trước đã khai sáng cho ta rất nhiều, cảm ơn huynh đệ!")

func OnGiveGift():
	var swordHash = DB.GetCellHash("Thanh Phong Kiem")
	var swordCell = DB.GetItem(swordHash)
	if swordCell and HasItem(swordHash, 1):
		StorySystemClass.GiveGiftToNpc(own, "TRAN_PHUONG", swordCell)
		Mes("Trần Phương xúc động ôm thanh kiếm: 'Bảo kiếm tốt thế này ngươi cũng tặng ta sao? Huynh đệ tốt cả đời!'")
	else:
		Mes("Trong túi trữ vật không có vật phẩm phù hợp để tặng Trần Phương.")

func OnChatIdeals():
	Mes("Trần Phương nhìn về phía đỉnh Trúc Sơn mây phủ, chia sẻ:")
	Mes("'Nhà ta ba đời làm nông, ta bước vào con đường tu tiên chỉ mong thay đổi số phận gia tộc. Ta biết tư chất mình kém, nhưng chỉ cần kiên trì không bỏ cuộc, kiến cũng có ngày leo tới đỉnh non cao!'")
