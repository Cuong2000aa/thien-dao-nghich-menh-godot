extends MerchantScript

#
func GetStock() -> PackedStringArray:
	return ["Desert Goggles", "Ghutra", "Desert Hood"]

func OnStart():
	Mes("Vào bão cát không che đầu? Sắp thành golem cát đấy!")
	super.OnStart()
