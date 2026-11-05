extends NpcScript

const DESERT_SEED_ID : int = ProgressCommons.Quest.DESERT_SEED

#
func OnStart():
	var state : ProgressCommons.DESERT_SEED = GetQuest(DESERT_SEED_ID) as ProgressCommons.DESERT_SEED
	if state == ProgressCommons.DESERT_SEED.SEEK_NINA and HasItem(DB.GetCellHash("Sandstorm Kano")):
		OnDesertSeedIntro()
	elif state == ProgressCommons.DESERT_SEED.SEEK_MANAYIR:
		OnDesertSeedReminder()
	else:
		var questState : ProgressCommons.NINA_HUNGRY = GetQuest(ProgressCommons.Quest.NINA_HUNGRY) as ProgressCommons.NINA_HUNGRY
		if questState == ProgressCommons.NINA_HUNGRY.INACTIVE:
			OnIntro()
		else:
			Mes("Chào lại.")
			OnPlayerChoice()

# Intro
func OnIntro():
	Mes("Xin chào. Elanore cử cậu đến à? Mời vào.")
	Mes("Chúng ta đang đứng trước Soul Menhir cổ xưa của Tulimshar. Ta là người giữ gìn nó, dùng sức mạnh của đá để bảo vệ dân thành — trong phạm vi được phép.")
	OnPlayerChoice()

func OnPlayerChoice():
	if GetQuest(ProgressCommons.Quest.NINA_HUNGRY) == ProgressCommons.NINA_HUNGRY.STARTED and HasItem(DB.GetCellHash("Croissant")):
		Choice("Ta mang bánh sừng bò cho ngươi!", OnCroissantTurnIn)
	else:
		Choice("Có ai cản trở ngươi không?", OnExplainOpposition)
		Choice("Kể thêm về Mana và Kaore được không?", OnExplainMana)
		Choice("Soul Menhir là gì?", OnExplainMenhir)
	Choice("Hẹn gặp lại.", Farewell)

# Opposition and faith
func OnExplainOpposition():
	Mes("Không hẳn vậy. Kahwe — người ngoài gọi là Druid — luôn được chấp nhận ở Tulimshar. Không có chúng ta, thành không sống nổi qua hạn hán và hiểm họa khí hậu Tonori.")
	Mes("Vương quốc tuy theo chính thức Giáo lý Savean. Họ tin, như nửa dân chung quanh, rằng Mana cũng là lực phá hoại như Kaore và cả hai đều nên tránh trừ khi bất đắc dĩ.")
	Mes("Menhir vẫn đứng vì nó làm đời sống dễ chịu hơn. Kẻ bất đồng cũng không phủ nhận lợi ích của Mana. Họ chống công khai, nhưng khi cần chữa người thân hay cầu mưa, họ lại tìm Kahwe như ta.")
	Mes("Ta chỉ mong nhiều người mở lòng với truyền thống cổ hơn. Niềm tin Savean đã mang bao rắc rối. Nay còn sinh ra tín đồ Varunian — gần như thờ Kaore.")
	Mes("Không phải lúc nào quan hệ với Mana cũng như thế trong phần lớn lịch sử Aemil.")
	Choice("Lập trường của dân ngươi?", OnKahwePosition)
	Choice("Ta còn điều khác muốn hỏi.", OnPlayerChoice)
	Choice("Cảm ơn đã dành thời gian.", Farewell)

func OnKahwePosition():
	Mes("Kahwe giữ tri thức thời Mana còn hài hòa, lành trên thế giới. Ta muốn khôi phục cân bằng đã mất khi Uru bị hủy.")
	Choice("Uru là gì?", OnExplainUru)
	Choice("Ta còn điều khác muốn hỏi.", OnPlayerChoice)
	Choice("Cảm ơn đã dành thời gian.", Farewell)

