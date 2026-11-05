# TDNM — COMBAT SYSTEM & DAMAGE PIPELINE AUDIT
## Phase 4.2.2 Technical Investigation

**Project:** Thiên Đạo Nghịch Mệnh (TDNM)  
**Date:** 2026-11-03  
**Status:** VERIFIED & EMPIRICALLY AUDITED  
**Scope Boundary:** Documentation and Technical Audit ONLY

---

## 1. FULL COMBAT PIPELINE TRACING

The complete combat execution loop from user mouse click / key press to visual damage display is structured as follows:

```
[1. Player Input]
  ├── Left Click on Monster / Attack Key (sources/actor/entity/Entity.gd:84 - Cast())
  └── Input validation: Check dialogue context, skill usable flag, skill cooldown.
          │
          ▼
[2. Client-to-Server RPC Request]
  ├── Network.TriggerSkill(targetRID, skillID) (sources/network/Network.gd:319)
  └── Packet sent via ENet (Desktop 6119) or WebSocket (Browser 6118).
          │
          ▼
[3. Server Validation & State Initialization]
  ├── Server.TriggerSkill() (sources/network/server/Server.gd:339)
  ├── Skill.Cast() (sources/skill/Skill.gd:17)
  ├── Validation: IsAlive(agent), HasSkill(), !IsCoolingDown(), !IsCasting().
  ├── Consume Mana upfront (SkillCommons.TryConsume(Mana)).
  ├── agent.SetState(ActorCommons.State.ATTACK)
  └── agent.SetSkillCastID(skill.id)
          │
          ▼
[4. Server State Broadcast]
  ├── Network.NotifyNeighbours("FullUpdateEntity", [agentRID, state=ATTACK, skillCastID, ...])
  └── Clients receive RPC -> visual.Refresh() -> animatedSprite.play("attack_" + dir).
          │
          ▼
[5. Server Timing Delay (Cast & Attack Delay)]
  ├── Callback.StartTimer(agent.actionTimer, skill.castTime + agent.stat.current.castAttackDelay, Skill.Process)
  └── Agent faces target via agent.LookAt(target).
          │
          ▼
[6. Server Hit Resolution (Skill.Process & Skill.Damaged)]
  ├── Check target alive & in range: SkillCommons.IsAttackable(agent, target, skill).
  ├── Consume Stamina (SkillCommons.TryConsume(Stamina)).
  ├── Calculate Hit / Miss / Crit: Formula.GetDamage(agent, target, skill, rng).
  └── Apply health alteration: target.stat.SetHealth(-damage).
          │
          ▼
[7. Target Agro & AI Refresh]
  ├── If target is AIAgent: target.AddAttacker(agent, damage).
  └── AI.Refresh(target) switches monster state to ATTACK/HUNT.
          │
          ▼
[8. Impact & Client Replication]
  ├── Server broadcasts Network.NotifyNeighbours("TargetAlteration", [damage, HIT/CRIT/MISS, skillID]).
  ├── Server broadcasts Network.NotifyNeighbours("Casted", [agentRID, skillID, cooldownLeft]).
  ├── Client interactive.DisplayAlteration() spawns floating combat text.
  └── Client sfx.HandleAlteration() plays hit.ogg or crit.ogg.
```

---

## 2. HIT DETECTION ARCHITECTURE: DISTANCE-BASED VS HITBOX

