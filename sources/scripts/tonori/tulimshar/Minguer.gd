extends MerchantScript

#
func GetStock() -> PackedStringArray:
	return ["Bandana Scarf", "Desert Boots"]

func OnStart():
	Mes("Cát nóng thiêu chân trần ngay. Cần giày không?")
	super.OnStart()
