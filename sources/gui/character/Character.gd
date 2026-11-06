extends Control

#
@onready var characterName : PanelContainer				= $PlayerName
@onready var characterNameLineEdit : LineEdit			= $PlayerName/Entry
@onready var characterNameDisplay : Label				= $PlayerName/Name

@onready var display : HBoxContainer					= $Display
@onready var traitsPanel : PanelContainer				= $Display/Traits
@onready var attributesPanel : PanelContainer			= $Display/Attributes
@onready var statsPanel : PanelContainer				= $Display/Stats

var isCharacterCreatorEnabled : bool					= false
var charactersInfo : Array[Dictionary]					= []
var charactersNode : Array[Entity]						= []
var currentCharacterID : int							= ActorCommons.InvalidCharacterSlot
var pendingFocusControl : Control						= null
var previewButton : Button								= null

#
func FillWarningLabel(err : NetworkCommons.CharacterError):
	if isCharacterCreatorEnabled:
		FSM.EnterState(FSM.States.CHAR_SCREEN)
		if err == NetworkCommons.CharacterError.ERR_OK:
			EnableCharacterCreator(false)
		else:
			EnableCharacterCreator(true)

	var warn : String = ""
	match err:
		NetworkCommons.CharacterError.ERR_OK:
			warn = ""
			EnableCharacterCreator(false)
		NetworkCommons.CharacterError.ERR_ALREADY_LOGGED_IN:
			warn = "Đạo hào hiện đang đăng nhập."
		NetworkCommons.CharacterError.ERR_TIMEOUT:
			warn = "Không thể kết nối đến máy chủ tiên giới (Mã lỗi %d)." % err
		NetworkCommons.CharacterError.ERR_MISSING_PARAMS:
			warn = "Thiếu thông tin đạo hào nhân vật."
			RequestFocus(characterNameLineEdit)
		NetworkCommons.CharacterError.ERR_NAME_AVAILABLE:
			warn = "Đạo hiệu này đã được tiền bối khác sử dụng."
			RequestFocus(characterNameLineEdit)
		NetworkCommons.CharacterError.ERR_NAME_VALID:
			warn = "Đạo hiệu chỉ bao gồm chữ cái, chữ số và ký tự hợp lệ."
			RequestFocus(characterNameLineEdit)
		NetworkCommons.CharacterError.ERR_NAME_SIZE:
			warn = "Độ dài đạo hiệu phải từ %d đến %d ký tự." % [NetworkCommons.PlayerNameMinSize, NetworkCommons.PlayerNameMaxSize]
			RequestFocus(characterNameLineEdit)
		NetworkCommons.CharacterError.ERR_EMPTY_ACCOUNT:
			EnableCharacterCreator(true)
		_:
			warn = "Sự cố đạo hào không xác định (Mã lỗi %d).\nVui lòng liên hệ tiên môn qua [url=%s][color=#%s]Discord[/color][/url].\n" % [err, LauncherCommons.DiscordInviteLink, UICommons.WarnTextColor]

	if not warn.is_empty():
		warn = "[color=#%s]%s[/color]" % [UICommons.WarnTextColor.to_html(false), warn]
	Launcher.GUI.notificationLabel.AddNotification(warn)

func RequestFocus(control : Control):
	pendingFocusControl = control
	if control.is_visible_in_tree():
		ApplyFocus.call_deferred()

func ApplyFocus():
	if pendingFocusControl:
		pendingFocusControl.release_focus()
		pendingFocusControl.grab_focus()
		pendingFocusControl = null

func FillMissingCharacterInfo(info : Dictionary):
	Util.DicCheckOrAdd(info, "nickname", "")
	Util.DicCheckOrAdd(info, "last_timestamp", ActorCommons.MaxStatValue)
	Util.DicCheckOrAdd(info, "created_timestamp", ActorCommons.MaxStatValue)
	Util.DicCheckOrAdd(info, "level", 1)
	Util.DicCheckOrAdd(info, "pos_map", LauncherCommons.DefaultStartMapID)
	Util.DicCheckOrAdd(info, "hairstyle", DB.UnknownHash)
	Util.DicCheckOrAdd(info, "haircolor", DB.UnknownHash)
	Util.DicCheckOrAdd(info, "gender", ActorCommons.Gender.MALE)
	Util.DicCheckOrAdd(info, "race", DB.UnknownHash)
	Util.DicCheckOrAdd(info, "skintone", DB.UnknownHash)

