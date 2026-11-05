extends NpcScript

# Requirements
var tributeItemID : int					= DB.GetCellHash("Apple")
const tributeItemCount : int			= 5
const playerLevelRequirement : int		= 1

#
func OnStart():
	if IsTriggering():
		Chat("Tập trung vào nhiệm vụ đi!")
	else:
		Mes("Hoan nghênh đến Tim Candor — nơi Linh Khí đi để tàn!")
		QuestionStart()

func QuestionStart():
	Choice("Bắt đầu thôi, Gabz.", StartFight)
	Choice("Ta đổi ý, phải đi đây.", Farewell)
	Choice("Đây là nơi nào?", ExplainCave)
	Choice("Ngươi biết sóng quái từ đâu à?", ExplainWaves)

func ExplainCave():
	Mes("Đây là Tim Candor — hệ hang động luôn chứa nồng độ Kaore cao.")
	Mes("Khi Linh Khí chảy qua Aemil, một phần năng lượng mục nát và đọng lại ở những vùng đặc biệt.")
	Mes("Đây là một trong số đó — nơi Linh Khí ngừng chảy và hóa thành Kaore.")
	QuestionsCave()

func QuestionsCave():
	Choice("Không hỏi thêm.", QuestionStart)
	Choice("Ngươi là ai? Trông hơi lạ.", ExplainNpc)
	Choice("Sao hang lại như thế?", ExplainCaveOrigin)

func ExplainWaves():
	Mes("Bệ đứng chúng ta là chất xúc tác, dùng năng lượng hang này triệu hồi muôn loại sinh vật.")
	Mes("Chúng tấn công theo từng sóng, cố làm kiệt sức đạo hữu.")
	Mes("Sống sót đủ sóng, phép triệu hồi dừng — đạo hữu chinh phục Tim Candor.")


func QuestionsWaves():
	Choice("Không hỏi thêm.", QuestionStart)
	Choice("Thua thì sao?", ExplainFailure)
	Choice("Không có cách thanh lọc sao?", ExplainCorruption)
	Choice("Vì sao Kaore khiến mọi thứ như vậy?", ExplainKaore)

func ExplainNpc():
	Mes("Ta chưa từng nghĩ... Không biết! Ta luôn ở đây, hình như vậy?")
	Think("Gabz nhìn đạo hữu hơi bối rối.")
	Mes("Ta là Gabz.")
	QuestionsCave()

func ExplainCaveOrigin():
	Mes("Không ai rõ. Có người bảo đường hang xuống tận lõi Aemil, toàn Kaore.")
	Mes("Kẻ khác cho rằng đá ở đây hút Kaore từ mọi phía.")
	Mes("Ta không hỏi nhiều.")
	QuestionsCave()

func ExplainFailure():
	Mes("May cho đạo hữu, ta nắm quyền sinh tử nơi này!")
	Mes("Khi đạo hữu vong trong hang, ta dùng Zielite Amulet để hồi phục bản thể sống tại Soul Menhir.")
	Mes("Không cứu thì chẳng bao lâu hết quân cờ để chơi.")
	QuestionsWaves()

func ExplainCorruption():
	Mes("Nồng độ Linh Khí cao có lẽ đổi cân bằng năng lượng.")
	Mes("Nhưng ta ở đây giữ Kaore, sao không để ta vui chút?")
	QuestionsWaves()
	
func ExplainKaore():
	Mes("Kaore khiến sinh vật hung dữ, lâu dần thành undead.")
	Mes("Nó nuôi chúng chống lại kẻ sống và liên kết Linh Khí của họ.")
	Mes("Ở lâu đây, đạo hữu cũng có thể cảm nhận.")
	QuestionsWaves()

func StartFight():
	var alivePlayerCount : int = AlivePlayerCount()
	if IsTriggering():
		if alivePlayerCount == 0:
			CallGlobal("OnCancel")
		else:
			Mes("Trận đã bắt đầu. Giờ không mở trận mới được.")
	elif alivePlayerCount > 0:
		if not HasItem(tributeItemID, tributeItemCount):
			Mes("Đạo hữu cần mang 5 quả táo làm cống vật trước khi bắt đầu.")
		elif own.stat.level < playerLevelRequirement:
			Mes("Đạo hữu chưa đủ sức cho trận này. Hãy đạt cấp %d rồi quay lại." % playerLevelRequirement)
		else:
			RemoveItem(tributeItemID, tributeItemCount)
			Chat("Ha, đạo hữu sẵn sàng rồi! Mười giây nữa trận bắt đầu — chuẩn bị!")
			Action(Trigger)
