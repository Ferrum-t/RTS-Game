# Technical Debt — Nomad Wars

**Branch:** `nomads-wars-grok`  
**Last updated:** 2026-08-31  
**Related:** `Docs/TODO.md`, `Docs/GROK_WORKLOG.md`, GPT audit vs Stage 1 report

This file is the durable list of **real architectural gaps** (not cosmetics). Revisit before claiming “AI uses the same placement pipeline as the player” or expanding AI construction / economy.

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

`can_build` encodes collision / footprint / “legal cell” rules the player must pass before spend+spawn.

### AI path (current)

```gdscript
# EconomicAIController._try_build_barracks
var pos: Vector3 = tc.global_position + barracks_offset
cm.place_building_for_team(_barracks_data, pos, team_id)
```

```
calculated position (hardcoded offset)
  → place_building_for_team  # cost + scene + team, NOT can_build
  → Building
```

`place_building_for_team()` checks affordability and instantiates; it does **not** run the same `can_build` / collision / footprint admissibility as the ghost.

### Why it still “works” in Stage 1

- `barracks_offset` is hand-tuned relative to Enemy TC (`Vector3(4, 0, 3)` by default).
- Map is open; one Barracks per AI side; no dense player walls around enemy TC yet.

### Risk when this bites

- AI Barracks on top of resource node / nav hole / another building.
- Second Barracks or Watchtower placement without a smarter site picker.
- Any future “AI expands base” feature inherits a lying shared-pipeline assumption.

### Intended fix (when we pick this up)

1. Extract a **shared placement query** used by both Ghost and AI, e.g.  
   `ConstructionManager.can_place(building_data, world_pos, team_id) -> bool`  
   (or reuse ghost validation without requiring a visible ghost node).
2. AI: sample candidate positions (offset ring around TC / existing barracks) until `can_place` succeeds, or fail soft + log `[AI_ECO] Barracks site rejected`.
3. Keep `place_building_for_team` as the single **commit** path (spend + instance + register) after validation.
4. Update report / CURRENT_STATE: “shared commit path; shared validation after TD-01”.

### Out of scope for the fix

- Full RTS build AI (wall-ins, min-distance to enemy, etc.).
- Changing player ghost UX.

### Code anchors

- `Scripts/AI/EconomicAIController.gd` → `_try_build_barracks`
- Player confirm path → ghost `can_build` then `ConstructionManager.place_building_for_team`
- `ConstructionManager` (place + any existing validation helpers)

---

## TD-02 — Primitive AI harvest heuristic (stone floor, not demand-driven)

| Field | Value |
|--------|--------|
| **Severity** | Design / Stage 1.5 — **not a code bug** |
| **Status** | Open (accepted Stage 1 limitation) |
| **Area** | EconomicAIController worker assignment |
| **Discovered** | 2026-08-31 (F5 log + GPT audit) |

### What the log shows

After Barracks completes:

```
wood=100 stone=450
  → Barracks cost 100W + 50S
wood=0   stone=400
```

Then repeatedly:

```
Barracks: not enough wood for Soldier (need 80) team=1
```

Wood recovers only gradually while stone stock is already huge.

### Current algorithm (implementation is correct relative to itself)

In `EconomicAIController._pick_resource_for_worker`:

```
Stone stock < 50  → prefer stone nodes
Stone stock >= 50 → prefer non-stone (wood path)
```

Workers are **not** told “next production needs 80 wood”. They only see a static stone floor.

So after a big stone buffer exists, assignment *should* go to wood — but:

1. Barracks just drained **all** wood in one spend.
2. Workers may still be mid-trip on stone (orders not interrupted).
3. There is no **goal stack** that says: production target = Soldier → deficit = wood → assign N workers to wood until `can_afford(Soldier)`.

Result: idle decision layer keeps trying `try_train_soldier` every tick while economy is wood-starved; looks broken in the log, but matches the heuristic.

### Verdict

- **Not** a bug in spend/train/team stockpiles.
- **Is** too primitive for a convincing opponent once Barracks exists.
- Next product step should be **AI Economy 1.5**, **not T2 content**.

### Target model (Economy 1.5)

```
BUILDING_GOAL          e.g. ensure Barracks exists
    ↓
PRODUCTION_GOAL        e.g. soldiers until attack_threshold
    ↓
RESOURCE_REQUIREMENT   e.g. Soldier cost → wood deficit 80
    ↓
WORKER_ASSIGNMENT      assign idle (and optionally reassign) to cover deficit
```

Replace:

```
stone < 50 ? stone : wood
```

with demand derived from the active goal (train Worker / train Soldier / save for Barracks / maintain buffer).

### Minimal incremental options (if we patch before full 1.5)

1. After Barracks exists and `wood < soldier_cost`: force all idle workers to wood (ignore stone floor).
2. Soft reassign: if wood deficit and worker is harvesting stone with bag empty, cancel → wood.
3. Log once: `[AI_ECO] wood deficit for Soldier need=80 have=…` to separate “trying” from spam.

Full goal stack is preferred long-term so Horses / multi-building costs don’t need special cases forever.

### Code anchors

- `Scripts/AI/EconomicAIController.gd` → `_pick_resource_for_worker`, `_assign_idle_workers`, `_think` train/build order
- Soldier / Barracks costs in building & unit data / try_train_* 

### Explicit non-goals for this TD

- Player economy changes
- T2 units/buildings
- Perfect WC-level build orders

---

## TD-03 — (reserved)

Further GPT/Stage 1 audit items → TD-03+

---

## Also tracked in `Docs/TODO.md` (older bullets)

- EnemySpawner config single source (MatchManager overrides)
- Staggered Nav Updates (dual economy)
- Aggro leashing, data-driven stats, multi-select buildings, MOBILE collision

Prefer **this file** for detailed “why / risk / fix sketch”; keep `TODO.md` as the short checklist.
