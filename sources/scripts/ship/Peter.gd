extends NpcScript

const QUEST_ID : int = ProgressCommons.Quest.SHIP_PETER_BOUNTY
const MIN_LEVEL : int = 5

const HOLD_SPAWN_POS : Vector2 = Vector2(48 * 32, 28 * 32)
const HOLD_SPAWN_MAP : StringName = "Ship Hold"

#
func OnStart():
	if own.stat.level < MIN_LEVEL:
		Mes("Đạo hữu còn quá trẻ để lang thang nơi này — hãy học cho xong rồi hãy nói chuyện.")
	elif npc.ownScript and npc.ownScript.IsInProgress(own):
		Mes("Sao đạo hữu lên tận đây? Việc nằm dưới khoang. Mau xuống!")
	else:
		Mes("Hừ? Nói nhanh, ta đang bận.")
		match GetQuest(QUEST_ID):
			ProgressCommons.SHIP_PETER_BOUNTY.INACTIVE:
				OnFirstMeeting()
			ProgressCommons.SHIP_PETER_BOUNTY.ALL_DONE:
				OnDailyOffer()
			_:
				OnReturnVisit()

func OnFirstMeeting():
	Mes("Có thứ gì đó đang gặm kho lương trong khoang. Ta đoán lại là đám Ratto... Cần người dọn chúng đi.")
	Choice("Ta cần luyện tập, nhận việc.", OnAccept)
	Choice("Không phải việc của ta.", OnDecline)

func OnAccept():
	Mes("Việc đây.")
	OnExplainBounties()

func OnDecline():
	Chat("Tùy đạo hữu.")

func OnReturnVisit():
	Mes("Lại đến? Tốt. Khoang chẳng tự dọn được đâu.")
	OnExplainBounties()

func OnExplainBounties():
	match GetQuest(QUEST_ID):
		ProgressCommons.SHIP_PETER_BOUNTY.INACTIVE:
			Mes("Đám Ratto tìm được thứ để cắn rồi. Dọn sạch chúng, ta trả công xứng đáng.")
			Choice("Coi như xong.", AcceptBounty.bind(ProgressCommons.SHIP_PETER_BOUNTY.WAVE_ONE_DONE, "Ratto", 5))
		ProgressCommons.SHIP_PETER_BOUNTY.WAVE_ONE_DONE:
			Mes("Ta phát hiện thêm một ổ mới — dưới khoang còn nhiều hơn, và táo bạo hơn. Lần này thù lao cao hơn.")
			Choice("Ta sẽ làm trọn việc đã bắt đầu.", AcceptBounty.bind(ProgressCommons.SHIP_PETER_BOUNTY.WAVE_TWO_DONE, "Ratto", 10))
		ProgressCommons.SHIP_PETER_BOUNTY.WAVE_TWO_DONE:
			Mes("Quên Ratto đi. Giờ là dơi dưới khoang. Dơi, đạo hữu tin được không?")
			Choice("Dơi thì dơi.", AcceptBounty.bind(ProgressCommons.SHIP_PETER_BOUNTY.ALL_DONE, "Bat", 10))

	Choice("Để lúc khác.", OnDecline)

func AcceptBounty(nextState : int, monsterName : String, monsterCount : int):
	Mes("Xuống xong đóng cửa thật nhanh — không khí ở đó khá kinh.")
	WarpInstance(HOLD_SPAWN_MAP.hash(), HOLD_SPAWN_POS)
	Action(npc.ownScript.StartRun.bind(own, nextState, monsterName.hash(), monsterCount))

func OnDailyOffer():
	if npc.ownScript.CanRunDailyQuest(own.get_rid().get_id()):
		Mes("Lại là đạo hữu? Tốt. Ratto chẳng biết chịu thua, chúng quay lại rồi.")
		Mes("Như mọi khi. Xuống khoang, dọn sạch, lên nhận tiền.")
		Choice("Ta đi ngay.", AcceptBounty.bind(ProgressCommons.SHIP_PETER_BOUNTY.ALL_DONE, "Ratto", 10))
		Choice("Hôm nay thôi.", OnDecline)
	else:
		Mes("Lại là đạo hữu? Hôm nay khoang yên ắng, không cần giúp — đạo hữu cứ đi tiếp.")
