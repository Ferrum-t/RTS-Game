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
| **Now** | **M17.0 — Variant C: Minimal AI 2nd TC** — **IN CODE, waiting F5** |
| **Not now** | Stage 1.5 B–G, Economy 1.5, M17.1 combat polish, AI pack/repair |

### M17.0 contract (implemented)

- File: `Scripts/AI/EconomicAIController.gd`
- After ≥1 Barracks and still 1 TC: if `wood >= expand_wood_min` (250) and `stone >= expand_stone_min` (100) → instant 2nd TC (`place_building_for_team(..., true)`)
- `max_ai_tc = 2` (no 3rd+)
- Offset from first TC: `second_tc_offset = (-10, 0, 6)` (away from barracks_offset)
- Train workers from **any** free alive same-team TC; total goal still `desired_worker_count` (4)
- Barracks / Soldier / EnemyAI unchanged

### F5 checklist

1. AI: TC + Barracks as before
2. After stock threshold → log `[AI_ECO] expanding 2nd TC` / `2nd TC completed`
3. No 3rd TC
4. Workers can train from either TC if one is busy/destroyed
5. Deposit nearest constructed AI TC still works
6. Soldiers ≥ 3 → attack as before
7. Player multi-TC / build / acquire / towers — no regression
8. Destroy AI TC1 after expand → AI still alive on TC2

---

## Stage 1 — ACCEPTED (2026-09-01)

---

## Player M10–M16 — IN CODE

Construction, repair, deposit-constructed, IDLE acquire, WT Pack/Unpack UI, camera clamp. See prior sync.

---

## AI before M17.0

Single TC train path replaced by multi-TC list + expand. Attack path unchanged.

---

## Stage 1.5 climate — PARKED

---

## Next after F5 accept M17.0

1. Mark M17.0 ACCEPTED in this file
2. Optional **M17.1** combat polish
3. Stage 1.5 B+ only on explicit request
