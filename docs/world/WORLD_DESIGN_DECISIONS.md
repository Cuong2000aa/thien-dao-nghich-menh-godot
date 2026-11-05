# THIÊN ĐẠO NGHỊCH MỆNH — MA TRẬN QUYẾT ĐỊNH THIẾT KẾ THẾ GIỚI
## World Design Decision Matrix & Canon Approval Log

**Dự án:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Tài liệu:** `docs/world/WORLD_DESIGN_DECISIONS.md`  
**Giai đoạn:** Phase 4.2.1 — Owner Decisions Integration & World Bible Consistency Revision  
**Mục đích:** Theo dõi minh bạch toàn bộ các quyết định thiết kế thế giới, phân định ranh giới tuyệt đối giữa Canon chính thức, các quyết định đã được Project Owner duyệt (APPROVED), các đề xuất (PROPOSED), các vấn đề chưa định đoạt (PENDING), và các ý tưởng bị bác bỏ (REJECTED).

---

## 1. HỆ THỐNG QUY CHUẨN TRẠNG THÁI (STATUS TAXONOMY)

| Trạng Thái | Định Nghĩa & Ý Nghĩa Kỹ Thuật |
|---|---|
| **[CANON]** | Đã được Project Owner phê duyệt chính thức và đã được tích hợp vững chắc vào mã nguồn, tài nguyên, hoặc cấu trúc bất biến của dự án. Bất khả xâm phạm. |
| **[APPROVED]** | Đã được Project Owner chính thức phê duyệt bằng văn bản chỉ đạo. Là cơ sở chuẩn mực bắt buộc, ghi đè mọi đề xuất xung đột trước đó. |
| **[PROPOSED]** | Ý tưởng / giải pháp thiết kế do đội ngũ Narrative đề xuất, có lập luận và phân tích ưu/nhược điểm, đang chờ rà soát. Chưa trở thành chuẩn mực. |
| **[PENDING]** | Vấn đề chưa đủ thông tin hoặc được cố ý giữ mở để phục vụ bí ẩn cốt truyện / chờ chỉ đạo trực tiếp từ Project Owner. Cấm tự ý bịa đặt câu trả lời. |
| **[REJECTED]** | Khái niệm, ý tưởng hoặc phương án đã bị Project Owner dứt khoát bác bỏ. Tuyệt đối cấm tái sử dụng. |

---

## 2. BẢNG THEO DÕI CÁC QUYẾT ĐỊNH CHÍNH THỨC CỦA CHỦ DỰ ÁN (OWNER DECISION HISTORY LOG)

