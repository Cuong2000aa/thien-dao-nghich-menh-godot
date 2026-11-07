extends NpcScript

#
func OnStart():
	var questState : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	match questState:
		ProgressCommons.TUTORIAL.INACTIVE:
			OnFirstMeeting()
		ProgressCommons.TUTORIAL.INTRO_ITEMS_GIVEN:
			OnFeelingChoice()
		ProgressCommons.TUTORIAL.POTION_GIVEN:
			OnFeelingBetter()
		ProgressCommons.TUTORIAL.CLOTHES_GIVEN:
			OnExplainUI()
		ProgressCommons.TUTORIAL.UI_EXPLAINED: # Deprecated
			Mes("Còn muốn hỏi gì nữa không?")
			SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.ELANORE_DONE)
			OnSendToKael()
			Action(OnMainChoice)
		_:
			Mes("Lại gặp rồi. Cần gì không?")
			OnMainChoice()

# First meeting — xuyên không bất ngờ tại Thanh Sa
func OnFirstMeeting():
	var waterBottleID : int = DB.GetCellHash("Water Bottle")
	var cactusSourCandyID : int = DB.GetCellHash("Cactus Sour Candy")

	Mes("Tỉnh rồi à? Lính canh thấy cậu bất tỉnh ngoài tường Thanh Sa Cảng.")
	Mes("Nơi này người địa phương gọi là Thanh Sa — các đạo hữu phương xa còn gọi Tulimshar.")
	Mes("Ta là Ái Lan, dược sư trông cổng thành. Uống nước này và ăn chút kẹo xương rồng đã.")
	SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.INTRO_ITEMS_GIVEN)
	AddItem(waterBottleID)
	AddItem(cactusSourCandyID)
	OnFeelingChoice()

func OnFeelingChoice():
	Choice("Khá hơn rồi... nhưng ta chẳng nhớ mình tới đây thế nào.", OnFeelingBetter)
	Choice("Vẫn chóng mặt... mọi thứ quá lạ.", OnFeelingWeak)

func OnFeelingWeak():
	var pitayaID : int = DB.GetCellHash("Pitaya")

	Mes("Cơ thể phàm trần khó chịu khí hậu sa mạc. Cầm lấy quả thanh long này, nghỉ thêm chút.")
	SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.POTION_GIVEN)
	AddItem(pitayaID)
	OnFeelingBetter()

func OnFeelingBetter():
	Mes("Ký ức đứt đoạn cũng thường thấy ở kẻ bị linh khí dị thường cuốn tới. Ngoại thành đang nguy hiểm — đừng đi một mình.")
	Choice("Ta chỉ muốn hiểu nơi này là đâu.", OnGiveStarterClothes)
	Choice("Có cách nào sống sót và kiếm ăn không?", OnGiveStarterClothes)
	Choice("Ta cảm thấy trong người có khí lạ... tạp loạn.", OnGiveStarterClothes)
	Choice("Có tông môn hay người tu hành gần đây không?", OnGiveStarterClothes)

func OnGiveStarterClothes():
	var cottonShirtID : int = DB.GetCellHash("Cotton Shirt")
	var linenShortsID : int = DB.GetCellHash("Shorts")

	Mes("Trước hết phải mặc tạm cho tử tế. Thành cần người làm việc thật, không cần danh phận cao siêu.")
	Mes("Sa mạc ngoài tường có yêu thú và dòng khí mục. Về sau nếu muốn hỏi đạo, hãy nghe ngóng đường lên sơn môn phương bắc.")
	Mes("Đây là quần áo thô — thay bộ giẻ lúc tìm thấy cậu.")
	SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.CLOTHES_GIVEN)
	AddItem(cottonShirtID, 1, "Used")
	AddItem(linenShortsID, 1, "Used")
	OnExplainUI()

