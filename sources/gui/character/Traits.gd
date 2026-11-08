extends PanelContainer

## Character creator: Hình Thể (hero) first, then Dao Path, then Gender.
## Hairstyle row = Hình Thể (always visible top row).
## Race row = Hệ Tu Luyện.

const DAO_PATHS : Array[Dictionary] = [
	{"id": "tu_dao", "name": "Tu Đạo", "modulate": Color(1.08, 1.06, 0.95, 1.0)},
	{"id": "tu_ma", "name": "Tu Ma", "modulate": Color(0.92, 0.72, 1.08, 1.0)},
	{"id": "tu_phat", "name": "Tu Phật", "modulate": Color(1.12, 1.05, 0.78, 1.0)},
	{"id": "ta_tu", "name": "Tà Tu", "modulate": Color(0.78, 1.05, 0.82, 1.0)},
	{"id": "kiem_tu", "name": "Kiếm Tu", "modulate": Color(0.92, 0.98, 1.12, 1.0)},
]

const HeroLib = preload("res://sources/actor/HeroLibrary.gd")

@onready var heroRow : HBoxContainer			= $Margin/VBox/Hairstyle
@onready var heroLabel : Label					= $Margin/VBox/Hairstyle/Name
@onready var heroPrev : Button					= $Margin/VBox/Hairstyle/Previous
@onready var heroNext : Button					= $Margin/VBox/Hairstyle/Next
@onready var heroTitle : Label					= $Margin/VBox/Hairstyle/Label

@onready var haircolorRow : HBoxContainer		= $Margin/VBox/HairColor
@onready var genderLabel : Label				= $Margin/VBox/Gender/Name
@onready var genderPrev : Button				= $Margin/VBox/Gender/Previous
@onready var genderNext : Button				= $Margin/VBox/Gender/Next
@onready var daoPathRow : HBoxContainer			= $Margin/VBox/Race
@onready var daoPathLabel : Label				= $Margin/VBox/Race/Name
@onready var daoPathTitle : Label				= $Margin/VBox/Race/Label
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
var heroValue : int							= 0

signal bodyUpdate
signal hairUpdate
signal pathUpdate
signal heroUpdate

func _ready():
	_SetupLabels()
	RefreshHero()
	RefreshDaoPath()
	RefreshGender()

func _SetupLabels() -> void:
	var panelTitle : Label = get_node_or_null("Margin/VBox/Label") as Label
	if panelTitle:
		panelTitle.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		panelTitle.text = "Chọn Nhân Vật"

	# Top row (Hairstyle node) → Hình Thể
	if heroRow:
		heroRow.visible = true
	if heroTitle:
		heroTitle.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		heroTitle.text = "Hình Thể"
	if heroLabel:
		heroLabel.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		heroLabel.custom_minimum_size.x = 140

	# Hệ Tu Luyện ẩn — skill theo Hình Thể (HeroSkillTree)
	if daoPathRow:
		daoPathRow.visible = false
	if daoPathTitle:
		daoPathTitle.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		daoPathTitle.text = "Hệ Tu Luyện"
	if daoPathLabel:
		daoPathLabel.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED

	if haircolorRow:
		haircolorRow.visible = false
	if skintoneRow:
		skintoneRow.visible = false

func GetDaoPath() -> Dictionary:
	if daoPathValue < 0 or daoPathValue >= DAO_PATHS.size():
		return DAO_PATHS[0]
	return DAO_PATHS[daoPathValue]

func GetDaoPathModulate() -> Color:
	return GetDaoPath().get("modulate", Color.WHITE)

func GetHeroIndex() -> int:
	return clampi(heroValue, 0, HeroLib.Count() - 1)

