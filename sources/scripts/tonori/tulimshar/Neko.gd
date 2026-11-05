extends MerchantScript

#
func GetStock() -> PackedStringArray:
	return ["Short Sword", "Cleaver", "Gladius"]

func OnStart():
	Mes("Cần lưỡi? Lính canh mua ở ta.")
	super.OnStart()
