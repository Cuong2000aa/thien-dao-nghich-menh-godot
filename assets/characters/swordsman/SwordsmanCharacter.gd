class_name SwordsmanCharacter
extends CharacterBody2D

# 8-Directional Swordsman Controller for Thien Dao Nghich Menh
# Uses AnimatedSprite2D with swordsman_frames.tres and anchors feet via foot_px offset

@export var move_speed : float = 120.0
@export var current_action : String = "idle" # idle, walk, attack, combo, hurt, death, qinggong
@export var current_direction : String = "south"

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape : CollisionShape2D = $CollisionShape2D

const FOOT_OFFSETS = {
	"idle": Vector2(20, 38),
	"walk": Vector2(20, 38),
	"attack": Vector2(36, 58),
	"hurt": Vector2(28, 48),
	"death": Vector2(28, 48),
	"qinggong": Vector2(36, 58),
	"combo": Vector2(36, 58)
}

const DIRECTIONS = [
	"east", "south-east", "south", "south-west",
	"west", "north-west", "north", "north-east"
]

func _ready():
	y_sort_enabled = true
	if sprite:
		play_action(current_action, current_direction)

func get_direction_from_vector(vec: Vector2) -> String:
	if vec.length_squared() < 0.01:
		return current_direction
	var angle = vec.angle() # [-PI, PI]
	# Map angle to 8 sectors (each 45 degrees = PI/4)
	# East is at 0
	var octant = round(angle / (PI / 4.0))
	if octant < 0:
		octant += 8
	var idx = int(octant) % 8
	return DIRECTIONS[idx]

func play_action(action: String, direction: String = ""):
	if direction.is_empty():
		direction = current_direction
	else:
		current_direction = direction
	current_action = action
	
	var anim_name = action + "_" + direction
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
		# Anchor sprite feet to (0, 0)
		var foot = FOOT_OFFSETS.get(action, Vector2(20, 38))
		sprite.offset = -foot

func _physics_process(delta: float):
	if current_action in ["attack", "combo", "death", "hurt"]:
		# Non-interruptible animation state unless finished
		if not sprite.is_playing() and current_action != "death":
			play_action("idle", current_direction)
		move_and_slide()
		return

	var input_vec = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vec.x += 1.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vec.x -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vec.y += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vec.y -= 1.0

	# Attack input
	if Input.is_key_pressed(KEY_J) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		play_action("attack", current_direction)
		velocity = Vector2.ZERO
		return
	elif Input.is_key_pressed(KEY_K):
		play_action("combo", current_direction)
		velocity = Vector2.ZERO
		return
	elif Input.is_key_pressed(KEY_SPACE):
		play_action("qinggong", current_direction)
		velocity = input_vec.normalized() * (move_speed * 1.8)
		move_and_slide()
		return

	if input_vec.length_squared() > 0.01:
		input_vec = input_vec.normalized()
		current_direction = get_direction_from_vector(input_vec)
		velocity = input_vec * move_speed
		play_action("walk", current_direction)
	else:
		velocity = Vector2.ZERO
		play_action("idle", current_direction)

	move_and_slide()
