extends NpcScript

#
func OnStart():
	Mes("Theo con đường phía đông là rời Thung Lũng Tulimshar, hướng tới Bờ Biển Manayir.")
	Mes("Ngươi lạc đường à?")
	DisplayChoices()

func DisplayChoices(hideChoice : int = -1):
	if hideChoice != 1:
		Choice("Ta tìm Mỏ Bão Cát.", OnMines)
	if hideChoice != 2:
		Choice("Kể cho ta về thung lũng này.", OnValley)
	if hideChoice != 3:
		Choice("Kể cho ta về Bờ Biển Manayir.", OnManayir)
	if hideChoice != 4:
		Choice("Cảm ơn đã dành thời gian.", Farewell)

func OnMines():
	LookAtNpc("To Mines")
	Mes("Mỏ nằm ngay phía nam đây.")
	ResetCamera()
	Mes("Bỏ hoang lâu rồi, nhưng ta vừa thấy một nhóm đi hướng đó.")
	Mes("Trông như dân Tulimshar. Không biết họ làm gì...")
	DisplayChoices()

func OnValley():
	Mes("Thung Lũng Tulimshar là vùng trũng được che chắn, nơi thành Tulimshar trú ẩn khỏi Sa Mạc Tonori bên ngoài.")
	Mes("Tường thành khép thành giữa thung lũng và biển mở.")
	Mes("Ngoài bão cát thổi qua thung lũng, vùng này tương đối an toàn so với xa hơn trong Tonori, nơi đủ loại nguy hiểm ẩn trong cát nóng.")
	DisplayChoices()

func OnManayir():
	Mes("Vùng Tonori yên tĩnh gần biển. Chắc là khí hậu dễ chịu nhất trong sa mạc này.")
	Mes("Nổi bật nhất là bán đảo kéo dài từ bãi biển.")
	Mes("Theo ngôn ngữ ta, gọi là Nawah — nơi Manayir Order sinh sống.")

	Choice("Manayir Order là gì?", OnManayirOrder)
	DisplayChoices(3)

func OnManayirOrder():
	Mes("Họ là tổ chức quyền lực của các pháp sư uyên bác, chuyên gia Mana. Tồn tại từ rất lâu, gần bằng dân ta.")
	Mes("Truyền thuyết xưa kể họ từng cai trị Tulimshar. Nay họ chủ yếu ẩn mình.")
	Mes("Ta đôi khi giao thương với họ; ta luôn chia sẻ tri thức và sự ngưỡng mộ Linh Hồn — Mana — với họ.")
	DisplayChoices()