| Quyết Định ID | Tên Quyết Định | Nội Dung Quyết Định Của Project Owner | Trạng Thái | Tài Liệu Bị Ảnh Hưởng | Vấn Đề Chưa Giải Quyết Liên Quan |
|---|---|---|:---:|---|---|
| **D-01** | **Tư Chất Linh Căn Của Nhân Vật Chính** | Nhân vật chính sở hữu **Ngũ Hành Tạp Căn (Kim, Mộc, Thủy, Hỏa, Thổ)**. Tư chất thấp, hấp thu và tinh luyện linh khí chậm, đòi hỏi nhiều thời gian, tài nguyên và nỗ lực. **KHÔNG** có linh căn ẩn tự động thức tỉnh, **KHÔNG** có biến dị sức mạnh không giải thích được, **KHÔNG** có hệ thống hack/cheat. Tri thức hiện đại giúp quan sát, ghi chép, suy luận logic, thực nghiệm và quản lý tài nguyên, nhưng hóa học hiện đại không tự động bằng luyện đan và khoa học không thể bỏ qua quy luật linh khí. Mọi cơ duyên đặc biệt (nếu có sau này) phải có nguyên nhân, giới hạn và hệ quả đáng tin cậy, tách biệt khỏi linh căn. | **[APPROVED]** | `MAIN_CHARACTER.md`, `CULTIVATION_SYSTEM.md`, `STORY_OVERVIEW.md`, `NARRATIVE_STRUCTURE.md` | Bản chất cụ thể của cơ duyên đầu tiên giúp dẫn khí nhập thể; mối quan hệ giữa thể tu và người mang tạp căn. |
| **D-02** | **Bản Chất Của Thiên Đạo** | **Thiên Đạo Tổn Thương — Quy Tắc Dị Biến (Damaged / Fragmented Objective Heavenly Dao)**. Thiên Đạo vốn là quy luật vũ trụ khách quan vận hành thế giới. Sau đại biến cố viễn cổ: một phần quy tắc bị tổn hại/vỡ vụn, các quy luật tự nhiên và siêu nhiên trở nên bất ổn, sinh ra dị tượng thời không và lôi kiếp bất thường, các mảnh vỡ Thiên Đạo tồn tại như bảo vật lịch sử/vũ trụ cực hiếm. **QUY TẮC TRIẾT HỌC BẮT BUỘC:** Thiên Đạo **KHÔNG** phải là thực thể phản diện có ý thức tà ác; **KHÔNG** cố ý nuôi dưỡng tu sĩ như hoa màu để thu hoạch. Thiên Đạo tổn thương sinh ra nguy hiểm nhưng không có ác ý chủ quan. | **[APPROVED]** | `COSMOLOGY.md`, `WORLD_TIMELINE.md`, `STORY_OVERVIEW.md`, `NARRATIVE_STRUCTURE.md` | Nguyên nhân chính xác của đại kiếp viễn cổ; danh tính thế lực cổ xưa liên quan; bản chất tối hậu của mảnh vỡ Thiên Đạo; mối liên hệ tối hậu với sự kiện xuyên không. |
| **D-03** | **Bản Sắc Khu Vực SacredSectHub** | Bản đồ nội bộ `995840901`, tên kỹ thuật `SacredSectHub`. Tên hiển thị người chơi: **CHƯA ĐỊNH ĐOẠT**. Tên tông môn chính thức: **CHƯA ĐỊNH ĐOẠT**. Triết lý, thủy tổ khai sơn, nguồn gốc lịch sử, hệ thống cấp bậc, công pháp truyền thừa và quan hệ chính trị: **CHƯA ĐỊNH ĐOẠT**. **CẤM KỴ:** Cấm đặt tên là Thiên Đạo Tông; cấm phê duyệt Vạn Kiếm Tiên Tông, Thái Hư Đạo Tông, Bắc Huyền Tông; cấm gán định đoạt dựa trên cảnh quan map hiện tại; **CẤM XEM ĐÂY LÀ MÔN PHÁI ĐẦU TIÊN BẮT BUỘC CỦA NHÂN VẬT CHÍNH**. Giữ nguyên mã kỹ thuật `SacredSectHub`. | **[PENDING OWNER APPROVAL]** | `FACTIONS_AND_SECTS.md`, `WORLD_GEOGRAPHY.md`, `LOCATION_NAMING_REGISTRY.md`, `NARRATIVE_STRUCTURE.md` | Thiết kế chi tiết tông môn: tên gọi chính thức, định hướng võ học, giáo tài, và vai trò của người chơi khi tương tác với map. |
| **D-04** | **Cấu Trúc Hệ Thống Cảnh Giới Tu Luyện** | Áp dụng mô hình tiến trình hỗn hợp (Hybrid Progression Model):<br>1. Tiền tu luyện: **Phàm Thân**.<br>2. Cảnh giới tu luyện đầu tiên: **Tụ Khí Cửu Trọng Thiên (Tầng 1 đến Tầng 9)**.<br>3. Các đại cảnh giới tiếp theo mỗi cảnh giới chia thành 4 giai đoạn: **Sơ Kỳ, Trung Kỳ, Hậu Kỳ, Đại Viên Mãn**.<br>Khung danh xưng cảnh giới thiết kế:<br>1. Phàm Thân<br>2. Tụ Khí (Cửu Trọng Thiên: Tầng 1 - 9)<br>3. Thông Mạch (4 giai đoạn)<br>4. Đạo Cơ (4 giai đoạn)<br>5. Huyền Đan (4 giai đoạn)<br>6. Nguyên Thần (4 giai đoạn)<br>7. Thiên Nhân (4 giai đoạn)<br>8. Quy Hư (4 giai đoạn)<br>9. Độ Kiếp (4 giai đoạn).<br>Cấm ngầm thay thế bằng mô hình cổ điển (Luyện Khí → Trúc Cơ → Kim Đan → Nguyên Anh → Hóa Thần). Mô hình cổ điển chỉ lưu làm phương án tham khảo lịch sử không chọn. Cấm tự ý bịa đặt level game, kinh nghiệm, thời gian tu luyện hay chỉ số số học. | **[APPROVED]** | `CULTIVATION_SYSTEM.md`, `COSMOLOGY.md`, `NARRATIVE_STRUCTURE.md`, `STORY_OVERVIEW.md` | `PENDING — LOWER REALM CULTIVATION CEILING AND ASCENSION TRANSITION`; cơ chế chuyển cảnh giới cụ thể; mối quan hệ giữa cảnh giới Độ Kiếp và sự kiện Phi Thăng. |

