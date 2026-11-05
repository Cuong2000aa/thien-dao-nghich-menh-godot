# PHASE 4.0 — CONTENT TRANSFORMATION & MAPPING SPECIFICATION
## Project: THIÊN ĐẠO NGHỊCH MỆNH (TDNM)
**Engine:** Godot 4.7.1 Stable  
**Foundation:** Source of Mana (Commit `1933bd66caf2c59fd5d9b5df410d19838059b243`)  
**Asset Vault Status:** Immutable (357 files in `thien-dao-nghich-menh/public/assets`)  
**Date:** 2026-11-02  

---

## 1. STRATEGIC ARCHITECTURAL PRINCIPLE

**Content Transformation, NOT a Rewrite.**
Source of Mana delivers a proven, high-performance MMORPG technical foundation (multiplayer networking, server authority, SQLite persistence, tick-based movement, and NPC scripting). 

The goal of **Thiên Đạo Nghịch Mệnh (TDNM)** is to completely replace the medieval Western fantasy world with a rich, authentic Eastern Tu Tiên / Xianxia universe while keeping the underlying engine and networking layers completely intact.

---

## 2. SYSTEM CLASSIFICATION MATRIX

Every component of the existing codebase is classified into one of five categories:
- **KEEP:** Preserve existing implementation without modification.
- **ADAPT:** Preserve core logic, but adjust parameters, formulas, names, or presentation.
- **REPLACE:** Swap out original assets, scenes, or narrative data with Xianxia equivalents.
- **EXTEND:** Retain existing architecture and build new capabilities on top.
- **REMOVE:** Safely deprecate unneeded components without breaking dependencies.

| Subsystem | Layer | Classification | Technical Justification |
| :--- | :--- | :---: | :--- |
| **`Launcher.gd` / Service Lifecycle** | Framework | **KEEP** | Rock-solid service injection (`SQL`, `World`, `Map`, `Audio`, `GUI`). |
| **Network Dual Protocol (ENet/WS)** | Framework | **KEEP** | Proven native desktop (6119) and Web browser (6118) cross-play. |
| **Authoritative Server Architecture** | Server | **KEEP** | Server authority prevents cheating, desync, and database corruption. |
| **SQLite Schema & Engine** | Persistence | **EXTEND** | 14 tables and triggers are stable. Extend with Realm (`realm_id`) and Sect (`sect_id`). |
| **Tick & Position Synchronization** | Network / Server | **KEEP** | Authoritative 30Hz position validation and client lerping is production-ready. |
| **8-Direction Swordsman Character** | Visual / Client | **KEEP** | Already migrated in Phase 2 & bound in Phase 3 (`swordsman_frames.tres`). |
| **Modular Paper-Doll Sprite Generator** | Visual / Client | **REPLACE** | Legacy Western hair/body sprites do not match Xianxia art; replaced by monolithic 8-dir animated sheets. |
| **`Visual.gd` Rendering Pipeline** | Framework | **KEEP** | Supports both legacy sprites and `AnimatedSprite2D` presets (`SwordsmanPreset.tscn`). |
| **`Map.gd` & `WorldMap.gd` Management** | Framework | **KEEP** | Dynamic layer loading, fringe parenting, and instance pooling work flawlessly. |
| **Western Fantasy Maps (Candor, Artis)**| Content / Map | **REPLACE** | Medieval towns and castles replaced by Xianxia zones (`SacredSectHub`, `TanThuThon`). |
| **Prototype C 2.5D Isometric World** | Environment | **KEEP** | Freeform footprint, Y-sort depth sorting, and collision polygons validated. |
| **`NpcScript.gd` Coroutine DSL** | Gameplay Logic | **KEEP** | `Mes()`, `Choice()`, `Warp()`, `Shop()`, `AddQuest()` provide complete dialogue scripting. |
| **Western Fantasy NPCs (Gabz, Sailor)** | Content / NPC | **REPLACE** | Replaced by Xianxia elders, merchants, and sect figures. |
| **`MonsterAgent.gd` AI & Spawns** | Gameplay Logic | **KEEP** | Wandering, aggro detection, pathfinding chase, and loot drops work out of the box. |
| **Western Monsters (Slime, Goblin)** | Content / Monster | **REPLACE** | Replaced by Xianxia beasts (Thỏ Tinh, Bạch Lang, Yêu Xà, Ma Đạo Tu Sĩ). |
| **Boss Tracker Bar & Music Hook** | UI / Gameplay | **KEEP** | `_isBoss = true` and `BossTrackerBar.gd` trigger seamlessly. |
| **Attribute Calculations (`Formula.gd`)** | Gameplay Logic | **ADAPT** | Base attributes (STR, VIT, AGI, END, CON) mapped 1:1 to Xianxia attributes. |
| **Combat / Skill Execution (`Skill.gd`)** | Gameplay Logic | **ADAPT** | Adapt Mana cost $\to$ Chân Khí / Linh Lực; expand skill ranges for flying swords. |
| **Inventory & Equipment (11 Slots)** | Gameplay Logic | **ADAPT** | 11 slots mapped to Xianxia attire (Bản Mệnh Kiếm, Đạo Bào, Trữ Vật Giới). |
| **Western Fantasy Items & Potions** | Content / Item | **REPLACE** | Replaced by Xianxia pills (Đan Dược), spirit stones (Linh Thạch), materials (Linh Thảo). |
| **Quest Tracking (`QuestData.gd`)** | Gameplay Logic | **KEEP** | Objective types (Kill, Talk, Gather) fit Xianxia mission structure perfectly. |
| **Western Quests (Shipwreck, Rats)** | Content / Quest | **REPLACE** | Replaced by Cultivation trials (Nhập Môn Khảo Nghiệm, Trảm Sát Ma Thú). |
| **GUI Layout & Windows (Godot Control)**| UI / Client | **ADAPT** | Keep window management; reskin theme from Western wood to Chinese Jade & Ink. |
| **Audio Music & SFX Engine** | Audio | **ADAPT** | Keep `AudioService`; replace Western tracks with Guzheng, Dizi, Erhu compositions. |
| **Localization Infrastructure** | Framework | **REPLACE** | SoM has no localization; introduce Godot `TranslationServer` with Vietnamese (`vi_VN`). |

