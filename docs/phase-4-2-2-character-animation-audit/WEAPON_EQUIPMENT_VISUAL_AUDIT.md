# TDNM — WEAPON & EQUIPMENT VISUAL RENDERING AUDIT
## Phase 4.2.2 Technical Investigation

**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Date:** 2026-11-03  
**Status:** VERIFIED & EMPIRICALLY AUDITED  
**Scope Boundary:** Documentation and Technical Audit ONLY

---

## 1. VISUAL CUSTOMIZATION ARCHITECTURE: HOW SOM RENDERS EQUIPMENT

In Source of Mana, equipment rendering is achieved through a multi-layer 2D paperdoll composite system.

### 1.1. Equipment Layer Hierarchy (`presets/entities/sprites/Player.tscn`)
The classic player character hierarchy contains 9 distinct child `Sprite2D` nodes rendered in strict Y-depth drawing order:

```
[Player.tscn (Node2D)]
  ├── Body (Sprite2D)      - Base skin texture (player-male.png / player-female.png)
  ├── Face (Sprite2D)      - Facial features & eye color
  ├── Feet (Sprite2D)      - Boots, shoes, sandals
  ├── Legs (Sprite2D)      - Trousers, pants, robes
  ├── Chest (Sprite2D)     - Tunics, armor, shirts, gowns
  ├── Hair (Sprite2D)      - Hairstyle mesh with dynamic palette shader
  ├── Hands (Sprite2D)     - Gloves, armbands, bracelets
  ├── Weapon (Sprite2D)    - Held weapon sprite
  ├── Shield (Sprite2D)    - Offhand shield sprite
  ├── Neck (Sprite2D)      - Scarves, amulets
  ├── Head (Sprite2D)      - Hats, helmets, hoods, crowns
  └── Animation (AnimationPlayer) -> Drives frame indices across all layers simultaneously
```

### 1.2. The Runtime Equipment Binding Flow (`sources/actor/entity/components/Visual.gd`)
1. When equipment changes, `inventory.EquipItem()` calls `Visual.SetEquipment(slot)`.
2. `Visual.gd` fetches the `ItemCell` from the slot:
   ```gdscript
   slotTexture = cell.textures[entity.stat.gender]
   slotMaterial = cell.shader
   sprite.set_texture(slotTexture)
   sprite.set_material(slotMaterial)
   ```
3. If the item provides custom animation frames, `ApplyAnimationOverrides()` dynamically duplicates the `AnimationLibrary` and injects item-specific keyframe tracks.

---

## 2. THE CORE ARCHITECTURAL CONFLICT: SWORDSMAN VS MODULAR EQUIPMENT

```mermaid
graph TD
    subgraph Storage["Inventory & SQLite Data Layer"]
        Inv["ActorInventory"] --> Slot["Equip Slot (e.g. WEAPON = Shortsword)"]
        Slot --> Stats["Stats Updated (+15 PAtk, +5 Agi)"]
    end

    subgraph Conflict["Visual Dispatch in Visual.gd"]
        Slot --> Check{"Does Entity possess AnimatedSprite2D?"}
        Check -->|YES (TDNM Swordsman)| Baked["SwordsmanPreset.tscn: Bypasses SetEquipment! Visual remains BAKED martial robe & single sword!"]
        Check -->|NO (Classic SoM)| Layered["Player.tscn: Swaps Weapon Sprite2D texture on classic 4-dir body"]
    end
```

### Critical Audit Finding:
- In Phase 3, the player character was upgraded to `SwordsmanPreset.tscn` to deliver stunning 8-directional isometric Xianxia visuals.
- However, `SwordsmanPreset.tscn` is an **all-in-one baked spritesheet** (`swordsman_frames.tres`). The character's martial robes, bamboo hat/hair, boots, and broadsword are drawn directly into each of the 512 frames.
- In `Visual.gd:108-116`, when `animatedSprite` is detected, `Visual.gd` does **NOT** instantiate or update the 9 `Sprite2D` equipment slots.
- **Consequence:** When a player equips a knife, large blade, helmet, or heavy armor, the character receives the statistical benefits in database and combat, but **THE ON-SCREEN SWORDSMAN RENDERS ZERO VISUAL CHANGE**. The character indefinitely wields the baked starter sword and wears the starter robe.

---

## 3. INVENTORY OF EXISTING WEAPON & ARMOR SPRITES (CLASSIC 4-DIR)

All existing equipment sprites in `data/graphics/sprites/equipment/` are formatted strictly for the classic $64 \times 64$ px 4-directional body:

