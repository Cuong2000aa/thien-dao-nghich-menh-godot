extends WindowPanel

#
@onready var button : TouchScreenButton	= $Button/TouchButton
@onready var buttonLabel : Label		= $Button/Label
@onready var scrollable : Scrollable	= $FixedHBox/Scrollable
@onready var scroll : ScrollContainer	= $FixedHBox/Scrollable/Scroll
@onready var scrollMargin : MarginContainer	= $FixedHBox/Scrollable/Scroll/Margin
@onready var scrollbar: VScrollBar		= $FixedHBox/Scrollable/Scroll/_v_scroll

var lastName : String					= ""
var lastTween : Tween					= null
var defaultHeight : float				= 0.0
var autoGrowHeight : float				= 0.0
var autoGrowFloor : float				= 0.0

const PlayerNameLabel : PackedScene		= preload("res://presets/gui/labels/PlayerNameLabel.tscn")
const NPCNameLabel : PackedScene		= preload("res://presets/gui/labels/NpcNameLabel.tscn")
const PlayerDialogueLabel : PackedScene	= preload("res://presets/gui/labels/PlayerDialogueLabel.tscn")

#
func Toggle(toggle : bool):
	if toggle:
		Launcher.GUI.DisplayActions(["ui_accept", "ui_cancel"])
		Clear()
		autoGrowFloor = minf(defaultHeight, autoGrowHeight)
		SetHeight(autoGrowFloor)
	else:
		_KillTween()
		Launcher.GUI.infoContext.FadeOut()
		Launcher.GUI.choiceContext.FadeOut()
		# LookAtNpc leaves cinematic camera; always re-attach on close
		if Launcher.Camera:
			Launcher.Camera.ResetCinematic()

	EnableControl(toggle)

func AddName(text : String):
	if lastName != text and not text.is_empty():
		var newName : bool = not lastName.is_empty()
		lastName = text
		var isPlayer : bool = Launcher.Player and lastName == Launcher.Player.nick
		var label : RichTextLabel = PlayerNameLabel.instantiate() if isPlayer else NPCNameLabel.instantiate()
		var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
		var titleColor : Color = ThemeClass.GOLD_SOFT if isPlayer else ThemeClass.NpcTitleColor(lastName)
		var prefix : String = "\n" if newName else ""
		var titleTag : String = "" if isPlayer else ThemeClass.NpcTitleTag(lastName)
		label.set_text("%s[color=#%s]%s%s[/color]" % [prefix, titleColor.to_html(false), titleTag, lastName])
		# Immediate add — deferred broke get_total_character_count() → empty tween / stuck Continue
		scrollable.textContainer.add_child(label)

func AddDialogue(text : String):
	var isPlayer : bool = Launcher.Player and lastName == Launcher.Player.nick
	var label : RichTextLabel = PlayerDialogueLabel.instantiate() if isPlayer else Scrollable.contentLabel.instantiate()
	label.set_text("[color=#%s]%s[/color]" % [UICommons.TextColor.to_html(false), text])
	scrollable.textContainer.add_child(label)
	if not isPlayer:
		TweenText(label)

func AddThink(text : String):
	var label : RichTextLabel = Scrollable.contentLabel.instantiate()
	label.set_text("[color=#%s]%s[/color]" % [UICommons.WarnTextColor.to_html(false), text])
	label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	scrollable.textContainer.add_child(label)
	TweenText(label)

func TweenText(label : RichTextLabel):
	if label == null or not is_instance_valid(label):
		return
	# Force BBCode layout so character count is valid before tween
	label.visible_characters = -1
	var textSize : int = maxi(label.get_total_character_count(), 1)
	label.visible_characters = 0
	_KillTween()
	lastTween = create_tween()
	lastTween.tween_property(label, "visible_characters", textSize, textSize * UICommons.DialogueTextSpeed)
	lastTween.tween_callback(DialogueDisplayed)

func DialogueDisplayed():
	lastTween = null

func _KillTween() -> void:
	if lastTween != null and is_instance_valid(lastTween):
		lastTween.kill()
	lastTween = null

