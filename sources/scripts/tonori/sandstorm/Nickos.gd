extends NpcScript

const QUEST_ID = ProgressCommons.Quest.MINE_EXPLORATION

#
func OnStart():
	var state : ProgressCommons.MINE_EXPLORATION = GetQuest(QUEST_ID) as ProgressCommons.MINE_EXPLORATION
	if state <= ProgressCommons.MINE_EXPLORATION.STARTED:
		Mes("Cứu...")
	elif state <= ProgressCommons.MINE_EXPLORATION.FIND_NICKOS:
		OnMeetNickos()
	elif state <= ProgressCommons.MINE_EXPLORATION.DEFEATED:
		OnRemindStranger()
	else:
		OnComplete()

func OnMeetNickos():
	Mes("Ngươi là ai? Làm ơn, giúp ta!")
	Choice("Tuần phòng Ryan cử ta đến tìm ngươi.", OnFoundNickos)

func OnFoundNickos():
	Mes("Ồ. Ta tưởng hắn để ta chết.")
	Mes("Hắn có vẻ chẳng quan tâm chuyện gì xảy ra khi bắt ta đi một mình xuống đây.")
	Choice("Chuyện gì đã xảy ra?", OnWhatHappened)

func OnWhatHappened():
	Mes("Ta bị tấn công bởi... ai đó?")
	Mes("Ta không ngờ gặp ai ở đây, nhưng có một người lạ mặc áo choàng đen.")
	Mes("Hắn có vẻ đang xem vách hang. Ta cố nói chuyện, hắn lập tức đánh không nói gì.")
	Choice("Ngươi thấy hắn đi đâu?", OnPursueStranger)
	Choice("Ngươi ổn chứ?", OnCheckNickos)

func OnCheckNickos():
	Mes("Sẽ ổn. Ta cần hít thở.")
	Mes("Ngươi có gì giúp được không?")
	var cactusPotionID : int = DB.GetCellHash("Cactus Potion")
	var pitayaID : int = DB.GetCellHash("Pitaya")
	if HasItem(cactusPotionID):
		Choice("Có. Thử cái này. [x1 Cactus Potion]", OnCactusPotion)
	if HasItem(pitayaID):
		Choice("Có. Thử cái này. [x1 Pitaya]", OnPitaya)
	Choice("Không, xin lỗi. Ta không có gì.", OnNothingOnMe)

func OnCactusPotion():
	var id : int = DB.GetCellHash("Cactus Potion")
	if HasItem(id):
		RemoveItem(id)
		Action(OnUsedItem)
	else:
		Action(OnNothingOnMe)

func OnPitaya():
	var id : int = DB.GetCellHash("Pitaya")
	if HasItem(id):
		RemoveItem(id)
		Action(OnUsedItem)
	else:
		Action(OnNothingOnMe)

func OnUsedItem():
	Mes("Cảm ơn! Ta khá hơn nhiều. Ta nghỉ chút rồi tự ra ngoài.")
	Mes("Cảm ơn đã cứu ta! Ta lo người đó quay lại giết nốt.")
	Choice("Ngươi thấy hắn đi đâu?", OnPursueStranger)

func OnNothingOnMe():
	Mes("Không sao. Ta nghỉ chút là tự ra được.")
	Mes("May vì ngươi tìm thấy ta. Ta lo hắn quay lại giết nốt.")
	Choice("Ngươi thấy hắn đi đâu?", OnPursueStranger)

func OnPursueStranger():
	Mes("Hắn đi theo hành lang này. Lần cuối ta nghe thấy là dưới bệ đá kia.")
	Mes("Nghe như bước trong nước. Rồi đá rơi.")
	Mes("Lần sau có tiếng động thì hóa ra là ngươi bước tới.")
	SetQuest(QUEST_ID, ProgressCommons.MINE_EXPLORATION.STRANGER_SPOTTED)

func OnRemindStranger():
	Mes("Nghe như bước trong nước. Rồi đá rơi.")
	Mes("Chắc có khe nứt ở vách dưới bệ đá. Hắn biến mất ở đó.")

func OnComplete():
	Mes("May vì ngươi tìm thấy ta. Ta lo hắn quay lại giết nốt.")
