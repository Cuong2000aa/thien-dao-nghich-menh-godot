extends NpcScript
class_name AncientStele

const STELE_EXP : int = 100

func OnStart():
	if not IsPlayer():
		return
	Mes("Trước mắt đạo hữu là một tấm Cổ Bi ngàn năm rêu phong phủ kín, trên mặt đá khắc những nét kiếm ý tung hoành như rồng bay phượng múa:")
	Mes("『Thiên Địa Hỗn Độn, Nhất Khí Sơ Phân. Trúc Sơn Đạo Pháp, Nghịch Mệnh Tu Chân.』")
	
	var qID : int = ProgressCommons.Quest.KHAM_PHA_CO_BI
	var qState : int = own.progress.GetQuest(qID)
	
	if qState == ProgressCommons.CompletedProgress or qState == ProgressCommons.KHAM_PHA_CO_BI.OBJECTIVE_MET:
		Mes("Kiếm ý trên cổ bi đã khắc sâu vào thần thức, đạo hữu tâm cảnh thanh tịnh, không còn chấp niệm.")
		Choice("Rời đi")
		return
		
	Choice("Tĩnh tâm tham ngộ kiếm ý", MeditateStele)
	Choice("Rời đi")

func MeditateStele():
	DisplayTracker("Đang tham ngộ Cổ Bi...", 0, 5, "")
	AddTimer(own, 0.3, OnMeditateTick.bind(0), "meditate_stele")

func OnMeditateTick(tick : int):
	if not own or not is_instance_valid(own):
		return
	if tick >= 5:
		ClearTracker()
		CompleteMeditation()
	else:
		DisplayTracker("Đang tham ngộ Cổ Bi...", tick + 1, 5, "")
		AddTimer(own, 0.3, OnMeditateTick.bind(tick + 1), "meditate_stele")

func CompleteMeditation():
	var qID : int = ProgressCommons.Quest.KHAM_PHA_CO_BI
	NpcCommons.SetQuest(own, qID, ProgressCommons.KHAM_PHA_CO_BI.OBJECTIVE_MET)
	NpcCommons.AddExp(own, STELE_EXP)
	
	var bookID : int = DB.GetCellHash("Truc Son Co Bi Tan Quyen")
	NpcCommons.AddItem(own, bookID, 1)
	
	Notification("Lĩnh ngộ thành công Trúc Sơn Cổ Bi! (+%d Tu Vi, nhận được Trúc Sơn Cổ Bi Tàn Quyển)" % STELE_EXP)
	NpcCommons.PushTracker(own, "Khám Phá Cổ Bi", 1, 1)
	
	Mes("Trong biển thức bừng sáng, một đạo kiếm khí xé toạc mây mù! Đạo hữu đã lĩnh ngộ được tinh yếu tàn quyển.")
