# PROJECT CONTEXT — THIÊN ĐẠO NGHỊCH MỆNH
## Document Version: 2.1 (Phase 2.1 Context Recovery)
## Engine: Godot Engine 4.7.1 Stable (Official)
## Upstream Foundation: Source of Mana (Commit `1933bd6`)

---

### 1. Project Overview & Identity

**Thiên Đạo Nghịch Mệnh** (TDNM) is an isometric 2.5D Xianxia / Tu Tiên MMORPG developed on top of the open-source Godot engine base **Source of Mana**. 

**Core Direction:**
TDNM continues to use the existing Source of Mana world and its 40+ interconnected maps as the **MAIN GAME WORLD**. We are NOT replacing the existing world with a newly built parallel world or making a newly created village the replacement main map. The strategy is to preserve the existing SoM world as the physical and technical foundation, then gradually transform its environment, characters, NPCs, quests, items, and monsters into the Xianxia cultivation setting. New maps (sects, cities, secret realms, dungeons) will be introduced progressively as additive expansions serving the story and gameplay.

The game combines traditional Eastern martial arts and cultivation fantasy (Tu Tiên, Ngũ Hành, Lôi Kiếp, Tông Môn, Phi Kiếm) with high-performance 2D pixel art, real-time multiplayer synchronization, and cross-platform native (macOS, Windows, Linux) and Web browser deployment.

---

### 2. Dual-Repository Architectural Model

To guarantee the permanence and immutability of the artistic assets and game design documents, the project maintains strict dual-repository separation:

```
[Vault Repository: thien-dao-nghich-menh]
  ├── public/assets/ (357 files, 42.3 MB - IMMUTABLE MASTER)
  ├── docs/ (Design specs, original Three.js/Colyseus architecture)
  └── Read-only / Immutable Single Source of Truth
                      │
                      │ (Selective Copy Pipeline — Zero Mutation on Vault)
                      ▼
[Godot Fork: thien-dao-nghich-menh-godot]
  ├── assets/ (Migrated runtime assets, 56-anim SpriteFrames, test scenes)
  ├── sources/ (SoM core GDScript networking, actor, GUI, and map logic)
  ├── data/ (Quarantined legacy SoM assets)
  ├── builds/ (Exported client macOS, server Linux, and Web WASM binaries)
  └── docs/ (Phase-by-phase engineering reports and verification logs)
```

#### Rules of Vault Preservation:
1. **Zero Mutations:** No script or tool may write, edit, rename, move, or delete files in `thien-dao-nghich-menh/public/assets`.
2. **Selective Extraction:** Assets are copied selectively into `thien-dao-nghich-menh-godot/assets/` only when approved and required.
3. **Traceability:** Every migrated asset is mapped back to its original vault path in `assets/source_metadata/vault_asset_manifest.json`.

---

### 3. Core Engine & Technical Stack

- **Target Engine:** Godot Engine v4.7.1.stable.official.a13da4feb (Universal macOS arm64/x86_64, Forward+ Metal 4.0 / Vulkan / WebGL2).
- **Upstream Commit Pin:** `1933bd66caf2c59fd5d9b5df410d19838059b243`.
- **Baseline Git Tag:** `v0.1.0-baseline-1933bd6`.
- **Remotes:**
  - `origin`: `https://github.com/Cuong2000aa/thien-dao-nghich-menh-godot.git`
  - `upstream`: `https://github.com/sourceofmana/sourceofmana.git`
- **Networking:** Authority dedicated server running headlessly (`--server`).
  - **Native PC Transport:** ENet UDP (Port 6119 for debug/testing, 6109 for production).
  - **Web Browser Transport:** WebSocket TCP (Port 6118 for debug/testing, 6108 for production).
