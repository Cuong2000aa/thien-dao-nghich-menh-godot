# Cây kỹ năng theo Hình Thể (Hero Skill Trees)

**Project:** Thiên Đạo Nghịch Mệnh  
**Source of truth:** `sources/actor/HeroSkillTree.gd`  
**UI:** `sources/gui/SkillTreeWindow.gd`  
**Grant:** tạo NV (`Server.CreateCharacter`) · lên cấp (`Stats.AddExperience`) · vào game (`Progress.ImportProgress`)  
**Combat data:** `presets/cells/skills/*.tres` (ưu tiên khi cast) · `CombatSystem.MARTIAL_CATALOG` (fxKey / element / qiCost)

---

## 1. Tổng quan

| Class (`hero_id`) | Entity shape | Fantasy | Skill khi max (Độ Kiếp) |
|---|---|---|---:|
| **Kiếm Khách** (`swordsman`) | `Player` | Kiếm tông, trận pháp, thuẫn, vạn kiếm | **12** |
| **Kiếm Sĩ** (`wuxia_swordsman`) | `PlayerWuxiaSword` | Một kiếm / lôi-hàn, burst | **12** |
| **Ảnh Sát** (`assassin`) | `PlayerAssassin` | Độc, ẩn, hút, SoM utility | **12** |

- **Cộng 3 class (ô trên cây):** 36 slot (mỗi class 12 skill name, kể Melee + Run).  
- **Unique skill names ≈ 28** (trùng `Melee`, `Run`, `Đạp Phong Bộ`, `Thanh Phong Kiếm Khí` giữa class).  
- Cây **full** Phàm Thân → Độ Kiếp (10 mốc cảnh giới).  
- Hotbar ~10 ô: học đủ 12 nhưng chỉ gắn phím những chiêu then chốt.

### So sánh nhanh 3 class

| | Kiếm Khách | Kiếm Sĩ | Ảnh Sát |
|---|---|---|---|
| Vai trò | Tanky clear / trụ | Burst / kite | Hit-and-run |
| Phòng thủ | Thuẫn + hồi | Ít | Bế Tán + Morph |
| Ult giữa game | Vạn Kiếm (lv27) | Nhất Kiếm (lv19) | Huyền Âm + độc |
| Ult Độ Kiếp | Hư Không Hấp Tinh | Hỏa Châu (Flar) | U Ảnh Tiễn |
| VFX chính | PixelFX | Pixel + SoM muộn | Nhiều SoM |

---

## 2. Map cảnh giới → `min_level`

Theo `Cultivation.REALMS` (nhãn trên cây = `realm_label` trong code):

| `min_level` | Cảnh giới (nhãn cây) | Ghi chú unlock |
|---:|---|---|
| 1 | Phàm Thân | Starter lúc tạo NV |
| 4 | Tụ Khí • Tầng 3 (Sơ Kỳ) | Skill thứ 4 |
| 10 | Tụ Khí • Tầng 9 (Viên Mãn) | Trước Thông Mạch |
| 11 | Thông Mạch • Sơ Kỳ | |
| 19 | Đạo Cơ • Sơ Kỳ | |
| 27 | Huyền Đan • Sơ Kỳ | |
| 35 | Nguyên Thần • Sơ Kỳ | |
| 43 | Thiên Nhân • Sơ Kỳ | |
| 51 | Quy Hư • Sơ Kỳ | |
| 61 | Độ Kiếp • Sơ Kỳ | Skill tối thượng |

`GrantSkillsToActor(actor, level)` mở **mọi** skill có `min_level ≤ level`.

---

## 3. Quy ước số liệu

Cột trong bảng chi tiết lấy từ `.tres`:

| Cột | Nguồn |
|---|---|
| **ATK** | Modifier `Attack` hoặc `MAttack` |
| **LP** | Modifier `Mana` (âm = tiêu hao Linh Lực) |
| **Hồi** | Modifier `Health` dương |
| **TL** | Modifier `Stamina` |
| **CD / Cast / Tầm** | `cooldownTime` / `castTime` / `skillRange` |
| **qiCost / fxKey** | `MARTIAL_CATALOG` (có thể lệch nhẹ CD/range so với `.tres`) |
| **VFX** | `pixel` = PixelFX qua `fxKey`; `som` = particle SoM / legacy preset |

