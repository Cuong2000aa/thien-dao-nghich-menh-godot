extends NpcScript

## NPC Script: Tàng Kinh Các Lão (Scripture Pavilion Elder)
## Guards sect martial scriptures, checks disciple rank and imparts techniques for Sect Contribution.

const SectSystemClass = preload("res://sources/sect/SectSystem.gd")

func OnStart():
	if not own or not own.stat:
		Farewell()
		return
		
	var rank : int = SectSystemClass.GetDiscipleRank(own)
	var rankName : String = SectSystemClass.GetDiscipleRankName(rank)
	var contrib : int = SectSystemClass.GetContribution(own)
	
	if rank == SectSystemClass.DiscipleRank.NONE:
		Mes("DỪNG BƯỚC! Tàng Kinh Các là trọng địa cấm cung của tông môn.")
		Mes("Kẻ chưa bái nhập môn phái không được phép đặt chân vào nửa bước. Hãy mau quay về Sơn Môn gặp Tiếp Dẫn Chấp Sự!")
		Choice("Vãn bối xin cáo lui.", Farewell)
		return
		
	Mes("Lão hủ phụ trách trông coi Tàng Kinh Các ngàn năm qua.")
	Mes("Chào %s. Điểm Cống Hiến hiện có: [%d Điểm]." % [rankName, contrib])
	Mes("Tại đây lưu giữ vô số kiếm quyết, tâm pháp và thân pháp từ thời lập phái đến nay.")
	
	Choice("Xem danh sách Công Pháp có thể tham ngộ.", OnBrowseScriptures)
	Choice("Thỉnh giáo Các Lão về quy tắc Tàng Kinh Các.", OnExplainRules)
	Choice("Đệ tử xin phép cáo từ.", Farewell)

func OnExplainRules():
	Mes("Quy tắc tham ngộ bí kíp tại Tàng Kinh Các:")
	Mes("1. Tạp Dịch Đệ Tử: Miễn phí lĩnh ngộ [Trúc Sơn Dẫn Khí Quyết] sơ bộ.")
	Mes("2. Ngoại Môn Đệ Tử: Được phép đổi võ học Hoàng Giai ([Thanh Phong Kiếm Quyết], [Đạp Phong Bộ], [Quy Nguyên Thuẫn]).")
	Mes("3. Nội Môn Đệ Tử: Mở khóa quyền tiến nhập tầng 2, lĩnh ngộ [Trúc Sơn Kiếm Trận] huyền ảo.")
	Mes("4. Chân Truyền Đệ Tử: Tiếp cận truyền thừa tối thượng của Thái Thượng Trưởng Lão.")
	Choice("Đệ tử đã hiểu rõ.", OnBrowseScriptures)
	Choice("Cáo từ Các Lão.", Farewell)

func OnBrowseScriptures():
	var rank : int = SectSystemClass.GetDiscipleRank(own)
	var contrib : int = SectSystemClass.GetContribution(own)
	
	Mes("--- DANH MỤC TRUYỀN THỪA CÔNG PHÁP ---")
	Mes("Cống hiến khả dụng: [%d Điểm] | Thân phận: [%s]" % [contrib, SectSystemClass.GetDiscipleRankName(rank)])
	
	for sc in SectSystemClass.SCRIPTURE_CATALOG:
		var scId : int = sc["id"]
		var cost : int = sc["cost"]
		var reqRankName : String = SectSystemClass.GetDiscipleRankName(sc["reqRank"])
		var label : String = "Lĩnh ngộ [%s] (%s - Cần: %s, %d Cống Hiến)" % [sc["name"], sc["category"], reqRankName, cost]
		Choice(label, _OnChooseScripture.bind(scId))
		
	Choice("Trở lại.", OnStart)

func _OnChooseScripture(scId : int):
	var result : Dictionary = SectSystemClass.LearnScripture(own, scId)
	if result["success"]:
		Mes("KHOẢNH KHẮC THÔNG TUỆ! %s" % result["message"])
		NpcCommons.PushNotification(own, "ĐÃ LĨNH HỘI CÔNG PHÁP: [%s]!" % result.get("skillLearned", ""))
		# Save state
		if own is PlayerAgent and own.peerID != NetworkCommons.PeerUnknownID:
			var charID : int = Peers.GetCharacter(own.peerID)
			if charID != NetworkCommons.PeerUnknownID:
				var dbPath = SQLCommons.GetDBPath()
				var db = SQLite.new()
				db.path = dbPath
				if db.open_db():
					SectSystemClass.SaveSectData(db, charID, SectSystemClass.GetSectData(own))
					db.close_db()
	else:
		Mes("KHÔNG THỂ THAM NGỘ: %s" % result["message"])
		
	Choice("Tiếp tục xem công pháp khác.", OnBrowseScriptures)
	Choice("Đa tạ Các Lão, đệ tử xin lui.", Farewell)