func HasSlot(slotID : int) -> bool:
	return slotID >= 0 and slotID <= ActorCommons.MaxCharacterCount

func GetDefaultSlot(slotID : int) -> int:
	return slotID if HasSlot(slotID) else 0

func NextAvailableSlot() -> int:
	var availableSlot : int = ActorCommons.InvalidCharacterSlot
	for charID in ActorCommons.MaxCharacterCount:
		if charactersInfo[charID].is_empty():
			availableSlot = charID
			break
	return availableSlot

func MoreRecentThan(firstChar : Dictionary, secondChar : Dictionary) -> bool:
	var firstVal : int = firstChar["created_timestamp"] if firstChar["last_timestamp"] == ActorCommons.MaxStatValue else firstChar["last_timestamp"]
	var secondVal : int = secondChar["created_timestamp"] if secondChar["last_timestamp"] == ActorCommons.MaxStatValue else secondChar["last_timestamp"]
	return firstVal > secondVal

func AddCharacter(info : Dictionary, equipment : Dictionary, slotID : int = ActorCommons.InvalidCharacterSlot):
	FillMissingCharacterInfo(info)

	var availableSlot : int = NextAvailableSlot() if slotID == ActorCommons.InvalidCharacterSlot else slotID
	if availableSlot == ActorCommons.InvalidCharacterSlot:
		assert(false, "No free available placement")
		return

	var entityData : EntityData = DB.EntitiesDB.get("Player".hash(), null)
	if not entityData:
		assert(false, "Could not retrieve the default entity database entry")
		return

	var entity : Entity = Instantiate.CreateEntity(ActorCommons.Type.PLAYER, entityData, info["nickname"], false)
	if not entity:
		assert(false, "Could not create character preview")
		return

	entity.inventory.ImportEquipment(equipment)

	entity.stat.hairstyle	= info["hairstyle"]
	entity.stat.haircolor	= info["haircolor"]
	entity.stat.gender		= info["gender"]
	entity.stat.race		= info["race"]
	entity.stat.skintone	= info["skintone"]
	# Swordsman has no paperdoll slots — re-apply cosmetics after stats are set
	if entity.visual:
		entity.visual.SetBody()
		entity.visual.SetFace()
		entity.visual.SetHair()

	RemoveCharacter(availableSlot)
	charactersInfo[availableSlot] = info
	charactersNode[availableSlot] = entity
	Launcher.Map.AddChild(entity)

	var randDir : Vector2 = Vector2(randf_range(-0.8, 0.8), 1.0)
	var randState : ActorCommons.State = ActorCommons.State.IDLE if isCharacterCreatorEnabled or randi() % 2 == 1 else ActorCommons.State.SIT
	entity.Update(Vector2.ZERO, ActorCommons.CharacterScreenLocations[availableSlot], randDir, randState, -1, true)

	if not HasSlot(currentCharacterID) or MoreRecentThan(info, charactersInfo[currentCharacterID]) or info["nickname"].is_empty():
		UpdateSelectedCharacter(info, availableSlot)

	RefreshCharacterList()

func RemoveCharacter(slotID : int):
	if HasSlot(slotID):
		if charactersNode[slotID] != null:
			Launcher.Map.RemoveChild(charactersNode[slotID])
			charactersNode[slotID] = null
		if not charactersInfo[slotID].is_empty():
			charactersInfo[slotID] = {}

		if currentCharacterID == slotID:
			var mostRecentTimestamp : int = -1
			var mostRecentCharacterID : int = ActorCommons.InvalidCharacterSlot
			for characterID in ActorCommons.MaxCharacterCount:
				if not charactersInfo[characterID].is_empty():
					if mostRecentCharacterID == ActorCommons.InvalidCharacterSlot:
						mostRecentCharacterID = characterID
					elif "last_timestamp" in charactersInfo[characterID] and charactersInfo[characterID]["last_timestamp"] != null and mostRecentTimestamp < charactersInfo[characterID]["last_timestamp"]:
						mostRecentTimestamp = charactersInfo[characterID]["last_timestamp"]
						mostRecentCharacterID = characterID
			UpdateSelectedCharacter(charactersInfo[mostRecentCharacterID] if HasSlot(mostRecentCharacterID) else {}, mostRecentCharacterID)

		RefreshCharacterList()

func RandomizeCharacter():
	attributesPanel.Randomize()
	traitsPanel.Randomize()