func OnExplainUI():
	Mes("Trước khi đi, để ta chỉ vài điều giúp cậu sống sót ngoài kia.")
	HighlightUI(UICommons.UITarget.STATINDICATOR)
	Narrate("Đây là các chỉ số sinh mệnh. Hãy luôn chú ý.")
	HighlightUI(UICommons.UITarget.HEALTHBAR)
	Narrate("Thanh sinh lực cho biết chịu được bao nhiêu sát thương trước khi ngã xuống.")
	HighlightUI(UICommons.UITarget.MANABAR)
	Narrate("Linh lực nuôi dưỡng kỹ năng. Hết linh lực thì nhiều tuyệt học không dùng được.")
	HighlightUI(UICommons.UITarget.STAMINABAR)
	Narrate("Thể lực quyết định chạy và động tác nặng trước khi kiệt sức.")
	HighlightUI(UICommons.UITarget.MENUINDICATOR)
	Narrate("Thực đơn mở túi đồ, kỹ năng, nhiệm vụ, cài đặt và nhiều hơn nữa.")
	HighlightUI(UICommons.UITarget.ACTION_BAR)
	Narrate("Thanh hành động gắn kỹ năng và vật phẩm để dùng nhanh — trong chiến đấu từng giây đều quý.")
	HighlightUI(UICommons.UITarget.INVENTORY)
	Narrate("Trong túi đồ có thể quản lý vật phẩm, trang bị, đan dược và những thứ nhặt được.")
	HighlightUI(UICommons.UITarget.NONE)
	SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.ELANORE_DONE)
	Mes("Ta không giữ cậu lâu hơn. Người mới tới phải tự tìm chỗ đứng — tuần phòng trong thành sẽ giao việc chân tay.")
	OnSendToKael()
	DisplayActions(["gp_interact", "gp_target"])
	Narrate("Dùng Tương Tác gần NPC để trò chuyện. Có thể dùng Nhắm Mục Tiêu để chọn trước.")
	Action(Farewell)

# Main choice loop
func GetPotionBatchCount() -> int:
	var maggotSlimeID : int = DB.GetCellHash("Maggot Slime")
	var waterBottleID : int = DB.GetCellHash("Water Bottle")
	var pitayaID : int = DB.GetCellHash("Pitaya")

	var batchCount : int = 0
	while HasItem(maggotSlimeID, (batchCount + 1) * 6) and HasItem(waterBottleID, batchCount + 1) and HasItem(pitayaID, batchCount + 1):
		batchCount += 1
	return batchCount

func OnMainChoice():
	if GetQuest(ProgressCommons.Quest.TUTORIAL) < ProgressCommons.CompletedProgress:
		Choice("Bây giờ ta nên đi đâu?", OnDirections)

	var potionQuestState : int = GetQuest(ProgressCommons.Quest.ELANORE_POTION)
	var hasPotionIngredients : bool = GetPotionBatchCount() > 0
	match potionQuestState:
		ProgressCommons.ELANORE_POTION.INACTIVE:
			Choice("Ta có thể giúp gì không?", OnHelpWithPotions)
		ProgressCommons.ELANORE_POTION.STARTED:
			if hasPotionIngredients:
				Choice("Ta mang nguyên liệu rồi.", OnPotionQuestTurnIn)
			else:
				Choice("Về mấy nguyên liệu kia...", OnPotionQuestReminder)
		ProgressCommons.ELANORE_POTION.BREWED:
			if hasPotionIngredients:
				Choice("Ta mang thêm nguyên liệu.", OnPotionQuestTurnIn)
			else:
				Choice("Về mấy nguyên liệu kia...", OnPotionQuestReminder)

	Choice("Linh khí mục / Kaore là gì?", OnExplainKaore)
	Choice("Ngươi là ai?", OnExplainSelf)

	if GetQuest(ProgressCommons.Quest.TUTORIAL) == ProgressCommons.CompletedProgress:
		Choice("Cảm ơn. Ta đi đây.", Farewell)

# Help with potions
func OnHelpWithPotions():
	Mes("Được. Ta pha đan hồi sinh cho lính canh và dân thành — trị thương nhanh.")
	Mes("Thiếu nguyên liệu. Cậu giúp thu thập, ta đổi vài bình đan xương rồng. Vừa kiếm sống vừa quen vùng ngoại thành.")
	Choice("Ta sẽ đi thu thập giúp.", OnPotionQuestAccept)
	Choice("Để lần khác.", OnPotionQuestDecline)

func OnPotionQuestAccept():
	Mes("Mỗi bình cần sáu Dịch Trùng Linh (Maggot Slime), một Bình Nước và một Thanh Long. Mang đủ tới đây.")
	SetQuest(ProgressCommons.Quest.ELANORE_POTION, ProgressCommons.ELANORE_POTION.STARTED)
	Action(OnMainChoice)

func OnPotionQuestDecline():
	Mes("Khi nào sẵn sàng cứ đến tìm Ái Lan.")
	Action(OnMainChoice)

