# Technical Debt — Nomad Wars

**Branch:** `nomads-wars-grok`  
**Last updated:** 2026-09-19  
**Related:** `Docs/TODO.md`, `Docs/CURRENT_STATE.md`, `Docs/GROK_WORKLOG.md`

Durable list of **real gaps** and **accepted limits**. Prefer this file for “why / risk / fix sketch”; `TODO.md` for the checklist; `CURRENT_STATE.md` for the live system table.

---

## TD-01 — AI construction does not share player position / collision validation

| Field | Value |
|--------|--------|
| **Severity** | Real architectural debt |
| **Status** | Open |
| **Area** | Construction / EconomicAI / Ghost |

Player path uses Ghost `can_build` before `place_building_for_team`. AI path calls `place_building_for_team` with a calculated offset only (cost + team, not placement validity).

Stage 1 still works: hand-tuned `barracks_offset`, open map, one Barracks. M17.0 2nd TC will use the same instant path — keep offset conservative; shared `can_place` remains later work.

**Code:** `EconomicAIController._try_build_barracks`

---

## TD-02 — Primitive AI harvest heuristic

| Field | Value |
|--------|--------|
| **Severity** | Design limit |
| **Status** | Open (accepted until Economy 1.5) |

Dual `stock_floor` + alternate wood/stone. No BUILDING_GOAL → PRODUCTION_GOAL chain. Not a code bug.

**Code:** `EconomicAIController._pick_resource_for_worker`

---

## TD-03 — Residual AI economy after Town Center death

| Field | Value |
|--------|--------|
| **Severity** | Design / victory rules |
| **Status** | Open (accepted while win = destroy TC) |

Workers may keep inventory with no drop-off. Match ends on TC destroy in Stage 1. M17.0 adds a second TC — residual behavior after **both** TCs die still OK under current win rule.

---

## TD-04 — TeamRules hardcodes DEAD ordinal

| Field | Value |
|--------|--------|
| **Severity** | Fragile coupling |
| **Status** | Open — **verify after M12.1** |

Historically `UNIT_STATE_DEAD := 6`. M12 inserted `REPAIRING` before `ATTACKING`; commit `M12.1` adjusted ordinal to **7**. Confirm `TeamRules` const matches current `BaseUnit.UnitState.DEAD` or switch to enum reference.

**Code:** `TeamRules`, `BaseUnit.UnitState`

---

## Deferred by design (not broken)

### Climate / zones economic influence

Backend geometry and seasonal state exist (Slice A + 8×r21 port + Seasonal Front v0). Soft harvest pressure, AI migration, and full Stage 1.5 B–G are **parked** — not drive-by wiring. See `CURRENT_STATE.md`.

### Navigation / door / rally

MAP_HALF=100 + rebake and BaseBuilding door/rally architecture accepted (2026-08-31 audit).

---

## Also tracked

EnemySpawner config single source · staggered nav · aggro leashing · data-driven stats · multi-select buildings · MOBILE collision polish
