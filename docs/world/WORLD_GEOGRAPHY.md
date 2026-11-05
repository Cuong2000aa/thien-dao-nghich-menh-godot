# THIÊN ĐẠO NGHỊCH MỆNH — ĐỊA LÝ THẾ GIỚI & TÍCH HỢP BẢN ĐỒ (WORLD GEOGRAPHY)
## Quy Hoạch Không Gian Địa Lý Dựa Trên 42 Bản Đồ Hiện Hữu Của Source of Mana

**Dự án:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Tài liệu:** `docs/world/WORLD_GEOGRAPHY.md`  
**Cơ sở dữ liệu kỹ thuật:** Kế thừa nguyên vẹn 42 bản đồ từ [`LOCATION_NAMING_REGISTRY.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/LOCATION_NAMING_REGISTRY.md)  
**Quy chế phê duyệt:** [PROPOSED] — Đề xuất quy hoạch bối cảnh không gian chờ Project Owner rà soát.

---

## 1. NGUYÊN TẮC QUY HOẠCH ĐỊA LÝ

> [!IMPORTANT]
> **Quy định ranh giới giữa Bản Đồ Kỹ Thuật và Địa Lý Tự Sự:**
> 1. Toàn bộ 42 bản đồ trong Source of Mana được bảo toàn nguyên vẹn về cấu trúc hình học, tọa độ, và liên kết cổng warp (`serverData.spawns`).
> 2. Các liên kết cổng warp kỹ thuật phản ánh các tuyến đường di chuyển vật lý có thể đi được trong game, nhưng **KHÔNG TỰ ĐỘNG THIẾT LẬP** mối quan hệ chính trị hay chủ quyền của bất kỳ môn phái nào nếu chưa được duyệt.
> 3. Tuyệt đối không bịa đặt khoảng cách dặm trường hoặc bản đồ chính trị thế giới vượt ngoài những gì đã được chứng thực.

---

## 2. PHÂN TẦNG ƯU TIÊN CHUYỂN HÓA BẢN ĐỒ (TRANSFORMATION TIERS)

Để quá trình chuyển đổi nội dung (Content Transformation) diễn ra khoa học, bền vững và không làm gãy game:

- **Tier 1 (Ưu tiên số 1 — Khu vực xuất phát & Tân thủ):**  
  Thanh Sa Cảng (`Tulimshar`), Thanh Sa Trấn (`Tulimshar Center`), Vịnh Cảng (`Tulimshar Bay`), Bờ Cát (`Tulimshar Beach`), Thành Chủ Phủ (`Tulimshar Castle`).  
  *Mục tiêu:* Đảm bảo trải nghiệm 20 giờ chơi đầu tiên đậm chất Tu Tiên.
- **Tier 2 (Ưu tiên số 2 — Khu vực trung kỳ & Kết nối liên lục địa):**  
  Trung Thổ Bình Nguyên (`Overworld`), Cổ Thành Vân Châu (`Artis`), Đông Hải & Linh Thuyền (`Ocean & Ship`), Sa mạc bão cát (`Sandstorm`, `Desert Mines`, `Desert Pit`).  
  *Mục tiêu:* Mở rộng không gian khám phá và giao thương bang hội.
- **Tier 3 (Ưu tiên số 3 — Thử thách nâng cao & Bản đồ mở rộng):**  
  Vạn Yêu Quật (`Splatyna`), Động băng Candor (`Candor Cave`), Ma Vực (`Drazil`), Thánh Tông (`SacredSectHub`), Thanh Vân Thôn (`TanThuThon`).  
  *Mục tiêu:* Dungeon cao cấp, Boss thế giới, và hoạt động Tông môn chuyên sâu.

---

## 3. BẢNG QUY HOẠCH CHI TIẾT 42 BẢN ĐỒ HIỆN HỮU

### 3.1. Phân Vùng 1: Thanh Sa Vực (Khu vực khởi đầu — Tier 1 Core)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Tulimshar` (`2608626462`) | **Thanh Sa Cảng** | Cảng biển xuất phát của người chơi; nơi lần đầu tỉnh giấc. | Ngư dân, phu khuân vác, tiểu thương, lính tuần tra cảng. | Chuột cống bến tàu, hải âu cướp mồi, lưu manh sa mạc. | Sinh tồn ngày đầu, tìm việc làm thuê, nghe ngóng tin tức tu tiên. | **Tier 1** |
| `Tulimshar Center` (`3958259487`) | **Thanh Sa Trấn** | Trung tâm thương mại náo nhiệt; phường thị trao đổi linh tài. | Chủ tiệm thuốc, thợ rèn, lái buôn linh thạch, tán tu du phương. | Kẻ trộm chợ, đệ tử thế gia hống hách. | Mua bán dược liệu, học nghề rèn sơ cấp, đổi tiền đồng lấy linh thạch. | **Tier 1** |
| `Tulimshar Bay` (`2910030842`) | **Thanh Sa Vịnh** | Vịnh nước sâu đón tàu linh thuyền cập bến từ trung thổ. | Thủy thủ viễn dương, quan sai kiểm dịch, ngư ông già. | Yêu giải ven bờ, cá mập biến dị. | Hộ tống kiện hàng cập bến, điều tra hải quái phá hoại lưới đánh cá. | **Tier 1** |
| `Tulimshar Castle` (`3953695706`) | **Thành Chủ Phủ** | Phủ đệ quyền lực cai quản trật tự cảng thị. | Thành chủ, hộ vệ tướng quân, quan ghi chép văn thư. | Thích khách trong bóng tối, gián điệp thế gia. | Nhận lệnh truy nã đạo tặc sa mạc, xin giấy thông hành ra khỏi thành. | **Tier 1** |
| `Tulimshar Castle Corridors` (`398960913`) | **Thành Chủ Phủ - Hành Lang** | Lối đi nội bộ bảo vệ nghiêm mật bên trong phủ. | Thị vệ canh gác, gia nhân phục vụ. | Cấm chế cơ quan ngầm. | Điều tra mật thư thất lạc, nhiệm vụ lén lút (stealth quest). | **Tier 1** |
| `Tulimshar West Chamber` (`2666049907`) | **Thành Chủ Phủ - Tây Sương Phòng** | Gian phòng tiếp khách quý và dưỡng thương. | Danh y sa mạc, sứ giả vương triều. | Không có (Vùng an toàn). | Diện kiến nhân vật quan trọng, chữa trị nội thương nặng. | **Tier 1** |
| `Tulimshar West Wall Pathway` (`2851687439`) | **Thanh Sa Cảng - Tây Thành Tường** | Bức tường đá phòng thủ ngăn cát và quái vật sa mạc. | Lính xạ thủ bắn nỏ, trinh sát viên tiền đồn. | Yêu điêu sa mạc, kền kền rình mồi. | Tuần tra đêm thành tường, báo động bão cát đang kéo tới. | **Tier 1** |

---

### 3.2. Phân Vùng 2: Thanh Sa Ngoại Vi & Đồi Cát (Tier 1 Progression)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Tulimshar Beach` (`3632810769`) | **Nguyệt Sa Hải Than** | Bãi biển cát trắng nối liền cảng thị với bờ biển hoang sơ. | Tiều phu nhặt củi, đạo sĩ tĩnh tọa ngắm trăng. | Cua cát mai cứng, hải xà ven bờ. | Thu thập vỏ sò linh quang, cứu người trôi dạt vào bờ cát. | **Tier 1** |
| `Tulimshar Eastern Hills` (`482856684`) | **Thanh Sa Cảng - Đông Lĩnh** | Sườn đồi thoai thoải hướng đông che chắn gió biển. | Thợ săn dã thú, người hái thuốc sa mạc. | Bọ cạp đỏ, chó hoang sa mạc. | Thử thách chiến đấu đầu tiên, thu thập thảo dược sơ cấp. | **Tier 1** |
| `Tulimshar Southern Hills` (`2479667282`) | **Thanh Sa Cảng - Nam Lĩnh** | Cửa ngõ hiểm trở dẫn lối từ Thanh Sa ra Bình Nguyên Trung Thổ. | Trạm dịch chuyển tiêu cục, lính canh biên ải. | Thổ phỉ sa mạc phục kích. | Nhiệm vụ hộ tống thương đoàn vượt ải tiến vào trung thổ. | **Tier 2** |
| `Tulimshar Western Hills` (`1967386498`) | **Thanh Sa Cảng - Tây Lĩnh** | Dãy đồi đá gồ ghề bao bọc bãi biển và cửa hang ngầm. | Ẩn sĩ câu cá trên vách đá. | Kền kền móng sắt, thằn lằn đá. | Tìm lối vào hang động bí mật, cứu thợ mỏ bị lạc. | **Tier 1** |
| `Tulimshar Western Cave` (`2011687557`) | **Thanh Sa Cảng - Tây Nham Động** | Hang đá ẩm ướt dưới chân đồi, nơi trú ngụ của thú ăn thịt. | Thi cốt tu sĩ cổ đại, rương đồ bỏ hoang. | Dơi hút máu, nhện độc giăng tơ. | Mini-dungeon đầu tiên cho tân thủ, tìm kiếm pháp khí vỡ. | **Tier 1** |

---

### 3.3. Phân Vùng 3: Cuồng Sa Hoang Mạc & Mỏ Cổ (Tier 2 Wilderness)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Sandstorm` (`1083397696`) | **Cuồng Sa Hoang Địa** | Biển cát cuồng nộ bão cát mịt mù quanh năm. | Lái buôn lạc đà dũng cảm, thợ đào cổ vật. | Sâu cát khổng lồ (Sandworm), linh hồn bão cát. | Vượt bão cát định hướng la bàn, giải cứu đoàn buôn mất tích. | **Tier 2** |
| `Desert Mines` (`599332840`) | **Cuồng Sa Khoáng Quật** | Khu mỏ linh thạch thời thượng cổ đã bị bỏ hoang. | Cai mỏ già hồi hương, thợ đào lậu linh thạch. | Quỷ bùn sa mạc, linh hồn thợ mỏ bị chôn sống. | Khai thác quặng hắc thiết, tìm kiếm bản đồ kho báu lòng mỏ. | **Tier 2** |
| `Desert Abandoned Level` (`259752832`) | **Phế Khoáng Đạo** | Đường hầm mỏ tầng giữa đầy rẫy cột chống sụp đổ. | Tán tu ma đạo lẩn trốn sự truy sát. | Dơi độc đột biến, nham thạch tích. | Phá giải cơ quan cấm chế mỏ, giải thoát thợ mỏ mắc kẹt. | **Tier 2** |
| `Desert Deep Level` (`1900546786`) | **U Minh Thâm Tầng** | Tầng đáy cùng của khu mỏ, nơi rỉ ra mạch Trọc Khí ngầm. | Bia đá phong ấn thượng cổ nứt nẻ. | Thủ lĩnh đá hắc ám, yêu linh lòng đất. | Đánh bại boss canh giữ linh mạch sâu, phong ấn khe nứt trọc khí. | **Tier 2** |

---

### 3.4. Phân Vùng 4: Xích Nham Hiểm Địa & Vạn Xà Khanh (Tier 2 High Threat)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Desert Mountains` (`3262969514`) | **Xích Nham Sơn Mạch** | Dãy núi đá màu đỏ sừng sững, gió rít như tiếng quỷ khóc. | Thợ săn ưng điêu, đạo sĩ khổ tu trên mỏm đá. | Đại bàng cánh lửa, báo săn vách đá. | Thu thập lông vũ linh ưng, leo núi hái Xích Linh Thảo. | **Tier 2** |
| `Desert Mountain Cave` (`173323126`) | **Xích Nham Thạch Động** | Hang động đá đỏ ngoằn ngoèo xuyên qua lòng núi. | Môn đồ luyện độc môn bí mật. | Bọ cạp đá đỏ hai đuôi, rết lửa. | Thu thập độc dịch luyện đan kháng hỏa, điều tra giáo phái tà độc. | **Tier 2** |
| `Desert Pit` (`3490954041`) | **Xích Sa Hãm Cốc** | Hố sâu sa mạc nơi lưu chuyển dòng cát lún tử thần. | Kẻ sống sót sau vụ đắm thuyền cát. | Quái vật cát lún, linh thiểm xà. | Vượt qua mê cung cát lún, tìm kiếm cổ vật rơi rớt dưới đáy hố. | **Tier 2** |
| `Snake Pit` (`1717452900`) | **Vạn Xà Khanh** | Sào huyệt ngập tràn linh xà và độc trùng dưới lòng đất. | Vu y thu thập độc xà, người nuôi rắn cổ xưa. | Mãng xà ngàn năm, xà tinh biến dị. | Săn Boss Thiên Niên Xà Vương, thu thập Độc Nang Thượng Phẩm. | **Tier 2** |

---

### 3.5. Phân Vùng 5: Linh Sa Hải Tân (Ốc Đảo Ven Biển — Tier 2 Sanctuary)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Manayir` (`356913494`) | **Linh Sa Cổ Trấn** | Thị trấn ốc đảo sa mạc thanh bình với kiến trúc cổ xưa. | Trưởng trấn ốc đảo, đạo hữu bói quẻ giang hồ. | Thổ phỉ đột kích ban đêm (World event). | Nghỉ ngơi hồi phục, mua sắm linh dược thanh nhiệt, giao dịch lạc đà. | **Tier 2** |
| `Manayir Beach` (`996649801`) | **Linh Sa Hải Than** | Bãi biển êm đềm rợp bóng dừa ven ốc đảo. | Ngư dân chài lưới, thiếu nữ hái ngọc trai. | Rùa biển khổng lồ, sứa phát quang. | Lặn biển tìm Linh Châu ngọc trai, câu cá linh dưỡng khí. | **Tier 2** |

---

### 3.6. Phân Vùng 6: Hàn Băng Đảo (Bắc Cực Băng Vực — Tier 3 Challenge)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Candor Cave` (`515101915`) | **Hàn Thạch Động** | Động băng tuyết vĩnh cửu ngàn năm buốt giá thấu xương. | Băng tu bế quan khổ luyện, tàn hồn đại năng. | Vượn tuyết cuồng nộ, linh hồn băng giá. | Hái Hàn Băng Chi, rèn luyện ý chí chống lạnh (Cơ chế nhiệt độ). | **Tier 3** |
| `Candor Arena` (`4111682275`) | **Hàn Băng Diễn Võ Đài** | Đấu trường băng tuyết cổ nơi tu sĩ luận kiếm tỉ thí. | Trọng tài võ đài cổ, linh ảnh võ đạo thượng cổ. | Ảo ảnh thử thách luận kiếm (PvE / PvP Arena). | Tham gia lôi đài tỉ thí cá nhân/bang hội, tranh đoạt danh hiệu Kiếm Thánh.| **Tier 3** |

---

### 3.7. Phân Vùng 7: Cổ Thành Vân Châu (Kinh Đô Trung Nguyên — Tier 2 Capital)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Artis` (`215463816`) | **Cổ Thành Vân Châu** | Đại đô thành tráng lệ bậc nhất, trung tâm văn minh Trung Thổ. | Hoàng thân quốc thích, chưởng quầy đấu giá, đại biểu các môn phái. | Hắc y nhân ám sát, gián điệp các thế lực. | Tham gia đại hội đấu giá quốc tế, nhận ủy thác triều đình, gia nhập bang. | **Tier 2** |
| `Artis Sewer` (`691121518`) | **Địa Đạo Cổ Thành** | Hệ thống đường ngầm chằng chịt dẫn ra ngoại thành và sông ngòi.| Ăn mày ngầm, trùm hắc thị lậu hàng, trộm cắp. | Chuột cống khổng lồ, thi thể nhiễm độc, tà tu ẩn dật. | Điều tra vụ án nhiễm độc nguồn nước, truy lùng căn cứ hắc thị ngầm. | **Tier 2** |

---

### 3.8. Phân Vùng 8: Trung Thổ Đại Lục (Bình Nguyên Bao La — Tier 2 Hub)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Overworld` (`1009372873`) | **Trung Thổ Bình Nguyên** | Bình nguyên rộng lớn bao la kết nối các châu phủ và sơn môn. | Nông dân trồng lúa, tiêu cục áp giải xe ngựa, đệ tử du lịch. | Đạo tặc thảo khấu, sói hoang bầy đàn, dã trư khổng lồ. | Hộ tống xe tiêu xa trường, khám phá các ngã ba đường bí ẩn. | **Tier 2** |

---

### 3.9. Phân Vùng 9: Đông Hải & Linh Thuyền (Hải Trình Viễn Tây — Tier 2 Expedition)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Ocean` (`231511051`) | **Đông Hải** | Đại dương mênh mông ngàn trùng sóng vỗ giữa các lục địa. | Thủy quái khổng lồ dưới biển sâu, linh điêu biển. | Bạch tuộc xúc tu ma quỷ, cá voi ma biến dị. | Vượt biển viễn chinh, bảo vệ chiến thuyền khỏi phong ba bão táp. | **Tier 2** |
| `Ship First Deck` (`4229445336`) | **Linh Thuyền - Thượng Tầng Giáp Bản** | Boong trên của chiến thuyền linh bảo vượt biển. | Thuyền phó quan sát mây trời, cung thủ trực chiến. | Quái điểu biển cướp mồi sà xuống boong. | Bắn hạ quái điểu bảo vệ cánh buồm năng lượng linh thạch. | **Tier 2** |
| `Ship Second Deck` (`2122050188`) | **Linh Thuyền - Hạ Tầng Giáp Bản** | Khoang sinh hoạt của hành khách và thủy thủ. | Bếp trưởng tàu biển, thương gia say sóng, bài thủ tiêu khiển. | Kẻ trộm hành lý trên tàu. | Giao lưu các câu chuyện kỳ bí khắp các châu lục, giải quyết ẩu đả trên tàu. | **Tier 2** |
| `Ship Hold` (`1266994400`) | **Linh Thuyền - Để Thương** | Khoang đáy chở linh tài, đan dược và vật tư hành trình. | Phu khuân vác, thủ kho ghi sổ. | Chuột biển gặm nhấm hòm thuốc, nước ngầm rò rỉ. | Sửa chữa van chống rò rỉ nước ngầm, bắt chuột bảo vệ dược liệu quý. | **Tier 2** |
| `Ship Alige Hide` (`944914549`) | **Linh Thuyền - Mật Thất** | Gian phòng bí mật ẩn sâu dưới khoang tàu. | Hành khách bí ẩn che mạng mặt, thương nhân buôn lậu. | Thích khách diệt khẩu. | Mở khóa hộp cơ quan mật thất, nhận nhiệm vụ ám sát gián điệp. | **Tier 2** |
| `Ship Nard's Room` (`1234630261`) | **Linh Thuyền - Thuyền Trưởng Thất** | Khoang chỉ huy của vị thuyền trưởng lão luyện. | Thuyền trưởng già dày dặn gió sương. | Không có (Vùng an toàn). | Nhận hải đồ hàng hải, chỉ huy hải trình vượt bão tố Đông Hải. | **Tier 2** |

---

### 3.10. Phân Vùng 10: Vạn Yêu Quật (Dungeon Huyết Quái — Tier 3 Raid)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Splatyna Cave Entrance` (`2961248192`)| **Vạn Yêu Quật - Động Khẩu** | Cửa hang âm u chướng khí, ngưỡng cửa vào tử địa yêu ma. | Thợ săn tiền thưởng lập trạm gác, tu sĩ đào tẩu bị thương. | Yêu lang gác cổng, nhện độc bám đá. | Nhiệm vụ cảnh báo thôn trấn, chuẩn bị thuốc kháng độc trước khi vào quật.| **Tier 3** |
| `Splatyna's Corridor` (`3863109455`) | **Vạn Yêu Quật - Huyết Lang Đạo** | Hành lang đá ẩm thấp dẫn sâu vào sào huyệt. | Tàn hồn tu sĩ bị yêu thú xé xác. | Bầy Huyết Lang khát máu, quỷ dơi hút tủy. | Đột phá vòng vây bầy quái, thu thập Huyết Lang Nha. | **Tier 3** |
| `Splatyna's Chamber` (`1514725053`) | **Vạn Yêu Quật - Yêu Vương Điện** | Đại điện trung tâm nơi ngự trị của chúa tể Vạn Yêu Quật. | Yêu Vương cổ đại ngự trên ngai xương. | Yêu Vương Đại Ma (Raid Boss 10 người), Vệ binh yêu tướng. | Tổ chức đội nhóm tiêu diệt Yêu Vương, đoạt bảo rương phong ấn. | **Tier 3** |
| `Splatyna's Dorian Dead End` (`678881037`)| **Vạn Yêu Quật - Tuyệt Bích** | Ngõ cụt vách đá hiểm trở với luồng tà khí nồng nặc. | Thi hài danh sĩ thượng cổ kẹt lại. | Quái vật mai phục từ trần hang. | Khảo cổ bia đá cổ, tìm kiếm bí kíp tàn thiên trong hốc đá. | **Tier 3** |
| `Splatyna's Gabriel Pit` (`575697006`) | **Vạn Yêu Quật - U Minh Uyên Khanh** | Vực sâu tăm tối chứa đựng nhiều bí ẩn dị thường. | Tà tu tu luyện tà công dưới vực. | Linh hồn oán thán rơi xuống vực, xúc tu vực sâu. | Nhảy xuống vực sâu tìm kỳ ngộ, tiêu diệt nguồn phát tán oán khí. | **Tier 3** |
| `Splatyna's Marvin Hole` (`1258335808`) | **Vạn Yêu Quật - Dị Linh Bí Quật** | Hốc đá bí mật nơi dị linh tụ tập luyện ma công. | Yêu đan hóa hình sơ cấp. | Dị linh thể lơ lửng miễn nhiễm sát thương vật lý. | Thử thách sử dụng sát thương phép / nguyên tố để khắc chế dị thể. | **Tier 3** |

---

### 3.11. Phân Vùng 11: Ma Giới Di Tích (Tier 3 End-game Zone)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `Drazil` (`2932080299`) | **U Minh Di Tích** | Vùng đất hoang tàn ngập tràn ma khí và cấm chế vỡ vụn. | Cổ ma phong ấn tàn dư, sứ giả hư không. | Ma binh tàn tích, thực thể hư không biến dị. | Phong ấn khe nứt ma giới, thu thập Cổ Ma Tinh Thạch. | **Tier 3** |

---

### 3.12. Phân Vùng 12: Bản Đồ Mở Rộng Tân Lập (Tier 3 Expansion Hubs)

| Tên Kỹ Thuật (ID) | Tên Hiển Thị | Vai Trò Tự Sự | Cư Dân & NPC Tiềm Năng | Kẻ Địch Tiềm Năng | Cơ Hội Nhiệm Vụ | Mức Ưu Tiên |
|---|---|---|---|---|---|:---:|
| `TanThuThon` (`1841251538`) | **Thanh Vân Thôn** | Làng quê tu tiên yên bình ẩn dật giữa thung lũng đào và tre. | Thôn trưởng, dược nông chăm ruộng linh thảo, lão tiều phu. | Lang yêu phá hoại mùa màng ngoài bìa rừng. | Học hái thuốc, làm quen với lối sống cư dân tu tiên, tìm hiểu lối lên núi. | **Tier 3** |
| `SacredSectHub` (`995840901`) | **Thánh Tông Tổng Đàn / Sơn Môn** [PENDING] | Sơn môn bề thế của đại tông môn tu tiên trên đỉnh núi mây. | Chấp pháp trưởng lão, đệ tử chân truyền, sư huynh truyền công. | Đệ tử thí luyện hình nhân, linh thú hộ môn khảo thí. | Bái sư nhập môn, tham gia khảo hạch tông môn, nhận bổng lộc đệ tử. | **Tier 3** |
