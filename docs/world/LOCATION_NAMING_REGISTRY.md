# THIÊN ĐẠO NGHỊCH MỆNH — LOCATION NAMING REGISTRY
## Quy Hoạch & Đăng Ký Danh Xưng Địa Danh Tu Tiên (42 Bản Đồ)

**Dự án:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Engine:** Godot 4.7.1 Stable  
**Foundation:** Source of Mana (Pinned Commit: `1933bd66caf2c59fd5d9b5df410d19838059b243`)  
**Milestone:** Phase 4.1.2 — Owner Review Integration  
**Cơ chế:** Tra cứu tập trung qua [`LocationNaming`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/world/LocationNaming.gd) & [`MapData.GetDisplayName()`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/db/instance/MapData.gd)  
**Tình trạng tổng kết:** 42 Bản đồ = **32 ĐÃ DUYỆT (APPROVED)** + **9 ĐỀ XUẤT (PROPOSED)** + **1 CHỜ DUYỆT (PENDING OWNER APPROVAL)**

---

## 1. NGUYÊN TẮC THIẾT KẾ & PHÂN ĐỊNH RANH GIỚI BỐI CẢNH

> [!IMPORTANT]
> **Phân định ranh giới giữa Nhóm Kỹ Thuật và Bản Đồ Thế Giới Chính Thức:**
> - 12 phân nhóm trong danh bạ này là **các nhóm bản đồ kỹ thuật và đề xuất danh xưng dựa trên thư mục scene và liên kết warp thực tế trong engine**.
> - Các nhóm này **CHƯA PHẢI** là bản đồ thế giới địa lý, chính trị hoặc lịch sử đã được phê duyệt chính thức.
> - Tuyệt đối **KHÔNG TỰ Ý SÁNG TẠO**:
>   - Khoảng cách không gian giữa các vùng.
>   - Mối quan hệ chính trị giữa các thành trấn hay thế lực.
>   - Biên niên sử hoặc mối quan hệ lịch sử giữa các địa danh.
>   - Quyền sở hữu của tông môn đối với các vùng đất.
>   - Tuyến đường di chuyển vượt ngoài các cổng warp đã được xác thực trong `serverData.spawns`.

1. **Internal Map Name & Hash ID (Bất biến):**
   - Định danh chuỗi gốc (ví dụ: `"Tulimshar"`, `"Overworld"`, `"Candor Cave"`) và mã hash `String.hash()` được giữ nguyên 100%.
   - Mọi truy vấn SQLite, đồng bộ mạng RPC/ENet/WebSocket, và AI navigation hoạt động trên mã hash kỹ thuật gốc.
2. **Resource & Scene Path (Bất biến):**
   - Đường dẫn tài nguyên `.tres`, `.tscn`, file server data, file navigation polygon giữ nguyên không thay đổi.
3. **Player-Facing Display Name (Danh xưng Tu Tiên):**
   - Người chơi chỉ nhìn thấy danh xưng Tiên hiệp thuần Việt trên toàn bộ giao diện: Banner thông báo khi nhập cảnh (`Client.PushNotification`), bảng trạng thái nhân vật (`Stats.locationLabel`), lựa chọn dịch chuyển (`WarpGlobal.warpName`), và danh sách bản đồ.
   - Cơ chế tra cứu tập trung tự động fallback về danh xưng kỹ thuật nếu bản đồ chưa có tên hiển thị tùy biến.

---

## 2. BẢNG TỔNG KHO ĐỊA DANH & TRẠNG THÁI PHÊ DUYỆT (42 BẢN ĐỒ)

