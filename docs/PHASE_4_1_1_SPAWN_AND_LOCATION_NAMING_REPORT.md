# BÁO CÁO NGHIỆM THU — PHASE 4.1.1
## KHÔI PHỤC ĐIỂM XUẤT PHÁT TULIMSHAR & THIẾT LẬP HỆ THỐNG DANH XƯNG TU TIÊN

**Dự án:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Nền tảng:** Source of Mana (Pinned Commit `1933bd66caf2c59fd5d9b5df410d19838059b243`)  
**Engine:** Godot 4.7.1 Stable Official  
**Giai đoạn:** Phase 4.1.1 — Spawn Restoration & Location Naming System  
**Ngày thực hiện:** 03/11/2026  
**Trạng thái kiểm chứng:** **100% PASS (ĐẠT HOÀN TOÀN TRÊN TẤT CẢ TIÊU CHÍ KỸ THUẬT)**

---

## 1. TỔNG QUAN & ĐỊNH HƯỚNG CỐT LÕI

Thực hiện chuẩn xác theo quyết định chỉ đạo của Project Owner:
1. **Khôi phục Tulimshar làm điểm xuất phát mặc định:** Nhân vật mới tạo xuất hiện tại thành phố cảng Tulimshar (`LauncherCommons.DefaultStartMapID = "Tulimshar".hash()`), tọa độ `Vector2i(2176, 2560)`.
2. **Bảo toàn thế giới Source of Mana làm Main Game World:** Toàn bộ 40+ bản đồ gốc của Source of Mana tiếp tục đóng vai trò thế giới chính kết nối liên hoàn của Thiên Đạo Nghịch Mệnh. Bản đồ Thanh Vân Thôn (`TanThuThon`) và Thánh Tông Tổng Đàn (`SacredSectHub`) được định vị là các bản đồ mở rộng (Tier 3 Expansion Maps), không thay thế thế giới chính.
3. **Bản địa hóa danh xưng địa danh thuần Việt Tiên hiệp:** Toàn bộ tên địa danh hướng về người chơi (Player-Facing) được chuyển thành danh xưng Tu Tiên giàu phong vị kiếm hiệp/tiên hiệp.
4. **Bảo toàn tính bất biến của định danh kỹ thuật:** Mọi Internal Map ID (`hash`), đường dẫn scene (`.tscn`), đường dẫn tài nguyên (`.tres`), cấu trúc SQLite, và giao thức mạng RPC/ENet/WebSocket được giữ nguyên vẹn 100%.

---

## 2. TRIỂN KHAI KỸ THUẬT

### 2.1. Khôi phục điểm xuất phát mặc định (`LauncherCommons.gd`)
Tập tin [`sources/launcher/LauncherCommons.gd`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/launcher/LauncherCommons.gd) đã được hoàn nguyên về giá trị chuẩn:
```gdscript
# Map
static var DefaultStartMapID : int		= "Tulimshar".hash()
const DefaultStartPos : Vector2i		= Vector2i(2176, 2560)
const DefaultStartOffset : Vector2i		= Vector2i(64, 32)
```
- Nhân vật mới tạo sẽ khởi đầu tại cảng thị Tulimshar.
- Vị trí của các nhân vật đã lưu trong SQLite (`testing.db`) không bị can thiệp hay dịch chuyển cưỡng chế.

### 2.2. Kiến trúc ánh xạ danh xưng tập trung (`LocationNaming.gd`)
Xây dựng mô-đun đăng ký và tra cứu danh xưng tập trung tại [`sources/world/LocationNaming.gd`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/world/LocationNaming.gd):
- Cung cấp phương thức tĩnh `GetDisplayName(identifier)` linh hoạt, chấp nhận:
  - `MapData` / `FileData` object
  - `String` (Internal Name, ví dụ `"Tulimshar"`, `"Overworld"`)
  - `int` (Hash ID, ví dụ `2608626462`)
- **Cơ chế Fallback an toàn:** Nếu một định danh chưa có tên ánh xạ trong từ điển, hệ thống tự động trả về chuỗi tên gốc hoặc ID kỹ thuật, tuyệt đối không gây crash hoặc lỗi null pointer.
- Cung cấp phương thức `GetLocationInfo(identifier)` truy xuất siêu dữ liệu: khu vực trực thuộc (`region`), trạng thái duyệt (`status`), và mô tả bối cảnh (`description`).

