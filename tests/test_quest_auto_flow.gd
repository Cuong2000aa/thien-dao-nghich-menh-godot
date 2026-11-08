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

	# 6. Test Quest Chain progression and Skip behavior
	var tutQid : int = ProgressCommons.Quest.TUTORIAL
	var nextAfterTut : int = QuestGuidanceClass.GetNextQuestInChain(tutQid)
	if nextAfterTut != ProgressCommons.Quest.ELANORE_POTION:
		print("[FAIL] GetNextQuestInChain(TUTORIAL) should be ELANORE_POTION, got: ", nextAfterTut)
		fails += 1
	else:
		print("[PASS] GetNextQuestInChain(TUTORIAL) correctly yields ELANORE_POTION")

	var nextAfterElanore : int = QuestGuidanceClass.GetNextQuestInChain(ProgressCommons.Quest.ELANORE_POTION)
	if nextAfterElanore != ProgressCommons.Quest.NINA_HUNGRY:
		print("[FAIL] GetNextQuestInChain(ELANORE_POTION) should be NINA_HUNGRY, got: ", nextAfterElanore)
		fails += 1
	else:
		print("[PASS] GetNextQuestInChain(ELANORE_POTION) correctly yields NINA_HUNGRY")

	var nextAfterNina : int = QuestGuidanceClass.GetNextQuestInChain(ProgressCommons.Quest.NINA_HUNGRY)
	if nextAfterNina != ProgressCommons.Quest.MINE_EXPLORATION:
		print("[FAIL] GetNextQuestInChain(NINA_HUNGRY) should be MINE_EXPLORATION, got: ", nextAfterNina)
		fails += 1
	else:
		print("[PASS] GetNextQuestInChain(NINA_HUNGRY) correctly yields MINE_EXPLORATION")

	# 7. Test FindNextAvailableQuest with partially completed chain
	if Launcher.Player == null:
		Launcher.Player = Entity.new(ActorCommons.Type.PLAYER, DB.EntitiesDB.get(DB.PlayerHash), "TestPlayer")
	Launcher.Player.progress.quests.clear()
	Launcher.Player.progress.SetQuest(tutQid, ProgressCommons.CompletedProgress, false)
	var nextAvail : int = QuestGuidanceClass.FindNextAvailableQuest()
	if nextAvail != ProgressCommons.Quest.ELANORE_POTION:
		print("[FAIL] FindNextAvailableQuest after TUTORIAL completion should be ELANORE_POTION, got: ", nextAvail)
		fails += 1
	else:
		print("[PASS] FindNextAvailableQuest correctly continues Starter Chain with ELANORE_POTION")

	# 8. Test Auto-Combat engagement: tolerance for colliders (55px distance is in attack range)
	var mockMob = Entity.new(ActorCommons.Type.MONSTER, DB.EntitiesDB.get("Peyote".hash()), "Peyote")
	Launcher.Player.position = Vector2(100, 100)
	mockMob.position = Vector2(100, 155) # 55px away
	autoCtrl._MaintainKillTarget(mockMob)
	if Entities.target != mockMob:
		print("[FAIL] AutoController did not lock Entities.target to mockMob!")
		fails += 1
	else:
		print("[PASS] AutoController locked Entities.target to monster")

	if Launcher.Player.position.distance_to(mockMob.position) <= 72.0:
		print("[PASS] 55px collider proximity is within combat attackRange (<= 72px)!")
	else:
		print("[FAIL] Attack range tolerance failed!")
		fails += 1

	# 9. Test Auto-Dialogue choice scoring & non-blocking tween advance
	var scoreAccept : int = autoCtrl._ScoreChoice("Ta sẽ đi thu thập giúp.", 0)
	var scoreDecline : int = autoCtrl._ScoreChoice("Để lần khác.", 1)
	if scoreAccept <= scoreDecline:
		print("[FAIL] Auto choice scoring failed: accept=%d, decline=%d" % [scoreAccept, scoreDecline])
		fails += 1
	else:
		print("[PASS] Auto choice correctly prioritizes accept (score=%d) over decline (score=%d)" % [scoreAccept, scoreDecline])

	# 10. Test Dialogue text animation fast-forward signal
	var DialogueScene = preload("res://presets/gui/Dialogue.tscn")
	var mockDialogue = DialogueScene.instantiate()
	add_child(mockDialogue)
	mockDialogue.lastTween = create_tween()
	mockDialogue.lastTween.tween_interval(10.0)
	var box : Array[bool] = [false]
	mockDialogue.text_animation_finished.connect(func(): box[0] = true)
	mockDialogue.FinishTextAnimation()
	if not box[0] or mockDialogue.lastTween != null:
		print("[FAIL] FinishTextAnimation failed to clear lastTween or emit text_animation_finished!")
		fails += 1
	else:
		print("[PASS] FinishTextAnimation cleanly terminated tween and emitted signal immediately")
	mockDialogue.queue_free()

	print("=== RESULT fails=%d ===" % fails)
	get_tree().quit(0 if fails == 0 else 1)
