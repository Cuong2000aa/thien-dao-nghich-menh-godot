extends BaseAgent
class_name PlayerAgent

# Player-specific variables
var peerID : int						= NetworkCommons.PeerUnknownID
var lastStat : ActorStats				= ActorStats.new()
var triggerShape : CollisionShape2D		= CollisionShape2D.new()
var circleShape : CircleShape2D			= CircleShape2D.new()
var respawnDestination : Destination	= null
var exploreOrigin : Destination			= null
var ownScript : NpcScript				= null
var tradeSession : WorldTrade.Session	= null
var isWarping : bool					= false

# Regen
var regenTimer : Timer					= Timer.new()
var statsUpdatePending : bool			= false

# Visible surrounding actors
var visibleAgents : Dictionary[int, bool]= {}
var lastCheckedPosition : Vector2		= Vector2.ZERO
var visibilityTimer : Timer				= Timer.new()
var visibilityHalfSize : Vector2		= Vector2(NetworkCommons.MaxVisibilityHalfWidth, NetworkCommons.MaxVisibilityHalfHeight)

# Player-specific signals
signal warp_confirmed

#
static func GetActorType() -> ActorCommons.Type: return ActorCommons.Type.PLAYER

#
static func GetDestinationFromData(charData : Dictionary, destID : String, posXID : String, posYID : String) -> Destination:
	var mapID = charData.get(destID, DB.UnknownHash)
	var mapPosX = charData.get(posXID, 0)
	var mapPosY = charData.get(posYID, 0)
	var map : WorldMap = Launcher.World.GetMap(mapID) if mapID and mapID != DB.UnknownHash else null
	var pos : Vector2 = Vector2(mapPosX if mapPosX else 0, mapPosY if mapPosY else 0)
	return Destination.new(map.id if map else DB.UnknownHash, pos)

static func GetSpawnFromData(charData : Dictionary) -> SpawnObject:
	var destination : Destination = GetDestinationFromData(charData, "pos_map", "pos_x", "pos_y")
	if destination.mapID != DB.UnknownHash:
		var spawnLocation : SpawnObject = SpawnObject.new()
		spawnLocation.map				= Launcher.World.GetMap(destination.mapID)
		spawnLocation.spawn_position	= destination.pos
		spawnLocation.type				= ActorCommons.Type.PLAYER
		spawnLocation.id				= DB.PlayerHash
		return spawnLocation
	return WorldAgent.defaultSpawnLocation

static func GetRespawnFromData(charData : Dictionary) -> Destination:
	var destination : Destination = GetDestinationFromData(charData, "respawn_map", "respawn_x", "respawn_y")
	return destination if destination.mapID != DB.UnknownHash else Destination.new(WorldAgent.defaultSpawnLocation.map.id, LauncherCommons.GetRandomStartPos())

static func GetExploreFromData(charData : Dictionary) -> Destination:
	return GetDestinationFromData(charData, "explore_map", "explore_x", "explore_y")

func SetCharacterInfo(charData : Dictionary, charID : int):
	# Stats
	stat.SetStats(charData)
	stat.ResetAttributesIfOverBudget()
	# Inventory
	var inventoryData : Array[Dictionary] = Launcher.SQL.GetStorage(charID, 0)
	inventory.ImportInventory(inventoryData)
	# Equiped items
	var equipmentData : Dictionary = Launcher.SQL.GetEquipment(charID)
	inventory.ImportEquipment(equipmentData)
	# Respawn
	respawnDestination = GetRespawnFromData(charData)
	# Explore
	exploreOrigin = GetExploreFromData(charData)
	# Progress
	progress.ImportProgress(charID)
	RestoreActiveTrackers()

