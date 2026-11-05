# TDNM — SKILL SYSTEM ARCHITECTURE & XIANXIA COMPATIBILITY AUDIT
## Phase 4.2.2 Technical Investigation

**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Date:** 2026-11-03  
**Status:** VERIFIED & EMPIRICALLY AUDITED  
**Scope Boundary:** Documentation and Technical Audit ONLY

---

## 1. SKILL SYSTEM ARCHITECTURE

Skills in Source of Mana are defined as individual Scriptable Resources (`SkillCell.gd` inheriting `BaseCell.gd`) residing in [`presets/cells/skills/`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/presets/cells/skills/).

### 1.1. Core Skill Properties (`SkillCell.gd`)
- `mode`: Target mode (`SINGLE = 0`, `ZONE = 1`, `SELF = 2`).
- `category`: `NONE = 0`, `COMBAT = 1`, `PASSIVE = 2`, `ABILITY = 3`.
- `skillRange`: Maximum distance in pixels from caster to target.
- `castTime`: Channeling duration before execution begins.
- `cooldownTime`: Time interval before the skill can be re-cast.
- `castWalk`: Boolean allowing or forbidding movement during channeling.
- `castPreset`: Particle scene instantiated at character origin during channeling.
- `skillPreset`: Particle scene instantiated upon skill release.
- `projectilePreset`: Node/particle instantiated for travel toward target.
- `buffPreset`: Looping particle node attached to character during buff duration.
- `cellScript`: GDScript handler for custom abilities (`RunAbility.gd`, `JumpAbility.gd`, `MorphAbility.gd`).

---

## 2. COMPLETE INVENTORY OF EXISTING SKILLS (15 SKILLS)

| Skill ID | Skill Name | Mode | Cast VFX | Projectile / Impact VFX | SFX Used | Hit Timing | Current Runtime Status |
|---|---|:---:|---|---|---|:---:|:---:|
| `229218829` | **Melee** | Single | None | None (Built-in blade arc) | `hit.ogg` / `crit.ogg` | `castAttackDelay` | `VERIFIED` (Active Base Attack) |
| `2101614743` | **Archer** | Single | None | `Arrow.tscn` | `attack.ogg` | Delay + travel | `VERIFIED` |
| `3195155981` | **Betsanc** | Self/Zone | `casts/Betsanc.tscn` | `Betsanc.tscn` (Holy light) | `heal.ogg` | `castTime` | `VERIFIED` |
| `2089110122` | **Flar** | Single | `casts/Flar.tscn` | `Flar.tscn` (Fire projectile) | `attack.ogg` | Delay + travel | `VERIFIED` |
| `3196942940` | **Inma** | Self | `casts/Inma.tscn` | Invisibility toggle | `skillup.ogg` | Instant | `VERIFIED` |
| `229153592` | **Jump** | Self | `casts/Jump.tscn` | `Jump.tscn` (Dust leap) | None | Ability script | `VERIFIED` |
| `2553926615` | **LeafBlades**| Zone | `casts/LeafBlades.tscn`| `LeafBlades.tscn` (Leaves) | `attack.ogg` | `castTime` | `VERIFIED` |
| `193855594` | **Lum** | Self | `casts/Lum.tscn` | Light radius increase | `skillup.ogg` | Instant | `VERIFIED` |
| `1419799298` | **ManaBurst** | Zone | `casts/ManaBurst.tscn` | `ManaBurst.tscn` (Energy nova)| `attack.ogg` | `castTime` | `VERIFIED` |
| `229221151` | **Morph** | Self | `casts/Morph.tscn` | `Morph.tscn` (Smoke burst) | `skillup.ogg` | Ability script | `VERIFIED` |
| `2726514457` | **Poison** | Single | None | `PoisonBubbles.tscn` | `hit.ogg` | DoT Tick | `VERIFIED` |
| `193897858` | **Run** | Self | None | None (Speed boost) | None | Toggle | `VERIFIED` |
| `1341857997` | **SonicScream**| Zone | None | `SonicScream.tscn` (Rings) | `attack.ogg` | Instant | `VERIFIED` |
| `1885994244` | **SonicWave** | Single | None | `SonicWave.tscn` (Wave) | `attack.ogg` | Travel delay | `VERIFIED` |
| `3537877209` | **Spitfire** | Zone | None | `Spitfire.tscn` (Cone fire) | `attack.ogg` | Instant | `VERIFIED` |

