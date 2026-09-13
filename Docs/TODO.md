# TODO

**Source of truth for Stage 1 status:** `Docs/CURRENT_STATE.md`  
**Stage 1.5 climate/migration contract:** `Docs/DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`  
**Expanded geography (design):** `Docs/EXPANDED_CLIMATE_GEOMETRY_V0_1.md`  
**Acceptance process:** `Docs/ACCEPTANCE_AND_PROCESS.md`

---

## Stage 1 — ACCEPTED (2026-09-01)

Core T1 loop, dual-floor economy, attack-once, door/rally, buildings, loot, nav rebake — closed. Do not reopen without new F5 evidence.

---

## Stage 1.5

- [x] Fixed-region / three-state climate design contract
- [x] Review Stage 1.5 design contract against current repository implementation
- [x] **A — Climate backend (prototype):** fixed non-overlapping regions + seasonal state lookup (4×r14 in code, F5 OK)
- [x] F5 Climate A against written acceptance criteria
- [x] **Expanded Climate Geometry v0.1** design sign-off (8×r21 Variant B) — `EXPANDED_CLIMATE_GEOMETRY_V0_1.md`
- [ ] **Layout port (explicit task):** put Variant B table into `EnvironmentZoneService` (only when requested)
- [ ] B — Environment state visuals
- [ ] F5 B
- [ ] C — Soft climate pressure on existing resource extraction
- [ ] F5 C
- [ ] D — Horse availability response
- [ ] F5 D
- [ ] E — Neutral camps + basic loot
- [ ] F5 E
- [ ] F — Minimal player hero + one artifact loop
- [ ] F5 F
- [ ] G — Conflict matrix / player decision test

## Deferred / blocked until evidence

- [ ] AI migration
- [ ] AI hero
- [ ] Full hero progression
- [ ] Artifact tiers
- [ ] Terrain / settlement suitability system
- [ ] Animal pathfinding
- [ ] Magic / mana / Power Site gameplay
- [ ] Economy 1.5 goal/deficit architecture
- [ ] T2 / T3
- [ ] New victory conditions

## Technical Debt (later)

- [ ] TD-01 shared `can_place`
- [ ] TD-02 Economy 1.5 (optional)
- [ ] TD-03 residual AI after TC
- [ ] TD-04 TeamRules DEAD const
- [ ] EnemySpawner config / nav stagger / aggro / MOBILE collision / multi-select buildings
