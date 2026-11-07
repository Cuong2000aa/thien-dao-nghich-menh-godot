extends NpcScript

## NPC Script: Tiếp Dẫn Chấp Sự (Sect Recruiter at Mountain Gate)
## Welcomes new wanderers, offers entry trial, bestows initial disciple rank & starter package.

const SectSystemClass = preload("res://sources/sect/SectSystem.gd")
const CultivationClass = preload("res://sources/actor/Cultivation.gd")

const QUEST_NHAP_MON : int = ProgressCommons.Quest.NHAP_MON_KHAO_NGHIEM

func OnStart():
	if not own or not own.stat:
		Farewell()
		return
		
	var rank : int = SectSystemClass.GetDiscipleRank(own)
	var rankName : String = SectSystemClass.GetDiscipleRankName(rank)
	
	if rank == SectSystemClass.DiscipleRank.NONE:
		# Player is not yet in sect — người xuyên không vừa tới
		Mes("Thiện tai. Bần đạo là Tiếp Dẫn Chấp Sự trông coi sơn môn Trúc Sơn.")
		Mes("Khí tức đạo hữu tạp loạn như kẻ vừa bị cuốn khỏi nơi khác — thân xác thật, không phải đoạt xá. Ngũ hành trong đan điền hỗn độn: tạp căn.")
		Mes("Nếu còn ký ức đứt đoạn, hãy ở lại sơn môn làm việc và hỏi đạo dần. Chẳng hay có chí bái nhập môn phái?")

		var qState : int = GetQuest(QUEST_NHAP_MON)
		var mq1 : int = GetQuest(ProgressCommons.Quest.MQ_CHUONG_1_TINH_LAC_DI_GIOI)
		if mq1 != ProgressCommons.CompletedProgress and mq1 != ProgressCommons.UnknownProgress:
			# Active MQ1 — ưu tiên chỉ dẫn tỉnh lạc
			Choice("Đạo hữu lạc lối xin chỉ điểm (Tỉnh Lạc Dị Giới).", OnMainStoryMQ1)
		elif mq1 == ProgressCommons.UnknownProgress:
			Choice("Ta vừa xuyên tới nơi này — xin chấp sự giúp nhận diện thân thể.", OnMainStoryMQ1)
		if qState == ProgressCommons.UnknownProgress:
			Choice("Đệ tử lạc lối, xin chấp sự cho khảo nghiệm nhập môn!", OnAcceptTrial)
			Choice("Xin thỉnh giáo tôn chỉ và quy tắc của môn phái.", OnExplainSect)
			Choice("Vãn bối chỉ đi ngang qua, xin phép cáo từ.", Farewell)
		elif qState == ProgressCommons.NHAP_MON_KHAO_NGHIEM.STARTED:
			Mes("Khảo nghiệm nhập môn: Đạo hữu hãy tĩnh tâm hít thở, vận hành chân khí một chu thiên rồi bái kiến Đạo Huyền Trưởng Lão tại Đại Điện.")
			Choice("Đệ tử đã hoàn tất vận khí chu thiên, xin diện kiến chấp sự!", OnCompleteTrial)
			Choice("Đệ tử xin chuẩn bị thêm.", Farewell)
		elif qState >= ProgressCommons.NHAP_MON_KHAO_NGHIEM.OBJECTIVE_MET:
			_BestowInitiation()
	else:
		# Player already a disciple
		var pName : String = str(own.nick) if own.get("nick") and not str(own.nick).is_empty() else "Sư đệ"
		Mes("Kính chào %s! Thân phận hiện tại: [%s]." % [pName, rankName])
		Mes("Sơn môn Trúc Sơn linh khí dồi dào. Đạo hữu hãy tích cực hoàn thành nhiệm vụ tông môn và rèn luyện đạo tâm.")
		Choice("Xin hỏi các khu vực công trình trong môn phái.", OnGuideFacilities)
		Choice("Cáo từ Tiếp Dẫn Chấp Sự.", Farewell)

func OnMainStoryMQ1():
	var qId : int = ProgressCommons.Quest.MQ_CHUONG_1_TINH_LAC_DI_GIOI
	var st : int = GetQuest(qId)
	if st == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Được. Hãy tĩnh tâm cảm nhận đan điền — ngũ hành tạp loạn là thật, không phải ảo giác.")
		Mes("Ký ức sẽ về dần khi đạo hữu đi lại, làm việc và hỏi đạo. Đây là bước đầu: nhận mình đang ở dị giới.")
		Choice("Đệ tử đã cảm nhận — xin ghi nhận tiến trình.", OnMainStoryMQ1Complete)
		Choice("Đệ tử cần thêm thời gian.", Farewell)
	elif st > ProgressCommons.UnknownProgress and st < ProgressCommons.CompletedProgress:
		OnMainStoryMQ1Complete()
	else:
		Mes("Đạo hữu đã nhận diện thân cảnh. Hãy tiếp tục hỏi đạo và xét khảo nghiệm nhập môn.")
		Choice("Xin cảm ơn chấp sự.", Farewell)

