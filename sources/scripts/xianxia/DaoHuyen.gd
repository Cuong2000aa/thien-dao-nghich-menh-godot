extends NpcScript

const Cultivation = preload("res://sources/actor/Cultivation.gd")

## NPC Script: Đạo Huyền Trưởng Lão (Sect Elder in Sacred Sect Hub)
## Manages quest lifecycle for "Thanh Trừ Linh Trùng" and canon realm guidance.

const QUEST_ID : int = ProgressCommons.Quest.THANH_TRU_LINH_TRUNG

func OnStart():
	var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
	var realmStr : String = Cultivation.GetRealmName(own.stat.level) if own and own.stat else "Phàm Thân"
	var rank : int = SectSystemClass.GetDiscipleRank(own)
	var rankName : String = SectSystemClass.GetDiscipleRankName(rank)
	var contrib : int = SectSystemClass.GetContribution(own)
	
	Mes("Chào mừng đạo hữu đến với Trúc Sơn Tiên Cảnh.")
	Mes("Quan sát khí tức của đạo hữu, hiện đang ở cảnh giới [%s]." % realmStr)
	if rank > SectSystemClass.DiscipleRank.NONE:
		Mes("Thân phận môn phái: [%s] | Điểm Cống Hiến: [%d Điểm]." % [rankName, contrib])

	Choice("Thỉnh cầu Trưởng Lão khảo hạch thăng cấp thân phận đệ tử.", OnRequestPromotion)
	Choice("Xin nhận nhiệm vụ Truyền Thừa Tông Môn.", OnSectTransmissionQuest)

	var qState : int = GetQuest(QUEST_ID)
	if qState == ProgressCommons.UnknownProgress:
		# Quest has not been accepted yet
		Mes("Gần đây dưới chân Trúc Sơn xuất hiện dị tượng, bầy Linh Trùng từ lòng đất sinh sôi bò lên quấy nhiễu linh mạch môn phái.")
		Mes("Bản tọa đang cần đệ tử xuất sơn thanh trừ yêu trùng để bảo toàn linh khí.")
		Choice("Nhận nhiệm vụ: Thanh Trừ Linh Trùng (0/5)", OnAcceptQuest)
		Choice("Xin Trưởng lão truyền thụ Kiếm Đạo Chân Truyền.", OnTransmitMartialArts)
		Choice("Thỉnh giáo Trưởng lão về các tầng cảnh giới tu chân.", OnExplainRealms)
		Choice("Xin Trưởng lão chỉ điểm phương pháp tu luyện.", OnCultivationAdvice)
		Choice("Đệ tử xin phép cáo từ.", Farewell)
	elif qState >= ProgressCommons.THANH_TRU_LINH_TRUNG.STARTED and qState < ProgressCommons.THANH_TRU_LINH_TRUNG.OBJECTIVE_MET:
		# In progress: kills < 5
		var kills : int = mini(qState - 1, 5)
		Mes("Linh Trùng dưới chân núi vẫn còn hoành hành.")
		Mes("Hiện tại đạo hữu mới tiêu diệt được [%d/5] Linh Trùng." % kills)
		Mes("Hãy mau chóng hạ sơn thanh trừ đủ số lượng yêu trùng để ổn định linh mạch.")
		Choice("Đệ tử sẽ lập tức đi ngay.", Farewell)
		Choice("Thỉnh giáo Trưởng lão về các tầng cảnh giới tu chân.", OnExplainRealms)
	elif qState >= ProgressCommons.THANH_TRU_LINH_TRUNG.OBJECTIVE_MET and qState < ProgressCommons.CompletedProgress:
		# Objective met: 5 kills reached, ready to turn in!
		Mes("Ha ha ha! Quả nhiên là thiếu niên xuất anh hùng!")
		Mes("Đạo hữu đã thanh trừ sạch 5 Linh Trùng, giúp linh mạch Trúc Sơn khôi phục lại vẻ bình yên.")
		Mes("Bản tọa đã chuẩn bị sẵn phần thưởng xứng đáng cho công lao của ngươi.")
		Choice("Giao nhiệm vụ & Nhận thưởng (50 Tu Vi, 100 Linh Thạch, Thanh Phong Kiếm)", OnCompleteQuest)
		Choice("Đệ tử xin chuẩn bị thêm một lát.", Farewell)
	else:
		# Quest 1 completed, check subsequent quest chain
		_HandlePostQuestChain()