UI `SkillTreeWindow` hiện dòng stats qua `HeroSkillTree.FormatSkillStats(cell)`.

---

## 4. Kiếm Khách — full 12 skill

**Fantasy:** ngoại môn Trúc Sơn → trụ cột tông môn. Mở bằng kiếm khí Mộc, vững bằng thuẫn + thánh quang, tuyệt bằng vạn kiếm Kim, Độ Kiếp nuốt hư không.

| Lv | DB `name` | Title UI | Vai trò | ATK | LP | CD | Cast | Tầm | fxKey / VFX | Element |
|---:|---|---|---|---:|---:|---:|---:|---:|---|---|
| 1 | Melee | Kiếm Căn Bản | Đánh thường | 1 | — | — | — | — | hit slash (skip cast FX) | Kim |
| 1 | Run | Khinh Thân | Toggle chạy | — | — | — | — | — | `haste` | Mộc |
| 1 | Thanh Phong Kiếm Khí | Thanh Phong Kiếm Khí | Poke Mộc xa | 25 | −8 | 2.0s | 0.2s | 160 | `sword_combo` · pixel | Mộc |
| 4 | Đạp Phong Bộ | Đạp Phong Bộ | Dash + i-frame ~0.35s | — | −6 | 3.0s | — | — | `dash_strike` · pixel | Mộc |
| 10 | Trúc Sơn Kiếm Trận | Trúc Sơn Kiếm Trận | AoE quanh thân | 45 | −18 | 5.0s | 0.4s | 90 | `spin_slash` · pixel | Mộc |
| 11 | Quy Nguyên Hộ Thể Thuẫn | Quy Nguyên Hộ Thể Thuẫn | Shield (~80 / 6s martial) | — | −10 | 8.0s | — | — | `divine_shield` · pixel | Thổ |
| 19 | Thánh Quang Hộ Đạo | Thánh Quang Hộ Đạo | Hồi KH | hồi 60 | −8 | 7.0s | 0.4s | 0 | `holy_smite` · pixel | Mộc |
| 27 | Vạn Kiếm Quy Tông | Vạn Kiếm Quy Tông | Ult Kim AoE | 85 | −28 | 12.0s | 0.45s | 140 | `van_kiem_quy_tong` · pixel | Kim |
| 35 | Hỏa Long Phun Tức | Hỏa Long Phun Tức | Cone Hỏa | 45 | −12 | 5.0s | 0.35s | 120 | `fire_breath` · pixel | Hỏa |
| 43 | Địa Long Phá Sơn | Địa Long Phá Sơn | AoE Thổ | 65 | −14 | 6.5s | 0.35s | 110 | `earth_stomp` · pixel | Thổ |
| 51 | Mana Burst | Linh Bộc | Burst pháp quanh thân | 20 | −8 | 1.0s | 2.0s | 40 | `mana_burst` · som/pixel | Kim |
| 61 | Hư Không Hấp Tinh | Hư Không Hấp Tinh | Ult Độ Kiếp | 90 | −24 | 14.0s | 0.6s | 130 | `black_hole` · pixel | Hỏa |

**Rotation gợi ý (mid):** Đạp Phong → Trúc Sơn / Hỏa Long clear → Thuẫn khi dồn sát thương → Vạn Kiếm khi pack dày → Hư Không khi boss phase.

**Lore từng chiêu (UI `desc`):**

