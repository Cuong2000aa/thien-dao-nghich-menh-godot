# PHASE 4.3 — OWNER DECISION PACKAGE
## Character & Combat Architecture Design Decisions

**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Phase:** 4.3 — Character & Combat Architecture Design  
**Document Type:** Formal Decision Package for Project Owner Approval  
**Date:** November 2026  
**Status:** PENDING OWNER DECISION  

---

## EXECUTIVE INTRODUCTION

This Decision Package presents **6 Critical Architectural Decision Points (DP-01 through DP-06)** formulated during Phase 4.3. Each decision point outlines the viable options, evaluates their trade-offs, provides quantitative scoring, and submits an authoritative engineering recommendation.

Following project governance, **the AI Assistant does NOT make authoritative choices for the project owner.** The Owner must select and approve an option for each Decision Point before implementation in Phase 5 begins.

---

## SUMMARY OF DECISION POINTS

| Decision ID | Topic | Options | Recommended Option |
| :--- | :--- | :--- | :--- |
| **DP-01** | **Character Rendering Architecture** | Option A (Classic SoM 4-dir)<br/>Option B (Monolithic 8-dir)<br/>Option C1 (Multi-layer 8-dir)<br/>Option C3 (Shader Robe + Sockets) | **Option C3** (Shader-Tinted Robes + Dynamic Sockets) |
| **DP-02** | **Animation State System Architecture** | Option 1 (Server State Bloat - 15+ states)<br/>Option 2 (4-Tier Action Dispatch) | **Option 2** (4-Tier Action Dispatch Framework) |
| **DP-03** | **Combat Engine & Hit Resolution** | Model A (Radial Point Distance)<br/>Model B (Directional Geometry Math)<br/>Model C (Server Physics Hitboxes)<br/>Model D (Hybrid Directional + Impact Apex) | **Model D** (Directional Geometry + Impact Apex Sync) |
| **DP-04** | **Equipment & Customization Pipeline** | Option 1 (Full 12-Slot Visual Paperdoll)<br/>Option 2 (3-Tier Visual Pipeline: Robe + Socket + Orbit) | **Option 2** (3-Tier Visual Representation) |
| **DP-05** | **Xianxia Skill & Elemental System** | Option 1 (Rigid Single-Class Skill Trees)<br/>Option 2 (Open Five-Element Matrix per D-01) | **Option 2** (Open Five-Element Wheel per D-01) |
| **DP-06** | **Multiplayer Combat Timing & Sync** | Option 1 (Full Server Physics Rewind)<br/>Option 2 (Client Prediction + Forward Tolerance Window) | **Option 2** (Client Prediction + Forward Tolerance Window) |

---

## DP-01: CHARACTER RENDERING ARCHITECTURE

### Context
Phase 4.2.2 uncovered the monolithic 512-frame `swordsman_frames.tres` (8 directions, 7 action types). We must determine how player characters, equipment, and future classes are rendered.

### Options:
- **Option A — Classic SoM 4-Direction Paperdoll:** Retain the baseline 4-direction layered rendering. Discard or severely downscale the 512-frame Swordsman.
  - *Pros:* Fully compatible with all existing SoM armor/weapon sprites. Zero art rework.
  - *Cons:* Visual regression. Discards the high-quality 8-direction Swordsman asset. Attacks look flat and dated.
- **Option B — Monolithic 8-Direction SpriteFrames:** Adopt the 512-frame Swordsman as the sole visual standard. All gear must be pre-rendered into the base spritesheet.
  - *Pros:* Maximum visual fluidity and character detail.
  - *Cons:* Complete loss of modular equipment customization. Every new armor set requires drawing 512 individual frames.
- **Option C1 — Multi-Layer 8-Direction Paperdoll:** Split the 512-frame Swordsman into modular layers (Body, Hair, Chest, Legs, Weapon, Shield) across all 8 directions.
  - *Pros:* Complete modularity in 8 directions.
  - *Cons:* **Combinatorial Art Explosion.** 10 robes $\times$ 5 weapons requires 25,600+ hand-drawn pixel frames. Unrealistic budget/time requirement.
- **Option C3 — Shader-Tinted Unified Robes + Dynamic Sockets (RECOMMENDED):**
  - Base body rendered via monolithic 8-direction animations.
  - Robes/armors share a unified geometry per realm tier, colored dynamically via GPU Palette-Swap Shaders (Gold, Jade, Azure, Crimson, Obsidian).
  - Weapons are rendered as independent 2D sprites dynamically attached to hand `Marker2D` sockets, with flying swords managed by procedural orbiting nodes (`PhiKiemNode2D`).
  - *Pros:* Retains 8-direction visual fidelity, solves the art explosion ($O(N)$ instead of $O(N \times M)$), enables vibrant Xianxia aesthetics (glowing swords, realm robes).
  - *Cons:* Requires authoring the weapon socket position table for the 56 Swordsman animations.

