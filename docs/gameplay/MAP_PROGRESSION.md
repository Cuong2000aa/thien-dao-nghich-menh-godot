# THIÊN ĐẠO NGHỊCH MỆNH — MAP PROGRESSION & WORLD HIERARCHY
## Document Code: DOC-GAME-MAP-PROGRESSION
## Status: OFFICIAL WORLD MAP HIERARCHY
## Engine: Godot 4.7.1 Stable | Foundation: Source of Mana

---

### 1. The Four-Tier Map Taxonomy

All level assets and map scenes in Thiên Đạo Nghịch Mệnh are categorized strictly into four functional tiers:

```
                                [WORLD MAP TAXONOMY]
                                         │
        ┌───────────────────┬────────────┴───────────────┬─────────────────────┐
        ▼                   ▼                            ▼                     ▼
[TIER 1: MAIN WORLD] [TIER 2: TRANSFORMED]   [TIER 3: EXPANSION]   [TIER 4: EXPERIMENTAL]
- 40+ Original SoM   - Existing maps with    - Newly built lore    - Isolated test scenes
  Maps (Interconnected Eastern/Xianxia        maps (Sects, realms,   (Dioramas, visual
  world backbone).     thematic reskin.       hidden valleys).       evaluation scenes).
- Primary progression - Keeps map ID &       - Connected via warps - Not in live game
  and default spawn.   warp network.          to main world.         progression.
```

---

### 2. Comprehensive Map Classification Table

| Map Name | Hash ID | Category Tier | Current Role / Story Function |
|---|---|---|---|
| **Tulimshar** | `1374526955` | **Tier 1 (Main World)** | **Default Starting Map:** Ancient desert port town where the modern protagonist awakes. Main starting experience. |
| **Tulimshar Center** | `1052608472` | **Tier 1 (Main World)** | Town center, marketplace, trade stalls, initial NPC contacts. |
| **Tulimshar Bay / Beach** | Various | **Tier 1 (Main World)** | Coastal border, fishing shacks, arrival beach, low-level crab/lizard mobs. |
| **Tulimshar Castle & Walls** | Various | **Tier 1 (Main World)** | Local feudal governor's stronghold, stone walls, guards. |
| **Tulimshar Western Cave / Hills** | Various | **Tier 1 (Main World)** | Rocky outcroppings, low-tier beast dens, beginner gathering zone. |
| **Overworld** | `211837582` | **Tier 1 (Main World)** | **Main Continental Highway:** Connects southern desert to northern capital. |
| **Artis** | `2042858172` | **Tier 1 (Main World)** | Imperial capital city, grand stone avenues, canals, major faction embassies. |
| **Artis Sewer** | `496338002` | **Tier 1 (Main World)** | Subterranean waterway system beneath the capital, rogue cultivator hideouts. |
| **Desert Mountains / Mines** | Various | **Tier 1 (Main World)** | Arid mountain paths, abandoned mines, mineral ore excavation sites. |
| **Desert Pit / Snake Pit** | Various | **Tier 1 (Main World)** | Dangerous sinkholes, venomous serpent dens, environmental hazards. |
| **Candor Cave / Arena** | Various | **Tier 1 (Main World)** | Icy cavern trials, ancient subterranean combat ring, mid-level challenges. |
| **Splatyna Cavern Network (6 maps)**| Various | **Tier 1 (Main World)** | Deep abyssal dungeon network, high-threat demonic beast colony. |
| **Ship First / Second Deck, Hold** | Various | **Tier 1 (Main World)** | Maritime passenger/merchant vessels sailing across the Misty Ocean. |
| **Ocean** | Various | **Tier 1 (Main World)** | Maritime water zones, sea monster encounters. |
| **SacredSectHub** | `995840901` | **Tier 3 (Expansion Map)** | **Sect Sanctum Enclave:** High mountain sanctuary featuring Shaolin, Wudang, Kunlun, Emei architecture. Optional / Mid-game cultivation hub. |
| **TanThuThon (Thanh Vân Thôn)** | `1841251538` | **Tier 3 (Expansion Map)** | **Hidden Valley Hamlet:** $3200 \times 2400$ pastoral mountain village with herbal farms and peach groves. Connects to SacredSectHub via two-way portal. Additional optional zone. |
| **WorldIntegrationScene** | N/A | **Tier 4 (Experimental)** | Phase 2 static visual integration scene. Used for diorama evaluation. |
| **prototype_iso/** | N/A | **Tier 4 (Experimental)** | Phase 1 baseline diorama prototype. Kept for historical reference. |

---

### 3. Player Flow & Journey Blueprint

```
[Arrival & Awakening] 
  └── Tulimshar Port & Beach (Main World Start)
        ├── Understand the world & survive
        └── Learn basic breathing & Qi condensation (Luyện Khí)
                       │
                       ▼
[Trade & Continental Travel]
  └── Overworld Plains & Mountain Caravan Paths
        ├── Gathering spiritual herbs & beast materials
        └── Encountering wandering Daoist merchants
                       │
                       ▼
[Great Metropolis & Imperial Court]
  └── Artis Capital & Subterranean Crypts
        ├── Rogue cultivator alliances (Tán Tu Minh)
        └── High-level martial competitions
                       │
                       ▼
[Subterranean Abysses & Trials]
  └── Candor Caverns & Splatyna Demonic Nest
        ├── Hunting foundation-grade beast cores
        └── Unearthing primordial formation ruins
                       │
                       ▼
[The Immortal Sanctums (Discovery Expansions)]
  └── Sacred Sect Hub & Hidden Realms (e.g. Thanh Vân Thôn)
        ├── Flying sword mastery & Core Formation (Kim Đan)
        └── Unlocking secrets of the Heavenly Dao
```

---

### 4. Directives Regarding Thanh Vân Thôn (TanThuThon)

1. **Not the Main Start Map:** Thanh Vân Thôn is a Tier 3 expansion map. It does not replace the default starting map `Tulimshar`.
2. **Modular Independence:** The map is fully functional ($3200 \times 2400$, 7 organic zones, 61 Y-sorted Fringe nodes, two-way warp with `SacredSectHub`) and remains preserved as an optional additional location.
3. **Restoration of Default Spawn:** The default starting spawn (`DefaultStartMapID` and `DefaultStartPos`) belongs to the main world and will be restored to `Tulimshar` upon project owner confirmation.
