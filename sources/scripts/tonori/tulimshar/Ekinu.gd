extends NpcScript

#
func OnStart():
	var questState : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	if questState < ProgressCommons.TUTORIAL.ELANORE_DONE:
		OnSendToElanore()
	elif questState < ProgressCommons.TUTORIAL.KAEL_DONE:
		OnSendToKael()
	elif questState < ProgressCommons.TUTORIAL.EKINU_DONE:
		OnKaelReport()
	else:
		OnComplete()

#
func OnSendToElanore():
	Mes("Đạo hữu đã dậy rồi?")
	LookAtNpc("Elanore")
	Mes("Nhớ nói chuyện với Elanore — nàng đã chăm đạo hữu khi ta tìm thấy ngươi bất tỉnh.")
	ResetCamera()

func OnSendToKael():
	Mes("Đạo hữu thấy đám sâu ta phải đối phó chưa?")
	Mes("Sinh vật kinh tởm. Người ta bảo xưa chúng nhỏ hơn.")
	Mes("Nông dân xương rồng chịu nặng nhất. Sâu đông làm hại mùa màng.")
	LookAtNpc("Kael")
	Mes("Tuần phòng Kael đóng phía đông, cạnh ruộng xương rồng.")
	ResetCamera()
	Mes("Muốn đền ơn thành thì giúp Kael dọn sâu.")

# Skip Tutorial
func OnSkipTutorial():
	Mes("Đạo hữu định đi đâu?")
	Choice("Ta lạc đường.", OnStart)
	Choice("Ta muốn rời nơi này.", OnForceHelpWithExpedition)

func OnForceHelpWithExpedition():
	Mes("Hmm... Ta hiểu.")
	Mes("Để trả nợ thành và nếu thật sự muốn đi, ta sẽ đưa đạo hữu vào đội thám hiểm ngoài thành.")
	OnExpedition()

# Kael's report
func OnKaelReport():
	Mes("Đã xử lý sâu chưa?")
	Choice("Rồi. Kael bảo ta làm tốt. Anh ấy nghĩ ta giúp được chuyến thám hiểm.", OnHelpWithExpedition)

func OnHelpWithExpedition():
	Mes("Hmm... Anh ấy đúng.")
	OnExpedition()

func OnExpedition():
	Mes("Ta cần thêm một võ giả, lo không rút quá nhiều lính khỏi trạm trong thành.")
	Mes("Đạo hữu sẽ đi nam, về Sandstorm Mines.")
	Mes("Tên gọi có lý do — vùng đó gió mạnh, cát cuốn khó đi.")
	Mes("Cơn bão này khác thường: dữ, nóng, kéo dài. Ta nghi có gì đó gây ra...")
	Choice("Sao phải đi hướng đó?", OnWhyExpedition)
	Choice("Ta phải làm gì?", OnJobExplanation)

func OnWhyExpedition():
	Mes("Mỏ xưa giàu Quặng Sắt — kinh doanh lời cho Red Queen vì cả vùng là đất riêng nàng.")
	Mes("Bỏ hoang vài năm vì bão cát mạnh, đi nguy hiểm, thợ mỏ chết vì bão hoặc quái sa mạc.")
	Mes("Giờ triều đình hết tiền. Nàng ra lệnh mở lại mỏ bất kể giá.")
	Mes("Nàng chẳng nghĩ đến nguy hiểm cho người bị đẩy xuống đó.")
	Choice("Ta phải làm gì?", OnJobExplanation)

