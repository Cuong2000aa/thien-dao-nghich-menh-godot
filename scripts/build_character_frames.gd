@tool
extends SceneTree

## Usage: godot --headless --path . -s scripts/build_character_frames.gd -- assassin
## Builds SpriteFrames from assets/characters/<id>/characters.json

func _init():
	var args : PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		args = OS.get_cmdline_args()
	var charId := "assassin"
	for i in args.size():
		if args[i] == "--" and i + 1 < args.size():
			charId = args[i + 1]
			break
		if not args[i].begins_with("-") and args[i].get_extension() == "" and args[i] != "scripts/build_character_frames.gd":
			# last non-flag often the id when passed after -s
			pass
	# Prefer explicit trailing token that matches a folder
	for a in args:
		if a in ["assassin", "wuxia_swordsman", "swordsman"]:
			charId = a
			break

	var base := "res://assets/characters/%s/" % charId
	var json_path := base + "characters.json"
	print("Building SpriteFrames for ", charId, " from ", json_path)
	if not FileAccess.file_exists(json_path):
		printerr("Missing: ", json_path)
		quit(1)
		return

	var file := FileAccess.open(json_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		printerr("Bad JSON")
		quit(1)
		return

	var rows : Array = data.get("rows", [])
	var anims : Dictionary = data.get("anims", {})
	var sprite_frames := SpriteFrames.new()
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")

	for anim_name in anims.keys():
		var cfg : Dictionary = anims[anim_name]
		var cell_w : int = int(cfg["cell"][0])
		var cell_h : int = int(cfg["cell"][1])
		var frame_count : int = int(cfg["frames"])
		var fps : float = float(cfg["fps"])
		var is_loop : bool = bool(cfg.get("loop", false))
		var sheet_rel : String = String(cfg["sheet"])
		var sheet_res_path := base + sheet_rel
		var tex := ResourceLoader.load(sheet_res_path) as Texture2D
		if tex == null:
			printerr("Failed sheet: ", sheet_res_path)
			continue
		for row_idx in range(rows.size()):
			var dir_name : String = String(rows[row_idx])
			var full_anim_name := "%s_%s" % [anim_name, dir_name]
			sprite_frames.add_animation(full_anim_name)
			sprite_frames.set_animation_speed(full_anim_name, fps)
			sprite_frames.set_animation_loop(full_anim_name, is_loop)
			for col_idx in range(frame_count):
				var atlas := AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = Rect2(col_idx * cell_w, row_idx * cell_h, cell_w, cell_h)
				sprite_frames.add_frame(full_anim_name, atlas)

	var save_path := base + "%s_frames.tres" % charId
	var err := ResourceSaver.save(sprite_frames, save_path)
	if err == OK:
		print("Saved ", save_path, " anims=", sprite_frames.get_animation_names().size())
		quit(0)
	else:
		printerr("Save failed: ", err)
		quit(1)