func OnMainStoryMQ1Complete():
	var qId : int = ProgressCommons.Quest.MQ_CHUONG_1_TINH_LAC_DI_GIOI
	if GetQuest(qId) >= ProgressCommons.CompletedProgress:
		Mes("Đạo hữu đã nhận diện thân cảnh rồi.")
		Choice("Xin cảm ơn chấp sự.", Farewell)
		return
	SetQuest(qId, ProgressCommons.CompletedProgress)
	AddExp(100)
	AddGP(50)
	var clothHash : int = DB.GetCellHash("Cotton Shirt")
	if clothHash != DB.UnknownHash:
		AddItem(clothHash, 1, "Used")
	var StorySystemClass = preload("res://sources/story/StorySystem.gd")
	StorySystemClass.UnlockClue(own, "CLUE_1_QI_FLUCTUATION")
	Mes("Ghi nhận: đạo hữu tỉnh lạc dị giới, tạp căn, ký ức đứt đoạn. Phần thưởng sơ: Tu Vi, Linh Thạch, vật dụng thô — và manh mối linh khí triều tịch.")
	NpcCommons.PushNotification(own, "Hoàn thành [Tỉnh Lạc Dị Giới] — Mảnh Ký Ức I!")
	Choice("Đệ tử xin tuân theo.", Farewell)

func OnAcceptTrial():
	SetQuest(QUEST_NHAP_MON, ProgressCommons.NHAP_MON_KHAO_NGHIEM.STARTED)
	Mes("Tốt lắm! Người tu đạo quan trọng nhất là tâm tính kiên định, không sợ gian khổ.")
	Mes("Hãy vận hành chu thiên khí hải, sau đó tiến vào Đại Điện trình diện.")
	Choice("Đệ tử xin tuân mệnh!", Farewell)

func OnExplainSect():
	var sectData = SectSystemClass.SECT_REGISTRY.get(SectSystemClass.DEFAULT_SECT_ID, {})
	Mes("Tông môn chúng ta kế thừa đạo thống ngàn năm: '%s'" % sectData.get("tenet", ""))
	Mes("Tông môn phân chia đệ tử thành 5 bậc nghiêm ngặt: Tạp Dịch, Ngoại Môn, Nội Môn, Chân Truyền và Thân Truyền.")
	Mes("Mỗi cấp bậc đều hưởng thụ tài nguyên và quyền hạn tương xứng, lấy Điểm Cống Hiến và Cảnh Giới làm thước đo thăng tiến.")
	Choice("Đệ tử đã hiểu, xin nhận bài khảo nghiệm!", OnAcceptTrial)
	Choice("Đa tạ Chấp sự chỉ điểm.", Farewell)

func OnCompleteTrial():
	SetQuest(QUEST_NHAP_MON, ProgressCommons.NHAP_MON_KHAO_NGHIEM.OBJECTIVE_MET)
	_BestowInitiation()

func _BestowInitiation():
	SetQuest(QUEST_NHAP_MON, ProgressCommons.CompletedProgress)
	SectSystemClass.SetDiscipleRank(own, SectSystemClass.DiscipleRank.TAP_DICH)
	SectSystemClass.AddContribution(own, 20, "Nhập Môn Tông Môn Lễ Bao")
	
	# Award Initiation Package: Tạp Dịch Lệnh Bài & 50 Linh Thạch & 30 Tu Vi
	var tokenCell = DB.GetItem(DB.GetCellHash("Tap Dich Lenh Bai"))
	if tokenCell and own.get("inventory"):
		own.inventory.AddItem(tokenCell, 1)
		
	if own.get("stat"):
		own.stat.SetExperience(30)
		own.stat.SetMoney(50)
		
	# Save to SQLite if player peer
	if own is PlayerAgent and own.peerID != NetworkCommons.PeerUnknownID:
		var charID : int = Peers.GetCharacter(own.peerID)
		if charID != NetworkCommons.PeerUnknownID:
			var dbPath = SQLCommons.GetDBPath()
			var db = SQLite.new()
			db.path = dbPath
			if db.open_db():
				SectSystemClass.EnsureSectTables(db)
				SectSystemClass.SaveSectData(db, charID, SectSystemClass.GetSectData(own))
				db.close_db()
				
	Mes("CHÚC MỪNG ĐẠO HỮU CHÍNH THỨC NHẬP MÔN!")
	Mes("Ngươi đã được ban thưởng [Tạp Dịch Lệnh Bài], 30 Tu Vi, 50 Linh Thạch và 20 Điểm Cống Hiến khởi đầu.")
	Mes("Hãy mau đến Đại Điện gặp Đạo Huyền Trưởng Lão hoặc tới Nhiệm Vụ Đường để nhận ủy thác môn phái.")
	NpcCommons.PushNotification(own, "BÁI NHẬP MÔN PHÁI! Thân phận: [Tạp Dịch Đệ Tử]!")
	Choice("Đệ tử đa tạ Tiếp Dẫn Chấp Sự!", Farewell)

func OnGuideFacilities():
	Mes("Hướng dẫn phân bố các công trình tại Trúc Sơn Tiên Cảnh:")
	Mes("• Đại Điện (ở phía Bắc): Gặp Trưởng lão nhận chỉ thị và khảo hạch thăng cấp.")
	Mes("• Tàng Kinh Các (ở phía Tây Bắc): Nơi chứa bí tịch võ học và kiếm quyết tông môn.")
	Mes("• Dược Đường & Lò Luyện Đan (ở phía Tây): Mua bán đan dược và luyện chế linh đan.")
	Mes("• Tụ Linh Trận (Đài Thái Cực ở phía Nam): Đả tọa tu luyện gia tốc linh khí.")
	Mes("• Diễn Võ Đường (ở phía Đông): Nơi luyện tập võ nghệ và khảo hạch thực chiến.")
	Choice("Đệ tử đã ghi nhớ rõ.", Farewell)