func _HandlePostQuestChain():
	var herbQID : int = ProgressCommons.Quest.THU_THAP_LINH_THAO
	var herbState : int = GetQuest(herbQID)
	
	var alcQID : int = ProgressCommons.Quest.LUYEN_DAN_NHAP_MON
	var alcState : int = GetQuest(alcQID)
	
	var steleQID : int = ProgressCommons.Quest.KHAM_PHA_CO_BI
	var steleState : int = GetQuest(steleQID)
	
	var bossQID : int = ProgressCommons.Quest.THAO_PHAT_THU_VUONG
	var bossState : int = GetQuest(bossQID)
	
	# Check Quest 2: Thu Thập Linh Thảo
	if herbState == ProgressCommons.UnknownProgress:
		Mes("Ngươi đã chứng minh được căn cơ vững chắc. Hiện tại Dược Các đang thiếu Ngân Linh Thảo để luyện chế Hồi Xuân Đan.")
		Mes("Ngân Linh Thảo mọc rải rác ven rặng trúc quanh sơn môn. Ngươi có nguyện ý đi hái 3 cọng về đây không?")
		Choice("Nhận nhiệm vụ: Thu Thập Linh Thảo (0/3)", OnAcceptHerbQuest)
		Choice("Thỉnh giáo Trưởng lão về các tầng cảnh giới tu chân.", OnExplainRealms)
		Choice("Đệ tử xin phép chuẩn bị thêm.", Farewell)
		return
	elif herbState >= ProgressCommons.THU_THAP_LINH_THAO.STARTED and herbState < ProgressCommons.THU_THAP_LINH_THAO.OBJECTIVE_MET:
		var count : int = herbState - 1
		Mes("Ngươi đang thực hiện nhiệm vụ thu thập Ngân Linh Thảo (%d/3)." % count)
		Mes("Hãy chú ý tìm những bụi cỏ phát ra ánh bạc dịu nhẹ dưới tán trúc.")
		Choice("Đệ tử sẽ đi tìm ngay.", Farewell)
		return
	elif herbState == ProgressCommons.THU_THAP_LINH_THAO.OBJECTIVE_MET:
		Mes("Tốt lắm! 3 cọng Ngân Linh Thảo này phẩm chất thượng thừa, nguyệt hoa chi khí cực kỳ nồng đậm.")
		Choice("Giao 3 Ngân Linh Thảo & Nhận thưởng (80 Tu Vi, 150 Linh Thạch, 2 Hồi Xuân Đan)", OnCompleteHerbQuest)
		return
		
	# Check Quest 3: Luyện Đan Nhập Môn
	if alcState == ProgressCommons.UnknownProgress:
		Mes("Tu sĩ hành tẩu thiên hạ không thể không biết thuật luyện đan dược.")
		Mes("Tại Đan Các có một tòa Luyện Đan Lô. Hãy mang 2 Linh Trùng Tương và 1 Ngân Linh Thảo đến đó luyện thành 1 viên Hồi Xuân Dược.")
		Choice("Nhận nhiệm vụ: Luyện Đan Nhập Môn", OnAcceptAlcQuest)
		Choice("Đệ tử xin chuẩn bị thêm.", Farewell)
		return
	elif alcState == ProgressCommons.LUYEN_DAN_NHAP_MON.STARTED:
		Mes("Hãy đến Luyện Đan Lô tại sân đan các để bắt đầu ngưng đan.")
		Choice("Đệ tử đi ngay.", Farewell)
		return
	elif alcState == ProgressCommons.LUYEN_DAN_NHAP_MON.OBJECTIVE_MET:
		Mes("Mùi đan hương thoang thoảng trên người ngươi chứng tỏ ngươi đã luyện thành Hồi Xuân Dược!")
		Choice("Báo cáo hoàn thành Luyện Đan Nhập Môn", OnCompleteAlcQuest)
		return
		
	# Check Quest 4: Khám Phá Cổ Bi
	if steleState == ProgressCommons.UnknownProgress:
		Mes("Tổ sư Trúc Sơn Tông ngàn năm trước từng khắc lại một tấm Cổ Bi tại Cổ Đạo Phế Tích.")
		Mes("Ngươi hãy lên đường tìm kiếm tấm Cổ Bi ấy, tĩnh tâm tham ngộ kiếm ý tàn quyên.")
		Choice("Nhận nhiệm vụ: Khám Phá Cổ Bi", OnAcceptSteleQuest)
		Choice("Đệ tử xin chuẩn bị thêm.", Farewell)
		return
	elif steleState == ProgressCommons.KHAM_PHA_CO_BI.STARTED:
		Mes("Cổ Bi nằm ở vùng phế tích cổ xưa. Hãy cẩn thận dã thú và yêu vật cản đường.")
		Choice("Đệ tử đi ngay.", Farewell)
		return
	elif steleState == ProgressCommons.KHAM_PHA_CO_BI.OBJECTIVE_MET:
		Mes("Ngươi đã lĩnh ngộ được kiếm ý của tiền nhân! Khí tức quả nhiên đã thăng hoa vượt bậc.")
		Choice("Dâng nộp tâm đắc & Nhận thưởng (150 Tu Vi, 200 Linh Thạch)", OnCompleteSteleQuest)
		return
		
	# Check Quest 5: Thảo Phạt Thú Vương
	if bossState == ProgressCommons.UnknownProgress:
		Mes("CẤP BÁO! Cấm chế trong Linh Khí Bí Cảnh đang rung chuyển dữ dội!")
		Mes("Xích Viêm Thú Hậu - hung thú ngàn năm sắp thức tỉnh. Nếu để nó thoát ra, sơn môn nguy nan.")
		Mes("Ngươi đã có đủ thực lực, hãy bước vào Linh Khí Bí Cảnh và trảm sát Thú Hậu!")
		Choice("Nhận đại lệnh: Thảo Phạt Thú Vương trong Linh Khí Bí Cảnh", OnAcceptBossQuest)
		Choice("Đệ tử cần chuẩn bị kỹ lưỡng trước khi vào cấm địa.", Farewell)
		return
	elif bossState == ProgressCommons.THAO_PHAT_THU_VUONG.STARTED:
		Mes("Lối vào Linh Khí Bí Cảnh đã mở. Hãy cẩn thận ngọn lửa xích viêm của Thú Hậu!")
		Choice("Đệ tử xuất chinh ngay!", Farewell)
		return
	elif bossState == ProgressCommons.THAO_PHAT_THU_VUONG.BOSS_SLAIN:
		Mes("Thiên địa thái bình! Ngươi đã chém đầu Xích Viêm Thú Hậu, lập đại công cho Trúc Sơn Tông!")
		Choice("Nhận thưởng Thảo Phạt Thú Vương (300 Tu Vi, 500 Linh Thạch)", OnCompleteBossQuest)
		return
		
	# All Quests Completed
	Mes("Đạo hữu nay đã là rường cột đệ nhất của Trúc Sơn Tông, danh chấn bát hoang!")
	Choice("Thỉnh giáo Trưởng lão về các tầng cảnh giới tu chân.", OnExplainRealms)
	Choice("Xin Trưởng lão chỉ điểm phương pháp tu luyện.", OnCultivationAdvice)
	Choice("Đệ tử xin phép cáo từ.", Farewell)