func OnPotionQuestReminder():
	Mes("Vẫn cần sáu Dịch Trùng Linh, một Bình Nước và một Thanh Long cho mỗi bình đan.")
	OnMainChoice()

func OnPotionQuestTurnIn():
	var batchCount : int = GetPotionBatchCount()
	if batchCount > 1:
		Mes("Đủ nguyên liệu cho %d bình đan! Muốn pha bao nhiêu?" % batchCount)
		Choice("Chỉ một bình.", OnPotionBrew.bind(1))
		Choice("Cả %d bình." % batchCount, OnPotionBrew.bind(batchCount))
	else:
		OnPotionBrew(1)

func OnPotionBrew(brewCount : int):
	var removeItems : Array = [[DB.GetCellHash("Maggot Slime"), 6 * brewCount], [DB.GetCellHash("Water Bottle"), brewCount], [DB.GetCellHash("Pitaya"), brewCount]]
	ExchangeItems(removeItems, [[DB.GetCellHash("Cactus Potion"), brewCount]], OnPotionBrewed)

func OnPotionBrewed(result : ActorInventory.ExchangeResult):
	match result:
		ActorInventory.ExchangeResult.OK:
			var isFirstBrew : bool = GetQuest(ProgressCommons.Quest.ELANORE_POTION) == ProgressCommons.ELANORE_POTION.STARTED
			SetQuest(ProgressCommons.Quest.ELANORE_POTION, ProgressCommons.ELANORE_POTION.BREWED)
			if isFirstBrew:
				Mes("Cảm ơn đã giúp. Ta pha đan hồi sinh ngay!")
				Mes("Giúp dân ngoài này tốt hơn ngồi trong tháp hay cung điện. Lãnh đạo thành nên nghĩ thêm về điều đó.")
			else:
				Mes("Cảm ơn — phần của cậu đây!")
			Action(OnPotionBrewedChoice)
		ActorInventory.ExchangeResult.MISSING_ITEMS:
			Mes("Hmm, hình như cậu không còn đủ nguyên liệu.")
			Action(OnMainChoice)
		ActorInventory.ExchangeResult.NO_SPACE:
			Mes("Túi đã đầy, hãy dọn chỗ trước.")
			Action(OnMainChoice)

func OnPotionBrewedChoice():
	Choice("Ta còn muốn hỏi chuyện khác.", OnMainChoice)
	Choice("Ta đi đây.", Farewell)

# What is Kaore — reframed as linh khí mục
func OnExplainKaore():
	Mes("Linh khí là sinh lực nuôi vạn vật. Khi bị ô nhiễm hay rạn nứt quy tắc trời đất, nó mục thành khí độc — dân cũ từng gọi Kaore.")
	LookAtNpc("Nina")
	Mes("Muốn hiểu sâu hãy hỏi Ni Na. Nàng canh linh thạch (Soul Menhir) của thành — biết nhiều về khí mạch nơi này.")
	ResetCamera()
	OnMainChoice()

# Who are you
func OnExplainSelf():
	Mes("Ta là Ái Lan. Người phương Tây còn ghi tên cũ Elanore trên sổ sách — đừng bận tâm. Ta pha đan và cứu người bị thương ngoài tường.")
	Mes("Chuyện tông môn, Thiên Đạo… hỏi sau khi cậu đứng vững đã. Giờ sống sót đã là công phu.")
	OnMainChoice()

func Farewell():
	if randi() % 2:
		Chat("Giữ gìn bản thân ngoài kia.")
	else:
		Chat("Bình an. Nhớ uống nước.")

# Directions
func OnDirections():
	var questState : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	if questState < ProgressCommons.TUTORIAL.KAEL_DONE:
		OnSendToKael()
	elif questState < ProgressCommons.CompletedProgress:
		OnSendToEkinu()
	Action(Farewell)

func OnSendToKael():
	Mes("Tuần phòng Kha Nhĩ tuần trong tường — nói chuyện với anh ấy nếu muốn nhận việc chân tay.")
	LookAtNpc("Kael")
	Mes("Anh ấy đứng phía đông bắc gần đám cây cọ.")
	Mes("Theo chân tường đến góc rồi đi lên là tới.")
	ResetCamera()

func OnSendToEkinu():
	Mes("Tuần phòng Nghê Khôn đóng cổng nam.")
	LookAtNpc("Ekinu")
	Mes("Kể việc cậu đã giúp Kha Nhĩ — anh ấy sẽ chỉ bước tiếp.")
	ResetCamera()
