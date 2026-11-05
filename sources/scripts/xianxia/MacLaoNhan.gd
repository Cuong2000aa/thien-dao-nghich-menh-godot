extends NpcScript

## NPC Script: Mặc Lão Nhân (Cổ Trận Kỳ Nhân)
## Thiên Đạo Nghịch Mệnh — Build 08: Main Story & NPC Relationship

const StorySystemClass = preload("res://sources/story/StorySystem.gd")

func OnStart():
	var aff = StorySystemClass.GetAffinity(own, "MAC_LAO_NHAN")
	var rank = StorySystemClass.GetRelationshipRank(aff)
	var rankName = StorySystemClass.GetRankName(rank)

	Mes("Mặc Lão Nhân đang chống gậy trúc, say sưa dùng ngón tay vẽ các đường đồ hình lên cát.")
	Mes("Quan hệ hiện tại: [%s] (Hảo cảm: %d điểm)." % [rankName, aff])

	if rank == StorySystemClass.RelationshipRank.STRANGER:
		Mes("Lại một tên đệ tử mù quáng tin vào chính sử của tông môn? Đi đi, lão phu không rảnh tiếp đãi kẻ vô tri.")
	elif rank >= StorySystemClass.RelationshipRank.FRIENDLY:
		Mes("Khá lắm tiểu tử mang tư duy dị giới! Ngươi nhìn ra sai số 7.3 độ của thiên văn trận đồ rồi đúng không? Lại đây đàm đạo!")

	Choice("Nhận nhiệm vụ: Minh Văn Trận Phù (Tìm 3 Mảnh Trận Phù Cổ)", OnQuest1)
	Choice("Nhận nhiệm vụ: Cổ Trận Thăm Dò (Đo lường tâm điểm Ngũ Hành Thạch Trận)", OnQuest2)
	Choice("Tặng cổ tịch / linh bảo kết giao hảo cảm.", OnGiveGift)
	Choice("Thỉnh giáo chân tướng về 'Đại Kiếp Liệt Thiên' vạn năm trước.", OnAskCataclysmLore)
	Choice("Cáo từ tiền bối.", Farewell)

func OnQuest1():
	var qId = ProgressCommons.Quest.NQ_MAC_LAO_NHAN_1
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Xung quanh bia đá có nhiều mảnh trận phù cổ rơi vãi bị đất vùi. Hãy nhặt 3 mảnh về đây để lão phu đối chiếu nét khắc.")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		SetQuest(qId, ProgressCommons.CompletedProgress)
		AddExp(160)
		AddGP(100)
		StorySystemClass.AddAffinity(own, "MAC_LAO_NHAN", 60)
		StorySystemClass.UnlockClue(own, "CLUE_3_ANCIENT_CONFLICT")
		Mes("Chính xác là phù văn thời tiền kiếp! Mặc Lão Nhân vuốt râu cười khoái trá (+60 Hảo Cảm)!")
	else:
		Mes("Các mảnh trận phù đợt trước đã giúp lão phu phục dựng được nửa trang bản đồ cổ động.")

func OnQuest2():
	var qId = ProgressCommons.Quest.NQ_MAC_LAO_NHAN_2
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Ngũ Hành Thạch Trận phía trước đang phát ra tần số dị thường. Hãy đến tâm điểm thạch trận đo lường chu kỳ rồi báo lại cho lão phu.")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		SetQuest(qId, ProgressCommons.CompletedProgress)
		AddExp(320)
		AddGP(200)
		StorySystemClass.AddAffinity(own, "MAC_LAO_NHAN", 100)
		StorySystemClass.UnlockClue(own, "CLUE_4_ARRAY_DRIFT")
		Mes("Chu kỳ dao động quả nhiên bị lệch 7.3 độ! Lão phu biết ngay mà! Ngươi thật sự có con mắt quan sát tinh tường (+100 Hảo Cảm)!")
	else:
		Mes("Thạch trận hiện tại đang ở trạng thái cân bằng tạm thời, không nên tác động bừa bãi.")

func OnGiveGift():
	var bkHash = DB.GetCellHash("Co Bi Bi Kip")
	var bkCell = DB.GetItem(bkHash)
	if bkCell and HasItem(bkHash, 1):
		StorySystemClass.GiveGiftToNpc(own, "MAC_LAO_NHAN", bkCell)
		Mes("Mặc Lão Nhân nâng niu cuốn bí kíp cổ: 'Báu vật! Đây chính là thứ lão phu tìm kiếm bao năm!'")
	else:
		Mes("Trong túi trữ vật không có cổ tịch hay kỳ bảo phù hợp để tặng Mặc Lão Nhân.")

func OnAskCataclysmLore():
	Mes("Mặc Lão Nhân nhìn lên bầu trời xa xăm, giọng trầm xuống:")
	Mes("'Vạn năm trước, một trận đại kiếp đã xé toạc một góc thiên quy. Các vị đại năng cổ đại dùng cả tính mạng để chắp vá, nhưng vết nứt vẫn luôn tồn tại rò rỉ hỗn mang. Thiên Đạo không phải thù địch của chúng ta... mà là một cỗ máy khổng lồ đang chạy với bánh răng vỡ!'")
	StorySystemClass.UnlockClue(own, "CLUE_5_DAMAGED_DAO")
