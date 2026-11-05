extends NpcScript

const FIELD_POSITION : Vector2 = Vector2(2912, 1312)

#
func OnStart():
	var questState : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	if questState < ProgressCommons.TUTORIAL.ELANORE_DONE:
		OnSendToElanore()
	elif questState == ProgressCommons.TUTORIAL.ELANORE_DONE:
		OnFirstMeeting()
	elif questState == ProgressCommons.TUTORIAL.KAEL_MET:
		OnCheckProgress()
	elif questState == ProgressCommons.TUTORIAL.KAEL_DONE:
		OnSendToEkinu()
	elif questState == ProgressCommons.TUTORIAL.EKINU_DONE:
		OnComplete()

# Too early
func OnSendToElanore():
	Mes("Đạo hữu đã dậy rồi?")
	LookAtNpc("Elanore")
	Mes("Nhớ nói chuyện với Elanore — nàng đã chăm đạo hữu khi ta tìm thấy ngươi bất tỉnh.")
	ResetCamera()

# Initial encounter
func OnFirstMeeting():
	Mes("Chào, ngươi là kẻ ta kéo khỏi cát? Mừng thấy đạo hữu đi được. Ta cần giúp.")
	Mes("Sâu đục xương rồng. Miệng nhỏ nhưng lanh, ăn quanh gai rồi đào vào trong cây — cảnh kinh khủng.")
	Mes("Một khi thủng vỏ, chúng đào vào ăn từ trong ra.")
	Choice("Sao sâu to dữ vậy?", OnKaoreExplanation)
	Choice("Nghe đáng sợ.", OnWildFauna)
	Choice("Nghe hay đấy!", OnWildFauna)

func OnKaoreExplanation():
	Mes("Người ta bảo xưa không như vậy. Ta chưa đủ tuổi nhớ — chẳng ai nhớ nữa.")
	Mes("Trước Thời đại Kaore, hàng trăm năm trước, sinh vật chưa... kỳ lạ như nay.")
	Mes("Thời đại Kaore biến chúng. Loại sâu này to và đông. Sinh vật khác tệ hơn.")
	Mes("Họ bảo sóc đã từng thông minh như người, rồi mất hết.")
	if GetQuest(ProgressCommons.Quest.TUTORIAL) >= ProgressCommons.TUTORIAL.KAEL_DONE:
		MainChoices()
	else:
		Mes("Thôi đủ chuyện. Vào ruộng dọn bã này!")
		Choice("Được, ta làm ngay!", OnFieldCleanUp)
		Choice("Sa mạc đang có chuyện gì?", OnDesertExplanation)

func OnWildFauna():
	Mes("Dù sao cũng phải diệt.")
	Mes("Chuyện gì ở sa mạc cũng ảnh hưởng sâu trong thành.")
	Mes("Tệ hơn, xương rồng cũng bị.")
	Mes("Vài cây nhảy nhót, làm mặt ngớ ngẩn, tưới cả ruộng lân cận! Giúp ta xử lý.")
	Choice("Được, ta làm ngay.", OnFieldCleanUp)
	Choice("Sa mạc đang có chuyện gì?", OnDesertExplanation)

func OnDesertExplanation():
	Mes("Kaore ảnh hưởng muôn loài.")
	Mes("Lực ác biến sinh vật thành... phiên bản tệ hơn? Hung dữ hơn.")
	Mes("Đến khi chiếm hẳn, chúng gần như sống lại từ cõi chết. Lời nguyền kinh khủng.")
	if GetQuest(ProgressCommons.Quest.TUTORIAL) >= ProgressCommons.TUTORIAL.KAEL_DONE:
		MainChoices()
	else:
		Mes("Pháp sư tháp Manayir đã cảnh báo Kaore đang tụ thành mảng nguy hiểm khắp Tonori.")
		Choice("Được rồi, giết chúng thôi.", OnFieldCleanUp)
		Choice("Manayir là ai?", OnManayir)

func OnManayir():
	Mes("Hội cổ nghiên cứu Mana và việc khác ở tháp tây thành.")
	Mes("Họ phát cảnh báo Kaore.")
	Mes("Manayir tuyên bố kết thúc Thời đại Kaore khoảng 27 năm trước.")
	Mes("Từ đó họ cập nhật dòng Linh Khí cho dân Tulimshar.")
	Mes("Như thời tiết — Mana và Kaore luôn đổi, ảnh hưởng mọi sinh linh vùng này.")
	Choice("Được rồi, giết chúng thôi.", OnFieldCleanUp)
	Choice("Thời đại Kaore là gì?", OnAgeOfKaore)

