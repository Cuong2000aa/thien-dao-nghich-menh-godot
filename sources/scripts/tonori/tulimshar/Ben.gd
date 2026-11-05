extends NpcScript

#
const QUEST_ID : int = ProgressCommons.Quest.TULIMSHAR_OLD_FRIENDSHIP
var sealedLettersID : int = DB.GetCellHash("Sealed Letters")

#
func OnStart():
	var questState : int = GetQuest(QUEST_ID)
	match questState:
		ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.ENVELOPES_FOUND:
			ReceiveLetters()
		ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.LETTERS_DELIVERED, \
		ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.REWARDS_WITHDREW:
			FreeRoaming()
		_:
			TulimsharWestWallLightTrigerGlobal.CallGuard(own)

func ReceiveLetters():
	if HasItem(sealedLettersID):
		Mes("Ngươi là ai?")
		Choice("Frost cử ta. Anh ấy đưa ta mấy thứ này...", GiveLetters)
	else:
		Mes("Trông ngươi muốn nói gì. Nhưng tay trống.")
		Mes("Có gì mang đến. Ta còn việc.")

func GiveLetters():
	Mes("Cái gì. Anh ấy cử ngươi mang những thứ này?")
	Think("Ben lướt thư, xếp trên tay.")
	Mes("Ta biết chữ viết này.")
	Mes("Cũ rồi. Hồi Nữ hoàng đóng quân cho ta xa nhau, trước khi cùng một đoạn tường.")
	Mes("Frost lo người. Ta lo đá. Thỏa thuận vậy.")
	Mes("Một thời ổn.")
	Mes("Rồi Nữ hoàng cứ đẩy. Đòi hỏi, luôn ý nàng. Không chỗ làm việc.")
	Mes("Frost đặt quy tắc. Quy trình mọi thứ. Ta bảo không cần thêm áp lực.")
	Mes("Anh ấy bảo ta loại anh ấy, tự quyết không báo ai.")
	Mes("Có lẽ ta có. Lời không phải vũ khí ta. Chưa bao giờ.")
	Mes("Ta chỉ muốn xây và để người ta thôi cãi cách xây.")
	Mes("Dù sao. Ta bảo anh ấy đi. Anh ấy đi. Hết chuyện.")
	Mes("...")
	Mes("Trừ là chưa hết. Vì ta đang canh tường chẳng ai đập.")
	Mes("Trừ ngươi... nhưng Frost cử thì khác.")
	ExchangeItems([sealedLettersID], [], OnLettersExchanged)

func OnLettersExchanged(result : ActorInventory.ExchangeResult):
	match result:
		ActorInventory.ExchangeResult.OK:
			SetQuest(QUEST_ID, ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.LETTERS_DELIVERED)
			Mes("Mang phong bì này về anh ấy. Anh ấy biết bên trong gì.")
			Mes("Và bảo tường vẫn đứng. Anh ấy sẽ... Ừ. Bảo vậy.")
		ActorInventory.ExchangeResult.MISSING_ITEMS:
			Mes("Thư đâu? Mang lại khi có.")

func FreeRoaming():
	Mes("Lại ngươi. Hành lang mở cho ngươi rồi — ta có ý vậy.")
	Mes("Có lối sau thư viện cạnh ta. Ra ngoài tường. Ít người biết.")
