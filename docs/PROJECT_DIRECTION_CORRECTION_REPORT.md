# THIÊN ĐẠO NGHỊCH MỆNH — PROJECT DIRECTION CORRECTION REPORT
## Document Code: REPORT-DIRECTION-CORRECTION-01
## Project: THIÊN ĐẠO NGHỊCH MỆNH (TDNM)
## Foundation: Source of Mana (Commit `1933bd6`, Tag `v0.1.0-baseline-1933bd6`)
## Engine: Godot 4.7.1 Stable
## Status: COMPLETED & AWAITING PROJECT OWNER APPROVAL

---

## 1. EXECUTIVE SUMMARY & CORRECTED DIRECTION

Following direct guidance from the Project Owner, the core vision and implementation strategy of **Thiên Đạo Nghịch Mệnh** have been authoritatively clarified and corrected:

1. **The Existing Source of Mana World IS the Main Game World:**
   - TDNM **continues to use the existing Source of Mana world and its 40+ interconnected maps as the primary game world**.
   - We are **NOT** replacing the existing SoM world with a newly built parallel world.
   - We are **NOT** making *Thanh Vân Thôn* (or any other newly created map) the new main map or automatically replacing the existing starting experience.
   - The verified direction is: **Preserve the existing SoM world as the physical, spatial, and technical foundation, then progressively transform its content, atmosphere, and identity into the Chinese Xianxia cultivation world.**

2. **World Transformation Strategy:**
   - **Existing Maps (Primary Backbone):** The existing 40+ interconnected maps (Tulimshar starting port, Overworld plains, Artis imperial capital, Candor/Splatyna subterranean cavern networks, Ship and Ocean sea lanes) remain the primary world. Their technical functionality, geometry, collision, and connectivity are preserved while their environmental art, NPC dialogues, quests, items, and monsters will be gradually transformed into Xianxia equivalents.
   - **New Expansion Maps (Additive):** New maps are introduced progressively only when serving a clear narrative or gameplay necessity (e.g., cultivation sect sanctums, ancient ruins, secret realms, demon beast forests, cultivation dungeons). New maps **expand** the world rather than replacing existing areas.
   - **One Coherent World:** All maps belong to one continuous, connected player journey.

3. **Protagonist & Narrative Foundation:**
   - The protagonist transmigrates from the modern 21st-century real world into this era.
   - He retains his **original physical body**, his **memories**, his **modern scientific and analytical knowledge**, and his **authentic personality**.
   - He does **NOT** possess (đoạt xá) another person's body or steal another cultivator's identity.
   - His journey begins with survival in an unfamiliar world, progresses to uncovering spiritual energy and self-cultivation, explores the main world, and ultimately seeks the cosmic truth behind his transmigration and the Heavenly Dao.

---

## 2. CURRENT MAIN WORLD MAP STRUCTURE

The existing Source of Mana main game world consists of **41 map scenes** interconnected via an established warp network. In accordance with the corrected taxonomy, all maps are classified into four distinct tiers:

```
+---------------------------------------------------------------------------------------+
|                       THIÊN ĐẠO NGHỊCH MỆNH WORLD MAP TAXONOMY                        |
+---------------------------------------------------------------------------------------+
|  [TIER 1: EXISTING MAIN WORLD MAPS] (40 Maps — Primary Interconnected World)          |
|  ├── Khu Vực Cảng Thành & Sa Mạc (Tonori / Tulimshar):                                |
|  │   ├── Tulimshar (Start Port) [Hash: 1374526955] ── Default Player Spawn          |
|  │   ├── Tulimshar Center, Bay, Beach, Castle, Castle Corridors, West Chamber,        |
|  │   │   West Wall Pathway, Western Hills, Eastern Hills, Southern Hills, Western Cave|
|  │   └── Desert Mountains, Desert Mountain Cave, Desert Mines, Desert Abandoned Level,|
|  │       Desert Deep Level, Desert Pit, Snake Pit, Sandstorm, Manayir, Manayir Beach  |
|  ├── Khu Vực Đại Lục & Kinh Đô (Overworld & Artis):                                   |
|  │   ├── Overworld [Hash: 211837582] ── Central Continental Plain Highway             |
|  │   └── Artis [Hash: 2042858172] & Artis Sewer [Hash: 496338002] ── Imperial City   |
|  ├── Khu Vực Hiểm Địa Hang Động (Candor & Splatyna):                                  |
|  │   ├── Candor Cave & Candor Arena                                                   |
|  │   └── Splatyna Cave Entrance, Chamber, Corridor, Dorian Dead End, Gabriel Pit,      |
|  │       Marvin Hole                                                                  |
|  └── Khu Vực Hải Vực & Thương Thuyền (Ship & Ocean):                                  |
|      └── Ship First Deck, Second Deck, Hold, Nard's Room, Alige Hide, Ocean           |
+---------------------------------------------------------------------------------------+
|  [TIER 2: TRANSFORMED EXISTING MAPS]                                                  |
|  └── Existing SoM maps scheduled for progressive Xianxia reskinning, NPC replacement, |
|      and lore adaptation (Beginning with Tulimshar port and surroundings).             |
+---------------------------------------------------------------------------------------+
|  [TIER 3: NEW ADDITIONAL EXPANSION MAPS]                                              |
|  ├── SacredSectHub (Tông Môn Thánh Địa) [Hash: 995840901] ── Cultivation mountain hub |
|  └── TanThuThon (Thanh Vân Thôn) [Hash: 1841251538] ── Hidden pastoral valley hamlet   |
+---------------------------------------------------------------------------------------+
|  [TIER 4: EXPERIMENTAL & TEST SCENES]                                                 |
|  ├── WorldIntegrationScene.tscn (Phase 2 static diorama evaluation)                   |
|  └── prototype_iso/ (Phase 1 isometric baseline prototype)                            |
+---------------------------------------------------------------------------------------+
```

