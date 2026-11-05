extends NpcScript

# Quest
const QUEST_ID : int				= ProgressCommons.Quest.TULIMSHAR_GLASSMAKING

# Recipe

const SET_INGREDIENT : int			= 4
const QUEST_SETS : int				= 3
const QUEST_INGREDIENT : int			= SET_INGREDIENT * QUEST_SETS
const QUEST_REWARD : int			= QUEST_SETS
const QUEST_EXP : int				= 100
const TRADE_MAX : int				= 20

# Quest items
var saltID : int					= DB.GetCellHash("Salt")
var boneID : int					= DB.GetCellHash("Bone")
var sulphurID : int					= DB.GetCellHash("Sulphur Powder")

# Reward items
var bottleID : int					= DB.GetCellHash("Bottle")

#
func OnStart():
	var questState : int = GetQuest(QUEST_ID)
	match questState:
		ProgressCommons.TULIMSHAR_GLASSMAKING.INACTIVE:
			OnInactive()
		ProgressCommons.TULIMSHAR_GLASSMAKING.REWARDS_WITHDREW:
			OnComplete()
		_:
			OnGathering()

# Helpers
func HasSets(setCount : int) -> bool:
	return HasItem(saltID, setCount * SET_INGREDIENT) and HasItem(boneID, setCount * SET_INGREDIENT) and HasItem(sulphurID, setCount * SET_INGREDIENT)

func GetTradeCount() -> int:
	var tradeCount : int = 0
	while tradeCount < TRADE_MAX and HasSets(tradeCount + 1):
		tradeCount += 1
	return tradeCount

func HasRoomFor(setCount : int, bottleCount : int) -> bool:
	return HasItemsSpace([[saltID, -setCount * SET_INGREDIENT], [boneID, -setCount * SET_INGREDIENT], [sulphurID, -setCount * SET_INGREDIENT], [bottleID, bottleCount]])

func TakeMaterials(setCount : int):
	RemoveItem(saltID, setCount * SET_INGREDIENT)
	RemoveItem(boneID, setCount * SET_INGREDIENT)
	RemoveItem(sulphurID, setCount * SET_INGREDIENT)

# Quest states
func OnInactive():
	Mes("Này! Mới đến thành phải không? Chưa gặp mặt ngươi. Ta là Eridu — thợ thủy tinh.")
	Mes("Gia đình ta làm thủy tinh đời nay. Dân dùng đựng nước trong khí hậu này — chủ yếu ta làm bình.")
	Mes("Ta làm từ cát Tonori, thêm muối, xương và bột lưu huỳnh.")
	Mes("Cát khắp nơi, ba thứ kia khó kiếm hơn.")

	QuestChoice()

func QuestChoice(previousChoice : int = -1):
	Choice("Ta có thể kiếm giúp.", OnAccept)
	if previousChoice != 1:
		Choice("Sao cần ba nguyên liệu đó?", OnAskRecipe)
	if previousChoice != 2:
		Choice("Kiếm ở đâu?", OnAskWhere)
	Choice("Để sau.", OnDecline)

func OnGathering():
	if not HasSets(QUEST_SETS):
		OnKeepLooking()
		return

	if not HasRoomFor(QUEST_SETS, QUEST_REWARD):
		Mes("Ngươi mang quá nhiều. Dọn bớt rồi quay lại.")
		return

	TakeMaterials(QUEST_SETS)
	SetQuest(QUEST_ID, ProgressCommons.TULIMSHAR_GLASSMAKING.REWARDS_WITHDREW)

	Mes("Muối, xương, lưu huỳnh. Đủ hết!")
	Mes("Ta làm bình ngay.")
	Mes("Trong lúc đó, đây là phần ta làm từ hàng cuối. Cầm lấy.")

	AddItem(bottleID, QUEST_REWARD)
	AddExp(QUEST_EXP)

	Mes("%d bình. Đừng làm vỡ — thủy tinh Eridu đấy!" % QUEST_REWARD)
	Think("Eridu cười.")
	Mes("Mang thêm nguyên liệu bất cứ lúc nào. Mỗi loại %d cái, ta thổi thêm bình." % SET_INGREDIENT)

