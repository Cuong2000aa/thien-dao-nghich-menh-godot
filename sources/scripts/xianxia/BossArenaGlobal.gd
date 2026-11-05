extends NpcScript
class_name BossArenaGlobal

const RETURN_MAP_ID : int = 995840901 # SacredSectHub (Trúc Sơn Tiên Cảnh)
const RETURN_POS : Vector2 = Vector2(850, 1350)

var bossAgent : MonsterAgent = null
var currentPhase : int = 1
var arenaPlayer : PlayerAgent = null

func OnAreaEnter(player : PlayerAgent):
	if player and not player.ownScript and not player.isWarping:
		arenaPlayer = player
		if not bossAgent or not is_instance_valid(bossAgent) or not ActorCommons.IsAlive(bossAgent):
			SpawnBoss(player)

func SpawnBoss(player : PlayerAgent):
	currentPhase = 1
	var bossID : int = 834389329 # BossRedQueen (Xích Viêm Thú Hậu)
	if not DB.EntitiesDB.has(bossID):
		bossID = DB.GetCellHash("Giant Maggot")
		
	var inst : WorldInstance = WorldAgent.GetInstanceFromAgent(player) if player else null
	if not inst:
		var arenaMap = Launcher.World.GetMap(4111682275) # Candor Arena
		if not arenaMap:
			arenaMap = Launcher.World.GetMap(Launcher.Map.currentMapID)
		if arenaMap and arenaMap.instances.has(0):
			inst = arenaMap.instances[0]
			
	if inst and inst.map:
		var spawnObject : SpawnObject = SpawnObject.new()
		spawnObject.map = inst.map
		spawnObject.type = ActorCommons.Type.MONSTER
		spawnObject.id = bossID
		spawnObject.count = 1
		spawnObject.spawn_position = Vector2i(1744, 1851)
		var agent = WorldAgent.CreateAgent(spawnObject, inst.id)
		if agent and agent is MonsterAgent:
			bossAgent = agent
			bossAgent.agent_killed.connect(OnBossKilled)
			if bossAgent.stat:
				bossAgent.stat.vital_stats_updated.connect(OnBossStatsUpdated)
			AI.Refresh(bossAgent)
			if player:
				NpcCommons.PushNotification(player, "CẢNH BÁO: Xích Viêm Thú Hậu đã xuất hiện trong Bí Cảnh!")

func OnBossStatsUpdated():
	if not bossAgent or not is_instance_valid(bossAgent) or not ActorCommons.IsAlive(bossAgent):
		return
	var hp : int = bossAgent.stat.health
	var maxHp : int = bossAgent.stat.current.maxHealth
	var hpPercent : float = float(hp) / float(maxHp) if maxHp > 0 else 0.0
	
	if currentPhase == 1 and hpPercent <= 0.5:
		currentPhase = 2
		var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
		CombatVisualSystemClass.TriggerBossEnrageVfx(bossAgent)
		if arenaPlayer:
			NpcCommons.PushNotification(arenaPlayer, "GIAI ĐOẠN 2: Xích Viêm Thú Hậu cuồng nộ gầm thét, triệu hồi Yêu Trùng hộ giá!")
		# Spawn 2 minion maggots around boss
		var maggotID : int = 3264333316 # Maggot entity id
		var minionInst : WorldInstance = WorldAgent.GetInstanceFromAgent(bossAgent)
		if minionInst and minionInst.map:
			var sp : SpawnObject = SpawnObject.new()
			sp.map = minionInst.map
			sp.type = ActorCommons.Type.MONSTER
			sp.id = maggotID
			sp.count = 2
			sp.spawn_position = Vector2i(bossAgent.position)
			WorldAgent.CreateAgent(sp, minionInst.id)
		# Enrage boss speed
		bossAgent.stat.current.walkSpeed += 30.0
		TriggerTelegraphedAttack()
	elif currentPhase == 2 and hpPercent <= 0.2:
		currentPhase = 3
		var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
		CombatVisualSystemClass.TriggerBossEnrageVfx(bossAgent)
		if arenaPlayer:
			NpcCommons.PushNotification(arenaPlayer, "GIAI ĐOẠN 3: Xích Viêm Thú Hậu thiêu đốt yêu đan, cuồng bạo hấp hối!")
		bossAgent.stat.current.attack += 15
		TriggerTelegraphedAttack()

