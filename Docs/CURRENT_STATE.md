# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Identity:** `Docs/GAME_DESIGN.md` § Official identity  
**Branch:** `nomads-wars-grok` *(legacy slug; product name is Nomad Wars, not “Nomads Wars”)*  
**HEAD fact date:** 2026-09-21

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M17.2 Level 1 Multi-Base Military** — **ACCEPTED** (F5 2026-09-19) |
| **Next (optional)** | M17.3 Watchtower PRE-CODE AUDIT done — lock when ready / M18 / balance |

### M17.2 F5 evidence

| Check | Result |
|-------|--------|
| TC2 → 2nd Barracks | `Barracks_4` near TownCenter_3 → `second_barracks_once locked` |
| Dual production | train at Barracks_1 + Barracks_4 |
| Stable state | `tc=2 barracks=2 b2=true` |
| Attack path | threshold + reinforcements |
| No 3rd Barracks | once policy held |

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

- **M17.3** AI Watchtower near TC2 (audit done; needs LOCK)
- **M18** Combat acquisition / stances
- Balance (dual-barracks pressure)
- Climate after multi-base loop feels settled
