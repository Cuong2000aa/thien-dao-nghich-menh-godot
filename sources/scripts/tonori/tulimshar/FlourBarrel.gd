extends NpcScript

var artisFlourSackID : int			= DB.GetCellHash("Artis Flour Sack")

#
func OnStart():
	match GetQuest(ProgressCommons.Quest.GRAIN_IN_THE_SAND):
		ProgressCommons.GRAIN_IN_THE_SAND.STARTED:
			OnSearch()

func OnSearch():
	Mes("Dấu sáp xanh đậm in huy hiệu Artis. Đúng thùng rồi.")
	Mes("Trong là túi bột mịn — đúng như Riskim mô tả.")

	if not HasSpace(1):
		Mes("Nhưng túi đầy, không mang được.")
		return

	SetQuest(ProgressCommons.Quest.GRAIN_IN_THE_SAND, ProgressCommons.GRAIN_IN_THE_SAND.SEARCHED_CRATES)
	AddItem(artisFlourSackID)
