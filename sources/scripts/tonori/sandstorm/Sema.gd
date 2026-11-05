extends NpcScript

#
func OnStart():
	if randi() % 2:
		Mes("Nơi này không ổn.")
		Mes("Có cảm giác u ám. Chắc vì bỏ hoang lâu?")
		Mes("Hay vì đó mà nơi này bị bỏ hoang...")
	else:
		Mes("Ta nghe tiếng động từ phía dưới. Ta thật sự không muốn xuống đó...")