func GetHeroShapeHash() -> int:
	return HeroLib.GetShapeHash(GetHeroIndex())

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
	var hero : Dictionary = HeroLib.Get(GetHeroIndex())

	return {
		"hairstyle" = hairstyles[hairstyleValue] if hairstyles.size() > 0 else DB.UnknownHash,
		"haircolor" = haircolors[haircolorValue] if haircolors.size() > 0 else DB.UnknownHash,
		"race" = races[raceValue],
		"skintone" = skinsKeys[skintoneValue].hash() if skinsKeys.size() > 0 else DB.UnknownHash,
		"gender" = genderValue,
		"shape" = GetHeroShapeHash(),
		"dao_path" = String(GetDaoPath().get("id", "tu_dao")),
		"dao_path_name" = String(GetDaoPath().get("name", "Tu Đạo")),
		"hero_id" = String(hero.get("id", "swordsman")),
		"hero_name" = String(hero.get("name", "Kiếm Khách")),
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

# --- Hình Thể (wired to Hairstyle buttons in Character.tscn) ---
func RefreshHero():
	_SetupLabels()
	heroValue = clampi(heroValue, 0, HeroLib.Count() - 1)
	var hero : Dictionary = HeroLib.Get(heroValue)
	if heroLabel:
		heroLabel.set_text(String(hero.get("name", "Kiếm Khách")))
	var heroId : String = String(hero.get("id", ""))
	if heroId == "sword_fairy" and genderValue != ActorCommons.Gender.FEMALE:
		genderValue = ActorCommons.Gender.FEMALE
		RefreshGender()
	elif heroId != "sword_fairy" and genderValue == ActorCommons.Gender.FEMALE:
		genderValue = ActorCommons.Gender.MALE
		RefreshGender()
	heroUpdate.emit()
	bodyUpdate.emit()

func _on_hairstyle_prev_button():
	heroValue = heroValue - 1 if heroValue > 0 else HeroLib.Count() - 1
	RefreshHero()

func _on_hairstyle_next_button():
	heroValue = heroValue + 1 if heroValue < HeroLib.Count() - 1 else 0
	RefreshHero()

func RefreshHairstyle():
	pass

func RefreshHaircolor():
	pass

func _on_haircolor_prev_button():
	pass

func _on_haircolor_next_button():
	pass

# --- Hệ Tu Luyện (wired to Race buttons) ---
func RefreshDaoPath():
	if daoPathValue < 0 or daoPathValue >= DAO_PATHS.size():
		daoPathValue = 0
	if daoPathLabel:
		daoPathLabel.set_text(String(DAO_PATHS[daoPathValue].get("name", "Tu Đạo")))
	pathUpdate.emit()
	bodyUpdate.emit()

func RefreshRace():
	RefreshDaoPath()

func _on_race_prev_button():
	daoPathValue = daoPathValue - 1 if daoPathValue > 0 else DAO_PATHS.size() - 1
	RefreshDaoPath()

func _on_race_next_button():
	daoPathValue = daoPathValue + 1 if daoPathValue < DAO_PATHS.size() - 1 else 0
	RefreshDaoPath()

func RefreshGender():
	var gName : String = "Nam Tu"
	match genderValue:
		ActorCommons.Gender.MALE: gName = "Nam Tu"
		ActorCommons.Gender.FEMALE: gName = "Nữ Tu"
		_: gName = "Vô Tướng"
	if genderLabel:
		genderLabel.set_text(gName)
	bodyUpdate.emit()

func _on_gender_prev_button():
	genderValue = genderValue - 1 if genderValue > 0 else ActorCommons.Gender.COUNT - 1
	RefreshGender()

func _on_gender_next_button():
	genderValue = genderValue + 1 if genderValue < ActorCommons.Gender.COUNT - 1 else 0
	RefreshGender()

func RefreshSkintone():
	bodyUpdate.emit()

func _on_skintone_prev_button():
	pass

func _on_skintone_next_button():
	pass

func Randomize():
	_EnsureDefaults()
	heroValue = randi() % HeroLib.Count()
	RefreshHero()
	daoPathValue = 0
	RefreshDaoPath()
	genderValue = randi() % ActorCommons.Gender.COUNT
	RefreshGender()
	hairstyleValue = 0
	haircolorValue = 0
	raceValue = _FindHumanRaceIndex(DB.RacesDB.keys())
	skintoneValue = 0
