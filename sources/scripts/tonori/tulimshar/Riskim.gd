extends NpcScript

# Quest items
var artisFlourSackID : int			= DB.GetCellHash("Artis Flour Sack")

# Reward items
var croissantID : int				= DB.GetCellHash("Croissant")
var cactusSourCandyID : int			= DB.GetCellHash("Cactus Sour Candy")

#
func OnStart():
	var questState : int = GetQuest(ProgressCommons.Quest.GRAIN_IN_THE_SAND)
	match questState:
		ProgressCommons.GRAIN_IN_THE_SAND.INACTIVE:
			OnInactive()
		ProgressCommons.GRAIN_IN_THE_SAND.SEARCHED_CRATES:
			OnReward()
		ProgressCommons.GRAIN_IN_THE_SAND.REWARDS_WITHDREW:
			OnComplete()
		_:
			OnKeepLooking()

# Quest states
func OnInactive():
	Mes("Chào mừng! Tiếc là kệ trống lúc này.")
	Mes("Tulimshar không có ruộng tốt. Như đạo hữu thấy — sa mạc. Chỉ xương rồng mọc.")
	Mes("Ta nhập bột mì từ Artis để tiệm chạy. Bánh Sandstorm Bread nuôi thành nhiều năm rồi.")
	Mes("Sáng nay hàng cập cảng, nhưng đi bộ qua nắng mệt lắm.")
	Mes("Ta tự đi thì hôm nay không nướng được gì.")
	Mes("Thùng tiệm Artis có dấu sáp xanh. Đạo hữu mang giúp túi bột trong đó được không?")

	QuestChoice()

func QuestChoice(previousChoice : int = -1):
	Choice("Ta sẽ ra bến cảng xem.", OnAccept)
	if previousChoice != 1:
		Choice("Sandstorm Bread là gì?", OnAskBread)
	if previousChoice != 2:
		Choice("Ở đây trồng được gì?", OnAskDesert)
	Choice("Để sau.", OnDecline)

func OnKeepLooking():
	Mes("Bến cảng có tin không? Tìm thùng dấu xanh.")
	Mes("Ta sẽ nóng lò sẵn.")

func OnComplete():
	Mes("Dù nắng gắt, bánh nóng vẫn khó cưỡng.")
	CompleteChoice()

func CompleteChoice(previousChoice : int = -1):
	if previousChoice != 0:
		Choice("Kể về Artis.", OnAskArtis)
	if previousChoice != 1:
		Choice("Tulimshar sống sao?", OnAskCity)
	if previousChoice != 2:
		Choice("Sandstorm Bread là gì?", OnAskBread)
	if previousChoice != 3:
		Choice("Ở đây trồng được gì?", OnAskDesert)
	if previousChoice != -1:
		Choice("Giữ sức.", OnFarewell)

# Optional dialogue
func OnAskBread():
	Mes("Công thức đặc trưng! Bột Artis, nước ép xương rồng thay nước thường, chút muối sa mạc.")
	Mes("Vỏ giữ qua bão cát, sáng hôm sau vẫn tươi — tên bánh từ đó.")
	if IsQuestCompleted(ProgressCommons.Quest.GRAIN_IN_THE_SAND):
		CompleteChoice(2)
	else:
		QuestChoice(1)

func OnAskDesert():
	Mes("Chủ yếu xưong rồng. Cứng cáp, ta tận dụng tốt — kẹo, đồ uống, cả thuốc.")
	Mes("Lúa mì? Tonori chưa bao giờ là nơi trồng. Không có thuyền buôn, thành đói.")
	if IsQuestCompleted(ProgressCommons.Quest.GRAIN_IN_THE_SAND):
		CompleteChoice(3)
	else:
		QuestChoice(2)

func OnAskArtis():
	Mes("Cảng lớn bên kia đại dương, bờ Aurora. Ruộng màu mỡ, thợ giỏi.")
	Mes("Chị ta ở đó. Nướng bánh quy ngon nhất! Bột ta nhập từ tiệm chị.")
	Mes("Thuyền Artis nuôi nửa chợ Tulimshar. Không có họ, ta chỉ còn xương rồng ăn.")
	CompleteChoice(0)

func OnAskCity():
	Mes("Buôn bán. Tulimshar giỏi nhất là thế. Thành trong thung lũng gió sa mạc sống sao?")
	Mes("Ta nằm giao lộ ba lục địa. Hàng hóa đều qua cảng Tulimshar.")
	Mes("Cũng nuôi sống ta, nhưng tiệm ta luôn chờ chuyến thuyền kế.")
	CompleteChoice(1)

func OnFarewell():
	Mes("Ghé bất cứ lúc nào. Luôn có bánh mới.")

# Transitions to next states
func OnAccept():
	SetQuest(ProgressCommons.Quest.GRAIN_IN_THE_SAND, ProgressCommons.GRAIN_IN_THE_SAND.STARTED)

	Mes("Đa tạ, bạn hiền.")
	Mes("Tìm dấu xanh đậm. Không lẫn được.")

func OnDecline():
	Mes("Không sao. Lò cứ chờ.")

func OnReward():
	if not HasItem(artisFlourSackID):
		Mes("Đã ra bến cảng chưa? Túi bột trong thùng dấu xanh.")
		return

	if not HasItemsSpace([[artisFlourSackID, -1], [cactusSourCandyID, 5], [croissantID, 5]]):
		Mes("Tìm được rồi! Nhưng túi đầy — ta không đưa quà được.")
		Mes("Dọn chỗ rồi quay lại.")
		return

	RemoveItem(artisFlourSackID)
	SetQuest(ProgressCommons.Quest.GRAIN_IN_THE_SAND, ProgressCommons.GRAIN_IN_THE_SAND.REWARDS_WITHDREW)

	Mes("Tìm được! Tuyệt.")
	Mes("Với bột này, Tulimshar có Sandstorm Bread tươi trước hoàng hôn.")

	AddItem(cactusSourCandyID, 5)
	AddItem(croissantID, 5)
	AddKarma(1)
	AddExp(30)

	Mes("Cầm vài món ta làm tốt nhất. Croissant và kẹo xương rồng — một công thức gia đình, một đặc sản Tulimshar!")
