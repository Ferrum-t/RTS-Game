# Nomad Wars — Climate, Regions & Migration Pressure Design

**Status:** DESIGN CONTRACT — no implementation is authorized by this file alone  
**Scope:** Stage 1.5 gameplay design  
**Branch:** `nomads-wars-grok`  
**Process:** `Docs/ACCEPTANCE_AND_PROCESS.md` §2, §3, §5  
**Related:** `STAGE_1_5_GAMEPLAY.md`, `CURRENT_STATE.md`, `EXPANDED_CLIMATE_GEOMETRY_V0_1.md`, `nomad_wars_v1_scope_and_architecture.md`, `02_GEOGRAPHY_AND_CLIMATE.md`, `08_MIGRATION_AND_NOMADISM.md`

> This document turns the current map concept and Stage 1.5 discussion into a single design contract. It describes intended gameplay and implementation direction; it does **not** mean any of these systems are implemented.

---

## 1. Core design principle

Nomad Wars should not use moving climate blobs as its core geography model.

Each map contains a set of **fixed geographic regions**. Their boundaries and positions do not move during a match. The seasonal system changes the **current state** of each region.

```text
FIXED REGION
    ↓
CURRENT CLIMATE STATE
    ↓
CURRENT ECOLOGICAL VALUE
    ↓
RESOURCE / HORSE PRESSURE
    ↓
PLAYER DECISION
(stay / develop / contest / raid / migrate)
```

The strategic identity is therefore:

> **The map is geographically stable, but its usefulness changes over time.**

This is the canonical Stage 1.5 interpretation of the "living geography" concept.

Older worldbuilding text that describes favorable areas as physically moving is superseded for the **current gameplay implementation model**. The worldbuilding idea remains valid at the conceptual level: environmental conditions change where life is most favorable.

---

## 2. Region model

### 2.1 Fixed geometry

A `ClimateRegion` is a permanent area of the current map.

Conceptually it contains:

```text
ClimateRegion
├── fixed position / boundary
├── fixed size / shape
├── seasonal phase offset
├── resources
├── horse availability
├── Power Site
├── neutral threat(s)
└── settlement capacity / space (map-design concept)
```

For the current prototype the region is represented as a circle. The geometry may later become polygonal or use another map mask, but **the defining rule is fixed geography, not moving geometry**.

### 2.2 Regions do not overlap

The current map concept intentionally uses **non-overlapping region boundaries**. Neighboring regions may be close to each other, but one region does not cover another region's area.

Therefore there is **no climate-overlap priority system** in the new model.

Do not carry the old "COLD > DRY > FAVORABLE" overlap rule into this design. That rule belonged to the earlier moving/overlapping implementation model and is not needed when regions are disjoint.

Neutral land between regions is outside the main ClimateRegion set and is not itself a climate state.

### 2.3 Region state count

Every region has exactly **three gameplay-relevant climate states**:

| Working name | Visual concept | Gameplay meaning |
|---|---|---|
| `COLD` | blue / winter | frost / low biological productivity |
| `FAVORABLE` | green / zone of life | most favorable state for settlement and economic development |
| `DRY` | orange / summer heat | heat / dryness / reduced ecological productivity |

`TRANSITION` is **not** a fourth gameplay state in the current design.

Spring/autumn can be represented by the season clock moving a region from one state to another. A separate transition state may be introduced later only if playtesting proves it necessary.

The names above are **technical working names**, not final lore terminology.

### 2.4 Naming direction

The setting is fictional and should not become a direct historical reproduction of a Turkic world.

World terminology should eventually be:

```text
Turkic linguistic / cultural inspiration
        +
fictional worldbuilding
        +
selected influences from other cultures
        ↓
unique Nomad Wars terminology
```

Do not force Tolkien-like naming conventions. Final in-world names for the three states, neutral factions, regions, and related objects are deferred until the mechanics are stable.

---

## 3. Seasonal state model