1. **Kiếm Căn Bản** — Đòn cận chiến nền tảng; mọi Hình Thể luyện từ ngày nhập đạo.  
2. **Khinh Thân** — Chạy nhanh đổi thể lực; né và reposition.  
3. **Thanh Phong Kiếm Khí** — Một đạo kiếm khí Mộc phóng xa; chiêu mở đầu ngoại môn Trúc Sơn.  
4. **Đạp Phong Bộ** — Lướt ngắn, thoáng vô địch; engage / né / bắt lưng.  
5. **Trúc Sơn Kiếm Trận** — Lục đạo kiếm quang xoay quanh thân; phá giáp, kiểm soát đám.  
6. **Quy Nguyên Hộ Thể Thuẫn** — Kim quang hộ thể hấp thụ thương; trụ cột sinh tồn.  
7. **Thánh Quang Hộ Đạo** — Hồi khí huyết, thanh tẩy; bổ sung sau khi đã có thuẫn.  
8. **Vạn Kiếm Quy Tông** — Vạn kiếm đồng quy; sát phạt diện rộng Kim hệ.  
9. **Hỏa Long Phun Tức** — Kiếm ý dẫn Hỏa phun phía trước.  
10. **Địa Long Phá Sơn** — Chấn địa Thổ; AoE nặng khi đã vững trụ.  
11. **Linh Bộc** — Bộc phát linh lực SoM quanh thân.  
12. **Hư Không Hấp Tinh** — Thiên giai nuốt linh khí vào điểm vô cực.

---

## 5. Kiếm Sĩ — full 12 skill

**Fantasy:** một kiếm phá thế. Hàn mở đường, lôi nối, Nhất Kiếm kết; muộn game thêm Hỏa/sóng SoM đa thuộc tính. Ít thuẫn hơn Kiếm Khách.

| Lv | DB `name` | Title UI | Vai trò | ATK | LP | CD | Cast | Tầm | fxKey / VFX | Element |
|---:|---|---|---|---:|---:|---:|---:|---:|---|---|
| 1 | Melee | Kiếm Căn Bản | Nền cận | 1 | — | — | — | — | slash | Kim |
| 1 | Run | Khinh Thân | Chạy | — | — | — | — | — | `haste` | Mộc |
| 1 | Hàn Băng Thiên Kiếm | Hàn Băng Thiên Kiếm | Poke Thủy | 40 | −10 | 4.0s | 0.3s | 180 | `ice_lance_throw` · pixel | Thủy |
| 4 | Đạp Phong Bộ | Đạp Phong Bộ | Engage / rút | — | −6 | 3.0s | — | — | `dash_strike` · pixel | Mộc |
| 10 | Tử Lôi Liên Hoàn | Tử Lôi Liên Hoàn | Chain Kim | 35 | −9 | 3.5s | 0.2s | 200 | `chain_lightning` · pixel | Kim |
| 11 | Thanh Phong Kiếm Khí | Thanh Phong Kiếm Khí | Wave phụ Mộc | 25 | −8 | 2.0s | 0.2s | 160 | `sword_combo` · pixel | Mộc |
| 19 | Nhất Kiếm Trảm Thiên Môn | Nhất Kiếm Trảm Thiên Môn | Signature burst | 110 | −36 | 16.0s | 0.55s | 160 | `nhat_kiem_tram_thien_mon` · pixel | Kim |
| 27 | Lôi Phạt Cửu Thiên | Lôi Phạt Cửu Thiên | Finisher AoE | 70 | −18 | 8.0s | 0.5s | 150 | `lightning_call` · pixel | Kim |
| 35 | Bát Hoang Liệt Không Quyền | Bát Hoang Liệt Không Quyền | Stun cận (~1.5s) | 40 | −12 | 4.0s | 0.2s | 28 | `ground_pound` · pixel | Kim |
| 43 | Spitfire | Liệt Hỏa Phún | Cone Hỏa SoM | 20 | −5 | 1.0s | — | 32 | `fire_breath` · som | Hỏa |
| 51 | Sonic Wave | Âm Lang Kiếm | Poke sóng | 50 | −10 | 3.0s | — | 64 | `thunderclap` · som | Kim |
| 61 | Flar | Hỏa Châu | Projectile Hỏa | 50 | −10 | 3.0s | 1.0s | 120 | `fireball_throw` · som | Hỏa |