- **Persistence:** Embedded SQLite 3.45.1 via `libgdsqlite` GDExtension with WAL (Write-Ahead Logging) journal mode.
- **Rendering Paradigm:** 2.5D Hybrid Isometric with GPU Y-Sort (Option C).
  - Tiled 2:1 dimetric ground plane.
  - Large monolithic sect architecture (Shaolin, Wudang, Kunlun, Emei) with custom 2D polygon footprints.
  - Natural depth occlusion (actors render behind roofs and in front of entrance steps seamlessly).

---

### 4. Character Animation Architecture

- **Martial Protagonist:** Wandering Swordsman (`res://assets/characters/swordsman/`).
- **8-Directional Model:** All character animations feature 8 discrete directions (`south`, `south-east`, `east`, `north-east`, `north`, `north-west`, `west`, `south-west`).
- **Compiled Animations:** 56 animations compiled into `res://assets/characters/swordsman/swordsman_frames.tres` using `AtlasTexture` slicing.
- **Dynamic Foot Anchoring (`foot_px`):** To eliminate visual sprite jumping when transitioning between different frame dimensions ($40 \times 40$ walk vs $72 \times 72$ attack vs $56 \times 56$ hurt), the controller dynamically adjusts the sprite offset by `-FOOT_OFFSETS[action]`, pinning the feet to local `(0, 0)`.

---

### 5. Important Visual & Palette Directives

#### 5.1 Intentional Magenta / Chroma-Key Backgrounds
Certain legacy asset packs (notably *Xianxia Pixel Pack v2.1*) were authored with intentional `#FF00FF` (pure magenta, RGB `255, 0, 255`) chroma-key backgrounds for 16-bit sprite sheets.
- **Rule:** Do NOT treat magenta backgrounds as engine rendering bugs.
- **Handling:** Do not destructively recolor or modify raw vault source files. In the runtime pipeline, apply an alpha-cutout shader or convert copies to transparent PNGs in staging before ingestion.

#### 5.2 License Gate for Chinese.Dragon Assets
Architecture assets originating from the itch.io *Ancient Chinese Buildings Bundle* by Chinese.Dragon are currently approved for **internal prototyping, diorama evaluation, and development builds only**. They must remain excluded from public commercial release builds until written client redistribution rights are finalized.

---

### 6. Phase 4.0 Content Audit & Transformation Strategy
- **Core Philosophy:** Content transformation, NOT a rewrite. Source of Mana core engine, networking, movement, database, and physics are preserved.
- **22-Domain Audit:** Detailed in `docs/PHASE_4_0_SOURCE_AUDIT.md`. Over 80% of framework code is reused directly or adapted via configuration.
- **Content Mapping & Target Slice:** Detailed in `docs/PHASE_4_0_CONTENT_MAPPING.md` (Tân Thủ Thôn beginner village, Thôn Trưởng Triệu Bá NPC, Lang Yêu beast, Lực Lượng/Thể Chất/Thân Pháp stats, Chân Khí energy).
- **Architectural Invariants & Invariant Rules:** Detailed in `docs/PHASE_4_0_DEPENDENCY_MAP.md`.
- **Implementation Sequence (Phases 4.1–4.5):** Detailed in `docs/PHASE_4_0_TDNM_ROADMAP.md`. Strict gate: Phase 4.1 begins only upon explicit user authorization.

---

### 7. Phase 4.1 Thanh Vân Thôn Implementation (Tier 3 Expansion Map)
- **Classification:** Additional / Expansion Map (Tier 3). Does NOT replace the main starting map (`Tulimshar`) or the main world.
- **Location:** Thanh Vân Thôn (`TanThuThon`, Map ID `1841251538`, size $3200 \times 2400$).
- **7 Organic Zones:** Zone A (Village Center & Ancestral Hall), Zone B (Residential Quarters), Zone C (Spiritual Herb Farm), Zone D (Peach Blossom Grove), Zone E (Stream, Watermill & Covered Bridge), Zone F (Moon Gate & Teleport Array), Zone G (Wilderness Buffer).
- **Two-Way Warp:** Seamless bidirectional warping between `TanThuThon` (`1841251538`) and `SacredSectHub` (`995840901`) with anti-bounce safety spacing.
- **Cross-Platform Play:** Verified across Native Desktop (ENet 6119) and real Microsoft Edge browser (WebSocket 6118).
- **Deliverable:** Fully documented in `docs/PHASE_4_1_IMPLEMENTATION_REPORT.md`.

