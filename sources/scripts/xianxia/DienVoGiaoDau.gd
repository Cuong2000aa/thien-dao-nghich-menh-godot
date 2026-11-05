extends NpcScript

## NPC Script: Diễn Võ Giáo Đầu (Martial Field Instructor)
## Conducts disciple sparring exams, tests martial combat proficiency for Outer/Inner promotions.

const SectSystemClass = preload("res://sources/sect/SectSystem.gd")
const CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")

const QUEST_KHAO_HACH_NGOAI : int = ProgressCommons.Quest.KHAO_HACH_NGOAI_MON

func OnStart():
	if not own or not own.stat:
		Farewell()
		return
		
	var rank : int = SectSystemClass.GetDiscipleRank(own)
	var rankName : String = SectSystemClass.GetDiscipleRankName(rank)
	
	Mes("Quyền phong như sấm, kiếm khí như hồng! Bản giáo đầu phụ trách khảo nghiệm thực chiến tại Diễn Võ Đường.")
	Mes("Chào %s. Chiến trường không có chỗ cho kẻ yếu đuối, chỉ có thực lực chân chính mới giành được tôn nghiêm." % rankName)
	
	var qState : int = GetQuest(QUEST_KHAO_HACH_NGOAI)
	if qState == ProgressCommons.KHAO_HACH_NGOAI_MON.STARTED:
		Choice("Tiến hành khảo thí võ công để thăng cấp Ngoại Môn Đệ Tử!", OnStartSparring)
	elif qState == ProgressCommons.KHAO_HACH_NGOAI_MON.SPARRING_WON:
		Mes("Khảo thí võ nghệ của ngươi đã đạt yêu cầu xuất sắc. Hãy mau về Đại Điện bái kiến Đạo Huyền Trưởng Lão để thụ phong lệnh bài!")
		Choice("Đệ tử xin đa tạ giáo đầu!", Farewell)
		return
		
	Choice("Thỉnh giáo khẩu quyết Liên Kích Tam Thức của Kiếm Phái.", OnExplainCombo)
	Choice("Luận bàn võ nghệ luyện tập đòn đánh.", OnPracticeCombat)
	Choice("Cáo từ Giáo đầu.", Farewell)

func OnStartSparring():
	# Validate player level and sword qi or combat readiness
	var playerLevel : int = own.stat.level if own.get("stat") else 1
	if playerLevel < 2:
		Mes("Cảnh giới chưa đủ! Cần đạt ít nhất [Tụ Khí • Tầng 1] mới có đủ linh lực để tiếp chiêu.")
		Choice("Đệ tử sẽ tiếp tục khổ tu.", Farewell)
		return
		
	# Execute sparring assessment
	SetQuest(QUEST_KHAO_HACH_NGOAI, ProgressCommons.KHAO_HACH_NGOAI_MON.SPARRING_WON)
	if own.get("stat"):
		own.stat.SetExperience(50)
	SectSystemClass.AddContribution(own, 30, "Vượt qua Diễn Võ Khảo Thí")
	
	Mes("HẢO KIẾM PHÁP! Đòn thế cương nhu hòa hợp, bộ pháp biến hóa linh hoạt.")
	Mes("Ngươi đã vượt qua bài khảo hạch thực chiến của Diễn Võ Đường! Nhận thêm 30 Điểm Cống Hiến và 50 Tu Vi.")
	Mes("Hãy trở về Đại Điện báo cáo với Đạo Huyền Trưởng Lão để chính thức tấn thăng Ngoại Môn!")
	NpcCommons.PushNotification(own, "VƯỢT QUA KHẢO HẠCH DIỄN VÕ ĐƯỜNG!")
	Choice("Đệ tử bái tạ Giáo đầu chỉ giáo!", Farewell)

func OnExplainCombo():
	Mes("Khẩu quyết Liên Kích Tam Thức của Trúc Sơn:")
	Mes("• Thức 1 (Thanh Phong Sơ Thức): Đòn đánh mở màn thanh thoát, nạp 1 tầng Kiếm Khí.")
	Mes("• Th thức 2 (Lạc Diệp Nhị Thức): Kiếm khí tăng uy lực lên 1.25x, đẩy lùi địch thủ.")
	Mes("• Thức 3 (Phá Không Tam Thức): Nhất kiếm đoạn không, bộc phát 1.6x sát thương cực đại và nạp thêm 2 tầng Kiếm Khí!")
	Mes("• Tích lũy đủ 5 tầng Kiếm Khí sẽ kích phát cảnh giới Kiếm Ý Viên Mãn, tăng vọt Công Kích và Bạo Kích.")
	Choice("Đệ tử đã lĩnh ngộ sâu sắc.", OnStart)

func OnPracticeCombat():
	Mes("Tốt! Đứng vững tấn pháp, ngưng thần tĩnh khí, xuất chiêu!")
	CombatSystemClass.AddSwordQi(own, 2)
	NpcCommons.PushNotification(own, "DIỄN VÕ THỰC HÀNH: +2 TẦNG KIẾM KHÍ!")
	Choice("Đa tạ Giáo đầu!", Farewell)
