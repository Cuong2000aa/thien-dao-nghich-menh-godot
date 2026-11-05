# THIÊN ĐẠO NGHỊCH MỆNH — HỆ THỐNG TU CHÂN (CULTIVATION SYSTEM)
## Pillar 3: Cơ Chế Tu Luyện, Cảnh Giới, Kinh Mạch & Đột Phá

**Dự án:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Tài liệu:** `docs/world/CULTIVATION_SYSTEM.md`  
**Giai đoạn:** Phase 4.2.1 — Owner Decisions Integration  
**Định hướng:** Tu chân là trục tiến trình sức mạnh cốt lõi tối thượng, chi phối toàn bộ chỉ số, kỹ năng và khả năng sinh tồn trong game MMORPG.  
**Quy chế phê duyệt:** [APPROVED] — Mô hình cảnh giới hỗn hợp theo Quyết định **D-04**.

---

## 1. NGUYÊN TẮC CỐT LÕI: PHÂN BIỆT 6 TRỤ CỘT SỨC MẠNH

Để hệ thống sức mạnh trong game không bị hỗn loạn hoặc tùy tiện phá vỡ logic, TDNM phân định rạch ròi 6 thành tố cấu thành chiến lực của một nhân vật:

```
+-------------------------------------------------------------------------------------------------+
| 6 TRỤ CỘT SỨC MẠNH NHÂN VẬT (CHARACTER POWER SYSTEM DECONSTRUCTION)                             |
+-------------------------------------------------------------------------------------------------+
| 1. CẢNH GIỚI TU VI (Cultivation Realm):                                                         |
|    - Là "dung tích bể chứa" và trần giới hạn sinh mệnh của nhân vật.                            |
|    - Quyết định lượng Chân Khí tối đa, tuổi thọ, cấp trang bị có thể dùng và cảnh giới áp chế. |
+-------------------------------------------------------------------------------------------------+
| 2. NHỤC THÂN CƠ SỞ (Physical Foundation & Mortal Body):                                         |
|    - Sức mạnh vật lý thuần túy của gân cốt, da thịt, khí huyết.                                 |
|    - Độc lập với Chân Khí: Một người phàm khỏe mạnh vẫn có thể đấm gục tu sĩ cạn kiệt khí lực.  |
|    - Có thể rèn luyện qua con đường Thể Tu (Body Cultivation) với những giới hạn riêng biệt.     |
+-------------------------------------------------------------------------------------------------+
| 3. CÔNG PHÁP / TÂM PHÁP (Cultivation Manuals & Breathing Techniques):                           |
|    - Là "thuật toán" giúp chuyển đổi Linh Khí trời đất thành Chân Khí trong Đan Điền.           |
|    - Quyết định tốc độ hồi phục Chân Khí, thuộc tính nguyên tố chủ đạo, và chỉ số nội tại ngầm. |
+-------------------------------------------------------------------------------------------------+
| 4. THẦN THÔNG / BÍ THUẬT (Divine Abilities & Active Techniques):                                |
|    - Là "ứng dụng thực chiến" tiêu hao Chân Khí để phóng thích uy lực (chưởng pháp, phi kiếm).   |
|    - Uy lực tỉ lệ thuận với độ tinh thuần của Chân Khí và mức độ thuần thục kỹ năng.            |
+-------------------------------------------------------------------------------------------------+
| 5. HUYẾT MẠCH (Bloodlines - Yếu tố Huyền huyễn mở rộng):                                        |
|    - Dòng máu đặc dị thừa hưởng từ tiên tổ hoặc dung hợp dị thú (Cổ Ma huyết, Chân Long khí).   |
|    - Mang lại năng lực bị động đặc thù (kháng hỏa, giác quan thứ sáu, bạo kích khi hấp hối).    |
+-------------------------------------------------------------------------------------------------+
| 6. PHÁP BẢO & KHÍ CỤ (Artifacts & Equipment):                                                   |
|    - Ngoại lực hỗ trợ: Phi kiếm, hộ tâm kính, pháp bào, đan dược, phù triện.                    |
|    - Đòi hỏi tu vi tương xứng để luyện hóa và kích phát linh tính.                              |
+-------------------------------------------------------------------------------------------------+
```

