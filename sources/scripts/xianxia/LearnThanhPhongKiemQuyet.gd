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
				db.close_db()
		NpcCommons.PushNotification(actor, "LĨNH HỘI THÀNH CÔNG! Đạo hữu đã học được [Thanh Phong Kiếm Quyết] cùng tuyệt học [Vạn Kiếm Quy Tông] và [Nhất Kiếm Trảm Thiên Môn]!")
