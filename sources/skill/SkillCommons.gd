extends RefCounted
class_name SkillCommons

const CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")

# Constants
const SkillMeleeName : String			= "Melee"
const SkillRunName : String				= "Run"
const PerspectiveIncrease : Vector2		= Vector2(1.0, 1.42)

# Actions
static func TryConsume(agent : BaseAgent, modifier : CellCommons.Modifier, skill : SkillCell) -> bool:
	if agent is not PlayerAgent:
		return true

	match modifier:
		CellCommons.Modifier.Health:
			var exhaust : int = skill.modifiers.Get(modifier)
			if agent.stat.health >= -exhaust:
				agent.stat.SetHealth(exhaust)
				return true
		CellCommons.Modifier.Mana:
			var exhaust : int = skill.modifiers.Get(modifier)
			if agent.stat.mana >= -exhaust:
				agent.stat.SetMana(exhaust)
				return true
		CellCommons.Modifier.Stamina:
			var exhaust : int = skill.modifiers.Get(modifier)
			if agent.stat.stamina >= -exhaust:
				agent.stat.SetStamina(exhaust)
				return true
	return false

static func GetDamage(agent : BaseAgent, target : BaseAgent, skill : SkillCell, rng : float) -> Skill.AlterationInfo:
	var info : Skill.AlterationInfo = Skill.AlterationInfo.new()
	var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")

	# Check Invulnerability (e.g. from Đạp Phong Bộ / dodge iframe)
	if CombatSystemClass.IsInvulnerable(target):
		info.type = ActorCommons.Alteration.DODGE
		info.value = 0
		return info

	# Debounce double-damage protection
	var aRID : int = agent.get_rid().get_id()
	var tRID : int = target.get_rid().get_id()
	var hitKey : String = "%d_%d_%d" % [aRID, tRID, skill.id]
	var now : float = Time.get_ticks_msec() / 1000.0
	if CombatSystemClass.lastHitTimestamps.has(hitKey) and (now - CombatSystemClass.lastHitTimestamps[hitKey]) < 0.15:
		info.type = ActorCommons.Alteration.MISS
		info.value = 0
		return info
	CombatSystemClass.lastHitTimestamps[hitKey] = now

	# Base calculation
	var skillValue : int = skill.modifiers.Get(CellCommons.Modifier.MAttack)
	var baseDmg : float = 0.0
	if skillValue > 0:
		baseDmg = maxf(1.0, float(agent.stat.current.mattack + skillValue - target.stat.current.mdefense))
	else:
		skillValue = skill.modifiers.Get(CellCommons.Modifier.Attack)
		baseDmg = maxf(1.0, float(agent.stat.current.attack + skillValue - target.stat.current.defense))

	# Sword Cultivation: Sword Intent bonus
	var swordIntent = CombatSystemClass.GetSwordIntentBonus(agent)
	baseDmg += swordIntent["attackBonus"]

	# Combo System: If standard attack/melee, advance combo
	if skill.name == SkillMeleeName or skill.id == 229218829:
		var comboRes = CombatSystemClass.AdvanceCombo(agent)
		baseDmg *= comboRes["damageRatio"]

	# Five Elements: Evaluate counter & root synergy
	var skillElem : int = CombatSystemClass.Element.WOOD if (skill.name.contains("Thanh Phong") or skill.name.contains("Truc Son")) else CombatSystemClass.Element.NONE
	var targetElem : int = CombatSystemClass.Element.NONE
	if target.data:
		if target.data._isBoss:
			targetElem = CombatSystemClass.Element.FIRE
		elif target.data._id == 3264333316:
			targetElem = CombatSystemClass.Element.WOOD
		else:
			targetElem = CombatSystemClass.Element.EARTH

	var elemEval = CombatSystemClass.EvaluateElementalInteraction(skillElem, targetElem)
	baseDmg *= elemEval["multiplier"]

	var rootSynergy = CombatSystemClass.EvaluateRootSynergy(agent, skillElem)
	if rootSynergy["matched"]:
		baseDmg *= (1.0 + rootSynergy["damageBonus"])

	# Hit / Dodge / Crit
	var evadeRate : float = Formula.GetEvadeRate(agent.stat, target.stat)
	var effectiveCrit : float = agent.stat.current.critRate + swordIntent["critRateBonus"]

	if randf() < evadeRate:
		info.type = ActorCommons.Alteration.DODGE
		info.value = 0
	elif randf() < effectiveCrit:
		info.type = ActorCommons.Alteration.CRIT
		info.value = maxi(1, int(round(baseDmg * 2.0)))
	else:
		info.type = ActorCommons.Alteration.HIT
		info.value = maxi(1, int(round(baseDmg * rng)))

	return info

static func GetHeal(agent : BaseAgent, target : BaseAgent, skill : SkillCell, rng : float) -> int:
	var skillValue : int = skill.modifiers.Get(CellCommons.Modifier.Health)
	var healValue : int = int(agent.stat.concentration + skillValue * rng)
	healValue = min(healValue, target.stat.current.maxHealth - target.stat.health)
	return healValue

