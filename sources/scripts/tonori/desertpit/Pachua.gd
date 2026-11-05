extends NpcScript

#
const COST_GP : int = 10000
const SNAKE_SKIN_AMOUNT : int = 10

#
func OnStart():
	Mes("Bao đời bộ tộc ta chế trang phục đặc biệt từ đủ loại vật liệu.")
	Mes("Mang đúng thứ ta có thể may cho ngươi.")
	Choice("Ngươi làm được gì?", OnShowRecipe)
	Choice("Bộ tộc ngươi ở đâu?", OnAskTribe)
	Choice("Vùng đất này sao rồi?", OnAskLand)
	Choice("Để sau.", OnFarewell)

func OnShowRecipe():
	Mes("Ta không mang đủ dụng cụ, để ta nghĩ... Quần jean chaps ngươi có thích không?")
	Mes("Cần một Jeans Shorts thường và khoảng 10 Snake Skin — da rắn dễ rách khi ta xử lý.")
	Mes("Thỏa thuận chứ?")
	Choice("Được.", OnAttemptCraft)
	Choice("Nghĩ lại, để sau.", OnNoDeal)

func OnAttemptCraft():
	var shortsID : int = DB.GetCellHash("Shorts")
	var snakeSkinID : int = DB.GetCellHash("Snake Skin")
	var chapsID : int = DB.GetCellHash("Jean Chaps")

	if not HasItem(shortsID):
		Mes("Ôi, hình như ngươi không có jeans shorts.")
		return
	if not HasItem(snakeSkinID, SNAKE_SKIN_AMOUNT):
		Mes("Ôi, hình như ngươi không đủ snake skins.")
		return

	RemoveItem(shortsID)
	RemoveItem(snakeSkinID, SNAKE_SKIN_AMOUNT)
	AddItem(chapsID)
	Mes("Xong!")
	Mes("Ghé lại bất cứ lúc nào.")

func OnAskTribe():
	Mes("Ta sống trên vách đá sa mạc, phía tây đây. Đường không mở cho người ngoài.")
	Mes("Ta ra đây giao thương. Người lạ thường chỉ tới đây thôi.")

func OnAskLand():
	Mes("Vương quốc rút khỏi vùng này từ lâu. Bảo không đáng giữ.")
	Mes("Dân ta ở đây trước họ và vẫn còn. Cần thì giao thương với Tulimshar, còn không thì giữ khoảng cách.")

func OnNoDeal():
	Mes("Ừ, nhưng không chỗ nào rẻ hơn đâu!")

func OnFarewell():
	Chat("Sẵn sàng thì quay lại.")
