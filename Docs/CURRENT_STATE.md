# CURRENT STATE

**Gameplay scope:** [`nomad_wars_v1_scope_and_architecture.md`](nomad_wars_v1_scope_and_architecture.md)  
**Vision:** [`12_PROGRESSION_AND_TIER_SYSTEM.md`](12_PROGRESSION_AND_TIER_SYSTEM.md)  
**Stage 1.5 design contract:** [`DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`](DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md)  
**Stage 1.5 gameplay questions:** [`STAGE_1_5_GAMEPLAY.md`](STAGE_1_5_GAMEPLAY.md)  
**Lore:** [`02_GEOGRAPHY_AND_CLIMATE.md`](02_GEOGRAPHY_AND_CLIMATE.md), [`08_MIGRATION_AND_NOMADISM.md`](08_MIGRATION_AND_NOMADISM.md)  
**Tech debt:** [`TECH_DEBT.md`](TECH_DEBT.md)  
**Process:** [`ACCEPTANCE_AND_PROCESS.md`](ACCEPTANCE_AND_PROCESS.md)

**Branch:** `nomads-wars-grok`

---

## Stage 1 — FORMAL SIGN-OFF

| Field | Value |
|--------|--------|
| **Status** | **ACCEPTED** |
| **Date** | 2026-09-01 |
| **Evidence** | Multiple F5 full matches (VICTORY / DEFEAT); post-commit logs for attack-once and dual-floor |
| **Scope** | T1 economic AI opponent, shared production/combat, no AI migration, no T2 |

### Accepted under Stage 1

- Core RTS loop (select, harvest, build, train, fight)
- Per-team stockpiles
- AI: workers → Barracks → soldiers → attack threshold → combat → match end
- Attack issue once + reinforcements
- Harvest dual stock-floor (`stock_floor=100`)
- Door / rally / flag / building select ring
- Building HP / visual states / loot on destroy
- Mobile buildings (pack/move/unpack)
- Navigation ~200×200 (`MAP_HALF=100`), footprint rebake
- Zones v1.0: existing motion/visual prototype + `get_multiplier_at`; **new Stage 1.5 design supersedes the moving-zone behavior as the target model**

### Explicitly out of Stage 1

| Item | Note |
|------|------|
| AI Economy 1.5 (goal→deficit→assign) | Deferred unless a later F5 proves need |
| T2 / T3 | Not started |
| Full Heroes | Not started |
| AI migration | Not Stage 1 |
| Zone → harvest / AI | Not wired |
| TD-01 shared `can_place` | Later |
| TD-03 residual AI after TC | OK while win = destroy TC |
| TD-04 TeamRules `DEAD := 6` | Later |

**Do not start Economy 1.5 or T2** unless a new F5 or Stage 1.5 design/implementation proves a concrete need.

---

## Stage 1.5 — CURRENT DESIGN PHASE

**Status:** **DESIGN ACTIVE / IMPLEMENTATION NOT YET ACCEPTED**

Canonical contract: `DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`.

### Accepted design direction

- Climate regions are **fixed geographic areas**.
- Region boundaries **do not overlap** in the current map model.
- Each region has exactly three gameplay states: `COLD`, `FAVORABLE`, `DRY`.
- `FAVORABLE` is the most advantageous ecological state for settlement/economic development.
- Seasonal change modifies state; it does not move region geometry.
- Spring/autumn are currently treated as seasonal transition timing, not a fourth gameplay state.
- Each region is designed as a potential ecological/economic package for an aul: Wood, Stone, Gold, Horses, Power Site, neutral threat and settlement space as appropriate to the map.
- A large region may support multiple auls as a future map/multiplayer design possibility; exact capacity is not fixed.
- Horses are a first clear gameplay response to climate.
- Neutral Camps replace the temporary "creeper" terminology in design documents until lore naming is finalized.
- A minimal **player hero** is planned for Stage 1.5 because the artifact carrier/drop/steal loop cannot be validated without one.
- First artifact slice = one artifact type, one simple passive bonus; no artifact tiers yet.
- Power Sites are future reserved infrastructure for magic/mana systems, not current implementation.

### Stage 1.5 implementation order

1. **A — Climate backend:** fixed regions + seasonal state lookup.
2. **B — Environment visuals:** state presentation.
3. **C — Resource climate pressure:** soft effect on existing resource extraction.
4. **D — Horses:** climate-dependent availability using existing Horse/Cavalry pipeline.
5. **E — Neutral camps:** combat + basic loot.
6. **F — Minimal player hero + one artifact:** pickup → bonus → death drop → steal.
7. **G — Conflict matrix:** develop / migrate / defend / raid / contest / commit.

Each step requires its own explicit implementation request and F5 acceptance. No Stage 1.5 mechanic is accepted merely because it is documented.

### Deferred

- AI migration
- AI hero
- full hero progression
- artifact tiers
- terrain/settlement suitability scoring
- animal pathfinding
- magic / mana / Power Site gameplay
- Economy 1.5 unless evidence requires it
- T2/T3
- new victory conditions

---

## Balance snapshot (canonical — repo fact, not chat-only)

Values from F5 / code exports on `nomads-wars-grok` as of 2026-09-01. Update this table in the **same session** when balance changes (`ACCEPTANCE_AND_PROCESS.md` §5).

### Map / bases

| Key | Value |
|-----|--------|
| Player TC | `(28.0, 0.0, -22.0)` |
| Enemy TC | `(-28.0, 0.0, 28.0)` |
| TC distance | **~75.1** |
| Nav `MAP_HALF` | **100** (playable ~200×200) |
| AI Barracks default offset | `tc + (4, 0, 3)` → e.g. `(-24, 0, 31)` |

### Resource nodes (starting amounts)

| Node type | Amount |
|-----------|--------|
| Tree / EnemyTree | **2500** |
| Stone / EnemyStone | **2500** |
| HorseHerd / EnemyHorseHerd | **1000** |

### AI controller (`EconomicAIController`)

| Export | Value |
|--------|--------|
| `desired_worker_count` | **4** |
| `attack_threshold` | **3** |
| `decision_interval` | **1.5 s** |
| `stock_floor` | **100** (wood & stone dual check + alternate) |
| `barracks_offset` | `(4, 0, 3)` |

### Unit move speeds

| Unit | `move_speed` |
|------|--------------:|
| Base / Worker default | **2.4** |
| Soldier | **2.7** |
| Cavalry | **3.9** |
| SiegeUnit | **1.8** |

### Training / building costs

| Item | Cost |
|------|------|
| Worker | 50 Wood (~3 s) |
| Soldier | 80 Wood |
| Cavalry | 100 Wood + 1 Horse |
| Siege | 150 Wood + 50 Stone |
| Barracks | 100 Wood + 50 Stone |
| Watchtower | 40 Wood + 20 Stone |

### Rally defaults (`BaseBuilding`)

| Key | Value |
|-----|--------|
| `spawn_offset` (door) | ~(3.5, 0, 0) |
| `default_rally_offset` | **(12, 0, 0)** |
| Rally grid | 4 cols × spacing **2.5** |

---

## Next action

1. ~~Formal Stage 1 sign-off~~ **done**
2. ~~Balance snapshot in repo~~ **done**
3. ~~Open Stage 1.5 design~~ **done / expanded**
4. **Next:** review/accept Stage 1.5 design contract, then implement **A — Climate backend** as a separate narrow task
5. Economy 1.5 / T2 / AI migration / hero AI only if later evidence explicitly demands them
