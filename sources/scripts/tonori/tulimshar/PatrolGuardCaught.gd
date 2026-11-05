extends NpcScript

#
const ENTRANCE_POS : Vector2 = Vector2(1536, 1600) # tile (48, 50)

#
func OnStart():
	Mes("Đứng lại.")
	Mes("Lệnh Councillor Bones. Không ai đi hành lang này không có giấy phép.")
	Mes("Ta không quan tâm đạo hữu làm gì ở đây. Quay lại.")
	Action(Escort)

func Escort():
	if own.state == ActorCommons.State.TRIGGER:
		own.SetState(ActorCommons.State.TRIGGER)

	var entranceMapID : int = "Tulimshar Center".hash()
	Action(NpcCommons.Warp.bind(own, entranceMapID, ENTRANCE_POS))
