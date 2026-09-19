# TODO

**Source of truth:** `Docs/CURRENT_STATE.md`  
**Scope:** `Docs/nomad_wars_v1_scope_and_architecture.md`  
**Process:** `Docs/ACCEPTANCE_AND_PROCESS.md`

---

## Active — M17.0

- [ ] **M17.0 Variant C — Minimal AI 2nd TC**
  - stocks ≥ thresholds + ≥1 Barracks + exactly 1 alive TC → instant 2nd TC
  - `max_ai_tc = 2` (no 3rd+)
  - train workers from **any** alive same-team TC
  - workers goal still `desired_worker_count` total (4)
  - Barracks / Soldier / EnemyAI unchanged
  - F5: 2nd TC appears once; train from both; destroy TC1 → still alive on TC2; no player regression
- [ ] M17.1 combat polish (only if needed after expand is stable)

---

## Done (repo fact)

- [x] Stage 1 T1 economic AI — ACCEPTED 2026-09-01
- [x] M10–M10.2 Worker construction + UI/gates/visuals
- [x] M11 start Workers ×4
- [x] M12 / M12.1 Repair + DEAD ordinal
- [x] M13 IDLE retaliation
- [x] M15 deposit constructed TC only
- [x] M16 IDLE auto-acquire r=12
- [x] Watchtower Pack/Unpack UI + camera clamp
- [x] Stage 1.5 design contract + Slice A prototype + 8×r21 geometry port + Seasonal Front v0 (**parked**)

---

## Stage 1.5 — PARKED (explicit request only)

- [x] Fixed-region design + Expanded Geometry v0.1 sign-off
- [x] A — Climate backend + layout port
- [ ] B — Environment state visuals
- [ ] C — Soft climate pressure on extraction
- [ ] D — Horse availability response
- [ ] E — Neutral camps + loot
- [ ] F — Minimal player hero + one artifact
- [ ] G — Conflict matrix

## Deferred

- AI migration / AI pack / AI repair / AI UNDER_CONSTRUCTION
- AI hero / full hero / artifact tiers / magic
- Economy 1.5 goal→deficit architecture
- T2 / T3 / new victory conditions

## Tech debt (see `TECH_DEBT.md`)

- [ ] TD-01 shared `can_place` for AI
- [ ] TD-02 harvest heuristic → Economy 1.5 if needed
- [ ] TD-03 residual AI after TC (OK while win = destroy TC)
- [ ] TD-04 TeamRules DEAD const vs enum (verify after M12.1 ordinal shift)
