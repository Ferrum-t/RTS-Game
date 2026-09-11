# Stage 1.5 — Gameplay Design

**Status:** Design active — implementation not yet accepted  
**Depends on:** Stage 1 **ACCEPTED** (`CURRENT_STATE.md`)  
**Canonical climate/migration contract:** `DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`  
**Process:** `ACCEPTANCE_AND_PROCESS.md` §2–§5

> This document answers **why Stage 1.5 exists and what gameplay loop it must create**. The detailed fixed-region climate, horse, neutral, hero and artifact contract lives in `DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`.

---

## 1. Why Stage 1.5 exists

Stage 1 delivers a complete T1 fight:

```text
ENVIRONMENT → RESOURCES → WORKERS → ECONOMY → MILITARY → ATTACK → RAID → VICTORY/DEFEAT
```

The risk after stabilization is a flat loop:

```text
gather → Barracks → army → attack TC → win/lose → repeat
```

Stage 1.5 asks:

> **Why should the player keep making meaningful decisions after the basic T1 economy has stabilized?**

Nomad Wars should not become “RTS with nomad skins”. The map itself must create changing economic and territorial decisions.

The intended identity is:

```text
FIXED GEOGRAPHY
      ↓
SEASONAL STATE CHANGES
      ↓
REGIONAL VALUE CHANGES
      ↓
RESOURCE / HORSE PRESSURE
      ↓
PLAYER DECISION
      ↓
STAY / DEVELOP / CONTEST / RAID / MIGRATE
      ↓
CONFLICT
```

---

## 2. Canonical map concept

The current map concept is **not** a set of moving ecological blobs.

Each large circle is a permanent geographic region. Its boundary and location stay fixed for the match. The season changes the region's state.

The regions intentionally **do not overlap or intersect**. Neutral land remains between them.

Each region is conceived as a potential ecological/economic package for an aul. The map concept places combinations of:

- Wood / trees;
- Stone;
- Gold;
- Horses when conditions are favorable;
- a Power Site;
- neutral threats;
- physical settlement space.

A large region can potentially hold more than one aul. The current concept uses roughly two as a future multiplayer/map-design possibility; exact capacity is not a Stage 1.5 constant.

### Three climate states

Each region has exactly three gameplay-relevant states:

| Technical name | Map color | Meaning |
|---|---|---|
| `COLD` | blue | winter / frost / low biological productivity |
| `FAVORABLE` | green | zone of life; best general ecological state for settlement and development |
| `DRY` | orange | summer heat / dryness / reduced ecological productivity |

`TRANSITION` is **not** a fourth gameplay state in the current model. Spring/autumn can be represented by the seasonal clock changing a region from one state to another.

The technical names are temporary. Final world terminology should be fictional and Turkic-inspired without directly copying a historical language or Tolkien-style fantasy languages.

---

## 3. Core causal chain

Every Stage 1.5 mechanic must answer:

```text
What changed?
      ↓
Why does it matter?
      ↓
What can the player do?
      ↓
What does each choice cost/risk?
      ↓
What is the payoff?
      ↓
How can the opponent exploit the same situation?
```

The primary intended chain is:

```text
SEASON CHANGES
      ↓
REGION STATES CHANGE
      ↓
ECOLOGICAL / ECONOMIC VALUE CHANGES
      ↓
RESOURCE / HORSE CONDITIONS CHANGE
      ↓
CURRENT AUL BECOMES MORE OR LESS ATTRACTIVE
      ↓
PLAYER EVALUATES OTHER REGIONS
      ↓
STAY / RETARGET / DEFEND / RAID / CONTEST / MIGRATE
```

The player must not be forced into migration merely because a clock reached a threshold.

---

## 4. Q1 — Role of climate regions

**Status:** DESIGN ACCEPTED.

Climate is a gameplay system, not only VFX.

The current intended first effect is a soft change in regional resource value/efficiency. The effect should be meaningful enough to influence army/build tempo, but not so dominant that harvesting outside a favorable state becomes impossible.

