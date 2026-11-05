# WORKSTREAM C — EQUIPMENT, ROBES & ARTIFACT CUSTOMIZATION PIPELINE
**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Phase:** 4.3 — Character & Combat Architecture Design  
**Type:** Technical Architecture Investigation & Visual Pipeline Design  
**Status:** ARCHITECTURAL PROPOSAL (`[PROPOSED]`) — SUBJECT TO OWNER REVIEW  

---

## 1. INVESTIGATION CONTEXT & BASELINE EQUIPMENT PIPELINE

In Source of Mana, equipment is categorized by [`ActorCommons.Slot`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/actor/ActorCommons.gd#L56-L74) into 12 functional slots:
```gdscript
enum Slot
{
	NONE = -1,
	CHEST = 0,
	LEGS,
	FEET,
	HANDS,
	HEAD,
	NECK,
	WEAPON,
	SHIELD,
	BODY,
	FACE,
	HAIR,
	QUEST,
	COUNT,
	FIRST_EQUIPMENT = CHEST,
	LAST_EQUIPMENT = SHIELD + 1,
	FIRST_MODIFIER = BODY,
	LAST_MODIFIER = HAIR + 1,
}
```

The database defines items as [`ItemCell`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/cell/ItemCell.gd) resources. Each item contains:
- `slot`: Target `ActorCommons.Slot`.
- `textures`: Dictionary of `Gender` $\rightarrow$ `Texture2D`.
- `shader`: Optional `Material` for palette re-coloring.
- `animationOverrides`: Optional `AnimationLibrary` to replace attack/walk animations.
- `modifiers`: Dictionary of stat bonuses (Health, Stamina, Attack, Defense, etc.).

---

## 2. SLOT-BY-SLOT AUDIT & XIANXIA RECONTEXTUALIZATION

Every existing equipment slot is audited below, mapping baseline Western fantasy behavior to its target Xianxia/Xuanhuan counterpart:

| Slot ID & Name | Existing SoM Asset & Role | Xianxia / Xuanhuan Recontextualization | Visual Rendering Strategy | Current Status |
| :--- | :--- | :--- | :--- | :--- |
| **0. `CHEST`** | Medieval plate mail, leather vests, shirts | **Daoist Robes (Đạo Bào / Pháp Y)** | Base robe silhouette + Five-Element Palette Shader | **PROPOSED** |
| **1. `LEGS`** | Trousers, chainmail leggings, shorts | **Cultivator Sashes & Trousers (Tiên Khố)** | Integrated into unified Daoist Robe lower hem | **PROPOSED** |
| **2. `FEET`** | Leather boots, iron greaves, sandals | **Cloud-Walking Boots (Đạp Vân Ngoa)** | Foot overlay sprites or unified robe hem | **PROPOSED** |
| **3. `HANDS`** | Gauntlets, leather gloves, bracers | **Spiritual Bracers (Hộ Uyển / Ngọc Trạc)**| Wrist wraps / bracelet overlay sprites | **PROPOSED** |
| **4. `HEAD`** | Iron helms, wizard hats, caps | **Daoist Crowns & Hairpins (Đạo Quan / Trâm)** | Sits on `Head` socket; anchors hairpins/crowns | **PROPOSED** |
| **5. `NECK`** | Pendants, iron torcs, amulets | **Spiritual Beads & Talismans (Hộ Thân Phù)** | Socket attachment or icon-only buff | **PROPOSED** |
| **6. `WEAPON`** | Broadsword, dagger, wooden club, battleaxe| **Spiritual Blades (Linh Kiếm / Bảo Đao)** | Dynamic `Marker2D` Hand Socket attachment | **PROPOSED** |
| **7. `SHIELD`** | Wooden buckler, heater shield | **Defensive Talisman / Spirit Mirror (Bảo Kính)**| Floating orbit around cultivator | **PROPOSED** |
| **8. `BODY`** | Human skin variants (Pale, Tan, Kralog) | **Mortal Physique (Phàm Thân / Linh Thể)** | Base naked anatomy mesh | **EXISTING (SoM)** |
| **9. `FACE`** | Chibi eyes, expressions | **Cultivator Visage (Pháp Tướng / Dung Mạo)** | Facial feature layer | **EXISTING (SoM)** |
| **10. `HAIR`** | Choppy, bald, braids | **Daoist Topknot & Long Flowing Hair** | Head layer with dynamic hair flutter | **EXISTING (SoM)** |
| **11. `QUEST`** | Quest-specific key items | **Natal Artifact / Cauldron (Bản Mệnh Pháp Bảo)** | Floating orbit or status display icon | **PROPOSED** |

---

## 3. FUTURE XIANXIA EQUIPMENT VISUAL ARCHITECTURE

To avoid the combinatorial explosion of drawing 512 frames for every new robe and weapon, TDNM adopts a **Three-Tier Visual Pipeline**:

```
┌────────────────────────────────────────────────────────────────────────┐
│ TIER 1: UNIFIED DAOIST ROBES + FIVE-ELEMENT PALETTE SHADERS            │
│ 1 base robe spritesheet per Cultivator Grade (Beginner -> Core).       │
│ Material shaders dynamically shift trim and fabric colors based on     │
│ elemental affinity (Kim = Gold, Mộc = Cyan, Thủy = Blue, etc.).        │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│ TIER 2: PROCEDURAL WEAPON ATTACHMENT SOCKETS                           │
│ Swords, Sabers, Staves, Whisks rendered as independent 2D sprites      │
│ attached to animated Marker2D sockets (Hand_R, Hand_L, Scabbard_Back). │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│ TIER 3: AUTONOMOUS FLOATING SPIRIT ARTIFACTS (ORBIT NODES)             │
│ Flying Swords (Phi Kiếm), Talismans (Đạo Phù), Spirit Cauldrons (Đỉnh) │
│ rendered as independent orbiting Node2D children running procedural    │
│ floating, glowing, and bobbing scripts.                                │
└────────────────────────────────────────────────────────────────────────┘
```

### 3.1 Tier 1: Daoist Robes & Elemental Shaders
Instead of creating dozens of disparate clothing items, clothing is organized into **Cultivation Realm Robes**:
1. **Phàm Nhân Tố Y (Mortal Coarse Robe):** Plain linen garment representing the protagonist's starting state.
2. **Ngoại Môn Đạo Bào (Outer Disciple Robe):** Clean white/grey robes with wide martial sleeves.
3. **Nội Môn Pháp Y (Inner Disciple Spiritual Garment):** Flowing silk robes with celestial cloud patterns.
4. **Trưởng Lão Tiên Y (Elder Immortal Robe):** Elaborate layered robes with gold embroidered trims.

**Five-Element Color Harmonization (Aligned with D-01 Ngũ Hành Tạp Căn):**
Using Godot shader `ColorPalette.gdshader`:
- **Kim (Metal):** White silk with sharp platinum/gold trim.
- **Mộc (Wood):** Pale cyan-green with bamboo/leaf embroidery.
- **Thủy (Water):** Deep azure-blue with wave ripples.
- **Hỏa (Fire):** Vermilion red with flame ember motifs.
- **Thổ (Earth):** Warm ochre-amber with mountain stone trim.

### 3.2 Tier 2: Dynamic Weapon Attachment Sockets
In the current baseline, the sword is permanently drawn into the Swordsman sprite raster. 
In the future architecture:
1. The character sprite sheet is drawn with **empty hands** or gripping a neutral hilt.
2. Sockets (`Marker2D`) are added to the character scene:
   - `Socket_MainHand`: Tracks the position of the dominant hand across each animation frame.
   - `Socket_OffHand`: Tracks the off-hand (for dual-wielding or catalyst items).
   - `Socket_Back`: Anchors the sword scabbard across the character's shoulders when weapons are sheathed.
3. Equipping a sword instantiates a single $32 \times 32$ or $48 \times 48$ weapon sprite that parents to `Socket_MainHand`.

### 3.3 Tier 3: Autonomous Floating Spirit Artifacts (Pháp Bảo)
Xianxia combat is celebrated for magical treasures that hover, orbit, and strike independently without physical hand contact:
- **Flying Swords (Phi Kiếm):** When not engaged in melee, the sword unsheathes procedurally and hovers over the cultivator's shoulder, emitting a subtle hum and faint light beam.
- **Defensive Talismans (Hộ Thân Phù):** 3 paper talismans inscribed with cinnabar runes orbit the character in an elliptical path, providing visual feedback for defensive shields.
- **Soul-Reaping Bells & Mirrors (Chiêu Hồn Chấn / Âm Dương Kính):** Hover above the cultivator's head, pulsing light whenever a spell is cast.

---

## 4. CURRENT VS PROPOSED VS MISSING ASSETS REGISTER

| Domain | Existing Baseline Functionality | Proposed Architectural Functionality | Missing Art / Engineering Assets | Technical Feasibility |
| :--- | :--- | :--- | :--- | :---: |
| **Base Body** | Male & Female 4-dir paperdoll bodies (`player-male.png`) | 8-dir naked cultivator base body | Female 8-dir frameset | **High** |
| **Hairstyles** | 5 hair presets (`Hair.tscn`, 4-dir) | Daoist topknot, flowing martial hair (8-dir) | 8-dir hair sprite frames | **Medium** |
| **Daoist Robes** | 26 medieval armor items (Plate, Leather, Tunics) | 4 core Xianxia realm robes + palette shaders | 8-dir robe sprite frames | **Medium** |
| **Melee Weapons** | 4 melee weapons (ShortSword, LongSword, Club, Axe) | 8-dir sword/saber/staff socket sprites | Socket offset coordinates per frame | **High** |
| **Flying Swords** | None (Weapons only render in hand) | Orbiting `PhiKiemNode2D` with bezier homing | Procedural sword trail shader | **High** |
| **Talismans** | None | Orbiting paper talisman particle emitter | Yellow talisman sprite ($16 \times 32$ px) | **Immediate** |
| **Auras & Barriers**| 12 status VFX (Poison, Berserk, Candor Circle) | Bagua / Yin-Yang defensive barrier | Rotating Bagua ring texture | **Immediate** |

---

## 5. SUMMARY RECOMMENDATION FOR OWNER DECISION

1. **Do not attempt to convert all 26 legacy armor items into 8-directional spritesheets.** This would consume hundreds of hours of art budget without fitting the Xianxia aesthetic.
2. **Adopt the Unified Cultivation Robe Tier System:** 4 master robe models tinted by Five-Element shaders fulfill 100% of narrative and visual progression needs.
3. **Decouple Weapons from Spritesheets:** Implement `Marker2D` hand sockets for melee weapons and orbiting `Node2D` nodes for Flying Swords and Talismans.

---

*Authored by Senior Godot Engineer & Systems Architect — Thiên Đạo Nghịch Mệnh Phase 4.3.*