---

## 3. AUDIT OF PHASE 4.1 IMPLEMENTATION (THANH VÂN THÔN)

A detailed technical inspection was conducted on all changes introduced in Phase 4.1 to answer the seven mandatory questions:

### 1. Which files were created?
| File Path | Description |
|---|---|
| `presets/maps/layers/xianxia/TanThuThon.tscn` | $3200 \times 2400$ 2.5D map scene (7 organic zones, 61 Y-sorted Fringe nodes). |
| `presets/maps/server/xianxia/TanThuThon.tres` | `MapServerData` resource with bidirectional warp definition. |
| `presets/maps/data/xianxia/TanThuThon.tres` | `MapData` resource binding layer, server data, navigation, and minimap. |
| `presets/maps/navigations/xianxia/TanThuThon.tres` | `NavigationPolygon` resource for actor pathfinding. |
| `data/graphics/minimaps/xianxia/TanThuThon.png` | Minimap HUD texture for Thanh Vân Thôn. |
| `data/graphics/minimaps/xianxia/SacredSectHub.png` | Minimap HUD texture for Sacred Sect Hub. |
| `scripts/generate_tan_thu_thon.py` | Procedural map generator script. |
| `tests/test_tan_thu_thon_load.gd` & `.tscn` | Headless resource registration and map loading verification test. |
| `tests/test_warp_two_way.gd` & `.tscn` | Headless bidirectional warp transition test. |
| `tests/capture_phase4_1_screenshots.gd` & `.tscn` | High-resolution camera screenshot capture harness. |
| `docs/PHASE_4_1_IMPLEMENTATION_REPORT.md` | Engineering implementation report. |
| `docs/images/phase4_1/` (10 PNG files) | Verified clean in-game screenshots without UI overlays. |

### 2. Which files were modified?
| File Path | Modification Summary |
|---|---|
| `sources/launcher/LauncherCommons.gd` | Changed `DefaultStartMapID` to `"TanThuThon".hash()` and `DefaultStartPos` to `Vector2i(1600, 1300)`. |
| `sources/launcher/Launcher.gd` | Added automated Web autologin sequence for browser tests, added `GUI.messageBox.Clear()`. |
| `sources/network/server/Server.gd` | Added detailed diagnostic logging for character creation validation. |
| `sources/map/Map.gd` | Broadened `currentFringe : TileMapLayer` to `Node2D` to support 2.5D Y-Sort scene roots. |
| `project.godot` | Configured debug collision outline settings to prevent rendering artifacts. |
| `.gitignore` | Added unignore rules `!presets/maps/*/xianxia/` so git tracks custom map resources. |
| `presets/maps/server/xianxia/SacredSectHub.tres` | Configured warp destination linking to TanThuThon. |
| `presets/maps/data/xianxia/SacredSectHub.tres` | Bound minimap path to resolve assertion failure. |
| `docs/PROJECT_CONTEXT.md` & `docs/PROJECT_STATUS.md` | Updated status documentation. |

### 3. Did it change the default starting map?
- **YES.** In `sources/launcher/LauncherCommons.gd`, `DefaultStartMapID` was temporarily set to `"TanThuThon".hash()`. This caused newly created accounts and test bots to spawn in Thanh Vân Thôn instead of the original SoM starting port `Tulimshar`.

### 4. Did it change the existing main map?
- **NO.** None of the 40 original Source of Mana maps (including `Tulimshar`, `Overworld`, `Artis`, `Candor Cave`, etc.) were deleted, overwritten, or modified. Their scene definitions and data resources remain 100% intact.

### 5. Did it change original SoM map connections?
- **NO.** None of the original map warps or triggers connecting existing SoM regions were altered. The only warp created was between the two expansion maps: `TanThuThon` $\leftrightarrow$ `SacredSectHub`.

### 6. Did it change default spawn configuration?
- **YES.** `DefaultStartPos` was changed from `Vector2i(2176, 2560)` (Tulimshar harbor) to `Vector2i(1600, 1300)` (Thanh Vân Thôn center), and `DefaultStartOffset` was changed from `Vector2i(64, 32)` to `Vector2i(48, 24)`.

