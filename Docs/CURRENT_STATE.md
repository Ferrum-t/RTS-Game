# CURRENT STATE

**Gameplay scope:** [`nomad_wars_v1_scope_and_architecture.md`](nomad_wars_v1_scope_and_architecture.md)  
**Tech debt:** [`TECH_DEBT.md`](TECH_DEBT.md)  
**Process:** [`ACCEPTANCE_AND_PROCESS.md`](ACCEPTANCE_AND_PROCESS.md)

**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-19

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M17.0 — Variant C: Minimal AI 2nd TC** — **ACCEPTED** (F5 2026-09-19) |
| **Next (optional)** | M17.1 combat polish / Stage 1.5 B+ only on explicit request |

### M17.0 ACCEPTED evidence

- File: `Scripts/AI/EconomicAIController.gd`
- F5 log:
  - Barracks then expand at W=270 S=450 → `TownCenter_3` at (-38, 0, 34), `constructed=true`
  - `tc=2` stable; no 3rd TC
  - Dual `TownCenter: not enough wood` when both TCs try train (multi-TC loop)
  - Soldiers train + attack; player build/repair/towers OK
  - Match completed (DEFEAT) with AI still reporting `tc=2`

### Parameters (exports)

| Export | Value |
|--------|--------|
| `expand_wood_min` | 250 |
| `expand_stone_min` | 100 |
| `max_ai_tc` | 2 |
| `second_tc_offset` | (-10, 0, 6) |

---

## Stage 1 — ACCEPTED (2026-09-01)

## Player M10–M16 — IN CODE

## Stage 1.5 climate — PARKED

---

## Known post-M17.0 noise (not blockers)

- When `workers=0` and wood=0, both TCs log «not enough wood» every decision tick — Stage-1 spam, not expand bug.
- AI still single Barracks; wood starved late-game (TD-02 heuristic).