#
func UpdateLastStats():
	if peerID == NetworkCommons.PeerUnknownID:
		return

	if lastStat.level != stat.level or \
	lastStat.health != stat.health or \
	lastStat.hairstyle != stat.hairstyle or \
	lastStat.haircolor != stat.haircolor or \
	lastStat.gender != stat.gender or \
	lastStat.race != stat.race or \
	lastStat.skintone != stat.skintone or \
	lastStat.currentShape != stat.currentShape:
		var inst : WorldInstance = WorldAgent.GetInstanceFromAgent(self)
		if inst:
			Network.NotifyInstance(inst, "UpdatePublicStats", [get_rid().get_id(), stat.level, stat.health, stat.current.maxHealth, stat.hairstyle, stat.haircolor, stat.gender, stat.race, stat.skintone, stat.currentShape])
		if lastStat.level != 0 and lastStat.level < stat.level:
			Network.NotifyNeighbours(self, "LevelUp", [get_rid().get_id()])
		lastStat.level				= stat.level
		lastStat.health				= stat.health
		lastStat.hairstyle			= stat.hairstyle
		lastStat.haircolor			= stat.haircolor
		lastStat.gender				= stat.gender
		lastStat.race				= stat.race
		lastStat.skintone			= stat.skintone
		lastStat.currentShape		= stat.currentShape

	if lastStat.experience != stat.experience or \
	lastStat.gp != stat.gp or \
	lastStat.mana != stat.mana or \
	lastStat.stamina != stat.stamina or \
	lastStat.karma != stat.karma or \
	lastStat.weight != stat.weight or \
	lastStat.shape != stat.shape or \
	lastStat.spirit != stat.spirit:
		Network.UpdatePrivateStats(stat.experience, stat.gp, stat.mana, stat.stamina, stat.karma, stat.weight, stat.shape, stat.spirit, peerID)
		lastStat.level				= stat.level
		lastStat.experience			= stat.experience
		lastStat.gp					= stat.gp
		lastStat.health				= stat.health
		lastStat.mana				= stat.mana
		lastStat.stamina			= stat.stamina
		lastStat.karma				= stat.karma
		lastStat.weight				= stat.weight
		lastStat.shape				= stat.shape
		lastStat.spirit				= stat.spirit

	if lastStat.strength != stat.strength or \
	lastStat.vitality != stat.vitality or \
	lastStat.agility != stat.agility or \
	lastStat.endurance != stat.endurance or \
	lastStat.concentration != stat.concentration:
		Network.UpdateAttributes(stat.strength, stat.vitality, stat.agility, stat.endurance, stat.concentration, peerID)
		lastStat.strength			= stat.strength
		lastStat.vitality			= stat.vitality
		lastStat.agility			= stat.agility
		lastStat.endurance			= stat.endurance
		lastStat.concentration		= stat.concentration

func Morph(notifyMorphing : bool, morphID : int = DB.UnknownHash):
	if morphID == DB.UnknownHash:
		morphID = GetNextShapeID()

	var morphData : EntityData = DB.EntitiesDB.get(morphID, null)
	if morphData:
		stat.Morph(morphData)
		var inst : WorldInstance = WorldAgent.GetInstanceFromAgent(self)
		if inst:
			Network.NotifyInstance(inst, "Morphed", [get_rid().get_id(), morphID, notifyMorphing])


# Running
func SetRunning(enable : bool):
	if stat.isRunning != enable:
		if not enable or (stat.stamina > 0 and state == ActorCommons.State.WALK):
			stat.isRunning = enable
			RefreshWalkSpeed()
			requireFullUpdate = true

#
func OnRegenTick():
	UpdateDeltas(ActorCommons.RegenTickInterval)

func RequestStatsUpdate():
	if not statsUpdatePending:
		statsUpdatePending = true
		FlushStatsUpdate.call_deferred()

func FlushStatsUpdate():
	statsUpdatePending = false
	UpdateLastStats()

func CheckVisibility(neighbour : BaseAgent):
	if not neighbour or ActorCommons.IsInvisibleToPlayers(neighbour):
		return
	if NetworkCommons.IsAlwaysVisible(neighbour) or NetworkCommons.IsVisible(position, neighbour.position, visibilityHalfSize):
		var agentRID : int = neighbour.get_rid().get_id()
		if not visibleAgents.has(agentRID):
			Network.Bulk("FullUpdateEntity", [agentRID, neighbour.velocity, neighbour.position, neighbour.currentOrientation, neighbour.state, neighbour.currentSkillID, neighbour.stat.isRunning, NetworkCommons.FrameID()], peerID)
			neighbour.stat.buffs.NotifyAgent(peerID)
		visibleAgents[agentRID] = true

