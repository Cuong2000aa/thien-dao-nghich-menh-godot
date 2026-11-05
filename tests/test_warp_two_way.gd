extends Node2D

func _ready():
	if not DB.isInitialized:
		print("Waiting for Launcher.dbInitialized...")
		await Launcher.dbInitialized
		
	print("=== EMPIRICALLY TESTING TWO-WAY WARP SYSTEM ===")
	var village_hash = "TanThuThon".hash()
	var hub_hash = "SacredSectHub".hash()
	
	# 1. Verify WorldService
	if not Launcher.World:
		print("Initializing World service on Server...")
		Launcher.Mode(false, false)
		
	var worldVillage = Launcher.World.GetMap(village_hash)
	var worldHub = Launcher.World.GetMap(hub_hash)
	
	assert(worldVillage != null, "WorldMap TanThuThon missing!")
	assert(worldHub != null, "WorldMap SacredSectHub missing!")
	
	print("WorldMap TanThuThon: ", worldVillage.name, " ID: ", worldVillage.id)
	print("WorldMap SacredSectHub: ", worldHub.name, " ID: ", worldHub.id)
	
	# 2. Check spawns in both maps
	print("TanThuThon Spawns: ", worldVillage.spawns.size())
	for s in worldVillage.spawns:
		print("  - Spawn: ", s.nick, ", trigger_radius: ", s.trigger_radius, ", dest_map: ", s.destination_map, ", dest_pos: ", s.destination_pos)
		assert(s.destination_map == hub_hash, "TanThuThon warp target must be SacredSectHub!")
		
	print("SacredSectHub Spawns: ", worldHub.spawns.size())
	for s in worldHub.spawns:
		print("  - Spawn: ", s.nick, ", trigger_radius: ", s.trigger_radius, ", dest_map: ", s.destination_map, ", dest_pos: ", s.destination_pos)
		assert(s.destination_map == village_hash, "SacredSectHub warp target must be TanThuThon!")
		
	# 3. Create a test PlayerAgent to execute warp
	var testSpawn = SpawnObject.new()
	testSpawn.map = worldVillage
	testSpawn.spawn_position = Vector2i(1600, 1300)
	testSpawn.type = ActorCommons.Type.PLAYER
	testSpawn.id = DB.PlayerHash
	testSpawn.nick = "TestDaoHuu"
	
	var playerAgent = WorldAgent.CreateAgent(testSpawn, 0, "TestDaoHuu")
	assert(playerAgent != null, "Could not create playerAgent for warp test!")
	await get_tree().process_frame
	await get_tree().process_frame
	print("Created PlayerAgent: ", playerAgent.nick, " in map: ", WorldAgent.GetMapFromAgent(playerAgent).name)
	assert(WorldAgent.GetMapFromAgent(playerAgent).id == village_hash, "Player did not spawn in TanThuThon!")
	
	# 4. Warp from TanThuThon -> SacredSectHub
	print("WARPING: TanThuThon -> SacredSectHub...")
	Launcher.World.Warp(playerAgent, worldHub, Vector2i(1000, 1400), ActorCommons.Direction.DOWN)
	
	# Wait a frame for tree entered
	await get_tree().process_frame
	
	var curMap = WorldAgent.GetMapFromAgent(playerAgent)
	print("Player position after warp 1: ", playerAgent.position, " in map: ", curMap.name)
	assert(curMap.id == hub_hash, "Player map is not SacredSectHub after warp!")
	assert(playerAgent.position == Vector2(1000, 1400), "Player position mismatch after warp 1!")
	print("PASS: TanThuThon -> SacredSectHub warp verified!")
	
	# 5. Warp from SacredSectHub -> TanThuThon
	print("WARPING: SacredSectHub -> TanThuThon...")
	Launcher.World.Warp(playerAgent, worldVillage, Vector2i(2650, 1260), ActorCommons.Direction.LEFT)
	
	await get_tree().process_frame
	
	curMap = WorldAgent.GetMapFromAgent(playerAgent)
	print("Player position after warp 2: ", playerAgent.position, " in map: ", curMap.name)
	assert(curMap.id == village_hash, "Player map is not TanThuThon after warp 2!")
	assert(playerAgent.position == Vector2(2650, 1260), "Player position mismatch after warp 2!")
	print("PASS: SacredSectHub -> TanThuThon return warp verified!")
	
	print("=== ALL TWO-WAY WARP VERIFICATIONS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)
