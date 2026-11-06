extends Node2D

## Full coverage: every quest in DB.QuestsDB must resolve STARTED to a real map coord.

const QuestGuidanceClass = preload("res://sources/quest/QuestGuidance.gd")

func _ready():
	if not DB.isInitialized:
		await Launcher.dbInitialized

	print("=== QuestGuidance FULL coverage ===")
	QuestGuidanceClass.InvalidateIndex()
	QuestGuidanceClass.RebuildIndex()

	var report : Dictionary = QuestGuidanceClass.AuditAllQuests()
	var ok : Array = report.get("ok", [])
	var bad : Array = report.get("bad", [])
	var total : int = int(report.get("total", 0))

	print("Resolved %d / %d" % [ok.size(), total])
	for name in ok:
		var qid : int = name.hash()
		# Quest id is SetCellHash(name) — use DB lookup
		var qData : QuestData = null
		for id in DB.QuestsDB:
			if DB.QuestsDB[id].name == name:
				qData = DB.QuestsDB[id]
				qid = id
				break
		var step : Dictionary = QuestGuidanceClass.BuildStep(qid, 1)
		print("  OK  %-40s → %s @ %s (%d,%d)" % [
			name,
			step.get("nick", ""),
			step.get("map_internal", step.get("map_display", "")),
			int(step.get("position", Vector2.ZERO).x),
			int(step.get("position", Vector2.ZERO).y),
		])

	if not bad.is_empty():
		print("--- UNRESOLVED ---")
		for b in bad:
			print("  XX  ", b)

	# Spot-check turn-in for Thanh Trừ
	var thanh : Dictionary = QuestGuidanceClass.BuildStep(
		ProgressCommons.Quest.THANH_TRU_LINH_TRUNG,
		ProgressCommons.THANH_TRU_LINH_TRUNG.OBJECTIVE_MET
	)
	var turnOk : bool = thanh.get("resolved") and thanh.get("nick") == "Đạo Huyền Trưởng Lão"
	print("Turn-in ThanhTru:", "PASS" if turnOk else "FAIL", thanh.get("nick"), thanh.get("position"))

	var fails : int = bad.size() + (0 if turnOk else 1)
	# Also require objective table covers every quest
	QuestGuidanceClass._EnsureObjectiveTable()
	var missingOverride : Array = []
	for id in DB.QuestsDB:
		if not QuestGuidanceClass._objectiveTable.has(id):
			missingOverride.append(DB.QuestsDB[id].name)
	if not missingOverride.is_empty():
		print("--- MISSING OVERRIDE ---")
		for m in missingOverride:
			print("  !! ", m)
		fails += missingOverride.size()

	print("=== RESULT fails=%d resolved=%d/%d ===" % [fails, ok.size(), total])
	get_tree().quit(0 if fails == 0 and ok.size() == total else 1)
