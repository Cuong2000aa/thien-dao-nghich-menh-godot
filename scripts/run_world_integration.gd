extends SceneTree

func _init():
	print("Launching WorldIntegrationScene via SceneTree runner...")
	var scene_res = load("res://assets/environment/WorldIntegrationScene.tscn")
	if scene_res:
		var scene = scene_res.instantiate()
		root.add_child(scene)
	else:
		printerr("Failed to load WorldIntegrationScene.tscn")
		quit(1)
