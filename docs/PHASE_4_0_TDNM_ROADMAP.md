# PHASE 4.0 — TDNM IMPLEMENTATION ROADMAP (PHASES 4.1 – 4.5)
## Project: THIÊN ĐẠO NGHỊCH MỆNH (TDNM)
**Engine:** Godot 4.7.1 Stable  
**Foundation:** Source of Mana (Commit `1933bd66caf2c59fd5d9b5df410d19838059b243`)  
**Status:** Planning & Sequencing (Awaiting Project Owner Approval)  
**Date:** 2026-11-02  

---

## 1. ROADMAP OVERVIEW & PRINCIPLES

Phase 4 transforms Source of Mana into **Thiên Đạo Nghịch Mệnh** through structured, incremental milestones. Each phase delivers a functional, verifiable content expansion while ensuring that the multiplayer game remains 100% playable and regression-free at every stage.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          PHASE 4.0: AUDIT (CURRENT)                         │
│                    22-Domain Inspection & Mapping Completed                │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                PHASE 4.1: TÂN THỦ THÔN & XIANXIA ENVIRONMENT                │
│             Beginner Village, 2.5D Y-Sort Scenery, Warp to Sect Hub          │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                PHASE 4.2: FIRST XIANXIA NPC & QUEST INTEGRATION             │
│            Thôn Trưởng Triệu Bá, NpcScript DSL, Beginner Quest Line         │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│              PHASE 4.3: FIRST XIANXIA MONSTER & COMBAT ENCOUNTER            │
│                 Lang Yêu Beast, Aggro AI, Combat Damage, Loot Drops         │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│              PHASE 4.4: CULTIVATION REALM CORE & FORMULA ADAPTATION         │
│          Luyện Khí / Trúc Cơ, Chân Khí Energy, Breakthrough Mechanics       │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│               PHASE 4.5: XIANXIA UI/HUD & VIETNAMESE LOCALIZATION           │
│           Jade/Ink Aesthetic Reskin, TranslationServer, First Slice Done    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. DETAILED PHASE BREAKDOWN

### Phase 4.1 — Tân Thủ Thôn Map & Xianxia Environment
- **Objective:** Build and integrate **Thanh Vân Thôn (Tân Thủ Thôn)** as the official beginner spawn zone and establish a two-way warp with the **Sacred Sect Hub**.
- **Scope:**
  - Create `TanThuThon` scene in `presets/maps/layers/xianxia/TanThuThon.tscn`.
  - Assemble rural Eastern village scenery (bamboo huts, peach blossoms, stone well, wooden fences) using Prototype C Y-Sort conventions.
  - Define ground navigation polygon and collision boundaries.
  - Register `TanThuThon.tres` in `presets/maps/server/xianxia/` (`MapServerData`).
  - Configure two-way warp portal linking Tân Thủ Thôn and Sacred Sect Hub (`id = 995840901`).
- **Dependencies:** `Map.gd`, `MapPool.gd`, `WorldMap.gd`, `SacredSectHub.tscn`.
- **Risks & Mitigations:**
  - *Risk:* Y-sort depth clipping between player and rural huts.  
    *Mitigation:* Apply verified Phase 2.1 footprint offsetting rules (`SWORDSMAN_FOOT_OFFSETS`).
- **Acceptance Criteria:**
  - Character spawns in Tân Thủ Thôn upon new game creation.
  - Walking into the sect portal teleports the player smoothly to Sacred Sect Hub.
  - Two players (Desktop and Web) can navigate Tân Thủ Thôn simultaneously with mutual visibility.

---

### Phase 4.2 — First Xianxia NPC & Quest Integration
- **Objective:** Introduce the first interactive Xianxia characters using the existing `NpcScript.gd` coroutine engine.
- **Scope:**
  - Create village elder **Thôn Trưởng Triệu Bá** (`ThonTruong.tres` and `ThonTruongScript.gd`).
  - Implement dialogue branch welcoming the player to cultivation.
  - Create first main quest **Nhập Môn Khảo Nghiệm** (`NhapMonKhaoNghiem.tres`).
  - Configure quest state progression in `ActorProgress` and SQLite `quest` table.
- **Dependencies:** `NpcAgent.gd`, `NpcScript.gd`, `Dialogue.gd`, `Progress.gd`.
- **Risks & Mitigations:**
  - *Risk:* Dialogue text truncation or UTF-8 Vietnamese character corruption.  
    *Mitigation:* Verify font asset UTF-8 support in Godot Label rendering.
