extends NpcScript

## NPC Script: Bạch Hạc Chân Nhân (Tàng Kinh Các Lão)
## Thiên Đạo Nghịch Mệnh — Build 08: Main Story & NPC Relationship

const StorySystemClass = preload("res://sources/story/StorySystem.gd")

func OnStart():
	var aff = StorySystemClass.GetAffinity(own, "BACH_HAC")
	var rank = StorySystemClass.GetRelationshipRank(aff)
	var rankName = StorySystemClass.GetRankName(rank)

	Mes("Bạch Hạc Chân Nhân tay cầm phất trần trắng, râu tóc bạc phơ toát lên tiên phong đạo cốt.")
	Mes("Quan hệ hiện tại: [%s] (Hảo cảm: %d điểm)." % [rankName, aff])

	if rank == StorySystemClass.RelationshipRank.STRANGER:
		Mes("Tàng Kinh Các lưu giữ vạn quyển điển tịch của tiền nhân. Đạo hữu đến đây tìm bí kíp hay muốn mượn sách tra cứu?")
	elif rank >= StorySystemClass.RelationshipRank.FRIENDLY:
		Mes("Hảo hài tử! Ánh mắt của ngươi tràn đầy sự tò mò và thấu triệt quy luật tự nhiên, rất giống phong thái của những bậc đại trí viễn cổ.")

	Choice("Nhận nhiệm vụ: Điều Tra Hầm Ngục Cổ Xưa (Thám sát tầng 1 địa lao)", OnQuestDungeonGate)
	Choice("Tặng điển tịch / linh đan kết giao hảo cảm.", OnGiveGift)
	Choice("Thỉnh giáo huyền lý: Vì sao Ngũ Hành Tạp Căn lại khó tu luyện?", OnAskDaoPhilosophy)
	Choice("Cáo từ các lão.", Farewell)

func OnQuestDungeonGate():
	var qId = ProgressCommons.Quest.SQ_PHONG_AN_DIA_HA
	var state = GetQuest(qId)
	if state == ProgressCommons.UnknownProgress:
		SetQuest(qId, ProgressCommons.XIANXIA_STORY_QUEST.STARTED)
		Mes("Dưới lòng đất Tàng Kinh Các có một tầng hầm niêm phong từ thượng cổ. Gần đây trận pháp xích sắt bị chấn động nới lỏng. Hãy cẩn thận xuống thám sát tầng 1!")
	elif state == ProgressCommons.XIANXIA_STORY_QUEST.STARTED:
		SetQuest(qId, ProgressCommons.CompletedProgress)
		AddExp(300)
		AddGP(250)
		StorySystemClass.AddAffinity(own, "BACH_HAC", 80)
		Mes("Đạo hữu đã thám sát hầm ngục và mang về tin tức quý giá! Lão phu vô cùng hài lòng (+80 Hảo Cảm)!")
	else:
		Mes("Tầng hầm cổ xưa đó đã được gia cố lại phong ấn, tạm thời không còn nguy cơ phát tán tà khí.")

func OnGiveGift():
	var bHash = DB.GetCellHash("Thanh Phong Bi Kip")
	var bCell = DB.GetItem(bHash)
	if bCell and HasItem(bHash, 1):
		StorySystemClass.GiveGiftToNpc(own, "BACH_HAC", bCell)
		Mes("Bạch Hạc Chân Nhân vuốt râu mỉm cười: 'Một cuốn bí kíp kiếm pháp tuyệt hảo, lão phu xin nhận tấm lòng của ngươi!'")
	else:
		Mes("Trong túi trữ vật không có thư tịch phù hợp để tặng Bạch Hạc Chân Nhân.")

func OnAskDaoPhilosophy():
	Mes("Bạch Hạc Chân Nhân điềm đạm giảng giải:")
	Mes("'Thế nhân cho rằng Thiên Linh Căn đơn thuần là nhanh nhất. Đúng, nó nhanh, nhưng nó đơn điệu. Trời đất vốn do ngũ hành hợp thành. Kẻ mang Ngũ Hành Tạp Căn tuy ban đầu trắc trở muôn phần, nhưng một khi ngộ nhập cảnh giới đại viên mãn, sẽ dung nạp được cả vũ trụ càn khôn!'")
