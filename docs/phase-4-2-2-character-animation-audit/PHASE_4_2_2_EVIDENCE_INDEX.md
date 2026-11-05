# PHASE 4.2.2 EVIDENCE INDEX & ARTIFACT REGISTER
**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Phase:** 4.2.2 — Character & Animation Deep Technical Audit  
**Scope:** Complete Catalog of Visual Evidence, Automated Extraction Scripts, Data Dumps & Test Executions  
**Status:** COMPLETE & AUDITED  

---

## 1. INDEX OVERVIEW

This register indexes all empirical artifacts, visual evidence, data extractions, and test results generated during Phase 4.2.2 in strict accordance with the **Evidence-First Policy**. Every assertion in the audit documents is directly traceable to the physical evidence cataloged below.

---

## 2. VISUAL EVIDENCE CONTACT SHEETS & MONTAGES

All visual evidence artifacts are located in [`docs/phase-4-2-2-character-animation-audit/visual_evidence/`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/visual_evidence/):

| Ref ID | Artifact Filename | Dimensions | File Size | Description & Key Audit Finding |
| :---: | :--- | :---: | :---: | :--- |
| **VIS-01** | [`01_swordsman_8dir_idle_sheet_2x.png`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/visual_evidence/01_swordsman_8dir_idle_sheet_2x.png) | $256 \times 512$ | 26 KB | 8-directional idle stances (4 frames per dir, 32 frames total). Confirms balanced stance, natural breathing posture, sharp silhouette. |
| **VIS-02** | [`02_swordsman_8dir_walk_sheet_2x.png`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/visual_evidence/02_swordsman_8dir_walk_sheet_2x.png) | $480 \times 640$ (Scaled 2x from $240 \times 320$) | 34 KB | 8-directional walk cycles (6 frames per dir, 48 frames total). Confirms smooth locomotion and accurate foot anchoring. |
| **VIS-03** | [`03_swordsman_8dir_attack_sheet.png`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/visual_evidence/03_swordsman_8dir_attack_sheet.png) | $720 \times 576$ | 42 KB | 8-directional primary attack (10 frames per dir, 80 frames total). Verifies sword slash trajectory and follow-through. |
| **VIS-04** | [`04_swordsman_8dir_combo_sheet.png`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/visual_evidence/04_swordsman_8dir_combo_sheet.png) | $1024 \times 512$ | 66 KB | 8-directional multi-hit sword combo (16 frames per dir, 128 frames total). **Proves existence of 128 unused frames.** |
| **VIS-05** | [`05_swordsman_8dir_qinggong_sheet.png`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/visual_evidence/05_swordsman_8dir_qinggong_sheet.png) | $896 \times 512$ | 67 KB | 8-directional high-speed qinggong sprint (14 frames per dir, 112 frames total). **Proves existence of 112 unused frames.** |
| **VIS-06** | [`06_swordsman_8dir_hurt_death_sheet.png`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/visual_evidence/06_swordsman_8dir_hurt_death_sheet.png) | $896 \times 512$ | 55 KB | 8-directional hurt (6 frames/dir, 48 frames) and death (8 frames/dir, 64 frames). **Proves existence of 48 unused hurt frames.** |
| **VIS-07** | [`07_representative_monsters_montage.png`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/visual_evidence/07_representative_monsters_montage.png) | $192 \times 64$ | 11 KB | Montage of baseline mobs: Croc Bandit, Snake, Piou Chick, Giant Turtle. Visually verifies pixel grid consistency. |
| **VIS-08** | [`08_skill_icons_overview.png`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/visual_evidence/08_skill_icons_overview.png) | $192 \times 96$ | 6.9 KB | Montage of 6 representative skill icons: Attack, Run, Candor Circle, PoisonCloud, Fireball, Heal. |

---

## 3. SCRATCH SCRIPTS & AUTOMATED EXTRACTION SUITE

Located in persistent brain scratch storage:

| Script / Data File | Size | Function & Extracted Data |
| :--- | :---: | :--- |
| `audit_extractor.py` | 5.8 KB | Recursively parses Godot `.tres` and `.tscn` text files across `presets/entities/`, `presets/cells/skills/`, and `presets/effects/`. Extracts entity IDs, names, sprites, scripts, and stats. |
| `audit_data.json` | 26 KB | Structured JSON database containing all 97 entity presets, 15 skills, 38 VFX scenes, and 74 audio files. |
| `inspect_sprites.py` | 1.5 KB | Deep-inspects Godot sprite scenes (`.tscn`) to extract root node classes (`AnimatedSprite2D` vs `AnimationPlayer`), child layer nodes, and resource links. |
| `sprite_presets.json` | 13 KB | Structured inventory of all 27 sprite scenes in `presets/entities/sprites/`. |
| `generate_visual_evidence.py` | 5.0 KB | Pillow-based automated contact-sheet generator slicing frames directly from `assets/characters/swordsman/` sheets to produce contact sheets VIS-01 through VIS-08. |
| `make_char_inventory.py` | 6.7 KB | Markdown table generator reconciling entity presets with runtime scenes, directions, and animation counts. |