---

## 2. NỀN MÓNG SINH HỌC TU TIÊN: LINH CĂN, KINH MẠCH & THỂ TU

### 2.1. Linh Căn (Spiritual Roots) [PROPOSED & CLARIFIED]
Linh căn là "ăng-ten" thiên phú bẩm sinh giúp cơ thể con người cảm ứng và hấp thu linh khí trong trời đất:
- **Ngũ Hành Linh Căn (Kim, Mộc, Thủy, Hỏa, Thổ):**
  - *Đơn Linh Căn (Thiên Linh Căn):* Chỉ có 1 thuộc tính thuần nhất, tốc độ tu luyện cực nhanh, tỷ lệ đột phá rất cao.
  - *Song / Tam Linh Căn:* Đa số tu sĩ thông thường sở hữu, có thể phối hợp đa nguyên tố.
  - *Ngũ Hành Tạp Căn:* Chứa đủ 5 thuộc tính Kim - Mộc - Thủy - Hỏa - Thổ nhưng tạp chất nhiều, hấp thu và tinh luyện linh khí chậm chạp. Đòi hỏi nỗ lực phi thường, hiểu biết sâu sắc về dược liệu và quản lý tài nguyên. *(Đây là tư chất chính thức của Nhân vật chính theo Quyết định D-01).*
- **Dị Linh Căn (Xuanhuan Mutation):** Biến dị hiếm gặp như Lôi Linh Căn, Phong Linh Căn, Băng Linh Căn.

### 2.2. Phân Định Rạch Ròi: Tu Linh Căn, Thể Tu & Song Tu [PROPOSED]
Để tránh tình trạng "Thể Tu" bị biến thành lối tắt tùy tiện vượt qua hạn chế của Linh Căn, thế giới thiết lập ranh giới rõ ràng:
1. **Tu Linh Căn (Khí Tu — Khí Đạo Chính Thống):**
   - Dựa vào linh căn để hấp thu linh khí trời đất, ngưng tụ trong Đan Điền, chuyển hóa thành Chân Khí, phóng thích thần thông thuật pháp.
   - Ưu điểm: Tầm đánh xa, uy lực biến hóa đa dạng, ngự kiếm phi hành. Nhược điểm: Nhục thân tương đối mỏng manh nếu cạn kiệt chân khí.
2. **Thể Tu (Nhục Thân Đoán Thể — Nhục Thân Cổ Đạo):**
   - Lấy thân xác làm đan điền, tôi luyện gân cốt, màng da, tủy xương và khí huyết.
   - **Giới hạn & Khó khăn tột bậc:**
     - Thể Tu **KHÔNG PHẢI** là con đường tắt miễn phí cho kẻ thiếu linh căn.
     - Đòi hỏi sự thống khổ tột cùng về thể xác (dùng sấm sét, địa hỏa, độc dược để tôi luyện da thịt).
     - Tiêu hao lượng tài nguyên khổng lồ: thảo dược bồi bổ khí huyết thượng phẩm, tinh huyết yêu thú thượng cổ cực hiếm.
     - Vẫn gặp phải bình cảnh nhục thân hiểm nghèo (nứt gãy kinh mạch, lão hóa khí huyết sớm) và khi vượt qua giới hạn phàm nhân vẫn phải gánh chịu Lôi Kiếp nhục thân khủng khiếp.
3. **Khí Thể Song Tu (Dual Cultivation):**
   - Vừa tu luyện Chân Khí Đan Điền vừa đoán luyện Thể Phách. Sức chiến đấu toàn diện nhất nhưng tốc độ tiến cảnh chậm gấp nhiều lần, đòi hỏi gấp bội thời gian và tài nguyên.