### Recommendation: **Option C3**

---

## DP-02: ANIMATION STATE SYSTEM ARCHITECTURE

### Context
Swordsman has 7 animation types (Idle, Walk, Attack, Combo, Qinggong, Hurt, Death). The server state machine (`ActorCommons.State`) has only 8 states. Should we add new server states for Qinggong, Combo, and Hurt?

### Options:
- **Option 1 — Server State Bloat:** Add `State.QINGGONG`, `State.COMBO`, `State.HURT`, `State.MEDITATE`, `State.CASTING` directly to `ActorCommons.State`.
  - *Pros:* Server tracks exact player pose.
  - *Cons:* Bloats network packet size; introduces high risk of desync; hurt state causes unfair stunlock in multiplayer; alters upstream baseline protocols.
- **Option 2 — 4-Tier Action Dispatch Framework (RECOMMENDED):**
  - **Tier 1 (Global Server States):** Keep `ActorCommons.State` strictly at 8 states (`IDLE`, `WALK`, `SIT`, `ATTACK`, `DEATH`, etc.).
  - **Tier 2 (Skill States):** Channeling/Casting driven by existing `skillCastID`.
  - **Tier 3 (Client Presentation Sub-Actions):**
    - `Qinggong` runs under `State.WALK` when `stat.isRunning = true` (activating 112 dormant frames).
    - `Combo` runs under `State.ATTACK` via client chained input buffer (activating 128 dormant frames).
    - `Meditate` maps directly to existing `State.SIT` (`State 2`), doubling HP/MP regen.
  - **Tier 4 (Visual Overlays):** `HURT` handled as a non-blocking shader flash and particle burst; does not interrupt player control.
  - *Pros:* 100% backward compatible with server; zero network bloat; eliminates stunlock; activates all 512 Swordsman frames.
  - *Cons:* Requires client-side animation controller script (`VisualAnimatedSprite2D.gd`).

### Recommendation: **Option 2**

---

## DP-03: COMBAT ENGINE & HIT RESOLUTION

### Context
Source of Mana evaluates melee and spell hits using a Euclidean point distance check (`IsNear`). This allows hitting enemies behind the character and ignores blade trajectory.

### Options:
- **Model A — Radial Distance (Current Baseline):** Retain simple point-to-point Euclidean distance check.
  - *Pros:* Simplest CPU cost.
  - *Cons:* Player can hit enemies standing behind them; attacks feel floaty and unnatural.
- **Model B — Pure Directional Geometry Math:** Server calculates whether the target lies inside a directional cone arc ($\vec{u} \cdot \vec{v} \ge \cos \theta$) or linear ray.
  - *Pros:* Accurate facing requirement; zero physics overhead; server-authoritative.
  - *Cons:* Instantaneous check does not synchronize with the visual blade swing apex.
- **Model C — Server-Side Godot Physics Hitboxes (`Area2D`):** Spawn Godot collision shapes on headless server during attacks.
  - *Pros:* Automatic collision callbacks.
  - *Cons:* High CPU overhead on headless server; risk of collision tunneling; severe performance degradation with 100+ entities.
- **Model D — Hybrid Directional Geometry + Impact Apex Sync (RECOMMENDED):**
  - Combines Model B's pure mathematical vector evaluation with **Impact Apex Frame Timing** ($\tau_{\text{hit}} = 416\text{ ms}$).
  - Server delays hit resolution by `castAttackDelay` so damage occurs exactly when the blade reaches maximum extension.
  - Directional Cones for melee slashes, Linear Rays for flying sword thrusts, Circles for area bursts.
  - *Pros:* Visually and mechanically frame-accurate; 100% server authoritative; zero physics CPU overhead.
  - *Cons:* Requires calibrating `castAttackDelay` in `SkillCell.gd` to match animation frames.

### Recommendation: **Model D**

---

## DP-04: EQUIPMENT & CUSTOMIZATION PIPELINE

### Context
Source of Mana has 12 equipment slots originally tailored for Western fantasy (Helmet, Armor, Boots, Weapon, Shield, Cape, Ring, Amulet, etc.).

### Options:
- **Option 1 — 12-Slot Hand-Drawn Paperdoll:** Every slot must have unique visual sprites in 8 directions.
  - *Pros:* Maximum visual variety per individual item.
  - *Cons:* Unattainable art budget; extreme performance cost with VRAM; impossible for small indie team.
