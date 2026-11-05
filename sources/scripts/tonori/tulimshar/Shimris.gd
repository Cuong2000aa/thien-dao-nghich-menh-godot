extends NpcScript

#
func OnStart():
	Mes("Đạo hữu cần gì?")
	OnMainChoice()

# Main choice loop
func OnMainChoice():
	Choice("Cảng ở đâu?", OnPort)
	Choice("Dọc bờ biển có gì?", OnEast)
	Choice("Ta phải đi.", Farewell)

# Answers
func OnPort():
	Mes("Đi bắc. Tới đó thôi.")
	Mes("Cảng là nơi hàng từ ngoài Tonori vào.")
	Mes("Thường đông — ta không chọc thủy thủ đang làm nếu là ta.")
	Mes("Ta thích ở gần lâu đài hơn đám đông đó.")
	OnMainChoice()

func OnEast():
	Mes("Bãi biển dài về đông. Thích cát thì thích. Không phải ai cũng thích cát...")
	Mes("Đông bắc có hải đăng lớn. Từ trên nhìn cả đại dương.")
	Mes("Khó lẫn — mốc hữu ích.")
	Mes("Đi tiếp đông sẽ tới Manayir Island, dọc bãi biển nữa.")

	OnMainChoice()
