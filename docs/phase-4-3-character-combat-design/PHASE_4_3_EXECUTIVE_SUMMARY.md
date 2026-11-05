# PHASE 4.3 — EXECUTIVE SUMMARY
## Character & Combat Architecture Design

**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Engine:** Godot 4.7.1 Stable  
**Foundation:** Source of Mana (Baseline commit: `1933bd66caf2c59fd5d9b5df410d19838059b243`)  
**Phase:** 4.3  
**Status:** COMPLETE — PENDING PROJECT OWNER APPROVAL  
**Date:** November 2026  

---

## 1. PURPOSE & MANDATE

Phase 4.3 establishes the comprehensive technical architecture and design specifications required to transform Source of Mana's Western fantasy combat and character rendering into an authentic, responsive Chinese Xianxia/Xuanhuan MMORPG.

The governing development imperative remains strictly:

$$\text{\bf CONTENT TRANSFORMATION, NOT A REWRITE.}$$

In strict compliance with project governance:
- **Zero code, scene, resource, or asset modifications** were made in this phase.
- All baseline Source of Mana architecture (server authority, ENet/WebSocket networking, SQLite persistence, Actor/Agent/Entity/Visual structure) is preserved.
- All approved World Bible invariants (Owner Decisions D-01, D-02, D-03, D-04) have been rigorously integrated.

---

## 2. KEY ARCHITECTURAL FINDINGS & SOLUTIONS

### Workstream A — Character Rendering Architecture
- **Problem:** The discovered Swordsman asset provides 512 frames across 8 directions. Hand-drawing layered armor/weapons for 512 frames leads to a fatal combinatorial art explosion (25,600+ frames).
- **Solution (Option C3):** Adopt a **Shader-Tinted Robe + Dynamic Socket + Orbiting Spirit Artifact** architecture. Customization is achieved via GPU palette-swap shaders and procedural attachment nodes (`Marker2D` and `PhiKiemNode2D`), achieving rich visual variety with linear $O(N)$ art production.

### Workstream B — Animation State System Design
- **Problem:** Swordsman contains 7 distinct animation types (Idle, Walk, Attack, Combo, Qinggong, Hurt, Death), but the server state machine (`ActorCommons.State`) only supports 8 fundamental states. Adding states causes packet bloat and network desync.
- **Solution (4-Tier Action Dispatch):** Keep server states strictly at 8. Map `Qinggong` to `WALK + isRunning`, `Combo` to a client chained input window during `ATTACK`, `Meditation` directly to existing `State.SIT` ($2.0\times$ HP/MP regen), and `HURT` to a non-interrupting visual overlay shader to eliminate MMORPG stunlock.

### Workstream C — Equipment & Customization Pipeline
- **Problem:** Western fantasy slots (Helmet, Shield, Boots, Cloak) do not reflect Xianxia aesthetics.
- **Solution:** Re-conceptualize the 12 inventory slots into Xianxia counterparts (Linh Kiếm, Đạo Bào, Trữ Vật Đại, Linh Bội, etc.). Stat math is preserved 100%, while visuals are driven by the 3-Tier Xianxia Visual Pipeline.

### Workstream D — Combat Engine & Hit Resolution
- **Problem:** Baseline `IsNear` checks Euclidean radial distance only, allowing players to hit enemies behind them and creating floaty, inaccurate combat.
- **Solution (Model D - Hybrid Engine):** Server evaluates Directional Geometry (Cones for slashes, Linear Rays for flying sword thrusts, Circles for area bursts) using pure vector math (zero physics overhead). Server schedules hit resolution at the animation's **Impact Apex Frame** ($\tau_{\text{hit}} \approx 416\text{ ms}$), creating frame-accurate, satisfying visual feedback.

### Workstream E — Xianxia Skill Architecture
- **Problem:** Baseline skill categories (`PHYSICAL`, `SPELL`, `ABILITY`) lack elemental metaphysics.
- **Solution:** Integrated the full **Ngũ Hành (Five Elements: Kim, Mộc, Thủy, Hỏa, Thổ)** cycle. Fully aligned with Owner Decision **D-01 (Ngũ Hành Tạp Căn)**: the protagonist possesses all five roots, experiencing slower cultivation and higher resource costs, but enjoying complete tactical flexibility. Skills are strictly gated by **D-04 Cultivation Realms**. 15 prototype skills cataloged.

