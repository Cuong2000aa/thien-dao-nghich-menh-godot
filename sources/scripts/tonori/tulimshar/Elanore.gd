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

# First meeting
func OnFirstMeeting():
	var waterBottleID : int = DB.GetCellHash("Water Bottle")
	var cactusSourCandyID : int = DB.GetCellHash("Cactus Sour Candy")

	Mes("Chào cậu. Chào mừng đến Tulimshar!")
	Mes("May cậu kịp tới cổng thành. Lính canh thấy cậu nằm bất tỉnh gần tường.")
	Mes("Ta là Elanore. Cậu thấy thế nào? Uống nước này và ăn chút kẹo xương rồng — sẽ dễ chịu hơn.")
	SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.INTRO_ITEMS_GIVEN)
	AddItem(waterBottleID)
	AddItem(cactusSourCandyID)
	OnFeelingChoice()

func OnFeelingChoice():
	Choice("Ta khá hơn rồi, cảm ơn.", OnFeelingBetter)
	Choice("Vẫn còn hơi mệt...", OnFeelingWeak)

func OnFeelingWeak():
	var pitayaID : int = DB.GetCellHash("Pitaya")

	Mes("Ồ... Được rồi. Cầm lấy quả này. Ngoài ra cậu nên nghỉ thêm chút.")
	SetQuest(ProgressCommons.Quest.TUTORIAL, ProgressCommons.TUTORIAL.POTION_GIVEN)
	AddItem(pitayaID)
	OnFeelingBetter()

func OnFeelingBetter():
	Mes("Sao cậu lại lạc trong sa mạc? Gần đây vùng ngoại thành rất nguy hiểm — đừng đi một mình.")
	Choice("Ta là lính đánh thuê, muốn lập danh nơi này.", OnGiveStarterClothes)
	Choice("Ta muốn giao thương với dân địa phương.", OnGiveStarterClothes)
	Choice("Ta là học giả, tìm hiểu Linh Khí và pháp thuật.", OnGiveStarterClothes)
	Choice("Ta là thủy thủ, tìm cơ hội mới trên bờ và dưới biển.", OnGiveStarterClothes)

func OnGiveStarterClothes():
	var cottonShirtID : int = DB.GetCellHash("Cotton Shirt")
	var linenShortsID : int = DB.GetCellHash("Shorts")

	Mes("Tốt lắm khi cậu còn ở đây. Thành phố cần người giỏi giúp giữ an toàn.")
	Mes("Gần đây sa mạc ngày càng nguy hiểm. Một nhóm cuồng tín Kaore ẩn trong núi phía đông, tấn công lữ khách và từng gần phá tường thành.")
	Mes("Đây là quần áo cơ bản thay cho bộ giẻ rách lúc tìm thấy cậu.")
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
	Mes("Ta không giữ cậu lâu hơn được. Người mới đến thành cần tự tìm chỗ đứng.")
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

	Choice("Kaore là gì?", OnExplainKaore)
	Choice("Ngươi là ai?", OnExplainSelf)

	if GetQuest(ProgressCommons.Quest.TUTORIAL) == ProgressCommons.CompletedProgress:
		Choice("Cảm ơn. Ta đi đây.", Farewell)

# Help with potions
func OnHelpWithPotions():
	Mes("Được! Ta pha rất nhiều Đan Hồi Sinh cho lính canh và dân thành. Chúng trị nhanh hầu hết thương tích.")
	Mes("Pha đan cần bí quyết và nguyên liệu. Cậu có muốn giúp thu thập nguyên liệu, đổi lấy vài bình đan không?")
	Choice("Ta sẽ đi thu thập giúp.", OnPotionQuestAccept)
	Choice("Để lần khác.", OnPotionQuestDecline)

func OnPotionQuestAccept():
	Mes("Mỗi bình đan cần sáu Maggot Slime, một Bình Nước và một Pitaya. Mang đủ đến đây, ta sẽ đổi Cactus Potion.")
	SetQuest(ProgressCommons.Quest.ELANORE_POTION, ProgressCommons.ELANORE_POTION.STARTED)
	Action(OnMainChoice)

func OnPotionQuestDecline():
	Mes("Khi nào sẵn sàng cứ đến tìm ta.")
	Action(OnMainChoice)

func OnPotionQuestReminder():
	Mes("Vẫn cần sáu Maggot Slime, một Bình Nước và một Pitaya cho mỗi bình đan. Có đủ rồi hãy quay lại.")
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

# What is Kaore
func OnExplainKaore():
	Mes("Linh Khí (Mana) là sinh lực nối kết vạn vật. Kaore là dạng Linh Khí đã mục nát, làm tha hóa chứ không nuôi sống. Còn nhiều tầng nữa, nhưng đại khái là vậy.")
	LookAtNpc("Nina")
	Mes("Muốn hiểu sâu hơn hãy hỏi đệ tử Nina. Cô ấy đang trông coi Soul Menhir của thành — học được rất nhiều từ cô ấy.")
	ResetCamera()
	OnMainChoice()

# Who are you
func OnExplainSelf():
	Mes("Ta là Elanore, Kahwe của thành này và vùng đất xung quanh. Người ngoài gọi chúng ta là Druid. Ta đại diện Kaumatua — dòng truyền thống cổ nhất thế giới này.")
	Mes("Đừng lo chuyện đó lúc này. Sau này nói tiếp. Hiện tại ta chỉ ở đây pha đan và tiếp nhận người bị thương từ ngoài tường.")
	OnMainChoice()

func Farewell():
	if randi() % 2:
		Chat("Giữ gìn bản thân ngoài kia.")
	else:
		Chat("Bình an.")

# Directions
func OnDirections():
	var questState : int = GetQuest(ProgressCommons.Quest.TUTORIAL)
	if questState < ProgressCommons.TUTORIAL.KAEL_DONE:
		OnSendToKael()
	elif questState < ProgressCommons.CompletedProgress:
		OnSendToEkinu()
	Action(Farewell)

func OnSendToKael():
	Mes("Tuần phòng Kael đang phụ trách tuần tra trong tường thành — nên nói chuyện với anh ấy nếu muốn nhận việc.")
	LookAtNpc("Kael")
	Mes("Anh ấy đứng phía đông bắc gần đám cây cọ.")
	Mes("Theo chân tường đến góc rồi đi lên là tới.")
	ResetCamera()

func OnSendToEkinu():
	Mes("Tuần phòng Ekinu đóng ở cổng phía nam.")
	LookAtNpc("Ekinu")
	Mes("Kể cho anh ấy việc cậu giúp Kael — anh ấy sẽ biết bước tiếp theo.")
	ResetCamera()