## Never await an already-finished tween (Godot hangs forever on that).
func _AwaitLastTween() -> void:
	var tw : Tween = lastTween
	if tw == null or not is_instance_valid(tw):
		lastTween = null
		return
	if tw.is_running():
		await tw.finished
	if lastTween == tw:
		lastTween = null

func SetHeight(height : float):
	var bottom : float = position.y + size.y
	size.y = height
	position.y = bottom - size.y

func GetPaddingHeight() -> float:
	return get_theme_stylebox("panel").get_minimum_size().y + scrollable.get_theme_stylebox("panel").get_minimum_size().y + scroll.get_theme_stylebox("panel").get_minimum_size().y

func AutoGrow():
	var maxHeight : float = minf(autoGrowHeight, position.y + size.y)
	if maxSize.y != -1:
		maxHeight = minf(maxHeight, maxSize.y)
	var contentHeight : float = scrollMargin.get_combined_minimum_size().y + GetPaddingHeight()
	var height : float = clampf(contentHeight, autoGrowFloor, maxf(autoGrowFloor, maxHeight))
	if not is_equal_approx(height, size.y):
		SetHeight(height)

func AutoScroll():
	scrollbar.value = scrollbar.max_value

func ToggleButton(enable : bool, text : String):
	if enable:
		await _AwaitLastTween()
	# Always apply — even if a previous await was cancelled mid-flight
	if button:
		button.set_visible(enable)
	if buttonLabel:
		buttonLabel.set_text(text)

func ButtonPressed():
	if lastTween and is_instance_valid(lastTween) and lastTween.is_running():
		lastTween.custom_step(INF)
		return

	if Launcher.Player:
		Network.TriggerNextContext()
	if buttonLabel and (buttonLabel.get_text() == "Close" or buttonLabel.get_text() == "Đóng"):
		set_visible(false)
		if Launcher.Camera:
			Launcher.Camera.ResetCinematic()

func Clear():
	_KillTween()
	scrollable.Clear()
	lastName = ""
	if button:
		button.set_visible(false)

func AddChoices(choices : PackedStringArray):
	await _AwaitLastTween()

	ToggleButton(false, "")
	Launcher.GUI.choiceContext.Clear()

	var choicesCount : int = choices.size()
	if choicesCount > 0:
		Launcher.GUI.choiceContext.Push(ContextData.new("ui_context_validate", choices[0], Network.TriggerChoice.bind(0)))
		if choicesCount > 1:
			Launcher.GUI.choiceContext.Push(ContextData.new("ui_context_cancel", choices[1], Network.TriggerChoice.bind(1)))
		if choicesCount > 2:
			Launcher.GUI.choiceContext.Push(ContextData.new("ui_context_secondary", choices[2], Network.TriggerChoice.bind(2)))
		if choicesCount > 3:
			Launcher.GUI.choiceContext.Push(ContextData.new("ui_context_tertiary", choices[3], Network.TriggerChoice.bind(3)))
		Launcher.GUI.choiceContext.FadeIn(true)

# Overloaded functions
func ResizeWindow(pos : Vector2, globalPos : Vector2):
	super.ResizeWindow(pos, globalPos)
	autoGrowHeight = size.y
	autoGrowFloor = size.y

func _ready():
	defaultHeight = size.y
	autoGrowHeight = defaultHeight
	autoGrowFloor = defaultHeight
	scrollbar.changed.connect(AutoGrow)
	scrollbar.changed.connect(AutoScroll)
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.PolishWindow(self)
	if buttonLabel:
		ThemeClass.AccentLabel(buttonLabel, true)

func _input(event : InputEvent):
	if Launcher.GUI and Launcher.GUI.IsDialogueContextOpened() and not Launcher.GUI.choiceContext.is_visible():
		if Launcher.Action.TryJustPressed(event, "ui_accept", true):
			ButtonPressed()
		if Launcher.Action.TryJustPressed(event, "ui_cancel", true):
			Network.TriggerCloseContext()
			if Launcher.Camera:
				Launcher.Camera.ResetCinematic()
