extends FileData
class_name MapData

@export var displayName : String			= ""
@export var serverData : MapServerData		= null
@export var layersPath : String				= ""
@export var navigation : NavigationPolygon	= null
@export var minimapPath : String			= ""

func GetDisplayName() -> String:
	if not displayName.is_empty():
		return displayName
	return LocationNaming.GetDisplayName(self)

func StripClient():
	layersPath = ""
	minimapPath = ""

func StripServer():
	serverData = null
	navigation = null