**Rotation gợi ý:** Hàn Băng poke → Đạp Phong vào → Nhất Kiếm → Lôi Phạt khi cụm → Bát Hoang nếu cần stun → Hỏa Châu kết liễu.

**Lore từng chiêu:**

1–2. Nền Melee / Khinh Thân.  
3. **Hàn Băng Thiên Kiếm** — Hàn kiếm xuyên thấu; chậm địch, poke trước áp sát.  
4. **Đạp Phong Bộ** — Nhịp võ hiệp: vào tầm một kiếm hoặc rút sau burst.  
5. **Tử Lôi Liên Hoàn** — Tử lôi nhảy mục tiêu; clear nhanh khi kite.  
6. **Thanh Phong Kiếm Khí** — Sóng phụ khi Hàn đang CD.  
7. **Nhất Kiếm Trảm Thiên Môn** — Xé thiên môn; CD dài, ATK cực cao.  
8. **Lôi Phạt Cửu Thiên** — Cửu thiên lôi phạt; finisher diện rộng.  
9. **Bát Hoang Liệt Không Quyền** — Quyền kình choáng khi đã lướt vào.  
10. **Liệt Hỏa Phún** — Phun lửa SoM đa thuộc tính.  
11. **Âm Lang Kiếm** — Sóng âm poke khoảng cách an toàn.  
12. **Hỏa Châu** — Kết thúc Độ Kiếp; đốt nốt sinh lực.

---

## 6. Ảnh Sát — full 12 skill

**Fantasy:** lén, độc, hút hồn, thân pháp ẩn. Ít đứng trận; Độ Kiếp kết bằng tiễn bóng tối. Nhiều skill DB name tiếng Anh (SoM) nhưng title UI đã Việt hóa.

| Lv | DB `name` | Title UI | Vai trò | ATK | LP / khác | CD | Cast | Tầm | fxKey / VFX | Element |
|---:|---|---|---|---:|---|---:|---:|---:|---|---|
| 1 | Melee | Kiếm Căn Bản | Nền | 1 | TL −10 | — | — | — | slash | Kim |
| 1 | Run | Khinh Thân | Chạy | — | — | — | — | — | `haste` | Mộc |
| 1 | Đạp Phong Bộ | Đạp Phong Bộ | Vào lưng / thoát | — | LP −6 | 3.0s | — | — | `dash_strike` · pixel | Mộc |
| 4 | Poison | Ẩn Độc | DoT | 1 | RegenHealth −1 | 15.0s | 0.1s | — | `poison_cloud` · som | Mộc |
| 10 | Huyền Âm Thôn Hồn | Huyền Âm Thôn Hồn | Hút / execute | 55 | LP −15 | 6.0s | 0.4s | 100 | `hex_sigil` · pixel | Thủy |
| 11 | Morph | Ảo Ảnh Thân | Escape / re-stealth | — | LP −50, TL −50 | 5.0s | 10.0s | — | `blink_out` · som | Thủy |
| 19 | Inma | Hàn Độc Chỉ | Hồi / poke | hồi 50 | LP −10, TL −15 | 5.0s | 3.0s | 128 | `ice_lance_throw` · som | Thủy |
| 27 | Betsanc | Bế Tán Chú | Buff Def/MDef +50, Dodge +8% | — | LP −20, TL −20 | 30.0s | 5.0s | — | `arcane_orb` · som | Kim |
| 35 | Jump | Túng Địa Dược | Nhảy địa hình | — | — | 5.0s | 0.5s | 256 | `dash_strike` · som | Mộc |
| 43 | Sonic Scream | Phá Âm Tiếu | CC / sát gần | 10 | LP −2 | 3.0s | — | 64 | `thunderclap` · som | Kim |
| 51 | Leaf Blades | Lạc Diệp Nhẫn | Kite xa | 30 | LP −10 | 1.0s | 2.0s | 40 | `leaf_storm` · som | Mộc |
| 61 | Archer | U Ảnh Tiễn | Sniper | 1 | TL −10 | — | — | 100 | `arrow_shot` · som | Mộc |

