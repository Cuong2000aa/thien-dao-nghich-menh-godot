extends MessageBox
class_name QuitBox

const QuitText : String = "Tu đạo gian nan, chớ vội nản lòng. Đạo hữu có chắc chắn muốn thoái xuất hồng trần?"

#
func Toggle():
	if is_visible():
		Clear()
		Launcher.GUI.messageBox.Restore()
		return

	var quit : Callable = Callable() if LauncherCommons.isWeb else FSM.EnterState.bind(FSM.States.QUIT)
	var logOut : Callable = LogOut if FSM.IsGameState() else Callable()
	if quit.is_valid() or logOut.is_valid():
		Launcher.GUI.messageBox.Suspend()
		Display(QuitText,
			Launcher.GUI.messageBox.Restore, "Ở Lại Tu Luyện",
			null, "",
			logOut, "Đăng Xuất Đạo Hào",
			quit, "Rời Khỏi Trò Chơi")
		closeCallback = Toggle

func LogOut():
	FSM.EnterState(FSM.States.LOGIN_SCREEN)
	Network.DisconnectAccount()
