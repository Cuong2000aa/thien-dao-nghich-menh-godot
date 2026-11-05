# THIÊN ĐẠO NGHỊCH MỆNH — AI WORKING GUIDELINES
## Document Code: DOC-AI-GUIDELINES
## Audience: All AI Pair Programmers, Autonomous Agents & Engineers
## Project: Thiên Đạo Nghịch Mệnh | Engine: Godot 4.7.1 Stable

---

### 1. Invariant Principles (NON-NEGOTIABLE)

Every AI assistant working on **Thiên Đạo Nghịch Mệnh** must strictly obey these core rules:

1. **The Existing Source of Mana World IS the Main Game World:**
   - Under no circumstances should an AI agent attempt to discard or replace the existing 40+ SoM maps with a newly generated custom map.
   - Do NOT redefine a newly created map (e.g. *Thanh Vân Thôn*) as the new primary world or replacement starting hub.
2. **Never Change Default Starting Map / Spawn Without Explicit Approval:**
   - The default start map ID (`LauncherCommons.DefaultStartMapID`) belongs to the main world (`Tulimshar`).
   - Do not alter starting maps or coordinates for global gameplay without explicit instructions from the project owner.
3. **The Original Asset Vault is Read-Only & Immutable:**
   - Path: `thien-dao-nghich-menh/public/assets` (357 files, 42.3 MB).
   - NEVER create, modify, rename, delete, or run batch conversions inside the Vault.
   - All migrations must copy assets into `thien-dao-nghich-menh-godot/assets/` first.
4. **Content Transformation Over Rewrite:**
   - We are transforming content (sprites, lore, dialogues, names, sound effects, stats), NOT rewriting the engine foundation.
   - Reuse working Source of Mana networking (ENet/WebSocket), actor state machines, movement synchronization, and SQLite persistence.
5. **Honor the Protagonist Lore:**
   - The protagonist is a modern real-world human who transmigrated into this era with his **original physical body**, his **memories**, and his **scientific knowledge**.
   - He does NOT possess (đoạt xá) another person's body or steal another identity.
6. **Empirical Verification Before Completion:**
   - Never declare a milestone complete without running actual tests (`--headless` or `--server`).
   - Ensure both Native PC (Metal/ENet) and Web Browser (WebSocket) remain fully functional.
7. **Clean Screenshot Capture Standard:**
   - Before capturing in-game screenshots via viewports, always hide or dismiss all GUI CanvasLayers (such as the Login screen) and modal popups (`MessageBox`). Viewports must capture authentic in-game scenery and gameplay actors.

---

### 2. Decision Hierarchy

When confronted with conflicting interpretations or design choices:

```
                  [1. Project Owner Explicit Directives]
                                    │
                                    ▼
                   [2. docs/project/PROJECT_VISION.md]
                                    │
                                    ▼
               [3. docs/project/DEVELOPMENT_PRINCIPLES.md]
                                    │
                                    ▼
                [4. Verified Engine Source Code & Tests]
                                    │
                                    ▼
                   [5. Historical Audit Documentation]
```

---

### 3. Verification Checklist for Every Task

Before closing any turn or reporting progress:

- [ ] Has the Asset Vault remained completely untouched?
- [ ] Is the main game world intact without broken map connections?
- [ ] Does the dedicated server start cleanly with zero fatal crashes?
- [ ] Do automated test suites pass without regression?
- [ ] Are all newly introduced files properly documented in their respective domain reports?
- [ ] Has the AI avoided unsolicited scope creep or premature phase initiation?