- **Acceptance Criteria:**
  - Player can interact with Thôn Trưởng via mouse click or hotkey.
  - Dialogue box opens, displays options, and accepts the quest.
  - Quest appears in player Quest Log (`J` key / Progress panel) with objective: "Trảm Sát 3 Lang Yêu".

---

### Phase 4.3 — First Xianxia Monster & Combat Encounter
- **Objective:** Spawn the first combat-ready Xianxia beast and verify authoritative combat and ground loot drops.
- **Scope:**
  - Create **Lang Yêu (Feral Wolf Beast)** (`LangYeu.tres` in `presets/entities/monsters/xianxia/`).
  - Assign sprite animations, hitboxes, and aggro parameters.
  - Place spawn points in the outskirts of Tân Thủ Thôn via `SpawnObject`.
  - Implement loot drop table: **Hạ Phẩm Linh Thạch** and **Lang Bì**.
  - Authorize melee damage resolution via `Formula.gd` and floating damage numbers (`AlterationLabel`).
- **Dependencies:** `MonsterAgent.gd`, `Formula.gd`, `Skill.gd`, `ItemCell.gd`.
- **Risks & Mitigations:**
  - *Risk:* Monster desync between Desktop and Web clients.  
    *Mitigation:* Rely on server authoritative movement ticks in `MonsterAgent.gd`.
- **Acceptance Criteria:**
  - Lang Yêu roams outskirts; chases player upon entering aggro range.
  - Player attacks with sword; combat damage calculates accurately according to stats.
  - Lang Yêu dies upon reaching 0 HP, awards EXP, increments quest kill counter, and drops loot.
  - Returning to Thôn Trưởng completes quest and awards **Hồi Huyết Đan**.

---

### Phase 4.4 — Cultivation Realm Core & Formula Adaptation
- **Objective:** Implement the core Eastern cultivation progression system (Luyện Khí $\to$ Trúc Cơ $\to$ Kim Đan).
- **Scope:**
  - Adapt `Formula.gd`: map base attributes to Lực Lượng, Thể Chất, Thân Pháp, Khí Huyết, Định Lực.
  - Add cultivation realm progression table (Luyện Khí Tầng 1–9, Trúc Cơ Sơ/Trung/Hậu Kỳ).
  - Introduce **Chân Khí (Spiritual Energy)** pool alongside Health.
  - Implement cultivation breakthrough mechanic (Đột Phá Cảnh Giới) requiring EXP + Trúc Cơ Đan.
  - Extend SQLite schema via migration script `005.sql` to persist `realm_tier` and `cultivation_exp`.
- **Dependencies:** `Formula.gd`, `BaseStats.gd`, `SQL.gd`, `ActorProgress.gd`.
- **Risks & Mitigations:**
  - *Risk:* Database migration breaks existing player records in `testing.db`.  
    *Mitigation:* Write backward-compatible SQLite migration with `DEFAULT` column values.
- **Acceptance Criteria:**
  - Reaching maximum cultivation EXP allows triggering breakthrough.
  - Successful breakthrough grants substantial stat multipliers and changes title overhead.
  - Realm tier persists across server restarts in SQLite.

---

### Phase 4.5 — Xianxia UI/HUD & Vietnamese Localization Gate
- **Objective:** Transform the user interface aesthetic from Western fantasy to Eastern Xianxia and implement full Vietnamese localization.
- **Scope:**
  - Integrate Godot `TranslationServer` with CSV / JSON translation catalogs (`vi_VN` primary, `en_US` secondary).
  - Reskin HUD frames: Jade health globe, Ink-wash borders, crimson skill slots.
  - Skin Character panel to display Cultivation Realm (Cảnh Giới), Spiritual Roots (Linh Căn), and Sect (Tông Môn).
  - Reskin Inventory to "Túi Trữ Vật" (Spatial Storage).
- **Dependencies:** `Gui.gd`, `HUD.gd`, Godot `TranslationServer`, Theme resources.
- **Risks & Mitigations:**
  - *Risk:* Missing translation keys causing empty UI labels.  
    *Mitigation:* Implement automatic English fallback for unmapped translation keys.
- **Acceptance Criteria:**
  - All HUD panels, menus, dialogues, and item descriptions display clean Vietnamese text.
  - UI visual presentation reflects authentic Eastern Xianxia aesthetics.
  - End-to-end playable slice validated with Desktop and Web clients.

---

## 3. ACCEPTANCE & AUTHORIZATION PROTOCOL

- **Do NOT implement Phase 4.1 without explicit user approval.**
- Stop after Phase 4.0 documentation and present findings to the project owner.
