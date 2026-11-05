# PHASE 4.0 — DEPENDENCY MAP & ARCHITECTURAL INVARIANTS
## Project: THIÊN ĐẠO NGHỊCH MỆNH (TDNM)
**Engine:** Godot 4.7.1 Stable  
**Foundation:** Source of Mana (Commit `1933bd66caf2c59fd5d9b5df410d19838059b243`)  
**Date:** 2026-11-02  

---

## 1. ARCHITECTURAL DEPENDENCY GRAPH

The diagram below illustrates the exact runtime dependencies between singletons, dynamic services, server components, and client presentation:

```
                      ┌─────────────────────────────────┐
                      │          project.godot          │
                      │  (Autoloads: Launcher, Network, │
                      │                 FSM)            │
                      └────────────────┬────────────────┘
                                       │
                ┌──────────────────────┴──────────────────────┐
                ▼                                             ▼
  ┌───────────────────────────┐                 ┌───────────────────────────┐
  │   Launcher (Client Mode)  │                 │   Launcher (Server Mode)  │
  └─────────────┬─────────────┘                 └─────────────┬─────────────┘
                │                                             │
      ┌─────────┴─────────┐                         ┌─────────┴─────────┐
      ▼                   ▼                         ▼                   ▼
┌───────────┐       ┌───────────┐             ┌───────────┐       ┌───────────┐
│MapService │       │GUI Service│             │WorldServ. │       │SQL Service│
│ (Map.gd)  │       │ (Gui.gd)  │             │(World.gd) │       │ (SQL.gd)  │
└─────┬─────┘       └─────┬─────┘             └─────┬─────┘       └─────┬─────┘
      │                   │                         │                   │
      ▼                   ▼                         ▼                   ▼
┌───────────┐       ┌───────────┐             ┌───────────┐       ┌───────────┐
│  MapPool  │       │HUD / Panels│            │WorldMap / │       │SQLite DB  │
│(Layers/   │       │(Inventory,│             │Instances  │       │(14 tables,│
│ Fringe)   │       │ Stats,etc)│             │(Agents)   │       │ triggers) │
└───────────┘       └───────────┘             └───────────┘       └───────────┘
```

---

## 2. CORE SYSTEM COUPLINGS & CONTRACTS

### 2.1 The `DB.gd` StringName Hash Contract
The resource database (`sources/db/DB.gd`) is the central registry for all entities, maps, items, skills, and quests.

**Strict Invariant Rules:**
1. **Hashing Constraint:** Every entity registered in `DB.EntitiesDB` must satisfy:
   $$\text{entity.\_id} == \text{entity.\_name.hash()}$$
   Failure will trigger an immediate assertion error on startup:
   `assert(entity._id == entity._name.hash(), "ID for entity %s is not set...")`
2. **Duplicate Protection:** Duplicate IDs in any dictionary (`EntitiesDB`, `ItemsDB`, `MapsDB`) will cause a hard assertion crash.
3. **Directory Scanning:** `DB.gd` populates itself via `FileSystem.ParseResources(path)` using constants defined in `Path.gd`. When introducing new Xianxia categories, paths must be explicitly configured.

---

### 2.2 Client-Server Network RPC Protocol
All multiplayer communication flows through `sources/network/Network.gd` and is governed by strict authoritative boundaries:

| RPC Direction | Method Name | Payload Structure | Function & Authority |
| :--- | :--- | :--- | :--- |
| **Client $\to$ Server** | `MoveAgent` | `[direction: int, speed: float]` | Client requests directional movement; Server calculates new position. |
| **Client $\to$ Server** | `CastSkill` | `[skillID: int, targetRID: int, targetPos: Vector2]` | Client requests skill activation; Server verifies cooldown and mana. |
| **Client $\to$ Server** | `InteractNpc`| `[npcRID: int]` | Client clicks NPC; Server initiates `NpcScript` coroutine. |
| **Client $\to$ Server** | `NpcChoice` | `[choiceIdx: int]` | Client selects branching dialogue option. |
| **Server $\to$ Client** | `Bulk` | `[method: String, args: Array, targetPeer: int]` | High-throughput batched packet delivery for entity states and warps. |
| **Server $\to$ Client** | `PreloadEntity` | `[agentRID, actorType, currentShape, nick, defaultState]` | Instructs client to cache and spawn entity under `Map.currentFringe`. |
| **Server $\to$ Client** | `SetAgentPosition` | `[agentRID, position, direction, state]` | Authoritative position update interpolated by client lerp. |
| **Server $\to$ Client** | `SyncStat` | `[agentRID, statDictionary]` | Synchronizes health, mana, level, and alteration timers. |

---

### 2.3 Map and Visual Layering Hierarchy
The 2.5D visual rendering pipeline relies on a specific scene tree structure:

```text
Launcher (Root Node)
└── MapNode (e.g. SacredSectHub)
    ├── GroundLayer (TileMapLayer - floor terrain)
    ├── Fringe (Node2D, y_sort_enabled = true)   <-- CRITICAL REPARENTING NODE
    │   ├── Scenery Objects (Sprite2D with Y-Sort)
    │   ├── Player Entities (Entity.gd -> Visual.gd)
    │   ├── Monster Entities (Entity.gd -> Visual.gd)
    │   └── Ground Drops (Interactive Item Sprites)
    └── OverheadLayer (Tree canopies, roofs above players)
```

**Key Invariant:**
- When `Map.LoadMapNode()` executes, it searches for a child named `"Fringe"`.
- `Map.SpawnEntity()` will **fail silently and return null** if `currentFringe` is missing.
- Every Xianxia map must maintain a `Fringe` node with `y_sort_enabled = true`.

---

## 3. SQLITE PERSISTENCE CONSTRAINTS

The persistence layer (`sources/sql/SQL.gd`) directly drives character data, inventory, and quest states.

### 3.1 Automated Trigger Constraints
SQLite triggers are installed automatically via migration files (`data/conf/migrations/001.sql`):
1. **`trg_character_new`**: Automatically initializes default rows in `traits`, `stats`, `inventory`, `equipment`, and `bestiary` whenever a new character record is inserted.
2. **`trg_character_delete`**: Automatically cascades and purges all related inventory, equipment, quest progress, and stat records when a character is deleted.
3. **`trg_account_delete`**: Cascades account deletion to all owned characters and their child records.

**Rule for Cultivation Features:**
When adding new cultivation tables (e.g. `cultivation_realm`, `sect_membership`), corresponding trigger definitions must be updated in migration scripts to prevent orphaned records.

---

## 4. PROTECTED SUBSYSTEMS (IMMUTABLE BOUNDARIES)

To maintain absolute stability, the following systems are classified as **PROTECTED** and must NOT be casually rewritten:

1. **Asset Vault (`thien-dao-nghich-menh/public/assets`):**
   - **IMMUTABLE MASTER.** Contains 357 original source files (42.3 MB).
   - Zero modifications, renaming, deletions, or moves permitted under any circumstances.
2. **Godot Engine Version:**
   - Locked to **Godot 4.7.1 Stable**.
   - No engine upgrades or third-party fork compilations.
3. **Upstream Git Remote & Baseline:**
   - Upstream commit pinned to `1933bd66caf2c59fd5d9b5df410d19838059b243`.
   - Git tag `v0.1.0-baseline-1933bd6`.
4. **Networking Ports & Protocols:**
   - ENet (Desktop Native) locked to UDP `6119`.
   - WebSocket (Web Browser) locked to TCP `6118`.
   - Web server local serving locked to port `8085` with mandatory COOP/COEP headers.
5. **Autoload Singleton Architecture:**
   - `project.godot` must retain strictly `Launcher`, `Network`, and `FSM`.
   - No polluting `project.godot` with global singletons that bypass dynamic mode allocation.