func OnAcceptHerbQuest():
	NpcCommons.SetQuest(own, ProgressCommons.Quest.THU_THAP_LINH_THAO, ProgressCommons.THU_THAP_LINH_THAO.STARTED)
	DisplayTracker("Thu thập Ngân Linh Thảo", 0, 3)
	Notification("Đã nhận nhiệm vụ: Thu Thập Linh Thảo (0/3)")
	Chat("Hãy cẩn thận yêu thú ẩn nấp quanh rặng trúc!")

func OnCompleteHerbQuest():
	var herbID : int = DB.GetCellHash("Ngan Linh Thao")
	var herbCell : ItemCell = DB.GetItem(herbID)
	var count : int = own.inventory.GetItemCount(herbCell) if herbCell else 0
	if count < 3:
		Mes("Ngươi chưa mang đủ 3 Ngân Linh Thảo trong túi đồ.")
		return
	NpcCommons.RemoveItem(own, herbID, 3)
	NpcCommons.SetQuest(own, ProgressCommons.Quest.THU_THAP_LINH_THAO, ProgressCommons.CompletedProgress)
	NpcCommons.AddExp(own, 80)
	NpcCommons.AddGP(own, 150)
	var potionID : int = DB.GetCellHash("Hoi Xuan Dan")
	NpcCommons.AddItem(own, potionID, 2)
	NpcCommons.ClearTracker(own)
	Notification("Hoàn thành nhiệm vụ: Thu Thập Linh Thảo! (+80 Tu Vi, +150 Linh Thạch, 2 Hồi Xuân Đan)")
	Chat("Rất tốt! Mau đem đan dược phòng thân.")

