extends Node2D

func _ready():
	if not DB.isInitialized:
		print("Waiting for Launcher.dbInitialized...")
		await Launcher.dbInitialized
		
	print("=== VERIFYING SACRED SECT HUB REGISTRATION ===")
	var hub_hash = "SacredSectHub".hash()
	print("SacredSectHub hash: ", hub_hash)
	print("Maps in DB.MapsDB count: ", DB.MapsDB.size())
	for k in DB.MapsDB.keys():
		var m = DB.MapsDB[k]
		print(" - Map key: %s, name: %s" % [k, m._name if m else "null"])
	
	if hub_hash not in DB.MapsDB:
		print("FAILED: SacredSectHub not found in DB.MapsDB!")
		get_tree().quit(1)
		return
		
	var mapData : MapData = DB.MapsDB[hub_hash]
	print("SUCCESS: Found MapData: ", mapData._name)
	print("Layers path: ", mapData.layersPath)
	print("Server data: ", mapData.serverData)
	print("Navigation: ", mapData.navigation)
	
	# Try creating WorldMap
	var worldMap : WorldMap = WorldMap.Create(hub_hash)
	if not worldMap:
		print("FAILED: Could not create WorldMap for SacredSectHub!")
		get_tree().quit(1)
		return
		
	print("SUCCESS: WorldMap created: ", worldMap.name, ", instances: ", worldMap.instances.size())
	
	# Test loading map node via MapPool
	var pool = MapPool.new()
	var mapNode = pool.LoadMapLayers(hub_hash)
	if not mapNode:
		print("FAILED: Could not load mapNode from pool!")
		get_tree().quit(1)
		return
		
	var fringeNode = null
	for child in mapNode.get_children():
		if child is Node2D and child.name == "Fringe":
			fringeNode = child
			break
			
	if not fringeNode:
		print("FAILED: Fringe layer not found in SacredSectHub!")
		get_tree().quit(1)
		return
		
	print("SUCCESS: Fringe layer found with y_sort_enabled = ", fringeNode.y_sort_enabled)
	print("Fringe children count: ", fringeNode.get_child_count())
	print("ALL SACRED SECT HUB CHECKS PASSED!")
	get_tree().quit(0)