func RefreshCharacterList():
	var characterCount : int = 0
	for character in charactersNode:
		if character != null:
			characterCount += 1
	statsPanel.selection.set_visible(characterCount >= 2)
	RefreshSuggestedButton()

func RefreshSuggestedButton():
	if not Launcher.GUI or not Launcher.GUI.buttonBoxes or not FSM.IsCharacterState():
		return

	if isCharacterCreatorEnabled or currentCharacterID != ActorCommons.InvalidCharacterSlot:
		Launcher.GUI.buttonBoxes.Suggest(UICommons.ButtonBox.PRIMARY)
	else:
		Launcher.GUI.buttonBoxes.Suggest(UICommons.ButtonBox.SECONDARY)

func CreateCharacter():
	if isCharacterCreatorEnabled:
		var nickname : String = characterNameLineEdit.get_text()
		var err : NetworkCommons.CharacterError = NetworkCommons.CheckCharacterInformation(nickname)
		if err != NetworkCommons.CharacterError.ERR_OK:
			FillWarningLabel(err)
		else:
			if Network.CreateCharacter(nickname, traitsPanel.GetValues(), attributesPanel.GetValues()):
				FSM.EnterState(FSM.States.CHAR_PROGRESS)

func SelectCharacter():
	if Network.ConnectCharacter(characterNameDisplay.get_text()):
		FSM.EnterState(FSM.States.CHAR_PROGRESS)

func DeleteCharacter():
	UICommons.MessageBox("""Are you sure you want to delete this character?
This action is permanent, and you will not be able to recover or use this character again.
""",
		Callback.Empty, "Cancel",
		ConfirmDeleteCharacter, "Confirm")

func ConfirmDeleteCharacter():
	if Network.DeleteCharacter(characterNameDisplay.get_text()):
		RemoveCharacter(currentCharacterID)

func GetSelectedEntity() -> Entity:
	return charactersNode[currentCharacterID] if currentCharacterID != ActorCommons.InvalidCharacterSlot else null

func UpdateSelectedCharacter(info : Dictionary, slotID : int):
	var displayInformation : bool = not info.is_empty() or isCharacterCreatorEnabled
	characterName.set_visible(displayInformation)
	display.set_visible(displayInformation)

	if not isCharacterCreatorEnabled and not info.is_empty():
		statsPanel.SetInfo(info)
		characterNameDisplay.set_text(info["nickname"])

	if HasSlot(slotID) and charactersNode[slotID] != null:
		if HasSlot(currentCharacterID) and charactersNode[currentCharacterID]:
			EnableCharacterSelectionFx(false, currentCharacterID)
		EnableCharacterSelectionFx(true, slotID)

	if FSM.IsCharacterState():
		Launcher.Camera.LookAt(ActorCommons.CharacterScreenLocations[GetDefaultSlot(slotID)])

	currentCharacterID = slotID

func EnableCharacterSelectionFx(isEnabled : bool, slotID : int):
	if charactersNode[slotID].interactive:
		charactersNode[slotID].interactive.DisplayTarget(ActorCommons.Target.ALLY if isEnabled else ActorCommons.Target.NONE)
	else:
		Callback.PlugCallback(charactersNode[slotID].ready, EnableCharacterSelectionFx, [isEnabled, slotID])

func ChangeSelectedCharacter(changeClockwise : bool = true):
	if not HasSlot(currentCharacterID):
		currentCharacterID = 0
	var operationValue : int = 1 if changeClockwise else -1

	for slotID in range(1, ActorCommons.MaxCharacterCount):
		var lookupID : int = (currentCharacterID + (slotID * operationValue) + ActorCommons.MaxCharacterCount) % ActorCommons.MaxCharacterCount
		var info : Dictionary = charactersInfo[lookupID]
		if not info.is_empty():
			UpdateSelectedCharacter(info, lookupID)
			break