Important separation:

```text
REGION       = fixed geography
CLIMATE      = current state of that region
STOCK        = resource amount remaining
DISTANCE     = logistics cost
WORKING AREA = practical combination of value + logistics + defense + opponent pressure
```

A green/FAVORABLE region is generally the most attractive ecological state, but **green does not automatically mean “build here”**.

Terrain/buildability is a separate future layer.

### Working region

The player's effective working region depends on more than color:

```text
CLIMATE
 + RESOURCE MIX / STOCK
 + HORSE AVAILABILITY
 + DISTANCE
 + DEFENSE
 + OPPONENT PRESSURE
 + SETTLEMENT POSITION / CAPACITY
 = CURRENT WORKING REGION
```

This prevents the system from becoming a simple “chase the green circle” mechanic.

---

## 5. Q2 — Scarcity and wrong geography

**Status:** DESIGN ACCEPTED.

Resource pressure remains separate from climate.

| Axis | Meaning |
|---|---|
| Physical depletion | local stock reaches zero |
| Spatial scarcity | useful stock exists but the next cluster is far |
| Wrong-typed geography | nearby stock does not match the current production plan |
| Climate flow | current regional efficiency/value |
| Economic scarcity | felt tempo gap, not a new deficit subsystem |

Local depletion is survivable.

Valid responses remain:

```text
endure
→ switch resource / plan
→ remote harvest
→ contest another region
→ migrate if persistent structural mismatch makes it worthwhile
```

Do not turn climate into a depletion wipe and do not create an automatic migration timer.

---

## 6. Q3 — Depletion is not a migration clock

**Status:** DESIGN ACCEPTED.

Rejected:

- hard local collapse;
- “home empty → must migrate”;
- a disguised depletion timer whose intended endpoint is migration.

Accepted:

> Depletion lowers the value of a local working region. Combined with distance, climate, resource mismatch, defense and opponent pressure, it can make another region more attractive.

Migration remains optional.

---

## 7. Q4 — Mobility and settlement migration

**Status:** DESIGN ACCEPTED.

Migration is a strategic repositioning of the settlement anchor, not a command issued by the climate system.

Hierarchy:

```text
Worker relocation
    ↓
Remote harvesting
    ↓
Temporary forward presence
    ↓
Settlement migration
```

The existing mobile Town Center / pack-unpack system is the **means** of changing the settlement anchor.

Migration should involve:

- downtime;
- vulnerability;
- lost or delayed production;
- positional risk;
- prediction of whether the destination remains valuable.

Migration can be wrong. The player must be able to win without migrating.

---

## 8. Horses as the first ecological response

Horses are a particularly readable test of the climate loop.

Conceptually:

```text
BAD HORSE CONDITIONS
      ↓
HORSE AVAILABILITY FALLS / BECOMES ZERO

FAVORABLE CONDITIONS
      ↓
HORSE HERD BECOMES AVAILABLE AGAIN
```

The implementation must reuse the existing Horse/Cavalry resource pipeline where practical.

The first slice does **not** require animal pathfinding. Deactivation/removal/respawn is an implementation choice to be made after repository inspection.

The key gameplay result is:

```text
climate
→ horse availability
→ cavalry economy
→ regional value
→ player decision
```

---

## 9. Neutral camps and hero progression

The temporary term “creeper” is not canonical. Use **Neutral Camp / Neutral** in technical design until a final lore name is chosen.

Neutral camps create a second route to value besides ordinary resource extraction:

```text
NEUTRAL CAMP
      ↓
COMBAT
      ↓
LOOT
 ┌────┴────┐
resources  future artifact
```

Neutral difficulty can eventually have multiple levels. The first slice may use one level only.

The long-term intended relationship is:

```text
weak hero / army
→ some neutral camps are too dangerous

stronger hero / army
→ higher-level camps become accessible
```