func OnJobExplanation():
	Mes("Nhiệm vụ: trinh sát, đảm bảo hang cũ không còn hiểm họa lớn. Ổn thì đưa thợ mỏ vào, vận hành lại.")

	var tutorialState : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	if tutorialState < ProgressCommons.TUTORIAL.EKINU_DONE:
		var desertBootsID : int = DB.GetCellHash("Desert Boots")
		var desertGogglesID : int = DB.GetCellHash("Desert Goggles")
		Mes("Trước khi đi, không thể qua sa mạc chân trần, mắt mù.")
		Mes("Cầm kính và giày. Cát thiêu chân, lọt vào mắt!")
		SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.EKINU_DONE)
		AddItem(desertBootsID)
		AddItem(desertGogglesID)
		AddExp(20)

		if tutorialState < ProgressCommons.TUTORIAL.KAEL_MET:
			var shortSwordID : int = DB.GetCellHash("Short Sword")
			Mes("Ngươi chưa có vũ khí phải không?")
			Mes("Cầm kiếm này. Tốt hơn tay không ra sa mạc.")
			AddItem(shortSwordID)

		Mes("Giày đúng giúp đi nhanh hơn chân trần.")
		Mes("Nguy hiểm thì chạy — chết không có gì đáng tự hào.")

		DisplayActions(["gp_run"])
		Narrate("Giữ Chạy để lướt nhanh hoặc thoát chiến.")
		Narrate("Chạy tốn thể lực — dùng khi cần.")

		Mes("Vậy là đủ đồ.")
		LookAtNpc("Gilgames")
		Mes("Một việc nữa. Trước khi ra khỏi thành, nói chuyện với Gilgames canh cổng — anh ấy hay nói với tân binh.")
		ResetCamera()

	Mes("Vài lính đã đi trước. Hỏi Tuần phòng Dausen ngoài cổng — anh ấy chỉ đường.")
	if GetQuest(ProgressCommons.Quest.MINE_EXPLORATION) < ProgressCommons.MINE_EXPLORATION.STARTED:
		SetQuest(ProgressCommons.Quest.MINE_EXPLORATION, ProgressCommons.MINE_EXPLORATION.STARTED)

	OnMainChoice()

# Main choice loop
func OnMainChoice():
	if GetQuest(ProgressCommons.Quest.MINE_EXPLORATION) == ProgressCommons.MINE_EXPLORATION.STARTED:
		Choice("Ta phải làm gì nhắc lại?", OnJobExplanation)
	Choice("Kể về Red Queen?", OnRedQueen)
	Choice("Nguy hiểm thì sao?", OnStrangerDanger)
	Choice("Được, ta đi thôi.", Farewell)

# Attack and flee
func OnStrangerDanger():
	Mes("Đánh trước.")
	Mes("Đối thủ quá mạnh thì chạy cứu mạng. Chết không có gì đáng tự hào.")
	DisplayActions(["gp_target"])
	DisplayActions(["gp_interact"])
	DisplayActions(["gp_run"])
	Narrate("Giữ Chạy để lướt nhanh hoặc thoát chiến.")
	Narrate("Chạy tốn thể lực — dùng khi cần.")
	OnMainChoice()

# Red Queen chain
func OnRedQueen():
	Mes("\"Red Queen\", chính thức Nữ hoàng Karolina I — vị cai trị vô dụng của thành.")
	Mes("Nàng tự xưng Nữ hoàng Tonori — như thể cai được gì ngoài tường thành.")
	Mes("Nàng bảo dòng Platinum Dynasty, cai Tulimshar ngàn năm trước. Thực ra ai cũng biết cha nàng là nông dân xương rồng — lên ngai vì cha thông minh.")
	Choice("Ngươi ghét nàng thật.", OnDislikeQueen)
	Choice("Cha nàng là nông dân xương rồng?", OnRedQueenFather)

func OnRedQueenFather():
	Mes("Đúng. Ông thuyết phục vua già sắp chết rằng mình là con ngoài giá thú.")
	Mes("Vua không con, ưng ông. Trước khi chết chỉ định thừa kế. Ông thông minh, lãnh đạo tốt — cung điện chấp nhận.")
	Mes("Giờ ông mất, con gái vô dụng bịa dòng máu hoàng tộc. Không ai thích nàng — nàng cần cớ để giữ vương miện.")
	Choice("Ngươi ghét nàng thật.", OnDislikeQueen)

func OnDislikeQueen():
	Mes("Còn nhẹ đấy!")
	Mes("Ta muốn thấy nàng chôn nửa người trong cát, bọ cạp gặm xác.")
	Mes("Đừng lan truyền ta nói thế.")
	Mes("Nàng lạnh lùng, ích kỷ. Cả ngày vườn trong Hoàng cung.")
	Mes("Nàng quan tâm vườn hơn mạng bất kỳ ai trong ta.")
	Choice("Mau đi trước khi nàng nổi giận!", OnMainChoice)

# Expedition started
func Farewell():
	if randi() % 2:
		Chat("Giữ tinh thần.")
	else:
		Chat("Về nguyên vẹn.")

func OnComplete():
	var questState : int = GetQuest(ProgressCommons.Quest.MINE_EXPLORATION)
	if questState == ProgressCommons.MINE_EXPLORATION.STARTED:
		Mes("Sẵn sàng thì báo Tuần phòng Dausen ngoài cổng.")
	else:
		Mes("May ta tìm thấy đạo hữu trước goblin — mừng thấy ngươi khá hơn.")

	OnMainChoice()