func OnExplainUru():
	Mes("Uru, hay Cây Mana, từng là tim của sinh mệnh thế giới, dẫn Linh Khí tự nhiên.")
	Mes("Xưa có rất nhiều cây, mỗi cây ổn định Mana, ngăn nó mục thành Kaore.")
	Mes("Cây Mana bị hủy nhiều năm trước sau cuộc chiến tàn khốc, khi Giáo lý Savean thống trị quyền quý Aemil.")
	Mes("Họ quyết định tiêu diệt Uru và tạo thế giới không Mana.")
	Choice("Hiện tình thế ra sao?", OnCurrentSituation)
	Choice("Ta còn điều khác muốn hỏi.", OnPlayerChoice)
	Choice("Cảm ơn đã dành thời gian.", Farewell)

func OnCurrentSituation():
	Mes("Tùy người hỏi. Có kẻ như Red Queen bảo đời tốt hơn không ma thuật.")
	Mes("Nhưng nàng vẫn dùng trong cung. Ý nàng là dân thường không nên có — bảo quá nguy hiểm.")
	Mes("Theo ta, ma thuật là phần tự nhiên của thế giới. Dù nguy hiểm nhất trong các lực tự nhiên, ta vẫn cần nó.")
	Mes("Nước cũng nguy hiểm nếu nghĩ kỹ, nhưng không ai bảo đóng giếng cả.")
	Choice("Red Queen là ai?", OnRedQueen)
	Choice("Ta có thể giúp gì không?", OnAskForHelp)

func OnRedQueen():
	Mes("Nàng cai trị thành và cả Vương quốc Tonori, dù quyền lực ngoài tường thành hạn chế.")
	Mes("Bộ lạc Zuni chưa công nhậ Vương quốc — nàng thực sự chỉ cai Tulimshar.")
	Mes("Đó cũng là lý nàng giữ ma thuật xa dân. Zuni vẫn tu cổ thuật, rất khó đối đầu.")
	Mes("Nàng không muốn vấn đề tương tự trong thành.")
	Choice("Zuni là ai?", OnZuni)
	Choice("Ta có thể giúp gì không?", OnAskForHelp)

func OnZuni():
	Mes("Họ sống trong sa mạc Tonori từ rất lâu. Họ còn kể chuyện vùng đất trước khi thành sa mạc.")
	Mes("Họ luôn giao thương với Tulimshar, phần lớn thân thiện — miễn ta không đưa binh quá xa tường thành.")
	Mes("Mỗi lần như vậy họ đánh trả đến khi ta rút lui. Ta trọng họ: ranh giới rõ, bảo vệ quê hương.")
	Choice("Gặp họ chắc thú vị!", OnZuniMarket)
	Choice("Huh! Du mục thô lỗ.", OnZuniDismissal)

func OnZuniDismissal():
	Mes("Ừm...")
	OnZuniMarket()

func OnZuniMarket():
	Mes("Một số thương nhân của họ ở chợ phía bắc đây.")
	Mes("Họ vui trò chuyện lắm — nhất là nếu cậu mua hàng.")
	Choice("Ta có thể giúp gì không?", OnAskForHelp)

# Mana and Kaore
func OnExplainMana():
	Mes("Mana, thường gọi là \"sinh lực\", là tinh túy mọi sinh linh.")
	Mes("Nó chảy qua sinh khối thế giới, thành mạng lưới năng lượng. Điều khiển đúng có thể tạo phép, hồi phục đất, nuôi sự sống.")
	Mes("Kaore là phần còn lại khi Mana bị cắt khỏi nguồn.")
	Mes("Thay vì nuôi sống, nó thối, hủy, mục nát. Thấm vào đất, biến sinh vật thành hung dữ.")
	Mes("Kaore theo nhiều cách cũng là dạng Mana — năng lượng chính ta cảm nhận được.")
	Mes("Mana chảy trong mọi sinh linh và ngấm khoáng Zielite. Soul Menhir này làm từ đó.")
	OnPlayerChoice()

