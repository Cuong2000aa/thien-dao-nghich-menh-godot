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
