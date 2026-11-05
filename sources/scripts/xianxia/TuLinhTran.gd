extends NpcScript

## Interactive Node: Tụ Linh Trận (Spirit Gathering Array on Tai Chi Platform)
## Allows Outer Disciples and above to absorb dense heavenly Qi, providing accelerated cultivation.

const SectSystemClass = preload("res://sources/sect/SectSystem.gd")

func OnStart():
	if not own or not own.stat:
		Farewell()
		return
		
	var rank : int = SectSystemClass.GetDiscipleRank(own)
	var hasAccess : bool = SectSystemClass.HasFacilityAccess(own, SectSystemClass.Facility.GATHERING_ARRAY)
	
	Mes("--- THÁI CỰC TỤ LINH ĐẠI TRẬN ---")
	Mes("Trận nhãn ngưng tụ linh mạch ngàn năm của Trúc Sơn Tiên Cảnh, sương mù linh khí dày đặc lượn quanh.")
	
	if not hasAccess:
		Mes("CẢNH BÁO: Linh khí nơi đây quá nồng đậm dữ dội!")
		Mes("Đệ tử Tạp Dịch hoặc người ngoài kinh mạch chưa được đúc luyện vững vàng, nếu cưỡng ép đả tọa sẽ bị linh khí trùng kích gây tổn thương.")
		Mes("Hãy thăng cấp lên thân phận [Ngoại Môn Đệ Tử] để đủ tư cách tiến vào đại trận.")
		Choice("Đệ tử hiểu rồi, xin lui ra.", Farewell)
		return
		
	Mes("Trận nhãn đã nhận diện lệnh bài đệ tử hợp lệ.")
	Choice("Tĩnh tọa đả tọa tại Tụ Linh Trận (+8 Tu Vi gia tốc linh khí).", OnMeditateInArray)
	Choice("Rời khỏi đài Thái Cực.", Farewell)

func OnMeditateInArray():
	if own.get("stat"):
		own.stat.SetExperience(8)
		# Recover some MP/HP
		own.stat.SetHealth(15)
		own.stat.SetMana(15)
		
	NpcCommons.PushNotification(own, "+8 TU VI (GIA TỐC TỤ LINH TRẬN)!")
	Mes("ĐẠO TÂM TĨNH LẶNG! Linh khí nồng đậm theo huyệt bách hội tràn vào đan điền.")
	Mes("Tu vi tăng thêm +8 điểm, khí huyết và linh lực được bồi đắp nhanh chóng.")
	Choice("Tiếp tục tĩnh tọa.", OnMeditateInArray)
	Choice("Thu công đứng dậy.", Farewell)