func OnAcceptAlcQuest():
	NpcCommons.SetQuest(own, ProgressCommons.Quest.LUYEN_DAN_NHAP_MON, ProgressCommons.LUYEN_DAN_NHAP_MON.STARTED)
	DisplayTracker("Luyện Đan Nhập Môn", 0, 1)
	Notification("Đã nhận nhiệm vụ: Luyện Đan Nhập Môn")
	Chat("Ngọn lửa linh hỏa sẽ giúp tôi luyện đạo tâm của ngươi!")

func OnCompleteAlcQuest():
	NpcCommons.SetQuest(own, ProgressCommons.Quest.LUYEN_DAN_NHAP_MON, ProgressCommons.CompletedProgress)
	NpcCommons.AddExp(own, 100)
	NpcCommons.AddGP(own, 100)
	var bottleID : int = DB.GetCellHash("Bottle")
	NpcCommons.AddItem(own, bottleID, 1)
	NpcCommons.ClearTracker(own)
	Notification("Hoàn thành nhiệm vụ: Luyện Đan Nhập Môn! (+100 Tu Vi, +100 Linh Thạch, 1 Ngọc Bình)")
	Chat("Từ nay ngươi đã là đan sư sơ cấp của bản tông!")

func OnAcceptSteleQuest():
	NpcCommons.SetQuest(own, ProgressCommons.Quest.KHAM_PHA_CO_BI, ProgressCommons.KHAM_PHA_CO_BI.STARTED)
	DisplayTracker("Khám Phá Cổ Bi", 0, 1)
	Notification("Đã nhận nhiệm vụ: Khám Phá Cổ Bi")
	Chat("Chúc ngươi sớm ngày lĩnh hội huyền cơ!")

func OnCompleteSteleQuest():
	NpcCommons.SetQuest(own, ProgressCommons.Quest.KHAM_PHA_CO_BI, ProgressCommons.CompletedProgress)
	NpcCommons.AddExp(own, 150)
	NpcCommons.AddGP(own, 200)
	NpcCommons.ClearTracker(own)
	Notification("Hoàn thành nhiệm vụ: Khám Phá Cổ Bi! (+150 Tu Vi, +200 Linh Thạch)")
	Chat("Kiếm ý tổ sư quả nhiên đã tìm được người kế tục!")

func OnAcceptBossQuest():
	NpcCommons.SetQuest(own, ProgressCommons.Quest.THAO_PHAT_THU_VUONG, ProgressCommons.THAO_PHAT_THU_VUONG.STARTED)
	DisplayTracker("Tiêu diệt Xích Viêm Thú Hậu", 0, 1)
	Notification("Đã nhận nhiệm vụ: Thảo Phạt Thú Vương!")
	Chat("Cổng Bí Cảnh đã mở, vạn sự cẩn trọng!")

func OnCompleteBossQuest():
	NpcCommons.SetQuest(own, ProgressCommons.Quest.THAO_PHAT_THU_VUONG, ProgressCommons.CompletedProgress)
	NpcCommons.AddExp(own, 300)
	NpcCommons.AddGP(own, 500)
	NpcCommons.ClearTracker(own)
	Notification("Hoàn thành nhiệm vụ: Thảo Phạt Thú Vương! (+300 Tu Vi, +500 Linh Thạch)")
	Chat("Uy danh của ngươi đã lưu truyền khắp đại lục!")

