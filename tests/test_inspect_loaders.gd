extends SceneTree

func _init():
	print("--- Testing resource loads ---")
	var paths = [
		"res://assets/characters/swordsman/swordsman_frames.tres",
		"res://presets/entities/sprites/SwordsmanPreset.tscn",
		"res://presets/entities/Player.tres",
		"res://presets/entities/SandstormMineKey.tres",
		"res://presets/entities/Ship.tres",
	]
	for p in paths:
		var res = load(p)
		print("Loaded: ", p, " => ", res)
	quit()
