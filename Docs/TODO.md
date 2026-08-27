# TODO

## Current Sprint

- [x] Phase 7 — Enemy AI Waves & Match Loop
- [x] Deposit team_id filter (no enemy TC)
- [x] Attack Hysteresis & RVO Avoidance (ACCEPTED F5)
- [ ] **Phase 8.0 — Stationary Watchtower + auto-attack** (wired, waiting F5)

---

## Technical Debt Backlog

- [ ] **Staggered Nav Updates:** Распределение перерасчёта путей юнитов по кадрам (frame slicing) при 50+ юнитах.
- [ ] **Aggro Leashing:** Ограничение дистанции преследования с возвратом на исходную позицию.
- [ ] **Data-Driven Stats:** Вынос HP / damage / speed / range в `.tres` ресурсы.
- [ ] **Safe Instance Checks:** Усиленная проверка `is_instance_valid()` при массовом уничтожении целей.
- [ ] **Idle Worker UI Event:** UI-оповещение, если нет своего TC для deposit.
- [x] **Attack Hysteresis & RVO Avoidance:** enter/exit range + soft NavigationAgent avoidance (2026-08-26).
- [ ] Watchtower ghost uses shared `GhostBuilding.tscn` (footprint larger than tower).

---

## Known residual (not blocking Phase 8.1)

- [ ] SiegeUnit corners / larger agent radius vs bake
- [ ] Mobile TC path through resource collision (partial)
- [ ] RVO fine-tune per unit type (Siege larger radius)
- [ ] RVO wall-nudge near building corners (accepted tech debt)

---

## Next

- F5 accept Phase 8.0 (`[TOWER]` logs)
- Phase 8.1 — MobileTower via `DeploymentComponent`
