extends Node2D

const QuestGuidanceClass = preload("res://sources/quest/QuestGuidance.gd")
const QuestAutoControllerClass = preload("res://sources/quest/QuestAutoController.gd")

func _ready():
	if not DB.isInitialized:
		await Launcher.dbInitialized

	print("=== test_quest_auto_flow ===")
	var fails : int = 0

	# 1. Test Tutorial initial state (KAEL_MET with 0 kills)
	var qid : int = ProgressCommons.Quest.TUTORIAL
	var s0 : Dictionary = QuestGuidanceClass.BuildStep(qid, ProgressCommons.TUTORIAL.KAEL_MET)
	if s0.get("nick") != "Peyote" or s0.get("action") != QuestGuidanceClass.Action.KILL:
		print("[FAIL] Initial KAEL_MET step should be Peyote, got: ", s0.get("nick"))
		fails += 1
	else:
		print("[PASS] Initial KAEL_MET step is Peyote")

	# 2. Test Multi-mob dynamic switch: simulate Peyote completed (5/5) via AutoController _killCounts
	var autoCtrl = QuestAutoControllerClass.new()
	add_child(autoCtrl)
	autoCtrl._killCounts["Peyote"] = 5
	autoCtrl._killCounts["Maggot"] = 0

	if Launcher.GUI == null:
		# Create mock GUI reference if headless without UI
		Launcher.GUI = Node.new()
	Launcher.GUI.set("questAutoController", autoCtrl)

	var sPeyoteDone : Dictionary = QuestGuidanceClass.BuildStep(qid, ProgressCommons.TUTORIAL.KAEL_MET)
	if sPeyoteDone.get("nick") != "Maggot":
		print("[FAIL] When Peyote is 5/5, guidance should switch to Maggot, got: ", sPeyoteDone.get("nick"))
		fails += 1
	else:
		print("[PASS] When Peyote is 5/5, guidance dynamically targets Maggot!")

	# 3. Test when both Peyote and Maggot are completed (5/5 and 5/5)
	autoCtrl._killCounts["Maggot"] = 5
	var sBothDone : Dictionary = QuestGuidanceClass.BuildStep(qid, ProgressCommons.TUTORIAL.KAEL_MET)
	if not sBothDone.get("turn_in") or sBothDone.get("nick") != "Kael":
		print("[FAIL] When both Peyote and Maggot are 5/5, should turn in at Kael, got: ", sBothDone)
		fails += 1
	else:
		print("[PASS] When both 5/5, guidance switches to Return Kael!")

	# 4. Test Mana Tree anchor and DEFEATED state
	var mineQid : int = ProgressCommons.Quest.MINE_EXPLORATION
	var sTree : Dictionary = QuestGuidanceClass.BuildStep(mineQid, ProgressCommons.MINE_EXPLORATION.DEFEATED)
	var treePos : Vector2 = sTree.get("position", Vector2.ZERO)
	if treePos.distance_to(Vector2(1349, 1349)) > 1.0 or sTree.get("nick") != "Mana Tree":
		print("[FAIL] Mana Tree step coords incorrect: ", sTree)
		fails += 1
	else:
		print("[PASS] Mana Tree DEFEATED step targets (1349, 1349) walkably")

	# 5. Test Desert Seed Seek Nina & Seek Manayir
	var seedQid : int = ProgressCommons.Quest.DESERT_SEED
	var sNina : Dictionary = QuestGuidanceClass.BuildStep(seedQid, ProgressCommons.DESERT_SEED.SEEK_NINA)
	var sHommer : Dictionary = QuestGuidanceClass.BuildStep(seedQid, ProgressCommons.DESERT_SEED.SEEK_MANAYIR)
	if sNina.get("nick") != "Nina" or sHommer.get("nick") != "Hommer":
		print("[FAIL] Desert Seed steps incorrect: ", sNina, sHommer)
		fails += 1
	else:
		print("[PASS] Desert Seed routes properly: Nina -> Hommer")

	print("=== RESULT fails=%d ===" % fails)
	get_tree().quit(0 if fails == 0 else 1)
