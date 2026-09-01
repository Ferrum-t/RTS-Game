# CURRENT STATE

**Gameplay scope:** [`nomad_wars_v1_scope_and_architecture.md`](nomad_wars_v1_scope_and_architecture.md)  
**Vision:** [`12_PROGRESSION_AND_TIER_SYSTEM.md`](12_PROGRESSION_AND_TIER_SYSTEM.md)  
**Lore override:** [`LORE_MVP_SCOPE_OVERRIDE.md`](LORE_MVP_SCOPE_OVERRIDE.md)  
**Tech debt:** [`TECH_DEBT.md`](TECH_DEBT.md)  
**Process:** [`ACCEPTANCE_AND_PROCESS.md`](ACCEPTANCE_AND_PROCESS.md)

**Branch:** `nomads-wars-grok`

## Snapshot (2026-09-01)

| Item | State |
|------|--------|
| Core mobile RTS + Zones v1.0 visuals + dual-mode caravan | **ACCEPTED** |
| **Stage 1 Simple Economic AI (T1, no migrate)** | **Practically confirmed (F5)** — formal player sign-off optional |
| AI attack issue-once + reinforcements | **Accepted (F5)** |
| AI harvest dual stock-floor (narrow fix) | **Done (F5)** — wood recovers after Barracks; not irreversible stick |
| Full **AI Economy 1.5** (goal→deficit→assign) | **Not started** — gated by `ACCEPTANCE_AND_PROCESS.md` §3 amendment |
| Wave spawner | **Pressure Test Mode** |
| Product: T1-only vs T1+T2 | **Under review** — **T2 blocked** until economy path reassessed |
| T2/T3 / Places / air / magic | Vision only |
| Heroes | NOT v1.0 |
| AI migration | NOT Stage 1 |

## System status (code + F5)

| System | State |
|--------|--------|
| Core RTS | Works |
| Per-team economy | Works |
| Player economy | Works |
| AI economy | Works at Stage 1 with **dual floor** (`stock_floor=100`); full goal stack = later |
| AI construction | Works (no shared `can_build` — TD-01) |
| AI production | Works |
| AI combat | Works (attack once at threshold) |
| Shared combat pipeline | Works |
| Door / Rally / flag / select ring | Works (`BaseBuilding`) |
| Building HP / visual states | Works |
| Loot | Works |
| Mobile buildings | Works |
| Navigation rebake | Works (`MAP_HALF=100`) |
| Moving zones | Works (visual + `get_multiplier_at`) |
| Zone harvest / AI influence | **No** — do not wire yet |
| T2 / Heroes / Places / AI migration | No |

## F5-backed Stage 1 loop

```
workers → harvest → deposit → barracks → soldiers → attack → destruction → victory/defeat
```

## Next action (ordered)

1. Formal Stage 1 sign-off (player) if desired.  
2. Optional: write balance numbers (TC coords, amounts, speeds) into this file — §5 process.  
3. **Economy 1.5 design only if** a new F5 shows dual-floor is still systematically insufficient under production goals (`ACCEPTANCE_AND_PROCESS.md` §3 amendment). Otherwise defer until T2 goal tree needs it.  
4. Later: TD-01 `can_place`, TD-03 victory coupling, TD-04 TeamRules, Zone Stage B.

**Do not start T2** to invent a need for a bigger AI economy.
