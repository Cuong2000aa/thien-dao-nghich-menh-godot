extends NpcScript

#
const QUEST_ID : int = ProgressCommons.Quest.MINE_EXPLORATION

#
func OnStart():
	if not own or not own.progress:
		return

	var questState : int = own.progress.GetQuest(ProgressCommons.Quest.MINE_EXPLORATION)
	if questState < ProgressCommons.MINE_EXPLORATION.STRANGER_SPOTTED or questState == ProgressCommons.CompletedProgress:
		return

	Narrate("Ngươi thấy một khe nứt trên vách hang. Ánh sáng xanh nhạt lọt từ bên kia.")
	Narrate("Có vẻ ngươi lách qua được.")
	Narrate("Một giọng bình thản vang trong đầu.")
	Mes("Ta không cảm thấy u ám như kẻ đầu tiên lọt qua đây. Xin hãy tiến lại.")
	Mes("Lần đầu sau hàng ngàn năm, ta cần sự giúp đỡ của ai đó.")
	WarpInstance(npc.ownScript.mapName, Vector2(npc.ownScript.mapPos))
