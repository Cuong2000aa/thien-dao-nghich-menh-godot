extends NpcScript

#
func OnStart():
	var questState : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	if questState >= ProgressCommons.TUTORIAL.EKINU_DONE:
		Mes("Ngươi là tân binh Ekinu nhận? Tốt.")
		Mes("Chắc đạo hữu có nhiều câu trước khi ra ngoài — ta giúp gì?")
		OnTutorialResume()
	else:
		Mes("Tránh xa cổng. Đi đi.")

# Common questions
func OnTutorialResume():
	Choice("Ta mạnh hơn thế nào?", OnStat)
	Choice("Lạc đường thì sao?", OnMinimap)
	Choice("Truy cập đồ đạc nhanh ra sao?", OnShortcut)
	Choice("Ổn hết!", Farewell)

func Farewell():
	Chat("Đừng chết oan.")

# Explanations
func OnStat():
	Mes("Hoàn thành mục tiêu, chiến đấu hay tham gia hoạt động giúp trưởng thành. Khám phá, đừng ngại nói chuyện dân địa phương.")
	HighlightUI(UICommons.UITarget.STAT)
	Narrate("Lên cấp nhận điểm thuộc tính — phân bổ theo lối chơi rồi xác nhận.")
	Narrate("Sức mạnh tăng sát thương vật lý, tốc đi bộ và tải trọng.")
	Narrate("Nhanh nhẹn ảnh hưởng tầm và tốc độ đánh, né tránh.")
	Narrate("Sinh mệnh tăng sinh lực, hồi phục và phòng thủ.")
	Narrate("Thể lực giúp thể lực bền hơn, hồi nhanh, đánh liên tiếp sớm hơn.")
	Narrate("Tập trung nuôi Mana và đạt đỉnh hiệu suất kỹ năng.")
	HighlightUI(UICommons.UITarget.STATINDICATOR)
	Narrate("Theo dõi sinh mệnh, Mana, thể lực — ra hoang với tài nguyên thấp không khôn.")
	HighlightUI(UICommons.UITarget.NONE)
	Mes("Đạo hữu cần mọi lợi thế để đánh thắng sa mạc.")
	OnTutorialResume()

func OnMinimap():
	Mes("Bản đồ là bạn — đừng ngại dùng khi lạc.")
	HighlightUI(UICommons.UITarget.MINIMAP)
	Narrate("Chấm điểm trên bản đồ để hướng tới đích.")
	HighlightUI(UICommons.UITarget.NONE)
	OnTutorialResume()

func OnShortcut():
	Mes("Giữ vật, đan dược hay kỹ năng yêu thích gần tay — hữu ích trong bão cát.")
	HighlightUI(UICommons.UITarget.ACTION_BAR)
	Narrate("Kéo thả vật dùng, kỹ năng hay biểu cảm vào thanh tắt.")
	HighlightUI(UICommons.UITarget.NONE)
	OnTutorialResume()
