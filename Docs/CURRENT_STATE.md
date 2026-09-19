# CURRENT STATE

**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-19

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M17.1 AI Expansion Economy** — **ACCEPTED** (F5 2026-09-19) |
| **Next (optional)** | M17.2 Multi-Base Military — only if needed |

### M17.1 F5 evidence

| ID | Result |
|----|--------|
| **A** expand-once | One `expanding 2nd TC` → `expand_once locked`. After EnemyTownCenter die: `tc=1 expanded=true`, **no** rebuild |
| **B** workers 4→6 | Goal `4/6` after expand; train at **both** EnemyTownCenter and TownCenter_3; reached `6/6` (brief `7/6` race OK) |
| **C** soft bias | Code path live; **0 deposits to TownCenter_3** in this map — TC2 offset keeps same resource cluster as TC1. Soft bias cannot invent a second frontier |
| **D** wood pressure | Wood stayed hundreds–thousands while workers alive (vs M17.0 late `wood=0 stone=2k+`) |
| **E** loss matrix | TC1 destroyed first → AI on TC2; then TC2 destroyed → VICTORY; no 3rd TC |

**Accepted with note:** C is soft-by-design; second *economic zone* needs farther expand placement or M17.2 military/anchor work — not more harvest planner in M17.1.

File: `Scripts/AI/EconomicAIController.gd`

---

## Done

- Stage 1 · Player M10–M16 · **M17.0** second TC · **M17.1** expansion economy
- Stage 1.5 Climate **PARKED**

## Optional next

```
M17.2  AI Multi-Base Military   (2nd barracks / defense near TC2 — if desired)
M18    Combat acquisition
M19    Stage 1.5 Climate
```
