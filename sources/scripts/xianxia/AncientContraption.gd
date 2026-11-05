extends NpcScript
class_name AncientContraption

const ExplorationSystemClass = preload("res://sources/world/ExplorationSystem.gd")

@export var pointId : String = "POI_CO_CO_QUAN_THACH_MON"
@export var contraptionName : String = "Thạch Môn Cơ Quan Tỏa"
@export var contraptionType : String = "CONTRAPTION" # "CONTRAPTION" or "ARRAY"

var currentLevers : int = 0
var currentArraySeq : Array[String] = []

func OnStart():
	if not IsPlayer():
		return
		
	var charId = ExplorationSystemClass._GetCharId(own)
	var state = ExplorationSystemClass.runtimeExplorationPoints.get(charId, {}).get(pointId, 0)
	
	if state > 0:
		Mes("[%s] đã được kích hoạt hoàn tất. Lối vào mật thất và cấm chế đã mở thông suốt." % contraptionName)
		Choice("Rời đi")
		return
		
	if contraptionType == "ARRAY":
		Mes("Trước mắt là Trận Bàn Ngũ Hành Thượng Cổ. 5 trụ đá khắc chữ Mộc, Hỏa, Thổ, Kim, Thủy đang mờ ảo:")
		Mes("『Ngũ hành lưu chuyển, tương sinh bất diệt. Vận chuyển đúng trình tự để mở trận nhãn.』")
		Choice("Kích hoạt theo trình tự tương sinh (Mộc -> Hỏa -> Thổ -> Kim -> Thủy)", SolveArray)
		Choice("Thử kích hoạt ngẫu nhiên", FailArray)
		Choice("Rời đi")
	else:
		Mes("Trước mắt là Thạch Môn khổng lồ bị khóa bởi 2 đòn bẩy thạch trụ tả - hữu đối xứng.")
		Mes("Hiện trạng cơ quan: Đã xoay %d/2 đòn bẩy thạch trụ." % currentLevers)
		if currentLevers < 2:
			Choice("Xoay đòn bẩy thạch trụ tiếp theo", PullLever)
		else:
			Choice("Đẩy Thạch Môn tiến vào mật thất", OpenDoor)
		Choice("Rời đi")

func PullLever():
	currentLevers += 1
	DisplayTracker("Đang xoay chuyển đòn bẩy thạch trụ...", 0, 3, "")
	AddTimer(own, 0.3, OnLeverTick.bind(0), "lever_tick")

func OnLeverTick(tick : int):
	if not own or not is_instance_valid(own):
		return
	if tick >= 3:
		ClearTracker()
		Notification("Cơ quan bánh răng chuyển động ầm ầm! Đòn bẩy đã vào khớp (%d/2)." % currentLevers)
		Mes("Đòn bẩy thạch trụ đã được kéo vào đúng vị trí! Cơ quan kêu răng rắc chuyển động.")
	else:
		DisplayTracker("Đang xoay chuyển đòn bẩy thạch trụ...", tick + 1, 3, "")
		AddTimer(own, 0.3, OnLeverTick.bind(tick + 1), "lever_tick")

func OpenDoor():
	var res = ExplorationSystemClass.InteractExplorationPoint(own, pointId, { "levers": currentLevers })
	if res.get("success", false):
		Notification("Thạch Môn ầm ầm mở ra! Phát hiện Mật Thất Kiếm Ý!")
		Mes("Cửa đá ngàn cân từ từ nâng lên! Luồng kiếm khí cổ xưa ùa ra từ bên trong mật thất.")
	else:
		Notification(res.get("message", "Chưa thể mở cửa!"))

func SolveArray():
	DisplayTracker("Đang rót linh lực dẫn động Ngũ Hành Tương Sinh...", 0, 5, "")
	AddTimer(own, 0.3, OnArrayTick.bind(0), "array_tick")

func OnArrayTick(tick : int):
	if not own or not is_instance_valid(own):
		return
	if tick >= 5:
		ClearTracker()
		var res = ExplorationSystemClass.InteractExplorationPoint(own, pointId, { "sequence": ["MOC", "HOA", "THO", "KIM", "THUY"] })
		if res.get("success", false):
			Notification("Trận pháp ngũ hành đại thành! Nhận Cổ Trận Bí Quyển và (+%d Tu Vi)!" % res.get("tuVi", 80))
			Mes("Năm luồng linh quang Mộc - Hỏa - Thổ - Kim - Thủy giao hòa rực rỡ, ban bố truyền thừa cổ trận.")
		else:
			Notification(res.get("message", "Kích hoạt trận pháp thất bại!"))
	else:
		DisplayTracker("Đang rót linh lực dẫn động Ngũ Hành Tương Sinh...", tick + 1, 5, "")
		AddTimer(own, 0.3, OnArrayTick.bind(tick + 1), "array_tick")

func FailArray():
	Notification("Linh khí xung đột kịch liệt! Trận bàn phát nổ nhẹ, hãy tĩnh tâm suy ngẫm lại quy luật tương sinh.")
	Mes("Linh khí nghịch hành bộc phát, thạch trụ chấn động rung chuyển! Cần theo quy luật Mộc sinh Hỏa, Hỏa sinh Thổ...")
