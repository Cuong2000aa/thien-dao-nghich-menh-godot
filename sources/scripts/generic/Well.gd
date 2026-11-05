extends NpcScript

#
const FILL_TIME : float									= 10.0
const FILL_TICKS : int									= 20
const FILL_TICK_TIME : float							= FILL_TIME / FILL_TICKS
const MOVE_TOLERANCE_SQUARED : float					= 8.0 * 8.0

var BOTTLE_ID : int										= "Bottle".hash()
var WATER_BOTTLE_ID : int								= "Water Bottle".hash()

#
func OnStart():
	if not HasItem(BOTTLE_ID):
		Mes("Cần một bình rỗng mới múc nước từ giếng này.")
	elif not HasItemsSpace([[BOTTLE_ID, -1], [WATER_BOTTLE_ID, 1]]):
		Mes("Túi đồ không còn chỗ trống.")
	else:
		Mes("Đứng yên trong lúc bình đang đầy...")
		Action(StartFill)

func StartFill():
	OnFillTick(own.position, 0)

func OnFillTick(startPos : Vector2, tick : int):
	if own.position.distance_squared_to(startPos) > MOVE_TOLERANCE_SQUARED:
		ClearTracker()
		Notification("Bạn đi quá xa giếng rồi!")
	elif not HasItem(BOTTLE_ID):
		ClearTracker()
	elif tick >= FILL_TICKS:
		CompleteFill()
	else:
		DisplayTracker("Filling...", tick, FILL_TICKS, "%")
		AddTimer(own, FILL_TICK_TIME, OnFillTick.bind(startPos, tick + 1), own.nick)

func CompleteFill():
	NpcCommons.ClearTracker(own)
	match NpcCommons.ExchangeItems(own, [BOTTLE_ID], [WATER_BOTTLE_ID]):
		ActorInventory.ExchangeResult.OK:
			PromptNext()
		ActorInventory.ExchangeResult.NO_SPACE:
			Notification("Túi trữ vật không còn chỗ trống.")

func PromptNext():
	if HasItem(BOTTLE_ID):
		Mes("Bình đã đầy nước trong. Còn một bình rỗng nữa nhé?")
		Choice("Múc thêm một bình", StartFill)
		Choice("Rời đi")
	else:
		Mes("Bình đã đầy nước trong.")
