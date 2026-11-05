# PHASE 4.2.2 — EXECUTIVE SUMMARY
## Complete Character, Animation, Combat & Skill Audit

**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Audit Directory:** [`docs/phase-4-2-2-character-animation-audit/`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/)  
**Date:** 2026-11-03  
**Status:** COMPLETE & EMPIRICALLY VERIFIED  
**Scope Boundary:** Documentation and Technical Audit ONLY (0 Code, Scene, or Asset Mutations)

---

## 1. PURPOSE & AUDIT SCOPE

This comprehensive audit investigates the technical reality of characters, animations, combat, skills, VFX/SFX, equipment rendering, and multiplayer synchronization within the Thiên Đạo Nghịch Mệnh Godot repository.

Following the core development principle:
> **Content Transformation, NOT a Rewrite.**  
> The existing Source of Mana (SoM) technical foundation is preserved while its medieval fantasy aesthetics and gameplay systems are systematically audited for transformation into an Isometric 2.5D Chinese Xianxia/Xuanhuan MMORPG.

Every finding in this audit has been verified against actual repository files, source scripts, compiled resources, and headless runtime execution tests under Godot 4.7.1 Stable.

---

## 2. HIGH-LEVEL AUDIT SUMMARY

| Audit Domain | Quantified Inventory | Primary Implementation Architecture | Current Runtime Status | Xianxia Transformation Readiness |
| :--- | :---: | :--- | :---: | :---: |
| **Characters** | **97** Entity Presets<br>(1 Player, 2 Bosses, 28 Mobs, 53 NPCs, 13 Objects) | `Entity.gd` + `Actor.gd` + `Visual.gd` + `Interactive.gd` | **VERIFIED** | **ADAPT / EXPAND** |
| **Animation Systems** | **2** Coexisting Paradigms<br>(SoM 4-dir vs TDNM 8-dir) | Paradigm A: `AnimationPlayer` + `AnimationTree` (4-dir)<br>Paradigm B: `AnimatedSprite2D` + `SpriteFrames` (8-dir) | **VERIFIED** | **PARADIGM B CANONICAL** |
| **Animation Resources** | **56** Swordsman Anims (512 frames)<br>**18** Classic Player Anims (128 frames)<br>**27** Sprite Presets | `swordsman_frames.tres` (8-dir)<br>`presets/entities/sprites/Player.tscn` (4-dir) | **VERIFIED** | **KEEP Swordsman / REPLACE SoM Player** |
| **State Machine** | **8** Global States<br>($8 \times 8$ Transition Matrix) | `ActorCommons.State` + `STATE_TRANSITIONS`<br>`BaseAgent.SetState()` + `Visual.UpdateSwordsmanVisual()` | **PARTIALLY VERIFIED**<br>(Idle & Walk runtime-tested 16/16 in `TestSwordsmanBinding.gd`; Attack & Death active in code; Hurt, Combo, Qinggong unmapped) | **REQUIRES EXTENSION** |
| **Combat Pipeline** | **1** Core Skill/Attack Flow<br>(Client Target $\rightarrow$ Server Cast $\rightarrow$ Hit Timing $\rightarrow$ Client Alteration) | `Entity.Cast()` $\rightarrow$ `Network.TriggerSkill()` $\rightarrow$ `Server.TriggerSkill()` $\rightarrow$ `Skill.Cast()` $\rightarrow$ `Skill.Process()` $\rightarrow$ `Interactive.DisplayAlteration()` | **VERIFIED** | **ADAPT TO REAL-TIME COMBAT** |
| **Skill System** | **15** Active Skill Presets<br>(Melee, Range, Area, Buff, Morph, Run, Jump) | `SkillCell.gd` + `Skill.gd` + `SkillCommons.gd`<br>`presets/cells/skills/*.tres` | **VERIFIED** | **ADAPT TO XIANXIA TECHNIQUES** |
| **VFX / SFX** | **38** Particle/Ambient Scenes<br>**67** SFX Files + **7** Music Tracks | `GPUParticles2D` + `EntityInteractive`<br>`AudioStreamPlayer2D` + `EntitySfx` | **VERIFIED** | **ADAPT (Replace Western with Daoist VFX/SFX)** |
| **Weapons & Equip** | **4** Weapons, **2** Shields, **26** Armor Pieces<br>(Classic SoM 4-dir only) | `Visual.SetEquipment()` + `ItemCell.gd`<br>Layered `Sprite2D` on classic body | **BLOCKED ON SWORDSMAN**<br>(Swordsman has baked equipment) | **REQUIRES MODULAR REFACTOR OR LAYERED SPRITES** |
| **Multiplayer Sync** | **2** Net Protocols (ENet / WSS)<br>Server-Authoritative Sync | `Network.FullUpdateEntity` + `UpdateEntity`<br>Quantized velocity/orientation broadcast | **VERIFIED** (Desktop + Web) | **EXCELLENT (Production Ready Netcode)** |

---

## 3. KEY ARCHITECTURAL DISCOVERIES