A global seasonal clock is the intended backend direction.

Conceptually:

```text
season_progress ∈ [0, 1)
```

Each region has a `phase_offset` so not all regions must enter the same state at the same time.

```text
state = lookup(season_progress + phase_offset)
```

The exact cycle timing, thresholds, easing, and phase values are **design parameters, not yet balance constants**.

The key constraint is that the region geometry remains fixed while its state changes.

### Required future test

A first climate implementation slice must prove:

1. region position/boundary remains fixed;
2. season progress advances deterministically;
3. different phase offsets can produce different current states;
4. debug visualization changes state without moving the region;
5. no resource, AI, hero, or migration gameplay is wired in during the climate-backend slice.

---

## 4. What a region represents for the player

A region is not only a colored circle. It is a potential **ecological and economic package for an aul**.

The current map concept places inside a region a deliberately mixed set of things needed for development, such as:

- trees / wood;
- stone;
- gold;
- horse availability;
- a Power Site;
- neutral threats;
- physical space for an aul.

The exact distribution and balance are map-design concerns, but the design principle is important:

> **A region should normally contain a coherent set of resources and opportunities that can support an aul.**

A large region may be able to contain more than one aul. The current concept allows a large region to support roughly two settlements as a future multiplayer/map-design possibility. Exact settlement capacity is a future map parameter, not a hard implementation rule for Stage 1.5.

---

## 5. Region ≠ working region

A geographic region, its current climate state, and the player's useful working region are separate concepts.

```text
GEOGRAPHIC REGION
        +
CLIMATE STATE
        +
RESOURCE MIX / STOCK
        +
HORSE AVAILABILITY
        +
DISTANCE / LOGISTICS
        +
DEFENSE
        +
OPPONENT PRESSURE
        +
SETTLEMENT CAPACITY / POSITION
        ↓
CURRENT WORKING REGION
```

A green/FAVORABLE region is generally the most attractive climate state, but **green does not automatically mean "build here" or "win here"**.

Likewise, a COLD or DRY region can still be strategically valuable because of a resource mix, position, defensive value, or access to a contested objective.

Terrain/buildability suitability is a separate future layer and is intentionally **not** part of the current Stage 1.5 implementation sequence.

---

## 6. Ecological pressure and migration

The climate system exists to create a meaningful change in regional value, not merely a color animation.

The desired causal chain is:

```text
SEASON CHANGES
      ↓
REGION STATES CHANGE
      ↓
ECOLOGICAL / ECONOMIC VALUE CHANGES
      ↓
HORSE / RESOURCE AVAILABILITY CHANGES
      ↓
CURRENT AUL BECOMES MORE OR LESS ATTRACTIVE
      ↓
PLAYER EVALUATES ALTERNATIVES
      ↓
STAY / RETARGET / CONTEST / RAID / MIGRATE
```

Migration must remain a **strategic choice**, not a timer fired by the climate system.

Existing Stage 1 mobile pack/unpack mechanics are the means of changing the settlement anchor; they are not themselves the reason why the player migrates.

### Migration principles inherited from Stage 1.5 Q2–Q4

- local depletion is survivable;
- depletion is not a migration clock;
- remote harvesting remains possible but carries distance/logistics cost;
- wrong resource mix can be as important as low stock;
- migration becomes attractive when a persistent structural mismatch makes the current anchor inefficient;
- migration can be wrong, mistimed, or dangerous;
- migration is never mandatory for victory.

---

## 7. Resource response

The current design does **not** turn climate into a hard build ban.

The intended first gameplay influence is a **soft change in regional value / extraction efficiency** applied to the existing resource system.

The exact multipliers are not fixed in this document.

The implementation should preserve the existing resource and harvest architecture rather than create a parallel climate economy.

Important separation:

```text
RESOURCE STOCK = how much resource remains
CLIMATE FLOW = how favorable current conditions are
DISTANCE = logistics cost
OPPONENT = contest pressure
```

