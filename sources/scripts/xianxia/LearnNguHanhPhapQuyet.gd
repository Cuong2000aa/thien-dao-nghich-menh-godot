extends CellScript
class_name LearnNguHanhPhapQuyet

## Ngũ Hành Pháp Quyết — lĩnh hội 8 tuyệt học phép thuật + tu tiên (PixelFX).

func Execute(actor : Actor, _cell : BaseCell):
	if not actor or not actor.progress:
		return

	var skillNames : Array[String] = [
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

	if actor is PlayerAgent and actor.peerID != NetworkCommons.PeerUnknownID:
		var charID : int = Peers.GetCharacter(actor.peerID)
		if charID != NetworkCommons.PeerUnknownID:
			var dbPath = SQLCommons.GetDBPath()
			var db = SQLite.new()
			db.path = dbPath
			if db.open_db():
				var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
				CombatSystemClass.EnsureMartialArtsTable(db)
				var arts : Array = [1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017]
				for i in arts.size():
					CombatSystemClass.SaveMartialArt(db, charID, int(arts[i]), 1, 0, i)
				db.close_db()

	NpcCommons.PushNotification(actor, "LĨNH HỘI NGŨ HÀNH PHÁP QUYẾT! Đạo hữu đã học 8 tuyệt học phép–tu tiên (Hỏa Long, Hàn Băng, Lôi Phạt, Huyền Âm, Thánh Quang, Địa Long, Tử Lôi, Hư Không)!")
