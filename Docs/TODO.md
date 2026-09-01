# TODO

**Source of truth:** `Docs/nomad_wars_v1_scope_and_architecture.md` §0  
**Vision (not auto-MVP):** `Docs/12_PROGRESSION_AND_TIER_SYSTEM.md`  
**Lore vs MVP:** `Docs/LORE_MVP_SCOPE_OVERRIDE.md`  
**Tech debt detail:** `Docs/TECH_DEBT.md`  
**Live status:** `Docs/CURRENT_STATE.md`  
**How we accept work (F5, debt vs fix, multi-chat):** `Docs/ACCEPTANCE_AND_PROCESS.md`

## Current Sprint

**Stage 1 — Simple Economic AI Opponent:** **practically confirmed (F5)**. Formal sign-off optional.

Wave Balance Pass remains **paused** (Pressure Test Mode only).

### Done

- [x] Phases 7–12, Zones v1.0 visuals, selection-aware control
- [x] Doc vision `12_PROGRESSION_AND_TIER_SYSTEM.md` (tiers + Stage 1 definition)
- [x] Stage 1 economic loop (gather → Barracks → Soldiers → attack; VICTORY/DEFEAT)
- [x] Door + rally + flag; building select ring; attack-issue once at threshold
- [x] GPT audit documented (TD-01…04); CURRENT_STATE synced
- [x] Dual stock-floor harvest (narrow fix; not full Economy 1.5)
- [x] `ACCEPTANCE_AND_PROCESS.md` — canonical process rules for all chats

## Next

- [ ] Canonical balance numbers in `CURRENT_STATE` (TC coords, amounts, speeds) — chat lore → repo
- [ ] **AI Economy 1.5** (goal → resource demand → worker assign) — **before T2** (TD-02)
- [ ] Optional: TD-01 shared `can_place` for AI builds
- [ ] Optional: Zone Stage B (harvest multiplier) — **not** AI-driven yet
- [ ] Post–Stage 1: decide v1.0 = T1-only vs T1+T2 (update scope §0)

## Technical Debt

- [ ] **TD-01** AI build skips player `can_build` — `Docs/TECH_DEBT.md`
- [ ] **TD-02** AI harvest → full Economy 1.5 after narrow floor fix — `Docs/TECH_DEBT.md`
- [ ] **TD-03** Residual AI after TC death — Stage 1 OK — `Docs/TECH_DEBT.md`
- [ ] **TD-04** TeamRules `UNIT_STATE_DEAD := 6` fragile — `Docs/TECH_DEBT.md`
- [ ] EnemySpawner config single source (MatchManager overrides)
- [ ] Staggered Nav Updates (more urgent with dual economy)
- [ ] Aggro leashing, data-driven stats, multi-select buildings, MOBILE collision
