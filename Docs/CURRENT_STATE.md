# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-22

---

## Active sprint

| Field | Value |
|--------|--------|
| **Now** | **Climate v0.1 C1–C3 IN CODE** — waiting **F5 (C4)** |
| **Doc** | `Docs/CLIMATE_V0_1_SCOPE_LOCK.md` |

### Changes

| File | What |
|------|------|
| `HorseResource.gd` | `climate_suspended` + cache amount; `harvest` blocked while suspended; no climate `queue_free` |
| `EnvironmentZoneService.gd` | `_update_horse_climate_gates` on state change + deferred start; `[CLIMATE] R0 A → B (home region)` |

### F5 look for

```
[CLIMATE] R0 FAVORABLE → DRY (home region)   # or COLD
[CLIMATE] horse suspended HorseHerd cached=...
[CLIMATE] horse resumed HorseHerd amount=...
```

Cycle: FAVORABLE → COLD/DRY → FAVORABLE; mult still 1.5/0.5; M18.x intact.

---

## Done chain

```
M17–M18.2     ✓
Climate v0.1  in code → F5
```
