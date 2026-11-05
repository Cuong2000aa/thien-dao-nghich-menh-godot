extends NpcScript

#
func OnStart():
	var globalScript : TicTacToeGlobal = (npc.ownScript as TicTacToeGlobal)
	match globalScript.startStep:
		TicTacToeGlobal.State.NONE:
			if steps.is_empty():
				match randi_range(0, 2):
					0: Mes("Chơi cờ ca-rô không? Ta tự vẽ bàn!")
					1:
						Mes("Ta không vẽ tròn được nên vẽ vuông. Andi cứ trêu ta.")
						Mes("Chơi cờ ca-rô không?")
					2:
						Mes("Ta thấy hải tặc chơi cờ ca-rô với lính hôm qua.")
						Mes("Chơi không?")
			else:
				Mes("Chơi cờ ca-rô không?")
			Choice("Đánh với ngươi", StartPvE)
			Choice("Đánh với người khác", StartPvP)
			Choice("Chơi thế nào?", ShowRules)
			Choice("Để sau", Decline)
		TicTacToeGlobal.State.X:
			if globalScript.playerX != own:
				Mes("Này, đã có người chờ rồi! Đánh với họ đi!")
				Choice("Ta đánh với họ!", StartPvP)
				Choice("Chơi thế nào?", ShowRules)
				Choice("Để sau", Decline)
			else:
				Mes("Chưa ai tới... Chờ thêm không?")
				Choice("Ta chờ thêm", WaitPvP)
				Choice("Chơi thế nào?", ShowRules)
				Choice("Ta phải đi", CancelPvP)
		TicTacToeGlobal.State.O:
			var isPlaying : bool = globalScript.playerX == own or globalScript.playerO == own
			if isPlaying:
				Mes("Này, đừng gian lận! Về bàn chơi đi!")
			else:
				Mes("Suỵt, họ đang chơi! Xem thôi.")
			Choice("Ừ ừ", OnQuit)
			Choice("Chơi thế nào?", ShowRules)
			if isPlaying:
				Choice("Ta phải đi", CancelPvP)

func ShowRules():
	Mes("Chọn ô rồi đánh dấu, rồi đến lượt người kia.")
	Mes("Ba ô liên tiếp là thắng! Ngang, dọc, hoặc chéo.")
	Mes("Hết ô mà không ai thắng là hòa. Hòa chán lắm.")
	OnStart()

func Decline():
	Chat("Ừ mà... Đổi ý cứ quay lại!")

# Player vs NPC
func StartPvE():
	var globalScript : TicTacToeGlobal = (npc.ownScript as TicTacToeGlobal)
	if globalScript.startStep == TicTacToeGlobal.State.NONE and globalScript.StartPvE(own):
		DisplayActions(["gp_target", "gp_untarget"])
		Mes("Đạo hữu là X! Chọn ô, nhanh nhanh!")
	else:
		Mes("Khoan, có người chơi rồi! Xếp hàng.")

# Player vs Player
func StartPvP():
	var globalScript : TicTacToeGlobal = (npc.ownScript as TicTacToeGlobal)
	match globalScript.StartPvP(own):
		TicTacToeGlobal.State.X:
			Mes("Giờ chờ ai đó tới...")
			return
		TicTacToeGlobal.State.O:
			DisplayActions(["gp_target", "gp_untarget"])
			Mes("Hay, đủ hai người! Chơi vui nhé!")
			return
		TicTacToeGlobal.State.NONE:
			Mes("Không, bàn có người rồi!")

func WaitPvP():
	if (npc.ownScript as TicTacToeGlobal).playerX == own:
		Chat("Chắc sẽ có người... Chắc vậy!")

func CancelPvP():
	var globalScript : TicTacToeGlobal = (npc.ownScript as TicTacToeGlobal)
	if globalScript.playerX == own:
		globalScript.LeaveQueue(own)
		Chat("Huh, đi rồi à? Ừ...")