### 2.1. Vực 1: Thanh Sa Vực (Tonori - Tulimshar Core) — Khu vực xuất phát chính

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Tulimshar` | `2608626462` | `res://presets/maps/layers/tonori/tulimshar/Tulimshar.tscn` | **Thanh Sa Cảng** | Thanh Sa Vực | **APPROVED** | Thành phố cảng sầm uất phía nam, điểm xuất phát mặc định của mọi tân thủ tu sĩ. |
| `Tulimshar Center` | `3958259487` | `res://presets/maps/layers/tonori/tulimshar/Tulimshar Center.tscn` | **Thanh Sa Trấn** | Thanh Sa Vực | **APPROVED** | Khu trung tâm buôn bán tấp nập, phường thị trao đổi đan dược và pháp bảo. |
| `Tulimshar Bay` | `2910030842` | `res://presets/maps/layers/tonori/tulimshar/Tulimshar Bay.tscn` | **Thanh Sa Vịnh** | Thanh Sa Vực | **APPROVED** | Vịnh biển đón các chuyến linh thuyền vượt biển từ trung thổ cập bến. |
| `Tulimshar Castle` | `3953695706` | `res://presets/maps/layers/tonori/tulimshar/Tulimshar Castle.tscn` | **Thành Chủ Phủ** | Thanh Sa Vực | **APPROVED** | Phủ đệ của Thành chủ cai quản toàn bộ bờ cảng Thanh Sa. |
| `Tulimshar Castle Corridors` | `398960913` | `res://presets/maps/layers/tonori/tulimshar/Tulimshar Castle Corridors.tscn` | **Thành Chủ Phủ - Hành Lang** | Thanh Sa Vực | **APPROVED** | Hành lang bên trong phủ đệ Thành Chủ Phủ. |
| `Tulimshar West Chamber` | `2666049907` | `res://presets/maps/layers/tonori/tulimshar/Tulimshar West Chamber.tscn` | **Thành Chủ Phủ - Tây Sương Phòng** | Thanh Sa Vực | **APPROVED** | Căn phòng nghỉ ngơi yên tĩnh phía tây phủ đệ. |
| `Tulimshar West Wall Pathway` | `2851687439` | `res://presets/maps/layers/tonori/tulimshar/Tulimshar West Wall Pathway.tscn` | **Thanh Sa Cảng - Tây Thành Tường** | Thanh Sa Vực | **APPROVED** | Bức tường thành đá kiên cố canh giữ bờ tây cảng thị. |

### 2.2. Vực 2: Thanh Sa Ngoại Vi (Tonori - Tulimshar Outskirts)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Tulimshar Beach` | `3632810769` | `res://presets/maps/layers/tonori/tulimshar outskirts/Tulimshar Beach.tscn` | **Nguyệt Sa Hải Than** | Thanh Sa Ngoại Vi | **APPROVED** | Bãi biển cát trắng mịn màng ngắm trăng bên ngoài thành lũy. |
| `Tulimshar Eastern Hills` | `482856684` | `res://presets/maps/layers/tonori/tulimshar outskirts/Tulimshar Eastern Hills.tscn` | **Thanh Sa Cảng - Đông Lĩnh** | Thanh Sa Ngoại Vi | **APPROVED** | Vùng đồi thoai thoải bảo vệ phía đông bờ cảng. |
| `Tulimshar Southern Hills` | `2479667282` | `res://presets/maps/layers/tonori/tulimshar outskirts/Tulimshar Southern Hills.tscn` | **Thanh Sa Cảng - Nam Lĩnh** | Thanh Sa Ngoại Vi | **APPROVED** | Dãy đồi đá phía nam mở đường tiến ra Trung Thổ Bình Nguyên. |
| `Tulimshar Western Hills` | `1967386498` | `res://presets/maps/layers/tonori/tulimshar outskirts/Tulimshar Western Hills.tscn` | **Thanh Sa Cảng - Tây Lĩnh** | Thanh Sa Ngoại Vi | **APPROVED** | Sườn đồi hướng tây bao bọc bãi biển và lối vào nham động. |
| `Tulimshar Western Cave` | `2011687557` | `res://presets/maps/layers/tonori/tulimshar outskirts/Tulimshar Western Cave.tscn` | **Thanh Sa Cảng - Tây Nham Động** | Thanh Sa Ngoại Vi | **APPROVED** | Hang động đá ngầm ẩm ướt dưới chân đồi phía tây. |

