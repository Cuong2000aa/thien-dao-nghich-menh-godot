extends NpcScript

const QUEST_ID = ProgressCommons.Quest.SANDSTORM_NAEM_HELMET

#
func OnStart():
	Mes("Ông nội ta từng làm trong mỏ này. Hồi nhỏ ông kể ta nghe.")
	Mes("Mỏ sâu lắm. Không biết họ muốn ta đi tới đâu; cũng không biết dưới đó còn sinh vật gì.")
	Mes("Ngươi nghĩ sao?")
	Choice("Ta chưa biết, nhưng sẽ tìm hiểu.", OnWillFindOut)

func OnWillFindOut():
	if GetQuest(QUEST_ID) == ProgressCommons.SANDSTORM_NAEM_HELMET.GIVEN:
		OnFarewell()
		return

	Mes("Ta không đi sâu thêm nếu tránh được. Đây, ta có mũ dự phòng.")
	SetQuest(QUEST_ID, ProgressCommons.SANDSTORM_NAEM_HELMET.GIVEN)
	AddItem(DB.GetCellHash("Miner Helmet"))
	Mes("Có thợ thủ công ở Tulimshar làm từ sợi cọ và nhựa xương rồng. Bền lắm. Giải khát nhất luôn.")
	Choice("Giải khát?", OnNevermind)

func OnNevermind():
	Mes("Thôi kệ. Chúc may mắn dưới đó!")

func OnFarewell():
	Chat("Chúc may mắn dưới đó!")
