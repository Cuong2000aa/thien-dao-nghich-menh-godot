extends Node2D

## Narrative rewrite gates: guidance 57/57, no "Chưa biết" rewards,
## MQ1 premise (no đoạt xá), Localization NPC nicks, skip/abandon state rules.

const QuestGuidanceClass = preload("res://sources/quest/QuestGuidance.gd")
const StorySystemClass = preload("res://sources/story/StorySystem.gd")

var fails : int = 0

func _fail(msg : String) -> void:
	fails += 1
	print("FAIL: ", msg)

func _ok(msg : String) -> void:
	print("OK: ", msg)

func _ready():
	if not DB.isInitialized:
		await Launcher.dbInitialized

	print("=== test_quest_story_rewrite ===")
	_TestGuidanceCoverage()
	_TestRewardsFilled()
	_TestMq1Premise()
	_TestNpcLocalization()
	_TestSkipAbandonConstants()
	_TestQuestGiverNicksResolve()
	_TestTutorialPhasesNoDialogueLoop()
	_TestMineExplorationNotStuckOnEkinu()
	_TestDesertSeedPhases()
	_TestKillQuestTurnInNotPremature()
	_TestAutoChoicePrefersExitOverReminder()

	print("=== RESULT fails=%d ===" % fails)
	get_tree().quit(0 if fails == 0 else 1)

func _TestGuidanceCoverage() -> void:
	QuestGuidanceClass.InvalidateIndex()
	QuestGuidanceClass.RebuildIndex()
	var report : Dictionary = QuestGuidanceClass.AuditAllQuests()
	var ok : Array = report.get("ok", [])
	var bad : Array = report.get("bad", [])
	var total : int = int(report.get("total", 0))
	if bad.is_empty() and ok.size() == total and total >= 50:
		_ok("Guidance %d/%d" % [ok.size(), total])
	else:
		_fail("Guidance unresolved=%s total=%d ok=%d" % [str(bad), total, ok.size()])

func _TestRewardsFilled() -> void:
	var empty : Array = []
	for id in DB.QuestsDB:
		var q : QuestData = DB.QuestsDB[id]
		var r : String = q.reward.strip_edges() if q.reward else ""
		if r.is_empty() or r == "Chưa biết" or r.to_lower() == "unknown":
			empty.append(q.name)
	if empty.is_empty():
		_ok("All quest rewards filled")
	else:
		_fail("Empty/unknown rewards: " + ", ".join(empty))

func _TestMq1Premise() -> void:
	var mq1 : QuestData = null
	for id in DB.QuestsDB:
		if DB.QuestsDB[id].name == "Tỉnh Lạc Dị Giới":
			mq1 = DB.QuestsDB[id]
			break
	if mq1 == null:
		_fail("MQ1 quest missing")
		return
	var blob : String = mq1.description + " " + mq1.reward
	if blob.contains("đoạt xá") and not blob.contains("không đoạt") and not blob.contains("không phải đoạt"):
		_fail("MQ1 still affirms đoạt xá")
	else:
		_ok("MQ1 no body-snatch premise")
	if not mq1.description.contains("xuyên") and not mq1.description.contains("Xuyên"):
		_fail("MQ1 should mention xuyên không")
	else:
		_ok("MQ1 xuyên không premise")
	var ch1 = StorySystemClass.MAIN_STORY_CHAPTERS[StorySystemClass.StoryChapter.CHAPTER_1_STRANGER]
	var syn : String = str(ch1.get("synopsis", ""))
	if syn.contains("thân xác một đệ tử") or syn.contains("xuyên không vào thân xác"):
		_fail("StorySystem CH1 synopsis still body-snatch")
	elif not syn.contains("thân xác thật") and not syn.contains("không đoạt"):
		_fail("StorySystem CH1 should affirm thân xác thật")
	else:
		_ok("StorySystem CH1 synopsis rewritten")