### 2.3. Vực 3: Cuồng Sa Hoang Mạc (Tonori - Sandstorm Region)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Sandstorm` | `1083397696` | `res://presets/maps/layers/tonori/sandstorm/Sandstorm.tscn` | **Cuồng Sa Hoang Địa** | Cuồng Sa Hoang Mạc | **APPROVED** | Hoang mạc bão cát cuồng phong gầm thét, cản trở bước chân phàm nhân. (Chủ dự án duyệt) |
| `Desert Mines` | `599332840` | `res://presets/maps/layers/tonori/sandstorm/Desert Mines.tscn` | **Cuồng Sa Khoáng Quật** | Cuồng Sa Hoang Mạc | **APPROVED** | Khu mỏ cổ xưa từng khai thác linh thạch chất lượng cao. (Chủ dự án duyệt) |
| `Desert Abandoned Level` | `259752832` | `res://presets/maps/layers/tonori/sandstorm/Desert Abandoned Level.tscn` | **Phế Khoáng Đạo** | Cuồng Sa Hoang Mạc | **PROPOSED** | Các tầng hầm mỏ bỏ hoang đầy sụp đổ và hiểm nguy. |
| `Desert Deep Level` | `1900546786` | `res://presets/maps/layers/tonori/sandstorm/Desert Deep Level.tscn` | **U Minh Thâm Tầng** | Cuồng Sa Hoang Mạc | **APPROVED** | Tầng đáy sâu thẳm của mỏ sa mạc, nơi linh khí biến đổi kỳ dị. (Chủ dự án duyệt) |

### 2.4. Vực 4: Xích Nham Hiểm Địa (Tonori - Desert Pit Region)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Desert Mountains` | `3262969514` | `res://presets/maps/layers/tonori/desertpit/Desert Mountains.tscn` | **Xích Nham Sơn Mạch** | Xích Nham Hiểm Địa | **APPROVED** | Dãy núi đá màu đỏ sừng sững giữa biển cát nóng bỏng. (Chủ dự án duyệt) |
| `Desert Mountain Cave` | `173323126` | `res://presets/maps/layers/tonori/desertpit/Desert Mountain Cave.tscn` | **Xích Nham Thạch Động** | Xích Nham Hiểm Địa | **PROPOSED** | Mê cung hang động xuyên sâu vào lòng núi đá đỏ. |
| `Desert Pit` | `3490954041` | `res://presets/maps/layers/tonori/desertpit/Desert Pit.tscn` | **Xích Sa Hãm Cốc** | Xích Nham Hiểm Địa | **PROPOSED** | Hố sâu thung lũng nơi cát lún cuồn cuộn nguy hiểm. |
| `Snake Pit` | `1717452900` | `res://presets/maps/layers/tonori/desertpit/Snake Pit.tscn` | **Vạn Xà Khanh** | Xích Nham Hiểm Địa | **APPROVED** | Hiểm địa hố sâu ngập tràn linh xà và độc trùng nguy hiểm. (Chủ dự án duyệt) |

### 2.5. Vực 5: Linh Sa Hải Tân (Tonori - Manayir Region)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Manayir` | `356913494` | `res://presets/maps/layers/tonori/manayir/Manayir.tscn` | **Linh Sa Cổ Trấn** | Linh Sa Hải Tân | **APPROVED** | Thị trấn ốc đảo cổ kính thanh bình ven bờ cát. (Chủ dự án duyệt) |
| `Manayir Beach` | `996649801` | `res://presets/maps/layers/tonori/manayir/Manayir Beach.tscn` | **Linh Sa Hải Than** | Linh Sa Hải Tân | **PROPOSED** | Bãi biển êm ả rợp bóng cây ven ốc đảo Linh Sa. |

### 2.6. Vực 6: Hàn Băng Đảo (Candor Region)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Candor Cave` | `515101915` | `res://presets/maps/layers/candor/Candor Cave.tscn` | **Hàn Thạch Động** | Hàn Băng Đảo | **APPROVED** | Động băng giá buốt vĩnh cửu quanh năm phủ tuyết trắng. |
| `Candor Arena` | `4111682275` | `res://presets/maps/layers/candor/Candor Arena.tscn` | **Hàn Băng Diễn Võ Đài** | Hàn Băng Đảo | **APPROVED** | Đấu trường băng tuyết cổ nơi các tu sĩ luận kiếm tỉ thí. (Chủ dự án duyệt) |