---

### 8. Protagonist & Narrative Premise
- **Origin:** Transmigrated modern person from the 21st-century real world.
- **Physical Reality:** Retains his **original physical body**, his **memories**, **modern scientific/practical knowledge**, and authentic **personality**.
- **No Body Possession:** He does NOT possess (đoạt xá) another cultivator's body or steal another identity.
- **Story Arc:** Survival in an unfamiliar world, gradual discovery of cultivation, personal growth, world exploration through the main SoM map network, and uncovering the cosmic truth behind his transmigration and the Heavenly Dao.

---

### 9. Phase 4.1.1 & 4.1.2 Default Spawn Restoration & Location Naming System
- **Default Spawn Restored:** Reverted `LauncherCommons.gd` default spawn back to the canonical starting city **Tulimshar** (`DefaultStartMapID = "Tulimshar".hash()`, `DefaultStartPos = Vector2i(2176, 2560)`, `DefaultStartOffset = Vector2i(64, 32)`). All new characters begin at Tulimshar (Thanh Sa Cảng), while existing characters retain their saved positions in SQLite.
- **Centralized Location Naming System:** Implemented via [`LocationNaming.gd`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/world/LocationNaming.gd) and [`MapData.GetDisplayName()`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/db/instance/MapData.gd).
- **Core Principle:** Internal technical map names, hash IDs, and resource paths remain 100% immutable; player-facing UI (notifications, status window, warp menus) dynamically queries the Vietnamese Xianxia display names.
- **Registry Coverage:** Complete inventory of 42 maps documented in [`docs/world/LOCATION_NAMING_REGISTRY.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/LOCATION_NAMING_REGISTRY.md) (32 APPROVED, 9 PROPOSED, 1 PENDING OWNER APPROVAL).

---

### 10. Phase 4.2 World Bible Foundation & Xuanhuan World Design
- **Genre Synthesis:** Classical Xianxia foundation (cultivation, realms, qi, meridians, Dao, tribulations) combined with Xuanhuan expansion (ancient bloodlines, mythical beasts, lost civilizational epochs, fragmented Heavenly Dao).
- **Core World Bible Suite:** Complete 12-document architecture in `docs/world/`:
  - Central Master Index: [`WORLD_BIBLE.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/WORLD_BIBLE.md)
  - Pillar 1 (Cosmology): [`COSMOLOGY.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/COSMOLOGY.md) (Fragmented Heavenly Dao, Planar Suppression)
  - Pillar 2 (History): [`WORLD_TIMELINE.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/WORLD_TIMELINE.md) (5 macro-eras, ancient cataclysms, transmigration hooks)
  - Pillar 3 (Cultivation): [`CULTIVATION_SYSTEM.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/CULTIVATION_SYSTEM.md) (6 power pillars, 2 progression models compared)
  - Pillar 4 (Races & Creatures): [`RACES_AND_CREATURES.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/RACES_AND_CREATURES.md) (4 entity tiers, 42-map mob/boss mapping, pets/mounts)
  - Pillar 5 (Factions & Sects): [`FACTIONS_AND_SECTS.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/FACTIONS_AND_SECTS.md) (5 faction blocs, SacredSectHub kept PENDING)
  - Pillar 6 (Resources & Economy): [`RESOURCES_AND_ARTIFACTS.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/RESOURCES_AND_ARTIFACTS.md) (Spirit stones, herbs, pills, ores, gear hierarchy)
  - Protagonist Profile: [`MAIN_CHARACTER.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/MAIN_CHARACTER.md) (Modern origin, real body, zero cheat start, pending talent)
  - Narrative Framework: [`NARRATIVE_STRUCTURE.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/NARRATIVE_STRUCTURE.md) & [`STORY_OVERVIEW.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/STORY_OVERVIEW.md) (6 preliminary chapters)
  - Geography & Map Roles: [`WORLD_GEOGRAPHY.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/WORLD_GEOGRAPHY.md) (42 maps, 3 transformation tiers, gameplay roles)
  - Decision Matrix: [`WORLD_DESIGN_DECISIONS.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/world/WORLD_DESIGN_DECISIONS.md) (Canon, proposals, open questions)
- **Strict Scope Boundary:** 100% design and documentation; zero gameplay, code, scene, or asset modifications.

---

### 11. Phase 4.2.1 Owner Decisions Integration & World Bible Revision
- **Authoritative Decisions Integrated:**
  - **D-01 (Protagonist Cultivation Aptitude) [APPROVED]:** The protagonist has **Ngũ Hành Tạp Căn** (Five-Element Mixed Root: Kim, Mộc, Thủy, Hỏa, Thổ). Low aptitude, slow Qi refinement, no hidden/latent root awakening, no unexplained mutation, no game/cheat system. Modern knowledge aids logic, record-keeping, experimentation, and resource management, but science cannot bypass spiritual laws.
  - **D-02 (Nature of the Heavenly Dao) [APPROVED]:** **Thiên Đạo Tổn Thương — Quy Tắc Dị Biến** (Damaged / Fragmented Objective Heavenly Dao). An objective cosmic law that became fragmented after a Primordial Catastrophe. Strictly **NOT** an evil sentient entity; does **NOT** harvest cultivators as crops. Cause of catastrophe, identity of ancient forces, and nature/number of fragments remain unresolved mysteries.
  - **D-03 (SacredSectHub Identity) [PENDING OWNER APPROVAL]:** Internal map ID `995840901`, technical name `SacredSectHub`. Official display name, sect name, philosophy, hierarchy, and lore remain strictly NOT DECIDED. Do NOT name "Thiên Đạo Tông", "Vạn Kiếm Tiên Tông", "Thái Hư Đạo Tông", or "Bắc Huyền Tông". Do NOT treat as the protagonist's guaranteed first sect.
  - **D-04 (Cultivation Realm Structure) [APPROVED]:** Hybrid progression model: Pre-cultivation stage **Phàm Thân**; first cultivation realm **Tụ Khí Cửu Trọng Thiên (Tầng 1–9)**; subsequent major realms each have 4 stages (Sơ Kỳ, Trung Kỳ, Hậu Kỳ, Đại Viên Mãn) across **Thông Mạch**, **Đạo Cơ**, **Huyền Đan**, **Nguyên Thần**, **Thiên Nhân**, **Quy Hư**, **Độ Kiếp**. The classic model is preserved only as an unselected historical alternative.
- **Critical Conceptual Distinctions Documented:**
  - **Issue D (Lower Realm Ceiling):** Recorded as `PENDING — LOWER REALM CULTIVATION CEILING AND ASCENSION TRANSITION` with 3 interpretations (Nguyên Thần vs Thiên Nhân vs Độ Kiếp).
  - **Issue E (Soul Possession vs Physical Transmigration):** Cultivator soul-possession techniques (đoạt xá) are in-universe martial arts abilities, completely distinct from the protagonist's physical space-time transmigration in his original 21st-century body.
  - **Issue F (Body Cultivation Boundaries):** Clarified distinction between Spiritual-Root cultivation, Body Cultivation (Thể Tu), and Dual Cultivation. Thể Tu is NOT a free shortcut around lack of spiritual roots; it requires extreme physical agony, rare resources, and faces severe bottlenecks and tribulations.
- **Verification Evidence:** Zero code or scene mutations; all 12 documents in `docs/world/` updated with 100% internal consistency. Full report in `docs/PHASE_4_2_1_OWNER_DECISIONS_INTEGRATION_REPORT.md`.




