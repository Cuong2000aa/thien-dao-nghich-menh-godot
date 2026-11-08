extends Node2D

## Headless accuracy checks for QuestGuidance spawn resolution.

const QuestGuidanceClass = preload("res://sources/quest/QuestGuidance.gd")

func _ready():
	if not DB.isInitialized:
		await Launcher.dbInitialized

	print("=== QuestGuidance accuracy ===")
	QuestGuidanceClass.InvalidateIndex()
	QuestGuidanceClass.RebuildIndex()

	var fails : int = 0

	# 1) Nick index must find core SacredSectHub spawns
	var checks : Array = [
		["Đạo Huyền Trưởng Lão", "SacredSectHub", Vector2(1000, 1300)],
		["Tiếp Dẫn Chấp Sự", "SacredSectHub", Vector2(1050, 1460)],
		["Linh Trùng", "SacredSectHub", Vector2(1100, 1350)],
		["Ngân Linh Thảo", "SacredSectHub", Vector2(1150, 1400)],
		["Huyền Thiết Khoáng", "Tulimshar Eastern Hills", Vector2(2600, 1300)],
		["Xakelbael", "Desert Deep Level", Vector2(1331, 1478)],
		["Nickos", "Desert Abandoned Level", Vector2(2860, 1832)],
		["Ryan", "Desert Mines", Vector2(1080, 994)],
		["Mana Tree", "Desert Deep Level", Vector2(1349, 1349)],
		["Cây Linh Mộc", "Desert Deep Level", Vector2(1349, 1349)],
	]
	for c in checks:
		var nick : String = c[0]
		var expectMap : String = c[1]
		var expectPos : Vector2 = c[2]
		var spawns : Array = QuestGuidanceClass.FindSpawns(nick)
		if spawns.is_empty():
			print("[FAIL] no spawn for nick:", nick)
			fails += 1
			continue
		var hit : bool = false
		for s in spawns:
			if s.get("map_internal") == expectMap and Vector2(s.get("position")).distance_to(expectPos) < 1.0:
				hit = true
				break
		if hit:
			print("[PASS] %s @ %s %s" % [nick, expectMap, expectPos])
		else:
			print("[FAIL] %s expected %s %s got %s" % [nick, expectMap, expectPos, spawns])
			fails += 1

	# 2) Thanh Trừ Linh Trùng STARTED → kill Linh Trùng at hub
	var qid : int = ProgressCommons.Quest.THANH_TRU_LINH_TRUNG
	var step : Dictionary = QuestGuidanceClass.BuildStep(qid, ProgressCommons.THANH_TRU_LINH_TRUNG.STARTED)
	if step.get("resolved") and step.get("nick") == "Linh Trùng" and step.get("map_internal") == "SacredSectHub":
		print("[PASS] ThanhTru STARTED → Linh Trùng @ SacredSectHub", step.get("position"))
	else:
		print("[FAIL] ThanhTru STARTED step:", step)
		fails += 1

	# 3) OBJECTIVE_MET → return Đạo Huyền
	step = QuestGuidanceClass.BuildStep(qid, ProgressCommons.THANH_TRU_LINH_TRUNG.OBJECTIVE_MET)
	if step.get("resolved") and step.get("nick") == "Đạo Huyền Trưởng Lão" and int(step.get("action")) == QuestGuidanceClass.Action.RETURN:
		print("[PASS] ThanhTru OBJECTIVE_MET → return Đạo Huyền", step.get("position"))
	else:
		print("[FAIL] ThanhTru turn-in step:", step)
		fails += 1

	# 4) MQ Chương 1 talk Tiếp Dẫn
	qid = ProgressCommons.Quest.MQ_CHUONG_1_TINH_LAC_DI_GIOI
	step = QuestGuidanceClass.BuildStep(qid, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
	if step.get("resolved") and step.get("nick") == "Tiếp Dẫn Chấp Sự":
		print("[PASS] MQ1 → Tiếp Dẫn", step.get("position"))
	else:
		print("[FAIL] MQ1 step:", step)
		fails += 1

	# 5) MatchNickInText
	var matched : String = QuestGuidanceClass.MatchNickInText("Tiêu diệt 5 Linh Trùng dưới chân núi")
	if matched == "Linh Trùng":
		print("[PASS] MatchNickInText Linh Trùng")
	else:
		print("[FAIL] MatchNickInText got:", matched)
		fails += 1

	# 6) MINE_EXPLORATION STRANGER_SPOTTED -> Xakelbael @ Desert Deep Level (TALK)
	qid = ProgressCommons.Quest.MINE_EXPLORATION
	step = QuestGuidanceClass.BuildStep(qid, ProgressCommons.MINE_EXPLORATION.STRANGER_SPOTTED)
	if step.get("resolved") and step.get("nick") == "Xakelbael" and step.get("map_internal") == "Desert Deep Level" and step.get("action") == QuestGuidanceClass.Action.TALK:
		print("[PASS] MineExploration STRANGER_SPOTTED → Xakelbael (TALK) @ Desert Deep Level", step.get("position"))
	else:
		print("[FAIL] MineExploration STRANGER_SPOTTED step:", step)
		fails += 1

	# 7) MINE_EXPLORATION FIGHTING -> Xakelbael @ Desert Deep Level (KILL)
	var stepFight = QuestGuidanceClass.BuildStep(qid, ProgressCommons.MINE_EXPLORATION.FIGHTING)
	if stepFight.get("resolved") and stepFight.get("nick") == "Xakelbael" and stepFight.get("action") == QuestGuidanceClass.Action.KILL:
		print("[PASS] MineExploration FIGHTING → Xakelbael (KILL) @ Desert Deep Level", stepFight.get("position"))
	else:
		print("[FAIL] MineExploration FIGHTING step:", stepFight)
		fails += 1

	# 8) MINE_EXPLORATION DEFEATED -> Mana Tree @ Desert Deep Level (TALK) at (1349, 1349)
	var stepTree = QuestGuidanceClass.BuildStep(qid, ProgressCommons.MINE_EXPLORATION.DEFEATED)
	if stepTree.get("resolved") and stepTree.get("nick") == "Mana Tree" and stepTree.get("map_internal") == "Desert Deep Level" and Vector2(stepTree.get("position")).distance_to(Vector2(1349, 1349)) < 1.0 and stepTree.get("action") == QuestGuidanceClass.Action.TALK:
		print("[PASS] MineExploration DEFEATED → Mana Tree (TALK) @ Desert Deep Level (1349, 1349)", stepTree.get("position"))
	else:
		print("[FAIL] MineExploration DEFEATED step:", stepTree)
		fails += 1

	# 9) MINE_EXPLORATION MANA_TREE_MET -> Ryan @ Desert Mines (RETURN)
	var stepRyan = QuestGuidanceClass.BuildStep(qid, ProgressCommons.MINE_EXPLORATION.MANA_TREE_MET)
	if stepRyan.get("resolved") and stepRyan.get("nick") == "Ryan" and stepRyan.get("map_internal") == "Desert Mines" and stepRyan.get("action") == QuestGuidanceClass.Action.RETURN:
		print("[PASS] MineExploration MANA_TREE_MET → Ryan (RETURN) @ Desert Mines", stepRyan.get("position"))
	else:
		print("[FAIL] MineExploration MANA_TREE_MET step:", stepRyan)
		fails += 1

	print("=== RESULT fails=%d ===" % fails)
	get_tree().quit(0 if fails == 0 else 1)