func _TestNpcLocalization() -> void:
	var pairs : Dictionary = {
		"Elanore": "Ái Lan",
		"Nina": "Ni Na",
		"Kael": "Kha Nhĩ",
		"Ekinu": "Nghê Khôn",
		"Nathan": "Na Thiên",
		"Naem": "Nẫm Công",
		"Peter": "Bạch Đạt",
		"Tutorial": "Tỉnh Dậy Thanh Sa",
		"Elanore's Potions": "Đan Dược Ái Lan",
		"Nina's Snack": "Bánh Cho Ni Na",
		"Peter's Bounty": "Ủy Thác Bạch Đạt",
	}
	var locFails : int = 0
	for k in pairs:
		var got : String = Localization.Get(k, k)
		if got != pairs[k]:
			locFails += 1
			_fail("Localization '%s' => '%s' (want '%s')" % [k, got, pairs[k]])
	if locFails == 0:
		_ok("NPC/quest Localization display names")

func _TestSkipAbandonConstants() -> void:
	# Skip marks Completed; Abandon marks Unknown — Progress.gd contract
	if ProgressCommons.CompletedProgress <= ProgressCommons.UnknownProgress:
		_fail("CompletedProgress must be > UnknownProgress")
	else:
		_ok("Skip/Abandon progress constants ordered")
	# Active quest window for buttons
	if not (1 > ProgressCommons.UnknownProgress and 1 < ProgressCommons.CompletedProgress):
		_fail("Active quest state band broken")
	else:
		_ok("Active quest state band for skip/abandon buttons")

func _TestQuestGiverNicksResolve() -> void:
	## Giver technical nicks for SoM-slot must still resolve via guidance overrides / spawn
	var critical : Array = [
		ProgressCommons.Quest.TUTORIAL,
		ProgressCommons.Quest.ELANORE_POTION,
		ProgressCommons.Quest.NINA_HUNGRY,
		ProgressCommons.Quest.MQ_CHUONG_1_TINH_LAC_DI_GIOI,
		ProgressCommons.Quest.SHIP_PETER_BOUNTY,
	]
	for qid in critical:
		var step : Dictionary = QuestGuidanceClass.BuildStep(qid, 1)
		if not step.get("resolved", false):
			_fail("Critical quest unresolved at STARTED: " + str(qid))
		else:
			_ok("Resolve %s → %s" % [step.get("quest_name", qid), step.get("nick", "")])

func _TestTutorialPhasesNoDialogueLoop() -> void:
	## After accepting Kael's kill quest, guidance must NOT send Auto back to Kael as talk/return.
	var qid : int = ProgressCommons.Quest.TUTORIAL
	var phases : Array = [
		[ProgressCommons.TUTORIAL.INTRO_ITEMS_GIVEN, "Elanore", QuestGuidanceClass.Action.TALK, false],
		[ProgressCommons.TUTORIAL.ELANORE_DONE, "Kael", QuestGuidanceClass.Action.TALK, false],
		[ProgressCommons.TUTORIAL.KAEL_MET, "Peyote", QuestGuidanceClass.Action.KILL, false],
		[ProgressCommons.TUTORIAL.KAEL_DONE, "Ekinu", QuestGuidanceClass.Action.TALK, false],
	]
	for p in phases:
		var step : Dictionary = QuestGuidanceClass.BuildStep(qid, int(p[0]))
		var nick : String = str(step.get("nick", ""))
		var action : int = int(step.get("action", -1))
		var turnIn : bool = bool(step.get("turn_in", true))
		if nick != str(p[1]) or action != int(p[2]) or turnIn != bool(p[3]):
			_fail("Tutorial state %s → nick=%s action=%s turn_in=%s (want %s/%s/%s)" % [
				p[0], nick, action, turnIn, p[1], p[2], p[3]
			])
		elif not step.get("resolved", false):
			_fail("Tutorial state %s unresolved" % p[0])
		else:
			_ok("Tutorial %s → %s (action %s)" % [p[0], nick, action])
	# Kill phase must keep return_nick for progress check, without turn_in
	var killStep : Dictionary = QuestGuidanceClass.BuildStep(qid, ProgressCommons.TUTORIAL.KAEL_MET)
	if str(killStep.get("return_nick", "")) != "Kael":
		_fail("KAEL_MET should keep return_nick=Kael for progress check")
	else:
		_ok("KAEL_MET return_nick=Kael (progress check only)")
	var kTargets : Array = killStep.get("kill_targets", [])
	if kTargets.size() < 2 or not kTargets.has("Peyote") or not kTargets.has("Maggot"):
		_fail("KAEL_MET kill_targets must be Peyote+Maggot, got %s" % str(kTargets))
	elif not bool(killStep.get("need_each", false)):
		_fail("KAEL_MET must set need_each")
	else:
		_ok("KAEL_MET kill_targets Peyote+Maggot need_each")