Do not collapse these into a single "region score" meter.

---

## 8. Horses: first visible gameplay response

Horses are a particularly clear test of whether climate matters.

Intended behavior:

```text
Region becomes unsuitable for horses
        ↓
horse availability in that region becomes zero / unavailable

Region becomes FAVORABLE
        ↓
horse herd becomes available again according to its spawn/cap rules
```

The behavior should reuse the existing Horse/Cavalry resource pipeline.

The design requirement is **behavioral**, not a locked implementation detail: the future implementation may deactivate, remove, or respawn a herd depending on what is safest for the current resource architecture.

Do not introduce animal pathfinding merely to make horses react to climate. Despawn/deactivate/respawn is sufficient for the first slice.

### Horse acceptance target

- unsuitable-region herd becomes unavailable;
- favorable-region herd becomes available within defined caps/rules;
- no duplicate or unbounded horse generation;
- cavalry training continues to consume horses through the existing pipeline;
- no horse-specific navigation system is introduced.

---

## 9. Neutral camps

The temporary term **"creepers" is not canonical**. Use `Neutral Camp` / `Neutral` as the technical term until lore naming is finalized.

Neutral camps occupy parts of the map, including neutral territory and/or suitable parts of regions.

They provide a second value stream besides ordinary resource extraction:

```text
NEUTRAL CAMP
     ↓
COMBAT / RAID
     ↓
LOOT
├── resources
└── future artifact rewards
```

Neutral camps may eventually have multiple difficulty levels. The first implementation slice may use one tier only.

Future tiers can create a natural risk ladder:

```text
weak army / hero
→ some camps are unsafe or uneconomical

stronger army / hero
→ higher-tier camps become accessible
```

The system should not require a full faction-simulation AI for the neutral camps in its first slice.

---

## 10. Minimal Hero

A minimal hero is part of the Stage 1.5 design because the artifact mechanic cannot be meaningfully tested without a unit that can carry and lose an artifact.

### First hero slice

Reuse the existing unit architecture wherever practical:

```text
BaseUnit
├── Movement
├── Combat
├── Order
└── minimal Hero data
```

Required scope:

- ordinary movement;
- ordinary attack;
- HP / death;
- hero selection through existing selection/UI systems;
- minimal progression hook if needed by the neutral-camp loop;
- exactly one carried-artifact slot;
- no full inventory system;
- no ability tree;
- no mana spellcasting system yet;
- no hero classes yet.

### AI hero

The first hero slice is **player-only**.

This is a scope decision, not a permanent asymmetry rule. A future AI hero should use the same hero mechanics available to the player unless a later design decision explicitly changes that rule.

This follows the same staged-scope precedent as "no AI migration" in the earlier stages: do not build the AI decision system before the player-facing mechanic has proven necessary.

---

## 11. Artifact

The first artifact implementation should be intentionally small.

### Required loop

```text
Neutral encounter / camp
        ↓
Artifact becomes available in world loot
        ↓
Hero physically reaches artifact
        ↓
Hero picks it up
        ↓
Artifact grants one simple passive bonus
        ↓
Hero dies
        ↓
Artifact drops at death position
        ↓
Another hero may steal it
```

Use **one artifact type** for the first vertical slice.

Do not introduce Artifact Tier 1/2/3 until the basic drop → pickup → bonus → death → steal loop has been validated.

The artifact is not treated as a normal Wood/Stone/Gold/Horse resource. It is a separate world object.

The implementation should reuse the existing order/target abstraction if the repository confirms that `Order` already supports a generic target without requiring an architectural rewrite. Verify repository facts before coding.

### Balance principle

The hero should be valuable, but the hero must not replace the RTS army as the primary military system. Do not lock a numeric hero-to-soldier value before the first playable test.

---

## 12. Power Sites

The star-marked **Power Site** on the map is a deliberate future gameplay anchor.

For the current design it is a reserved world object, not an implementation task.

Future uses may include:

