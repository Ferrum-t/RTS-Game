# CURRENT STATE

**Branch:** `nomads-wars-grok`  
**Version:** 0.2 playable match loop

## Status

| Milestone | State |
|-----------|--------|
| M1–M6.9 Foundation / Nav / Harvest-through-Movement | COMPLETE |
| Phase 4 Mobile TC (Deployment) | COMPLETE |
| Phase 5 Horses & Cavalry | COMPLETE |
| Phase 6 Raid/Loot + Siege + Building Visual States | COMPLETE |
| **Phase 7 AI Waves & Core Loop** | **COMPLETE** |
| Deposit own-team only | COMPLETE |
| **Sprint: Navigation & Combat Polish (Hysteresis & RVO)** | **ACTIVE** |

## Active work

**Sprint: Navigation & Combat Polish**

- Attack range hysteresis (unit + building siege)
- Soft RVO on `NavigationAgent3D` for unit–unit avoidance

## Architecture (stable)

- `BaseUnit` owns `unit_state` + `Order`
- `MovementComponent` = HOW (NavAgent + path + optional RVO)
- `Harvest` / `Combat` report status; Unit decides transitions
- `MatchManager` Win/Lose by buildings team 0 vs 1
- `EnemyAIComponent` + `EnemySpawner` for team 1 waves

## Next after polish F5

Phase 8 — defensive structures / mobile towers
