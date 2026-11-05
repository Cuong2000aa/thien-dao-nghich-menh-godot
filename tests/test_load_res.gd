extends SceneTree

func _init():
	var p = "res://presets/maps/data/xianxia/SacredSectHub.tres"
	var res = ResourceLoader.load(p)
	print("Loaded res: ", res)
	if res:
		print("name: ", res._name, ", id: ", res._id)
	quit(0)