---

## 3. NHẬT KÝ CHI TIẾT THEO TỪNG LĨNH VỰC (DOMAIN DECISION LOG)

### 3.1. Nền Tảng Thế Giới & Phương Pháp Luận
- **Quyết định 1.1:** Dự án là sự chuyển đổi nội dung (Content Transformation), KHÔNG PHẢI là viết lại (Rewrite). Giữ nguyên toàn bộ 40+ bản đồ gốc của Source of Mana làm Main Game World.  
  *Trạng thái:* **[CANON]**
- **Quyết định 1.2:** Thể loại kết hợp: Tiên hiệp cổ điển làm nền tảng, Huyền huyễn mở rộng quy mô.  
  *Trạng thái:* **[APPROVED]**
- **Quyết định 1.3:** Bảo toàn tính bất biến tuyệt đối của Asset Vault gốc (`thien-dao-nghich-menh/public/assets`).  
  *Trạng thái:* **[CANON]**
- **Quyết định 1.4:** 12 nhóm bản đồ kỹ thuật chỉ là phân loại thư mục/cổng warp, KHÔNG PHẢI là bản đồ chính trị hay địa lý chính thức. Cấm tự ý bịa đặt khoảng cách, quan hệ chính trị, hay biên giới quốc gia.  
  *Trạng thái:* **[CANON]**

### 3.2. Nhân Vật Chính (Protagonist)
- **Quyết định 2.1:** Xuất thân từ thế giới thực hiện đại thế kỷ 21, xuyên không sang thời đại tu chân.  
  *Trạng thái:* **[APPROVED]**
- **Quyết định 2.2:** Giữ nguyên thân xác vật lý gốc từ Trái Đất. **TUYỆT ĐỐI KHÔNG ĐOẠT XÁ** (No body possession). Thuật đoạt xá của tu sĩ cấp cao (Nguyên Thần) là một năng lực tu chân trong thế giới giả tưởng, hoàn toàn tách biệt với cơ chế xuyên không vật lý nguyên thân của nhân vật chính.  
  *Trạng thái:* **[APPROVED]**
- **Quyết định 2.3:** Tư chất linh căn là **Ngũ Hành Tạp Căn (Kim, Mộc, Thủy, Hỏa, Thổ)** theo quyết định **D-01**. Bác bỏ dứt khoát mọi phương án linh căn dị biến lôi/hư không, tiên thiên đạo hạt, hoặc tự động thức tỉnh ngầm.  
  *Trạng thái:* **[APPROVED — D-01]**
- **Quyết định 2.4:** Tri thức hiện đại chỉ hỗ trợ quan sát, ghi chép, tư duy phân tích thực nghiệm và quản lý tài nguyên. Khoa học không thể vi phạm hay vượt qua quy luật linh khí; hóa học không tự động biến thành thuật luyện đan. Không có giao diện cheat/hack.  
  *Trạng thái:* **[APPROVED — D-01]**
- **Quyết định 2.5:** Xuất phát điểm là người phàm tay trắng, không danh phận, không môn phái bảo bọc, khởi đầu tại bờ biển sa mạc Thanh Sa Cảng (`Tulimshar Beach`).  
  *Trạng thái:* **[APPROVED]**

### 3.3. Điểm Xuất Phát & Bản Đồ Mở Rộng
- **Quyết định 3.1:** Điểm xuất phát mặc định của mọi nhân vật mới là thành phố cảng **Tulimshar (Thanh Sa Cảng)** tại tọa độ `Vector2i(2176, 2560)` trong `LauncherCommons.gd`.  
  *Trạng thái:* **[CANON]**
- **Quyết định 3.2:** **Thanh Vân Thôn (`TanThuThon`)** là bản đồ mở rộng Tier 3, KHÔNG thay thế Tulimshar hay thế giới chính SoM.  
  *Trạng thái:* **[CANON]**
- **Quyết định 3.3:** **Bản đồ `SacredSectHub` (`995840901`)** là bản đồ sơn môn kỹ thuật, giữ nguyên mã nội bộ. Danh xưng, tên môn phái, và vai trò cốt truyện để mở theo quyết định **D-03**. Tuyệt đối không coi đây là môn phái đầu tiên bắt buộc của người chơi.  
  *Trạng thái:* **[PENDING OWNER APPROVAL — D-03]**

