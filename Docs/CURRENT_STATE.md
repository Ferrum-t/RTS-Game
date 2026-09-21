# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Identity:** `Docs/GAME_DESIGN.md` § Official identity  
**Branch:** `nomads-wars-grok` *(legacy slug)*  
**HEAD fact date:** 2026-09-21

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | Variant B Core Audit — ACCEPTED |
| **Now** | **M17.3 Level 1 AI Watchtower** — **IN CODE, waiting F5** |
| **After F5** | **M18** Combat acquisition (next) |

### M17.3 Level 1 (locked)

| IN | OUT |
|----|-----|
| 1× Watchtower near TC2 after `_second_barracks_once` | multi-tower / TC1 tower |
| `watchtower_offset = (-4, 0, 4)` | rebuild |
| `_watchtower_once` | defense brain / EnemyAI edits |
| instant `place_building_for_team` | Climate / army split |
| `BuildingCombatComponent` as-is | |

File: `Scripts/AI/EconomicAIController.gd` only.

### F5 matrix

1. `b2=true` → log `building Watchtower near …` → `watchtower_once locked`
2. `[TOWER] … combat ready team=1` + Watchtower registered
3. Player unit in range → `acquired` / `hits`
4. Destroy tower → no 2nd AI tower (`w1=true`)
5. Dual Barracks / expand / attack path no regression
6. Player systems no regression

---

## Done chain

```
M17.0–M17.2 · Variant B    ✓
M17.3 Watchtower L1         in code
M18 Combat acquisition      NEXT after F5
```

Stage 1.5 Climate **PARKED**