func UpdateVisibility():
	if peerID == NetworkCommons.PeerUnknownID:
		return
	var inst : WorldInstance = WorldAgent.GetInstanceFromAgent(self)
	if not inst:
		return

	# Pre-set every previously visible agents to false
	for agentRID in visibleAgents:
		visibleAgents[agentRID] = false

	# Set every visible agents to true
	for neighbour in inst.players:
		if neighbour != self:
			CheckVisibility(neighbour)
	for neighbour in inst.npcs:
		if neighbour and neighbour.isVisible:
			CheckVisibility(neighbour)
	for neighbour in inst.mobs:
		CheckVisibility(neighbour)

	# Remove any previously visible agents that just disapeared
	for agentRID in visibleAgents:
		if not visibleAgents[agentRID]:
			Network.Bulk("RemoveEntity", [agentRID], peerID)
			visibleAgents.erase(agentRID)

func NotifyPosition():
	super.NotifyPosition()
	if position.distance_squared_to(lastCheckedPosition) >= ActorCommons.VisibilityCheckDistSqrd:
		lastCheckedPosition = position
		UpdateVisibility()

# Override
func SetData():
	super.SetData()
	circleShape.radius = data._radius

func _ready():
	super._ready()

	collision_mask = 0
	triggerShape.set_name("TriggerShape")
	circleShape.radius = 1.0
	triggerShape.shape = circleShape
	add_child.call_deferred(triggerShape)

	regenTimer.set_name("RegenTimer")
	regenTimer.set_one_shot(false)
	regenTimer.set_wait_time(ActorCommons.RegenTickInterval)
	regenTimer.autostart = true
	regenTimer.timeout.connect(OnRegenTick)
	add_child.call_deferred(regenTimer)

	visibilityTimer.set_name("VisibilityTimer")
	visibilityTimer.set_one_shot(false)
	visibilityTimer.set_wait_time(ActorCommons.VisibilityCheckTimeInternal)
	visibilityTimer.autostart = true
	visibilityTimer.timeout.connect(UpdateVisibility)
	add_child.call_deferred(visibilityTimer)

	stat.entity_stats_updated.connect(RequestStatsUpdate)
	stat.vital_stats_updated.connect(RequestStatsUpdate)
	enemy_killed.connect(_OnEnemyKilled)

func _OnEnemyKilled(_killer : BaseAgent, monsterID : int):
	var maggotID : int = "Maggot".hash()
	var bossID : int = "Xich Viem Thu Hau".hash()
	var giantMaggotID : int = "Giant Maggot".hash()
	
	if monsterID == maggotID and progress:
		var questID : int = ProgressCommons.Quest.THANH_TRU_LINH_TRUNG
		var qState : int = progress.GetQuest(questID)
		if qState >= ProgressCommons.THANH_TRU_LINH_TRUNG.STARTED and qState < ProgressCommons.THANH_TRU_LINH_TRUNG.OBJECTIVE_MET:
			qState += 1
			progress.SetQuest(questID, qState)
			var kills : int = mini(qState - 1, 5)
			NpcCommons.PushTracker(self, "Tiêu diệt Linh Trùng", kills, 5)
			if qState >= ProgressCommons.THANH_TRU_LINH_TRUNG.OBJECTIVE_MET:
				NpcCommons.PushNotification(self, "Hoàn thành mục tiêu: Tiêu diệt 5 Linh Trùng! Hãy trở về gặp Đạo Huyền Trưởng Lão.")
			else:
				NpcCommons.PushNotification(self, "Tiêu diệt Linh Trùng: %d/5" % kills)
				
	elif (monsterID == bossID or monsterID == giantMaggotID) and progress:
		var questID : int = ProgressCommons.Quest.THAO_PHAT_THU_VUONG
		var qState : int = progress.GetQuest(questID)
		if qState == ProgressCommons.THAO_PHAT_THU_VUONG.STARTED:
			progress.SetQuest(questID, ProgressCommons.THAO_PHAT_THU_VUONG.BOSS_SLAIN)
			NpcCommons.PushTracker(self, "Tiêu diệt Xích Viêm Thú Hậu", 1, 1)
			NpcCommons.PushNotification(self, "Đại thắng! Đã tiêu diệt Xích Viêm Thú Hậu! Hãy trở về bẩm báo Đạo Huyền Trưởng Lão.")