func OnAcceptQuest():
	Mes("Rất tốt! Bản tọa tin tưởng vào đạo tâm của ngươi.")
	Mes("Hãy xuống chân núi Trúc Sơn, tiêu diệt 5 Linh Trùng rồi trở về bẩm báo.")
	Action(func():
		SetQuest(QUEST_ID, ProgressCommons.THANH_TRU_LINH_TRUNG.STARTED)
		DisplayTracker("Tiêu diệt Linh Trùng", 0, 5)
		Notification("Đã nhận nhiệm vụ: Thanh Trừ Linh Trùng")
	)
	Chat("Chúc đạo hữu thuận buồm xuôi gió, sớm ngày khải hoàn!")

func OnCompleteQuest():
	Mes("Đây là 50 điểm Tu Vi, 100 Linh Thạch cùng một thanh [Thanh Phong Kiếm] sắc bén.")
	Mes("Hãy mang thanh kiếm này bên mình, dùng nó để trảm yêu trừ ma, bảo vệ đạo tâm trên tiên lộ!")
	Action(func():
		# Award rewards exactly once
		AddExp(50)
		AddGP(100)
		var swordHash : int = DB.GetCellHash("Short Sword")
		AddItem(swordHash, 1)
		SetQuest(QUEST_ID, ProgressCommons.CompletedProgress)
		ClearTracker()
		Notification("Hoàn thành nhiệm vụ: Thanh Trừ Linh Trùng! (+50 Tu Vi, +100 Linh Thạch, +Thanh Phong Kiếm)")
	)
	Chat("Hãy tiếp tục tĩnh tâm tu luyện, sớm ngày đột phá cảnh giới!")

func OnExplainRealms():
	Mes("Tu đạo từ xưa phân định 9 đại cảnh giới theo Thiên Đạo chuẩn tắc:")
	Mes("1. Phàm Thân: Thân thể phàm nhân nguyên bản, rèn luyện gân cốt khí huyết.")
	Mes("2. Tụ Khí (Cửu Trọng Thiên): Dẫn khí nhập thể, tích tụ chân khí trong đan điền từ Tầng 1 đến Tầng 9 Viên Mãn.")
	Mes("3. Thông Mạch: Chân khí dồi dào đả thông Thập Nhị Chính Kinh và Kỳ Kinh Bát Mạch.")
	Mes("4. Đạo Cơ: Chân khí hóa lỏng đúc thành nền móng bất hoại, ngự kiếm phi hành.")
	Mes("5. Huyền Đan: Chân dịch ngưng kết thành đan châu phát sáng, thọ nguyên tăng vọt.")
	Mes("6. Nguyên Thần: Đan thăng hoa sinh ra Nguyên Thần, thần thức bao trùm vạn dặm.")
	Mes("7. Thiên Nhân: Thần hồn giao hòa cùng trời đất, lĩnh ngộ pháp tắc tự nhiên sơ khai.")
	Mes("8. Quy Hư: Phản phác quy chân, chạm tới ngưỡng cửa hư không, xé rách không gian.")
	Mes("9. Độ Kiếp: Đối mặt Lôi Kiếp cực hạn của Thiên Đạo, mở ra cánh cổng Phi Thăng!")
	Choice("Đệ tử đã hiểu, xin cảm tạ Trưởng lão.", OnStart)

func OnCultivationAdvice():
	Mes("Muốn tăng tiến tu vi, đạo hữu cần chú trọng:")
	Mes("Thứ nhất: Tích cực thảo phạt yêu thú dị biến quanh sơn môn để thu thập tinh hoa và linh thạch.")
	Mes("Thứ hai: Sau khi tăng cảnh giới, hãy mở [Túi Đồ & Thuộc Tính] để phân bổ điểm tiềm năng vào Lực Lượng, Thể Chất, Thân Pháp, Định Lực hoặc Thần Thức.")
	Mes("Thứ ba: Trang bị pháp bảo, đạo bào hoặc phi kiếm sẽ trực tiếp gia tăng uy lực chiến đấu.")
	Chat("Kiên trì tu hành, ắt có ngày phi thăng!")
	Choice("Đệ tử xin ghi nhớ lời dạy.", OnStart)

