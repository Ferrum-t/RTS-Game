# Technical Debt — Nomad Wars

**Branch:** `nomads-wars-grok`  
**Last updated:** 2026-08-31  
**Related:** `Docs/TODO.md`, `Docs/GROK_WORKLOG.md`, GPT audit vs Stage 1 report

This file is the durable list of **real architectural gaps** (not cosmetics). Revisit before claiming “AI uses the same placement pipeline as the player” or expanding AI construction.

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

## TD-02 — (reserved)

Further GPT/Stage 1 audit items can be appended here as TD-02, TD-03, …

---

## Also tracked in `Docs/TODO.md` (older bullets)

- EnemySpawner config single source (MatchManager overrides)
- Staggered Nav Updates (dual economy)
- Aggro leashing, data-driven stats, multi-select buildings, MOBILE collision

Prefer **this file** for detailed “why / risk / fix sketch”; keep `TODO.md` as the short checklist.
