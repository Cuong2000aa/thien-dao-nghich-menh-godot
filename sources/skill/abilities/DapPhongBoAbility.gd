extends CellScript
class_name DapPhongBoAbility

func Execute(target : BaseAgent, _cell : BaseCell):
	if not target or not target.stat:
		return
	var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
	CombatSystemClass.SetInvulnerable(target, 0.4)
	
	# Dash movement in current orientation
	var dashDir : Vector2 = target.currentOrientation
	if dashDir.is_zero_approx():
		dashDir = Vector2.DOWN
	target.position += dashDir * 80.0
	
	# Speed buff for 2.5s
	if target.stat.buffs:
		target.stat.buffs.Apply(CellCommons.Modifier.WalkSpeed, 50.0, 2.5)
	
	if target is PlayerAgent:
		NpcCommons.PushNotification(target, "Đạp Phong Bộ: Thân như ngự phong, vô ảnh vô hình!")