### 3.4. Bản Chất Thiên Đạo (Cosmology)
- **Quyết định 4.1:** Áp dụng mô hình **Thiên Đạo Tổn Thương — Quy Tắc Dị Biến** theo quyết định **D-02**. Thiên Đạo là quy luật khách quan bị phân mảnh/tổn hại sau đại biến cố viễn cổ.  
  *Trạng thái:* **[APPROVED — D-02]**
- **Quyết định 4.2:** Bác bỏ mô hình Thiên Đạo tà ác có ý thức nuôi nhốt chúng sinh làm mùa màng (Sentient Corrupted Harvester). Thiên Đạo tổn thương gây ra hậu quả nguy hiểm nhưng không có ý chí thù hằn.  
  *Trạng thái:* **[REJECTED CONFLICTING CONCEPT]**
- **Quyết định 4.3:** Giữ kín các bí ẩn vĩnh viễn: nguyên nhân đại kiếp, thế lực cổ đại, số lượng/bản chất mảnh vỡ Thiên Đạo, khả năng chắp vá Thiên Đạo, và mối liên kết sâu xa với sự kiện xuyên không.  
  *Trạng thái:* **[PENDING MYSTERIES — DO NOT FINALIZE]**

### 3.5. Hệ Thống Cảnh Giới Tu Chân (Cultivation Realms)
- **Quyết định 5.1:** Áp dụng khung tiến trình Cửu Cảnh Giới hỗn hợp theo quyết định **D-04**: Phàm Thân → Tụ Khí (Cửu Trọng: Tầng 1–9) → Thông Mạch → Đạo Cơ → Huyền Đan → Nguyên Thần → Thiên Nhân → Quy Hư → Độ Kiếp (mỗi cảnh giới từ Thông Mạch trở đi gồm 4 giai đoạn: Sơ Kỳ, Trung Kỳ, Hậu Kỳ, Đại Viên Mãn).  
  *Trạng thái:* **[APPROVED — D-04]**
- **Quyết định 5.2:** Phân định rõ ràng: Tầng bậc linh hồn là **Nguyên Thần**, không dùng lẫn lộn tráo đổi với danh xưng Nguyên Anh. Mô hình cổ điển (Luyện Khí → Trúc Cơ → Kim Đan → Nguyên Anh → Hóa Thần) chỉ là phương án tham khảo không được chọn.  
  *Trạng thái:* **[APPROVED — D-04]**
- **Quyết định 5.3:** Trần cảnh giới của Phàm Trần Giới (Hạ Giới) và cơ chế phi thăng được ghi nhận là vấn đề chờ quyết định: `PENDING — LOWER REALM CULTIVATION CEILING AND ASCENSION TRANSITION`.  
  *Trạng thái:* **[PENDING OWNER DECISION]**
- **Quyết định 5.4:** Phân định bản chất giữa Tu Linh Căn, Thể Tu và Song Tu. Thể Tu không phải là "đường tắt miễn phí" cho người không có linh căn; Thể Tu đòi hỏi rèn luyện nhục thân cực đoan, tài nguyên linh dược quý hiếm, và vẫn phải đối mặt với lôi kiếp và bình cảnh thể xác.  
  *Trạng thái:* **[PROPOSED CLARIFICATION]**

---

## 4. BẢNG CÁC Ý TƯỞNG ĐÃ BỊ BÁC BỎ (REJECTED CONCEPTS ARCHIVE)

