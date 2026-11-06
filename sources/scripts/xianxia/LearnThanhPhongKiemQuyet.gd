extends CellScript
class_name LearnThanhPhongKiemQuyet

func Execute(actor : Actor, _cell : BaseCell):
	if not actor or not actor.progress:
		return
		
	# Skills to learn
	var skillNames : Array[String] = [
		"Thanh Phong Kiếm Khí",
		"Trúc Sơn Kiếm Trận",
		"Đạp Phong Bộ",
		"Vạn Kiếm Quy Tông",
		"Nhất Kiếm Trảm Thiên Môn",
		# Ngũ hành pháp–tu tiên
		"Hỏa Long Phun Tức",
		"Hàn Băng Thiên Kiếm",
		"Lôi Phạt Cửu Thiên",
		"Huyền Âm Thôn Hồn",
		"Thánh Quang Hộ Đạo",
		"Địa Long Phá Sơn",
		"Tử Lôi Liên Hoàn",
		"Hư Không Hấp Tinh",
	]
	
	for sName in skillNames:
		var sHash : int = DB.GetCellHash(sName)
		var sCell : SkillCell = DB.GetSkill(sHash)
		if sCell:
			actor.progress.AddSkill(sCell, 1, true)
			
	# Save to SQLite char_martial_arts if PlayerAgent
	if actor is PlayerAgent and actor.peerID != NetworkCommons.PeerUnknownID:
		var charID : int = Peers.GetCharacter(actor.peerID)
		if charID != NetworkCommons.PeerUnknownID:
			var dbPath = SQLCommons.GetDBPath()
			var db = SQLite.new()
			db.path = dbPath
			if db.open_db():
				var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
				CombatSystemClass.EnsureMartialArtsTable(db)
				CombatSystemClass.SaveMartialArt(db, charID, 1001, 1, 0, 0) # Thanh Phong Kiếm Quyết
				CombatSystemClass.SaveMartialArt(db, charID, 1002, 1, 0, 1) # Thanh Phong Kiếm Khí
				CombatSystemClass.SaveMartialArt(db, charID, 1003, 1, 0, 2) # Trúc Sơn Kiếm Trận
				CombatSystemClass.SaveMartialArt(db, charID, 1004, 1, 0, 3) # Đạp Phong Bộ
				CombatSystemClass.SaveMartialArt(db, charID, 1008, 1, 0, 4) # Vạn Kiếm Quy Tông
				CombatSystemClass.SaveMartialArt(db, charID, 1009, 1, 0, 5) # Nhất Kiếm Trảm Thiên Môn
				var extraArts : Array = [1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017]
				for i in extraArts.size():
					CombatSystemClass.SaveMartialArt(db, charID, int(extraArts[i]), 1, 0, 6 + i)
				db.close_db()
		NpcCommons.PushNotification(actor, "LĨNH HỘI THÀNH CÔNG! Đạo hữu đã học [Thanh Phong Kiếm Quyết], tuyệt học kiếm đạo và Ngũ Hành Pháp Quyết!")