func TriggerTelegraphedAttack():
	if not bossAgent or not is_instance_valid(bossAgent) or not ActorCommons.IsAlive(bossAgent):
		return
	if arenaPlayer:
		NpcCommons.PushNotification(arenaPlayer, "CẢNH BÁO NGUY HIỂM: Xích Viêm Thú Hậu súc tích hỏa diễm, chuẩn bị thi triển [Xích Viêm Liệt Địa]!")
	
	var CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
	var inst : WorldInstance = WorldAgent.GetInstanceFromAgent(bossAgent)
	var bossPos : Vector2 = bossAgent.position
	
	# Spawn telegraphed circle
	CombatSystemClass.CreateDangerTelegraph(bossAgent.get_parent(), bossPos, 120.0, 1.2, func():
		# Detonation effect
		if arenaPlayer and is_instance_valid(arenaPlayer) and ActorCommons.IsAlive(arenaPlayer):
			var distSq : float = arenaPlayer.position.distance_squared_to(bossPos)
			if distSq <= (120.0 * 120.0):
				if CombatSystemClass.IsInvulnerable(arenaPlayer):
					NpcCommons.PushNotification(arenaPlayer, "NÉ TRÁNH THÀNH CÔNG! Đạo hữu dùng thân pháp né tránh trọn vẹn [Xích Viêm Liệt Địa]!")
				else:
					arenaPlayer.stat.SetHealth(-45)
					NpcCommons.PushNotification(arenaPlayer, "TRÚNG ĐÒN! Đạo hữu bị sóng nhiệt [Xích Viêm Liệt Địa] oanh kích, mất 45 Khí Huyết!")
					if Launcher.Camera and Launcher.Camera.camera:
						Launcher.Camera.camera.offset = Vector2(randf_range(-6, 6), randf_range(-6, 6))
	)

func OnBossKilled(mob : BaseAgent):
	bossAgent = null
	var CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
	CombatVisualSystemClass.TriggerCameraShake(CombatVisualSystemClass.ShakeLevel.BOSS, 12.0, 0.4)
	if arenaPlayer and is_instance_valid(arenaPlayer):
		var qID : int = ProgressCommons.Quest.THAO_PHAT_THU_VUONG
		var state : int = arenaPlayer.progress.GetQuest(qID)
		if state == ProgressCommons.THAO_PHAT_THU_VUONG.STARTED:
			NpcCommons.SetQuest(arenaPlayer, qID, ProgressCommons.THAO_PHAT_THU_VUONG.BOSS_SLAIN)
			NpcCommons.PushTracker(arenaPlayer, "Thảo Phạt Thú Vương", 1, 1)
		
		# Specialized Boss Artifact Drops (Build 05 & Build 07)
		var baoChauHash = DB.GetCellHash("Xich Viem Bao Chau")
		var baoChauCell = DB.GetItem(baoChauHash)
		if baoChauCell:
			arenaPlayer.inventory.AddItem(baoChauCell, 1)
		var biKipHash = DB.GetCellHash("Thanh Phong Bi Kip")
		var biKipCell = DB.GetItem(biKipHash)
		if biKipCell:
			arenaPlayer.inventory.AddItem(biKipCell, 1)
		var yeuDanHash = DB.GetCellHash("Xich Viem Yeu Dan")
		var yeuDanCell = DB.GetItem(yeuDanHash)
		if yeuDanCell:
			arenaPlayer.inventory.AddItem(yeuDanCell, 1)
		var khoangHash = DB.GetCellHash("Xich Viem Khoang")
		var khoangCell = DB.GetItem(khoangHash)
		if khoangCell:
			arenaPlayer.inventory.AddItem(khoangCell, 2)
		
		NpcCommons.PushNotification(arenaPlayer, "CHIẾN THẮNG! Xích Viêm Thú Hậu đã bị tiêu diệt! Nhận được [Xích Viêm Yêu Đan], [Xích Viêm Khoáng], [Xích Viêm Bảo Châu] và [Thanh Phong Bí Kíp]!")
		# Add boss defeat to bestiary
		if mob and mob.data:
			NpcCommons.AddBestiary(arenaPlayer, mob.data._id, 1)

func OnStart():
	if not IsPlayer():
		return
	Mes("Trận pháp truyền tống rời khỏi Linh Khí Bí Cảnh. Đạo hữu có muốn trở về Trúc Sơn Tiên Cảnh?")
	Choice("Trở về Trúc Sơn Tiên Cảnh", ReturnToHub)
	Choice("Ở lại bí cảnh")

func ReturnToHub():
	if arenaPlayer and is_instance_valid(arenaPlayer):
		NpcCommons.PushNotification(arenaPlayer, "Đang truyền tống về Trúc Sơn Tiên Cảnh...")
		NpcCommons.Warp(arenaPlayer, RETURN_MAP_ID, RETURN_POS, ActorCommons.Direction.DOWN)
	elif own and is_instance_valid(own):
		NpcCommons.PushNotification(own, "Đang truyền tống về Trúc Sơn Tiên Cảnh...")
		NpcCommons.Warp(own, RETURN_MAP_ID, RETURN_POS, ActorCommons.Direction.DOWN)
