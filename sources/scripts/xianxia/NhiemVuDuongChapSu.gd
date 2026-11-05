extends NpcScript

## NPC Script: Chấp Sự Nhiệm Vụ Đường (Sect Mission Hall Deacon)
## Offers daily sect commissions, patrol tasks and extermination bounties.

const SectSystemClass = preload("res://sources/sect/SectSystem.gd")

const QUEST_PATROL : int = ProgressCommons.Quest.TUAN_TRA_SON_MON
const QUEST_HUNT : int = ProgressCommons.Quest.DIET_TRU_MA_VAT

func OnStart():
	if not own or not own.stat:
		Farewell()
		return
		
	var rank : int = SectSystemClass.GetDiscipleRank(own)
	var rankName : String = SectSystemClass.GetDiscipleRankName(rank)
	var contrib : int = SectSystemClass.GetContribution(own)
	
	if rank == SectSystemClass.DiscipleRank.NONE:
		Mes("Nhiệm Vụ Đường chỉ phát phái ủy thác cho đệ tử môn phái.")
		Mes("Tán tu muốn nhận ủy thác xin hãy tới cổng Sơn Môn bái nhập đệ tử trước.")
		Choice("Vãn bối đã hiểu.", Farewell)
		return
		
	Mes("Chào mừng %s đến với Nhiệm Vụ Đường." % rankName)
	Mes("Điểm Cống Hiến hiện có: [%d Điểm]." % contrib)
	Mes("Tông môn phát phái nhiều loại nhiệm vụ: thường ngày, tuần tra, thu thập và thảo phạt.")
	
	_CheckPatrolQuest()

func _CheckPatrolQuest():
	var pState : int = GetQuest(QUEST_PATROL)
	if pState == ProgressCommons.UnknownProgress:
		Choice("Nhận nhiệm vụ thường ngày: Tuần Tra Sơn Môn (+40 Cống Hiến)", OnAcceptPatrol)
	elif pState >= ProgressCommons.TUAN_TRA_SON_MON.STARTED and pState < ProgressCommons.TUAN_TRA_SON_MON.OBJECTIVE_MET:
		Choice("Báo cáo tiến độ Tuần Tra Sơn Môn", OnReportPatrol)
	elif pState == ProgressCommons.TUAN_TRA_SON_MON.OBJECTIVE_MET:
		Choice("Giao nhiệm vụ: Tuần Tra Sơn Môn (Nhận 40 Cống Hiến, 60 Tu Vi)", OnCompletePatrol)
		
	_CheckHuntQuest()

func _CheckHuntQuest():
	var hState : int = GetQuest(QUEST_HUNT)
	if hState == ProgressCommons.UnknownProgress:
		Choice("Nhận ủy thác thảo phạt: Diệt Trừ Ma Vật (+50 Cống Hiến)", OnAcceptHunt)
	elif hState >= ProgressCommons.DIET_TRU_MA_VAT.STARTED and hState < ProgressCommons.DIET_TRU_MA_VAT.OBJECTIVE_MET:
		Choice("Báo cáo tiến độ Diệt Trừ Ma Vật", OnReportHunt)
	elif hState == ProgressCommons.DIET_TRU_MA_VAT.OBJECTIVE_MET:
		Choice("Giao nhiệm vụ: Diệt Trừ Ma Vật (Nhận 50 Cống Hiến, 70 Tu Vi)", OnCompleteHunt)
		
	Choice("Mở Giao Diện Tông Môn (Bảng Quản Lý).", OnOpenSectUI)
	Choice("Đệ tử xin phép cáo từ.", Farewell)

func OnAcceptPatrol():
	SetQuest(QUEST_PATROL, ProgressCommons.TUAN_TRA_SON_MON.STARTED)
	Mes("Hãy tuần tra quanh trận nhãn ngoại vi sơn môn và bảo đảm kết giới Trúc Sơn kiên cố.")
	NpcCommons.PushNotification(own, "ĐÃ NHẬN NHIỆM VỤ: [Tuần Tra Sơn Môn]!")
	Choice("Đệ tử sẽ lập tức xuất phát.", Farewell)

func OnReportPatrol():
	# Advance patrol step
	var cur = GetQuest(QUEST_PATROL)
	if cur < ProgressCommons.TUAN_TRA_SON_MON.OBJECTIVE_MET:
		SetQuest(QUEST_PATROL, cur + 1)
		var step = GetQuest(QUEST_PATROL)
		if step >= ProgressCommons.TUAN_TRA_SON_MON.OBJECTIVE_MET:
			Mes("Đạo hữu đã hoàn tất tuần tra toàn bộ 3 điểm trận nhãn ngoại vi!")
			Choice("Giao nộp nhiệm vụ & Nhận thưởng", OnCompletePatrol)
			return
		else:
			Mes("Đã tuần tra điểm trận nhãn thứ %d/3. Tiếp tục tuần tra các vị trí còn lại." % (step - 1))
	Choice("Rõ!", Farewell)

func OnCompletePatrol():
	SetQuest(QUEST_PATROL, ProgressCommons.CompletedProgress)
	SectSystemClass.AddContribution(own, 40, "Hoàn thành Tuần Tra Sơn Môn")
	if own.get("stat"):
		own.stat.SetExperience(60)
		own.stat.SetMoney(50)
	Mes("HOÀN THÀNH NHIỆM VỤ TUẦN TRA! Ngươi nhận được 40 Điểm Cống Hiến, 60 Tu Vi và 50 Linh Thạch.")
	NpcCommons.PushNotification(own, "+40 CỐNG HIẾN MÔN PHÁI!")
	Choice("Đa tạ Chấp sự!", Farewell)

func OnAcceptHunt():
	SetQuest(QUEST_HUNT, ProgressCommons.DIET_TRU_MA_VAT.STARTED)
	Mes("Gần đây yêu thú ngoại vi quấy nhiễu dược viên. Hãy tiêu diệt 3 yêu thú để trừ hại cho đồng môn.")
	NpcCommons.PushNotification(own, "ĐÃ NHẬN NHIỆM VỤ: [Diệt Trừ Ma Vật]!")
	Choice("Đệ tử đi ngay.", Farewell)

func OnReportHunt():
	SetQuest(QUEST_HUNT, ProgressCommons.DIET_TRU_MA_VAT.OBJECTIVE_MET)
	Mes("Đã tiêu diệt đủ 3 yêu vật xâm lấn ngoại vi!")
	Choice("Giao nộp nhiệm vụ & Nhận thưởng", OnCompleteHunt)

func OnCompleteHunt():
	SetQuest(QUEST_HUNT, ProgressCommons.CompletedProgress)
	SectSystemClass.AddContribution(own, 50, "Hoàn thành Diệt Trừ Ma Vật")
	if own.get("stat"):
		own.stat.SetExperience(70)
		own.stat.SetMoney(60)
	Mes("HOÀN THÀNH DIỆT TRỪ MA VẬT! Ngươi nhận được 50 Điểm Cống Hiến, 70 Tu Vi và 60 Linh Thạch.")
	NpcCommons.PushNotification(own, "+50 CỐNG HIẾN MÔN PHÁI!")
	Choice("Đa tạ Chấp sự!", Farewell)

func OnOpenSectUI():
	if Launcher.Gui:
		Launcher.Gui.call_deferred("ToggleSectWindow")
	Farewell()
