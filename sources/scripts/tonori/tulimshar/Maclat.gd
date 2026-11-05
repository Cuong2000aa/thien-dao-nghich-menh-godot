extends MerchantScript

#
func GetStock() -> PackedStringArray:
	return ["Shorts", "Cotton Shirt", "Tank Top"]

func OnStart():
	Mes("Mua đồ mát trước khi nắng nướng chết!")
	super.OnStart()
