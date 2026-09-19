# CURRENT STATE

**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-19

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | M17.1 Expansion Economy |
| **Now** | **M17.2 Level 1 Multi-Base Military** — **IN CODE, waiting F5** |

### M17.2 Level 1 (locked)

| IN | OUT |
|----|-----|
| 2nd Barracks near TC2 (`second_barracks_offset`) | Watchtower / tower AI |
| `max_ai_barracks=2` + `_second_barracks_once` | rebuild 2nd Barracks |
| train Soldier from **any** free Barracks | EnemyAI scoring changes |
| existing `attack_threshold` + attach | defend stance / army split |
| | cavalry/siege AI mix, Climate, 3rd TC/Barracks |

File: `Scripts/AI/EconomicAIController.gd` only.

Trigger: `tc >= 2` + can_afford Barracks cost (no extra W threshold).

### F5 matrix

1. TC2 → log `building 2nd Barracks` / `second_barracks_once locked`
2. `barracks=2` → `training Soldier at` both names
3. Destroy Barracks1 → Barracks2 still trains
4. Destroy TC2/Barracks2 → no 3rd Barracks (`b2=true`)
5. Destroy TC1 → TC2 + Barracks2 production continues
6. attack_threshold / EnemyAI no regression
7. Player systems no regression

---

## Done

M10–M16 player · M17.0 · M17.1 · Stage 1.5 Climate **PARKED**
