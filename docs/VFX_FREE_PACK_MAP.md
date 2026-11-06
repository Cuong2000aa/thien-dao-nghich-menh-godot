# Free VFX packs → skill mapping (TDNM)

## Packs đã lấy về

| Pack | License | Path | Ghi chú |
|---|---|---|---|
| **Kenney Particle Pack** | CC0 | `assets/vfx/kenney/` (+ subset `data/graphics/effects/particles/kenney/`) | Soft particle textures cho SoM `GPUParticles2D` |
| **Saltmire Spark** | MIT | `addons/saltmire_spark/` + autoload `Spark` | Burst juice dưới PixelFX hit |
| IceMaan / Stonebit / Brackeys / Stylized Lite | — | **chưa tải được** (itch.io cần login / 403 CLI) | Tải tay vào `assets/vfx/_incoming/` nếu muốn thêm sheet pixel |

## Gắn Kenney → SoM particle scenes

| Texture Kenney | Scene / skill |
|---|---|
| `fire_01.png` | `Flar.tscn` (đạn Flar / Hỏa Châu) |
| `smoke_05.png` | `Jump.tscn`, `Morph.tscn` |
| `magic_01.png` | `Betsanc.tscn` |
| `magic_05.png` | `ManaBurst.tscn` (Linh Bộc) |

## Gắn PixelFX + Spark → skill (sau QA)

| Skill | fxKey (cast) | hitFx | Spark juice |
|---|---|---|---|
| Flar | `fireball_throw` | `crit_hit` | hit |
| Spitfire | `fire_breath` | `hit_spark` | hit |
| **Inma** | `blessing` *(đổi — không dùng `heal` vì sheet có silhouette NV)* | `heal_aoe` | pickup |
| **Lum** | `heal_aoe` | `feather_burst` | pickup |
| Mana Burst | `mana_burst` | `hit_flash` | hit |
| Leaf Blades | `leaf_storm` | `thorns` | pickup |
| Sonic Scream | `thunderclap` | `blunt_hit` | dust |
| **Sonic Wave** | `arcane_beam` *(tách khỏi scream)* | `zap_hit` | hit |
| Archer | `arrow_shot` | `hit_spark` | hit |
| **Jump** | `blink_in` *(tách khỏi Đạp Phong)* | — | — |
| Morph | `blink_out` | — | — |
| Poison | `poison_cloud` | `thorns` | pickup |
| Betsanc | `arcane_orb` | `zap_hit` | hit |
| Thánh Quang Hộ Đạo | `holy_smite` | `heal_aoe` *(không còn `heal` bake body)* | pickup |
| Hàn Băng Thiên Kiếm | `ice_lance_throw` | `ice_spikes` | pickup |
| Melee / kiếm slash | — | `slash` → alias `sword_slash` | hit |

## QA / PM notes (đã chặn)

1. **`heal.png` có nhân vật xám baked** → cấm gắn cast/hit lên player (double body). Dùng `blessing` / `heal_aoe` / `feather_burst`.  
2. Sonic Wave ≠ Sonic Scream (trước đây cùng `thunderclap`).  
3. Jump ≠ Đạp Phong (trước đây cùng `dash_strike`).  
4. Kenney textures là **grayscale soft** — màu lấy từ `ParticleProcessMaterial.color` / additive blend.  
5. itch packs (IceMaan 150 FX, Stonebit, Brackeys) vẫn là bước tiếp theo nếu muốn sheet pixel mới ngoài PixelFX sẵn có.

## Cách tải tay (itch)

1. Mở pack → Download  
2. Giải vào `assets/vfx/_incoming/<pack-name>/`  
3. Báo agent map thêm vào `PixelFxLibrary.CATALOG` + `MARTIAL_CATALOG`
