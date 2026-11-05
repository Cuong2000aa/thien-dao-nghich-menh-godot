extends NpcScript

const questID : int = ProgressCommons.Quest.SNAKE_PIT_THIEF
const bitIndex : int = 4
var thiefsKeyID : int = DB.GetCellHash("Thief's Key")

#
func OnStart():
	var state : int = GetQuest(questID)
	if state >= ProgressCommons.SNAKE_PIT_THIEF.RIDDLE_SOLVED:
		return

	Mes("Manh mối 5")

	var newState : int = state | (1 << bitIndex)
	if newState != state:
		SetQuest(questID, newState)

	if newState == ProgressCommons.SNAKE_PIT_THIEF.ALL_CLUES_FOUND:
		OnAllCluesFound()

func OnAllCluesFound():
	SetQuest(questID, ProgressCommons.SNAKE_PIT_THIEF.RIDDLE_SOLVED)
	AddItem(thiefsKeyID, 1)
	Mes("Ngươi tìm thấy chìa khóa giấu dưới manh mối 5.")
