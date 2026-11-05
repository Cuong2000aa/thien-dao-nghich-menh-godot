# THIÊN ĐẠO NGHỊCH MỆNH — DEVELOPMENT PRINCIPLES
## Document Code: DOC-PROJ-PRINCIPLES
## Status: NON-NEGOTIABLE CORE POLICY
## Engine: Godot 4.7.1 Stable | Base: Source of Mana

---

### 1. The Core Engineering Axiom

> **CONTENT TRANSFORMATION, NOT AN ENGINE OR LEVEL REWRITE.**

1. **Preserve What Works:** Source of Mana provides battle-tested network synchronization, dedicated server infrastructure, client-server state machines, inventory and equipment logic, and SQLite persistence. These systems must be reused, configured, and incrementally adapted—never rebuilt from scratch.
2. **Main World Continuity:** Do not bypass the existing 40+ maps to create a parallel custom sandbox. The player's journey begins in the existing main world, which is progressively enriched with Xianxia flavor, characters, dialogue, monsters, and items.
3. **Additive World Expansion:** When new maps (such as cultivation sects or secret realms) are constructed, they must attach to the existing world topology via logical warps and quest gateways, not replace the primary starting map or world hub.

---

### 2. Dual-Repository Preservation Rules

The project strictly separates immutable vault assets from engine working directories:

```
[Asset Vault: thien-dao-nghich-menh] 
    └── IMMUTABLE MASTER (357 files, 42.3 MB)
          - ZERO write, rename, move, delete, or destructive conversions.
          - Single Source of Truth for raw art, character sprites, audio, and design docs.

[Working Godot Engine: thien-dao-nghich-menh-godot]
    └── OPERATIONAL CODEBASE
          - All asset migrations operate on explicit copies.
          - Chroma-key transparency processing and slicing happen strictly on local copies.
          - Traceability: Every asset references its original vault provenance.
```

---

### 3. Verification & Empirical Discipline

1. **Verify Before Asserting:** Never assume a commit, map link, or engine feature works without executing code. Run tests with actual server-client execution.
2. **Deterministic Playability:** The game must launch and connect on both Native PC (ENet UDP) and Web Browser (WebSocket TCP) after every code modification.
3. **Automated Verification Harnesses:** Keep headless regression tests runnable (`tests/run_multiplayer_test.sh`, `tests/test_single_client.tscn`, `tests/test_warp_two_way.tscn`).
4. **Clean Viewports:** Do not capture screenshots when UI overlays (e.g., Login screen or modal dialogs) are obstructing game scenery and gameplay actors.

---

### 4. Content Migration & Adaptation Workflow

When adapting an existing Source of Mana system to Xianxia:

1. **Audit Domain:** Inspect the existing data structure in `sources/db/DB.gd`, `sources/actor/`, or `presets/`.
2. **Keep Core Schemas:** Retain database tables, network packet IDs, and enum contracts.
3. **Adapt Content:**
   - Map existing stats (`Str`, `Agi`, `Vit`, `Int`, `Wis`, `Luk`) to cultivation fundamentals (`Lực Lượng`, `Thân Pháp`, `Thể Chất`, `Nguyên Thần`, `Định Lực`, `Khí Vận`).
   - Map mana/energy systems to `Chân Khí` / `Linh Lực`.
   - Map equipment slots to Taoist robes, spiritual rings, flying swords, and talismans.
4. **Test in Isolation:** Verify via unit test scenes before introducing changes to the live dedicated server database or world map definitions.

---

### 5. Scope Management & Feature Gating

- **Strict Phasing:** Every phase has defined objectives, boundaries, and acceptance criteria.
- **No Scope Creep:** Do not unilaterally introduce new maps, gameplay loops, or storyline overhauls without explicit project owner authorization.
- **Direction Alignment:** Always review `docs/project/PROJECT_VISION.md` before making architectural decisions.