**Rotation gợi ý:** Bế Tán trước fight lớn → Đạp Phong lưng → Poison → Huyền Âm sustain → Morph thoát → Leaf/Archer kite.

**Lore từng chiêu:**

1–2. Nền.  
3. **Đạp Phong Bộ** — Skill mở đầu bắt buộc: vào lưng hoặc thoát vây.  
4. **Ẩn Độc** — Mòn khí huyết theo thời gian; kết hợp đánh thường.  
5. **Huyền Âm Thôn Hồn** — Hút sinh cơ; sustain chính khi đã dính độc.  
6. **Ảo Ảnh Thân** — Biến ảo, tái vị trí, thoát khóa mục tiêu (cast nặng).  
7. **Hàn Độc Chỉ** — Chạm hàn độc / hồi nhẹ tùy ngữ cảnh.  
8. **Bế Tán Chú** — Buff phòng/né dài; cast trước giao tranh lớn.  
9. **Túng Địa Dược** — Nhảy địa hình ngoài Đạp Phong.  
10. **Phá Âm Tiếu** — Siêu âm khi bị vây sau lộ hình.  
11. **Lạc Diệp Nhẫn** — Mưa lá kiếm kite.  
12. **U Ảnh Tiễn** — Tiễn từ bóng tối; không lộ kiếm khí.

---

## 7. VFX quy ước

| Tag trong cây (`vfx`) | Runtime |
|---|---|
| **pixel** | `CombatVisualSystem.PlaySkillFx` theo `fxKey` trong `MARTIAL_CATALOG` |
| **som** | Legacy SoM `skillPreset` / GPUParticles; vẫn có thể map `fxKey` PixelFX (1020–1033) |

Particle SoM: `presets/effects/particles/`.  
PixelFX keys ví dụ: `sword_combo`, `spin_slash`, `van_kiem_quy_tong`, `black_hole`, `poison_cloud`, …

---

## 8. UI & luồng người chơi

1. **Tạo NV:** chọn Hình Thể → **Cây Kỹ Năng** xem preview class (không còn chọn Hệ Tu Luyện).  
2. **Trong game:** Tu Luyện → **Cây Kỹ Năng** — khóa/mở theo cấp; mỗi ô: icon + title + lore + dòng `ATK · LP · CD · Tầm`.  
3. **Lên cấp:** `GrantSkillsBetweenLevels` → `AddSkill` + notify `Lĩnh ngộ: <title>`.  
4. **NV cũ:** `ImportProgress` catch-up theo level hiện tại.  
5. **Starter payload:** mọi skill `min_level ≤ 1` của class (Melee + Run + skill mở đầu class).

---

## 9. File liên quan

| File | Việc |
|---|---|
| `sources/actor/HeroSkillTree.gd` | Data cây, grant, `FormatSkillStats` |
| `sources/gui/SkillTreeWindow.gd` | UI cây |
| `sources/network/server/Server.gd` | Starter skills theo `shape` |
| `sources/actor/Stats.gd` | Grant khi level-up |
| `sources/actor/Progress.gd` | Catch-up lúc import |
| `presets/cells/skills/*.tres` | Description VI + modifier combat |
| `sources/combat/CombatSystem.gd` | `MARTIAL_CATALOG` / PixelFX |
| `sources/actor/HeroLibrary.gd` | Map Hình Thể ↔ `hero_id` |

---

## 10. Việc còn mở (cân bằng / polish)

- Đồng bộ tuyệt đối `qiCost` martial ↔ `Mana` trong `.tres` (một số skill martial CD/range khác `.tres` vài phần mười giây).  
- Icon art riêng theo class (hiện reuse SoM / skill PNG).  
- Hotbar loadout 10 chiêu gắn phím tách khỏi danh sách “đã học”.  
- Cân lại Morph cast 10s / Poison ATK 1 / Archer ATK 1 nếu combat cảm thấy yếu ở endgame.