func OnAgeOfKaore():
	Mes("Ta còn trẻ, nhưng vài thập kỷ trước đời khó hơn nhiều.")
	Mes("Kaore dày hơn Mana — vài trăm năm người ta vật lộn với quái dị và xác sống.")
	Mes("Ta than sâu và peyote, nhưng so với cha mẹ ta còn may.")
	Choice("Được rồi, giết chúng thôi.", OnFieldCleanUp)

# Task assignment
func OnFieldCleanUp():
	var shortSwordID : int = DB.GetCellHash("Short Sword")

	Mes("Không thể dọn ruộng tay không.")
	Mes("Cầm kiếm này. Không lớn lắm, nhưng cắt Maggot và Peyote được.")
	AddItem(shortSwordID)
	OnFightTutorial()
	Mes("Bắt đầu với peyote ruộng phía bắc đây.")
	LookAtPosition(FIELD_POSITION)
	Mes("Xương rồng nhiễm Kaore — vô hại với ta nhưng hỏng mùa màng.")
	Mes("Chúng nhảy nhót, tưới ruộng lân cận...")
	ResetCamera()
	Mes("Diệt 5 peyote và 5 maggot là đủ bảo vệ mùa hôm nay.")
	HighlightUI(UICommons.UITarget.PROGRESS)
	Narrate("Cửa sổ tiến độ gom nhiệm vụ và giao chiến đang làm.")
	HighlightUI(UICommons.UITarget.NONE)
	Narrate("Số quái đã diệt xem trong tab Manapedia trên thanh menu.")
	SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.KAEL_MET)
	npc.ownScript.TrackPlayer(own)

# Progress check
func OnCheckProgress():
	var kaelGlobal : KaelGlobal = npc.ownScript as KaelGlobal
	kaelGlobal.TrackPlayer(own)

	var peyoteKills : int = kaelGlobal.GetKillCount(own, kaelGlobal.peyoteID)
	var maggotKills : int = kaelGlobal.GetKillCount(own, kaelGlobal.maggotID)
	if peyoteKills >= KaelGlobal.PEYOTE_REQUIRED and maggotKills >= KaelGlobal.MAGGOT_REQUIRED:
		OnTaskComplete()
	elif peyoteKills < KaelGlobal.PEYOTE_REQUIRED:
		Mes("Chưa xong. Còn %d peyote trong ruộng." % (KaelGlobal.PEYOTE_REQUIRED - peyoteKills))
	else:
		Mes("Peyote ổn rồi. Còn %d maggot nữa." % (KaelGlobal.MAGGOT_REQUIRED - maggotKills))

# Task completion
func OnTaskComplete():
	Mes("Làm tốt lắm!")
	Mes("Nhanh và gọn hơn ta mong.")
	Mes("Báo Tuần phòng Ekinu gần cổng gặp Elanore. Nói ta hài lòng với việc đạo hữu làm.")
	Mes("Sắp có chuyến vào sa mạc — đạo hữu có thể là người ta cần.")
	SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.KAEL_DONE)
	AddExp(20)
	npc.ownScript.UntrackPlayer(own)
	ClearTracker()

#
func OnSendToEkinu():
	Mes("Sẵn sàng thì báo Tuần phòng Ekinu.")
	Mes("Anh ấy biết bước tiếp.")
	MainChoices()

#
func OnComplete():
	Mes("Mừng gặp lại! Như đạo hữu thấy, ta vẫn vây quanh đám sâu trắng nhảy nhót.")
	MainChoices()

#
func MainChoices():
	Choice("Sao sâu to dữ vậy?", OnKaoreExplanation)
	Choice("Đánh chúng thế nào?", OnFightTutorial)
	Choice("Sa mạc đang có chuyện gì?", OnDesertExplanation)
	Choice("Ta phải đi.", Farewell)

func Farewell():
	Chat("Giữ mình cẩn thận ngoài kia.")

func OnFightTutorial():
	Mes("Nhắm, đánh và bịt tai — chúng kêu kinh khi trúng đòn.")
	DisplayActions(["gp_interact", "gp_target", "gp_sit"])
	Narrate("Nhấn Tương Tác gần địch để tự nhắm và tấn công.")
	Narrate("Có thể dùng Nhắm Mục Tiêu để chọn thủ công.")
	Narrate("Mỗi đòn tốn thể lực. Hết thì đòn yếu đi.")
	Narrate("Ngồi giúp hồi thể lực.")