---

## 3. ORIGINAL SOM TO TDNM CONTENT MAPPING

### 3.1 Maps & World Hierarchy
| SoM Original Map | Role | TDNM Xianxia World Map | Role & Narrative Theme |
| :--- | :--- | :--- | :--- |
| `Ship` (Tutorial / Intro) | Shipwreck tutorial | **Thần Bí Thảo Đường** | Mountain hermitage where the player awakens as an aspiring mortal cultivator. |
| `Candor Island` | Beginner town | **Thanh Vân Thôn (Tân Thủ Thôn)** | Peaceful mortal village nestled beneath the clouds, beset by low-tier spiritual beasts. |
| `Artis` | Capital city | **Thánh Địa Tông Môn (Sacred Sect Hub)** | Grand immortal sect headquarters (Kunlun, Wudang, Shaolin pavilions) — already playable. |
| `Tonori` | Desert wilderness | **Vạn Yêu Cổ Lâm** | Primordial wilderness filled with savage beasts and spiritual herbs. |
| `Drazil` | Underground caverns | **Hắc Phong Động (Ma Quật)** | Demonic subterranean cave harboring rogue demonic cultivators (Ma Tu). |
| `Ocean` | Sea routes | **Đông Hải Tiên Đảo** | Mystical archipelagos for high-level maritime cultivation expeditions. |

---

### 3.2 Characters & Non-Player Characters (NPCs)
| SoM Original NPC | Original Role | TDNM Xianxia NPC | Xianxia Function & Dialogue Role |
| :--- | :--- | :--- | :--- |
| `Gabz` | Local tutorial guide | **Thôn Trưởng Triệu Bá** | Village elder of Tân Thủ Thôn; introduces basic martial guidance and local troubles. |
| `Sailor / Captain` | Transport captain | **Truyền Tống Sứ Giả** | Sect envoy who transports worthy disciples between Tân Thủ Thôn and the Sacred Sect Hub. |
| `Merchant Tom` | General store | **Vạn Bảo Các Chưởng Quỹ** | Immortal pavilion merchant selling spirit herbs, empty talismans, and recovery pills. |
| `Blacksmith Hal` | Weaponsmith | **Luyện Khí Sư Cổ Thiết** | Blacksmith repairing flying swords and forging basic spiritual armors. |
| `Priest Elan` | Healer / Resurrect | **Dược Sư Liễu Y** | Sect alchemist restoring vitality and detoxifying demonic miasma. |
| *(None / New)* | — | **Truyền Công Trưởng Lão** | Sect Elder presiding over cultivation realm breakthroughs (Luyện Khí $\to$ Trúc Cơ). |

---

