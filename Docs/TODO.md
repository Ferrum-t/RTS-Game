# TODO

**Source of truth:** `Docs/nomad_wars_v1_scope_and_architecture.md` §0  
**Live status + balance snapshot:** `Docs/CURRENT_STATE.md`  
**Process:** `Docs/ACCEPTANCE_AND_PROCESS.md`  
**Stage 1.5 gameplay:** `Docs/STAGE_1_5_GAMEPLAY.md`  
**Stage 1.5 climate/migration contract:** `Docs/DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`  
**Tech debt:** `Docs/TECH_DEBT.md`

## Current Sprint

**Stage 1 — ACCEPTED (2026-09-01).**  
**Current phase:** Stage 1.5 design is defined; next is a narrow Climate backend implementation task.

### Done

- [x] Stage 1 core loop + formal sign-off
- [x] Attack once + dual-floor + F5
- [x] Balance snapshot in `CURRENT_STATE.md`
- [x] Stage 1.5 causal-chain framing
- [x] Fixed-region / three-state climate design contract
- [x] Region content / horses / neutral camps / minimal hero / artifact scope defined

## Next

- [ ] Review Stage 1.5 design contract against current repository implementation
- [ ] **A — Climate backend:** replace moving-zone model with fixed non-overlapping regions + seasonal state lookup
- [ ] F5 Climate A against written acceptance criteria
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
