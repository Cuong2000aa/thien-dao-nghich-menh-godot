extends NpcScript

const DESERT_SEED_ID : int = ProgressCommons.Quest.DESERT_SEED

#
func OnStart():
	Mes("Hoan nghênh đến Manayir.")
	DisplayChoices()

func DisplayChoices():
	if GetQuest(DESERT_SEED_ID) == ProgressCommons.DESERT_SEED.SEEK_MANAYIR:
		Choice("Nina ở Tulimshar cử ta đến.", OnKano)
	Choice("Đây là nơi nào?", OnAboutManayir)
	Choice("Hantu là gì?", OnHantus)
	Choice("Cáo từ.", Farewell)

func OnAboutManayir():
	Mes("Chúng ta là Kahwe — phe druid tụ họp để nghiên cứu, truyền dạy và bảo vệ trật tự Mana trên thế gian.")
	Mes("Xưa kia ta rải khắp vùng, mỗi người chăm một Hantu gần chỗ ở. Thời đó đã qua.")
	Mes("Ta cũng từng hiện diện lâu ở Tulimshar, cố giữ Mana khỏi bị chính trị hóa. Thời đó cũng đã qua.")
	Mes("Giờ ta giữ tri thức còn lại và tiếp tục nghiên cứu.")
	DisplayChoices()

func OnHantus():
	Mes("Hantu — còn gọi là cây Mana — từng là trụ cột Mana trên thế gian.")
	Mes("Chúng nối mọi sinh linh qua dòng Mana. Mỗi cây giữ đất quanh mình sống, ngăn Mana suy thành Kaore.")
	Mes("Khi người ta sợ Mana, họ chém hạ. Lan nhanh. Tôn giáo và chính trị biến thành giáo lý — chẳng bao lâu không còn cây nào.")
	Mes("Ta là hộ vệ của chúng. Ta thất bại.")
	Mes("Phần còn lại của mục đích ta là giữ tri thức về chúng. Ta nghiên cứu dòng và dấu vết Mana để lại. Ta chờ.")
	DisplayChoices()

func OnKano():
	Mes("Ngươi mang thứ gì đó.")
	Mes("Một Kano — Mana Seed.")
	Mes("Ta chỉ đọc sách về chúng, ai cũng vậy. Không ngờ còn thấy lại.")
	Choice("Nina bảo có thể tin ngươi.", OnNinaSentMe)

func OnNinaSentMe():
	Mes("Tốt, nàng biết đó là lựa chọn đúng.")
	Mes("Nhưng trước hết ta phải nói với ngươi một điều.")
	Choice("Là gì?", OnEndPrototype)

func OnEndPrototype():
	Mes("Con đường tạm dừng ở đây.")
	Mes("Những người dựng nên thế giới này vẫn đang làm phần tiếp theo. Ngươi đã đuổi kịp họ.")
	Mes("Chúc mừng đã tới đây và cảm ơn vì đồng hành cùng chúng ta!")
	Mes("Ở lại bao lâu cũng được; ghé thăm và chào trên Discord của chúng ta.")
	Mes("Cho tới lúc đó, Manayir và vùng Tonori thuộc về ngươi để khám phá tiếp.")
	SetQuest(DESERT_SEED_ID, ProgressCommons.DESERT_SEED.REWARDS_WITHDREW)
	AddExp(500)
	AddGP(2000)
	Choice("Ta ở thêm chút.", Farewell)
