extends NpcScript

## NPC Script: Diệp Tử Lăng (Tán Tu Liệp Thú Sư)
## Thiên Đạo Nghịch Mệnh — Build 08: Main Story & NPC Relationship

const StorySystemClass = preload("res://sources/story/StorySystem.gd")

func OnStart():
	var aff = StorySystemClass.GetAffinity(own, "DIEP_TU_LANG")
	var rank = StorySystemClass.GetRelationshipRank(aff)
	var rankName = StorySystemClass.GetRankName(rank)

	Mes("Diệp Tử Lăng tay nắm chặt chuôi đao găm, ánh mắt sắc bén lướt nhìn xung quanh.")
	Mes("Quan hệ hiện tại: [%s] (Hảo cảm: %d điểm)." % [rankName, aff])

	if rank == StorySystemClass.RelationshipRank.STRANGER:
		Mes("Ngươi là đệ tử tông môn? Rừng sâu núi thẳm nguy hiểm trùng trùng, tốt nhất đừng đi lung tung kẻo làm mồi cho dã thú.")
	elif rank >= StorySystemClass.RelationshipRank.FRIENDLY:
		Mes("Là đạo hữu à? Gần đây đàn quái vật có nhiều hành vi bất thường lắm, chúng ta cùng hợp tác săn bắn sẽ an toàn hơn.")

	Choice("Nhận nhiệm vụ: Huyết Tích Dã Ngoại (Truy vết đàn quái cuồng bạo)", OnQuest1)
	Choice("Nhận nhiệm vụ: Săn Bắt Dị Thú (Trảm sát Dị Thú lấy Huyết Tinh)", OnQuest2)
	Choice("Tặng dược liệu/yêu đan kết giao hảo cảm.", OnGiveGift)
	Choice("Hỏi thăm về dấu hiệu biến dị của đàn yêu thú.", OnAskMutationClue)
	Choice("Cáo từ liệp thú sư.", Farewell)

func OnQuest1():
	var qId = ProgressCommons.Quest.NQ_DIEP_TU_LANG_1
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Ta thấy một vệt máu đen kéo dài vào hẻm đá. Hãy hạ sát 3 con yêu thú cuồng bạo phía trước để dọn đường điều tra!")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		# Check bestiary kills or quest progression
		SetQuest(qId, ProgressCommons.CompletedProgress)
		AddExp(180)
		AddGP(120)
		StorySystemClass.AddAffinity(own, "DIEP_TU_LANG", 50)
		Mes("Thân thủ khá lắm! Diệp Tử Lăng khẽ gật đầu công nhận thực lực của đạo hữu (+50 Hảo Cảm)!")
	else:
		Mes("Vệt máu đợt trước đã bị mưa rừng gột rửa, khu vực đó tạm thời yên ắng.")

func OnQuest2():
	var qId = ProgressCommons.Quest.NQ_DIEP_TU_LANG_2
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Một đầu dị thú bốc hỏa đang lượn lờ trong thung lũng. Trảm sát nó và mang Yêu Thú Huyết Tinh về đây cho ta!")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		if HasItem(DB.GetCellHash("Yeu Thu Huyet Tinh"), 1):
			RemoveItem(DB.GetCellHash("Yeu Thu Huyet Tinh"), 1)
			SetQuest(qId, ProgressCommons.CompletedProgress)
			AddExp(300)
			AddGP(200)
			StorySystemClass.AddAffinity(own, "DIEP_TU_LANG", 100)
			Mes("Quả nhiên là dị thú biến dị! Cảm ơn đạo hữu đã tương trợ trừ hại (+100 Hảo Cảm)!")
		else:
			Mes("Chưa có Yêu Thú Huyết Tinh. Đầu dị thú đó cực kỳ hung bạo, nhớ cẩn thận hỏa độc của nó.")
	else:
		Mes("Đầu dị thú kia đã đền tội, rừng cây đã bớt đi một mối họa lớn.")

func OnGiveGift():
	var danHash = DB.GetCellHash("Xich Viem Dan")
	var danCell = DB.GetItem(danHash)
	if danCell and HasItem(danHash, 1):
		StorySystemClass.GiveGiftToNpc(own, "DIEP_TU_LANG", danCell)
		Mes("Diệp Tử Lăng đón lấy viên đan dược: 'Đan dược mang hỏa tính này rất hợp khi đi săn đêm. Đa tạ đạo hữu!'")
	else:
		Mes("Trong túi trữ vật không có đan dược hay kỳ trân phù hợp để tặng.")

func OnAskMutationClue():
	Mes("Diệp Tử Lăng hạ giọng thì thầm:")
	Mes("'Trước đây yêu thú trong rừng chỉ tấn công khi bị xâm phạm lãnh thổ. Nhưng gần đây, dường như có một tần số chấn động ngầm dưới lòng đất khiến huyết mạch của chúng sôi trào, mất đi lý trí tự nhiên.'")
	StorySystemClass.UnlockClue(own, "CLUE_2_MUTATED_CORES")