func EnableCharacterCreator(enable : bool):
	if isCharacterCreatorEnabled != enable:
		isCharacterCreatorEnabled = enable
		if enable:
			if Launcher.Camera.IsZooming(ActorCommons.CameraZoomDefault):
				Launcher.Camera.ZoomAt(ActorCommons.CameraZoomDouble)
			RandomizeCharacter()
			AddCharacter(traitsPanel.GetValues(), {}, ActorCommons.MaxCharacterCount)
		else:
			if Launcher.Camera.IsZooming(ActorCommons.CameraZoomDouble):
				Launcher.Camera.ZoomAt(ActorCommons.CameraZoomDefault)
			if not enable and HasSlot(currentCharacterID) and charactersNode[currentCharacterID] != null:
				RemoveCharacter(ActorCommons.MaxCharacterCount)

	statsPanel.set_visible(not enable and visible)
	characterNameDisplay.set_visible(not enable and visible)
	characterNameLineEdit.set_visible(enable)
	traitsPanel.set_visible(enable)
	attributesPanel.set_visible(enable)

	if enable:
		RequestFocus(characterNameLineEdit)
	else:
		pendingFocusControl = null

	_SetPreviewButtonVisible(true)

	if Launcher.GUI.buttonBoxes:
		Launcher.GUI.buttonBoxes.ClearAll()
		if enable:
			Launcher.GUI.buttonBoxes.Bind(UICommons.ButtonBox.PRIMARY, "Tạo Nhân Vật", CreateCharacter)
			Launcher.GUI.buttonBoxes.Bind(UICommons.ButtonBox.SECONDARY, "Ngẫu Nhiên", RandomizeCharacter)
			Launcher.GUI.buttonBoxes.Bind(UICommons.ButtonBox.TERTIARY, "Xem Trước", OpenPreviewGallery)
			Launcher.GUI.buttonBoxes.Bind(UICommons.ButtonBox.CANCEL, "Hủy", EnableCharacterCreator.bind(false))
			RefreshSuggestedButton()
		else:
			Launcher.GUI.buttonBoxes.Bind(UICommons.ButtonBox.PRIMARY, "Vào Tiên Giới", SelectCharacter)
			if NextAvailableSlot() != ActorCommons.InvalidCharacterSlot:
				Launcher.GUI.buttonBoxes.Bind(UICommons.ButtonBox.SECONDARY, "Tạo Mới", EnableCharacterCreator.bind(true))
			# Prefer dedicated preview button; keep TERTIARY for delete when a slot is selected.
			if currentCharacterID != ActorCommons.InvalidCharacterSlot:
				Launcher.GUI.buttonBoxes.Bind(UICommons.ButtonBox.TERTIARY, "Xóa", DeleteCharacter.bind())
			else:
				Launcher.GUI.buttonBoxes.Bind(UICommons.ButtonBox.TERTIARY, "Xem Trước", OpenPreviewGallery)
			Launcher.GUI.buttonBoxes.Bind(UICommons.ButtonBox.CANCEL, "Đăng Xuất", Leave)
			RefreshSuggestedButton()

func UpdateCharacterCreatorBody():
	if isCharacterCreatorEnabled and charactersNode[ActorCommons.MaxCharacterCount]:
		var races : PackedInt64Array = DB.RacesDB.keys()
		var race : RaceData = DB.GetRace(races[traitsPanel.raceValue])
		var skins : Dictionary[String, Material] = race.skins if race else {}
		var skinsKeys : PackedStringArray = skins.keys()
		charactersNode[ActorCommons.MaxCharacterCount].stat.race = races[traitsPanel.raceValue]
		charactersNode[ActorCommons.MaxCharacterCount].stat.skintone = skinsKeys[traitsPanel.skintoneValue].hash()
		charactersNode[ActorCommons.MaxCharacterCount].stat.gender = traitsPanel.genderValue
		if charactersNode[ActorCommons.MaxCharacterCount].visual:
			charactersNode[ActorCommons.MaxCharacterCount].visual.SetBody()
			charactersNode[ActorCommons.MaxCharacterCount].visual.SetFace()

func UpdateCharacterCreatorHair():
	if isCharacterCreatorEnabled and charactersNode[ActorCommons.MaxCharacterCount]:
		var hairstyles : PackedInt64Array = DB.HairstylesDB.keys()
		var haircolors : PackedInt64Array = DB.PalettesDB[DB.Palette.HAIR].keys()
		charactersNode[ActorCommons.MaxCharacterCount].stat.hairstyle = hairstyles[traitsPanel.hairstyleValue]
		charactersNode[ActorCommons.MaxCharacterCount].stat.haircolor = haircolors[traitsPanel.haircolorValue]
		if charactersNode[ActorCommons.MaxCharacterCount].visual:
			charactersNode[ActorCommons.MaxCharacterCount].visual.SetHair()

