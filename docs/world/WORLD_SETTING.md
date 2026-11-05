# THIÊN ĐẠO NGHỊCH MỆNH — WORLD SETTING & GEOGRAPHICAL REGIONS
## Document Code: DOC-WORLD-SETTING
## Status: MAPPING OF THE EXISTING MAIN GAME WORLD

---

### 1. Geographical Structure & Existing Map Integration

> [!IMPORTANT]
> **World Design & Technical Grouping Distinction (Phase 4.1.2):**
> The region groupings in this document and the Location Naming Registry are **technical map groupings and naming proposals based on verified engine map folders and technical warp connectivity**.
> They do **NOT** represent an officially approved geographical, political, or historical world map.
> 
> Development strictly abides by the following negative constraints:
> - Do NOT invent distances between regions.
> - Do NOT invent political relationships between territories, towns, or factions.
> - Do NOT invent historical chronicles or relationships.
> - Do NOT invent sect ownership over specific areas. The official sect identity and name have not yet been decided.
> - Do NOT invent travel routes beyond verified existing map connectivity in `serverData.spawns`.

The game world of Thiên Đạo Nghịch Mệnh retains the **original 40+ interconnected maps** of Source of Mana as its primary physical topology:

```
+---------------------------------------------------------------------------------------+
|                                THIÊN ĐẠO NGHỊCH MỆNH WORLD                            |
+---------------------------------------------------------------------------------------+
|  [VÙNG 1: BIÊN GIỚI SA MẠC & CẢNG THÀNH KHỞI ĐẦU] (Tonori / Tulimshar Region)       |
|  - Cảng Tulimshar, Vịnh Biển, Bờ Cát, Sa Mạc Vàng, Khe Núi, Mỏ Khoáng, Hố Cát Lún   |
|  * Vai trò: Khu vực khởi đầu chính thức của thế giới, nơi nhân vật chính xuất hiện.   |
+---------------------------------------------------------------------------------------+
|                                           │                                           |
|                                           ▼  (Hải Trình Thương Thuyền / Đường Bộ)     |
+---------------------------------------------------------------------------------------+
|  [VÙNG 2: HẢI VỰC & ĐẢO VẮNG] (Ship & Ocean Region)                                   |
|  - Boong tàu, Hầm tàu, Vùng biển sương mù, Hải lưu viễn đông                         |
|  * Vai trò: Giao thương đường thủy, hiểm họa yêu thú biển, bí cảnh ngoài khơi.        |
+---------------------------------------------------------------------------------------+
|                                           │                                           |
|                                           ▼                                           |
+---------------------------------------------------------------------------------------+
|  [VÙNG 3: TRUNG NGUYÊN ĐẠI LỤC] (Artis & Overworld Region)                            |
|  - Cố Đô Artis, Kênh Đào Ngầm, Đồng Bằng Rộng, Dãy Núi Phía Bắc                       |
|  * Vai trò: Trung tâm kinh tế, chính trị phàm trần và nơi giao lưu tán tu.            |
+---------------------------------------------------------------------------------------+
|                                           │                                           |
|                                           ▼                                           |
+---------------------------------------------------------------------------------------+
|  [VÙNG 4: HIỂM ĐỊA HANG ĐỘNG & ĐỊA ĐẠO] (Candor & Splatyna Region)                    |
|  - Động Candor, Đấu Trường Thử Lách, Mê Cung Splatyna, Hầm Đá Ngầm                    |
|  * Vai trò: Dungeon ngầm, nơi trú ngụ của yêu thú bóng tối và khoáng thạch cổ xưa.    |
+---------------------------------------------------------------------------------------+
|                                           │                                           |
|                                           ▼  (Các Nhánh Mở Rộng / Expansion Hubs)     |
+---------------------------------------------------------------------------------------+
|  [VÙNG 5: THÁNH ĐỊA TÔNG MÔN & THÔN TRANG ẨN DẬT] (Xianxia Expansion Realms)         |
|  - Tông Môn Thánh Địa (Sacred Sect Hub): Sơn môn tu tiên (danh xưng chính thức chờ duyệt)|
|  - Thanh Vân Thôn (TanThuThon): Thôn cổ ẩn mình trong núi, rừng đào, suối ngọc.      |
|  * Vai trò: Bản đồ mở rộng thế giới (Additional Maps), khám phá theo cốt truyện.     |
+---------------------------------------------------------------------------------------+
```

---

### 2. Detailed Region Mapping Matrix

| Existing SoM Region | Existing Scene Files | Xianxia Setting Name | Atmospheric & Narrative Identity |
|---|---|---|---|
| **Tonori Region** | `Tulimshar.tscn`, `Tulimshar Center.tscn`, `Tulimshar Bay.tscn`, `Tulimshar Beach.tscn`, `Tulimshar Castle.tscn`, `Tulimshar Western Cave.tscn`, `Desert Mines.tscn`, `Desert Pit.tscn`, `Sandstorm.tscn` (17 maps) | **Hải Cảng Cổ & Biên Giới Hoang Mạc** | Cảng thành đá cổ ven sa mạc, nơi thương nhân và ngư dân sinh sống. Cửa ngõ mà nhân vật chính lần đầu đặt chân tới thế giới tu tiên. |
| **Overworld Region** | `Overworld.tscn` | **Đồng Bằng Trung Thổ** | Vùng đất bình nguyên bao la kết nối các châu phủ, rải rác đồn điền nông nghiệp, quán trọ và miếu cổ. |
| **Artis Region** | `Artis.tscn`, `Artis Sewer.tscn` | **Kinh Đô Cổ Thành** | Thành trì phồn hoa tráng lệ với tường thành đá hoa cương, kênh đào và hệ thống cống ngầm bí mật. |
| **Candor Region** | `Candor Cave.tscn`, `Candor Arena.tscn` | **Hàn Băng Thạch Động & Di Tích Võ Đài** | Hang động đá lạnh lẽo nơi lưu giữ những vết tích cổ đại từ thời thượng cổ đại chiến. |
| **Splatyna Region** | `Splatyna's Chamber.tscn`, `Splatyna Cave Entrance.tscn`, `Splatyna's Corridor.tscn`, v.v. (6 maps) | **Vạn Yêu Quỷ Quật** | Quần thể hang ngầm sâu dưới lòng đất, chứa nhiều yêu thú hung tợn và khoáng thạch linh dị. |
| **Ship & Ocean** | `Ship First Deck.tscn`, `Ship Second Deck.tscn`, `Ship Hold.tscn`, `Ocean.tscn` (6 maps) | **Viễn Dương Linh Thuyền** | Đội thuyền buôn vượt biển lớn, nơi đối mặt với phong ba bão táp và yêu thú biển sâu. |
| **Xianxia Expansions** | `SacredSectHub.tscn`, `TanThuThon.tscn` | **Tông Môn Sơn & Thanh Vân Thôn** | Các địa điểm mở rộng bổ sung: Sơn môn tu tiên trên mây và ngôi làng ẩn dật giữa thung lũng. |

---

### 3. World Transformation Principles

1. **Topological Preservation:** All existing scene geometry, collision boundaries, and warp triggers connecting the 40 original maps remain valid.
2. **Incremental Asset & Lore Ingestion:** Maps transition into Xianxia by swapping tileset art, updating ambient soundscapes, introducing Chinese architectural props, and replacing NPC dialogues.
3. **No Breakage of Map IDs:** The hash IDs of existing maps (e.g. `Tulimshar.hash()`, `Overworld.hash()`) are permanent database and networking keys. They must never be deleted or replaced.