- **Option 2 — 3-Tier Xianxia Visual Pipeline (RECOMMENDED):**
  - All 12 slots provide full gameplay stats and attributes in the inventory.
  - Visually represented through 3 elegant tiers:
    1. *Unified Realm Robe:* Base silhouette with realm-tier trims and GPU palette shader.
    2. *Socketed Primary Weapon:* Rendered at `Marker2D` hand socket.
    3. *Orbiting Spirit Artifacts:* Flying sword (`Phi Kiem`), defensive talisman, or alchemy cauldron floating procedurally around character.
  - *Pros:* Captures authentic Xianxia flavor; affordable art scope; zero VRAM bloat.
  - *Cons:* Non-robe equipment (e.g., rings, boots, belts) do not alter the character's base sprite.

### Recommendation: **Option 2**

---

## DP-05: XIANXIA SKILL & ELEMENTAL PROGRESSION

### Context
Must align skill architecture with Owner Decision **D-01 (Ngũ Hành Tạp Căn)** and **D-04 (Hybrid Progression)**.

### Options:
- **Option 1 — Traditional Western Class Trees:** Lock skills behind rigid classes (Warrior, Mage, Rogue).
  - *Pros:* Standard RPG trope.
  - *Cons:* Violates Owner Decision D-01 (Protagonist has all 5 elemental roots); destroys Xianxia thematic depth.
- **Option 2 — Open Five-Element Matrix per D-01 (RECOMMENDED):**
  - Skill taxonomy spans 5 traditions: Thể Tu (Body), Ngự Kiếm (Flying Sword), Ngũ Hành (Elemental Spells), Phù Lục (Talismans), Trận Pháp (Formations).
  - Incorporates the full Tương Sinh (Mutual Generation) and Tương Khắc (Mutual Overcoming) damage matrix ($+30\% / -25\%$).
  - Protagonist can learn all 5 elements, but must invest more cultivation resources to balance them.
  - Skills strictly locked behind D-04 Cultivation Realms (Phàm Thân $\rightarrow$ Tụ Khí $\rightarrow$ Thông Mạch $\rightarrow$ Đạo Cơ).
  - *Pros:* Deep strategic combat; perfectly faithful to approved World Bible and Owner Decisions D-01 and D-04.
  - *Cons:* Requires careful balance tuning across the 5 elements.

### Recommendation: **Option 2**

---

## DP-06: MULTIPLAYER COMBAT SYNCHRONIZATION & LATENCY

### Context
Ensure fair, responsive multiplayer combat across both Desktop (ENet UDP) and Web Browser (WebSocket TCP) clients.

### Options:
- **Option 1 — Full Historical Physics Rewind (Rollback):** Server records 1-2 seconds of entity histories and rewinds world state upon each client attack.
  - *Pros:* Perfect precision in high-speed shooter games.
  - *Cons:* Massive server CPU load; causes jarring position "teleportation" for observing players; inappropriate for isometric MMORPGs.
- **Option 2 — Responsive Client Prediction + Forward Tolerance Window (RECOMMENDED):**
  - Client plays windup animation locally on hotkey press for instant responsiveness.
  - Server authoritatively validates state, cooldown, range, and resources.
  - Hit detection incorporates a dynamic tolerance window ($\Delta t \approx 100-150\text{ ms}$, $\text{margin} \le 64\text{ px}$) to prevent unfair misses due to network jitter.
  - Damage calculation delayed to Impact Apex Frame ($\tau_{\text{hit}} \approx 416\text{ ms}$) so damage pops on blade contact.
  - *Pros:* Silky smooth combat feel; fair to mobile/web players; zero server physics load; exploit-proof.
  - *Cons:* Client must handle occasional animation cancellations if the server rejects an invalid skill.

### Recommendation: **Option 2**

---

## OWNER SIGN-OFF SHEET (TEMPLATE)

To authorize Phase 5 implementation, the Project Owner may select the options below:

```
[ ] DP-01 Character Rendering:       [ ] Option A    [ ] Option B    [ ] Option C1   [X] Option C3 (Recommended)
[ ] DP-02 Animation State System:    [ ] Option 1    [X] Option 2 (Recommended)
[ ] DP-03 Combat Hit Resolution:     [ ] Model A     [ ] Model B     [ ] Model C     [X] Model D (Recommended)
[ ] DP-04 Equipment Pipeline:        [ ] Option 1    [X] Option 2 (Recommended)
[ ] DP-05 Xianxia Skill System:      [ ] Option 1    [X] Option 2 (Recommended)
[ ] DP-06 Multiplayer Timing:        [ ] Option 1    [X] Option 2 (Recommended)

Owner Signature: _______________________          Date: ______________
```