- magical entities;
- hero mana replenishment;
- magical infrastructure;
- faction-specific interactions.

None of these systems are part of the first climate/horse/neutral/hero slice.

The important design rule is:

> **Each major region can contain a reserved Power Site as part of the region's future strategic infrastructure.**

---

## 13. Stage 1.5 implementation sequence

This is the canonical staged order. One stage = one narrow implementation request + F5, according to `ACCEPTANCE_AND_PROCESS.md` §3.

### A — Climate backend

Replace the old moving-zone behavior with fixed regions + seasonal state lookup.

Scope:

- fixed geometry;
- season clock;
- phase offsets;
- exactly three states (`COLD`, `FAVORABLE`, `DRY`);
- debug visualization;
- no resource/AI/hero coupling.

### B — Environment visuals

Map/terrain presentation follows the current regional state.

Scope only:

- snow/cold visual;
- green/favorable visual;
- dry/heat visual.

No economic effect yet.

### C — Resource climate pressure

Connect the existing resource harvest path to the regional climate modifier.

Scope only:

- existing resource nodes;
- soft extraction/value effect;
- no AI migration;
- no new economy framework.

### D — Horses

Make horse availability react to regional climate state using the existing horse/cavalry pipeline.

### E — Neutral camps

Introduce neutral camps with combat and basic resource loot.

First slice can use one difficulty tier and existing combat/loot architecture.

### F — Minimal player hero + one artifact

Introduce the smallest hero needed to validate:

```text
hero → artifact pickup → passive bonus → death drop → steal
```

Do not combine this slice with AI hero behavior or a full progression system.

### G — Conflict matrix

After A–F are proven, formalize and test the strategic choices:

```text
DEVELOP
MIGRATE
DEFEND
RAID
CONTEST
COMMIT
```

The matrix should describe actual player-facing trade-offs already present in the prototype, not invent abstract modes.

---

## 14. Explicitly deferred

The following are deliberately **not** part of the current implementation sequence:

- moving climate geometry;
- overlapping-zone priority logic;
- mandatory migration;
- hard climate build bans;
- terrain/settlement-suitability scoring system;
- horse pathfinding / simulated animal migration;
- AI migration;
- AI hero;
- full hero skill/level system;
- Artifact Tier 1/2/3 progression;
- full magic system;
- mana system;
- Power Site gameplay;
- Economy 1.5 goal/deficit architecture;
- T2/T3 content;
- new victory conditions.

These can be reconsidered only after evidence from the narrower slices.

---

## 15. Repository verification rule

Before implementation, any statement such as "already exists", "reuse X", or "X does not need changes" must be checked against the actual repository on the target branch.

In particular, verify before coding:

- current `EnvironmentZoneService` behavior;
- current Horse resource implementation;
- `HarvestComponent` handling of vanished resources;
- current `Order` target abstraction;
- current loot implementation;
- TeamRules / neutral-team behavior;
- current hero/selection infrastructure if any.

Chat history and prior model claims are not repository facts.

---

## 16. Definition of design completion

This document is considered **design-complete for the next implementation step** when:

1. the three-state fixed-region model is understood and consistent;
2. the causal chain climate → regional value → resource/horse pressure → player choice is preserved;
3. neutral camps, minimal hero, artifact, and Power Site roles are separated by scope;
4. no hidden overlap/moving-zone assumptions remain;
5. the next implementation slice is a single narrow A-stage request.

Design completion does **not** mean any of the mechanics are accepted in code.

---

## Appendix — Expanded Climate Geometry v0.1

Design sign-off for the first **8-region / radius 21** layout (Variant B) lives in:

`Docs/EXPANDED_CLIMATE_GEOMETRY_V0_1.md`

That document is geography-only. It does not by itself accept implementation, change Slice A runtime prototype (4×r14), or authorize Slice B visuals.

---

*Created 2026-09-11 from the map concept and multi-model design review. This is a design contract, not an implementation commit.*