### 3.1. Weapons (4 Total)
1. `knife.png` ($1024 \times 512$ px, 4 directions) — Small dagger.
2. `shortsword.png` ($1024 \times 512$ px, 4 directions) — Standard one-handed blade.
3. `sword.png` ($1024 \times 512$ px, 4 directions) — Broad steel sword.
4. `largeblade.png` ($1024 \times 512$ px, 4 directions) — Heavy two-handed cleaver.

### 3.2. Shields (2 Total)
1. `leather-shield` (male/female, 4 directions) — Buckler.
2. `rawwood-shield` (male/female, 4 directions) — Round wooden shield.

### 3.3. Armor & Clothing (26 Total)
- **Head (7):** `desert-goggles`, `tonori-crown`, `druid-hood`, `desert-hood`, `funky-hat`, `miner-helmet`, `ghutra`.
- **Chest (9):** `gown`, `croptop`, `tanktop`, `druidrobe`, `shirt`, `vneckjumper`, `leathershirt`, `desertjacket`, `desertarmor`.
- **Legs (5):** `shorts`, `cloudpants`, `jeanschaps`, `trousers`, `pants`.
- **Hands (3):** `armbands`, `bracelets`, `gloves`.
- **Feet (1):** `boots`.
- **Neck (1):** `bandana-scarf`.

---

## 4. FUTURE XIANXIA WEAPON TYPE COMPATIBILITY

| Weapon Classification | Iconic Xianxia Archetype | Current Implementation Status | Technical Feasibility for 8-Direction |
|---|---|:---:|---|
| **Flying Sword / Longsword (Phi Kiếm / Trường Kiếm)** | Trảm Yêu Kiếm, Thanh Phong Kiếm | **BAKED IN SWORDSMAN** | Current default; needs texture variations for higher tiers. |
| **Spear / Halberd (Trường Thương / Phương Thiên Họa Kích)** | Phá Quân Thương | **NOT IMPLEMENTED** | Requires new 8-directional weapon animation set ($72 \times 72$ px). |
| **Staff / Quarterstaff (Thiết Bổng / Thiền Trượng)** | Hàng Ma Trượng | **NOT IMPLEMENTED** | Requires new 8-directional swing and thrust animations. |
| **Bow / Crossbow (Linh Cung / Thần Nỗ)** | Xạ Nhật Cung | **PARTIALLY VERIFIED** | Supported in `Archer.tres` skill logic, but no 8-dir sprites. |
| **Daggers / Flying Knives (Phi Đao / Ám Khí)** | Vô Ảnh Chủy Thủ | **NOT IMPLEMENTED** | Requires rapid short-range thrust frames. |
| **Heavy Greatsword (Trọng Kiếm)** | Huyền Thiết Trọng Kiếm | **NOT IMPLEMENTED** | Requires high-weight anticipation and floor-cleaving frames. |
| **Unarmed / Gauntlets (Quyền Sáo / Không Thủ)** | Hám Thiên Quyền | **NOT IMPLEMENTED** | Requires removing weapon layer and rendering bare-fist strikes. |

---

## 5. ARCHITECTURAL SOLUTIONS FOR 8-DIRECTIONAL EQUIPMENT

To enable equipment progression in TDNM without losing the 8-directional isometric quality, three viable paths exist:

### Option 1: Multi-Layer 8-Directional SpriteFrames (Recommended for Production)
- Deconstruct the Swordsman into base nude body frames + modular equipment overlay sheets (`swordsman_armor_tier1.png`, `swordsman_sword_tier1.png`).
- `Visual.gd` synchronizes multiple `AnimatedSprite2D` nodes sharing the same animation frame index.
- *Pros:* Preserves pixel-art precision and allows unlimited mix-and-match armor/weapons.

### Option 2: Programmatic Attachment Sockets (Marker2D)
- Keep character body monolithic, but extract the weapon sprite. Attach a `Marker2D` tracking the hand position per frame.
- *Pros:* Only weapons need to be swapped; robes remain baked.
- *Cons:* Hand rotation in pixel art requires manual per-frame subpixel offsets to avoid floating hilts.

### Option 3: Full Costume Set Swaps (Realm-Based Outfits)
- Players unlock a completely new 8-directional spritesheet upon reaching major cultivation realms (e.g. *Phàm Thân Bộ* $\rightarrow$ *Tụ Khí Đạo Bào* $\rightarrow$ *Đạo Cơ Chiến Giáp* $\rightarrow$ *Huyền Đan Tiên Y*).
- *Pros:* Easiest to implement immediately; avoids complex layering. Matches the narrative progression of cultivating higher robes.
