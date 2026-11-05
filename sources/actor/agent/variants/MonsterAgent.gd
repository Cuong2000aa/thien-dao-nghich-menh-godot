extends AIAgent
class_name MonsterAgent

#
static func GetActorType() -> ActorCommons.Type: return ActorCommons.Type.MONSTER

func IsDropCell(cell : ItemCell) -> bool:
	if cell:
		for dropCell in data._drops:
			if dropCell and dropCell.id == cell.id and dropCell.customfield == cell.customfield:
				return true
	return false

func Killed():
	super.Killed()
	Formula.ApplyXp(self)

	# Iterate from last to first to keep idx linear even with dropped items
	for idx in range(inventory.items.size() - 1, -1, -1):
		var item : Item = inventory.items[idx]
		if item:
			var cell : ItemCell = DB.GetItem(item.cellID, item.cellCustomfield)
			if IsDropCell(cell):
				inventory.DropItem(cell, item.count, idx)

	var inst : WorldInstance = WorldAgent.GetInstanceFromAgent(self)
	if inst and inst.timers:
		Callback.SelfDestructTimer(inst.timers, ActorCommons.DeathDelay, WorldAgent.RemoveAgent, [self])

func _ready():
	inventory = ActorInventory.new(self)
	super._ready()
	AddSkill(DB.SkillsDB[DB.GetCellHash(SkillCommons.SkillMeleeName)], 1.0)
	
	# Build 05: Diverse Monster AI & Boss Skill Arsenal
	if data:
		# Maggots / Venom spiders get ranged poison spit
		if data._id == 3264333316 or data._isBoss:
			var poisonHash = DB.GetCellHash("Poison")
			if DB.SkillsDB.has(poisonHash):
				AddSkill(DB.SkillsDB[poisonHash], 0.4)
		# Bosses get AoE burst & sonic roar
		if data._isBoss:
			var burstHash = DB.GetCellHash("Mana Burst")
			if DB.SkillsDB.has(burstHash):
				AddSkill(DB.SkillsDB[burstHash], 0.5)
			var roarHash = DB.GetCellHash("Sonic Wave")
			if DB.SkillsDB.has(roarHash):
				AddSkill(DB.SkillsDB[roarHash], 0.3)
