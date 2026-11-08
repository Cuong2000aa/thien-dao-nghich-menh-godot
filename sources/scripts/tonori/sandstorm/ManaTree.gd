extends NpcScript

const QUEST_ID : int = ProgressCommons.Quest.MINE_EXPLORATION

#
func OnStart():
	match GetQuest(QUEST_ID):
		ProgressCommons.MINE_EXPLORATION.REWARDS_WITHDREW, ProgressCommons.MINE_EXPLORATION.MANA_TREE_MET:
			OnComplete()
		ProgressCommons.MINE_EXPLORATION.DEFEATED:
			OnPostFight()
		_:
			Mes("Hãy tiến lên. Ta sẽ giữ ngươi an toàn.")

func OnPostFight():
	Mes("Cảm tạ.")
	Mes("Ta có thể tự vệ như lúc vì ngươi, nhưng hắn sẽ rời đi — và hắn vừa làm vậy.")
	Mes("Vị trí ta đã lộ; ta cần đồng minh chống mối đe dọa mới.")
	Choice("Ngươi... là cây?", OnTree)

func OnTree():
	Mes("Đúng. Ta là Uru — cây Mana.")
	Mes("Loài ta là sinh mệnh đầu tiên trên Aemil; đến hôm nay ta tưởng mình là kẻ cuối.")
	Mes("Kẻ ngươi vừa đánh đến vì Kano của ta. Các ngươi gọi là Mana Seed.")
	Mes("Vật hiếm có thể nảy thành Uru mới. Đặc biệt quý giờ này, vì ta là Uru cuối cùng còn sống.")
	Action(OnTreeBranch)

func OnTreeBranch():
	Choice("Ngươi sống sót dưới đây thế nào?", OnHowSurvive)
	Choice("Giờ ta nên làm gì?", OnWhatNext)
	Choice("Sao ngươi lại ở hang này?", OnLocation)
	Choice("Từ đó đến nay chuyện gì đã xảy ra?", OnWhatHappened)

func OnHowSurvive():
	Mes("Dù ta muốn thấy, ta không cần ánh mặt trời để sống.")
	Mes("Rễ ta ăn sâu vào đất, hưởng nguồn sinh mệnh nuôi mọi loài: Mana.")
	Mes("Chỉ cần nối với dòng Mana, ta còn sống.")
	Mes("Nhiều năm trước thế giới đầy Uru như ta. Rễ liên thông, Mana chảy mạnh hơn bây giờ.")
	Action(OnTreeBranch)

func OnWhatHappened():
	Mes("Mana đôi khi biến đổi bất ngờ.")
	Mes("Khi nó làm đảo lộn đời người một thời, niềm tin rằng nó có hại lan rộng.")
	Mes("Nhiều văn hóa chém Uru để hạn chế dòng Mana.")
	Action(OnTreeBranch)

func OnLocation():
	Mes("Khi Uru bị uy hiếp, một nhóm druid muốn bảo vệ ta gieo Kano trong hang này.")
	Mes("Sau đó họ lập Manayir gần đây, nghiên cứu và dùng dòng Mana quanh rễ ta.")
	Mes("Ta sinh ra ở đây, ẩn khỏi thế gian. Manayir dần để kiến thức về ta phai mờ, kể cả trong chính họ, để ta vẫn kín.")
	Action(OnTreeBranch)

func OnWhatNext():
	Mes("Ta nhờ ngươi đừng nói với ai về sự tồn tại của ta.")
	Mes("Hãy lấy Kano — Mana Seed.")
	Mes("Nina druid ở Tulimshar là người ta tin ngươi có thể giao phó. Nàng rất đồng điệu với Mana; ta quen cảm nhận nàng.")
	Mes("Hãy bảo lính canh mỏ quanh đây rằng ngươi gặp nguy hiểm lớn, tầng dưới không an toàn.")
	Mes("Ta không còn cách nào khác ngoài tin ngươi sẽ quyết định đúng.")
	Mes("Dù ngươi làm gì, cũng không tệ bằng kẻ ngươi vừa đánh.")
	Choice("Ta sẽ đến gặp Nina.", OnTellNina)
	Choice("Ngươi biết gì về hắn?", OnXakelbael)

func OnTellNina():
	Mes("Hãy cẩn thận. Điều ngươi phát hiện hôm nay đã được che giấu hàng ngàn năm.")
	Mes("Theo duyên phận, giờ ngươi là hộ vệ một Nguồn Mana mạnh mẽ.")
	var kanoID : int = DB.GetCellHash("Sandstorm Kano")
	if not HasItem(kanoID):
		AddItem(kanoID)
	SetQuest(QUEST_ID, ProgressCommons.MINE_EXPLORATION.MANA_TREE_MET)
	SetQuest(ProgressCommons.Quest.DESERT_SEED, ProgressCommons.DESERT_SEED.SEEK_NINA)

func OnXakelbael():
	Mes("Hắn từng thuộc Manayir. Ý định hắn đã khác.")
	Mes("Hãy hỏi những người cùng phe hắn. Họ sẽ nói hắn là ai.")
	Choice("Ta sẽ đến gặp Nina.", OnTellNina)

func OnComplete():
	Chat("Nhớ thứ ngươi đang mang theo.")