### Workstream F — Multiplayer Combat Synchronization & Latency
- **Problem:** Web browser clients (WebSocket TCP) experience higher jitter than Desktop clients (ENet UDP). Input lag ruins melee combat feel.
- **Solution:** Implement **Responsive Client Prediction** for instant local windups. Implement a **Forward Tolerance Window** ($\le 64\text{ px}$ buffer) on server geometry checks to absorb network jitter without expensive physics history rewinds.

### Workstream G — Incremental Migration Roadmap
- **Strategy:** Structured execution plan spanning Phase 5.0 through Phase 5.5. Every sub-phase contains explicit deliverables, automated test gates, and zero-regression safeguards for baseline Tulimshar gameplay.

---

## 3. TABLE OF DELIVERABLES

All phase deliverables have been authored and organized within `docs/phase-4-3-character-combat-design/`:

| File | Workstream / Content | Focus Area |
| :--- | :--- | :--- |
| [`01_CHARACTER_RENDERING_ARCHITECTURE.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/01_CHARACTER_RENDERING_ARCHITECTURE.md) | Workstream A | 4 Rendering Options, 9-Criteria Evaluation Matrix, Option C3 Selection |
| [`02_ANIMATION_STATE_SYSTEM_DESIGN.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/02_ANIMATION_STATE_SYSTEM_DESIGN.md) | Workstream B | 4-Tier Action Dispatch, Swordsman 56 anims, Qinggong, Combo, Sit |
| [`03_EQUIPMENT_AND_CUSTOMIZATION_PIPELINE.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/03_EQUIPMENT_AND_CUSTOMIZATION_PIPELINE.md) | Workstream C | 12-Slot Xianxia Mapping, 3-Tier Visual Pipeline, Asset Matrix |
| [`04_COMBAT_ENGINE_AND_HIT_RESOLUTION.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/04_COMBAT_ENGINE_AND_HIT_RESOLUTION.md) | Workstream D | 10-Stage Combat Flow, 4 Combat Models, Directional Math & Impact Apex |
| [`05_XIANXIA_SKILL_ARCHITECTURE.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/05_XIANXIA_SKILL_ARCHITECTURE.md) | Workstream E | Five-Element Cycle, D-01 Tạp Căn Dynamics, D-04 Realms, 15 Skills |
| [`06_MULTIPLAYER_COMBAT_SYNC_AND_TIMING.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/06_MULTIPLAYER_COMBAT_SYNC_AND_TIMING.md) | Workstream F | ENet / WebSocket, Client Prediction, Forward Tolerance Window |
| [`07_INCREMENTAL_MIGRATION_ROADMAP.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/07_INCREMENTAL_MIGRATION_ROADMAP.md) | Workstream G | Phases 5.0-5.5 Roadmap, Risk Matrix, Regression Quality Gates |
| [`08_OWNER_DECISION_PACKAGE.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/08_OWNER_DECISION_PACKAGE.md) | Owner Package | Decision Points DP-01 through DP-06 with formal sign-off sheet |
| [`PHASE_4_3_EXECUTIVE_SUMMARY.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/PHASE_4_3_EXECUTIVE_SUMMARY.md) | Executive Summary | Architectural synthesis and governance report (this document) |
| [`PHASE_4_3_MASTER_DESIGN_DOCUMENT.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/PHASE_4_3_MASTER_DESIGN_DOCUMENT.md) | Master Reference | Consolidated monolithic architecture master document |

---

## 4. NEXT STEPS & OWNER ACTION REQUIRED

1. **Review Decision Package:** The Project Owner is requested to review [`08_OWNER_DECISION_PACKAGE.md`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-3-character-combat-design/08_OWNER_DECISION_PACKAGE.md) and indicate approval or modifications for Decision Points DP-01 through DP-06.
2. **Phase 5 Authorization:** Upon Owner approval, Phase 5.0 (Animation Activation & Visual Foundation) will commence implementation in strict accordance with the approved architectural options.
