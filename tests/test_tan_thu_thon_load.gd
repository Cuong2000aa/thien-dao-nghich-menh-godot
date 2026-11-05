extends Node2D

func _ready():
	if not DB.isInitialized:
		print("Waiting for Launcher.dbInitialized...")
		await Launcher.dbInitialized
		
	print("=== VERIFYING THANH VAN THON REGISTRATION ===")
	var village_hash = "TanThuThon".hash()
	var hub_hash = "SacredSectHub".hash()
	print("TanThuThon hash: ", village_hash)
	print("SacredSectHub hash: ", hub_hash)
	print("Total maps in DB.MapsDB: ", DB.MapsDB.size())
	
	if village_hash not in DB.MapsDB:
		print("FAILED: TanThuThon not found in DB.MapsDB!")
		get_tree().quit(1)
		return
		
	var mapData : MapData = DB.MapsDB[village_hash]
	print("SUCCESS: Found MapData: ", mapData._name)
	print("Layers path: ", mapData.layersPath)
	print("Server data: ", mapData.serverData)
	print("Navigation: ", mapData.navigation)
	
	# Verify server data spawns
	if not mapData.serverData:
		print("FAILED: TanThuThon missing serverData!")
		get_tree().quit(1)
		return
		
	print("TanThuThon spawns count: ", mapData.serverData.spawns.size())
	if mapData.serverData.spawns.is_empty():
		print("FAILED: TanThuThon has no spawns (expected Warp to SacredSectHub)!")
		get_tree().quit(1)
		return
		
	var warpToHub : SpawnObject = mapData.serverData.spawns[0]
	print("Warp 0: nick=", warpToHub.nick, ", id=", warpToHub.id, ", dest_map=", warpToHub.destination_map, ", dest_pos=", warpToHub.destination_pos)
	assert(warpToHub.destination_map == hub_hash, "Warp destination does not point to SacredSectHub!")
	
	# Verify SacredSectHub has warp to TanThuThon
	var hubData : MapData = DB.MapsDB[hub_hash]
	print("SacredSectHub spawns count: ", hubData.serverData.spawns.size())
	assert(not hubData.serverData.spawns.is_empty(), "SacredSectHub missing warp spawn!")
	var warpToVillage : SpawnObject = hubData.serverData.spawns[0]
	print("Hub Warp 0: nick=", warpToVillage.nick, ", dest_map=", warpToVillage.destination_map, ", dest_pos=", warpToVillage.destination_pos)
	assert(warpToVillage.destination_map == village_hash, "Hub warp destination does not point to TanThuThon!")
	
	# Test creating WorldMap for both
	var worldVillage : WorldMap = WorldMap.Create(village_hash)
	if not worldVillage:
		print("FAILED: Could not create WorldMap for TanThuThon!")
		get_tree().quit(1)
		return
	print("SUCCESS: WorldMap TanThuThon created, instances: ", worldVillage.instances.size(), ", spawns: ", worldVillage.spawns.size())
	
	var worldHub : WorldMap = WorldMap.Create(hub_hash)
	if not worldHub:
		print("FAILED: Could not create WorldMap for SacredSectHub!")
		get_tree().quit(1)
		return
	print("SUCCESS: WorldMap SacredSectHub created, instances: ", worldHub.instances.size(), ", spawns: ", worldHub.spawns.size())
	
	# Test loading map node via MapPool
	var pool = MapPool.new()
	var mapNode = pool.LoadMapLayers(village_hash)
	if not mapNode:
		print("FAILED: Could not load TanThuThon mapNode from pool!")
		get_tree().quit(1)
		return
		
	var fringeNode = null
	for child in mapNode.get_children():
		if child is Node2D and child.name == "Fringe":
			fringeNode = child
			break
			
	if not fringeNode:
		print("FAILED: Fringe layer not found in TanThuThon!")
		get_tree().quit(1)
		return
		
	print("SUCCESS: Fringe layer found with y_sort_enabled = ", fringeNode.y_sort_enabled)
	print("Fringe children count: ", fringeNode.get_child_count())
	print("MapBoundaries metadata: ", mapNode.get_meta("MapBoundaries", Vector2.ZERO))
	
	# Clean up
	mapNode.queue_free()
	
	print("ALL THANH VAN THON AND TWO-WAY WARP VERIFICATIONS PASSED!")
	get_tree().quit(0)
