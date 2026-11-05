extends CellScript
class_name QuyNguyenThuanAbility

func Execute(target : BaseAgent, _cell : BaseCell):
	if not target or not target.stat:
		return
	if target.stat.buffs:
		target.stat.buffs.Apply(CellCommons.Modifier.Defense, 25, 6.0)
		target.stat.buffs.Apply(CellCommons.Modifier.MDefense, 20, 6.0)
	if target is PlayerAgent:
		NpcCommons.PushNotification(target, "Quy Nguyên Thuẫn: Kim quang hộ thể, tâm như bàn thạch!")
