extends NpcScript

const QUEST_ID = ProgressCommons.Quest.MINE_EXPLORATION
const DESERT_SEED_ID = ProgressCommons.Quest.DESERT_SEED

#
func OnStart():
	var state : ProgressCommons.MINE_EXPLORATION = GetQuest(QUEST_ID) as ProgressCommons.MINE_EXPLORATION
	if state <= ProgressCommons.MINE_EXPLORATION.STARTED:
		OnFirstEncounter()
	elif state <= ProgressCommons.MINE_EXPLORATION.DEFEATED:
		OnRemindObjective()
	elif state == ProgressCommons.MINE_EXPLORATION.MANA_TREE_MET:
		OnWarnAboutMines()
	else:
		OnFarewell()

#
func OnFirstEncounter():
	Mes("Ngươi là ai?")
	Choice("Tuần phòng Ekinu cử ta đến trinh sát mỏ này.", OnPresentation)

func OnPresentation():
	Mes("Hắn cử NGƯƠI? Ta bảo thằng não cát kia cử TÂN BINH.")
	Mes("Không phải kẻ lang thang sa mạc bất kỳ.")
	Mes("Gặp bọn bọ cạp là ngươi chạy mất dép, phải không?")
	if GetBestiary("Scorpion".hash()) > 0:
		Choice("Ta đi bộ cả đoạn đường tới đây và đã đánh lui vài con bọ cạp rồi.", OnHarshWelcome)
	else:
		Choice("Ta không đi xa tới đây để bỏ cuộc nhanh thế.", OnHarshWelcome)

func OnHarshWelcome():
	Mes("Ừ... thôi kệ. Im đi.")
	Mes("Giọng ngươi chói tai. Ta không cần tiếng vang vọng khắp hang.")
	Mes("Như ngươi thấy, ta đã có mấy kẻ tội nghiệp đủ tuyệt vọng để đào đất xem còn kim loại quý trong cái hố khốn này không.")
	Choice("Vậy ta phải làm gì?", OnExplainWhatToDo)

func OnExplainWhatToDo():
	Mes("Ta sắp nói rồi!")
	Mes("Ta cử một thằng trong bọn đi trinh sát trước, hắn có vẻ lạc mất.")
	Mes("Tên Nickos. Lâu rồi không thấy về.")
	Mes("Đi tìm hắn.")
	Mes("Sống thì dẫn về. Chết thì ngươi chắc cũng chết, và ta biết phía dưới nguy hiểm.")
	Mes("Nghe ổn không?")
	Choice("Tệ hại, nhưng ta làm.", OnStartQuest)
	Choice("Ừm... sao ta lại đồng ý...", OnStartQuest)

func OnStartQuest():
	Mes("Tốt. Dù sao ta cũng không định cho ngươi chọn.")
	Mes("Đi! Đừng đợi ta hôn tạm biệt.")
	SetQuest(QUEST_ID, ProgressCommons.MINE_EXPLORATION.FIND_NICKOS)

func OnRemindObjective():
	Mes("Tên Nickos. Lâu rồi không thấy về.")
	Mes("Đi tìm hắn.")
	Mes("Sống thì dẫn về. Chết thì ngươi chắc cũng chết, và ta biết phía dưới nguy hiểm.")

func OnWarnAboutMines():
	Mes("Ngươi còn sống.")
	Mes("Ta tưởng ngươi cũng lạc rồi. Phía dưới chuyện gì xảy ra?")
	Choice("Tầng dưới ngập nước hoàn toàn. Không lọt qua được.", OnLieFlooded)
	Choice("Bọ cạp phun lửa! Hàng trăm con! Động vào là chúng nổi điên!", OnLieScorpions)
	Choice("Tổ goblin khắp nơi! Dọn chúng mất nhiều người lắm.", OnLieGoblins)
	Choice("Có cây ma thuật. Cây đó nói chuyện với ta!", OnLieManaTree) 

func OnLieFlooded():
	Mes("Ngập?")
	Mes("Không biết nước từ đâu ra.")
	Mes("Ngoài đây có giếng, chắc có nguồn ngầm gần đó.")
	Mes("Hang ngập không nên động vào. Hầm có thể sập, nhốt cả bọn. Ta báo mỏ coi như hết.")
	Action(OnAskAboutNickos)

func OnLieScorpions():
	Mes("Phun lửa? Ta chưa từng thấy.")
	Mes("Ta từng thấy bọ cạp to nuốt cả người. Có lẽ phun lửa cũng không quá lạ.")
	Mes("Hay tránh nơi này. Chẳng có gì đáng đào.")
	Action(OnAskAboutNickos)

func OnLieGoblins():
	Mes("G... goblin? Ngươi... chắc chứ?")
	Mes("Ta... ta không sợ! Nếu ngươi đang nghĩ vậy. TA KHÔNG SỢ GOBLIN!")
	Mes("Biết không? Ta bỏ nơi này đi. Đi thôi.")
	Mes("Nguy hiểm quá, không đáng mạo hiểm vì mấy mỏ quặng quên lãng.")
	Action(OnAskAboutNickos)

func OnLieManaTree():
	Mes("Một cây. Cây ma thuật. Cây ma thuật BIẾT NÓI.")
	Mes("Tiếp theo ngươi bảo bọ cạp phun lửa? Goblin hát cho ngươi nghe?")
	Mes("Ngươi mất trí rồi. Chuyện phía dưới làm ngươi ngu đi!")
	Mes("Chắc hang ma ám. Ta nghĩ không nên xuống nữa.")
	Action(OnAskAboutNickos)

func OnAskAboutNickos():
	Mes("Nói vậy. Nickos sao? Tìm thấy chưa?")
	Choice("Hắn còn sống. Choáng váng nhưng đang nghỉ.", OnNickosAlive)
	Choice("Ta tìm thấy di hài hắn.", OnNickosDead)

func OnNickosAlive():
	Mes("Không lạ. Ta từng thấy hắn sợ cả con maggot bò tới.")
	Mes("Hắn tốt hơn lên đây nhanh, không ta bỏ mặc.")
	SetQuest(QUEST_ID, ProgressCommons.MINE_EXPLORATION.REWARDS_WITHDREW)
	AddGP(1000)
	OnFarewell()

func OnNickosDead():
	Mes("...")
	Mes("Ừ.")
	Mes("Hắn biết rủi ro. Ai làm việc này cũng biết.")
	Mes("...")
	Mes("Ta không đi lấy xác. Đừng gợi ý.")
	Mes("Mất thêm người nữa là ta không bao giờ được dẫn ai ra ngoài thành nữa.")
	Mes("Lương hắn tự lấy. Coi như của ngươi vì báo cáo.")
	Mes("Ít nhất ta chắc không xuống nữa. Người đầu tiên ta cử chết. Không phải dấu tốt.")
	SetQuest(QUEST_ID, ProgressCommons.MINE_EXPLORATION.REWARDS_WITHDREW)
	AddGP(2000)
	OnFarewell()

func OnFarewell():
	var responses : PackedStringArray = [
		"Tốt. Giờ đừng đứng đây nữa.",
		"Đến lúc rồi. Ta tưởng ngươi cũng lạc.",
		"Đừng mong huy chương.",
		"Đi tìm việc có ích đi.",
		"Ngươi vẫn đang lãng phí thời gian ta.",
	]
	Chat(responses[randi() % responses.size()])
