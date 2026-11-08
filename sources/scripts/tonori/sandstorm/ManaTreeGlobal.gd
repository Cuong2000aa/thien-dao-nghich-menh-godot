extends NpcScript

const QUEST_ID : int = ProgressCommons.Quest.MINE_EXPLORATION

func PostInit():
	if npc and npc.spawnInfo:
		npc.spawnInfo.trigger_radius = 2000.0

func OnAreaEnter(player : PlayerAgent):
	var inst : WorldInstance = WorldAgent.GetInstanceFromAgent(npc)
	if not inst or inst.id != player.get_rid().get_id():
		return

	if player.progress.GetQuest(QUEST_ID) != ProgressCommons.MINE_EXPLORATION.STRANGER_SPOTTED:
		return

	SpawnXakelbael(inst)
	npc.RemoveTrigger()
	NpcCommons.PushNotification(player, "Đạo hữu cảm nhận năng lượng ấm bao bọc, hộ thể.")

func SpawnXakelbael(inst : WorldInstance):
	var spawn : SpawnObject = SpawnObject.new()
	spawn.map				= inst.map
	spawn.type				= ActorCommons.Type.NPC
	spawn.nick				= "Xakelbael"
	spawn.id				= spawn.nick.hash()
	spawn.spawn_position	= Vector2i(1331, 1478)
	spawn.spawn_offset		= Vector2i(5, 5)
	spawn.direction			= ActorCommons.Direction.UP
	spawn.state				= ActorCommons.State.IDLE
	spawn.behaviour			= AICommons.Behaviour.IMMOBILE
	spawn.trigger_radius	= 120.0
	spawn.own_script		= FileSystem.LoadScript("tonori/sandstorm/XakelbaelGlobal.gd")
	spawn.player_script		= FileSystem.LoadScript("tonori/sandstorm/Xakelbael.gd")
	spawn.is_persistant		= false
	spawn.respawn_delay		= 0.0
	WorldAgent.CreateAgent(spawn, inst.id)