### Discovery 1: The Two Incompatible Visual Paradigms
- **Paradigm A (Original Source of Mana):** Uses modular layered `Sprite2D` nodes (`Body`, `Face`, `Hair`, `Chest`, `Legs`, `Feet`, `Hands`, `Weapon`, `Shield`) driven by `AnimationPlayer` and `AnimationTree` (4 directions: Down, Up, Left, Right). Allows dynamic paperdoll equipment swaps, but is locked to 4 directions and Western fantasy proportions.
- **Paradigm B (TDNM Swordsman — Phase 3 Implementation):** Uses a monolithic `AnimatedSprite2D` driven by `swordsman_frames.tres` with 8 isometric directions (`east`, `south-east`, `south`, `south-west`, `west`, `north-west`, `north`, `north-east`). Features dynamic foot anchoring (`SWORDSMAN_FOOT_OFFSETS`) and exceptional Xianxia visual fidelity.
- **Architectural Conflict:** When `animatedSprite` is instantiated (as in `Player.tres` $\rightarrow$ `SwordsmanPreset.tscn`), `Visual.gd` bypasses the modular equipment layers entirely (`sprites[slot]` is ignored). The character currently renders with a single baked martial outfit and sword. Equipping armor or weapons in inventory changes character stats but produces **zero visual change** on the Swordsman.

### Discovery 2: Unreachable Animations in the Swordsman Frameset
In `assets/characters/swordsman/swordsman_frames.tres`, the artists created 7 full 8-directional action sets (56 animations, 512 frames):
1. `idle_` (8 directions) — **ACTIVE** (verified in `Visual.GetSwordsmanAction`).
2. `walk_` (8 directions) — **ACTIVE** (verified in `Visual.GetSwordsmanAction`).
3. `attack_` (8 directions) — **ACTIVE** (verified in `Visual.GetSwordsmanAction`).
4. `death_` (8 directions) — **ACTIVE** (verified in `Visual.GetSwordsmanAction`).
5. `hurt_` (8 directions) — **UNREACHABLE** (`ActorCommons.State` lacks a `HURT` state; damage events trigger floating text only).
6. `combo_` (8 directions) — **UNREACHABLE** (Combat uses single-attack loop; no combo state machine).
7. `qinggong_` (8 directions) — **UNREACHABLE** (`stat.isRunning` increases walk speed but `Visual.GetSwordsmanAction` returns `"walk"` regardless of run status).

### Discovery 3: Combat Authority & Timing Model
- Combat in SoM is entirely **server-authoritative** and **skill-driven**. Normal attacks are executed through `Skill.Cast(player, target, DB.SkillsDB[MeleeHash])`.
- There are **no animation event tracks (method tracks)** triggering hitboxes. Instead, hit timing is purely timer-based (`Callback.StartTimer` with `castTime + castAttackDelay`). Damage is applied instantly upon timer expiration, regardless of which sprite frame is currently rendering.
- This decoupling allows lag compensation and prevents client-side combat tampering, but causes slight visual desynchronization when attack animation length does not match `stat.current.castAttackDelay`.

---

## 4. IMMEDIATE PRODUCTION ROADMAP PRIORITIES

1. **Phase 1 (Pre-Combat Prototype Fixes):**
   - Connect `qinggong` animations to `stat.isRunning` inside `Visual.UpdateSwordsmanVisual()`.
   - Wire `combo` animations to successive attack clicks within the attack cooldown window.
   - Wire `hurt` animations into `interactive.DisplayAlteration()` or introduce a non-blocking flinch visual trigger.
2. **Phase 2 (Pre-Alpha Public Gate):**
   - Implement modular equipment rendering for 8-directional characters (either multi-layer 8-dir spritesheets or attachment socket pivots).
   - Re-skin the 15 base skills into Xianxia spiritual arts (e.g., `Flar` $\rightarrow$ Tam Muội Chân Hỏa, `ManaBurst` $\rightarrow$ Vạn Kiếm Quy Tông).
   - Implement visual sword trails and Daoist talisman/seal casting effects.
3. **Phase 3 (Long-Term Scalability):**
   - Establish shared 8-directional animation infrastructure for humanoid Cultivators and NPCs.
   - Develop boss phase transition animations and telegraph attack indicators.

---

## 5. AUDIT SUITE NAVIGATION

All detailed domain audits are available in the [`docs/phase-4-2-2-character-animation-audit/`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/) directory:

- [Character Inventory](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/CHARACTER_INVENTORY.md)
- [Animation Inventory](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/ANIMATION_INVENTORY.md)
- [Animation State Machine Audit](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/ANIMATION_STATE_MACHINE_AUDIT.md)
- [Combat System Audit](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/COMBAT_SYSTEM_AUDIT.md)
- [Skill System Audit](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/SKILL_SYSTEM_AUDIT.md)
- [VFX & SFX Audit](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/VFX_SFX_AUDIT.md)
- [Weapon & Equipment Visual Audit](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/WEAPON_EQUIPMENT_VISUAL_AUDIT.md)
- [Multiplayer Animation Audit](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/MULTIPLAYER_ANIMATION_AUDIT.md)
- [Visual Quality & Artistic Compatibility Audit](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/VISUAL_QUALITY_AUDIT.md)
- [Technical Architecture Assessment](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/TECHNICAL_ARCHITECTURE_ASSESSMENT.md)
- [Asset Reuse & Production Gap Analysis](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/ASSET_REUSE_AND_GAP_ANALYSIS.md)
- [Production Roadmap](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/TDNM_CHARACTER_ANIMATION_PRODUCTION_ROADMAP.md)
- [Visual Evidence Index](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/PHASE_4_2_2_EVIDENCE_INDEX.md)
- [Comprehensive Final Audit Report](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/PHASE_4_2_2_FINAL_AUDIT_REPORT.md)
- [Phase 4.2.3 Reconciliation & Evidence Validation Report](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/PHASE_4_2_3_RECONCILIATION_REPORT.md)
- [Phase 4.2.3.1 Final Evidence Sanity Check](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/phase-4-2-2-character-animation-audit/PHASE_4_2_3_1_FINAL_EVIDENCE_SANITY_CHECK.md)
- [Documentation Cleanup Report](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/docs/DOCUMENTATION_CLEANUP_REPORT.md)
