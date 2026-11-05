extends NpcScript

#
func OnStart():
	Mes("Hôm nay đạo hữu muốn đổi kiểu tóc hay màu tóc?")
	Choice("Ta muốn thử kiểu khác", OnHairstyle)
	Choice("Màu mới", OnHaircolor)
	Choice("Thôi", OnQuit)

func OnHairstyle():
	var hairstyles : Array[HairstyleData] = DB.HairstylesDB.values()
	var count : int = hairstyles.size() -1
	var randIdx : int = randi_range(0, count)

	var newStyleIdx : int = hairstyles[randIdx]._id
	if newStyleIdx == own.stat.haircolor:
		randIdx = (randIdx + 1) % (count + 1)
		newStyleIdx = hairstyles[randIdx]._id
	own.stat.SetHairstyle(newStyleIdx)

	Choice("Kiểu khác nữa", OnHairstyle)
	Choice("Vừa ý!", OnQuit)

func OnHaircolor():
	var haircolors : Array = DB.PalettesDB[DB.Palette.HAIR].values()
	var count : int = haircolors.size() - 1
	var randIdx : int = randi_range(0, count)

	var newColorIdx : int = haircolors[randIdx]._id
	if newColorIdx == own.stat.haircolor:
		randIdx = (randIdx + 1) % (count + 1)
		newColorIdx = haircolors[randIdx]._id
	own.stat.SetHaircolor(newColorIdx)

	Choice("Màu khác nữa", OnHaircolor)
	Choice("Vừa ý!", OnQuit)