func _TestAutoChoicePrefersExitOverReminder() -> void:
	## Gate menus: never prefer "nhắc lại" over "đi thôi" / "Ổn hết!".
	var auto := QuestAutoController.new()
	var reminder : int = auto._ScoreChoice("Ta phải làm gì nhắc lại?", 0)
	var leave : int = auto._ScoreChoice("Được, ta đi thôi.", 3)
	var tip : int = auto._ScoreChoice("Ta mạnh hơn thế nào?", 0)
	var okExit : int = auto._ScoreChoice("Ổn hết!", 3)
	auto.free()
	if leave <= reminder:
		_fail("Exit 'đi thôi' must beat reminder loop (%d vs %d)" % [leave, reminder])
	elif okExit <= tip:
		_fail("Gilgames 'Ổn hết!' must beat lore tip (%d vs %d)" % [okExit, tip])
	else:
		_ok("Auto choice prefers exit over reminder/lore loops")

func _TestMineExplorationNotStuckOnEkinu() -> void:
	## After accepting expedition, Auto must leave Ekinu (menu loops) → Dausen, then Ryan.
	var qid : int = ProgressCommons.Quest.MINE_EXPLORATION
	var step : Dictionary = QuestGuidanceClass.BuildStep(qid, ProgressCommons.MINE_EXPLORATION.STARTED)
	if str(step.get("nick", "")) != "Dausen":
		_fail("MINE STARTED should target Dausen, got %s" % step.get("nick", ""))
	elif str(step.get("next_nick", "")) != "Ryan":
		_fail("MINE STARTED next_do should be Ryan, got %s" % step.get("next_nick", ""))
	elif int(step.get("action", -1)) != QuestGuidanceClass.Action.TALK:
		_fail("MINE STARTED should be talk")
	else:
		_ok("MINE STARTED → Dausen → next Ryan (not Ekinu loop)")

	var fin : Dictionary = QuestGuidanceClass.BuildCompletionStep(qid)
	if str(fin.get("nick", "")) != "Ryan":
		_fail("MINE completion step should be Ryan")
	else:
		_ok("MINE Skip completion → Ryan")

func _TestDesertSeedPhases() -> void:
	var qid : int = ProgressCommons.Quest.DESERT_SEED
	var s1 : Dictionary = QuestGuidanceClass.BuildStep(qid, ProgressCommons.DESERT_SEED.SEEK_NINA)
	if str(s1.get("nick", "")) != "Nina" or int(s1.get("action", -1)) != QuestGuidanceClass.Action.TALK:
		_fail("DESERT_SEED SEEK_NINA should be Nina TALK, got: %s" % str(s1))
	else:
		_ok("DESERT_SEED SEEK_NINA → Nina")

	var s2 : Dictionary = QuestGuidanceClass.BuildStep(qid, ProgressCommons.DESERT_SEED.SEEK_MANAYIR)
	if str(s2.get("nick", "")) != "Hommer" or not bool(s2.get("turn_in", false)):
		_fail("DESERT_SEED SEEK_MANAYIR should be Hommer turn_in, got: %s" % str(s2))
	else:
		_ok("DESERT_SEED SEEK_MANAYIR → Hommer (turn_in)")

func _TestKillQuestTurnInNotPremature() -> void:
	## state>need heuristic must not force turn-in mid objective for all active quests.
	QuestGuidanceClass._EnsureObjectiveTable()
	var premature : Array = []
	for qid in DB.QuestsDB:
		var override : Dictionary = QuestGuidanceClass._objectiveTable.get(qid, {})
		if override.is_empty():
			continue
		var kind : String = str(override.get("kind", ""))
		if kind != "kill" and kind != "gather":
			continue
		# Mid-progress state = STARTED (1) must not be turn-in
		if QuestGuidanceClass.IsReadyToTurnIn(qid, 1):
			premature.append(DB.QuestsDB[qid].name)
	if premature.is_empty():
		_ok("No kill/gather quest marks STARTED as turn-in")
	else:
		_fail("Premature turn-in at STARTED: " + ", ".join(premature))
