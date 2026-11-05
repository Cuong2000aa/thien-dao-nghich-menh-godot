extends NpcScript

#
func OnStart():
	match GetQuest(ProgressCommons.Quest.SPLATYNA_OFFERING):
		ProgressCommons.SPLATYNA_OFFERING.INACTIVE: Inactive()
		ProgressCommons.SPLATYNA_OFFERING.STARTED: OnRecap()
		_: OnFinish()

func Inactive():
	Mes("Tụng danh Splatyna, Nữ Vương Slime uy mãnh!")
	Mes("Ngươi kia! Đến dâng vàng cho nữ vương nhầy nhụa của chúng ta phải không?")
	InfoChoice()

func InfoChoice(previousText : int = -1):
	var questState : int = GetQuest(ProgressCommons.Quest.SPLATYNA_OFFERING)
	if previousText != 0:
		if questState == ProgressCommons.SPLATYNA_OFFERING.INACTIVE:
			Choice("Được, ta sẽ mang lễ vật đến cho nàng.", OnAcceptQuest)
		else:
			Choice("Ta phải làm gì?", OnRecap)
	if previousText != 1:
		Choice("Vô lý! Ta cáo từ.", OnDecline)
	if previousText != 2:
		Choice("Splatyna là ai?", OnAskAboutSplatyna)
	if previousText != 3:
		Choice("Đây là nơi nào?", OnAskAboutPlace)

func OnRecap():
	Mes("Đạo hữu vẫn chưa dâng của cải cho Splatyna?")
	Mes("Vào hang nàng, tìm tín đồ và dâng vàng!")
	Mes("Ba kẻ trung thành giữ chìa khóa — nhớ kỹ!")
	InfoChoice(0)

func OnFinish():
	Mes("Khoan... ta nghe tiếng gì đó. Một tiếng hét!")
	Mes("Splatyna có chuyện gì?! Đạo hữu đã làm gì?")

	Choice("Không có gì! Mọi thứ ổn...", OnDeny)
	Choice("Nàng ấy... đã đi rồi.", OnAdmit)

func OnDeny():
	Mes("Tốt, tốt! Ta ở đây đảm bảo Nữ Vương vui vẻ.")

func OnAdmit():
	Mes("Đi rồi?! Không, không! Đạo hữu nói dối! Splatyna không thể chết!")
	Mes("Cứ... đi đi, trước khi ta mất trí!")

func OnAskAboutSplatyna():
	Mes("Splatyna không giống slime khác. Nàng mạnh mẽ! Nàng được Kaore ban phước!")
	Mes("Nàng từng là nữ vương vĩ đại. Linh hồn nàng bị trục xuất và tìm đến đây. Giờ nàng lại có thể trị vì!")
	Mes("Nữ vương ta yêu vàng. Vàng làm hình thể mới nàng thật đẹp! Nàng thích thế hơn.")
	Mes("Phải dâng đủ vàng nàng đòi. Chọc giận nàng, nàng nuốt chúng ta hết!")
	InfoChoice(2)

func OnAskAboutPlace():
	Mes("Đây là Vương Quốc Vàng của Splatyna! Trước chỉ là hang, giờ nữ vương ta cai trị.")
	Mes("Slime ở đây trung thành với Splatyna. Chúng canh giữ nàng và kho báu khổng lồ.")
	Mes("Ba con đặc biệt, trung thành thật sự. Chúng giữ chìa phòng nàng, không đưa dễ dàng — đạo hữu phải chịu khó!")
	Mes("Đừng lo. Mang đủ vàng, có lẽ Splatyna cho đạo hữu qua...")
	InfoChoice(3)

func OnAcceptQuest():
	Mes("Hay lắm, cầm vàng này dâng Splatyna. Nàng sẽ phán xét giá trị đạo hữu.")
	SetQuest(ProgressCommons.Quest.SPLATYNA_OFFERING, ProgressCommons.SPLATYNA_OFFERING.STARTED)
	Farewell()

func OnDecline():
	Chat("Báo ngược! Dám từ chối lễ vật Splatyna?!")
