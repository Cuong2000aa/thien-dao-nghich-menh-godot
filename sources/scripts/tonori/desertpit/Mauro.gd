extends NpcScript

#
func OnStart():
	match GetQuest(WaterPondGlobal.QUEST_ID):
		ProgressCommons.SNAKE_PIT_BITING_THIRST.INACTIVE:
			OnInactive()
		ProgressCommons.SNAKE_PIT_BITING_THIRST.STARTED:
			OnCheckProgress()
		ProgressCommons.SNAKE_PIT_BITING_THIRST.REWARDS_WITHDREW:
			OnComplete()
		_:
			OnInProgress()

# Quest states
func OnInactive():
	Mes("Nước của ta hết sạch! Không biết làm sao về Tulimshar.")
	Mes("Vài ngày trước ta quyết đối mặt sa mạc, khám phá vùng này.")
	Mes("Hang ở đây có ao ngầm nước trong veo.")
	Mes("Ngày xưa người ta đến lấy nước, nhưng vài năm trước nơi này đầy rắn.")
	Mes("Ta tưởng đánh lui được rắn, không ngờ nhiều thế!")
	Mes("Ta cố tới ao nhưng rắn cứ tấn công, ta đổ hết nước đã hứng.")
	Mes("Ngươi thử giúp được không? Ta mệt lắm. Cần ít nhất một bình đầy để về thành.")
	Mes("Rắn không độc, nhưng hung dữ và quá đông...")
	Choice("Ta thử được.", OnAccept)
	Choice("Hôm nay thôi.", OnDecline)

func OnCheckProgress():
	var rid : int = own.get_rid().get_id()
	if WaterPondGlobal.biteCounters.get(rid, 0) == 0:
		OnInProgress()
	else:
		OnDeliverWater()

func OnInProgress():
	Mes("Ao sâu trong hang. Cách tốt nhất tìm là cứ đi lạc, rồi sẽ thấy.")
	Mes("Hứng nước vào bình nếu tìm được, mang về đây.")
	Mes("Cẩn thận — rắn cắn là mất nước dọc đường!")

func OnDeliverWater():
	WaterPondGlobal.StopJugTransport(own)
	ClearTracker()
	Mes("Ngươi làm được! Và còn mang nước!")
	Mes("Này, cầm lấy. Ta chỉ còn bấy nhiêu.")
	SetQuest(WaterPondGlobal.QUEST_ID, ProgressCommons.SNAKE_PIT_BITING_THIRST.REWARDS_WITHDREW)
	AddItem(DB.GetCellHash("Pitaya"), 10)
	AddExp(50)
	AddGP(1000)
	AddKarma(1)
	Mes("Ta về Tulimshar. Vùng này nguy hiểm quá.")
	Mes("Ta bám giếng trong thành an toàn hơn. Chắc nước này thuộc về rắn rồi.")

func OnComplete():
	Mes("Cảm ơn vì nước. Giờ ta có thể thư giãn, từ từ về.")
	Mes("Mấy ngày trong sa mạc là hạnh phúc nhất, nhưng ta nghĩ đến lúc về nơi văn minh.")

func OnDecline():
	Mes("Ta hiểu. Đổi ý thì quay lại.")

# Transitions
func OnAccept():
	SetQuest(WaterPondGlobal.QUEST_ID, ProgressCommons.SNAKE_PIT_BITING_THIRST.STARTED)
	Mes("Đây là bình. Nguồn nước sâu trong hang.")
	Mes("Mẹo quan trọng: để tìm, ta nhớ đi bắc rồi đông...")
	Mes("Rồi nam? Hay đi thêm đông rồi bắc lần nữa...")
	Mes("Thật ra ta chỉ nhớ rắn và vết cắn nhọn. May loại này không độc.")
	Mes("Chúc may mắn; ta vẫn khuyên đừng đi một mình.")
	Mes("Có người giúp chắc đánh rắn và hứng nước dễ hơn.")