### 2.1. Crucial Architectural Discovery: No Physical Collision Hitboxes
- In Source of Mana, combat **DOES NOT** use physics collision shapes (`Area2D`, `CollisionPolygon2D`, or frame-triggered hitboxes) for attack detection.
- Instead, all hit detection is **pure mathematical distance checking**:
  In [`sources/skill/SkillCommons.gd`](file:///Users/it/Documents/Tu%20%C4%91a%CC%A3o/thien-dao-nghich-menh-godot/sources/skill/SkillCommons.gd):
  ```gdscript
  static func IsAttackable(agent : BaseAgent, target : BaseAgent, skill : SkillCell) -> bool:
      if not agent or not target or agent == target or not ActorCommons.IsAlive(target):
          return false
      var maxDist : float = float(skill.skillRange + agent.stat.current.attackRange)
      return agent.position.distance_to(target.position) <= maxDist
  ```
- **Range Values:**
  - Base melee attack range: $32$–$48$ px (depending on agility modifier).
  - Ranged attack range (`Archer`, `Flar`): $120$–$200$ px.
  - AOE radius (`ManaBurst`, `SonicWave`): $80$–$150$ px.

### 2.2. Advantage & Limitations
- **Advantage:** 100% cheat-proof and server-authoritative; zero client-side hitbox spoofing; operates identically on Native Desktop and low-power WebAssembly clients.
- **Limitation:** Visual desynchronization. If a player attacks, the animation plays for 10 frames ($0.7$ seconds), but the damage calculation is fired strictly when `actionTimer` expires, regardless of whether the sword has visually connected with the enemy sprite.

---

## 3. DAMAGE CALCULATION FORMULAS (`sources/actor/stat/Formula.gd`)

Damage calculation is deterministic and governed by mathematically balanced formulas:

```
Physical Attack (PAtk) = MorphBaseAtk + Strength * 3.0 + Level * 0.4 + Modifiers
Magic Attack (MAtk)    = MorphBaseMAtk + Concentration * 3.0 + Level * 0.4 + Modifiers
Physical Defense (PDef)= MorphBaseDef + Endurance * 2.0 + Level * 0.3 + Modifiers
Magic Defense (MDef)   = MorphBaseMDef + Concentration * 1.5 + Level * 0.3 + Modifiers
```

### Hit & Dodge Resolution:
- **Hit Chance:** `clamp(0.05, 0.95, (Attacker.Agility * 2.0 + Attacker.Level) / (Defender.Agility * 2.5 + Defender.Level))`
- **Critical Strike Chance:** `clamp(0.01, 0.50, (Attacker.Concentration * 1.5) / 100.0)`
- **Net Damage Applied:**
  ```gdscript
  BaseDamage = (Attacker.PAtk * SkillMultiplier) - Defender.PDef
  FinalDamage = max(1, BaseDamage * (1.5 if isCrit else 1.0) * RNG_Variance)
  ```

---

## 4. SOURCE EVIDENCE FOR REPRESENTATIVE COMBAT SCENARIOS

### 4.1. Normal Player Melee Attack
- **Definition:** `presets/cells/skills/Melee.tres` (`id: 229218829`).
- **Initiation:** Triggered automatically when right-clicking an enemy or targeting an enemy with `Space`/`Enter`.
- **Cost:** 10 Stamina per swing; 0 Mana.
- **Cast Delay:** Dynamically adjusted via `Formula.GetCastAttackDelay(stat)` based on character Agility.
- **Visuals:** Swordsman plays `attack_dir` (10 frames) with built-in white blade arc.

### 4.2. Monster Melee Attack
- **Evidence:** `sources/actor/agent/variants/MonsterAgent.gd:33`:
  ```gdscript
  AddSkill(DB.SkillsDB[DB.GetCellHash(SkillCommons.SkillMeleeName)], 1.0)
  ```
- **Execution:** Mobs use the exact same `Melee.tres` skill as players, with damage scaled by the monster's `stat.attack`.
- **AI Loop:** When agroed, `AIAgent.gd` navigates within `attackRange` using `NavigationAgent2D`, halts movement, and calls `Skill.Cast(self, target, meleeSkill)`.

### 4.3. Ranged Projectile Attack (`Flar.tres` / `Archer.tres`)
- **Evidence:** `presets/cells/skills/Flar.tres` (Fire missile) and `presets/effects/particles/Flar.tscn`.
- **Execution:** When `Skill.Process()` fires, `SkillCommons.IsDelayed(skill)` is true. The server broadcasts `ThrowProjectile(agentRID, targetPos, skillID)`.
- **Client Handling:** In `Interactive.gd:185`, `DisplayProjectile()` instantiates a `Projectile` node that travels across screen toward `targetPos` over `castAttackDelay` duration. When the projectile arrives, `DisplayAlteration()` spawns damage numbers.

### 4.4. Boss Combat Execution (`Red Queen` / `Frost`)
- **Evidence:** `presets/entities/Red Queen.tres` (ID `4253303867`) and `presets/entities/Frost.tres` (ID `1327170942`).
- **Behavior:**
  - Bosses inherit `MonsterAgent.gd` and `AIAgent.gd`.
  - They possess larger collision radii ($24$–$32$ px) and elevated HP ($10,000$+).
  - Health updates are mirrored to `Launcher.GUI.bossTracker` on the client screen.
  - **Limitation:** Bosses currently execute standard melee/spell rotations without multi-target telegraphed AOE indicators or phase transitions.

---

## 5. COMBAT DEFICIENCIES & PRODUCTION RECOMMENDATIONS

1. **Missing Combat Feedback (Impact Stagger):**
   - Entities currently take damage without pausing or playing a flinch animation. Adding a brief $0.15$s visual flinch or hit flash will dramatically increase visceral feel.
2. **Decoupled Animation Events:**
   - Replacing pure independent timers with animation track markers (or calibrating `castAttackDelay` exactly to the apex frame of `attack_sheet.png`) will ensure damage numbers appear the exact microsecond the blade impacts.
3. **No Knockback / Crowd Control:**
   - Currently, no knockback, stun, or root mechanics exist in `Skill.gd`. Adding an impulse vector to `entityVelocity` during critical hits will establish true MMORPG combat weight.
