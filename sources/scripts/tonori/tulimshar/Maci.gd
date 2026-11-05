extends NpcScript

#
func OnStart():
	if own.stat and own.stat.level < 5:
		Mes("Ồ, mặt mới! Hoan nghênh Tulimshar.")
		Mes("Ta là %s. Ta giúp người mới định hướng." % npc.nick)
	else:
		Mes("Cần biết chỗ nào? Cứ hỏi.")
	OnMainChoice()

# Main choice loop
func OnMainChoice():
	Choice("Kể về thành phố.", OnCityOverview)
	Choice("Sống ở đây thế nào?", OnLiveHere)
	Choice("Ta phải đi.", Farewell)

# Answers
func OnCityOverview():
	Mes("Tulimshar nằm thung lũng giữa đồi đông và tây.")
	Mes("Tường quanh giữ sa mạc hoang và bảo ta khỏi bão cát phía nam.")
	Mes("Ta chủ yếu ở trong đó — dân sống làm việc khu trung tâm từ đây tới cảng bắc.")
	Mes("Phía bắc là chỗ tốt nhất cho mọi thứ cần — chợ, trò chơi, v.v.")
	OnMainChoice()

func OnLiveHere():
	Mes("Cộng đồng gắn bó.")
	Mes("Ta cố giúp nhau — may có người quan tâm lẫn nhau.")
	Mes("Cảnh báo: xúc phạm không được chào đón. Ta bảo vệ nhau trong thành.")

	OnMainChoice()

# Farewell
func Farewell():
	Chat("Cố lên nhé %s." % own.nick)