# Soul Menhir and Zielite
func OnExplainMenhir():
	Mes("Soul Menhir là bia cổ khắc từ khối Zielite khổng lồ, Kahwe dựng để dẫn và tỏa Mana.")
	Mes("Khi hoạt động, chúng tạo hào quang bảo vệ, đuổi sinh vật nhiễm Kaore và ổn định đất.")
	Mes("Có Kahwe, Soul Menhir có thể chữa thương, thậm chí ngăn tử vong — cho người thêm cơ hội sống.")
	Choice("Ngươi biết gì về Zielite?", OnExplainZielite)
	Choice("Ta còn điều khác muốn hỏi.", OnPlayerChoice)
	Choice("Cảm ơn đã dành thời gian.", Farewell)

func OnExplainZielite():
	Mes("Zielite là khoáng hiếm thân Mana. Hấp thu, lưu và phát Linh Khí — quý cho phép thuật và bảo vệ.")
	Mes("Xưa còn nhiều, nay khan hiếm sau cuộc thanh trừng khi Giáo lý Savean khiến xã hội chống Mana.")
	Mes("Nghề Zielite còn trong bùa ẩn, tàn tích, và vài Soul Menhir còn đứng chống Kaore.")
	OnPlayerChoice()

# Hungry quest
func OnAskForHelp():
	var questState : int = GetQuest(ProgressCommons.Quest.NINA_HUNGRY)
	if questState == ProgressCommons.NINA_HUNGRY.STARTED:
		Mes("Lúc này chưa. Ta vẫn mong món nhẹ — nếu cậu tình cờ gặp!")
		OnPlayerChoice()
	elif questState == ProgressCommons.NINA_HUNGRY.REWARDS_WITHDREW:
		Mes("Lúc này không, nhưng cảm ơn cậu đã hỏi.")
		OnPlayerChoice()
	else:
		Mes("Lúc này thì chưa...")
		Mes("Hơi đói thật. Ta không nhờ cậu mang đồ ăn đâu — ta tự lo sau.")
		Choice("Ta sẽ để ý đồ ăn nhẹ trên đường ra chợ.", OnStartHungryQuest)
		Choice("Ta đi đây.", Farewell)

func OnStartHungryQuest():
	Mes("Cậu tốt bụng quá. Ta thường không nhờ ai, nhưng bánh sừng bò lúc này thật tuyệt.")
	Mes("Thường có ở quầy bánh chợ. Ta muốn tự đi nhưng... Menhir này không tự canh được.")
	SetQuest(ProgressCommons.Quest.NINA_HUNGRY, ProgressCommons.NINA_HUNGRY.STARTED)

func OnCroissantTurnIn():
	Mes("Trời ơi!")
	Mes("Bánh sừng bò! Không ngờ. Cậu tử tế quá, ta không dám mong!")
	ExchangeItems([DB.GetCellHash("Croissant")], [[DB.GetCellHash("Cactus Potion"), 10]], OnCroissantExchanged)

func OnCroissantExchanged(result : ActorInventory.ExchangeResult):
	match result:
		ActorInventory.ExchangeResult.OK:
			SetQuest(ProgressCommons.Quest.NINA_HUNGRY, ProgressCommons.NINA_HUNGRY.REWARDS_WITHDREW)
			AddGP(100)
			Mes("Nhận Cactus Potion và chút vàng bù phần cậu đã chi nhé.")
		ActorInventory.ExchangeResult.MISSING_ITEMS:
			Mes("Ồ... Bánh đâu rồi? Thôi, lần sau vậy.")
		ActorInventory.ExchangeResult.NO_SPACE:
			Mes("Ta muốn đáp lễ nhưng túi đầy. Dọn chỗ rồi quay lại.")

# Desert Seed quest
func OnDesertSeedIntro():
	Mes("Cậu về rồi!")
	Mes("Chuyến đi thế nào?")
	Choice("Cậu sẽ không tin chuyện xảy ra đâu. Ta tìm thấy cái này...", OnRevealKano)

func OnRevealKano():
	Mes("Cho ta xem được không?")
	Mes("...")
	Mes("Cậu nói đúng. Đây là Kano. Hạt Mana!")
	Mes("Ta chỉ đọc sách, chưa tưởng thấy một cái trong đời.")
	Mes("Cậu tìm được sao?")
	Choice("Có Cây Mana đáy mỏ. Nó trao cho ta.", OnRevealManaTree)

