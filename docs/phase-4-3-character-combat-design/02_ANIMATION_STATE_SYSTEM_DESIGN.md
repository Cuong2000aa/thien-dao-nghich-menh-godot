# WORKSTREAM B — ANIMATION STATE MACHINE & ACTION DISPATCH ARCHITECTURE
**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Phase:** 4.3 — Character & Combat Architecture Design  
**Type:** Technical Architecture Investigation & System Design  
**Status:** ARCHITECTURAL PROPOSAL (`[PROPOSED]`) — SUBJECT TO OWNER REVIEW  

---

## 1. INVESTIGATION CONTEXT & CURRENT ARCHITECTURAL BASELINE

In Source of Mana, character behavior is driven by a rigid table-driven state machine declared in [`sources/actor/ActorCommons.gd:120-154`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/actor/ActorCommons.gd#L120-L154):
- Enum: `UNKNOWN = -1, IDLE = 0, WALK = 1, SIT = 2, ATTACK = 3, DEATH = 4, TO_TRIGGER = 5, TRIGGER = 6, FROM_TRIGGER = 7, COUNT = 8`.
- Transition Matrix: $8 \times 8$ `STATE_TRANSITIONS` (64 bytes).
- Execution: [`BaseAgent.gd:61-69`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/actor/agent/BaseAgent.gd#L61-L69) indexes the matrix via `stateIdx = state * COUNT + wantedState`.

### The Core Architectural Dilemma:
As discovered in Phase 4.2.2, **288 out of 512 animation frames** in the Swordsman asset suite (`hurt`, `combo`, `qinggong`) are currently unreachable. 
The naive instinct would be to simply add `HURT`, `QINGGONG`, `CASTING`, and `MEDITATE` to `ActorCommons.State`. However, expanding the global state enum causes an **exponential matrix explosion** (from $8 \times 8 = 64$ to $14 \times 14 = 196$ transitions), risks breaking server physics loops, and introduces RPC packet overhead.

This workstream establishes an architectural taxonomy dividing character actions into four distinct operational layers.

---

## 2. FOUR-TIER ACTION DISPATCH TAXONOMY

Rather than forcing every animation into the server state machine, TDNM defines four decoupled tiers:

```
┌────────────────────────────────────────────────────────────────────────┐
│ TIER 1: AUTHORITATIVE GLOBAL ACTOR STATES (Server Logic + Network Sync)│
│ Manages movement authority, collision, server timers, dead-reckoning.  │
│ States: IDLE, WALK, ATTACK, DEATH, SIT, TRIGGER.                       │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ RPC: FullUpdateEntity (agentState)
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│ TIER 2: SKILL PRESENTATION STATES (Skill-Driven Presentation)          │
│ Driven by skillCastID. Client plays distinct casting/channeling loops  │
│ without mutating server actor state.                                   │
│ Actions: Sword Qi Channeling, Talisman Burning, Spell Seal Invocation. │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ RPC: TargetAlteration / Casted
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│ TIER 3: CLIENT ANIMATION-ONLY ACTIONS (Sub-State Modifiers)            │
│ Local visual presentation driven by client movement speed or combo     │
│ input windows. Server maintains base WALK or ATTACK state.             │
│ Actions: Qinggong Sprint, Chained Sword Combos, Meditation Pose.       │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ Client Visual Hook
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│ TIER 4: TEMPORARY VISUAL OVERLAYS & IMPACT REACTIONS                   │
│ Completely non-blocking visual feedback. Plays on secondary layers     │
│ or shaders without interrupting locomotion or combat timers.           │
│ Actions: Hit Stagger / Flinch (Hurt), Qi Shield Ripples, Ghost Trails. │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. COMPREHENSIVE ACTION SPECIFICATION & TRADE-OFF ANALYSIS

### 3.1 Core Locomotion Actions

#### 1. Idle (`idle_*`, 8 Dirs, 32 Frames)
- **Why Required:** Baseline resting stance when velocity is zero.
- **Classification:** **Tier 1 — Authoritative Global State (`ActorCommons.State.IDLE`).**
- **Trigger Event:** `velocity.is_zero_approx()` on server; default state upon actor creation.
- **Authority & Sync:** Server broadcasts via `UpdateEntity` / `FullUpdateEntity`. Client plays `idle_<dir>`.

#### 2. Walk (`walk_*`, 8 Dirs, 48 Frames)
- **Why Required:** Standard navigation across isometric terrain.
- **Classification:** **Tier 1 — Authoritative Global State (`ActorCommons.State.WALK`).**
- **Trigger Event:** Player input vector or AI pathfinding destination.
- **Authority & Sync:** Server validates safe velocity against navigation mesh; broadcasts velocity vector.

#### 3. Qinggong Sprint (`qinggong_*`, 8 Dirs, 112 Frames)
- **Why Required:** High-speed cultivation traversal with fluttering robes and wind effects.
- **Classification:** **Tier 3 — Client Animation-Only Action.**
- **Architectural Rationale:**
  - *Why NOT a global state?* If `QINGGONG` is a separate server state, the server must duplicate all navigation, avoidance, obstacle collision, and warp logic between `WALK` and `QINGGONG`.
  - *Optimal Implementation:* Server maintains `state = WALK` but sets boolean flag `stat.isRunning = true`.
  - When `stat.isRunning == true`, `Visual.GetSwordsmanAction()` returns `"qinggong"` instead of `"walk"`.
  - Client spawns ghost trail particle overlays (`CPUParticles2D` trailing behind the sprite).
- **Result:** Activates all **112 dormant qinggong frames** with **zero server state machine modifications**.

---

### 3.2 Martial Combat Actions

#### 4. Normal Attack (`attack_*`, 8 Dirs, 80 Frames)
- **Why Required:** Primary martial sword strike or basic melee execution.
- **Classification:** **Tier 1 — Authoritative Global State (`ActorCommons.State.ATTACK`).**
- **Trigger Event:** `Skill.Cast(agent, target, MeleeSkill)`.
- **Authority & Sync:** Server enters `ATTACK`, halts locomotion, locks orientation toward target, and starts `actionTimer`.

#### 5. Multi-Hit Combo (`combo_*`, 8 Dirs, 128 Frames)
- **Why Required:** Fluid wuxia swordplay where consecutive clicks unleash chained slashes rather than repetitive single swings.
- **Classification:** **Tier 3 — Client Animation-Only Sub-Action (Chained Input Window).**
- **Architectural Rationale:**
  - *Why NOT a global state?* Adding `COMBO_1`, `COMBO_2`, `COMBO_3` to `ActorCommons.State` increases transition matrix complexity dramatically.
  - *Optimal Implementation:* Server handles cooldown via `actionTimer`. Client tracks a local `comboIndex` (0 $\rightarrow$ 1 $\rightarrow$ 2) within an active combo window ($\le 0.6$ seconds after previous attack).
  - Strike 1 plays `attack_<dir>` (Frames 0–9).
  - Strike 2 within window plays `combo_<dir>` first half (Frames 0–7).
  - Strike 3 within window plays `combo_<dir>` second half (Frames 8–15).
- **Result:** Activates all **128 dormant combo frames** while preserving strict server damage timing.

#### 6. Hit Reaction / Flinch (`hurt_*`, 8 Dirs, 48 Frames)
- **Why Required:** Impact readability when an actor receives damage.
- **Classification:** **Tier 4 — Temporary Visual Overlay / Non-Blocking Visual Reaction.**
- **Architectural Rationale:**
  - *Why NOT a global state?* If `HURT` is an authoritative state, receiving damage in an MMORPG with multiple attackers causes **stunlock (hit-lock)**, halting movement and freezing the player in place.
  - *Optimal Implementation:* When client receives `TargetAlteration(damage, HIT)` via RPC:
    1. If the character is in `IDLE`, play `hurt_<dir>` once.
    2. If the character is in `WALK` or `ATTACK`, **do not interrupt movement**. Instead, trigger a 0.1-second chromatic flash shader (red flash) + blood/qi spark particle burst + floating combat text.
- **Result:** Solves the missing hit reaction without destabilizing server movement or introducing frustrating gameplay stunlocks.

#### 7. Death (`death_*`, 8 Dirs, 64 Frames)
- **Why Required:** Actor defeat and collapse.
- **Classification:** **Tier 1 — Authoritative Global State (`ActorCommons.State.DEATH`).**
- **Trigger Event:** `stat.health <= 0`.
- **Authority & Sync:** Terminal absorbing state. Server halts physics, disconnects navigation, and broadcasts `DEATH`. Client plays `death_<dir>` and halts on frame 7.

---

### 3.3 Cultivation & Ability Actions

#### 8. Skill Casting & Hand Seals (Kiếm Chỉ, Kết Ấn)
- **Why Required:** Cultivators channeling spiritual energy before unleashing spells.
- **Classification:** **Tier 2 — Skill Presentation State.**
- **Trigger Event:** Server initiates `Skill.Cast()` with `skill.castTime > 0`.
- **Authority & Sync:** Server transmits `skillCastID` via `FullUpdateEntity`.
- **Client Presentation:** `Visual.gd` checks `skillCastID`. If `castTime > 0`, avatar adopts the two-finger sword seal pose (`Kiếm Chỉ`), while floor magic circles (`casts/*.tscn`) rotate beneath the character.

#### 9. Meditation & Cultivation Pose (Vận Công / Tĩnh Tọa)
- **Why Required:** Passive spiritual energy refinement (D-01/D-04 progression), HP/MP recovery, breakthrough ceremonies.
- **Classification:** **Tier 1 — Authoritative Global State (`ActorCommons.State.SIT`).**
- **Architectural Rationale:**
  - Source of Mana already possesses an authoritative `SIT` state in `ActorCommons.State.SIT` (`State 2`), complete with valid transitions (`IDLE <-> SIT`, `SIT -> WALK`, `SIT -> DEATH`).
  - Currently, `SIT` increases health and stamina regeneration via `ActorCommons.GetRecovery()` (`Recovery.GOOD = 2.0x`).
  - **Proposed Visual Re-skin:** Map `State.SIT` on the Swordsman to a five-heart-towards-sky (Ngũ Tâm Triều Thiên) cross-legged meditation sprite.
  - Client spawns a subtle spiraling spiritual energy particle effect (`SpiritualQiAura`).
- **Result:** Integrates classical cultivation meditation into existing engine architecture with **zero new state declarations**.

---

## 4. ACTION CLASSIFICATION & DISPATCH SUMMARY MATRIX

| Action Name | Handcrafted Frames | Target Action Tier | Server State Mutation | Client Presentation Method | Network Replication |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **`idle_*`** | 32 frames | **Tier 1** (Global State) | `State.IDLE` | `animatedSprite.play("idle_" + dir)` | `UpdateEntity` / `FullUpdateEntity` |
| **`walk_*`** | 48 frames | **Tier 1** (Global State) | `State.WALK` | `animatedSprite.play("walk_" + dir)` | `UpdateEntity` (Velocity vector) |
| **`qinggong_*`** | 112 frames | **Tier 3** (Sub-Action) | None (`stat.isRunning`) | `animatedSprite.play("qinggong_" + dir)` | Replicates `isRunning` bool in RPC |
| **`attack_*`** | 80 frames | **Tier 1** (Global State) | `State.ATTACK` | `animatedSprite.play("attack_" + dir)` | `FullUpdateEntity` (`ATTACK`) |
| **`combo_*`** | 128 frames | **Tier 3** (Sub-Action) | None (Chained clicks) | `animatedSprite.play("combo_" + dir)` | Client-side input window check |
| **`hurt_*`** | 48 frames | **Tier 4** (Visual Overlay)| None (Non-blocking) | Shader flash + idle stagger playback | Triggered by `TargetAlteration` RPC |
| **`death_*`** | 64 frames | **Tier 1** (Global State) | `State.DEATH` | `animatedSprite.play("death_" + dir)` | `FullUpdateEntity` (`DEATH`) |
| **`meditate`** | 8 frames (New) | **Tier 1** (Global State) | `State.SIT` (Existing) | Cross-legged sitting pose + Qi aura | Existing `SIT` state transitions |
| **`casting`** | 8 frames (New) | **Tier 2** (Skill State) | None (`skillCastID`) | Two-finger sword seal pose | Replicates `skillCastID` in RPC |

---

## 5. SUMMARY RECOMMENDATION FOR OWNER DECISION

1. **Keep `ActorCommons.State` Lean:** Retain the authoritative 8-state transition matrix without bloating it with transient animations.
2. **Re-skin Existing `SIT` as Cultivation Meditation:** Immediately unlocks authentic cultivation breathing and spiritual recovery.
3. **Dispatch `qinggong` and `combo` as Client Sub-Actions:** Activates 240 handcrafted frames without risking server physics or desync.
4. **Treat `hurt` as Non-Blocking Visual Impact:** Protects gameplay fluidity from frustrating hit-stunlocks while preserving visual combat punchiness.

---

*Authored by Senior Godot Engineer & Systems Architect — Thiên Đạo Nghịch Mệnh Phase 4.3.*