### 2.3. Kinh Mạch & Đan Điền (Meridians & Dantian) [PROPOSED]
- **Hạ Đan Điền (Khí Hải):** Nơi chứa đựng Chân Khí. Khởi đầu từ sương mờ (Khí thái) ở tầng Tụ Khí, cô đặc thành đan châu (Cố thái) ở tầng Huyền Đan.
- **Thập Nhị Chính Kinh & Kỳ Kinh Bát Mạch:** Tuyến đường tuần hoàn Chân Khí trong cơ thể. Khi đả thông mạch Nhâm - Đốc trong giai đoạn Thông Mạch, nhân vật chính thức phá tan gông cùm phàm thân.

---

## 3. CẤU TRÚC CẢNH GIỚI CHÍNH THỨC (CULTIVATION REALM PROGRESSION) [APPROVED — DECISION D-04]

Theo quyết định **D-04** của Project Owner, cấu trúc cảnh giới chính thức của Thiên Đạo Nghịch Mệnh sử dụng **Mô hình Tiến trình Hỗn Hợp (Hybrid Progression Model)**:

```
[1. PHÀM THÂN (Mortal Stage)]
           │
           ▼
[2. TỤ KHÍ CỬU TRỌNG THIÊN (Qi Gathering: Tầng 1 ──► Tầng 9)]
           │
           ▼
[3. THÔNG MẠCH] ──► [4. ĐẠO CƠ] ──► [5. HUYỀN ĐAN] ──► [6. NGUYÊN THẦN]
  (Sơ/Trung/Hậu/     (Sơ/Trung/Hậu/   (Sơ/Trung/Hậu/     (Sơ/Trung/Hậu/
   Đại Viên Mãn)      Đại Viên Mãn)    Đại Viên Mãn)      Đại Viên Mãn)
           │
           ▼
[7. THIÊN NHÂN] ──► [8. QUY HƯ]  ──► [9. ĐỘ KIẾP (Ascension Gate)]
  (Sơ/Trung/Hậu/     (Sơ/Trung/Hậu/   (Sơ/Trung/Hậu/
   Đại Viên Mãn)      Đại Viên Mãn)    Đại Viên Mãn)
```

### 3.1. Chi Tiết Các Cảnh Giới Chính Thức

1. **Giai đoạn Tiền Tu Luyện: Phàm Thân (Mortal Stage):**
   - Cơ thể phàm nhân nguyên bản, chưa dẫn khí nhập thể.
   - Thể lực hữu hạn, nhạy cảm với đói khát, độc tố, thời tiết khắc nghiệt. Phải dựa vào sức cơ bắp, công cụ và dược liệu phàm trần để sinh tồn.
2. **Cảnh giới thứ nhất: Tụ Khí Cửu Trọng Thiên (Qi Gathering — 9 Tầng):**
   - **Tầng 1 đến Tầng 9:** Từng bước cảm ứng thiên địa linh khí, dẫn khí thanh lọc tạp chất cơ thể, ngưng tụ sợi Chân Khí đầu tiên trong Khí Hải.
   - Tạo không gian tiến cấp mịn màng, phù hợp hoàn hảo với trải nghiệm nhập môn và chuỗi nhiệm vụ tân thủ MMORPG.
3. **Cảnh giới thứ hai: Thông Mạch (Meridian Opening — 4 Giai đoạn):**
   - *Sơ Kỳ, Trung Kỳ, Hậu Kỳ, Đại Viên Mãn.*
   - Chân Khí dồi dào bắt đầu trùng kích, đả thông Thập Nhị Chính Kinh và Kỳ Kinh Bát Mạch. Cơ thể trở nên thanh thoát, có thể vận hành khinh công lướt trên mặt cỏ, gia tăng kịch khung tốc độ và kháng đòn.
4. **Cảnh giới thứ ba: Đạo Cơ (Dao Foundation — 4 Giai đoạn):**
   - *Sơ Kỳ, Trung Kỳ, Hậu Kỳ, Đại Viên Mãn.*
   - Chân khí hóa lỏng đúc thành nền móng Đạo Cơ vững chắc trong Đan Điền. Mở khóa khả năng phóng xuất chân hỏa, ngự kiếm phi hành cự ly ngắn, kích phát phù chú trung cấp.
