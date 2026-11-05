extends NpcScript

#
func OnStart():
	match randi_range(0, 5):
		0: SeenClay()
		1: GoingToSea()
		2: Circles()
		3: Chat("Ồ, ta thích hòn đá kia!")
		4: Chat("Cẩn thận hải tặc ẩn nấp — nguy hiểm lắm.")
		5: Chat("Đừng xóa phấn nhé!")

func SeenClay():
	Mes("Đạo hữu thấy phấn của ta không?")
	Mes("Ta cá lính canh lấy đi chơi riêng.")

func GoingToSea():
	Mes("Một ngày ta sẽ ra biển khám phá thế giới.")
	Mes("Nghe có thành phía bắc cát trắng lạnh.")

func Circles():
	Mes("Đạo hữu vẽ tròn hoàn hảo được không? Ta được! Cha dạy.")
	Mes("Wie không vẽ tròn. Cô ấy vẽ giống hình vuông béo.")
	Mes("Buồn cười lắm, nhưng cô ấy không thích bị cười nên luôn muốn làm X.")
	Mes("Ta gọi cô ấy \"X hoang dã\".")