func OnTransmitMartialArts():
	if not own or not own.stat:
		return
	if own.stat.level < 2:
		Mes("Căn cốt của đạo hữu hiện còn ở cảnh giới Phàm Thân, đan điền chưa tụ khí, kinh mạch chưa thông, nếu gượng ép luyện kiếm ắt bị kiếm khí phản phệ.")
		Mes("Hãy mau chóng vận công đả tọa, vượt qua bình cảnh đột phá lên Tụ Khí Kỳ rồi quay lại bái kiến bản tọa!")
		Choice("Đệ tử hiểu rồi, sẽ chăm chỉ tu luyện.", Farewell)
		return
		
	Mes("Tốt! Khí tức của ngươi đã tụ thành dòng chảy linh khí trong đan điền, đủ tư cách tu tập [Thanh Phong Kiếm Quyết].")
	Mes("Bản tọa hôm nay thay mặt Trúc Sơn Tông, truyền thụ cho ngươi bộ Kiếm Quyết chân truyền này cùng một thanh [Thanh Phong Kiếm]. Hãy nhớ lấy: Kiếm giả, chính khí dũng mãnh, nghịch mệnh tầm đạo!")
	
	# Give book and sword
	var biKipHash = DB.GetCellHash("Thanh Phong Bi Kip")
	var biKip = DB.GetItem(biKipHash)
	if biKip:
		NpcCommons.AddItem(own, biKipHash, 1)
	var kiemHash = DB.GetCellHash("Thanh Phong Kiem")
	var kiem = DB.GetItem(kiemHash)
	if kiem:
		NpcCommons.AddItem(own, kiemHash, 1)
		
	# Directly learn skills into progress
	var skillNames : Array[String] = ["Thanh Phong Kiếm Khí", "Trúc Sơn Kiếm Trận", "Đạp Phong Bộ"]
	for sName in skillNames:
		var sHash : int = DB.GetCellHash(sName)
		var sCell = DB.GetSkill(sHash)
		if sCell:
			own.progress.AddSkill(sCell, 1, true)
			
	# Save to SQLite char_martial_arts
	if own is PlayerAgent and own.peerID != NetworkCommons.PeerUnknownID:
		var charID : int = Peers.GetCharacter(own.peerID)
		if charID != NetworkCommons.PeerUnknownID:
			var dbPath = SQLCommons.GetDBPath()
			var db = SQLite.new()
			db.path = dbPath
			if db.open_db():
				var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
				CombatSystemClass.EnsureMartialArtsTable(db)
				CombatSystemClass.SaveMartialArt(db, charID, 1001, 1, 0, 0)
				CombatSystemClass.SaveMartialArt(db, charID, 1002, 1, 0, 1)
				CombatSystemClass.SaveMartialArt(db, charID, 1003, 1, 0, 2)
				CombatSystemClass.SaveMartialArt(db, charID, 1004, 1, 0, 3)
				db.close_db()
				
	Notification("Đã lĩnh ngộ Thanh Phong Kiếm Quyết! Nhận được [Thanh Phong Kiếm] & [Thanh Phong Bí Kíp]!")
	Chat("Kiếm đạo mênh mông, mong ngươi sớm ngày ngộ ra Kiếm Ý viên mãn!")

