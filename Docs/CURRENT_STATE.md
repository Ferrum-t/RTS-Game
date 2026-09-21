# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-21

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | M18 Level 1 Combat acquisition (A+C) |
| **Now** | **M18.1 Balance P1+P2** — **IN CODE, waiting F5** |

### M18.1 changes

| ID | Change | File |
|----|--------|------|
| **P1** | `attack_threshold` 3 → **5** | `EconomicAIController.gd` |
| **P2** | `soldier_train_time` 5.0 → **6.5** s | `Barracks.gd` |
| OUT | P3/P4/P5 · Climate · M18-B · stances |

### F5 matrix

1. Ready log: `attack_at=5`
2. Train log: `training Soldier... (6.5s, ...)`
3. First attack at army **≥5** (not 3)
4. Dual Barracks still works (`b2=true`)
5. Player window: Barracks + Watchtower + soldiers before first wave
6. AI still attacks and can kill idle player
7. M17.x / M18 A+C no regression

---

## Done chain

```
M17.0–M17.3 · M18 A+C     ✓
M18.1 P1+P2               in code → F5
```

Climate **PARKED**
