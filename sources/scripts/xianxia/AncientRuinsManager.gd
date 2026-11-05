extends NpcScript
class_name AncientRuinsManager

const ExplorationSystemClass = preload("res://sources/world/ExplorationSystem.gd")

@export var ruinId : String = "RUIN_TRUC_SON_CO_DONG"

func OnStart():
	if not IsPlayer():
		return
		
	var ruinInfo = ExplorationSystemClass.ANCIENT_RUINS.get(ruinId, {})
	var rName = ruinInfo.get("name", "Cổ Đạo Di Tích")
	var prog = ExplorationSystemClass.GetRuinProgress(own, ruinId)
	var currentStep = prog.get("step", 0)
	var isDone = prog.get("completed", false)
	
	Mes("=== DI TÍCH KHÁM PHÁ: [%s] ===" % rName)
	if isDone:
		Mes("Đạo hữu đã hoàn thành toàn bộ thử thách của di tích này! Toàn bộ cơ quan đã mở, bảo vật đã quy về túi.")
		Choice("Rời đi")
		return
		
	Mes("Tiến độ hiện tại: Bước %d/%d" % [currentStep, ruinInfo.get("stepsTotal", 5)])
	if currentStep < ruinInfo.get("stepsDesc", []).size():
		Mes("Mục tiêu tiếp theo: %s" % ruinInfo["stepsDesc"][currentStep])
		
	match currentStep:
		0:
			Choice("Khảo sát minh văn cổ bia tìm manh mối", Step1_InspectStele)
		1:
			Choice("Kích hoạt cơ quan thạch trụ đối xứng", Step2_TriggerLevers)
		2:
			Choice("Khiêu chiến Cổ Thạch Khôi Lỗi canh cửa", Step3_FightGuardian)
		3:
			Choice("Khai mở Thạch Môn mật thất kiếm ý", Step4_OpenSecretChamber)
		4:
			Choice("Khai mở bảo rương cổ truyền thừa", Step5_LootChest)
			
	Choice("Rời đi")

func Step1_InspectStele():
	DisplayTracker("Đang khảo sát bia đá...", 0, 3, "")
	AddTimer(own, 0.3, func():
		ClearTracker()
		var res = ExplorationSystemClass.ProgressAncientRuin(own, ruinId, 1)
		Notification(res.get("message", "Đã giải mã minh văn!"))
		Mes("Minh văn hiển thị: 'Thạch trụ tả hữu, đồng thời xoay chuyển, thạch môn tự khai.'")
	, "ruin_step1")

func Step2_TriggerLevers():
	DisplayTracker("Đang phối hợp xoay thạch trụ...", 0, 3, "")
	AddTimer(own, 0.3, func():
		ClearTracker()
		var res = ExplorationSystemClass.ProgressAncientRuin(own, ruinId, 2)
		Notification(res.get("message", "Thạch trụ đã vào khớp!"))
		Mes("Cơ quan cổ chuyển động! Bụi đá rơi rụng, một con Cổ Thạch Khôi Lỗi từ từ đứng dậy chắn lối!")
	, "ruin_step2")

func Step3_FightGuardian():
	DisplayTracker("Đang giao chiến với Cổ Thạch Khôi Lỗi...", 0, 4, "")
	AddTimer(own, 0.3, func():
		ClearTracker()
		var res = ExplorationSystemClass.ProgressAncientRuin(own, ruinId, 3)
		Notification("Trảm sát Cổ Thạch Khôi Lỗi thành công! Rơi Cổ Linh Thiết!")
		Mes("Khôi lỗi vỡ vụn thành cát đá! Lối vào thạch môn đã hoàn toàn thông suốt.")
	, "ruin_step3")

func Step4_OpenSecretChamber():
	DisplayTracker("Đang giải trừ cấm chế thạch môn...", 0, 3, "")
	AddTimer(own, 0.3, func():
		ClearTracker()
		var res = ExplorationSystemClass.ProgressAncientRuin(own, ruinId, 4)
		Notification(res.get("message", "Thạch môn đã mở!"))
		Mes("Cửa đá mở ra, để lộ Mật Thất Kiếm Ý ngập tràn ánh sáng thanh phong cổ xưa.")
	, "ruin_step4")

func Step5_LootChest():
	DisplayTracker("Đang khai mở bảo rương cổ tích...", 0, 4, "")
	AddTimer(own, 0.3, func():
		ClearTracker()
		var res = ExplorationSystemClass.ProgressAncientRuin(own, ruinId, 5)
		Notification("HOÀN THÀNH DI TÍCH! Nhận Thanh Phong Cổ Kiếm và (+%d Tu Vi)!" % res.get("tuVi", 200))
		Mes("Đạo hữu đã đắc được kiếm ý và cổ kiếm chân truyền ngàn năm của Trúc Sơn Cổ Đạo!")
	, "ruin_step5")
