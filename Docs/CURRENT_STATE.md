# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-21

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | M17.3 AI Watchtower L1 |
| **Now** | **M18 Level 1 Combat acquisition (A+C)** — **IN CODE, waiting F5** |

### M18 Level 1 (locked)

| IN | OUT |
|----|-----|
| **A** Retaliate from IDLE / MOVING / HARVESTING / RETURNING | BUILD / REPAIR interrupt |
| **C** Immediate REACQUIRE after TARGET_DEAD/LOST in radius 12 | Idle acquire → buildings (**B** deferred) |
| File: `Scripts/Units/BaseUnit.gd` only | Stances · EnemyAI · Climate |

### F5 matrix

1. Worker HARVESTING hit by enemy → `RETALIATE ->` → ATTACKING
2. Kill unit with 2nd enemy in r12 → `REACQUIRE ->` without long idle pause
3. BUILD/REPAIR **not** broken by random retaliate
4. No ACQUIRE/RETALIATE spam every frame
5. M17.2/17.3 / towers / dual Barracks no regression

---

## Done chain

```
M17.0–M17.3     ✓
M18 A+C         in code → F5
M18-B (buildings acquire) deferred
```

Climate **PARKED**
