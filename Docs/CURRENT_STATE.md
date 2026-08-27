# CURRENT STATE

**Branch:** `nomads-wars-grok`  
**Version:** 0.2 playable match loop + Phase 8.0 Watchtower (F5 pending)

## Status

| Milestone | State |
|-----------|--------|
| M1–M6.9 Foundation / Nav / Harvest-through-Movement | COMPLETE |
| Phase 4 Mobile TC (Deployment) | COMPLETE |
| Phase 5 Horses & Cavalry | COMPLETE |
| Phase 6 Raid/Loot + Siege + Building Visual States | COMPLETE |
| Phase 7 AI Waves & Core Loop | COMPLETE |
| Deposit own-team only | COMPLETE |
| Sprint: Navigation & Combat Polish (Hysteresis & RVO) | **ACCEPTED** |
| **Phase 8.0 Stationary Watchtower + auto-attack** | **WAITING F5** |

## Active work

**Phase 8.0 — Watchtower**

- `BuildingCombatComponent` scans `UnitManager.units` (`scan_interval = 0.4`)
- No Area3D / PhysicsQuery
- Catalog cost Wood 40 / Stone 20 (`WatchtowerData` + `ResourceManager.cost_watchtower()`)
- MatchManager spawns one player tower on the enemy march path

## Architecture (stable)

- `BaseUnit` owns `unit_state` + `Order`
- `MovementComponent` = HOW (NavAgent + path + optional RVO)
- `Harvest` / `Combat` report status; Unit decides transitions
- `MatchManager` Win/Lose by buildings team 0 vs 1
- `EnemyAIComponent` + `EnemySpawner` for team 1 waves
- `BuildingCombatComponent` = building auto-attack (does not issue Orders)

## Next after F5 accept 8.0

Phase 8.1 — MobileTower via existing `DeploymentComponent`