### 3.3 Monsters & Bosses
| SoM Original Monster | Level | TDNM Xianxia Beast | Nature & Combat Behavior |
| :--- | :---: | :--- | :--- |
| `Poring / Slime` | Lv 1–3 | **Thỏ Tinh (Spiritual Hare)** | Docile herbivore infused with weak spiritual energy; non-aggressive unless provoked. |
| `Goblin` | Lv 4–6 | **Lang Yêu (Feral Wolf Beast)** | Pack predator roaming village outskirts; aggressive pursuit with leap bite. |
| `Giant Spider` | Lv 7–9 | **Độc Giác Chu (Poison Horn Spider)**| Poison-spitting arachnid causing slow and damage-over-time alterations. |
| `Splatyna` | Lv 12 | **Hắc Phong Ma Viên (Black Wind Ape)** | Elite wild beast wielding heavy wooden club; high endurance and knockdown stomp. |
| `Xakelbael` (Demon Boss)| Lv 25 | **Xích Diễm Ma Long (Crimson Fire Drake)**| World Boss with multi-target flame breath, high critical rate, and overhead boss tracker. |

---

### 3.4 Attributes & Combat Stat Conversion
Source of Mana centralizes all mechanics in `Formula.gd`. Here is the authoritative mapping:

| SoM Attribute | TDNM Xianxia Term | Meaning & Mechanical Function in TDNM |
| :--- | :--- | :--- |
| `strength` | **Lực Lượng (Strength)** | Increases physical attack power, blade weight capacity, and blunt force damage. |
| `vitality` | **Thể Chất (Vitality)** | Increases maximum health (Khí Huyết) and passive health regeneration. |
| `agility` | **Thân Pháp (Agility)** | Increases movement speed, evasion rate, and basic attack animation speed. |
| `endurance` | **Khí Huyết / Ngự Thủ (Endurance)** | Increases physical defense mitigation and stamina threshold for blocking. |
| `concentration` | **Định Lực / Ngộ Tính (Perception)**| Increases spiritual mana (Chân Khí), spell penetration, and critical strike chance. |
| `health` | **Khí Huyết (Health Points)** | Life essence. Depletion leads to spiritual body dispersion (death). |
| `mana` | **Chân Khí / Linh Lực (Spiritual Energy)**| Resource consumed to execute sword techniques, fly, and activate magic treasures. |

---

### 3.5 Items, Consumables & Equipment
| SoM Original Item | TDNM Xianxia Item | Type | Effect & Xianxia Lore |
| :--- | :--- | :---: | :--- |
| `Red Apple / Health Potion`| **Hồi Huyết Đan (Blood Return Pill)**| Consumable | Instantly restores 150 Khí Huyết (Health). |
| `Blue Potion / Mana Water` | **Hồi Khí Đan (Qi Recovery Pill)** | Consumable | Restores 100 Chân Khí (Spiritual Energy). |
| `Wooden Stick` | **Mộc Kiếm (Peach Wood Sword)** | Weapon | Basic training sword crafted from lightning-struck peach wood. |
| `Iron Sword` | **Thanh Phong Kiếm (Breeze Sword)** | Weapon | Tier-1 mortal flying sword with sharp cutting edge (+25 Attack). |
| `Cloth Tunic` | **Thô Bố Y (Coarse Cloth Robe)** | Chest Armor | Humble garment worn by outer disciples (+5 Defense). |
| `Leather Boots` | **Thần Hành Hài (Swift Walk Boots)** | Boots | Boots enchanted with wind runes (+10 Movement Speed). |
| `Copper Ring` | **Thanh Ngọc Giới (Green Jade Ring)** | Ring | Minor talisman stabilizing cultivator focus (+5 Ngộ Tính). |
| `Gold Coin` | **Hạ Phẩm Linh Thạch (Low Spirit Stone)**| Currency | Universal medium of trade and cultivation energy in the immortal world. |

---

### 3.6 Skills & Cultivation Techniques
| SoM Skill | TDNM Skill Name | Element | Description & Effects |
| :--- | :--- | :---: | :--- |
| `Melee Attack` | **Phổ Thông Kiếm Quyết** | Phàm | Standard 8-directional sword thrust/slash. |
| `Fireball` | **Hỏa Cầu Thuật (Fireball Art)** | Hỏa | Launches blazing orb of spiritual flame exploding on contact. |
| `Ice Shard` | **Băng Thứ Thuật (Ice Spike Art)**| Thủy | Pierces target with frozen spike, inflicting 3-second movement slow. |
| `Heal` | **Mộc Xuân Thuật (Spring Wood Heal)**| Mộc | Channels vegetative vitality to restore health over time. |
| `Dash / Slash` | **Ngự Kiếm Nhất Kích (Sword Thrust)**| Kim | Rapid forward dash thrust dealing 200% weapon damage. |
| `Shield / Stone Skin` | **Kim Cang Hộ Thể (Vajra Shield)** | Thổ | Surrounds body with golden qi barrier absorbing up to 500 damage. |

