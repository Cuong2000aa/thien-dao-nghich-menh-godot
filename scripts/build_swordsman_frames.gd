@tool
extends SceneTree

func _init():
	print("Building Swordsman SpriteFrames from characters.json...")
	var json_path = "res://assets/characters/swordsman/characters.json"
	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		printerr("Cannot open: " + json_path)
		quit(1)
		return
	
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	var rows = data["rows"] # ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]
	var anims = data["anims"]
	
	var sprite_frames = SpriteFrames.new()
	# Remove default animation
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
		
	for anim_name in anims:
		var cfg = anims[anim_name]
		var cell_w = cfg["cell"][0]
		var cell_h = cfg["cell"][1]
		var frame_count = cfg["frames"]
		var fps = cfg["fps"]
		var is_loop = cfg["loop"]
		var sheet_rel = cfg["sheet"]
		var sheet_res_path = "res://assets/characters/swordsman/" + sheet_rel
		var tex = ResourceLoader.load(sheet_res_path) as Texture2D
		if not tex:
			printerr("Failed to load sheet: " + sheet_res_path)
			continue
			
		for row_idx in range(rows.size()):
			var dir_name = rows[row_idx]
			var full_anim_name = anim_name + "_" + dir_name
			sprite_frames.add_animation(full_anim_name)
			sprite_frames.set_animation_speed(full_anim_name, fps)
			sprite_frames.set_animation_loop(full_anim_name, is_loop)
			
			for col_idx in range(frame_count):
				var atlas = AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = Rect2(col_idx * cell_w, row_idx * cell_h, cell_w, cell_h)
				sprite_frames.add_frame(full_anim_name, atlas)
				
	var save_path = "res://assets/characters/swordsman/swordsman_frames.tres"
	var err = ResourceSaver.save(sprite_frames, save_path)
	if err == OK:
		print("Successfully generated SpriteFrames at: " + save_path)
		print("Total animations created: ", sprite_frames.get_animation_names().size())
	else:
		printerr("Failed to save SpriteFrames: ", err)
	quit(0)
