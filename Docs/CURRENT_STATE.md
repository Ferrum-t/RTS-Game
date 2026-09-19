# CURRENT STATE

**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-19

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M17.0** ACCEPTED |
| **Now** | **M17.1 AI Expansion Economy** — **IN CODE, waiting F5** |

### M17.1 scope (locked)

| ID | Behavior |
|----|----------|
| **A** | `_expanded_once` — one successful 2nd TC per match; no rebuild after TC2 loss |
| **B** | Worker goal: 4 if `tc==1`, **6** if `tc>=2` (`extra_workers_at_two_tc=2`) |
| **C** | Soft harvest bias: score blends worker distance + distance to under-served TC (`underserved_tc_bias=0.3`); no Worker→TC assignment system |
| **D** | Wood pressure: if `wood < production_wood_floor` (80) → force WOOD before dual-floor |
| **E** | F5 matrix below |

**Out of M17.1:** 2nd Barracks, towers, AI repair, combat brain, Climate, 3rd TC, Economy 1.5 planner.

File: `Scripts/AI/EconomicAIController.gd`

### F5 matrix (E)

1. Normal expand: Barracks → threshold → 2nd TC once; log `expand_once locked`
2. `workers` climbs toward **6** after `tc=2`
3. Idle workers show activity near both TC neighborhoods over time (soft bias, not forced 3+3)
4. Wood recovers when low (less permanent `wood=0 stone=2000+`)
5. **Destroy TC2** → AI continues on TC1; **no** third/rebuild TC (`expanded=true` stays)
6. **Destroy TC1** → AI continues on TC2; train/deposit still work
7. No 3rd TC while both alive
8. Player systems unchanged

---

## Done

- Stage 1 · M10–M16 player · M17.0 second TC
- Stage 1.5 climate **PARKED**

## Next after M17.1 F5

- **M17.2** AI Multi-Base Military (only if eco cycle feels real)
- M18 Combat acquisition · M19 Climate — later