func RefreshOnce():
	if isCharacterCreatorEnabled:
		EnableCharacterCreator(isCharacterCreatorEnabled)
		return

	Clear()

	Launcher.Map.EmplaceMapNode(ActorCommons.CharacterScreenMapID)
	currentCharacterID = ActorCommons.InvalidCharacterSlot
	for slotID in charactersInfo.size():
		RemoveCharacter(slotID)

	EnableCharacterCreator(isCharacterCreatorEnabled)
	UpdateSelectedCharacter({}, currentCharacterID)
	Network.CharacterListing()

func Clear():
	for slotID in charactersInfo.size():
		RemoveCharacter(slotID)
	Launcher.GUI.buttonBoxes.ClearAll()
	currentCharacterID = ActorCommons.InvalidCharacterSlot
	_SetPreviewButtonVisible(false)

func Leave():
	FSM.EnterState(FSM.States.LOGIN_SCREEN)
	Network.DisconnectAccount()
	Clear()

func Close():
	if isCharacterCreatorEnabled:
		EnableCharacterCreator(false)
	else:
		Leave()

#
func OpenPreviewGallery():
	if Launcher.GUI:
		Launcher.GUI.TogglePreviewGallery()

func _EnsurePreviewButton():
	if previewButton and is_instance_valid(previewButton):
		return
	previewButton = Button.new()
	previewButton.name = "PreviewGalleryButton"
	previewButton.text = "Xem Trước"
	previewButton.tooltip_text = "Xem hiệu ứng · chiêu thức · nhân vật"
	previewButton.focus_mode = Control.FOCUS_NONE
	previewButton.custom_minimum_size = Vector2(128, 40)
	previewButton.pressed.connect(OpenPreviewGallery)
	# Host on GUI overlay (not this VBox) so layout không đẩy nút.
	# Gui is CanvasLayer — use Node, not Control, for the host type.
	var host : Node = Launcher.GUI if Launcher.GUI else get_parent()
	if host == null:
		host = self
	host.add_child(previewButton)
	previewButton.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	previewButton.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	previewButton.offset_left = -148
	previewButton.offset_top = 16
	previewButton.offset_right = -16
	previewButton.offset_bottom = 56
	previewButton.z_index = 80
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.AccentButton(previewButton)

func _SetPreviewButtonVisible(show : bool):
	_EnsurePreviewButton()
	if previewButton and is_instance_valid(previewButton):
		previewButton.set_visible(show)

func _ready():
	assert(ActorCommons.MaxCharacterCount + 1 == ActorCommons.CharacterScreenLocations.size(), "Character screen locations count mismatch with the max character count")
	charactersInfo.resize(ActorCommons.MaxCharacterCount + 1)
	charactersNode.resize(ActorCommons.MaxCharacterCount + 1)
	statsPanel.previousButton.pressed.connect(ChangeSelectedCharacter.bind(false))
	statsPanel.nextButton.pressed.connect(ChangeSelectedCharacter.bind(true))
	traitsPanel.bodyUpdate.connect(UpdateCharacterCreatorBody)
	traitsPanel.hairUpdate.connect(UpdateCharacterCreatorHair)
	FSM.enter_game.connect(Clear)
	_EnsurePreviewButton()
	_SetPreviewButtonVisible(false)

func _physics_process(_delta: float):
	var entity : Entity = GetSelectedEntity()
	if entity:
		var move : Vector2 = Launcher.Action.GetMove()
		if move != Vector2.ZERO:
			entity.entityOrientation = move
			if entity.visual:
				entity.visual.Refresh()

func _unhandled_input(event : InputEvent):
	if not visible:
		return

	var entity : Entity = GetSelectedEntity()
	if entity and Launcher.Action.TryJustPressed(event, "gp_sit"):
		entity.state = ActorCommons.State.IDLE if entity.state == ActorCommons.State.SIT else ActorCommons.State.SIT
		if entity.visual:
			entity.visual.Refresh()

func _on_visibility_changed():
	if visible:
		if pendingFocusControl and pendingFocusControl.is_visible_in_tree():
			ApplyFocus.call_deferred()
	else:
		if statsPanel:
			statsPanel.set_visible(false)
		if traitsPanel:
			traitsPanel.set_visible(false)
		if attributesPanel:
			attributesPanel.set_visible(false)

func _on_text_focus_entered():
	if Launcher.Action:
		Launcher.Action.Enable(false)

func _on_text_focus_exited():
	if Launcher.Action:
		Launcher.Action.Enable(true)