func OnKeepLooking():
	Mes("Theo mắt ta còn thiếu. Mỗi loại %d. Ít hơn thì hỗn hợp không ăn." % QUEST_INGREDIENT)
	Mes("Từ từ. Lò không đi đâu, ta cũng vậy.")

func OnComplete():
	Mes("Mua thêm thủy tinh? Mừng gặp lại.")
	CompleteChoice()

func OnCompleteContinue():
	Mes("Cần gì nữa không?")
	CompleteChoice()

func CompleteChoice(previousChoice : int = -1):
	if GetTradeCount() > 0:
		Choice("Ta mang thêm nguyên liệu.", OnTrade)
	elif previousChoice != 0:
		Choice("Cần gì cho một bình nữa?", OnTradeReminder)
	if previousChoice != 1:
		Choice("Sao cần ba nguyên liệu đó?", OnAskRecipe)
	if previousChoice != 2:
		Choice("Kiếm ở đâu?", OnAskWhere)
	Choice("Giữ sức khỏe, Eridu.", OnFarewell)

# Optional dialogue
func OnAskRecipe():
	Mes("Cát là thủy tinh. Ta nấu chảy rồi làm nguội.")
	Mes("Cát thì ta có nhiều, như ngươi thấy.")
	Mes("Muối hạ nhiệt nóng chảy — không quá nóng cho nồi đất.")
	Mes("Canxi từ xương nghiền bột — để thủy tinh không tan khi gặp nước.")
	Mes("Lưu huỳnh xử bọt và bớt màu xanh.")
	Mes("Sai tỷ lệ thì yếu. Hoặc tệ hơn — xấu.")
	if IsQuestCompleted(QUEST_ID):
		CompleteChoice(1)
	else:
		QuestChoice(1)

func OnAskWhere():

	Mes("Slime hay chứa muối. Đôi khi tinh thể muối trong ruột — nhanh hơn để nước biển cạn nhưng vất vả hơn.")
	Mes("Lưu huỳnh khó hơn. Goblin lửa gần cơn bão cát mang theo. Có lẽ cơ thể chúng tạo ra — để phun lửa?")
	Mes("Xương lấy từ xác tái sinh lang thang vài vùng. Nghe bảo Kaore tạo ra. Tốt hơn đào mộ.")
	if IsQuestCompleted(QUEST_ID):
		CompleteChoice(2)
	else:
		QuestChoice(2)

func OnFarewell():
	Chat("Cẩn thận mảnh vỡ.")

# Transitions to next states
func OnAccept():
	SetQuest(QUEST_ID, ProgressCommons.TULIMSHAR_GLASSMAKING.STARTED)

	Mes("Tốt. Ngươi biết rồi.")
	Mes("Mang đến đây, ta giao %d bình trước khi nguội hẳn." % QUEST_REWARD)

func OnDecline():
	Mes("Tùy ngươi. Lò vẫn cháy.")

# Repeatable exchange
func OnTradeReminder():
	Mes("Mỗi bình cần %d Salt, %d Bone và %d Sulphur Powder. Gấp đôi thì hai bình. Đơn giản." % [SET_INGREDIENT, SET_INGREDIENT, SET_INGREDIENT])
	CompleteChoice(0)

func OnTrade():
	var tradeCount : int = GetTradeCount()
	if tradeCount <= 0:
		OnTradeReminder()
		return

	Mes("Để ta cân đồ ngươi mang...")
	Choice("Chỉ một bình.", OnExchange.bind(1))
	if tradeCount > 1:
		Choice("Hết luôn, %d bình." % tradeCount, OnExchange.bind(tradeCount))
	Choice("Ta giữ lại.", OnCompleteContinue)

func OnExchange(bottleCount : int):
	if bottleCount <= 0 or not HasSets(bottleCount):
		OnTradeReminder()
		return

	if not HasRoomFor(bottleCount, bottleCount):
		Mes("Túi sắp nổ. Sao nhét thủy tinh vào? Dọn bớt!")
		Action(OnCompleteContinue)
		return

	TakeMaterials(bottleCount)
	AddItem(bottleID, bottleCount)

	if bottleCount > 1:
		Mes("%d bình. Đừng làm vỡ!" % bottleCount)
	else:
		Mes("Một bình. Đừng vỡ nhé!")

	Action(OnCompleteContinue)
