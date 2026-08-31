# GROK WORKLOG — Nomad Wars

Ветка: `nomads-wars-grok`

**Scope:** `Docs/nomad_wars_v1_scope_and_architecture.md`  
**Tech debt:** `Docs/TECH_DEBT.md`  
**Status:** `Docs/CURRENT_STATE.md`

---

## 2026-08-31 — Stage 1 F5 + full GPT audit documented

### Code (earlier same day)

- Rally: door + offset 12, grid slots, flag, RMB set rally; select ring on all buildings.
- AI attack: issue **once** at threshold; reinforcements only if new unit lacks AI.

### Docs

| ID | Topic | Action |
|----|--------|--------|
| — | Attack spam | **Fixed** |
| TD-01 | AI placement ≠ `can_build` | Recorded |
| TD-02 | stone<50 heuristic → Economy 1.5 | Recorded |
| TD-03 | Residual AI after TC death | Recorded (no Stage 1 fix) |
| TD-04 | TeamRules `DEAD := 6` | Recorded (not blocker) |
| — | Zones: motion/visual/query yes, harvest/AI no | Deferred by design |
| — | Nav MAP_HALF=100 + rebake | Confirmed OK |
| — | Door/rally on BaseBuilding | Confirmed OK |
| — | CURRENT_STATE lagged (“Stage 1 NEXT”) | **Synced** — Stage 1 practically confirmed |

### Product stance

Next meaningful step after Stage 1 sign-off: **AI Economy 1.5**, not T2. Do not wire zones into AI yet.

---

## 2026-08-29 — Doc sync §0 + phases 10–12 closed

### Accepted since last §0 write (F5-backed)

- **Environment Zones v1.0:** 4 blobs, harvest multiplier API exists but Stage B not applied to gather; priority COLD>DRY>FAVORABLE visuals.
- **Enemy AI / selection-aware control / billboard pack bar** — as prior logs.

### Doc action

Updated §0 / pointers (`CURRENT_STATE`, `TODO`, `ROADMAP`) — later superseded by 2026-08-31 Stage 1 snapshot.

---

## 2026-08-28 — Formation-offsets ACCEPTED + billboard fix

Formation-offsets ACCEPTED. MOBILE collision passthrough still tech debt (TODO list).

---

## 2026-08-28 earlier — Docs cleanup (Claude audit)

Deleted ARCHITECTURE, PROJECT_ROADMAP, PHASE_8_*, SESSION. Pointers synced.

---

*Older: Phase 7–8.2, polish — see git history.*