---

## 3. AUDIT OF CURRENT SKILL IMPLEMENTATION GAPS

1. **Reusing Normal Attack Animations:**
   - There are **no custom casting animations** for the Swordsman. When casting `Flar`, `Betsanc`, or `ManaBurst`, the Swordsman plays `idle_dir` with a floor particle circle (`casts/*.tscn`), then snaps to `attack_dir` for release.
   - Traditional Daoist hand seals (Kết Ấn) or sword channeling stances are completely absent.
2. **Generic Projectiles:**
   - Projectiles travel along a strict linear path from caster to target position (`Interactive.gd:191-196`).
   - Flying weapons do not arc, orbit, pierce through multiple targets, or return to the caster.
3. **Disconnected Visual FX from Damage:**
   - Damage is calculated by server timers and applied instantly upon timer timeout, whereas particle bursts on client run on autonomous lifetimes (`GPUParticles2D.lifetime`). If a mob moves away during projectile travel, the floating damage number still spawns at the target's current position.

---

## 4. FUTURE XIANXIA SKILL COMPATIBILITY MATRIX

> [!NOTE]
> All Xianxia skill names, technique categories, and spell concepts below are **engineering design proposals (`[PROPOSED]`)** intended solely to evaluate engine architecture compatibility. None of these names represent approved canon lore until officially authorized by the Project Owner.

Every iconic Chinese cultivation martial technique has been evaluated against the existing Source of Mana architecture:

| Xianxia Skill Category | Example In-Game Name | Technical Classification | Required Architectural Work | Feasibility |
|---|---|:---:|---|:---:|
| **Sword Qi Projectile (Kiếm Khí)** | *Phá Không Kiếm Khí* | **SUPPORTED WITH CONFIGURATION** | Re-skin `SonicWave.tscn` with blue/gold crescent blade shader. | **High** |
| **Multi-Sword Nova (Vạn Kiếm)** | *Vạn Kiếm Quy Tông* | **SUPPORTED WITH CONFIGURATION** | Re-skin `ManaBurst.tscn` with 8 sword meshes radiating outward. | **High** |
| **Palm Strikes (Chưởng Pháp)** | *Huyền Âm Chưởng* | **SUPPORTED** | Direct mapping to `Melee.tres` with frost palm impact particle. | **Immediate** |
| **Flying Sword (Ngự Kiếm Thuật)** | *Ngự Kiếm Xuất Khiếu* | **REQUIRES EXTENSION** | Extend `Projectile.gd` with bezier curve homing and return-to-hand logic. | **Medium** |
| **Five-Element Magic (Ngũ Hành Thuật)**| *Tam Muội Chân Hỏa / Huyền Thủy*| **SUPPORTED WITH CONFIGURATION** | Re-skin `Flar.tres` (Fire), `LeafBlades.tres` (Wood/Wind), create Water/Lightning particles. | **High** |
| **Defensive Barrier (Kim Chung Tráo)** | *Hộ Thể Cương Khí* | **SUPPORTED** | Re-skin `Inma.tres` / `Betsanc.tres` buffPreset with rotating Daoist talisman barrier. | **Immediate** |
| **Sword Formation (Kiếm Trận)** | *Lục Hợp Kiếm Trận* | **REQUIRES NEW SYSTEM** | New `ZoneModifier` persistent entity spawning boundary swords and DOT field. | **Medium** |
| **Qinggong Dash (Lăng Ba Vi Bộ)** | *Bát Hoang Du Long Bộ* | **SUPPORTED WITH CONFIGURATION** | Wire `qinggong_sheet.png` to `stat.isRunning` in `Visual.gd`. | **Immediate** |
| **Soul Escape / Possession (Đoạt Xá)**| *Nguyên Thần Xuất Khiếu* | **REQUIRES NEW SYSTEM** | High-realm narrative/combat transition; detach player agent from body to spirit form. | **Long-Term** |
