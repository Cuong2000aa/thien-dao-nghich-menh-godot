extends NpcScript

const QUEST_ID = ProgressCommons.Quest.MINE_EXPLORATION

func OnStart():
	match GetQuest(QUEST_ID):
		ProgressCommons.MINE_EXPLORATION.DEFEATED:
			Mes("Ngươi mạnh hơn ta nghĩ.")
			Mes("Chúng ta sẽ gặp lại...")
		_:
			OnMeetXakelbael()

func OnQuit():
	super.OnQuit()
	if GetQuest(QUEST_ID) == ProgressCommons.MINE_EXPLORATION.DEFEATED:
		npc.ownScript.TriggerManaTree.call_deferred()
		npc.ownScript.RunAway.call_deferred()

func OnMeetXakelbael():
	Mes("Ta đến đây vì Kano. Không ngờ còn Uru sống ẩn trong bóng tối. Nó sống sao được?")
	Mes("Đó là cây cuối cùng hay còn nữa?")
	Choice("Ngươi nói gì vậy?", OnBadMoment)
	Choice("Kano? Uru?", OnBadMoment)
	Choice("Ngươi là ai?", OnBadMoment)

func OnBadMoment():
	Mes("Không phải lúc dân Tulimshar xâm nhập nơi này.")
	Mes("Ta đã xử một kẻ các ngươi trước đó, nhưng ngươi theo quá xa — ta sẽ không khoan dung như vậy.")
	Choice("Đây là nơi nào?", OnNotSupposedToBeHere)
	Choice("Giải thích chuyện gì đang xảy ra được không?", OnNotSupposedToBeHere)
	Choice("Ta còn chẳng biết ngươi là ai.", OnNotSupposedToBeHere)

func OnNotSupposedToBeHere():
	Mes("Ngươi không nên ở đây. Ta cũng vậy, nhưng không quan trọng.")
	Mes("Ta đã có thứ ta cần.")
	Mes("Ta không có thời gian thỏa mãn tò mò của ngươi, và không thể để ngươi rời khỏi nơi này.")
	Action(npc.ownScript.StartFight)
