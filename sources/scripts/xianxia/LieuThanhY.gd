extends NpcScript

## NPC Script: Liễu Thanh Y (Y Sư Dược Đường)
## Thiên Đạo Nghịch Mệnh — Build 08: Main Story & NPC Relationship

const StorySystemClass = preload("res://sources/story/StorySystem.gd")

func OnStart():
	var aff = StorySystemClass.GetAffinity(own, "LIEU_THANH_Y")
	var rank = StorySystemClass.GetRelationshipRank(aff)
	var rankName = StorySystemClass.GetRankName(rank)

	Mes("Liễu Thanh Y mỉm cười thanh nhã cúi đầu chào đạo hữu.")
	Mes("Quan hệ hiện tại: [%s] (Hảo cảm: %d điểm)." % [rankName, aff])

	if rank == StorySystemClass.RelationshipRank.STRANGER:
		Mes("Dược Đường hôm nay có khá nhiều linh thảo mới hái, đạo hữu cần tìm dược thảo hay bốc thuốc chữa trị?")
	elif rank >= StorySystemClass.RelationshipRank.FRIENDLY:
		Mes("Đạo hữu lại tới thăm ta sao? Ta vừa pha một ấm Ngân Linh Trà bồi bổ kinh mạch, mời đạo hữu cùng dùng.")

	Choice("Nhận nhiệm vụ quan hệ: Dược Điển Tầm Thảo (Cần 3 Ngân Linh Thảo, 1 U Hồn Thảo)", OnQuest1)
	Choice("Nhận nhiệm vụ quan hệ: Cứu Trợ Thương Binh", OnQuest2)
	Choice("Tặng quà linh thảo kết giao hảo cảm.", OnGiveGift)
	Choice("Thỉnh giáo y lý về thể trạng Ngũ Hành Tạp Căn.", OnAskRootAdvice)
	Choice("Cáo từ y sư.", Farewell)

func OnQuest1():
	var qId = ProgressCommons.Quest.NQ_LIEU_THANH_Y_1
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Đa tạ đạo hữu! Ta đang rất cần 3 cọng Ngân Linh Thảo và 1 cọng U Hồn Thảo để điều chế thuốc trị thương cho đệ tử.")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		var hasHerb = HasItem(DB.GetCellHash("Ngan Linh Thao"), 3)
		var hasSoul = HasItem(DB.GetCellHash("U Hon Thao"), 1)
		if hasHerb and hasSoul:
			RemoveItem(DB.GetCellHash("Ngan Linh Thao"), 3)
			RemoveItem(DB.GetCellHash("U Hon Thao"), 1)
			SetQuest(qId, ProgressCommons.CompletedProgress)
			AddExp(120)
			AddGP(80)
			StorySystemClass.AddAffinity(own, "LIEU_THANH_Y", 60)
			Mes("Dược thảo phẩm chất thật tốt! Liễu Thanh Y vô cùng cảm kích công lao của đạo hữu (+60 Hảo Cảm)!")
		else:
			Mes("Đạo hữu vẫn chưa gom đủ 3 Ngân Linh Thảo và 1 U Hồn Thảo, xin hãy cẩn thận tìm kiếm thêm nơi ven suối.")
	else:
		Mes("Đạo hữu đã hoàn thành nhiệm vụ Dược Điển Tầm Thảo rồi, dược tính đan dược đợt này vô cùng ổn định.")

func OnQuest2():
	var qId = ProgressCommons.Quest.NQ_LIEU_THANH_Y_2
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Nhiều đệ tử ngoại vi bị trúng hỏa chướng độc khí, xin đạo hữu đem Thanh Tâm Đan phân phát cứu viện đệ tử!")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		if HasItem(DB.GetCellHash("Thanh Tam Dan"), 1):
			RemoveItem(DB.GetCellHash("Thanh Tam Dan"), 1)
			SetQuest(qId, ProgressCommons.CompletedProgress)
			AddExp(200)
			AddGP(100)
			StorySystemClass.AddAffinity(own, "LIEU_THANH_Y", 100)
			Mes("Kịp thời cứu vãn tính mệnh đồng môn! Liễu Thanh Y nhìn đạo hữu với ánh mắt vô cùng cảm kích (+100 Hảo Cảm)!")
		else:
			Mes("Cần 1 viên Thanh Tâm Đan để hóa giải hỏa chướng khí. Đạo hữu có thể luyện chế tại Đan Các.")
	else:
		Mes("Thương thế các đệ tử đã ổn định hoàn toàn, công đức của đạo hữu thật vô lượng.")

func OnGiveGift():
	var herbHash = DB.GetCellHash("Ngan Linh Thao")
	var herbCell = DB.GetItem(herbHash)
	if herbCell and HasItem(herbHash, 1):
		StorySystemClass.GiveGiftToNpc(own, "LIEU_THANH_Y", herbCell)
		Mes("Liễu Thanh Y đón nhận linh thảo với vẻ vui mừng khôn xiết: 'Đa tạ tâm ý của đạo hữu!'")
	else:
		Mes("Trong túi trữ vật của đạo hữu hiện không có linh thảo phù hợp để tặng.")

func OnAskRootAdvice():
	Mes("Liễu Thanh Y chăm chú bắt mạch cho đạo hữu, trầm ngâm nói:")
	Mes("'Ngũ Hành Tạp Căn vốn là thể chất tự nhiên của vạn vật trời đất. Người đời chê nó chậm chạp, nhưng nếu thấu triệt chu kỳ sinh khắc, dung hợp cả ngũ hành thì đan điền lại vững chắc hơn bất kỳ ai.'")
