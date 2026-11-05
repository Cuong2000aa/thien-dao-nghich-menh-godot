# TDNM CHARACTER & ANIMATION PRODUCTION ROADMAP
**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Phase:** 4.2.2 — Character & Animation Deep Technical Audit  
**Scope:** Actionable Multi-Phase Implementation Plan for Character Art, State Machines, Combat & Animation Systems  
**Status:** ENGINEERING PROPOSAL (`[PROPOSED]`) — SUBJECT TO OWNER AUTHORIZATION  

---

## 1. STRATEGIC PURPOSE

> [!NOTE]
> This production roadmap represents **engineering proposals (`[PROPOSED]`)** designed to structure future character art, combat mechanics, and animation systems sequentially. No milestone will be executed without explicit Project Owner approval.

This production roadmap defines the precise development trajectory for transitioning Thiên Đạo Nghịch Mệnh from the current static audit state to a fully playable, visually coherent, 8-directional Xianxia MMORPG combat experience. 

All roadmap phases strictly adhere to the overarching principle:
> **Content Transformation, NOT a Rewrite.** Every milestone builds incrementally upon the existing Godot 4.7.1 Source of Mana foundation.

---

## 2. MULTI-PHASE PRODUCTION MILESTONES

```
┌────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: PRE-COMBAT PROTOTYPE & ENGINE UNBLOCK (Immediate Next)       │
│  Duration: 1-2 Sprints | Focus: GDScript Logic & Existing Frame Wiring │
├────────────────────────────────────────────────────────────────────────┤
│  • M1.1: Expand ActorCommons.State (HURT, QINGGONG, CASTING).          │
│  • M1.2: Activate 288 dormant Swordsman frames (hurt, combo, qinggong).│
│  • M1.3: Implement 8-direction weapon overlay anchor system.           │
│  • M1.4: Resolve upstream text resource parse errors in Locks/Maclat.  │
│  • Gate: 100% of Swordsman 512 frames playable in headless + live.     │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: PRE-ALPHA XIANXIA COMBAT GATE                                │
│  Duration: 2-3 Sprints | Focus: Spells, VFX, Audio & Spirit Beasts    │
├────────────────────────────────────────────────────────────────────────┤
│  • M2.1: Implement Sword Qi (Kiếm Khí) projectile & arc slash VFX.     │
│  • M2.2: Implement Daoist Talisman (Đạo Phù) burning & flight VFX.     │
│  • M2.3: Integrate Meditation / Cultivation (Vận Công) pose.          │
│  • M2.4: Apply Xianxia spirit-beast shaders to snakes & scorpions.     │
│  • M2.5: Replace Western sword clangs with crisp martial SFX.          │
│  • Gate: Complete 3-skill cultivation combat loop verified in browser. │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: WORLD & SECT EXPANSION                                       │
│  Duration: 3-4 Sprints | Focus: Full Roster, NPCs & Environment        │
├────────────────────────────────────────────────────────────────────────┤
│  • M3.1: Deliver 8-directional Female Cultivator frameset (56 anims).  │
│  • M3.2: Reskin Tulimshar guards into Daoist disciples / Sect guards.  │
│  • M3.3: Introduce Spirit Herb gathering and Alchemy furnace nodes.    │
│  • M3.4: Integrate Traditional Chinese Guzheng/Flute ambient BGM.      │
│  • M3.5: Implement 2D illustrated dialogue portraits for key NPCs.     │
│  • Gate: First complete Sect Questline playable from start to finish.  │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: XUANHUAN GRAND SPECTACLE & POLISH                            │
│  Duration: Long-term | Focus: High-Tier Cultivation & Boss Encounters   │
├────────────────────────────────────────────────────────────────────────┤
│  • M4.1: Flying Sword (Ngự Kiếm Phi Hành) airborne movement system.    │
│  • M4.2: Heavenly Tribulation (Thiên Kiếp) multi-stage lightning VFX.  │
│  • M4.3: Multi-phase Ancient Xuanhuan Mythical Boss encounters.        │
│  • M4.4: Dynamic Yin-Yang Bagua Sect Defense Arrays.                   │
│  • Gate: Core Golden Core / Tribulation breakthrough ceremony.         │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. DETAILED MILESTONE SPECIFICATIONS

### Phase 1: Pre-Combat Prototype & Engine Unblock

| Milestone | Target Component | Engineering / Art Action | Acceptance Criteria |
| :--- | :--- | :--- | :--- |
| **M1.1** | `ActorCommons.gd` | Add `HURT = 8`, `QINGGONG = 9`, `CASTING = 10` to `State` enum | Enum serialized across ENet & WebSocket without protocol regression |
| **M1.2** | `Visual.gd` | Extend `GetSwordsmanAction` to return `"hurt"`, `"combo"`, `"qinggong"` | All 56 animations (512 frames) triggerable in test suite |
| **M1.3** | `Player.tscn` / `Visual.gd` | Wire dynamic weapon sprite layer synced to Swordsman hand positions | Equipping LongSword displays blade in hand across all 8 directions |
| **M1.4** | `presets/entities/*.tres` | Regenerate clean Godot UID resource headers for `Locks`, `Maclat`, `Mauro` | Zero parse errors during `DB.gd` initial boot sequence |

### Phase 2: Pre-Alpha Xianxia Combat Gate

| Milestone | Target Component | Engineering / Art Action | Acceptance Criteria |
| :--- | :--- | :--- | :--- |
| **M2.1** | `presets/effects/` | Create `SwordQiSlash.tscn` with trailing cyan/golden light ribbon | Spawns along cast orientation, plays impact ripple on target |
| **M2.2** | `presets/effects/` | Create `TalismanFlame.tscn` burning parchment projectile | Tracks target with flame emitter and dissipation explosion |
| **M2.3** | `swordsman_frames.tres` | Author 8-frame cross-legged meditation loop `meditate` | Triggers when character enters passive HP/MP regeneration |
| **M2.4** | `presets/entities/` | Apply chromatic shader and glowing eye effects to desert monsters | Snakes, scorpions, and spiders reflect spirit-beast tiering |
| **M2.5** | `data/sounds/` | Replace 12 combat impacts with traditional martial audio samples | Slash, hit, and block SFX sound sharp, resonant, and cinematic |

---

## 4. QUALITY ASSURANCE & VERIFICATION GATES

Every milestone must pass strict verification gates prior to sign-off:

1. **Headless Regression Gate:**
   - Execute Godot in `--headless` mode on local macOS test bench.
   - Core test scenes (`test_phase_4_1_1_naming.tscn`, `TestSwordsmanBinding.tscn`) must yield 100% pass rate.
2. **Dedicated Server Multiplayer Gate:**
   - Spawn server with `./Godot --headless --server`.
   - Connect simultaneously via Desktop client and Browser client (port `8085`).
   - Movement, combat triggers, and animation state changes must replicate without desynchronization or console errors.
3. **Visual Quality Review:**
   - Pixel art scaling must remain crisp at native integer scales without blur, texture filtering distortion, or sprite jitter.

---

*Authored by Senior Godot Engineer & Systems Architect — Thiên Đạo Nghịch Mệnh Phase 4.2.2.*
