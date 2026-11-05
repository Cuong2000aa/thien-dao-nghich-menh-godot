# TDNM — VFX & SFX AUDIO SYSTEM AUDIT
## Phase 4.2.2 Technical Investigation

**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Date:** 2026-11-03  
**Status:** VERIFIED & EMPIRICALLY AUDITED  
**Scope Boundary:** Documentation and Technical Audit ONLY

---

## 1. VISUAL EFFECTS (VFX) ARCHITECTURE & INVENTORY

All visual effects in Source of Mana are implemented as standalone Godot PackedScenes instantiating `GPUParticles2D` nodes, configured under [`presets/effects/`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/presets/effects/).

### 1.1. Categorized Inventory of Existing VFX Scenes (38 Scenes)

| VFX Category | Scene File Path | Particle Type | Directional Support | Artistic Style | Xianxia Reuse Recommendation |
|---|---|:---:|:---:|---|---|
| **Casting Circles (8)** | `presets/effects/particles/casts/*.tscn`<br>(`Betsanc`, `Flar`, `Inma`, `Jump`, `LeafBlades`, `Lum`, `ManaBurst`, `Morph`) | Ground Ring GPUParticles2D | Omni (360°) | Western magic summoning rune circles | **REPLACE** with Bagua (Bát Quái), Taiji (Thái Cực), or Daoist talisman circles. |
| **Projectiles (5)** | `Arrow.tscn`, `Flar.tscn`, `LeafBlades.tscn`, `SonicWave.tscn`, `Spitfire.tscn` | Linear Moving Particles | Facing Angle | Western elemental orbs / physical arrows | **ADAPT:** `Flar` $\rightarrow$ True Fire talisman; `SonicWave` $\rightarrow$ Crescent Sword Qi. |
| **Explosions / AOE (4)**| `ManaBurst.tscn`, `SonicScream.tscn`, `FireRing.tscn`, `PoisonBubbles.tscn` | Burst Shockwave | Radial | Arcane energy / soundwave lines | **ADAPT:** `ManaBurst` $\rightarrow$ Golden Core spiritual detonation. |
| **Buffs & Healing (3)** | `Heal.tscn`, `Twinkle.tscn`, `Morph.tscn` | Vertical Float GPUParticles2D | Omni | Green cross/sparkle aura | **ADAPT:** Green vitality qi / spiritual pill dissolution mist. |
| **Feedback & State (4)**| `LevelUp.tscn`, `Selection.tscn`, `Emote.tscn`, `LightSource.tscn` | Radial / Point Light | Dynamic | Clean arcade visual feedback | **KEEP / ADAPT:** `LevelUp` $\rightarrow$ Golden breakthrough beam. |
| **Ambient / Env (14)** | `presets/effects/ambient/*.tscn`<br>(`Sandstorm.tscn`, `Lighting.tscn`, `Cloud.tscn`, `Fountain.tscn`, `ChimneySmoke.tscn`, etc.) | Full-screen / Polygon Particles | Environmental | Pixel weather and atmospheric lighting | **KEEP:** Sandstorm and Lighting are excellent; directly reusable in Cuồng Sa and Hàn Thạch. |

---

## 2. SOUND EFFECTS (SFX) ARCHITECTURE & INVENTORY

Audio reproduction is managed by [`sources/actor/entity/components/Sfx.gd`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/actor/entity/components/Sfx.gd), which routes sounds through dedicated Godot audio buses:
- `ActorCommons.SfxAlterationBus` (Combat hits, dodges, crits, heals).
- `ActorCommons.SfxNotificationBus` (Level-up, quest updates, gold pickups).
- `ActorCommons.SfxStateBus` (Monster grunts, attack swings, death sounds).
- Volume attenuation is managed via `othersVolumeDb` to ensure the local player's actions remain prominent.

### 2.1. Complete Inventory of Existing Audio Files (67 SFX, 7 Music Tracks)

#### Combat Alteration SFX (10 Files — `data/sounds/alteration/`)
- `hit.ogg` — Dull blunt physical impact. (Needs sharp sword clash for TDNM).
- `crit.ogg` — High-pitched metal resonance. (Good impact; keep).
- `dodge.ogg` — Swift air whoosh. (Keep for qinggong evasion).
- `heal.ogg` — Gentle chime chime. (Good; adapt).
- `levelup.ogg` — Fanfare ascending chime.
- `skillup.ogg` — Magical resonance.
- `exp.ogg` — Soft tick.
- `gp.ogg` — Coin jingle. (Keep for copper/silver phàm trần trade).
- `quest-done.ogg` & `quest-update.ogg` — Clean quest notification cues.

#### Monster & Entity SFX (57 Files across 18 Entity Types — `data/sounds/entities/`)
- **Beasts:** `croc`, `lynx`, `ratto`, `snake`, `turtle`, `scorpion` (attack, hit, dodge, death).
- **Insects / Flying:** `bat`, `piou`, `maggot` (attack, death).
- **Elementals:** `fire-goblin`, `fire-skull`, `slime`, `peyote`, `shroom` (attack, hit, death).
- **Undead:** `skeleton` (death rattle).
- **Objects:** `chest` (open/close), `tictactoe` (trigger).

#### Background Music Tracks (7 Files — `data/music/`)
1. `Bart Kelsey - The Adventure Begins.ogg` (Upbeat European medieval town theme).
2. `Bart Kelsey - In the forest of the birches.ogg` (Acoustic guitar/flute European forest).
3. `Jose. S & Dakota. D - Lenia.ogg` (Melancholic ambient acoustic).
4. `Jose. S & Dakota. D - Night is calling.ogg` (Atmospheric nocturnal strings).
5. `NYC Sound Design & Dariunas - Cave.ogg` (Deep subterranean reverb; reusable in cavern maps).
6. `Dariunas - Faith.ogg` (Ethereal synth ambiance).
7. `Hitctrl - Foreboding ambiance.ogg` (Ominous drone; reusable in Vạn Yêu Quật).

---

## 3. ARTISTIC COMPATIBILITY EVALUATION FOR XIANXIA

1. **Current Audio Landscape:**
   - Dominated by Western fantasy instrumentation: acoustic folk guitar, European wooden flutes, orchestral fanfares, and Western monster grunts.
2. **Required Xianxia Audio Evolution:**
   - **Instruments:** Transition main town and regional themes to traditional Chinese instruments: **Cổ Cầm (Guqin)**, **Tranh (Guzheng)**, **Tỳ Bà (Pipa)**, **Nhị Hồ (Erhu)**, **Sáo Trúc (Dizi)**.
   - **Combat SFX:** Replace generic blunt thuds with crisp metallic sword deflections, deep Daoist bell resonances, crackling heavenly lightning, and roaring dragon/tiger beast calls.
   - **Ambience:** Wind blowing through bamboo forests, distant temple bells at mountain peaks, and deep subterranean demonic chanting.
