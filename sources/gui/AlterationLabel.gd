extends Label

#
var timeLeft : float						= 3.0
var fadingTime : float						= 1.0
var velocity : Vector2						= Vector2.ZERO
var criticalHit : bool						= false
var HSVA : Vector4							= Vector4.ZERO
var floorPosition : float					= 0.0
var bounce : bool							= false

var customColor : Color						= Color.TRANSPARENT

const gravityRedux : float					= 180.0
const maxVelocityAngle : float				= 36
const minVelocitySpeed : float				= 24.0
const maxVelocitySpeed : float				= 60.0
const overheadOffset : int					= -10

#
func SetPosition(startPos : Vector2, floorPos : Vector2):
	position = startPos
	floorPosition = floorPos.y

func SetValue(dealer : Entity, target : Entity, value : int, alteration : ActorCommons.Alteration):
	velocity.x = randf_range(-maxVelocityAngle, maxVelocityAngle)
	velocity.y = randf_range(minVelocitySpeed, maxVelocitySpeed)

	var hue : float = 0.0
	match alteration:
		ActorCommons.Alteration.CRIT:
			criticalHit = true
			bounce = true
			set_text("Bạo Kích! %d" % value)
			scale = Vector2(1.35, 1.35)
			var punchTween = create_tween()
			if punchTween:
				punchTween.tween_property(self, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		ActorCommons.Alteration.DODGE:
			hue = ActorCommons.DodgeAttackColor
			bounce = true
			set_text("Né Tránh")
		ActorCommons.Alteration.HIT:
			bounce = true
			hue = ActorCommons.MonsterColor
			if dealer != target:
				if dealer == Launcher.Player:
					hue = ActorCommons.LocalAttackColor
				elif dealer.type == ActorCommons.Type.PLAYER:
					hue = ActorCommons.PlayerColor
			set_text(str(value))
		ActorCommons.Alteration.MISS:
			bounce = true
			hue = ActorCommons.MissAttackColor
			set_text("Trượt")
		ActorCommons.Alteration.HEAL:
			bounce = true
			hue = ActorCommons.HealColor
			set_text("+%d" % value)
		ActorCommons.Alteration.EXP:
			velocity = Vector2(0.0, 12)
			floorPosition = -100000.0
			hue = ActorCommons.ExpColor
			set_text("+%d Tu Vi" % value)
		ActorCommons.Alteration.GP:
			velocity = Vector2(0.0, 12)
			hue = ActorCommons.GPColor
			set_text("+%d Linh Thạch" % value)
		_:
			assert(false, "Alteration type not handled: " + str(alteration))

	HSVA = Vector4(hue, 0.8, 1.0, 1.0)

	add_theme_color_override("font_color", Color.from_hsv(HSVA.x, HSVA.y, HSVA.z, HSVA.w))
	add_theme_color_override("font_outline_color", Color.from_hsv(HSVA.x, HSVA.y, 0.0, HSVA.w))

func SetElementalValue(dealer : Entity, target : Entity, value : int, alteration : ActorCommons.Alteration, element : int = 0):
	SetValue(dealer, target, value, alteration)
	var elemColors : Dictionary = {
		1: Color(1.0, 0.90, 0.20),   # Metal / Kim (Vàng kim)
		2: Color(0.25, 0.95, 0.35),  # Wood / Mộc (Xanh lục bảo)
		3: Color(0.20, 0.80, 1.00),  # Water / Thủy (Lam băng)
		4: Color(1.0, 0.35, 0.10),   # Fire / Hỏa (Xích viêm)
		5: Color(0.90, 0.65, 0.25)   # Earth / Thổ (Hoàng thổ)
	}
	if elemColors.has(element):
		customColor = elemColors[element]
		add_theme_color_override("font_color", customColor)
		add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.1, 0.9))

func SetStatusText(text : String, col : Color = Color(1.0, 0.85, 0.25)):
	velocity = Vector2(0.0, 35.0)
	bounce = false
	floorPosition = -100000.0
	customColor = col
	set_text(text)
	add_theme_color_override("font_color", customColor)
	add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.1, 0.9))

#
func _process(delta):
	timeLeft -= delta
	if timeLeft <= 0.0: 
		queue_free()
		return

	if timeLeft < fadingTime:
		modulate.a = timeLeft / fadingTime

	if velocity != Vector2.ZERO:
		var deltaVelocity : Vector2 = velocity * delta
		if bounce:
			if position.y - deltaVelocity.y >= floorPosition:
				velocity.y = -velocity.y
				velocity.y *= 0.66
			velocity.y -= gravityRedux * delta
		position -= deltaVelocity

	if criticalHit and customColor == Color.TRANSPARENT:
		HSVA.x = HSVA.x + delta * 2
		if HSVA.x > 1.0:
			HSVA.x = 0.0
		if HSVA.x > 0.3 and HSVA.x < 0.7:
			HSVA.x = 0.7

		add_theme_color_override("font_color", Color.from_hsv(HSVA.x, HSVA.y, HSVA.z, HSVA.w))
		add_theme_color_override("font_outline_color", Color.from_hsv(HSVA.x, HSVA.y, 0.2, HSVA.w))
