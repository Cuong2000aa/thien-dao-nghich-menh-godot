extends CellScript
class_name XianxiaElixirScript

## TDNM — BUILD 07: XIANXIA ELIXIR EFFECT HANDLER
## Handles specialized elixir consumption logic, buffs, and cooldowns.

func Execute(target : BaseAgent, cell : BaseCell):
	if not target or not is_instance_valid(target) or not cell:
		return
	
	var cellName : String = cell.name
	var agentRid : int = target.get_rid().get_id()
	
	match cellName:
		"Dai Hoi Xuan Dan":
			target.stat.SetHealth(350)
			_Notify(target, "Uống [Đại Hồi Xuân Đan]: Khí Huyết dồi dào, hồi phục 350 điểm!")
		"Ngung Than Dan":
			target.stat.SetMana(200)
			_Notify(target, "Uống [Ngưng Thần Đan]: Thức hải an định, phục hồi 200 Linh Lực!")
		"Tu Khi Dan":
			NpcCommons.AddExp(target, 150)
			_Notify(target, "Uống [Tụ Khí Đan]: Linh khí tinh thuần rót vào đan điền, gia tăng +150 Tu Vi!")
		"Kim Cang Dan":
			target.stat.buffs.Apply(CellCommons.Modifier.Defense, 15.0, 120.0)
			_Notify(target, "Uống [Kim Cang Đan]: Kim quang hộ thể, tăng 15 điểm Phòng Ngự trong 120 giây!")
		"Bao Nguyen Dan":
			target.stat.buffs.Apply(CellCommons.Modifier.Attack, 20.0, 120.0)
			_Notify(target, "Uống [Bạo Nguyên Đan]: Chân khí cuộn trào, tăng 20 điểm Công Kích trong 120 giây!")
		"Thanh Tam Dan":
			target.stat.buffs.ClearSkill(DB.GetCellHash("Poison"))
			target.set_meta("poison_immunity_until", Time.get_unix_time_from_system() + 60.0)
			_Notify(target, "Uống [Thanh Tâm Đan]: Tạp chất và độc tố tiêu tán, miễn dịch kịch độc trong 60 giây!")
		"Ti Hoa Dan":
			target.set_meta("fire_resist_until", Time.get_unix_time_from_system() + 120.0)
			_Notify(target, "Uống [Tị Hỏa Đan]: Hỏa độc bất xâm, giảm 50% sát thương Hỏa hệ trong 120 giây!")
		"Truc Co Dan":
			target.set_meta("truc_co_breakthrough_buff", true)
			_Notify(target, "Uống [Trúc Cơ Đan]: Đan điền cố bản bồi nguyên, tăng 30% tỷ lệ đột phá và hộ thể khỏi cắn trả!")
		"Toi The Dan":
			var currentMax : int = target.stat.current.maxHealth
			target.stat.current.maxHealth = currentMax + 50
			target.stat.SetHealth(50)
			_Notify(target, "Uống [Tôi Thể Đan]: Gân cốt lột xác, Khí Huyết Tối Đa vĩnh viễn tăng +50 điểm!")
		"Xich Viem Dan":
			target.stat.buffs.Apply(CellCommons.Modifier.Attack, 40.0, 120.0)
			target.set_meta("xich_viem_burn_attack", true)
			_Notify(target, "Uống [Xích Viêm Đan]: Yêu hỏa thiêu đốt chân khí, Công Kích +40 và đòn đánh kèm hiệu ứng Thiêu Đốt!")

func _Notify(agent : BaseAgent, msg : String):
	if agent is PlayerAgent:
		Network.PushNotification(msg, agent.peerID)