---

## 4. HEADLESS TEST EXECUTION LOGS & VERIFICATION MATRIX

### 4.1 TestSwordsmanBinding.tscn Scope & Limitations
- **Target:** [`tests/TestSwordsmanBinding.tscn`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/tests/TestSwordsmanBinding.tscn)
- **Engine Command:** `/tmp/godot_setup/Godot.app/Contents/MacOS/Godot --headless --path . tests/TestSwordsmanBinding.tscn`
- **Exact Test Scope:**
  - Loads: `Entity.tscn` with `Player.tres` -> `SwordsmanPreset.tscn` -> `swordsman_frames.tres`.
  - Tests exactly 16 assertions: 8 directional steps for `idle` + 8 directional steps for `walk`.
  - Asserts: `actual_anim == expected_anim` and `actual_offset == expected_offset`.
  - **Critical Limitation:** Does **NOT** test `attack_*`, `death_*`, `combo_*`, `qinggong_*`, or `hurt_*`.
- **Swordsman Animation Verification Matrix:**

| Animation Family | Dirs | Frames | Static Resource Check | Runtime Load | Runtime Playback | Gameplay Trigger | Multiplayer Sync |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `idle_*` | 8 | 32 | **VERIFIED** | **VERIFIED** | **VERIFIED** (Tested in `TestSwordsmanBinding.gd`) | **VERIFIED** (Default state) | **VERIFIED** (Inherited Phase 3/3.1) |
| `walk_*` | 8 | 48 | **VERIFIED** | **VERIFIED** | **VERIFIED** (Tested in `TestSwordsmanBinding.gd`) | **VERIFIED** (Movement input) | **VERIFIED** (Inherited Phase 3/3.1) |
| `attack_*` | 8 | 80 | **VERIFIED** | **VERIFIED** | **STATICALLY IDENTIFIED** (Not in test) | **VERIFIED** (`Skill.Cast()` melee) | **STATICALLY IDENTIFIED** (`Network.gd`) |
| `death_*` | 8 | 64 | **VERIFIED** | **VERIFIED** | **STATICALLY IDENTIFIED** (Not in test) | **VERIFIED** (`health <= 0`) | **STATICALLY IDENTIFIED** (`DEATH` state sync) |
| `hurt_*` | 8 | 48 | **VERIFIED** | **VERIFIED** | **NOT VERIFIED** | **NOT IMPLEMENTED** (No HURT state) | **NOT IMPLEMENTED** |
| `combo_*` | 8 | 128 | **VERIFIED** | **VERIFIED** | **NOT VERIFIED** | **NOT IMPLEMENTED** (No combo logic) | **NOT IMPLEMENTED** |
| `qinggong_*` | 8 | 112 | **VERIFIED** | **VERIFIED** | **NOT VERIFIED** | **NOT IMPLEMENTED** (Runs as walk) | **NOT IMPLEMENTED** |

### 4.2 test_phase_4_1_1_naming.tscn
- **Target:** `tests/test_phase_4_1_1_naming.tscn`
- **Engine Command:** `/tmp/godot_setup/Godot.app/Contents/MacOS/Godot --headless --path . tests/test_phase_4_1_1_naming.tscn`
- **Result:** 100% Pass. Confirms zero regression in baseline Tulimshar spawn and location registry display names (32 APPROVED, 9 PROPOSED, 1 PENDING).

### 4.3 Multiplayer Evidence Provenance
- **Phase 4.2.2 Execution:** Statically inspected GDScript replication logic (`Network.gd`, `BaseAgent.gd`, `Map.gd`, `Entity.gd`). **No new live multi-client network benchmark was executed during Phase 4.2.2.**
- **Phase 3 & 3.1 Historical Inheritance:** Multi-client cross-play between Native Desktop (ENet UDP 6119) and Web Browser (WebSocket TCP 6118 via Edge Chromium CDP automation) was verified empirically in Phase 3/3.1 test scripts (`tests/run_crossplatform_test.sh`). All latency metrics cited (1-5ms desktop, 5-15ms web loopback) originate from these historical test logs.

---

## 5. REPRODUCIBILITY DECLARATION

All evidence in this register was generated non-destructively without modifying any production game code, scenes, or assets. Any future auditor can reproduce these exact visual sheets and test outputs by re-executing the referenced scripts in the scratch directory against baseline commit `1933bd66caf2c59fd5d9b5df410d19838059b243`.

---

*Authored by Senior Godot Engineer & Systems Architect — Thiên Đạo Nghịch Mệnh Phase 4.2.2.*
