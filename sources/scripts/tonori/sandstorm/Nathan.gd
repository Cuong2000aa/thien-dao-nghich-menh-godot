extends NpcScript

const QUEST_ID = ProgressCommons.Quest.SANDSTORM_NATHAN_WATER

#
func OnStart():
	match GetQuest(QUEST_ID):
		ProgressCommons.SANDSTORM_NATHAN_WATER.INACTIVE:
			Mes("Chào! Ta là tuần phòng Nathan.")
			Mes("Thường ngày ta canh cảng Tulimshar, nhưng hôm nay ta được vinh dự... BỊ NẮNG QUAY CẢ NGƯỜI RA GIỮA SA MẠC NÀY.")
			Mes("Xin lỗi. Ta nói nhảm rồi.")
			Mes("Mặt trời làm ta loạn cả óc.")
			Choice("Đây có phải lối vào Mỏ Bão Cát không?", OnEntrance)
		ProgressCommons.SANDSTORM_NATHAN_WATER.STARTED:
			Mes("À, là ngươi! Xin lỗi, cát che mặt nên ta không nhận ra.")
			Choice("Về chai nước kia.", OnWaitingWater)
		ProgressCommons.SANDSTORM_NATHAN_WATER.REWARDS_WITHDREW:
			OnComplete()
	Choice("Thôi, ta tưởng ngươi là ma cát.", Farewell)

func Farewell():
	Express("Cát dính khắp người... KHẮP NƠI.")

# Default dialogue flow
func OnEntrance():
	Mes("Đúng vậy! Ta hiểu vì sao nơi này bị bỏ hoang.")
	Mes("Bão cát làm cát dính cả giữa răng. Không dám tưởng thợ mỏ ngày xưa phải đi lại đây mỗi ngày thế nào.")
	Mes("Giờ bọn trong đó cũng phải chịu cảnh này.")
	Mes("Ta chỉ mong được về canh cảng. Nếu bị giam ở đây mãi, ta có khi tự ném mình cho goblin ăn.")

	Choice("Thực ra ta vào cùng bọn họ.", OnJoinThem)

func OnJoinThem():
	Mes("Thật sao? Trông ngươi không giống thợ mỏ. Cuốc đâu rồi?")

	Choice("Ta không đến đào, chỉ trinh sát.", OnJustScouting)

func OnJustScouting():
	Mes("À, vậy à.")
	Mes("Xin lỗi vì cản đường. Đứng một mình ngoài này chán lắm.")
	Mes("Vào đi, chắc họ đang đợi ngươi.")

	Choice("Cảm ơn Nathan. Chúc một ngày tốt lành!", OnNiceDay)
	if GetQuest(QUEST_ID) == ProgressCommons.SANDSTORM_NATHAN_WATER.INACTIVE:
		Choice("Có gì ta giúp cho đỡ bớt khổ ngoài này không?", OnJobEasier)

func OnNiceDay():
	Express("Ta sẽ có ngày tuyệt khi được về nhìn biển! Hẹn gặp lại.")

# Water quest
func OnJobEasier():
	Mes("Ngươi hỏi thì ta nói... Ta cần thêm nước!")
	Mes("Có giếng ở đây nhưng khô lâu rồi.")
	Mes("Nói thật: không phải để uống. Ta mang theo rồi.")
	Mes("Ta chỉ muốn đổ lên mặt cho bớt cảm giác bị luộc chín dưới nắng.")
	Mes("Yêu cầu có ngớ ngẩn không?")

	Choice("Không hề. Ta hiểu cảm giác quá nhiệt ở vùng này.", AcceptQuest)
	Choice("Có, thật đấy. Ta còn việc quan trọng hơn.", RefuseQuest)

func RefuseQuest():
	Mes("Ồ... ta hiểu. Không sao. Coi như ta chưa hỏi.")
	Mes("Chắc vì thế họ mới đóng ta gác ngoài này... Ta phiền lắm nhỉ.")
	Action(Farewell)

func AcceptQuest():
	Mes("Ta biết ngươi sẽ hiểu. Giữ nước là quan trọng! Ta đợi ngươi, bằng hữu.")
	Think("Nathan tự nghĩ bụng")
	Mes("Dù muốn đi cũng không đi được...")
	SetQuest(QUEST_ID, ProgressCommons.SANDSTORM_NATHAN_WATER.STARTED)
	if HasItem(DB.GetCellHash("Water Bottle")):
		Choice("Ta mang theo một chai.", OnDeliverWater)
	Choice("Ta sẽ tìm giúp!", Farewell)

func OnWaitingWater():
	Mes("Ngươi tìm được chai nước chưa?")
	if HasItem(DB.GetCellHash("Water Bottle")):
		Choice("Có rồi.", OnDeliverWater)
	Choice("Chưa, ta sẽ tiếp tục tìm.", Farewell)

func OnDeliverWater():
	var waterBottleHash : int = DB.GetCellHash("Water Bottle")
	if HasItem(waterBottleHash):
		RemoveItem(waterBottleHash)
		SetQuest(QUEST_ID, ProgressCommons.SANDSTORM_NATHAN_WATER.REWARDS_WITHDREW)
		Mes("Cảm ơn, bằng hữu! Cuối cùng cũng được nhẹ người!")
		Think("Nathan nhanh chóng đổ hết nước ngươi mang tới lên người mình.")
		Think("Ngươi đứng nhìn nước cẩn thận mang cả đoạn đường chảy xuống thân hắn rồi thấm vào cát bên dưới.")
		AddExp(50)
		AddGP(100)
		Action(OnComplete)
	else:
		Action(Farewell)

func OnComplete():
	Mes("Đúng thứ ta cần. Ngươi không tưởng được đâu.")
	Mes("Giờ chỉ cần ai đó mang thêm một chai nữa...")
	Express("Đùa thôi. Phần lớn là đùa.")
