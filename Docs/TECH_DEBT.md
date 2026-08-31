# Technical Debt — Nomad Wars

**Branch:** `nomads-wars-grok`  
**Last updated:** 2026-08-31  
**Related:** `Docs/TODO.md`, `Docs/CURRENT_STATE.md`, `Docs/GROK_WORKLOG.md`, GPT audit vs Stage 1 report

Durable list of **real gaps** and **accepted Stage 1 limits**. Prefer this file for “why / risk / fix sketch”; `TODO.md` for the short checklist; `CURRENT_STATE.md` for the live system table.

---

## TD-01 — AI construction does not share player position / collision validation

| Field | Value |
|--------|--------|
| **Severity** | Real Stage 1 architectural debt (not polish) |
| **Status** | Open |
| **Area** | Construction / EconomicAI / Ghost |
| **Discovered** | 2026-08-31 (GPT code audit vs report claim) |

### Claim that was wrong

Report said: `place_building_for_team(...)` — same cost / position / ownership checks as the player.

**Partially true for cost + team ownership; false for position validity.**

### Player path

```
Ghost (current_ghost)
  → confirm_build()
  → if not current_ghost.can_build: return
  → place_building_for_team(...)
  → Building
```

### AI path (current)

```
calculated position (tc + barracks_offset)
  → place_building_for_team  # cost + scene + team, NOT can_build
  → Building
```

### Why Stage 1 still works

Hand-tuned `barracks_offset`; open map; one AI Barracks.

### Fix sketch

Shared `ConstructionManager.can_place(...)` used by Ghost and AI; AI samples sites; `place_building_for_team` remains commit-only.

### Code anchors

- `EconomicAIController._try_build_barracks`
- Ghost `can_build` → `place_building_for_team`

---

## TD-02 — Primitive AI harvest heuristic (stone floor, not demand-driven)

| Field | Value |
|--------|--------|
| **Severity** | Design / Stage 1.5 — **not a code bug** |
| **Status** | Open (accepted Stage 1 limitation) |
| **Area** | EconomicAIController worker assignment |
| **Discovered** | 2026-08-31 (F5 log + GPT audit) |

### Symptom

After Barracks (100W+50S): `wood=0`, stone high → spam `not enough wood for Soldier`.

### Heuristic

```
Stone < 50 → stone
Stone >= 50 → wood
```

No PRODUCTION_GOAL → RESOURCE_REQUIREMENT chain.

### Next product step

**AI Economy 1.5** (before T2):

```
BUILDING_GOAL → PRODUCTION_GOAL → RESOURCE_REQUIREMENT → WORKER_ASSIGNMENT
```

### Code anchors

- `EconomicAIController._pick_resource_for_worker`

---

## TD-03 — Residual AI economy after Town Center death

| Field | Value |
|--------|--------|
| **Severity** | Design / victory-rules — **do not fix in Stage 1** |
| **Status** | Open (accepted Stage 1 behavior) |
| **Area** | Match end / drop-off / production without TC |
| **Discovered** | 2026-08-31 (F5 log + GPT audit) |

### Log

```
EnemyTownCenter destroyed
AIWorker_0 — no own-team Town Center found, keeping inventory
```

Workers/Barracks/soldiers can theoretically continue; match currently ends on TC destroy so Stage 1 is fine. Revisit with richer victory conditions.

---

## TD-04 — TeamRules hardcodes `UNIT_STATE_DEAD := 6`

| Field | Value |
|--------|--------|
| **Severity** | Fragile coupling — **not a Stage 1 blocker** |
| **Status** | Open |
| **Area** | TeamRules / BaseUnit.UnitState |
| **Discovered** | 2026-08-31 (GPT audit) |

### Problem

`TeamRules` uses a numeric constant instead of `BaseUnit.UnitState.DEAD`:

```gdscript
const UNIT_STATE_DEAD := 6
```

Current enum order (must stay aligned):

```
IDLE=0, MOVING=1, HARVESTING=2, RETURNING=3, BUILDING=4, ATTACKING=5, DEAD=6
```

If enum order changes, TeamRules fails **silently** (wrong live/dead checks).

### Fix when convenient

Reference `BaseUnit.UnitState.DEAD` (or a shared autoload enum) — avoid magic int. Only needed if TeamRules cannot depend on BaseUnit class_name for parse reasons; then document a single source of truth.

### Code anchors

- `TeamRules` (const + call sites)
- `BaseUnit.UnitState`

---

## Deferred by design (not “broken”)

### Zones — visual / query only (Stage B harvest not wired)

`EnvironmentZoneService` already has:

- Moving blobs + bounce
- Visualization
- `get_multiplier_at(world_pos)` with FAVORABLE=1.5, TRANSITION=1.0, DRY=0.5, COLD=0.5

**Not connected:** harvest rate, AI decisions, migration pressure.

```
zone motion          YES
zone visuals         YES
zone detection       YES
economic influence   NO
migration influence  NO
```

**Decision:** do **not** suddenly wire zones into AI or harvest as a drive-by. Stage B / Zones v1.1 is a deliberate product step. Matches existing zone docs.

### Navigation scale — confirmed healthy

- `MAP_HALF = 100` → nav ~200×200
- Buildings register footprints; rebake on place/destroy; `bake_id` increments

Report claim “rebake on placement/destruction” is **true**. Not debt.

### Door / Rally on BaseBuilding — confirmed healthy

```
BaseBuilding
 ├── get_door_position()
 ├── get_rally_point()
 ├── next_rally_destination()
 ├── set_rally_point()
 ├── set_building_selected()
 ├── BuildingSelectRing
 └── RallyFlag
```

Barracks / TownCenter only:

```gdscript
var door := get_door_position()
var dest := next_rally_destination()
bu.replace_order_move(dest)
```

Selection ring unified on BaseBuilding (duplicate removed from MobileBuilding). Architecture accepted.

---

## Also tracked in `Docs/TODO.md` (older bullets)

- EnemySpawner config single source (MatchManager overrides)
- Staggered Nav Updates (dual economy)
- Aggro leashing, data-driven stats, multi-select buildings, MOBILE collision

---

## Audit index (GPT 2026-08-31)

| # | Topic | Tracking |
|---|--------|----------|
| 1 | Attack spam every AI tick | **Fixed** in code |
| 2 | AI placement ≠ player `can_build` | **TD-01** |
| 3 | Stone/wood heuristic / Economy 1.5 | **TD-02** |
| 4 | Residual AI after TC death | **TD-03** |
| 5 | Zones no economic effect | Deferred by design (above) |
| 6 | Nav MAP_HALF + rebake | Confirmed OK |
| 7 | Door/rally on BaseBuilding | Confirmed OK |
| 8 | TeamRules DEAD = 6 | **TD-04** |
| — | CURRENT_STATE lagged Stage 1 | **Synced** 2026-08-31 |