### 2.3. Tích hợp trực tiếp vào `MapData.gd`
Mở rộng [`sources/db/instance/MapData.gd`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/db/instance/MapData.gd):
- Bổ sung thuộc tính `@export var displayName : String = ""` cho phép cấu hình trực tiếp từ inspector nếu cần.
- Bổ sung phương thức `func GetDisplayName() -> String` tự động ủy quyền qua `LocationNaming.GetDisplayName(self)`.

### 2.4. Bản địa hóa các vị trí hiển thị người chơi
1. **Banner thông báo khi nhập cảnh bản đồ:**  
   [`sources/network/client/Client.gd`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/network/client/Client.gd) (dòng 14):
   ```gdscript
   PushNotification(LocationNaming.GetDisplayName(mapData), _peerID)
   ```
2. **Lựa chọn tại cổng / NPC dịch chuyển (Warp Dialog):**  
   [`sources/scripts/generic/WarpGlobal.gd`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/scripts/generic/WarpGlobal.gd) (dòng 25):
   ```gdscript
   warpName = LocationNaming.GetDisplayName(mapData)
   ```
3. **Bảng thông tin nhân vật (Character Stats Window):**  
   [`sources/gui/character/Stats.gd`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/gui/character/Stats.gd) (dòng 15):
   ```gdscript
   locationLabel.set_text(LocationNaming.GetDisplayName(mapData))
   ```

---

## 3. DANH BẠ ĐỊA DANH & TRẠNG THÁI PHÊ DUYỆT (42 BẢN ĐỒ)

