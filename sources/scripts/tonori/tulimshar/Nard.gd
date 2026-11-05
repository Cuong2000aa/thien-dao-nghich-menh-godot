extends NpcScript

#
func OnStart():
	Mes("Chào — coi như lên tàu vậy.")
	Mes("Ta là thuyền trưởng La Johanne, con tàu neo ngay sau lưng ta.")
	Mes("Ta đang nghỉ xứng đáng xa rét — vài tuần qua ta ở phía bắc vùng Kaizei.")
	MainChoices()

func MainChoices():
	Choice("Ngươi có thể chở ta ra biển không?", OnSailOffer)
	Choice("Kể về bản thân.", OnAbout)
	Choice("Bình an, Thuyền trưởng.", Farewell)

func OnSailOffer():
	Mes("Sắp buồm Candor, nhưng tạm thời có thể đi chuyến ngắn ngươi muốn.")
	Mes("Tàu chắc và nhanh. Ta đi gần hết bờ Aemil — từng tới tận Thermin!")
	Mes("Sẵn sàng thì lên lái La Johanne. Ta bàn cụ thể đi đâu.")
	Mes("Lâu rồi không chở khách. Ta thường chở hàng.")
	Choice("Đi được những đâu?", OnDestinations)
	Choice("Ta nghĩ thêm.", MainChoices)

func OnDestinations():
	Mes("Candor phía bắc, bờ Manayir tây từ đây, hoặc tới Artis đông bắc.")
	Mes("Đích khác cần chuẩn bị lâu hơn.")
	Mes("Ta không muốn trả phí cảng Esperia vô cớ! Hurnscald cũng vậy.")
	MainChoices()

func OnAbout():
	Mes("Ta bắt đầu làm mộc ở cảng Artis. Lúc đó ít của, nhưng tay nghề tốt.")
	Mes("Ta còn dạy vài học trò.")
	Mes("Rồi đủ tiền mua tàu — gần như xác ve chai, ta sửa ngày đêm đến khi ra khơi được.")
	Mes("Ta gom bạn: Gado, Julia và Magic Arpan — từng làm chung ở cảng.")
	Mes("Đặt tàu La Johanne — theo thuyền trưởng cũ. Biết không nên đổi tên tàu, nhưng ta gần như dựng lại.")
	Mes("Giờ ta kiếm sống bờ này bờ kia, chở hàng. Giá công bằng, ta nghĩ vậy.")
	Choice("Nhớ Artis không?", OnMissOldLife)
	Choice("Kể về thủy thủ.", OnCrew)
	Choice("Quay lại chuyện chính.", MainChoices)

func OnMissOldLife():
	Mes("Thành vĩ đại nhất thế giới — nếu hỏi ta. Không khí, dân, rượu...")
	Mes("Ta nhớ, nhưng hay về — dù không lâu. Artis hàng ra hàng vào.")
	Mes("Ta nhớ học trò. Có lẽ một ngày ta dạy lại. Ai biết?")
	MainChoices()

func OnCrew():
	Mes("Ta quen vài người từ lâu. Gado từng đại phó. Julia là đầu bếp.")
	Mes("Vấn đề: Gado hay cãi nhưng nấu giỏi. Julia thích yên — nấu thì tệ! Ta đổi vai cho nhau.")
	Mes("Magic Arpan... sao không mời lên tàu? Bạn thân nhiều năm. Quyến rũ — đúng nghĩa, dùng phép quyến rũ!")
	Mes("Người khác gom dần — ai hợp tính ta. Ai trên tàu đều có lý do.")
	Mes("Họ đều hữu ích... trừ Silvio. Chỉ uống và tán tỉnh Julia — ông rượu già!")
	MainChoices()

func Farewell():
	Chat("Hẹn gặp! Ghé khi muốn trò chuyện. Ta thích có bạn.")
