extends NpcScript

#
func OnStart():
	Mes("Được đóng quân đoạn tường trong này là may nhất có thể.")
	Mes("Ta ngồi bóng mát cả ngày, lính khác giữ thú hoang ngoài tường.")
	Mes("Việc ta chỉ là không để ai làm phiền Nữ hoàng khi nàng làm vườn.")
	OnMainChoice()

# Main choice loop
func OnMainChoice():
	Choice("Tòa lớn kia là gì?", OnCastle)
	Choice("Phía tây có gì?", OnWest)
	Choice("Phía nam có gì?", OnSouth)
	Choice("Ta phải đi.", Farewell)

# Answers
func OnCastle():
	Mes("Đó là lâu đài Red Queen.")
	Mes("Có thể xin kiến Nữ hoàng nếu việc quan trọng — nhưng đừng làm nàng bỏ vườn.")
	Mes("Trong đó còn thư viện lớn thứ hai lục địa — gần bằng số sách tháp Manayir!")
	OnMainChoice()

func OnWest():
	Mes("ARGH.")
	Mes("...Xin lỗi. Vùng đó làm ta khó chịu.")
	Mes("Nguy hiểm. Rắn nhiều — đó còn là phần dễ chịu. Có dân bản địa — ta không muốn dính; nghe họ ăn chim sống, nhảy múa lông vũ.")
	Mes("Bắt buộc phải đi thì bám đường. Tốt hơn là đừng.")
	OnMainChoice()

func OnSouth():
	Mes("Ngoài tường còn ruộng xương rồng và khu ở cũ — hoang không hết.")
	Mes("Bão cát nuốt hết, ép ta chốt chặt cuối thung lũng.")
	Mes("Không lý tưởng — bão càng lớn mỗi năm.")
	OnMainChoice()
