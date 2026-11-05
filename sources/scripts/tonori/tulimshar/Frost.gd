extends NpcScript

#
const QUEST_ID : int = ProgressCommons.Quest.TULIMSHAR_OLD_FRIENDSHIP
var sealedLettersID : int = DB.GetCellHash("Sealed Letters")
var heavyEnvelopeID : int = DB.GetCellHash("Heavy Envelope")

#
func OnStart():
	var questState : int = GetQuest(QUEST_ID)
	match questState:
		ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.INACTIVE:
			QuestInactive()
		ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.STARTED:
			QuestStarted()
		ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.ENVELOPES_FOUND:
			QuestEnvelopesFound()
		ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.LETTERS_DELIVERED:
			QuestRewards()
		ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.REWARDS_WITHDREW:
			QuestCompleted()

func QuestInactive():
	Mes("Cẩn thận chân. Xương rồng mới mọc.")
	Mes("Xin lỗi, ít khách. Từ khi ta còn làm cố vấn trong cung.")
	Mes("Ta bỏ vài năm rồi. Trên kia gánh nặng quá.")
	Mes("Ở đây chỉ ta và đất. Nông nghiệp có ích cho thành — ta không phiền.")
	Mes("Ngươi có bao giờ lặp đi lặp lại một kịch bản trong đầu, tự hỏi nếu chọn khác thì sao?")
	Choice("Ngươi đang nghĩ gì?", Lore)
	Choice("Ta đi đây", Dismiss)

func QuestStarted():
	Mes("Vẫn làm à? Hành lang đó không thân thiện.")
	Choice("Kể lại về Ben", Lore)
	Choice("Thư ở đâu?", Directions)
	Choice("Ta đang làm", Dismiss)

func QuestEnvelopesFound():
	Mes("Tìm được rồi. Tốt.")
	Mes("Mang thư niêm phong đến Ben. Ta vừa thấy anh ấy bước vào hành lang ngay sau khi ngươi đi.")
	Mes("Anh ấy nhạy bén — hoặc ngươi ồn khi né ánh sáng. Dù sao anh ấy cũng ở trong đó.")

func QuestRewards():
	if HasItem(heavyEnvelopeID):
		Mes("Ngươi về rồi. Anh ấy...")
		Mes("Phong bì này. Nặng.")
		Mes("...")
		Mes("Vàng. Anh ấy bỏ vàng. Ghi tên ta.")
		Mes("Khi Nữ hoàng lần đầu đóng quân cho ta cùng chỗ, mỗi người dành phần cho kia — phòng khi một người cần trốn.")
		Mes("Ta tưởng anh ấy đã tiêu sau khi ta đi. Ta hiểu nếu anh ấy làm vậy.")
		Mes("Ta không xứng. Nên thuộc về ai là bạn tốt hơn ta từng là.")
		Mes("Cầm lấy. Một buổi chiều ngươi làm hơn ta và Ben cả năm.")
		ExchangeItems([heavyEnvelopeID], [], OnEnvelopeExchanged)
	else:
		Mes("Tìm Ben chưa? Anh ấy ở hành lang tường tây.")

func OnEnvelopeExchanged(result : ActorInventory.ExchangeResult):
	match result:
		ActorInventory.ExchangeResult.OK:
			SetQuest(QUEST_ID, ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.REWARDS_WITHDREW)
			AddGP(1000)
		ActorInventory.ExchangeResult.MISSING_ITEMS:
			Mes("Khoan, phong bì đâu? Mang lại cho ta.")

func QuestCompleted():
	Mes("Xương rồng năm nay mọc tốt.")
	Mes("Ta cứ nghĩ nên đi bộ tới hành lang. Không phải hôm nay, nhưng ta quyết sẽ đi.")
	Mes("Anh ấy giữ thư. Cũng là gì đó, phải không?")

func Lore():
	Mes("Có người ta từng làm cùng. Ben. Tài giỏi — sửa được mọi thứ, dựng được mọi thứ.")
	Mes("Im lặng. Anh ấy thà phá tường rồi dựng lại còn hơn giải thích.")
	Mes("Ta là người nói chuyện với dân. Sắp ca, giải quyết cãi vã, giữ mọi thứ chạy.")
	Mes("Ta và anh ấy giữ tường này nhiều năm. Dưới Nữ hoàng, không dễ.")
	Choice("Chuyện gì xảy ra?", Conflict)
	Choice("Ta đi đây", Dismiss)

func Conflict():
	Mes("Nữ hoàng. Hoặc nàng cứ như vậy. Luôn đòi hỏi, luôn theo ý nàng.")
	Mes("Ta bắt đầu đặt quy tắc. Quy trình mọi thứ. Ta nghĩ nếu sắp xếp hết, áp lực sẽ nhẹ.")
	Mes("Ben nghĩ khác. Bảo ta chồng thêm áp lực lên gánh sẵn có.")
	Mes("Anh ấy cứ làm. Tự quyết. Không báo ai. Ta biết sau.")
	Mes("Cả hai cùng giữ một bức tường. Rồi ta ngừng nói chuyện, bắt đầu cãi nhau.")
	Mes("Ta mắc quá nhiều lỗi để nghĩ mình đúng hết. Nhưng hồi đó không ai nhún nhường.")
	Mes("Anh ấy bảo ta đi. Ta đi. Ta không tự hào cách xử lý, nhưng ta nhường đường.")
	Mes("Vài năm rồi. Ta vẫn nghĩ nhiều hơn nên.")
	if GetQuest(QUEST_ID) == ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.INACTIVE:
		Choice("Ta có thể giúp gì không?", Quest)
		Choice("Ta tiếc khi nghe vậy", Dismiss)

func Quest():
	Mes("Thực ra... có thể.")
	Mes("Cuối hành lang tường tây, qua tuần tra của Ben, có phòng nhỏ với kệ thư viện.")
	Mes("Trên kệ có phong bì. Thư ta và Ben viết cho nhau khi Nữ hoàng đóng quân cho ta xa nhau — trước khi mọi thứ hỏng.")
	Mes("Không chắc đổi được gì. Nhưng nếu anh ấy đọc lại, có lẽ nhớ ta không lúc nào cũng như nay.")
	Mes("Hành lang có tuần tra. Bám bóng tối. Bước vào sáng, lính bắt.")
	Choice("Ta sẽ làm", Accept)
	Choice("Để sau", Decline)

func Directions():
	Mes("Cuối hành lang tường tây bên trái ta, trên kệ thư viện.")
	Mes("Và tránh ánh sáng. Lính có lệnh đuổi dân không phép.")

func Accept():
	SetQuest(QUEST_ID, ProgressCommons.TULIMSHAR_OLD_FRIENDSHIP.STARTED)
	Mes("Cảm ơn nhé.")
	Directions()

func Decline():
	Chat("Ta hiểu. Nhờ người lạ quá nhiều.")

func Dismiss():
	Chat("Ừ. Xương rồng không tự chăm được.")
