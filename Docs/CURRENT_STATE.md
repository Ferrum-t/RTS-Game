# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Identity:** `Docs/GAME_DESIGN.md` § Official identity  
**Branch:** `nomads-wars-grok` *(legacy slug)*  
**HEAD fact date:** 2026-09-21

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M17.3 Level 1 AI Watchtower** — **ACCEPTED** (F5 2026-09-21) |
| **Next** | **M18 Combat acquisition** — PRE-CODE AUDIT first |

### M17.3 F5 evidence

| Check | Result |
|-------|--------|
| After Barracks2 | `building Watchtower at (-42,0,38) near TownCenter_4` |
| Once lock | `Watchtower_6` · `watchtower_once locked` · `w1=true` |
| Combat team=1 | `[TOWER] Watchtower_6 combat ready team=1` |
| No rebuild | after tower destroy still `w1=true`, no 2nd AI tower place |
| Dual Barracks | train Barracks_1 + Barracks_5 |
| Match | VICTORY (player cleared AI base after resource shift) |

---

## Done chain

```
M10–M16  Player foundation          ✓
M17.0    AI Second TC               ✓
M17.1    Expansion Economy          ✓
M17.2    Multi-Base Military L1     ✓
Variant B Core Audit                ✓
M17.3    AI Watchtower L1           ✓
M18      Combat acquisition         ← NEXT (audit → lock → code)
```

Stage 1.5 Climate **PARKED**