func RestoreActiveTrackers():
	if progress:
		var q1 : int = progress.GetQuest(ProgressCommons.Quest.THANH_TRU_LINH_TRUNG)
		if q1 >= ProgressCommons.THANH_TRU_LINH_TRUNG.STARTED and q1 < ProgressCommons.THANH_TRU_LINH_TRUNG.COMPLETED:
			var kills : int = mini(q1 - 1, 5)
			NpcCommons.PushTracker(self, "Tiêu diệt Linh Trùng", kills, 5)
			return
			
		var q2 : int = progress.GetQuest(ProgressCommons.Quest.THU_THAP_LINH_THAO)
		if q2 >= ProgressCommons.THU_THAP_LINH_THAO.STARTED and q2 < ProgressCommons.THU_THAP_LINH_THAO.COMPLETED:
			var herbs : int = mini(q2 - 1, 3)
			NpcCommons.PushTracker(self, "Thu thập Ngân Linh Thảo", herbs, 3)
			return
			
		var q3 : int = progress.GetQuest(ProgressCommons.Quest.LUYEN_DAN_NHAP_MON)
		if q3 == ProgressCommons.LUYEN_DAN_NHAP_MON.STARTED:
			NpcCommons.PushTracker(self, "Luyện Đan Nhập Môn", 0, 1)
			return
			
		var q4 : int = progress.GetQuest(ProgressCommons.Quest.KHAM_PHA_CO_BI)
		if q4 == ProgressCommons.KHAM_PHA_CO_BI.STARTED:
			NpcCommons.PushTracker(self, "Khám Phá Cổ Bi", 0, 1)
			return
			
		var q5 : int = progress.GetQuest(ProgressCommons.Quest.THAO_PHAT_THU_VUONG)
		if q5 == ProgressCommons.THAO_PHAT_THU_VUONG.STARTED:
			NpcCommons.PushTracker(self, "Tiêu diệt Xích Viêm Thú Hậu", 0, 1)
			return
			
		var q6 : int = progress.GetQuest(ProgressCommons.Quest.THU_THAP_KHOANG_THACH)
		if q6 >= ProgressCommons.THU_THAP_KHOANG_THACH.STARTED and q6 < ProgressCommons.THU_THAP_KHOANG_THACH.COMPLETED:
			var ores : int = mini(q6 - 1, 2)
			NpcCommons.PushTracker(self, "Khai thác Huyền Thiết", ores, 2)
			return

func _exit_tree():
	ClearScript()
	WorldTrade.Cancel(self, "Trade cancelled, %s left." % nick)
	super._exit_tree()

#
func Respawn():
	if Revive():
		WarpTo(respawnDestination)

func Explore():
	if ActorCommons.IsAlive(self):
		var map : WorldMap = WorldAgent.GetMapFromAgent(self)
		if map and map.HasFlags(WorldMap.Flags.ONLY_SPIRIT):
			if stat.IsSailing():
				exploreOrigin.mapID = map.id
				exploreOrigin.pos = position
				WarpTo(ActorCommons.SailingDestination)

func WarpTo(dest : Destination):
	var nextMap : WorldMap = Launcher.World.GetMap(dest.mapID)
	if nextMap:
		Launcher.World.Warp(self, nextMap, dest.pos, ActorCommons.Direction.UNKNOWN, dest.instance)

func Killed():
	super.Killed()
	WorldTrade.Cancel(self, "Trade cancelled.")
	if ownScript:
		ClearScript()
		NpcCommons.ToggleContext(self, false)

func UpdateDeltas(delta : float):
	if ActorCommons.IsRunning(self):
		stat.deltaStamina -= ActorCommons.RunningStaminaCostPerSecond * delta
		if (stat.stamina + stat.deltaStamina) <= 0.0:
			SetRunning(false)
	super.UpdateDeltas(delta)

#
func AddScript(npc : NpcAgent):
	if npc:
		WorldTrade.Cancel(self, "Trade cancelled.")
		SetRelativeMode(false, Vector2.ZERO)
		ownScript = npc.playerScriptPreset.new(npc, self) if npc.playerScriptPreset else NpcScript.new(npc, self)
		ownScript.PostInit()

func ClearScript():
	if ownScript:
		ownScript.OnQuit()
		ownScript = null
