# TODO

**Source of truth:** `Docs/nomad_wars_v1_scope_and_architecture.md` §0  
**Vision (not auto-MVP):** `Docs/12_PROGRESSION_AND_TIER_SYSTEM.md`  
**Lore vs MVP:** `Docs/LORE_MVP_SCOPE_OVERRIDE.md`  
**Tech debt detail:** `Docs/TECH_DEBT.md`  
**Live status:** `Docs/CURRENT_STATE.md`  
**How we accept work:** `Docs/ACCEPTANCE_AND_PROCESS.md` (§3 amendment: symptom ≠ full system)

## Current Sprint

**Stage 1** — practically confirmed (F5). Formal sign-off optional.

### Done

- [x] Stage 1 economic loop + attack once + door/rally
- [x] Dual stock-floor harvest (narrow fix; F5 wood recovery)
- [x] `ACCEPTANCE_AND_PROCESS.md` + §3 amendment

## Next

- [ ] Canonical balance numbers in `CURRENT_STATE` (TC coords, amounts, speeds)
- [ ] **AI Economy 1.5 design** — **only if** dual-floor F5 still insufficient (see §3 amendment); else defer until T2 needs richer goals
- [ ] Optional: TD-01 shared `can_place`
- [ ] Optional: Zone Stage B harvest — not AI-driven
- [ ] Post–Stage 1: T1-only vs T1+T2 — **after** economy reassessment; **no T2 now**

## Technical Debt

- [ ] **TD-01** AI build skips `can_build` — `TECH_DEBT.md`
- [ ] **TD-02** Full Economy 1.5 — optional after dual-floor; not auto-next
- [ ] **TD-03** Residual AI after TC death — Stage 1 OK
- [ ] **TD-04** TeamRules `DEAD := 6`
- [ ] EnemySpawner config single source
- [ ] Staggered Nav Updates / aggro leashing / MOBILE collision / multi-select buildings
