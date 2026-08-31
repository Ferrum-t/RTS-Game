# TODO

**Source of truth:** `Docs/nomad_wars_v1_scope_and_architecture.md` §0  
**Vision (not auto-MVP):** `Docs/12_PROGRESSION_AND_TIER_SYSTEM.md`  
**Lore vs MVP:** `Docs/LORE_MVP_SCOPE_OVERRIDE.md`  
**Tech debt detail:** `Docs/TECH_DEBT.md`

## Current Sprint

**Active:** **Stage 1 — Simple Economic AI Opponent (T1 only, no AI migration)**

Wave Balance Pass is **paused** (15/30/45 data kept; Pressure Test Mode only). Do not prioritize further interval tuning until Stage 1 F5 result.

### Done

- [x] Phases 7–12, Zones v1.0, selection-aware control
- [x] Doc vision `12_PROGRESSION_AND_TIER_SYSTEM.md` (tiers + Stage 1 definition)
- [x] Scope §0 Product Scope Under Active Review (2026-08-31)
- [x] Stage 1 economic loop playable (gather → Barracks → Soldiers → attack; VICTORY/DEFEAT)
- [x] Door + rally + flag; building select ring; attack-issue once at threshold (TD decision-layer spam fixed)

## Next

- [ ] Stage 1 polish / remaining GPT audit items (see `TECH_DEBT.md`)
- [ ] **Preferred after Stage 1 close: AI Economy 1.5** (goal → resource demand → worker assign) — **before T2**
- [ ] Optional: Zone readability / Zones v1.1 seasonal front
- [ ] Post–Stage 1: decide v1.0 = T1-only vs T1+T2 (update scope §0)

## Technical Debt

- [ ] **TD-01** AI build skips player `can_build` / collision — `Docs/TECH_DEBT.md`
- [ ] **TD-02** AI harvest = stone<50?stone:wood (not demand-driven) → Economy 1.5 — `Docs/TECH_DEBT.md`
- [ ] EnemySpawner config single source (MatchManager overrides)
- [ ] Staggered Nav Updates (more urgent with dual economy)
- [ ] Aggro leashing, data-driven stats, multi-select buildings, MOBILE collision