func OnRevealManaTree():
	Mes("Xin lỗi?! Cây Mana? Còn sống? Trong Sandstorm Mines???")
	Mes("Ta...")
	Mes("Ta cần chút thời gian.")
	Mes("Ta từng cảm thấy gì đó hướng đó, lâu rồi. Ta tưởng là mỏ Zielite sâu. Không ngờ.")
	Mes("Cậu nói chuyện được với nó à? Nó bảo làm gì với Kano?")
	Choice("Nó bảo mang đến ngươi và tin ngươi được.", OnNinaReacts)

func OnNinaReacts():
	Mes("Sao nó biết ta? Khó tin quá...")
	Mes("Mừng vì được tin, nhưng phải báo Manayir — dòng druid cổ từng canh các cây này.")
	Mes("Họ xây thành trên bán đảo, bên kia bãi biển phía tây thung lũng Tulimshar, qua cơn bão cát.")
	Mes("Ra khỏi tường thành rồi đi tây.")
	Mes("Tìm họ, cho xem Kano. Kể những gì cậu thấy.")
	Mes("Đừng kể ai khác vội. Vật quá mạnh — chắc kéo tai để ý xấu.")
	Mes("Trước khi đi, cầm lấy.")
	ExchangeItems([], [DB.GetCellHash("Brass Zielite Amulet")], OnAmuletExchanged)

func OnAmuletExchanged(result : ActorInventory.ExchangeResult):
	match result:
		ActorInventory.ExchangeResult.OK:
			SetQuest(DESERT_SEED_ID, ProgressCommons.DESERT_SEED.SEEK_MANAYIR)
			Mes("Đây là Zielite Amulet. Hạt giữa là mảnh Zielite thuần, cùng loại Menhir này.")
			Mes("Đeo vào có thể dẫn Mana và kết nối Soul Menhir.")
			Choice("Kết nối Soul Menhir có tác dụng gì?", OnExplainMenhirSync)
		ActorInventory.ExchangeResult.NO_SPACE:
			Mes("Túi đầy, không mang được. Dọn chỗ rồi quay lại.")

func OnExplainMenhirSync():
	Mes("Chạm Soul Menhir khi đeo Zielite Amulet, đá cộng hưởng với Zielite trong Menhir.")
	Mes("Tạo liên kết giữa hồn cậu và Menhir. Gặp nạn, Menhir làm neo.")
	Mes("Hồn quay về đây thay vì tan mất.")
	Mes("Kahwe luôn bảo vệ người dưới trướng như vậy. Lẽ ra ta đã trao sớm hơn.")
	Choice("[Chạm Soul Menhir]", OnTouchMenhir)

func OnTouchMenhir():
	Narrate("Cậu đặt tay lên Soul Menhir. Zielite Amulet ấm trên da.")
	Narrate("Cảm giác lạ truyền qua — như nước chảy nhưng không ướt. Đá nhấp nháy ánh xanh nhạt.")
	Action(SaveRespawnSoulMenhir)
	Mes("Tốt. Đã kết nối.")
	Mes("Gặp Soul Menhir khác, hãy chạm. Ngươi sẽ đồng điệu với cái chạm gần nhất.")
	Mes("Giờ nên đi Manayir. Không thể cầm Kano mãi.")
	OnPlayerChoice()

func OnDesertSeedReminder():
	Mes("Đã tìm được Manayir chưa?")
	Mes("Đi nam rồi tây. Tháp họ qua cơn bão cát, trên bán đảo yên tĩnh. Hỏi dân vùng đó, ai cũng chỉ đường được.")
	OnPlayerChoice()

func SaveRespawnSoulMenhir():
	var soulmenhirAgent : NpcAgent = GetNamedGlobalNPC("Soul Menhir")
	if soulmenhirAgent:
		var globalScript : SoulMenhirGlobal = soulmenhirAgent.ownScript
		if globalScript:
			globalScript.SaveRespawn(own)
