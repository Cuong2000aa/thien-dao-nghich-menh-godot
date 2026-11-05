extends Node2D

func _ready():
	if not DB.isInitialized:
		await Launcher.dbInitialized
		
	print("=== DB.MapsDB TOTAL MAPS: ", DB.MapsDB.size(), " ===")
	var output = []
	for map_id in DB.MapsDB:
		var md : MapData = DB.MapsDB[map_id]
		var warps = []
		if md.serverData and md.serverData.spawns:
			for spawn in md.serverData.spawns:
				if spawn.destination_map != 0:
					var dest_name = "UNKNOWN"
					if spawn.destination_map in DB.MapsDB:
						dest_name = DB.MapsDB[spawn.destination_map]._name
					warps.append({
						"nick": spawn.nick,
						"dest_id": spawn.destination_map,
						"dest_name": dest_name,
						"dest_pos": [spawn.destination_pos.x, spawn.destination_pos.y]
					})
		var entry = {
			"id": map_id,
			"name": md._name,
			"layersPath": md.layersPath,
			"serverData": md.serverData.resource_path if md.serverData else "",
			"navigation": md.navigation.resource_path if md.navigation else "",
			"minimapPath": md.minimapPath,
			"warps": warps
		}
		output.append(entry)
		
	var f = FileAccess.open("res://tests/all_maps_dump.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(output, "\t"))
		f.close()
	print("Saved all_maps_dump.json")
	get_tree().quit(0)
