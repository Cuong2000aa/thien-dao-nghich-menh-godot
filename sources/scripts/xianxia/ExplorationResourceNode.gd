extends NpcScript
class_name ExplorationResourceNode

const ExplorationSystemClass = preload("res://sources/world/ExplorationSystem.gd")

@export var pointId : String = "POI_CUU_DIEP_NGOC_CHI"
@export var resourceName : String = "Cửu Diệp Ngọc Chi"
@export var itemName : String = "Cuu Diep Ngoc Chi"
@export var harvestCount : int = 1
@export var harvestTicks : int = 5

func OnStart():
	if not IsPlayer():
		return
		
	var itemHash : int = DB.GetCellHash(itemName)
	if not HasItemsSpace([[itemHash, harvestCount]]):
		Mes("Túi trữ vật của đạo hữu đã đầy, không thể thu thập thêm linh tài hiếm.")
		Choice("Rời đi")
		return
		
	Mes("Trước mắt là bụi [%s] tỏa ra dược hương thuần khiết, linh quang nhấp nháy trên vách đá:" % resourceName)
	Mes("『Linh vật thiên địa có linh, cần cẩn trọng hái để không làm tổn hại rễ cây và dược tính.』")
	Choice("Bắt đầu thu hái cẩn trọng", StartHarvest)
	Choice("Rời đi")

func StartHarvest():
	DisplayTracker("Đang cẩn thận thu hái %s..." % resourceName, 0, harvestTicks, "")
	AddTimer(own, 0.3, OnHarvestTick.bind(0), "exploration_harvest")

func OnHarvestTick(tick : int):
	if not own or not is_instance_valid(own):
		return
	if tick >= harvestTicks:
		ClearTracker()
		CompleteHarvest()
	else:
		DisplayTracker("Đang cẩn thận thu hái %s..." % resourceName, tick + 1, harvestTicks, "")
		AddTimer(own, 0.3, OnHarvestTick.bind(tick + 1), "exploration_harvest")

func CompleteHarvest():
	var res = ExplorationSystemClass.InteractExplorationPoint(own, pointId)
	if res.get("success", false):
		Notification("Thu hoạch thành công %dx [%s]!" % [res.get("count", 1), resourceName])
		Mes("Linh tài quý hiếm đã được cất cẩn thận vào Túi Trữ Vật.")
	else:
		Notification(res.get("message", "Chưa thể thu hoạch!"))
		Mes(res.get("message", "Chưa thể thu hoạch!"))
