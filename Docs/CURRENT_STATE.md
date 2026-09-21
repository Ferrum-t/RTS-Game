# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Identity:** `Docs/GAME_DESIGN.md` § Official identity  
**Branch:** `nomads-wars-grok` *(legacy slug)*  
**HEAD fact date:** 2026-09-21

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M17.2 Level 1 Multi-Base Military** — **ACCEPTED** (F5 2026-09-19) |
| **Now** | **Variant B — Core Gameplay Polish / Audit** (no new mechanics) |
| **Not active** | M17.3 code · M18 · Climate · Hero / Magic |

### Audit goal

Confirm post-M17.2 loop is stable: economy, construction, combat, AI multi-base, UI.  
**OUT:** new systems, Watchtower AI, balance number changes unless F5 shows P0.

### M17.2 evidence (baseline)

| Check | Result |
|-------|--------|
| TC2 → 2nd Barracks | Barracks_4 · `second_barracks_once locked` |
| Dual production | Barracks_1 + Barracks_4 train |
| State | `tc=2 barracks=2 b2=true` |
| Attack | threshold + reinforcements |

---

## Done chain

```
M10–M16  Player RTS foundation     ✓
M17.0    AI Second TC               ✓
M17.1    Expansion Economy          ✓
M17.2    Multi-Base Military L1     ✓
```

Stage 1.5 Climate **PARKED**

## After audit

- M17.3 Watchtower (if LOCK) · M18 · balance · Climate (parked)
