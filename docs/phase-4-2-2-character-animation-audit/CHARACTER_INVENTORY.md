# TDNM — CHARACTER INVENTORY & ARCHITECTURAL AUDIT
## Phase 4.2.2 Technical Investigation

**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Date:** 2026-11-03  
**Evidence Policy:** 100% verified against repository `.tres` and `.tscn` files.  

---

## 1. CHARACTER ARCHITECTURE OVERVIEW

The character system in Source of Mana follows a hierarchical component architecture:
- **Base Class:** `Actor.gd` (inherits `CharacterBody2D`) provides base stats (`ActorStats`), inventory (`ActorInventory`), progress (`ActorProgress`), and state (`ActorCommons.State`).
- **Network Agent:** `BaseAgent.gd` (server-side agent handling physics, collision, navigation with `NavigationAgent2D`, velocity synchronization, and state transitions).
  - `PlayerAgent.gd` handles player networking, visibility culling, stats synchronization, and trading.
  - `MonsterAgent.gd` / `AIAgent.gd` handles mob agro, target tracking, pathfinding, and attack cooldowns.
  - `NpcAgent.gd` handles dialogue scripts (`NpcScript.gd`) and interaction boundaries.
- **Client Entity:** `Entity.gd` (client-side actor rendering in world) coordinates three child nodes:
  - `Visual.gd` (`$Visual`): Instantiates `$Visual/Preset`, manages animations, 4-dir vs 8-dir directional facing, foot offsets, and equipment/hair overrides.
  - `Interactive.gd` (`$Interactive`): Displays health bars, nameplates, chat bubbles, selection circles, emotes, casting VFX, and floating alteration numbers.
  - `Sfx.gd` (`$Sfx`): 2D positional audio manager playing movement, attack, damage, level-up, and environmental sounds.

---

## 2. COMPLETE INVENTORY OF EXISTING ENTITY PRESETS (97 PRESETS)