static func GetZoneTargets(instance : WorldInstance, zonePos : Vector2, skill : SkillCell) -> Array[BaseAgent]:
	var targets : Array[BaseAgent] = []

	if skill.modifiers.Get(CellCommons.Modifier.Attack) != 0 or skill.modifiers.Get(CellCommons.Modifier.MAttack) != 0:
		for neighbour in instance.mobs:
			var filteredRange : float = skill.skillRange + neighbour.data._radius
			if ActorCommons.IsAlive(neighbour) and Util.IsReachableSquared(neighbour.position, zonePos, filteredRange * filteredRange):
				targets.append(neighbour)
	if skill.modifiers.Get(CellCommons.Modifier.Health) != 0:
		for neighbour in instance.players:
			var filteredRange : float = skill.skillRange + neighbour.data._radius
			if ActorCommons.IsAlive(neighbour) and Util.IsReachableSquared(neighbour.position, zonePos, filteredRange * filteredRange):
				targets.append(neighbour)

	return targets

static func GetSurroundingTargets(agent : BaseAgent, skill : SkillCell) -> Array[BaseAgent]:
	var targets : Array[BaseAgent] = []
	var instance : WorldInstance = WorldAgent.GetInstanceFromAgent(agent)

	if instance:
		if skill.modifiers.Get(CellCommons.Modifier.Attack) != 0 or skill.modifiers.Get(CellCommons.Modifier.MAttack) != 0:
			for neighbour in instance.mobs:
				if IsAttackable(agent, neighbour, skill):
					targets.append(neighbour)
		if skill.modifiers.Get(CellCommons.Modifier.Health) != 0:
			for neighbour in instance.players:
				if IsAttackable(agent, neighbour, skill):
					targets.append(neighbour)

	return targets

static func GetRNG(hasStamina : bool) -> float:
	return randf_range(0.9 if hasStamina else 0.1, 1.0)

# Checks
static func IsNear(agent : BaseAgent, target : BaseAgent, skillRange : int) -> bool:
	var filteredRange : float = skillRange + agent.data._radius + target.data._radius
	var distanceSquared : float = 0.0
	if not target.agent:
		distanceSquared = ActorCommons.GetDistanceSquared(agent, target.position)
	else:
		distanceSquared = WorldNavigation.GetDistanceSquaredSafe(agent, target.position)
	return distanceSquared <= filteredRange * filteredRange

static func IsSameMap(agent : BaseAgent, target : BaseAgent) -> bool:
	return WorldAgent.GetMapFromAgent(agent) == WorldAgent.GetMapFromAgent(target)

static func IsSameInstance(agent : BaseAgent, target : BaseAgent) -> bool:
	return WorldAgent.GetInstanceFromAgent(agent) == WorldAgent.GetInstanceFromAgent(target)

static func IsAttackable(agent : BaseAgent, target : BaseAgent, skill : SkillCell) -> bool:
	return IsInteractable(agent, target) and IsNear(agent, target, ActorCommons.GetSkillRange(agent, skill))

static func IsTargetable(agent : BaseAgent, target : BaseAgent) -> bool:
	return IsInteractable(agent, target) and IsNear(agent, target, ActorCommons.TargetMaxDistance)

static func IsInteractable(agent : BaseAgent, target : BaseAgent) -> bool:
	return not ActorCommons.IsSameActor(agent, target) and ActorCommons.IsAlive(target) and IsSameInstance(agent, target)

static func IsStaticCasting(agent : BaseAgent) -> bool:
	return agent.currentSkillID != DB.UnknownHash and not DB.SkillsDB[agent.currentSkillID].castWalk

static func IsCasting(agent : BaseAgent, skill : SkillCell = null) -> bool:
	return (agent.currentSkillID == skill.id) if skill else DB.SkillsDB.has(agent.currentSkillID)

static func IsCoolingDown(agent : BaseAgent, skill : SkillCell) -> bool:
	return agent.cooldownTimers.get(skill.id, false)

static func GetCooldown(actor : Actor, skill : SkillCell) -> float:
	return actor.stat.current.cooldownAttackDelay + skill.cooldownTime

static func IsDelayed(skill : SkillCell) -> bool:
	return skill.projectilePreset != null

static func HasSkill(agent : BaseAgent, skill : SkillCell) -> bool:
	if agent.progress:
		return agent.progress.HasSkill(skill)
	if agent is AIAgent:
		return skill != null and skill.id in agent.aiSkills
	return false

static func IsInstantAbility(skill : SkillCell) -> bool:
	return skill.category == SkillCell.Category.ABILITY and not skill.modifiers.HasAny() and skill.castTime == 0.0 and skill.cooldownTime == 0.0

static func HasAnyActionInProgress(agent : BaseAgent) -> bool:
	return agent.currentSkillID != DB.UnknownHash or not agent.actionTimer.is_stopped()
