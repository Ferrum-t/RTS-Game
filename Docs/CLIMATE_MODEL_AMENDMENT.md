# Climate Model Amendment (Stage 1.5)

> **Canonical for match implementation.** Overrides older "moving zones" language in foundation lore docs where they conflict.

## Contract

See `Docs/DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md` and `Docs/STAGE_1_5_GAMEPLAY.md`.

### Rules

1. Geographic regions are **fixed** (geometry does not move).
2. Region boundaries **do not overlap or touch**.
3. Exactly three gameplay climate states: **Cold / Favorable / Dry**.
4. Season changes **state**, not geometry.
5. **Favorable** is the most beneficial general state for an aul.
6. `TRANSITION` is **not** a fourth gameplay state (spring/autumn = timing only).
7. Lore may describe a "living world"; match implementation uses fixed regions + changing climate state.

### Supersedes

Any foundation-lore phrasing such as:

- "The zones move"
- "moving environmental zones"
- "zones migrate across the map"
- TRANSITION as a fourth zone type

in `00_WORLD_FOUNDATION.md`, `01_WORLD_AND_PLANET.md`, `02_GEOGRAPHY_AND_CLIMATE.md`, and related files, when read for **current match implementation scope**.

### Status

- Stage 1: ACCEPTED
- Stage 1.5 design (Q1–Q4): DESIGN ACCEPTED
- Code may still host Zones v1.0 blob prototype until Stage 1.5 implementation

---

## Runtime vs expanded geography

| Layer | Status | Notes |
|-------|--------|--------|
| **Slice A code** | In repo / F5 OK | 4 regions × r=14 — technical prototype only |
| **Expanded Climate Geometry v0.1** | Design signed-off | 8 regions × r=21 — see `EXPANDED_CLIMATE_GEOMETRY_V0_1.md` |
| Port of v0.1 into code | **Not started** | Requires a separate implementation request |

Do not assume the running match uses 8 regions until the port task is completed and F5-accepted.