5. **Cảnh giới thứ tư: Huyền Đan (Mystic Core — 4 Giai đoạn):**
   - *Sơ Kỳ, Trung Kỳ, Hậu Kỳ, Đại Viên Mãn.*
   - Chân dịch cô đặc ngưng kết thành Huyền Đan tròn trịa phát sáng. Tuổi thọ gia tăng vượt bậc. Ngự kiếm phi hành tầm cao, hô phong hoán vũ, ngự trị chiến trường dã ngoại.
6. **Cảnh giới thứ năm: Nguyên Thần (Spirit Soul — 4 Giai đoạn):**
   - *Sơ Kỳ, Trung Kỳ, Hậu Kỳ, Đại Viên Mãn.*
   - Huyền Đan thăng hoa sinh ra **Nguyên Thần** (linh hồn hữu hình, thần thức bao trùm vạn dặm).
   - *(Lưu ý chuẩn hóa danh xưng: Sử dụng thống nhất tên gọi Nguyên Thần, không dùng lẫn lộn với Nguyên Anh của mô hình cổ điển).*
7. **Cảnh giới thứ sáu: Thiên Nhân (Heavenly Unity — 4 Giai đoạn):**
   - *Sơ Kỳ, Trung Kỳ, Hậu Kỳ, Đại Viên Mãn.*
   - Thần hồn giao hòa cùng trời đất, lĩnh ngộ pháp tắc tự nhiên sơ khai. Uy áp cảnh giới có thể làm đông cứng linh lực của tu sĩ cấp dưới.
8. **Cảnh giới thứ bảy: Quy Hư (Void Return — 4 Giai đoạn):**
   - *Sơ Kỳ, Trung Kỳ, Hậu Kỳ, Đại Viên Mãn.*
   - Chân khí phản phác quy chân, chạm tới ngưỡng cửa hư không, có khả năng xé rách không gian tầm ngắn hoặc tiến vào các bí cảnh thời không rạn nứt.
9. **Cảnh giới thứ tám: Độ Kiếp (Tribulation Crossing — 4 Giai đoạn):**
   - *Sơ Kỳ, Trung Kỳ, Hậu Kỳ, Đại Viên Mãn.*
   - Chuẩn bị đối mặt với Lôi Kiếp cực hạn của Thiên Đạo để phá vỡ gông cùm giới diện, mở ra ngưỡng cửa Phi Thăng.

### 3.2. Mô Hình Cổ Điển: Phương Án Tham Khảo Lịch Sử Không Lựa Chọn (Unselected Alternative)
Mô hình Tiên hiệp truyền thống (Luyện Khí → Trúc Cơ → Kim Đan → Nguyên Anh → Hóa Thần) được lưu trữ làm phương án tham khảo thiết kế, **TUYỆT ĐỐI KHÔNG DÙNG LÀM TIẾN TRÌNH CHÍNH** trong TDNM.

---

## 4. PHÂN BIỆT THUẬT ĐOẠT XÁ vs XUYÊN KHÔNG VẬT LÝ [CRITICAL DISTINCTION]

Cần phân định rạch ròi giữa hai khái niệm hoàn toàn khác biệt để bảo vệ tính nhất quán của cốt truyện:

