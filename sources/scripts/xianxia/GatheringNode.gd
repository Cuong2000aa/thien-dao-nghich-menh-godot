extends NpcScript
class_name GatheringNode

const GATHER_TICKS : int = 5
const GATHER_TICK_TIME : float = 0.3 # Total 1.5s
const MOVE_TOLERANCE_SQUARED : float = 48.0 * 48.0

@export var itemName : String = "Ngan Linh Thao"
@export var itemDisplayName : String = "Ngân Linh Thảo"
@export var expReward : int = 15
@export var respawnCooldown : float = 15.0

var isDepleted : bool = false
var currentTick : int = 0
var gathererPos : Vector2 = Vector2.ZERO

func OnStart():
	if not IsPlayer():
		return
	if isDepleted:
		Mes("Tài nguyên nơi này đã cạn kiệt, cần thời gian để thiên địa linh khí tẩm bổ hồi phục.")
		return
		
	var itemID : int = DB.GetCellHash(itemName)
	if not HasItemsSpace([[itemID, 1]]):
		Mes("Túi trữ vật của đạo hữu đã đầy, không thể thu thập thêm linh tài.")
		return
		
	Mes("Bắt đầu thu thập %s, giữ nguyên vị trí để không làm hao tổn linh tính..." % itemDisplayName)
	Action(StartGathering)

func StartGathering():
	currentTick = 0
	gathererPos = own.position
	DisplayTracker("Đang hái %s..." % itemDisplayName, 0, GATHER_TICKS, "")
	AddTimer(own, GATHER_TICK_TIME, OnGatherTick, "gathering_tick")

func OnGatherTick():
	if not own or not is_instance_valid(own):
		return
	if isDepleted:
		ClearTracker()
		return
	if own.position.distance_squared_to(gathererPos) > MOVE_TOLERANCE_SQUARED:
		ClearTracker()
		Notification("Di chuyển quá xa, quá trình thu thập đã bị gián đoạn!")
		return
		
	currentTick += 1
	DisplayTracker("Đang hái %s..." % itemDisplayName, currentTick, GATHER_TICKS, "")
	
	if currentTick >= GATHER_TICKS:
		CompleteGathering()
	else:
		AddTimer(own, GATHER_TICK_TIME, OnGatherTick, "gathering_tick")

func CompleteGathering():
	ClearTracker()
	isDepleted = true
	var itemID : int = DB.GetCellHash(itemName)
	
	NpcCommons.AddItem(own, itemID, 1)
	NpcCommons.AddExp(own, expReward)
	var CraftingSystemClass = preload("res://sources/crafting/CraftingSystem.gd")
	if itemName.contains("Khoang"):
		CraftingSystemClass.AddProfessionExp(own, CraftingSystemClass.Profession.MINER, expReward)
	else:
		CraftingSystemClass.AddProfessionExp(own, CraftingSystemClass.Profession.HERBALIST, expReward)
	Notification("Thu thập thành công: %s x1 (+%d Tu Vi)!" % [itemDisplayName, expReward])
	
	# Check Quest progress
	if itemName == "Ngan Linh Thao":
		_CheckHerbQuest()
	elif itemName == "Huyen Thiet Khoang":
		_CheckOreQuest()
		
	# Deplete visual and set respawn timer
	SetVisible(false)
	if npc:
		AddTimer(npc, respawnCooldown, RespawnNode, "node_respawn")

func RespawnNode():
	isDepleted = false
	SetVisible(true)

func _CheckHerbQuest():
	var qID : int = ProgressCommons.Quest.THU_THAP_LINH_THAO
	var state : int = own.progress.GetQuest(qID)
	if state >= ProgressCommons.THU_THAP_LINH_THAO.STARTED and state < ProgressCommons.THU_THAP_LINH_THAO.OBJECTIVE_MET:
		var nextState : int = state + 1
		NpcCommons.SetQuest(own, qID, nextState)
		var gathered : int = nextState - 1
		if nextState == ProgressCommons.THU_THAP_LINH_THAO.OBJECTIVE_MET:
			Notification("Nhiệm vụ hoàn thành: Đã thu thập đủ 3 Ngân Linh Thảo! Hãy quay về phục mệnh Đạo Huyền Trưởng Lão.")
			NpcCommons.PushTracker(own, "Thu thập Ngân Linh Thảo", 3, 3)
		else:
			Notification("Tiến độ nhiệm vụ: Ngân Linh Thảo (%d/3)" % gathered)
			NpcCommons.PushTracker(own, "Thu thập Ngân Linh Thảo", gathered, 3)

func _CheckOreQuest():
	var qID : int = ProgressCommons.Quest.THU_THAP_KHOANG_THACH
	var state : int = own.progress.GetQuest(qID)
	if state >= ProgressCommons.THU_THAP_KHOANG_THACH.STARTED and state < ProgressCommons.THU_THAP_KHOANG_THACH.OBJECTIVE_MET:
		var nextState : int = state + 1
		NpcCommons.SetQuest(own, qID, nextState)
		if nextState == ProgressCommons.THU_THAP_KHOANG_THACH.OBJECTIVE_MET:
			Notification("Nhiệm vụ hoàn thành: Đã thu thập đủ 2 Huyền Thiết Khoáng! Giao cho Dược Đường Chấp Sự.")
			NpcCommons.PushTracker(own, "Khai thác Huyền Thiết", 2, 2)
		else:
			Notification("Tiến độ nhiệm vụ: Huyền Thiết Khoáng (1/2)")
			NpcCommons.PushTracker(own, "Khai thác Huyền Thiết", 1, 2)
