extends PanelContainer

## Character creator traits: Dao Path + Gender (Swordsman look).
## Hair/Race/Skin UI hidden — values auto-filled for server CheckTraits.

const DAO_PATHS : Array[Dictionary] = [
	{"id": "tu_dao", "name": "Tu Đạo", "modulate": Color(1.08, 1.06, 0.95, 1.0)},
	{"id": "tu_ma", "name": "Tu Ma", "modulate": Color(0.92, 0.72, 1.08, 1.0)},
	{"id": "tu_phat", "name": "Tu Phật", "modulate": Color(1.12, 1.05, 0.78, 1.0)},
	{"id": "ta_tu", "name": "Tà Tu", "modulate": Color(0.78, 1.05, 0.82, 1.0)},
	{"id": "kiem_tu", "name": "Kiếm Tu", "modulate": Color(0.92, 0.98, 1.12, 1.0)},
]

@onready var daoPathRow : HBoxContainer			= $Margin/VBox/Hairstyle
@onready var daoPathLabel : Label				= $Margin/VBox/Hairstyle/Name
@onready var daoPathPrev : Button				= $Margin/VBox/Hairstyle/Previous
@onready var daoPathNext : Button				= $Margin/VBox/Hairstyle/Next
@onready var daoPathTitle : Label				= $Margin/VBox/Hairstyle/Label

@onready var haircolorRow : HBoxContainer		= $Margin/VBox/HairColor
@onready var genderLabel : Label				= $Margin/VBox/Gender/Name
@onready var genderPrev : Button				= $Margin/VBox/Gender/Previous
@onready var genderNext : Button				= $Margin/VBox/Gender/Next
@onready var raceRow : HBoxContainer			= $Margin/VBox/Race
@onready var skintoneRow : HBoxContainer		= $Margin/VBox/SkinTone

# Kept for Character.gd / Randomize compatibility
var skintoneCount : int						= 1
var hairstylesCount : int					= 0
var haircolorsCount : int					= 0
var raceCount : int							= 1

var daoPathValue : int						= 0
var hairstyleValue : int					= 0
var haircolorValue : int					= 0
var genderValue : int						= 0
var raceValue : int							= 0
var skintoneValue : int						= 0

signal bodyUpdate
signal hairUpdate
signal pathUpdate

func _ready():
	if daoPathTitle:
		daoPathTitle.text = "Hệ Tu Luyện"
	if haircolorRow:
		haircolorRow.visible = false
	if raceRow:
		raceRow.visible = false
	if skintoneRow:
		skintoneRow.visible = false
	# Rebind Hairstyle buttons → dao path (connections already point to hairstyle handlers)
	RefreshDaoPath()

func GetDaoPath() -> Dictionary:
	if daoPathValue < 0 or daoPathValue >= DAO_PATHS.size():
		return DAO_PATHS[0]
	return DAO_PATHS[daoPathValue]

func GetDaoPathModulate() -> Color:
	return GetDaoPath().get("modulate", Color.WHITE)

func GetValues():
	_EnsureDefaults()
	var hairstyles : PackedInt64Array = DB.HairstylesDB.keys()
	var haircolors : PackedInt64Array = DB.PalettesDB[DB.Palette.HAIR].keys()
	var races : PackedInt64Array = DB.RacesDB.keys()
	var humanIdx : int = _FindHumanRaceIndex(races)
	raceValue = humanIdx
	var race : RaceData = DB.GetRace(races[raceValue])
	var skins : Dictionary[String, Material] = race.skins if race else {}
	var skinsKeys : Array = skins.keys()
	skintoneValue = 0
	hairstyleValue = mini(hairstyleValue, maxi(0, hairstyles.size() - 1))
	haircolorValue = mini(haircolorValue, maxi(0, haircolors.size() - 1))

	return {
		"hairstyle" = hairstyles[hairstyleValue] if hairstyles.size() > 0 else DB.UnknownHash,
		"haircolor" = haircolors[haircolorValue] if haircolors.size() > 0 else DB.UnknownHash,
		"race" = races[raceValue],
		"skintone" = skinsKeys[skintoneValue].hash() if skinsKeys.size() > 0 else DB.UnknownHash,
		"gender" = genderValue,
		"dao_path" = String(GetDaoPath().get("id", "tu_dao")),
		"dao_path_name" = String(GetDaoPath().get("name", "Tu Đạo")),
	}

func _FindHumanRaceIndex(races : PackedInt64Array) -> int:
	for i in races.size():
		var data : RaceData = DB.GetRace(races[i])
		if data and data.name == "Human":
			return i
	return 0

func _EnsureDefaults():
	hairstylesCount = DB.HairstylesDB.size()
	haircolorsCount = DB.PalettesDB[DB.Palette.HAIR].size()
	raceCount = DB.RacesDB.size()

func RefreshDaoPath():
	if daoPathValue < 0 or daoPathValue >= DAO_PATHS.size():
		daoPathValue = 0
	if daoPathLabel:
		daoPathLabel.set_text(String(DAO_PATHS[daoPathValue].get("name", "Tu Đạo")))
	pathUpdate.emit()
	bodyUpdate.emit()

func _on_hairstyle_prev_button():
	daoPathValue = daoPathValue - 1 if daoPathValue > 0 else DAO_PATHS.size() - 1
	RefreshDaoPath()

func _on_hairstyle_next_button():
	daoPathValue = daoPathValue + 1 if daoPathValue < DAO_PATHS.size() - 1 else 0
	RefreshDaoPath()

# Unused hair handlers kept so old connections don't error if re-enabled
func RefreshHairstyle():
	pass

func RefreshHaircolor():
	pass

func _on_haircolor_prev_button():
	pass

func _on_haircolor_next_button():
	pass

func RefreshGender():
	var gName : String = "Nam Tu"
	match genderValue:
		ActorCommons.Gender.MALE: gName = "Nam Tu"
		ActorCommons.Gender.FEMALE: gName = "Nữ Tu"
		_: gName = "Vô Tướng"
	genderLabel.set_text(gName)
	bodyUpdate.emit()

func _on_gender_prev_button():
	genderValue = genderValue - 1 if genderValue > 0 else ActorCommons.Gender.COUNT - 1
	RefreshGender()

func _on_gender_next_button():
	genderValue = genderValue + 1 if genderValue < ActorCommons.Gender.COUNT - 1 else 0
	RefreshGender()

func RefreshRace():
	bodyUpdate.emit()

func _on_race_prev_button():
	pass

func _on_race_next_button():
	pass

func RefreshSkintone():
	bodyUpdate.emit()

func _on_skintone_prev_button():
	pass

func _on_skintone_next_button():
	pass

func Randomize():
	_EnsureDefaults()
	daoPathValue = randi() % DAO_PATHS.size()
	RefreshDaoPath()
	genderValue = randi() % ActorCommons.Gender.COUNT
	RefreshGender()
	hairstyleValue = 0
	haircolorValue = 0
	raceValue = _FindHumanRaceIndex(DB.RacesDB.keys())
	skintoneValue = 0