### Minimal hero

A minimal **player hero** is included in Stage 1.5 planning because the artifact mechanic cannot be meaningfully tested without a carrier.

First hero scope:

- reuse `BaseUnit` / Movement / Combat / Order where possible;
- normal movement and combat;
- HP/death;
- existing selection/UI;
- minimal progression hook if required by neutral rewards;
- one artifact slot;
- no full inventory;
- no ability tree;
- no full mana system;
- no hero classes.

AI hero is deferred. This is a scope decision, not a permanent asymmetric rule.

---

## 10. Artifact loop

The first artifact implementation is deliberately minimal:

```text
Neutral encounter / camp
      ↓
Artifact appears as world loot
      ↓
Hero reaches artifact
      ↓
Pickup
      ↓
One simple passive bonus
      ↓
Hero dies
      ↓
Artifact drops
      ↓
Another hero can steal it
```

Use **one artifact type** initially. Do not create Artifact Tier 1/2/3 until the basic loop is proven.

The artifact is a world object, not a normal Wood/Stone/Gold/Horse resource.

---

## 11. Power Sites

The star-marked Power Sites are deliberate future infrastructure anchors.

They are reserved for later:

- magical creatures;
- hero mana replenishment;
- magic infrastructure;
- faction-specific interactions.

No Power Site gameplay is part of the first implementation slice.

The current map concept expects a Power Site to be associated with each major region as a future strategic layer.

---

## 12. Conflict beyond “kill TC”

Stage 1.5 should create reasons to fight that are not limited to immediately attacking the enemy Town Center.

Candidate conflict reasons include:

- contesting a favorable region;
- contesting horse availability;
- raiding exposed workers;
- attacking neutral camps for rewards;
- denying an opponent's migration destination;
- protecting an artifact carrier;
- stealing a dropped artifact;
- defending the economic anchor during migration.

These are **conflict consequences**, not new capture-point modes or new victory conditions.

---

## 13. Strategic decision matrix

The intended player decision set is:

```text
DEVELOP
MIGRATE
DEFEND
RAID
CONTEST
COMMIT
```

These choices must emerge from the systems above. Do not create separate “migrate mode”, “territory mode”, or “raid mode” simply to manufacture variety.

---

## 14. Deferred systems

Until the narrower slices prove a concrete need, keep the following out of implementation:

- AI migration;
- AI hero;
- full Economy 1.5 goal/deficit architecture;
- full hero level/skill progression;
- Artifact tiers;
- terrain/settlement suitability scoring;
- animal pathfinding;
- magic/mana systems;
- Power Site gameplay;
- T2/T3;
- new victory conditions.

Do not start these because they are theoretically useful. Start them only when the accepted gameplay loop demonstrates the need.

---

## 15. Implementation order

The canonical order is defined in `DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`:

```text
A  Climate backend
↓
B  Environment visuals
↓
C  Resource climate pressure
↓
D  Horse response
↓
E  Neutral camps
↓
F  Minimal player hero + artifact
↓
G  Conflict matrix / playtest
```

Each stage is a separate implementation request and requires F5 acceptance.

---

## 16. Design completion state

Q1–Q4 are accepted as the current foundation:

| Question | Status |
|---|---|
| Q1 — Climate regions | **ACCEPTED** |
| Q2 — Scarcity / wrong geography | **ACCEPTED** |
| Q3 — Depletion | **ACCEPTED** |
| Q4 — Mobility / migration | **ACCEPTED** |
| Fixed non-overlapping region model | **ACCEPTED** |
| Three-state climate model | **ACCEPTED** |
| Neutral / hero / artifact vertical slice | **DESIGNED — NOT IMPLEMENTED** |
| Power Sites | **DEFERRED** |

**Next implementation question:** Can the fixed-region climate backend replace the old moving-zone model cleanly without touching unrelated Stage 1 systems?

*Updated 2026-09-11 after map review and multi-model design reconciliation.*