### 7. Is it independent and can it remain as an optional additional map?
- **YES.** `TanThuThon` is completely modular and encapsulated within its own dedicated directory (`presets/maps/*/xianxia/`). It introduces no breaking hardcoded couplings into engine core systems. It is technically robust, fully tested on Native Desktop and Web, and can seamlessly remain as an **optional Tier 3 expansion map** (a hidden mountain valley discovered later through exploration or quests).

---

## 4. DOCUMENTATION UPDATES EXECUTED

In strict accordance with Section 6 of the Project Direction Correction directive, the project documentation suite has been reviewed, updated, and restructured:

1. **`docs/project/PROJECT_VISION.md` (CREATED):**
   - Formalized the non-negotiable core vision: The existing SoM world remains the primary game world.
   - Defined the additive expansion strategy and single coherent world principle.
   - Documented the modern transmigrator protagonist with original physical body, memories, and modern knowledge.
2. **`docs/project/DEVELOPMENT_PRINCIPLES.md` (CREATED):**
   - Established the "Content Transformation, Not Engine/Level Rewrite" axiom.
   - Reaffirmed dual-repository Vault immutability rules and empirical verification discipline.
3. **`docs/world/WORLD_BIBLE.md` (CREATED):**
   - Established the metaphysical foundations of Heavenly Dao, Spiritual Energy (Linh Khí), and Cultivation Realms (Phàm Nhân, Luyện Khí, Trúc Cơ, Kim Đan, Nguyên Anh).
4. **`docs/world/WORLD_SETTING.md` (CREATED):**
   - Provided complete geographical mapping of the 40+ SoM regions to Eastern Xianxia settings (Tonori $\rightarrow$ Bờ cõi sa mạc & cảng khởi đầu, Artis $\rightarrow$ Kinh đô cố thành, Candor/Splatyna $\rightarrow$ Hàn băng địa huyệt & Vạn yêu quỷ quật).
5. **`docs/world/STORY_OVERVIEW.md` (CREATED):**
   - Outlined the 4-act narrative arc: Survival $\rightarrow$ Awakening $\rightarrow$ Expansion $\rightarrow$ The Truth of the Heavenly Dao.
6. **`docs/gameplay/MAP_PROGRESSION.md` (CREATED):**
   - Formulated the 4-Tier Map Taxonomy (Main World, Transformed, Expansion, Experimental).
   - Documented the player progression path beginning at Tulimshar harbor.
7. **`docs/ai/AI_WORKING_GUIDELINES.md` (CREATED):**
   - Codified strict operating rules for AI coding assistants to prevent future direction drift.
8. **`docs/PROJECT_CONTEXT.md` & `PROJECT_STATUS.md` (UPDATED):**
   - Corrected all references that previously defined Thanh Vân Thôn as the replacement main world.
   - Re-anchored project status to acknowledge the existing 40+ maps as the primary backbone.

---

## 5. CONCRETE ACTIONS & RECOMMENDATIONS FOR NEXT PHASE

### Immediate Non-Destructive Realignment (Upon Approval):
1. **Restore Main World Default Starting Map:**
   In `sources/launcher/LauncherCommons.gd`, revert starting configuration back to the original Source of Mana baseline:
   ```gdscript
   static var DefaultStartMapID : int    = "Tulimshar".hash()
   const DefaultStartPos : Vector2i      = Vector2i(2176, 2560) # Tulimshar Starting Harbor
   const DefaultStartOffset : Vector2i   = Vector2i(64, 32)
   ```
2. **Preserve Thanh Vân Thôn as Tier 3 Expansion:**
   Keep `presets/maps/layers/xianxia/TanThuThon.tscn` and its related resources intact as an optional discovery realm accessible via warps or high-level quest gateways.

### Recommended Next Phase: Phase 4.2 — Main World Starting Experience & First Xianxia Transformation
Instead of adding new detached maps, Phase 4.2 should focus on the **real main starting world** (`Tulimshar`):
1. **First Xianxia Inhabitant in Tulimshar:** Adapt the first NPC encountered near the starting harbor into a local resident/fisherman/herbalist who interacts with the freshly arrived modern protagonist.
2. **First Modern Survival Quest:** Implement a dialogue and quest introducing the protagonist's survival dilemma (adapting to this strange era with his modern body).
3. **First Demonic Beast Adaptation:** Adapt the low-level beach/desert fauna around Tulimshar (e.g. crabs, scorpions, desert lizards) into low-tier spiritual / demonic beasts with appropriate Chinese Xianxia naming and drops.

---

## 6. STATUS & APPROVAL GATE

- Direction correction report completed.
- Documentation suite synchronized.
- Zero source code or map assets deleted or broken.
- **Engine execution status:** Dedicated server and web client fully operational.
- **NEXT STEP:** Awaiting project owner review and explicit authorization before applying any further changes.
