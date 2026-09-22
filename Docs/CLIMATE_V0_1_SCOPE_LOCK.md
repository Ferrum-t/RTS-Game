# Climate Pressure v0.1 — SCOPE LOCK

**Status:** LOCKED — implementation authorized only within this file  
**Date:** 2026-09-22  
**Product:** Nomad Wars  
**Branch:** `nomads-wars-grok`  
**Prerequisite:** M18.2 Core Gameplay Audit ACCEPTED  
**Related:** `DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`, `STAGE_1_5_GAMEPLAY.md`, `EnvironmentZoneService.gd`

---

## Hypothesis

Does a soft climate change (harvest flow + horse availability + minimal signal) make the player *consider* stay vs migrate — without forced pack or AI climate brain?

---

## LOCK = C1 + C2 + C3 + C4

| ID | What | Notes |
|----|------|--------|
| **C1** | Keep existing climate backend | 8×r21 Variant B, COLD/FAVORABLE/DRY, 180s, mult 1.5/0.5/0.5, `get_multiplier_at` unchanged |
| **C2** | Horse gate by region state | `FAVORABLE` → available; `COLD`/`DRY` → deactivated (not `queue_free`); restore on FAVORABLE |
| **C3** | Minimal player-facing signal | On home-region (R0 / team-0 TC region) state change: clear log + existing disc/label already update |
| **C4** | F5 matrix | See § F5 |

### OUT (explicit)

- Level 2 extreme winter/summer (resource hard-off, mobility penalty)
- 12-month UI / Tree of Life / SFX
- Pack cost by climate / auto-pack
- AI climate response
- Hero / Power Sites / magic / wells
- Moving geometry / TRANSITION state
- Blocking wood/stone / unit slow / climate damage
- Changing M18.1 balance numbers

---

## Implementation audit (read-only)

### C1 — no structural change

`Scripts/Systems/EnvironmentZoneService.gd` already owns:

- region list + fixed centers
- `get_region_at` / `get_region_state` / `get_multiplier_at`
- `_on_climate_states_changed()` (prints all regions)
- debug discs + Label3D state text

Harvest already multiplies via `HarvestComponent` → `get_multiplier_at`. **Do not fork economy.**

### C2 — Horse gate (narrow)

| Fact | Implication |
|------|-------------|
| `HorseResource` extends `BaseResource` | `harvest()` returns 0 if `resource_amount <= 0`; deplete path `queue_free` — **avoid deplete-to-zero for climate** |
| Climate must be reversible | Prefer `climate_suspended: bool` + store `_climate_cached_amount`; when suspended set amount gate without freeing node |
| Query region | `EnvironmentZoneService.get_region_at(global_position)` + `get_region_state` |
| Who updates? | Option A: ZoneService on `_on_climate_states_changed` scans `group Resource` / HorseResource. Option B: each HorseResource polls. **Prefer A** (one place, matches state-change already) |
| Visual | Optional hide mesh / modulate when suspended — keep minimal |
| NavBake | Node stays registered — no rebake required for suspend |

**Do not** `queue_free()` herds on COLD/DRY.

### C3 — Signal

| Approach | Notes |
|----------|--------|
| Extend `_on_climate_states_changed` | Compare previous vs new state for **R0** (player home) and **R1** (enemy home optional) |
| Log format | e.g. `[CLIMATE] R0 FAVORABLE → COLD  (home region)` |
| Disc/label | Already update every frame when `debug_draw` — sufficient for v0.1 player-facing if debug discs on in play builds; if not, log is minimum |
| No new Control UI | OUT |

### Files expected to touch (when coding)

1. `Scripts/Systems/EnvironmentZoneService.gd` — horse scan + home-region signal in `_on_climate_states_changed`
2. `Scripts/WorldObjects/Resources/HorseResource.gd` — suspend/resume API (or thin methods on BaseResource only if needed)

Avoid: EconomicAIController, Barracks, BaseUnit combat, ResourceManager stocks.

---

## F5 matrix (C4)

1. Match start: R0 state logged; horses in FAVORABLE region harvestable
2. Season advances → R0 flips to COLD or DRY
3. `[CLIMATE]` (or equivalent) home signal printed
4. Harvest in that region shows mult 0.5 (existing)
5. Horse herds in COLD/DRY region: cannot harvest / suspended; **node still in tree**
6. Season returns region to FAVORABLE → horses harvestable again
7. M17–M18.2 systems unchanged (AI attack_at=5, dual barracks, RETALIATE)
8. No script errors; no forced pack

---

## Next step after this doc

`Climate v0.1 READY FOR IMPLEMENTATION` → code only C1–C3 paths above → one F5 → accept or open v0.2 Level 2 discussion.