### 2.7. Vực 7: Cổ Thành Vân Châu (Artis & Sewer Region)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Artis` | `215463816` | `res://presets/maps/layers/artis/Artis.tscn` | **Cổ Thành Vân Châu** | Vân Châu Vực | **APPROVED** | Đại đô thành sầm uất tráng lệ bậc nhất tiên giới. |
| `Artis Sewer` | `691121518` | `res://presets/maps/layers/sewer/Artis Sewer.tscn` | **Địa Đạo Cổ Thành** | Vân Châu Vực | **APPROVED** | Mạng lưới cống ngầm cổ đại bí ẩn bên dưới Vân Châu. |

### 2.8. Vực 8: Trung Thổ Đại Lục (Overworld)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Overworld` | `1009372873` | `res://presets/maps/layers/overworld/Overworld.tscn` | **Trung Thổ Bình Nguyên** | Trung Thổ Đại Lục | **APPROVED** | Bình nguyên bao la kết nối các tông môn, thành trấn và bí cảnh. |

### 2.9. Vực 9: Đông Hải Vực & Linh Thuyền (Ocean & Ship)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Ocean` | `231511051` | `res://presets/maps/layers/ocean/Ocean.tscn` | **Đông Hải** | Đông Hải Vực | **APPROVED** | Đại dương mênh mông sóng vỗ ngàn trùng nối liền các châu lục. |
| `Ship First Deck` | `4229445336` | `res://presets/maps/layers/ship/Ship First Deck.tscn` | **Linh Thuyền - Thượng Tầng Giáp Bản** | Đông Hải Vực | **APPROVED** | Boong trên của chiến thuyền linh bảo vượt biển. |
| `Ship Second Deck` | `2122050188` | `res://presets/maps/layers/ship/Ship Second Deck.tscn` | **Linh Thuyền - Hạ Tầng Giáp Bản** | Đông Hải Vực | **APPROVED** | Boong dưới nơi hành khách và thủy thủ sinh hoạt. |
| `Ship Hold` | `1266994400` | `res://presets/maps/layers/ship/Ship Hold.tscn` | **Linh Thuyền - Để Thương** | Đông Hải Vực | **APPROVED** | Khoang đáy chứa linh tài, đan dược và vật tư hành trình. |
| `Ship Alige Hide` | `944914549` | `res://presets/maps/layers/ship/Ship Alige Hide.tscn` | **Linh Thuyền - Mật Thất** | Đông Hải Vực | **PROPOSED** | Căn phòng bí mật ẩn sâu dưới đáy thuyền. |
| `Ship Nard's Room` | `1234630261` | `res://presets/maps/layers/ship/Ship Nard's Room.tscn` | **Linh Thuyền - Thuyền Trưởng Thất** | Đông Hải Vực | **APPROVED** | Căn phòng riêng của vị thuyền trưởng lão luyện. (Chủ dự án duyệt) |

### 2.10. Vực 10: Vạn Yêu Quật (Splatyna Region)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Splatyna Cave Entrance` | `2961248192` | `res://presets/maps/layers/splatyna/Splatyna Cave Entrance.tscn` | **Vạn Yêu Quật - Động Khẩu** | Vạn Yêu Quật | **APPROVED** | Lối vào âm u chướng khí của sào huyệt yêu ma. |
| `Splatyna's Corridor` | `3863109455` | `res://presets/maps/layers/splatyna/Splatyna's Corridor.tscn` | **Vạn Yêu Quật - Huyết Lang Đạo** | Vạn Yêu Quật | **APPROVED** | Đường hầm đá dẫn sâu vào lòng huyệt động. |
| `Splatyna's Chamber` | `1514725053` | `res://presets/maps/layers/splatyna/Splatyna's Chamber.tscn` | **Vạn Yêu Quật - Yêu Vương Điện** | Vạn Yêu Quật | **APPROVED** | Gian phòng trung tâm sào huyệt nơi đại yêu ngự trị. |
| `Splatyna's Dorian Dead End` | `678881037` | `res://presets/maps/layers/splatyna/Splatyna's Dorian Dead End.tscn` | **Vạn Yêu Quật - Tuyệt Bích** | Vạn Yêu Quật | **PROPOSED** | Vách đá cụt ngập tràn chướng khí nguy hiểm. |
| `Splatyna's Gabriel Pit` | `575697006` | `res://presets/maps/layers/splatyna/Splatyna's Gabriel Pit.tscn` | **Vạn Yêu Quật - U Minh Uyên Khanh** | Vạn Yêu Quật | **PROPOSED** | Vực sâu tăm tối ẩn chứa hung hiểm dị thường. |
| `Splatyna's Marvin Hole` | `1258335808` | `res://presets/maps/layers/splatyna/Splatyna's Marvin Hole.tscn` | **Vạn Yêu Quật - Dị Linh Bí Quật** | Vạn Yêu Quật | **PROPOSED** | Hốc đá bí mật nơi dị linh tụ tập luyện ma công. |

