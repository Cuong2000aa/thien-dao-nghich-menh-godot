# THIÊN ĐẠO NGHỊCH MỆNH — PROJECT VISION
## Document Code: DOC-PROJ-VISION
## Status: AUTHORITATIVE & CORRECTED BASELINE
## Engine: Godot 4.7.1 Stable | Foundation: Source of Mana (Commit `1933bd6`)

---

### 1. The Core Vision

**Thiên Đạo Nghịch Mệnh** (TDNM) is an isometric 2.5D Chinese Xianxia (Tu Tiên) MMORPG developed on top of the open-source Godot engine foundation **Source of Mana** (SoM).

The central mandate of TDNM is:
> **Preserve the existing Source of Mana world and maps as the MAIN GAME WORLD, and progressively transform its content, atmosphere, and mechanics into the Chinese Xianxia cultivation world of Thiên Đạo Nghịch Mệnh.**

#### Fundamental Directives:
1. **No Replacement World:** We are **NOT** replacing the existing Source of Mana world with a newly built parallel map.
2. **No Parallel Forked Game:** We are **NOT** building a detached mini-game or disconnected playground.
3. **No Automatic Start Map Override:** Newly created maps (such as *Thanh Vân Thôn* or *Sacred Sect Hub*) do **NOT** automatically replace the default starting experience or the primary world of Source of Mana.
4. **Continuity of One Coherent World:** All maps—both the original interconnected 40+ regions of Source of Mana and new expansion areas—coexist within a single coherent universe.

---

### 2. The Protagonist & Narrative Premise

- **Identity:** The protagonist is a modern person from the 21st-century real world who transmigrates into this cultivation era.
- **Physical Entity:** He retains his **original physical body**, his **memories**, his **scientific and modern knowledge**, and his **authentic personality**. He does **NOT** possess (đoạt xá) another person's body or steal another cultivator's identity.
- **Core Journey:**
  1. *Survival:* Awaking in an unfamiliar, harsh world with only modern wits and mortal limits.
  2. *Cultivation Discovery:* Uncovering the laws of spiritual energy (Linh Khí), meridian circulation, and breathing techniques.
  3. *Growth & Mastery:* Transitioning from a modern mortal surviving in mortal settlements to a true cultivator traversing perilous wildernesses and ancient ruins.
  4. *The Ultimate Quest:* Unraveling the profound mystery of the Heavenly Dao (Thiên Đạo) and discovering the true cosmic cause behind his transmigration.

---

### 3. World Transformation Strategy

Rather than discarding the rich, functioning level architecture of Source of Mana, TDNM employs a **gradual content transformation**:

```
[Existing Source of Mana Technical Foundation]
  ├── Working Multiplayer (ENet + WebSocket Dual Protocol)
  ├── Server Authority Movement & Synchronization
  ├── SQLite Persistence Architecture
  └── 40+ Interconnected Map Regions
                       │
                       ▼  (Gradual Thematic & Content Transformation)
[Thiên Đạo Nghịch Mệnh Cultivation MMORPG]
  ├── Player Characters ──► Xianxia Cultivators (8-direction Swordsman, etc.)
  ├── NPCs & Merchants  ──► Daoist Inhabitants, Herbalists, Village Elders, Sect Disciples
  ├── Monsters & Mobs   ──► Demonic Beasts, Spiritual Fauna, Corrupted Entities
  ├── Boss Encounters   ──► Ancient Guardians, Demon Lords, Realm Tribulation Beasts
  ├── Quests & Lore     ──► Xianxia Missions, Sect Trials, Daoist Opportunities (Cơ Duyên)
  ├── Items & Equipment ──► Spirit Stones, Cultivation Pills, Flying Swords, Dharma Artifacts
  └── Skills & Combat   ──► Qi Condensation Arts, Elemental Techniques, Sword Formations
```

---

### 4. Classification of Game World Maps

To ensure crystal clarity for design and engineering, all maps in TDNM fall into one of four distinct categories:

| Category | Definition | Current Examples |
|---|---|---|
| **1. Existing Main World Maps** | The original interconnected maps of Source of Mana serving as the backbone of the player's world journey. | `Tulimshar` (Port/Start), `Overworld`, `Artis`, `Candor Cave`, `Tonori Desert`, `Ship Decks`. |
| **2. Transformed Existing Maps** | Original SoM maps that undergo gradual environmental reskinning, NPC replacement, and lore re-anchoring to become Eastern Xianxia locations. | Planned gradual re-theming of Tulimshar into an ancient maritime trade port / mortal boundary. |
| **3. New Additional Maps** | Newly constructed maps introduced to expand the world when required by narrative, sect lore, or high-level gameplay. Must connect into the world logically without replacing it. | `SacredSectHub` (Tông Môn Thánh Địa), `TanThuThon` (Thanh Vân Thôn - hidden mountain village). |
| **4. Experimental / Test Maps** | Isolated technical diorama and test environments used solely for engine evaluations and automated test harnesses. Never part of main player progression. | `WorldIntegrationScene.tscn`, `prototype_iso/`. |

---

### 5. Architectural Invariants

1. **Working Systems Stay Working:** Never rewrite working networking, movement synchronization, or database persistence merely to change aesthetic themes.
2. **Asset Vault Immutability:** The asset vault (`thien-dao-nghich-menh/public/assets`) is strictly read-only and immutable.
3. **Continuous Playability:** Every release and milestone must produce a fully playable, client-server connected build on Native Desktop and Web browsers.
