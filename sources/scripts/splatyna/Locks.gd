extends NpcScript

# Required items
var dorianKeyID : int				= DB.GetCellHash("Dorian's Key")
var gabrielKeyID : int				= DB.GetCellHash("Gabriel's Key")
var marvinKeyID : int				= DB.GetCellHash("Marvin's Key")

var mapID : int						= "Splatyna's Chamber".hash()
const mapPosition : Vector2			= Vector2(1500, 2190)

#
func OnStart():
	match GetQuest(ProgressCommons.Quest.SPLATYNA_OFFERING):
		ProgressCommons.SPLATYNA_OFFERING.INACTIVE: Inactive()
		_: AskChoice()

func AskChoice():
	if HasItem(dorianKeyID) and HasItem(gabrielKeyID) and HasItem(marvinKeyID):
		Mes("Ba ổ khóa khác nhau — đạo hữu muốn làm gì?")
		Choice("Mở chúng", TryOpen)
		Choice("Rời đi")
	else:
		Chat("Cần ba chìa khóa khác nhau mới mở được lối này.")

func TryOpen():
	# Check and remove items to open the chest
	if GetQuest(ProgressCommons.Quest.SPLATYNA_OFFERING) != ProgressCommons.SPLATYNA_OFFERING.INACTIVE:
		if HasItem(dorianKeyID) and HasItem(gabrielKeyID) and HasItem(marvinKeyID):
			RemoveItem(dorianKeyID)
			RemoveItem(gabrielKeyID)
			RemoveItem(marvinKeyID)
			Warp(mapID, mapPosition)
			Close()
		else:
			Chat("Cần ba chìa khóa khác nhau mới mở được lối này.")

func Inactive():
	Chat("Ba ổ khóa chặn lối đi này.")
