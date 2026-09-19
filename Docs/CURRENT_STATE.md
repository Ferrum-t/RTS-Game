# CURRENT STATE

**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-19

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M17.2 Level 1 Multi-Base Military** — **ACCEPTED** (F5 2026-09-19) |
| **Next (optional)** | M17.3 Watchtower / M18 combat acquisition / balance — on request |

### M17.2 F5 evidence

| Check | Result |
|-------|--------|
| TC2 → 2nd Barracks | `building 2nd Barracks at (-34,0,31) near TownCenter_3` → `Barracks_4` → `second_barracks_once locked` (once) |
| Dual production | `training Soldier at Barracks_1` (13×) + `Barracks_4` (10×) |
| Stable state | `tc=2 barracks=2 expanded=true b2=true`; army up to ~14 |
| Attack path | `attack threshold` + continuous `reinforcements` |
| No 3rd Barracks | only one 2nd-Barracks place event |
| Player | build/towers/combat OK (player under dual-Barracks pressure — expected) |

File: `Scripts/AI/EconomicAIController.gd`

---

## Done chain

```
M10–M16  Player RTS foundation     ✓
M17.0    AI Second TC               ✓
M17.1    Expansion Economy          ✓
M17.2    Multi-Base Military L1     ✓
```

Stage 1.5 Climate **PARKED**

## Optional next

- **M17.3** AI Watchtower near TC2 (if defense gap matters)
- **M18** Combat acquisition / stances
- Balance (AI pressure with 2 barracks is strong — intentional)
- Climate only after static multi-base loop feels settled
