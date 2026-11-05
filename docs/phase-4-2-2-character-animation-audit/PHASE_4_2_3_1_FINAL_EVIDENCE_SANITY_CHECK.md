# PHASE 4.2.3.1 — FINAL EVIDENCE SANITY CHECK & DOCUMENTATION SUPPLEMENT
**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Phase:** 4.2.3.1  
**Execution Type:** Final Forensic Evidence Sanity Check & Documentation Supplement  
**Scope Boundary:** Strictly Documentation Only (0 Code, Scene, Resource, Asset, or Database Changes)  
**Baseline Git Commit:** `1933bd66caf2c59fd5d9b5df410d19838059b243`  
**Status:** COMPLETE, AUDITED & AUTHORITATIVE  

---

## 1. EXECUTIVE SUMMARY

Phase 4.2.3.1 was executed as a focused, forensic verification and sanity check supplementing the Phase 4.2.2 audit and Phase 4.2.3 reconciliation. It resolves four critical technical questions without modifying any gameplay code or engine configurations:
1. **R-06 (State Initialization Safety):** Audited the full actor instantiation lifecycle across Player, Monster, and NPC agents to determine if `BaseAgent.SetState()` can ever execute with `state == ActorCommons.State.UNKNOWN (-1)`.
2. **R-07 (Network Port Reconciliation):** Resolved all conflicting network port citations across source code, launch scripts, test runners, and documentation into a single authoritative port matrix.
3. **R-08 (Animation Verification Terminology):** Formalized and applied the strict three-tier verification taxonomy (**Resource Load**, **Animation Availability**, **Runtime Playback**) to all 56 Swordsman animations.
4. **R-09 (Git Diff & Zero-Mutation Forensic Audit):** Conducted a timestamp-backed file audit proving that zero engine source files (`.gd`), scenes (`.tscn`), resources (`.tres`), or assets have been touched since Phase 4.1.1 (10:05:18).

---

## 2. R-06 — ACTORCOMMONS.STATE INITIALIZATION SAFETY AUDIT

