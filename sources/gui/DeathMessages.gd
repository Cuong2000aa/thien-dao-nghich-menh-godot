extends RefCounted
class_name DeathMessages

# Authentic Vietnamese Xianxia Death Messages
const Messages : PackedStringArray = [
	"Đạo đồ gian nan, đạo hữu bất hạnh vẫn lạc tại chiến trường.",
	"Đạo tiêu thân vong, một đời tu vi ngỡ như giấc mộng Nam Kha.",
	"Chân linh chưa diệt, quy tụ về Linh Trì sơn môn tái tụ nhục thân.",
	"Thiên Đạo vô tình, sinh tử do mệnh. Kiếp số khó thoát!",
	"Khí huyết hao kiệt, thần hồn ly thể, nhục thân tan biến trong thiên địa.",
	"Lực kiệt tâm tàn trước nghịch cảnh, hồn quy u minh, luân hồi tái khởi.",
	"Một bước sẩy chân vạn kiếp bất phục, tiên lộ gập ghềnh đoạn trường sinh.",
	"Kinh mạch đoạn tuyệt, đan điền vỡ vụn, chân linh phiêu dạt giữa hư không.",
	"Trời cao đố kỵ anh tài, phong ba bão táp vùi dập mầm tiên.",
	"Dục tốc bất đạt, nghịch thiên tranh mệnh há có thể vẹn toàn?",
	"Tử sinh hữu mệnh, phúc họa tương sinh. Đạo hữu chớ nản lòng thoái chí!",
	"Kiếp nạn chưa dứt, thân thể đã tiêu vong. Hẹn ngày trùng tu tiên lộ.",
	"Tu đạo vốn là nghịch thiên nhi hành, ngã xuống hôm nay là cơ duyên ngày sau.",
	"Bách niên tu khổ, một sớm thành không. Chân linh thắp lại ngọn đèn sinh mệnh.",
	"Thiên kiếp hung hiểm, sát cơ trùng trùng, sinh linh đồ thán chốn hồng trần.",
	"Hồn phách quay về chốn sơn môn bản mệnh, tĩnh tâm ngưng thần trọng tố linh thể.",
	"Sinh tử luân hồi vốn là đạo lý trời đất, mở mắt ra lại là một kiếp nhân duyên.",
	"Chí chưa thành thân đã khuất, linh hồn bất diệt chờ ngày vấn đỉnh thương khung.",
	"Vận khí chưa tới, mệnh số nan vi. Dưỡng túc thần hồn rồi lại nhập thế tranh hùng!",
	"Huyết nhiễm chiến bào, thân chôn nơi hoang dã. Chân linh phản bổn quy nguyên.",
	"Kiếm gãy thần tan, phong vân biến sắc. Trùng sinh độ kiếp, nghịch chuyển càn khôn!",
	"Đạo tâm bất diệt, ắt có ngày phá cảnh trùng sinh, ngạo thị quần hùng."
]

#
static func Pick() -> String:
	return Messages[randi() % Messages.size()]
