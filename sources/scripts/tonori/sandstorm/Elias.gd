extends NpcScript

#
func OnStart():
	Mes("Theo đèo phía tây kia là rời Thung Lũng Tulimshar, bước vào Cao Nguyên Zuni.")
	Mes("Ngươi biết mình đi đâu chứ?")
	Choice("Ta tìm Mỏ Bão Cát.", OnMines)
	Choice("Ta tìm Tulimshar.", OnTulimshar)

func OnMines():
	LookAtNpc("To Mines")
	Mes("Theo con đường này là xa Mỏ Bão Cát hơn.")
	ResetCamera()
	Mes("Ngươi nên quay về phía tây, hướng phía nam thung lũng.")

func OnTulimshar():
	LookAtNpc("To Tulimshar")
	Mes("Theo lối kia về phía bắc tới tường thành.")
	ResetCamera()
	Mes("Không thể nhầm, từ đó gần như thấy tường thành!")