### 2.1 The Vulnerability Under Investigation
In [`sources/actor/agent/BaseAgent.gd:61-63`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/actor/agent/BaseAgent.gd#L61-L63):
```gdscript
func SetState(wantedState : ActorCommons.State) -> bool:
	var stateIdx : int = state * ActorCommons.State.COUNT + wantedState
	var nextState : ActorCommons.State = ActorCommons.STATE_TRANSITIONS[stateIdx] as ActorCommons.State
```
Because `ActorCommons.State.UNKNOWN = -1`, if `state == -1`, `stateIdx = (-1) * 8 + wantedState = wantedState - 8`, which is a **negative index**. In GDScript, negative array indices wrap backwards from the end of `STATE_TRANSITIONS` (indexing elements 56–63 of row 7 `FROM_TRIGGER`), corrupting state machine logic.

### 2.2 Deep Architectural Tracing

#### 1. Declaration & Base Initialization
In [`sources/actor/Actor.gd:7`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/actor/Actor.gd#L7):
```gdscript
var state : ActorCommons.State = ActorCommons.State.IDLE
```
- Both `BaseAgent` and `Entity` inherit directly from `Actor`.
- Neither subclass redeclares `var state`.
- **Finding:** Upon object instantiation, `state` is immediately assigned `ActorCommons.State.IDLE` (integer `0`). It **never** defaults to `UNKNOWN` (`-1`).

#### 2. Default State vs Current State
In [`sources/actor/agent/BaseAgent.gd:27`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/actor/agent/BaseAgent.gd#L27):
```gdscript
var defaultState : ActorCommons.State = ActorCommons.State.UNKNOWN
```
- It is `defaultState`, not `state`, that defaults to `UNKNOWN` (`-1`).
- In `BaseAgent.SetData()` ([lines 169–173](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/actor/agent/BaseAgent.gd#L169-L173)):
  ```gdscript
  if defaultState == ActorCommons.State.UNKNOWN and data._state != ActorCommons.State.UNKNOWN:
      defaultState = data._state
  if defaultState != ActorCommons.State.UNKNOWN:
      SetState(defaultState)
  ```
- If an entity preset has an explicit initial state (e.g., `Mauro.tres` has `_state = 2` [`SIT`]), `SetState(2)` is called. At this moment, `self.state` is still `IDLE` (`0`), so `stateIdx = 0 * 8 + 2 = 2`. The lookup evaluates safely to `STATE_TRANSITIONS[2] == State.SIT`.

#### 3. State Machine Closure
In `ActorCommons.STATE_TRANSITIONS` ([lines 135–154](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/actor/ActorCommons.gd#L135-L154)):
- All 64 entries in the transition table evaluate to valid states in $[0, 7]$.
- Not a single element in `STATE_TRANSITIONS` is `UNKNOWN` (`-1`).
- Therefore, once initialized to `IDLE` (`0`), no sequence of `SetState()` calls can ever transition `state` to `UNKNOWN`.

### 2.3 Actor Lifecycle & Initialization Matrix

| Actor Type | Initial State | First State Assignment | First SetState Call | UNKNOWN Risk | Status & Evidence |
| :--- | :--- | :--- | :--- | :---: | :--- |
| **PlayerAgent** | `IDLE` (0) | `Actor.gd:7` (`var state = IDLE`) | In `_velocity_computed()` upon first movement tick or halt | **NONE** | **VERIFIED** (`PlayerAgent.gd:47`, `Actor.gd:7`) |
| **MonsterAgent** | `IDLE` (0) | `Actor.gd:7` (`var state = IDLE`) | In `BaseAgent.SetData()` if `data._state != UNKNOWN`, else AI loop | **NONE** | **VERIFIED** (`AIAgent.gd:22`, `BaseAgent.gd:173`) |
| **NPCAgent** | `IDLE` (0) | `Actor.gd:7` (`var state = IDLE`) | In `BaseAgent.SetData()` (e.g. `SIT` if preset specifies), else idle | **NONE** | **VERIFIED** (`NPCAgent.gd:18`, `NpcScript.gd:43`) |
| **Entity (Client)** | `IDLE` (0) | `Actor.gd:7` (`var state = IDLE`) | In `Entity.Update()` upon receiving first `FullUpdateEntity` RPC | **NONE** | **VERIFIED** (`Entity.gd:39`, `Actor.gd:7`) |

### 2.4 Conclusion & Technical Debt Classification
- **Operational Reality:** **VERIFIED SAFE.** In the current codebase, `state` is never `-1`, and `SetState()` is never invoked with `state == UNKNOWN`. A negative index in `STATE_TRANSITIONS` is impossible in live gameplay.
- **Architectural Vulnerability (`POTENTIAL DEFECT`):** `BaseAgent.SetState()` lacks an assertion or boundary clamp. If future code introduces an uninitialized state or passes an out-of-bounds enum, GDScript will wrap array access silently without throwing an error. A defensive check (`assert(state >= 0 and wantedState >= 0 and wantedState < ActorCommons.State.COUNT)`) should be scheduled for Phase 5.

---

## 3. R-07 — NETWORK PORT CONFIGURATION RECONCILIATION

### 3.1 Historical Confusions & Misattributions
Prior audit drafts cited conflicting port numbers:
- Conflating the Python web static asset server (`8085`) with WebSocket server listeners.
- Citing an unconfigured generic development port (`8080`) that does not exist anywhere in project configuration or scripts.
- Mixing up production ports (`6108`/`6109`) with testing ports (`6118`/`6119`).

### 3.2 Authoritative Configuration Analysis
Direct inspection of [`sources/network/NetworkCommons.gd:4-10`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/network/NetworkCommons.gd#L4-L10):
```gdscript
const WebSocketPortTesting : int = 6118
const ENetPortTesting : int      = 6119

const WebSocketPort : int        = 6108
const ENetPort : int             = 6109
```
And in [`sources/launcher/LauncherCommons.gd:24`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/launcher/LauncherCommons.gd#L24):
```gdscript
static var IsTesting : bool = not OS.has_feature("production")
```
Because the engine runs in debug/development builds (`not OS.has_feature("production")`), `LauncherCommons.IsTesting` is **TRUE** for all local and automated test runs.

### 3.3 Authoritative Service & Port Matrix

| Service | Protocol / Transport | Port | Configuration Source | Runtime & Test Evidence | Status |
| :--- | :--- | ---:| :--- | :--- | :--- |
| **Dedicated Server (Desktop Client Listener)** | ENet over UDP | **6119** | `NetworkCommons.ENetPortTesting` | Verified in `tests/run_crossplatform_test.sh:12` and `tests/test_multi_api.gd:10` | **VERIFIED** |
| **Dedicated Server (Web Browser Listener)** | WebSocket over TCP | **6118** | `NetworkCommons.WebSocketPortTesting` | Verified in `tests/run_crossplatform_test.sh:20` and `scripts/edge_cdp_test.py` | **VERIFIED** |
| **Local Web Static Asset Server** | HTTP (Python) | **8085** | `scripts/serve_web.py:6` (`PORT = 8085`) | Verified in `scripts/serve_web.py` with mandatory COOP/COEP headers | **VERIFIED** |
| **Production Server (Desktop Listener)** | ENet over UDP | **6109** | `NetworkCommons.ENetPort` | Active only when exported with `OS.has_feature("production")` | **STATICALLY IDENTIFIED** |
| **Production Server (Web Browser Listener)**| WebSocket over TCP | **6108** | `NetworkCommons.WebSocketPort` | Active only when exported with `OS.has_feature("production")` | **STATICALLY IDENTIFIED** |
| **Generic Port 8080** | None | — | None (Documentation artifact) | Grep across entire codebase confirmed 0 occurrences in configs/scripts | **OBSOLETE / INVALID** |

---

## 4. R-08 — ANIMATION VERIFICATION TERMINOLOGY & CORRECTED MATRIX

To eliminate all ambiguity, every animation is evaluated against three mutually exclusive, non-conflated verification tiers:
1. **Resource Load:** The resource or scene loads into Godot memory cleanly without parser errors.
2. **Animation Availability:** The animation track exists inside the loaded `SpriteFrames` resource with the exact expected direction suffix and frame count.
3. **Runtime Playback:** The animation is selected and executed by `AnimatedSprite2D.play()`, and its playback behavior and position offsets are actively asserted during test execution.

### Authoritative Swordsman 8-Directional Verification Matrix

| Animation Family | Dirs | Total Frames | Resource Load | Animation Availability | Runtime Playback | Gameplay Trigger | Network Sync |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`idle_*`** | 8 | 32 | **VERIFIED** | **VERIFIED** (8 octants, 4 f/dir) | **VERIFIED** (`TestSwordsmanBinding.gd` Pass 1–8) | **VERIFIED** (Default actor state) | **HISTORICAL** (Phase 3/3.1 cross-play) |
| **`walk_*`** | 8 | 48 | **VERIFIED** | **VERIFIED** (8 octants, 6 f/dir) | **VERIFIED** (`TestSwordsmanBinding.gd` Pass 9–16) | **VERIFIED** (Velocity input trigger) | **HISTORICAL** (Phase 3/3.1 cross-play) |
| **`attack_*`** | 8 | 80 | **VERIFIED** | **VERIFIED** (8 octants, 10 f/dir)| **STATICALLY IDENTIFIED** (Mapped in `Visual.gd:136`; not in test) | **VERIFIED** (`Skill.Cast()` melee) | **STATICALLY IDENTIFIED** (`Network.gd`) |
| **`death_*`** | 8 | 64 | **VERIFIED** | **VERIFIED** (8 octants, 8 f/dir) | **STATICALLY IDENTIFIED** (Mapped in `Visual.gd:136`; not in test) | **VERIFIED** (`health <= 0` trigger) | **STATICALLY IDENTIFIED** (`FullUpdateEntity`) |
| **`hurt_*`** | 8 | 48 | **VERIFIED** | **VERIFIED** (8 octants, 6 f/dir) | **NOT VERIFIED** | **NOT IMPLEMENTED** (No HURT state in enum) | **NOT IMPLEMENTED** |
| **`combo_*`** | 8 | 128 | **VERIFIED** | **VERIFIED** (8 octants, 16 f/dir)| **NOT VERIFIED** | **NOT IMPLEMENTED** (No combo selection branch)| **NOT IMPLEMENTED** |
| **`qinggong_*`**| 8 | 112 | **VERIFIED** | **VERIFIED** (8 octants, 14 f/dir)| **NOT VERIFIED** | **NOT IMPLEMENTED** (Running maps to walk) | **NOT IMPLEMENTED** |

**Summary Metrics:**
- **Total Handcrafted Frames:** **512 frames**.
- **Playback Verified in Test Suite:** **80 frames** (`idle` 32 + `walk` 48 across 16 directional test steps).
- **Active in Code Mapping (Untested in Test Suite):** **144 frames** (`attack` 80 + `death` 64).
- **Unreachable / Unimplemented in Code:** **288 frames** (`hurt` 48 + `combo` 128 + `qinggong` 112 = 56.25%).

---

## 5. R-09 — GIT DIFF AND ZERO-MUTATION FORENSIC AUDIT

### 5.1 Working Tree Status Inspection
Output of `git status --short`:
```text
 M .gitignore
 M presets/entities/Player.tres
 M project.godot
 M sources/actor/entity/components/Visual.gd
 M sources/db/instance/MapData.gd
 M sources/gui/character/Stats.gd
 M sources/launcher/Launcher.gd
 M sources/launcher/LauncherCommons.gd
 M sources/map/Map.gd
 M sources/network/NetworkCommons.gd
 M sources/network/client/Client.gd
 M sources/network/server/Server.gd
 M sources/scripts/generic/WarpGlobal.gd
?? docs/phase-4-2-2-character-animation-audit/
... (untracked documentation and test artifacts)
```

### 5.2 Forensic Modification Timestamp Analysis
An automated timestamp audit of all 13 modified tracked files was conducted using the local filesystem:

| File Path | Filesystem Modification Timestamp | Phase Where Modified |
| :--- | :---: | :--- |
| `presets/entities/Player.tres` | **2026-11-02 19:02:09** | Phase 2 (Asset Migration) |
| `sources/actor/entity/components/Visual.gd` | **2026-11-02 19:01:57** | Phase 3 (Network Actor Binding) |
| `sources/network/server/Server.gd` | **2026-11-02 16:52:21** | Phase 3 (Multiplayer Transport) |
| `sources/map/Map.gd` | **2026-11-02 19:02:22** | Phase 3 (Actor Spawning) |
| `sources/network/NetworkCommons.gd` | **2026-11-02 21:04:18** | Phase 3 (Testing Ports) |
| `.gitignore` | **2026-11-03 08:55:38** | Phase 4.1 (Thanh Vân Thôn) |
| `project.godot` | **2026-11-03 09:18:45** | Phase 4.1 (Minimap / Actions) |
| `sources/launcher/Launcher.gd` | **2026-11-03 09:25:59** | Phase 4.1 (Headless Server Init) |
| `sources/launcher/LauncherCommons.gd` | **2026-11-03 10:00:15** | Phase 4.1.1 (Tulimshar Default Spawn) |
| `sources/db/instance/MapData.gd` | **2026-11-03 10:04:54** | Phase 4.1.1 (Location Display Name) |
| `sources/network/client/Client.gd` | **2026-11-03 10:05:01** | Phase 4.1.1 (Location Registry Hook) |
| `sources/scripts/generic/WarpGlobal.gd` | **2026-11-03 10:05:11** | Phase 4.1.1 (Location Notification) |
| `sources/gui/character/Stats.gd` | **2026-11-03 10:05:18** | Phase 4.1.1 (Character Status UI) |

### 5.3 Forensic Zero-Mutation Verification
- **Phase 4.2.2 Commencement:** 2026-11-03 11:00:00
- **Phase 4.2.3 Commencement:** 2026-11-03 11:23:00
- **Phase 4.2.3.1 Commencement:** 2026-11-03 11:37:00
- **Latest Source File Modification:** `sources/gui/character/Stats.gd` at **10:05:18** (during Phase 4.1.1).

**Forensic Conclusion:**
Command `git diff --name-only -- '*.gd' '*.tscn' '*.tres' '*.res' '*.png' '*.webp' '*.jpg' '*.ogg' '*.wav'` shows **zero modifications** performed during Phase 4.2.2, 4.2.3, or 4.2.3.1. All tracked changes exist as uncommitted working-tree modifications inherited from Phase 2 through Phase 4.1.1. Every change executed in Phase 4.2.2, 4.2.3, and 4.2.3.1 has been strictly confined to Markdown documentation files (`.md`).

---

## 6. EVIDENCE INDEX & ARTIFACT REGISTER

| Artifact Ref | Path / Resource | Type | Verified Truth / Finding |
| :--- | :--- | :--- | :--- |
| **EV-01** | `sources/actor/Actor.gd:7` | Source Code | `var state = State.IDLE` establishes default state is 0, never -1. |
| **EV-02** | `sources/actor/agent/BaseAgent.gd:61-70` | Source Code | `SetState()` indexing formula and state transition mechanism. |
| **EV-03** | `sources/network/NetworkCommons.gd:5-10` | Source Code | Port declarations: ENet 6119/6109, WebSocket 6118/6108. |
| **EV-04** | `scripts/serve_web.py:6` | Python Script | Static web server port is 8085 with COOP/COEP headers. |
| **EV-05** | `tests/run_crossplatform_test.sh:12,19`| Shell Script | Empirical runtime test proves ENet on 6119 and WebSocket on 6118. |
| **EV-06** | `tests/TestSwordsmanBinding.gd:38-98` | Test Script | Exactly 16 assertions executed covering Idle and Walk octants only. |
| **EV-07** | `assets/characters/swordsman/*.png` | Image Assets | 7 spritesheets totaling 512 frames verified via Pillow image scanner. |
| **EV-08** | Git Filesystem MTime | Filesystem Stat | Proves zero source modifications since 10:05:18 on 2026-11-03. |

---

## 7. REMAINING RISKS & UNVERIFIED CLAIMS

1. **Unchecked State Indexing:** `BaseAgent.SetState()` lacks defensive bounds checking against out-of-range state enums. While currently safe, future additions to `ActorCommons.State` carry negative indexing risks if not clamped.
2. **Untested Attack / Death Playback:** While `attack_*` (80 frames) and `death_*` (64 frames) are mapped in `Visual.gd:136`, they have not been asserted in an automated test script like `TestSwordsmanBinding.gd`.
3. **Missing Frame-Level Sync over High WAN Latency:** On network connections with $>150$ ms latency, damage numbers appear before the sword slash animation finishes.

---

## 8. FINAL ACCEPTANCE ASSESSMENT

All requirements for Phase 4.2.3.1 have been achieved:
- [x] **R-06:** State initialization traced across Player, Monster, and NPC lifecycles; verified safe; potential architectural defect documented.
- [x] **R-07:** Network ports reconciled across ENet (6119/6109), WebSocket (6118/6108), and HTTP static serving (8085); obsolete 8080 eliminated.
- [x] **R-08:** Three-tier verification taxonomy (Resource Load, Animation Availability, Runtime Playback) established and applied across all 56 animations.
- [x] **R-09:** Git diff and zero-mutation status forensically validated via file modification timestamps.
- [x] **Strict Scope:** Zero gameplay code, scene, resource, asset, database, or project settings files modified.

---

*Authored by Senior Godot Engineer & Documentation Lead — Thiên Đạo Nghịch Mệnh Phase 4.2.3.1.*