### 2.11. Vực 11: Ma Giới Di Tích (Drazil)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `Drazil` | `2932080299` | `res://presets/maps/layers/drazil/Drazil.tscn` | **U Minh Di Tích** | Ma Giới Di Tích | **PROPOSED** | Vùng đất u ám hoang tàn ngập tràn ma khí và cấm chế tàn tích cổ. |

### 2.12. Vực 12: Bản Đồ Mở Rộng Tân Lập (Tier 3 Expansion Maps)

| Tên Gốc (Internal Name) | Map Hash ID | Đường Dẫn Scene (Scene Path) | Danh Xưng Tu Tiên (Display Name) | Khu Vực Phụ Thuộc (Parent Region) | Trạng Thái | Mô Tả Ngắn Gọn |
|---|---|---|---|---|---|---|
| `TanThuThon` | `1841251538` | `res://presets/maps/layers/xianxia/TanThuThon.tscn` | **Thanh Vân Thôn** | Thanh Vân Ngoại Vi | **APPROVED** | Ngôi làng tu tiên tân thủ yên bình với rặng tre, hoa đào, ruộng linh thảo và suối trong. |
| `SacredSectHub` | `995840901` | `res://assets/environment/SacredSectHub.tscn` | **Thánh Tông Tổng Đàn** *(Đề xuất)* / **Thánh Tông Sơn Môn** *(Thay thế)* | Tiên Gia Thánh Địa | **PENDING OWNER APPROVAL** | Sơn môn tổng đàn uy nghiêm của tông môn tu tiên. **Chưa quyết định danh xưng chính thức do danh tính và tên tông môn chưa được chốt.** |

---

## 3. THỐNG KÊ & TỔNG KẾT DANH XƯNG (42 BẢN ĐỒ)

- **Tổng số bản đồ đã quét và đăng ký:** 42 / 42 (100%)
- **Số lượng danh xưng ĐÃ DUYỆT (APPROVED):** **32 bản đồ** (76.2%)
  - *Phase 4.1.1 (24 bản đồ):* Tulimshar (và các phân khu Thành Chủ Phủ, Ngoại Vi), Artis, Artis Sewer, Overworld, Candor Cave, Ocean, Ship Deck/Hold, Splatyna Chamber/Corridor/Entrance, TanThuThon.
  - *Phase 4.1.2 Chủ dự án duyệt (8 bản đồ):* Cuồng Sa Hoang Địa, Cuồng Sa Khoáng Quật, U Minh Thâm Tầng, Xích Nham Sơn Mạch, Vạn Xà Khanh, Linh Sa Cổ Trấn, Hàn Băng Diễn Võ Đài, Linh Thuyền - Thuyền Trưởng Thất.
- **Số lượng danh xưng ĐỀ XUẤT CẬP NHẬT (PROPOSED):** **9 bản đồ** (21.4%)
  - Phế Khoáng Đạo, Xích Nham Thạch Động, Xích Sa Hãm Cốc, Linh Sa Hải Than, Linh Thuyền - Mật Thất, Vạn Yêu Quật - Tuyệt Bích, Vạn Yêu Quật - U Minh Uyên Khanh, Vạn Yêu Quật - Dị Linh Bí Quật, U Minh Di Tích.
- **Số lượng danh xưng CHỜ DUYỆT (PENDING OWNER APPROVAL):** **1 bản đồ** (2.4%)
  - `SacredSectHub`: Giữ trạng thái PENDING chờ quyết định chính thức về danh xưng và danh tính tông môn.
- **Tình trạng kiểm chứng code:** Bộ kiểm tra `tests/test_phase_4_1_1_naming.tscn` đạt **100% PASS** trên toàn bộ 42 bản đồ (32 APPROVED, 9 PROPOSED, 1 PENDING).