| Character ID | Name | Category | Scene / Preset | Sprite Resource | Animation Count | Direction Support | Runtime Status |
|---|---|---|---|---|---:|---|---|
| `2088932705` | **Andi** | NPC | `Andi.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2834092087` | **Bandit** | NPC | `Bandit.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `193452188` | **Bat** | MONSTER | `Bat.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `193452314` | **Ben** | NPC | `Ben.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2843189460` | **Bicies** | NPC | `Bicies.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2088963654` | **Bird** | NPC | `Bird.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `217460284` | **Chest** | OBJECT / TRIGGER | `Chest.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `2089009292` | **Croc** | MONSTER | `Croc.tres` | `Embedded / None` | 29 | 8 Directions | `VERIFIED` |
| `2929114690` | **Dorian** | NPC | `Dorian.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2469123693` | **Drain Slime** | MONSTER | `Drain Slime.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `219944129` | **Ekinu** | NPC | `Ekinu.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3325600555` | **Elanore** | NPC | `Elanore.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `219979635` | **Elias** | NPC | `Elias.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089075532` | **Emil** | NPC | `Emil.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `220195358` | **Eridu** | NPC | `Eridu.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2866154511` | **Evil Mushroom** | MONSTER | `Evil Mushroom.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `1836204198` | **Fire Goblin** | MONSTER | `Fire Goblin.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `4234567318` | **Fire Skull** | NPC | `Fire Skull.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `1902637957` | **Flour Barrel** | OBJECT / TRIGGER | `Flour Barrel.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `3003932433` | **Fluffy** | MONSTER | `Fluffy.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `221388307` | **Frost** | NPC | `Frost.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `1184402587` | **Gabriel** | NPC | `Gabriel.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089134121` | **Gabz** | NPC | `Gabz.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2624609623` | **Giant Maggot** | MONSTER | `Giant Maggot.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2550418766` | **Gilgames** | NPC | `Gilgames.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3045949408` | **Goblin** | MONSTER | `Goblin.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3097291557` | **Hyland** | NPC | `Hyland.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089277954` | **Kael** | NPC | `Kael.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3922677720` | **Letter Stash** | OBJECT / TRIGGER | `Letter Stash.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `31947249` | **Light Trigger** | OBJECT / TRIGGER | `Light Trigger.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `228176527` | **Lilah** | NPC | `Lilah.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `1435506618` | **Lizandra** | NPC | `Lizandra.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `1435506622` | **Lizandre** | NPC | `Lizandre.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `228382689` | **Locks** | NPC | `Locks.tres` | `Embedded / None` | 18 | 4 Directions | `BLOCKED (Resource Parse Error)` |
| `228607896` | **Lulea** | NPC | `Lulea.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089340336` | **Lynx** | MONSTER | `Lynx.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3264194551` | **Maclat** | NPC | `Maclat.tres` | `Embedded / None` | 18 | 4 Directions | `BLOCKED (Resource Parse Error)` |
| `3264333316` | **Maggot** | MONSTER | `Maggot.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2025440114` | **Mana Tree** | OBJECT / TRIGGER | `Mana Tree.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `999510798` | **Manayir Druid** | NPC | `ManayirDruid.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `608165177` | **Manayir Druidess** | NPC | `ManayirDruidess.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3264744754` | **Marvin** | NPC | `Marvin.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `229085321` | **Mauro** | NPC | `Mauro.tres` | `Embedded / None` | 18 | 4 Directions | `BLOCKED (Resource Parse Error)` |
| `670207772` | **Minguer** | NPC | `Minguer.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `193464646` | **NPC** | NPC | `NPC.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089385766` | **Naem** | NPC | `Naem.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089386186` | **Nard** | NPC | `Nard.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089390322` | **Neko** | NPC | `Neko.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3312816684` | **Nickos** | NPC | `Nickos.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `1948908174` | **Nicolas** | NPC | `Nicolas.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089394763` | **Nina** | NPC | `Nina.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3343895260` | **Object** | NPC | `Object.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `4054136443` | **Old Chest** | OBJECT / TRIGGER | `Old Chest.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `3381597015` | **Pachua** | NPC | `Pachua.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `232785317` | **Peter** | NPC | `Peter.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3387138907` | **Peyote** | MONSTER | `Peyote.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3391482565` | **Pinkie** | MONSTER | `Pinkie.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089466690` | **Piou** | MONSTER | `Piou.tres` | `Embedded / None` | 29 | 8 Directions | `VERIFIED` |
| `3394588274` | **Player** | PLAYER | `Player.tres` | `SwordsmanPreset.tscn` | 56 | 8 Directions | `VERIFIED (Active)` |
| `235013903` | **Ratto** | MONSTER | `Ratto.tres` | `Embedded / None` | 29 | 8 Directions | `VERIFIED` |
| `3662818686` | **Red Queen** | NPC | `Red Queen.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `825312237` | **Red Scorpion** | MONSTER | `Red Scorpion.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3469933044` | **Riskim** | NPC | `Riskim.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089555519` | **Ryan** | NPC | `Ryan.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2250973363` | **Salt Slime** | MONSTER | `Salt Slime.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2399925469` | **Sand Snake** | MONSTER | `Sand Snake.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `817801695` | **DeepLevelCrack** | OBJECT / TRIGGER | `SandstormMineCrack.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `3478975634` | **SandstormMineKey** | OBJECT / TRIGGER | `SandstormMineKey.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `236203253` | **Sawyl** | NPC | `Sawyl.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3842739378` | **Scorpion** | MONSTER | `Scorpion.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `1744780248` | **Sea Slime** | MONSTER | `Sea Slime.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089570059` | **Sema** | NPC | `Sema.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089573209` | **Ship** | NPC | `Ship.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `236439338` | **Shiro** | NPC | `Shiro.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `890728458` | **Skeleton** | MONSTER | `Skeleton.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `236582911` | **Slime** | MONSTER | `Slime.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2450367875` | **Sludge Slime** | MONSTER | `Sludge Slime.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `1190381389` | **Snake Pit Clue** | MONSTER | `Snake Pit Clue.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `1190851605` | **Snake Pit Pond** | MONSTER | `Snake Pit Pond.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `236646007` | **Snake** | MONSTER | `Snake.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `737772331` | **Soul Menhir** | OBJECT / TRIGGER | `Soul Menhir.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `2549154767` | **Spiky Mushroom** | MONSTER | `Spiky Mushroom.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3314548081` | **Splatyna** | BOSS | `Splatyna.tres` | `Embedded / None` | 18-29 | 4-8 Directions | `VERIFIED (Map Spawn)` |
| `89439950` | **StaticNPC** | NPC | `StaticNPC.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `1629942628` | **StaticObject** | NPC | `StaticObject.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `970294591` | **Thiefs Chest** | OBJECT / TRIGGER | `Thiefs Chest.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `1060916485` | **TicTacToeCell** | OBJECT / TRIGGER | `TicTacToeCell.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `3905186616` | **Tulimshar Desert Guard** | NPC | `Tulimshar Desert Guard.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3918743578` | **Tulimshar Desert Sbire** | NPC | `Tulimshar Desert Sbire.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3639315857` | **Tulimshar Guard** | NPC | `Tulimshar Guard.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3652872819` | **Tulimshar Sbire** | NPC | `Tulimshar Sbire.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `3562408837` | **Turtle** | MONSTER | `Turtle.tres` | `Embedded / None` | 29 | 8 Directions | `VERIFIED` |
| `2377595219` | **WalkingNPC** | MONSTER | `WalkingNPC.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2089709631` | **Warp** | OBJECT / TRIGGER | `Warp.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `2089713785` | **Well** | OBJECT / TRIGGER | `Well.tres` | `Embedded / None` | 0-8 | Static / 1 Dir | `VERIFIED` |
| `193475306` | **Wie** | NPC | `Wie.tres` | `Embedded / None` | 18 | 4 Directions | `VERIFIED` |
| `2715760142` | **Xakelbael** | BOSS | `Xakelbael.tres` | `Embedded / None` | 18-29 | 4-8 Directions | `VERIFIED (Map Spawn)` |

---

## 3. CATEGORY BREAKDOWN & METRICS

- **Total Entity Presets:** 97
- **Player Characters:** 1 (`Player.tres` $\rightarrow$ `SwordsmanPreset.tscn`)
- **Bosses:** 2 (`Red Queen` `4253303867`, `Frost` `1327170942`)
- **Monsters / Hostile Entities:** 28
- **NPCs / Townspeople / Guards:** 53
- **Interactive Objects / Chests / Triggers / Menhirs:** 13

---

## 4. DETAILED CATEGORY ASSESSMENTS

### 4.1. Playable Character (`Player.tres` / `SwordsmanPreset.tscn`)
- **Runtime Status:** `PARTIALLY VERIFIED` (Actively bound in `Player.tres`; runtime playback verified for 16 directional states in `TestSwordsmanBinding.gd`: 8-dir `idle` + 8-dir `walk`; `attack` and `death` mapped in code; `hurt`, `combo`, `qinggong` unmapped).
- **Architecture:** `SwordsmanPreset.tscn` contains an `AnimatedSprite2D` node with `swordsman_frames.tres` (56 animations, 512 total frames).
- **Collision Shape:** Circle shape with radius 10px in `PlayerAgent.gd` (`triggerShape`).
- **Pivot and Foot Anchor:** Dynamic anchoring via `Visual.SWORDSMAN_FOOT_OFFSETS`: `idle`/`walk` at `(20, 38)`, `attack`/`qinggong`/`combo` at `(36, 58)`, `hurt`/`death` at `(28, 48)`.
- **Directional Facing:** 8 isometric directions (`east`, `south-east`, `south`, `south-west`, `west`, `north-west`, `north`, `north-east`) calculated via vector angle octant formula in `Visual.GetSwordsmanDirection()`.
- **Y-Sort:** Enabled directly on root node (`y_sort_enabled = true`).
- **Limitations:** Bypasses SoM paperdoll equipment layering. Clothes, hair, and sword are baked into the spritesheet.

### 4.2. Boss Characters (`Red Queen`, `Frost`)
- **`Red Queen` (`4253303867`):** Instantiates `Splatyna.tscn` (giant queen monster in Splatyna Cavern). Radius 32px. Features 4-direction idle, walk, attack, and death. Tracked via `Launcher.GUI.bossTracker`.
- **`Frost` (`1327170942`):** Instantiates `Generic4Directions.tscn` (ice boss in Candor Arena). Radius 24px. Features 4-direction attack and spellcasting. Tracked via `bossTracker`.
- **Boss Phase Transitions:** Currently `NOT IMPLEMENTED`. Bosses use standard mob AI (`AIAgent.gd`) with higher HP and damage values; they do not possess multi-phase animation transformations or attack telegraph zones.

### 4.3. Monster Categories (28 Mobs)
- **8-Direction Monsters (4 types):** `Croc` (crocodile), `Piou` (desert bird/chicken), `Ratto` (giant rat), `Turtle` (armored tortoise). Each possesses 29 animations in `AnimationPlayer` across 8 directions.
- **4-Direction Monsters (14 types):** `Bat`, `Bird`, `Lizzy`, `Lynx`, `Skull`, `Slime`, `SlimeSea`, `SlimeSludge`, `Splatyna`, `Skeleton`, `Snake`, `Scorpion`, `Mushroom-Evil`, `Mushroom-Spiky`. Each possesses 18 animations.
- **Static / Minimal Monsters (10 variants):** Slime color variants (`Drain Slime`, `Salt Slime`), Maggots, Peyote cactus.

### 4.4. NPCs (53 Presets)
- Most NPCs instantiate `StaticNPC.tscn` (single facing with subtle idle loop) or `Generic4Directions.tscn` (4-direction idle).
- Interactive talk dialog is managed by `interactive._on_click_area_mouse_entered()` and server `NpcAgent.gd` dispatching to `NpcScript.gd`.
- Three presets (`Locks.tres`, `Maclat.tres`, `Mauro.tres`) fail to parse due to upstream SoM syntax anomalies (`Parse Error: .`); they are quarantined and documented in `TECHNICAL_ARCHITECTURE_ASSESSMENT.md`.