---

## 4. TARGET TDNM LOGICAL CONTENT STRUCTURE

To avoid polluting the engine core while establishing a modular Xianxia content hierarchy, we define the target content layout. 

Because `Path.gd` and `DB.gd` resolve paths relative to `res://presets/` and `res://data/`, the Xianxia content will be organized into namespaced subdirectories that naturally register with Godot's resource loader:

```text
res://
├── assets/
│   ├── characters/
│   │   └── swordsman/             # 56-animation sprite frames & textures
│   └── environment/
│       ├── xianxia/               # Sacred Sect Hub & Tan Thu Thon visual nodes
│       └── sprites/               # Eastern buildings, pavilions, flora
├── presets/
│   ├── cells/
│   │   ├── items/xianxia/         # Linh Thạch, Đan Dược, Pháp Bảo .tres
│   │   └── skills/xianxia/        # Ngự Kiếm Thuật, Hỏa Cầu .tres
│   ├── entities/
│   │   ├── monsters/xianxia/      # ThoTinh.tres, LangYeu.tres
│   │   └── npcs/xianxia/          # ThonTruong.tres, TruyenCong.tres
│   ├── maps/
│   │   ├── layers/xianxia/        # SacredSectHub.tscn, TanThuThon.tscn
│   │   ├── server/xianxia/        # MapServerData with Xianxia spawn tables
│   │   └── navigations/xianxia/   # NavigationPolygon resources for pathfinding
│   └── quests/xianxia/            # NhapMonKhaoNghiem.tres
├── sources/
│   ├── scripts/xianxia/           # NpcScript implementations for village & sect
│   └── localization/              # Vietnamese / Chinese string translation dictionaries
└── data/
    └── music/xianxia/             # Traditional Eastern instrumental tracks (.ogg)
```

**Rule:** No moving or renaming of original SoM folders (`candor/`, `artis/`, `items/`) until the Xianxia equivalents are fully implemented and verified. Both sets can safely coexist during the transition.

---

## 5. FIRST PLAYABLE CONTENT SLICE SPECIFICATION

The goal of the first playable content slice (targeted across Phases 4.1–4.5) is to deliver an authentic Xianxia gameplay loop without regressions:

1. **Zone:** **Tân Thủ Thôn (Thanh Vân Thôn)** — peaceful beginner village with rural peach trees, bamboo huts, stone wells, and dirt paths.
2. **Player Character:** 8-directional cultivator swordsman with walking, running, idle, and attack animations.
3. **Village Elder NPC:** **Thôn Trưởng Triệu Bá** standing near the village center.
   - Scripted via `NpcScript.gd`.
   - Offers dialogue: *"Chào đạo hữu, chào mừng đến với Thanh Vân Thôn..."*
   - Gives the first main quest: **Nhập Môn Khảo Nghiệm** (Kill 3 Lang Yêu outside the village).
4. **Beginner Monster:** **Lang Yêu (Feral Wolf Beast)**.
   - Spawns in the outskirts of Tân Thủ Thôn via `SpawnObject`.
   - Aggro radius: 250 pixels.
   - Uses basic bite attack.
5. **Combat Encounter:**
   - Player targets Lang Yêu and executes basic attack / sword thrust.
   - Server runs `Formula.gd` damage calculation.
   - Floating damage labels (`AlterationLabel.tscn`) appear overhead.
6. **Reward & Progression:**
   - Killing 3 Lang Yêu completes quest objective in `ActorProgress`.
   - Monster drops **Hạ Phẩm Linh Thạch** and **Lang Bì (Wolf Pelt)**.
   - Player returns to Thôn Trưởng, receives EXP and **Hồi Huyết Đan**.
7. **Warp to Sect Hub:**
   - Thôn Trưởng introduces **Truyền Tống Trận** (Teleport Array) warping player to **Sacred Sect Hub** (`id = 995840901`).
8. **Multiplayer & Persistence Verification:**
   - Two clients (Native Desktop & Web Browser) witness each other in Tân Thủ Thôn.
   - Combat, drops, and NPC dialogues update simultaneously.
   - Disconnecting and reconnecting preserves quest completion, inventory, and character coordinates in SQLite.
