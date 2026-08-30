# TODO

**Source of truth:** `Docs/nomad_wars_v1_scope_and_architecture.md` §0  
**Vision (not auto-MVP):** `Docs/12_PROGRESSION_AND_TIER_SYSTEM.md`  
**Lore vs MVP:** `Docs/LORE_MVP_SCOPE_OVERRIDE.md`

## Current Sprint

**Active:** **Stage 1 — Simple Economic AI Opponent (T1 only, no AI migration)**

Wave Balance Pass is **paused** (15/30/45 data kept; Pressure Test Mode only). Do not prioritize further interval tuning until Stage 1 F5 result.

### Done

- [x] Phases 7–12, Zones v1.0, selection-aware control
- [x] Doc vision `12_PROGRESSION_AND_TIER_SYSTEM.md` (tiers + Stage 1 definition)
- [x] Scope §0 Product Scope Under Active Review (2026-08-31)

## Next

- [ ] **Stage 1 Economic AI** — shared systems; gather → Barracks → Soldier → attack at army size K; no migrate
- [ ] Optional: Building Health Bar
- [ ] Zone readability / Zones v1.1 seasonal front
- [ ] Post–Stage 1: decide v1.0 = T1-only vs T1+T2 (update scope §0)

## Technical Debt

- [ ] EnemySpawner config single source (MatchManager overrides)
- [ ] Staggered Nav Updates (more urgent with dual economy)
- [ ] Aggro leashing, data-driven stats, multi-select buildings, MOBILE collision