Toàn bộ 42 bản đồ hiện có trong cơ sở dữ liệu `DB.MapsDB` đã được lập danh bạ chi tiết tại [`docs/world/LOCATION_NAMING_REGISTRY.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/LOCATION_NAMING_REGISTRY.md):

### Phân loại trạng thái:
- **ĐÃ PHÊ DUYỆT CHÍNH THỨC (APPROVED): 24 bản đồ**
  - 12 địa danh cốt lõi do Project Owner phê duyệt: Tulimshar, Tulimshar Center, Tulimshar Bay, Tulimshar Beach, Tulimshar Castle, Overworld, Artis, Artis Sewer, Candor Cave, Splatyna, Ship, Ocean.
  - Các khu vực phân cấp trực thuộc theo chỉ đạo:
    - *Thành Chủ Phủ:* Hành Lang, Tây Sương Phòng, Tây Thành Tường.
    - *Thanh Sa Ngoại Vi:* Đông Lĩnh, Nam Lĩnh, Tây Lĩnh, Tây Nham Động.
    - *Vạn Yêu Quật:* Động Khẩu, Yêu Vương Điện, Huyết Lang Đạo.
    - *Linh Thuyền:* Thượng Tầng Giáp Bản, Hạ Tầng Giáp Bản, Để Thương.
    - *Bản đồ mở rộng:* Thanh Vân Thôn (`TanThuThon`).
- **ĐỀ XUẤT CHỜ CHỦ DỰ ÁN PHÊ DUYỆT (PROPOSED): 18 bản đồ**
  - Sa mạc bão cát: Cuồng Sa Hoang Địa, Cuồng Sa Khoáng Quật, Phế Khí Khoáng Đạo, U Minh Thâm Tầng.
  - Vực đá đỏ: Xích Nham Sơn Mạch, Xích Nham Động Quật, Xích Sa Hãm Khanh, Vạn Xà Khanh.
  - Ốc đảo ven biển: Linh Sa Cổ Trấn, Linh Sa Than Đầu.
  - Ngõ sâu Vạn Yêu Quật: Dorian Tuyệt Bích, Gabriel Uyên Khanh, Marvin Bí Quật.
  - Phòng đặc biệt trên tàu: Mật Thất Alige, Thuyền Trưởng Thất.
  - Di tích ma giới: U Minh Ma Vực (`Drazil`).
  - Võ đài băng tuyết: Hàn Băng Diễn Võ Đài (`Candor Arena`).
  - Tông môn mở rộng: Thánh Tông Tổng Đàn (`SacredSectHub`).

---

## 4. KẾT QUẢ KIỂM CHỨNG THỰC NGHIỆM

Mọi xác nhận đều được chứng thực thông qua mã kiểm tra thực thi độc lập:

| STT | Bài Kiểm Tra | Mục Tiêu Kiểm Chứng | Kết Quả Thực Tế | Trạng Thái |
| :---: | :--- | :--- | :--- | :---: |
| **01** | `test_phase_4_1_1_naming.tscn` | Khôi phục spawn `LauncherCommons`, kiểm tra tra cứu `LocationNaming` (String, Hash, MapData), kiểm tra fallback, audit toàn bộ 42 bản đồ. | 42/42 bản đồ định danh hợp lệ (24 APPROVED, 18 PROPOSED). Fallback chính xác. | **PASS** |
| **02** | `test_tan_thu_thon_load.tscn` | Kiểm tra tính nguyên vẹn của bản đồ mở rộng Thanh Vân Thôn và hai chiều warp với SacredSectHub. | Load thành công 61 Fringe nodes, Y-Sort hoạt động, liên kết warp bảo toàn. | **PASS** |
| **03** | `test_warp_two_way.tscn` | Kiểm tra dịch chuyển thực tế của nhân vật giữa Thanh Vân Thôn và Thánh Tông Tổng Đàn. | Dịch chuyển 2 chiều thành công với tọa độ chính xác. | **PASS** |
| **04** | `test_spawn_new_character.tscn` | **Tạo nhân vật mới trên Dedicated Server sống và kiểm tra điểm spawn thực tế trong thế giới game.** | Nhân vật spawn tại `(2174.0, 2590.0)` trong map `Tulimshar` (ID `2608626462`), tên hiển thị `"Thanh Sa Cảng"`. | **PASS** |
| **05** | `test_single_client.tscn` | Kiểm tra nhân vật cũ (`ThienKiem01`) không bị cưỡng chế dịch chuyển vị trí đã lưu. | Nhân vật cũ giữ nguyên vị trí SQLite tại `(1594.0, 1599.0)`. | **PASS** |
| **06** | Web Export (`builds/web/index.html`) | Biên dịch gói WebAssembly / HTML5 với logic spawn và danh xưng mới. | Biên dịch thành công với exit code 0. | **PASS** |

### Dẫn chứng log kiểm tra spawn nhân vật mới thực tế:
```
==========================================
[NewCharTest] SUCCESS: Player spawned in world!
[NewCharTest] Map ID: 2608626462 (Expected Tulimshar: 2608626462)
[NewCharTest] Map Display Name: Thanh Sa Cảng
[NewCharTest] Player Position: (2174.0, 2590.0)
==========================================
[NewCharTest] Check 1 (Map is Tulimshar): true
[NewCharTest] Check 2 (Pos within (2176,2560) ± (64,32)): true
[NewCharTest] Check 3 (Display name is 'Thanh Sa Cảng'): true

>>> EMPIRICAL VERIFICATION COMPLETE: ALL CHECKS PASSED! <<<
```

---

## 5. TUÂN THỦ PHẠM VI DỰ ÁN (SCOPE BOUNDARIES)

Giai đoạn 4.1.1 đã tuân thủ tuyệt đối các ranh giới:
- **KHÔNG** can thiệp hoặc thay đổi các file trong Asset Vault (`thien-dao-nghich-menh/public/assets`).
- **KHÔNG** xóa bỏ, đổi tên file hay sửa đổi cấu trúc map `.tscn` của bất kỳ bản đồ nào trong số 40+ bản đồ gốc.
- **KHÔNG** thay đổi mã hash kỹ thuật của bất kỳ bản đồ nào.
- **KHÔNG** thay thế NPC, monster, trang bị hay viết hệ thống gameplay mới ngoài phạm vi danh xưng địa danh và điểm xuất phát.

---

## 6. KẾT LUẬN & KIẾN NGHỊ

**Phase 4.1.1 đã hoàn thành trọn vẹn và sẵn sàng bàn giao.**

Dự án hiện đang duy trì:
- Điểm xuất phát mặc định chuẩn xác tại Thanh Sa Cảng (Tulimshar).
- Hệ thống danh xưng Tu Tiên hoàn chỉnh cho toàn bộ 42 bản đồ.
- Nền tảng server và client đa nền tảng (Desktop + Web) hoạt động ổn định.

> [!IMPORTANT]
> **Dừng lại và chờ phê duyệt:**  
> Đề nghị Project Owner xem xét danh mục 18 danh xưng đề xuất tại [`docs/world/LOCATION_NAMING_REGISTRY.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/LOCATION_NAMING_REGISTRY.md).  
> **Không tự ý chuyển sang Phase 4.2 khi chưa có lệnh phê duyệt chính thức.**