```
+-------------------------------------------------------------------------------------------------+
| PHÂN BIỆT THUẬT ĐOẠT XÁ TU CHÂN vs XUYÊN KHÔNG THÂN XÁC NGUYÊN BẢN                              |
+-------------------------------------------------------------------------------------------------+
| 1. THUẬT ĐOẠT XÁ (Body Possession — Khái niệm nội tại của thế giới tu chân):                    |
|    - Là một năng lực/tà thuật tu luyện của các tu sĩ đạt cảnh giới cao (như Nguyên Thần).        |
|    - Khi nhục thân bị hủy hoại, Nguyên Thần có thể thoát ra ngoài, xâm nhập vào thức hải của    |
|      một người khác để tiêu diệt linh hồn đối phương và chiếm đoạt thể xác.                     |
|    - Đây là một quy luật ma đạo tồn tại trong xã hội tu tiên giả tưởng.                         |
|                                                                                                 |
| 2. XUYÊN KHÔNG CỦA NHÂN VẬT CHÍNH (Physical Transmigration — Bí ẩn tự sự):                     |
|    - Nhân vật chính rơi vào dị giới bằng CHÍNH THÂN XÁC VẬT LÝ THẾ KỶ 21 CỦA MÌNH.             |
|    - Nhân vật TUYỆT ĐỐI KHÔNG ĐOẠT XÁ, không nhập vào xác của bất kỳ ai, không đánh cắp ký ức   |
|      hay cuộc đời của người khác.                                                               |
|    - Nhân vật là chính mình, một con người hiện đại mang đầy đủ ADN, vết sẹo và thân thể gốc.   |
+-------------------------------------------------------------------------------------------------+
```

---

## 5. BÌNH CẢNH, ĐỘT PHÁ & LÔI KIẾP

### 5.1. Bình Cảnh & Tâm Ma Kiếp (Bottlenecks & Mental Tribulations) [PROPOSED]
- **Bình Cảnh:** Khi kinh mạch chứa đầy Chân Khí nhưng chưa thông suốt đạo lý của tầng thứ mới, tích lũy điểm kinh nghiệm sẽ tạm dừng. Đòi hỏi phải tìm kiếm **Đan Dược Phá Cảnh** hoặc hoàn thành **Nhiệm Vụ Ngộ Đạo (Epiphany Quest)**.
- **Tâm Ma:** Trong gameplay, Tâm Ma có thể xuất hiện dưới dạng một ảo ảnh bản sao của chính người chơi trong không gian ý thức mà người chơi phải tự mình đánh bại.

### 5.2. Lôi Kiếp Thiên Địa (Heavenly Tribulation) [PROPOSED]
- Khi đột phá các đại cảnh giới then chốt (như ngưng tụ Huyền Đan hoặc phá kén Nguyên Thần), Thiên Đạo sẽ giáng Lôi Kiếp thử thách.
- Do quy tắc Thiên Đạo bị tổn thương (D-02), một số lôi kiếp có thể sinh ra biến dị bất thường (hỗn hợp lôi hỏa, phong lôi dị thường), đòi hỏi người chơi chuẩn bị trận pháp phòng hộ hoặc liên thủ hộ pháp.

---

## 6. NHỮNG ĐIỀU KHOẢN CHƯA ĐỊNH ĐOẠT (UNRESOLVED ITEMS) [PENDING]

1. **`PENDING — LOWER REALM CULTIVATION CEILING AND ASCENSION TRANSITION`:**  
   Xác định trần cảnh giới tối đa tại Hạ Giới (Nguyên Thần Đại Viên Mãn vs Thiên Nhân Đại Viên Mãn vs Độ Kiếp) và cơ chế phi thăng cụ thể (xem chi tiết tại `docs/world/COSMOLOGY.md`).
2. **Cơ chế chuyển tiếp cảnh giới chi tiết:** Quy định cụ thể các loại đan dược bổ trợ và điều kiện môi trường cần thiết cho từng lần phá cảnh.
3. **Mối quan hệ giữa Độ Kiếp và Phi Thăng:** Độ Kiếp xong sẽ mở ra cánh cổng không gian mới ngay lập tức hay nhân vật có thể tiếp tục lưu lại nhân gian dưới dạng "Tán Tiên / Địa Tiên"?
4. **Không tùy tiện bịa đặt con số game balance:** Tuyệt đối không tự ý gán cấp độ level cụ thể (ví dụ: Level 1–100), số điểm kinh nghiệm số học, thời gian tu luyện tính bằng phút, hay hệ số nhân sát thương trong tài liệu thiết kế thế giới này. Các yếu tố này thuộc về cân bằng gameplay của các phase sau.
