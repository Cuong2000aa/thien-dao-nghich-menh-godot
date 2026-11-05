extends NpcScript

func OnStart():
	match GetQuest(WaterPondGlobal.QUEST_ID):
		ProgressCommons.SNAKE_PIT_BITING_THIRST.STARTED:
			Mes("Nước bẩn quá! Ngươi nghĩ đây không phải ao Mauro nói tới.")
