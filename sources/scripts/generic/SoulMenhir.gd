extends NpcScript

const DESERT_SEED_ID : int = ProgressCommons.Quest.DESERT_SEED

#
func OnStart():
	Narrate("Một khối đá khắc uy nghi, quấn quanh là dòng Linh Khí chảy. Sự hiện diện ấy mang cảm giác an bình.")
	Narrate("Gân silery mảnh chạy trên đá xám đen, đổi sắc khi ánh xanh Linh Khí thô chảy qua.")
	if GetQuest(DESERT_SEED_ID) >= ProgressCommons.DESERT_SEED.SEEK_MANAYIR:
		Narrate("Đạo hữu có muốn đặt tay lên Soul Menhir?")
		Choice("Chạm vào Soul Menhir.", Touch)
		Choice("Để yên.")

func Touch():
	var globalScript : SoulMenhirGlobal = npc.ownScript
	if globalScript:
		globalScript.SaveRespawn(own)
