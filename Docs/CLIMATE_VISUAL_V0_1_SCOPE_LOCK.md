# Climate Visual v0.1 — SCOPE LOCK

**Status:** LOCKED — implementation only after `Climate Visual v0.1 READY FOR IMPLEMENTATION`  
**Date:** 2026-09-23  
**Product:** Nomad Wars  
**Branch:** `nomads-wars-grok`  
**Prerequisite:** ME-0 ACCEPTED + playtest (pressure not felt without console)  
**Related:** `PLAYTEST_ME0_AND_ROADMAP_NOTES.md`, `EnvironmentZoneService.gd`, `ME0_MIGRATION_INFO_SCOPE_LOCK.md`

---

## Goal

Make home-region climate **legible in the viewport** without relying on the Godot output console.

```text
R0 state + mult always visible on HUD
        +
short feedback on state change
        +
slower season (360s)
        +
stronger R0 disc readability
```

No new economy, migration cost, or Level 2 pressure.

---

## LOCK = V1 + V2 + V3 + V4

| ID | What | Notes |
|----|------|--------|
| **V1** | Home **R0** HUD | Always visible: state `COLD` / `FAVORABLE` / `DRY` + multiplier `×0.5` / `×1.5` (from existing `_MULT`) |
| **V2** | R0 state-change feedback | Short flash / color change on HUD when R0 transitions (hook existing `_emit_home_region_signal` / state change) |
| **V3** | Season duration | `season_duration_sec`: **180 → 360** |
| **V4** | R0 disc readability | Stronger alpha / outline / label emphasis for **R0 only** (existing debug disc path) |

### Data source

Reuse only existing ZoneService APIs: region id `R0`, `get_region_state`, `_MULT`. Do not invent new climate states.

---

## OUT (explicit)

- 12-month calendar / Tree of Life / seasonal SFX
- Climate Level 2 / hard resource blocks
- ME-1 pack cost / forced pack
- Horse mesh hide
- Resources in R2–R7
- Training queue / remote train / food-supply UI
- AI climate brain
- Hero / magic / Power Sites

---

## Implementation path (when READY)

**Expected files:**

1. `Scripts/Systems/EnvironmentZoneService.gd` — default duration 360; R0 disc emphasis (V3, V4)
2. New thin HUD script e.g. `Scripts/UI/ClimateHomeHud.gd` (CanvasLayer) — V1, V2  
   *or* minimal Control attached to existing scene UI root if one is found at implement time

**Do not touch:** EconomicAIController, combat, Barracks, ResourceManager stocks, DeploymentComponent.

---

## F5 acceptance (on PC later)

1. Without opening console: R0 state + mult visible on screen at all times
2. R0 state change → HUD feedback noticeable in combat camera
3. Season feels slower (360s full cycle)
4. R0 disc easier to read than other regions
5. Climate v0.1 horse gate + ME-0 log still work
6. Zero script errors; M18.x / AI unchanged

---

## Roadmap after this slice

```text
Climate Visual v0.1
        ↓
Resources R2–R7
        ↓
Core UX slices (separate LOCKs)
        ↓
Level 2 / 12-month / ME-1 / yurt supply
```

---

## Gate

Say **`Climate Visual v0.1 READY FOR IMPLEMENTATION`** to authorize code.