func OnRequestPromotion():
	var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
	var check : Dictionary = SectSystemClass.CanPromote(own)
	
	if not check["canPromote"]:
		Mes("KHẢO HẠCH CHƯA ĐẠT: %s" % check["message"])
		Choice("Đệ tử sẽ nỗ lực tích lũy thêm cống hiến.", Farewell)
		return
		
	var nextRank : int = check["nextRank"]
	var promoRes : Dictionary = SectSystemClass.PromoteDisciple(own)
	var newRankName : String = promoRes.get("newRankName", "Đệ Tử")
	
	# Award corresponding Token
	var tokenName : String = ""
	match nextRank:
		SectSystemClass.DiscipleRank.NGOAI_MON:
			tokenName = "Ngoai Mon Lenh Bai"
		SectSystemClass.DiscipleRank.NOI_MON:
			tokenName = "Noi Mon Lenh Bai"
		SectSystemClass.DiscipleRank.CHAN_TRUYEN:
			tokenName = "Chan Truyen Lenh Bai"
			
	if not tokenName.is_empty():
		var tokenHash = DB.GetCellHash(tokenName)
		var tokenCell = DB.GetItem(tokenHash)
		if tokenCell and own.get("inventory"):
			own.inventory.AddItem(tokenCell, 1)
			
	# Save to SQLite
	if own is PlayerAgent and own.peerID != NetworkCommons.PeerUnknownID:
		var charID : int = Peers.GetCharacter(own.peerID)
		if charID != NetworkCommons.PeerUnknownID:
			var dbPath = SQLCommons.GetDBPath()
			var db = SQLite.new()
			db.path = dbPath
			if db.open_db():
				SectSystemClass.SaveSectData(db, charID, SectSystemClass.GetSectData(own))
				db.close_db()
				
	Mes("CHÚC MỪNG TẤN THĂNG! Ngươi đã vượt qua khảo hạch môn phái, chính thức trở thành [%s]!" % newRankName)
	Mes("Bản tọa ban thưởng cho ngươi lệnh bài thân phận tương ứng và mở khóa toàn bộ quyền hạn mới!")
	NpcCommons.PushNotification(own, "THĂNG CẤP THÂN PHẬN: [%s]!" % newRankName)
	Choice("Đệ tử bái tạ Đạo Huyền Trưởng Lão!", Farewell)

func OnSectTransmissionQuest():
	var SectSystemClass = preload("res://sources/sect/SectSystem.gd")
	var rank : int = SectSystemClass.GetDiscipleRank(own)
	var transQID : int = ProgressCommons.Quest.TRUYEN_THUA_TONG_MON
	var qState : int = GetQuest(transQID)
	
	if rank < SectSystemClass.DiscipleRank.NGOAI_MON:
		Mes("Nhiệm vụ Truyền Thừa Tông Môn chỉ dành cho đệ tử chính thức từ Ngoại Môn trở lên. Hãy nỗ lực thăng cấp thân phận trước!")
		Choice("Đệ tử đã hiểu.", Farewell)
		return
		
	if qState == ProgressCommons.UnknownProgress:
		SetQuest(transQID, ProgressCommons.TRUYEN_THUA_TONG_MON.STARTED)
		Mes("Bản tọa quan sát thấy ngươi đạo tâm kiên định, tiến cảnh vượt bậc.")
		Mes("Nay ban cho ngươi cơ duyên tham ngộ Truyền Thừa Kiếm Quyết của bản tông. Hãy diện kiến bản tọa một lần nữa để nhận thụ pháp ấn!")
		NpcCommons.PushNotification(own, "ĐÃ NHẬN NHIỆM VỤ: [Truyền Thừa Tông Môn]!")
		Choice("Đệ tử xin cảm tạ ân sư!", Farewell)
	elif qState == ProgressCommons.TRUYEN_THUA_TONG_MON.STARTED:
		SetQuest(transQID, ProgressCommons.CompletedProgress)
		SectSystemClass.AddContribution(own, 200, "Hoàn thành Truyền Thừa Tông Môn")
		if own.get("stat"):
			own.stat.SetExperience(300)
		var biKipHash = DB.GetCellHash("Thanh Phong Bi Kip")
		var biKip = DB.GetItem(biKipHash)
		if biKip and own.get("inventory"):
			own.inventory.AddItem(biKip, 1)
		Mes("TRUYỀN THỪA VIÊN MÃN! Ngươi nhận được [Thanh Phong Kiếm Quyết Bí Tịch], 200 Điểm Cống Hiến và 300 Tu Vi!")
		NpcCommons.PushNotification(own, "+200 CỐNG HIẾN & BÍ TỊCH TRUYỀN THỪA!")
		Choice("Đệ tử nguyện vì môn phái dốc lòng tận tụy!", Farewell)
	else:
		Mes("Ngươi đã hoàn tất truyền thừa chân truyền tông môn. Hãy dốc lòng tu luyện, vang danh Trúc Sơn!")
		Choice("Đệ tử xin ghi nhớ.", Farewell)

func Farewell():
	Chat("Chúc đạo hữu sớm ngày đột phá cảnh giới!")
