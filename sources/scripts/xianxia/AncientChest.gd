extends NpcScript
class_name AncientChest

const ExplorationSystemClass = preload("res://sources/world/ExplorationSystem.gd")

@export var chestId : String = "POI_RUONG_BAU_CO_TICH"
@export var chestName : String = "Cổ Tích Bảo Rương"
@export var reqItem : String = "Co Dao Chi Khoa"

func OnStart():
	if not IsPlayer():
		return
		
	var charId = ExplorationSystemClass._GetCharId(own)
	if chestId in ExplorationSystemClass.runtimeOpenedChests.get(charId, []):
		Mes("Chiếc rương đồng cổ này đã được mở ra từ trước, bên trong trống không, linh khí đã sớm tiêu tán.")
		Choice("Rời đi")
		return
		
	Mes("Trước mắt đạo hữu là một chiếc [%s] bằng đồng thau ngàn năm, phủ đầy rêu phong và phù văn cấm chế:" % chestName)
	Mes("『Muốn mở bảo rương, phải có Chìa Khóa Cổ Đạo hoặc giải trừ phong ấn.』")
	
	var keyHash : int = DB.GetCellHash(reqItem)
	if NpcCommons.HasItem(own, keyHash):
		Choice("Tra Chìa Khóa Cổ Đạo vào ổ khóa để mở", TryUnlockChest)
	else:
		Choice("Khảo sát phù văn cấm chế (Chưa có chìa khóa)", InspectLock)
		
	Choice("Rời đi")

func InspectLock():
	Mes("Phù văn trên ổ khóa yêu cầu đạo hữu phải tìm được [%s] thất lạc trong cổ tích." % reqItem)

func TryUnlockChest():
	DisplayTracker("Đang giải trừ phù văn và mở rương...", 0, 4, "")
	AddTimer(own, 0.3, OnUnlockTick.bind(0), "unlock_chest")

func OnUnlockTick(tick : int):
	if not own or not is_instance_valid(own):
		return
	if tick >= 4:
		ClearTracker()
		CompleteUnlock()
	else:
		DisplayTracker("Đang giải trừ phù văn và mở rương...", tick + 1, 4, "")
		AddTimer(own, 0.3, OnUnlockTick.bind(tick + 1), "unlock_chest")

func CompleteUnlock():
	var res = ExplorationSystemClass.InteractExplorationPoint(own, chestId)
	if res.get("success", false):
		Notification("Mở rương thành công! Nhận được bảo vật cổ tích và (+%d Tu Vi)!" % res.get("tuVi", 100))
		Mes("Nắp rương bật mở, hào quang bảo vật rực rỡ! Đạo hữu đã thu được kỳ trân cổ vật.")
	else:
		Notification(res.get("message", "Mở rương thất bại!"))
		Mes(res.get("message", "Mở rương thất bại!"))
