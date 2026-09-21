# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Identity:** `Docs/GAME_DESIGN.md` § Official identity  
**Branch:** `nomads-wars-grok` *(legacy slug)*  
**HEAD fact date:** 2026-09-21

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **Variant B — Core Gameplay Polish / Audit** — **ACCEPTED** (F5 2026-09-21) |
| **Prior feature** | M17.2 Level 1 Multi-Base Military — ACCEPTED |
| **Next (optional)** | M17.3 Watchtower LOCK · **Balance pass** · M18 |

### Variant B F5 (control match)

| Check | Result |
|-------|--------|
| Player harvest + deposit | ✓ (TC + TownCenter_1) |
| Player 2nd TC build → COMPLETE | ✓ TownCenter_1 |
| Deposit on 2nd TC | ✓ Worker/Worker3/Worker4 |
| Player Watchtower place + combat | ✓ Watchtower_3 / _6 acquire/hits |
| AI Barracks → TC2 → 2nd Barracks | ✓ Barracks_5 `second_barracks_once locked` |
| Dual train | ✓ Barracks_2 ×12 + Barracks_5 ×9 |
| Attack path | ✓ threshold + reinforcements |
| No 3rd TC/Barracks | ✓ `b2=true` |
| Crashes / script errors | none in log |
| Repair | not completed (AI wave too fast — **balance**, not P0) |

**Note:** Dual-Barracks AI pressure makes solo player development hard. Not a regression of systems — intentional M17.2 outcome. Optional **balance pass** (attack_threshold / costs / train times) if desired; not required to close B.

---

## Done chain

```
M10–M16  Player RTS foundation     ✓
M17.0    AI Second TC               ✓
M17.1    Expansion Economy          ✓
M17.2    Multi-Base Military L1     ✓
Variant B Core Audit                ✓
```

Stage 1.5 Climate **PARKED**