| Khái Niệm Bị Bác Bỏ | Lý Do Bác Bỏ | Quyết Định / Căn Cứ Bác Bỏ |
|---|---|:---:|
| Thay thế thế giới Source of Mana bằng map làng mới dựng | Trái ngược nguyên tắc bất biến "Chuyển hóa nội dung, không viết lại". | Project Direction Correction Mandate |
| Nhân vật chính đoạt xá thân xác phế vật / đệ tử tông môn | Làm mất đi căn tính người hiện đại thế kỷ 21, xóa bỏ xung đột thế giới quan. | Owner Approved Concept |
| Gán cho nhân vật chính Linh Căn Dị Biến (Lôi, Hư Không) hoặc hệ thống cheat | Trái ngược bản sắc nỗ lực, thực tế và tư duy khoa học của nhân vật chính. | **D-01 (APPROVED)** |
| Thiên Đạo là thực thể tà ác nuôi nhốt tu sĩ gặt hái như hoa màu | Biến tác phẩm thành mô-típ phản nghịch sáo rỗng, làm mất đi sự uy nghiêm khách quan của vũ trụ. | **D-02 (APPROVED)** |
| Đặt tên bản đồ `SacredSectHub` là "Thiên Đạo Tông", "Vạn Kiếm Tiên Tông", v.v. | Chưa có quyết định thiết kế môn phái của Project Owner; cấm suy diễn từ asset map. | **D-03 (PENDING)** |
| Tự động coi `SacredSectHub` là môn phái đầu tiên bắt buộc của người chơi | Giới hạn tính tự do và phân nhánh cốt truyện của người chơi trong MMORPG. | **D-03 (PENDING)** |
| Dùng lẫn lộn danh xưng Nguyên Anh và Nguyên Thần | Không nhất quán với cấu trúc cảnh giới đã được phê duyệt trong D-04. | **D-04 (APPROVED)** |
| Đưa ma pháp phương Tây (Mana, Sorcerer, Elf, Orc) vào game | Làm loãng bản sắc Tiên hiệp phương Đông kết hợp Huyền huyễn. | Phase 4.2 Mandate |

---

## 5. DANH SÁCH VẤN ĐỀ CHỜ CHỦ DỰ ÁN QUYẾT ĐỊNH (REMAINING PRIORITIZED DECISION LIST)

Dưới đây là các câu hỏi thiết kế thế giới còn tồn đọng cần Project Owner chỉ đạo trong các giai đoạn tiếp theo:

### Vấn đề 1: `PENDING — LOWER REALM CULTIVATION CEILING AND ASCENSION TRANSITION`
Cấu trúc cảnh giới D-04 gồm 9 bậc (Phàm Thân, Tụ Khí, Thông Mạch, Đạo Cơ, Huyền Đan, Nguyên Thần, Thiên Nhân, Quy Hư, Độ Kiếp). Vũ trụ luận trước đây ghi trần Hạ Giới là Đỉnh Phong Nguyên Anh / Hóa Thần sơ kỳ.
- **Phương án 1 (Trần tại Nguyên Thần Đại Viên Mãn):** Hạ Giới chỉ dung nạp tối đa tới Nguyên Thần. Đột phá Thiên Nhân bắt buộc phải vượt giới diện hoặc kích hoạt phi thăng. (Ưu điểm: Giữ thế giới 42 map ở quy mô vừa phải, tạo động lực phi thăng cho endgame).
- **Phương án 2 (Trần tại Thiên Nhân Đại Viên Mãn):** Cho phép đạt tới Thiên Nhân tại Hạ Giới, chỉ Quy Hư và Độ Kiếp mới thuộc cảnh giới Thượng Giới/Bí Cảnh Hư Không. (Ưu điểm: Người chơi ở Hạ Giới có nhiều cấp bậc sức mạnh trải nghiệm hơn).
- **Phương án 3 (Trần tại Độ Kiếp):** Toàn bộ 9 cảnh giới đều có thể đạt được ở Hạ Giới; Độ Kiếp thành công là dấu mốc mở ra Thượng Giới hoặc kết thúc Main Questline.

### Vấn đề 2: `PENDING — SACREDSECTHUB SECT DESIGN & IDENTITY`
Bản sắc chính thức của bản đồ `SacredSectHub` (`id: 995840901`):
- Tên môn phái chính thức.
- Tông chỉ võ học / đạo thuật (Kiếm tu, Trận pháp/Đạo gia toàn diện, hay Ẩn thế hộ đạo).
- Định vị trong thế giới: Là môn phái có thể gia nhập, hay là trung tâm giao lưu giữa các phái, hay là một cấm địa khảo thí cổ xưa?

### Vấn đề 3: `PENDING — FIRST CULTIVATION ENCOUNTER FOR PROTAGONIST`
Cách thức nhân vật chính (Ngũ Hành Tạp Căn) đạt được khẩu quyết Tụ Khí đầu tiên:
- Mua lại tàn quyển từ tiệm sách cũ phàm trần bằng tiền làm thuê bốc vác tại cảng?
- Vô tình cứu giúp một tán tu trọng thương trên bờ biển Nguyệt Sa và được đền đáp khẩu quyết cơ bản?
- Nhặt được ngọc giản vỡ từ mỏ khoáng sa mạc và tự mình dịch nghĩa?
