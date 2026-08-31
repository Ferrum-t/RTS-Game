# CURRENT STATE

**Gameplay scope:** [`nomad_wars_v1_scope_and_architecture.md`](nomad_wars_v1_scope_and_architecture.md)  
**Vision:** [`12_PROGRESSION_AND_TIER_SYSTEM.md`](12_PROGRESSION_AND_TIER_SYSTEM.md)  
**Lore override:** [`LORE_MVP_SCOPE_OVERRIDE.md`](LORE_MVP_SCOPE_OVERRIDE.md)  
**Tech debt:** [`TECH_DEBT.md`](TECH_DEBT.md)

**Branch:** `nomads-wars-grok`

## Snapshot (2026-08-31 / GPT audit + F5)

| Item | State |
|------|--------|
| Core mobile RTS + Zones v1.0 visuals + dual-mode caravan | **ACCEPTED** |
| **Stage 1 Simple Economic AI (T1, no migrate)** | **Practically confirmed (F5)** — formal acceptance when player signs off |
| Wave spawner | **Pressure Test Mode** (not final loop) |
| Wave interval balance | **PAUSED** |
| Product: T1-only vs T1+T2 | **Under review** — prefer **AI Economy 1.5** before T2 |
| T2/T3 / Places / air / magic | Vision only — not implementing |
| Heroes | NOT v1.0 |
| AI migration | NOT Stage 1 (correct) |

## System status (code + F5)

| System | State |
|--------|--------|
| Core RTS | Works |
| Per-team economy | Works |
| Player economy | Works |
| AI economy | Works (primitive heuristic — TD-02) |
| AI construction | Works (no shared `can_build` — TD-01) |
| AI production | Works |
| AI combat | Works (attack issue once at threshold) |
| Shared combat pipeline | Works |
| Door / Rally / flag / select ring | Works (`BaseBuilding`) |
| Building HP / visual states | Works |
| Loot | Works |
| Mobile buildings | Works |
| Navigation rebake | Works (`MAP_HALF=100`, footprints, bake_id) |
| Moving zones (motion + visuals + `get_multiplier_at`) | Works |
| Zone **gameplay** effect on harvest | **Not wired** (Stage B deferred — intentional) |
| Zone influence on migration / AI | **No** — do not wire to AI yet |
| AI migration | No — correct |
| T2 / T3 | No — correct |
| Heroes | No — correct |
| Places of Power | No — correct |
| Wave Spawner | Pressure Test Mode |
| Stage 1 acceptance | Practically confirmed; doc was lagging until this snapshot |

## F5-backed Stage 1 loop

```
workers → harvest → deposit → barracks → soldiers → attack → destruction → victory/defeat
```

Both player and team-1 AI use shared production / order / combat systems (not a separate wave spawner as the main opponent).

## Pointer sync

| File | Note |
|------|------|
| CURRENT_STATE | this snapshot |
| TODO | Stage 1 done items + Economy 1.5 next |
| TECH_DEBT | TD-01…TD-04 |
| GROK_WORKLOG | 2026-08-31 audit trail |
| 12_PROGRESSION | Stage 1 §7 definition still valid |

## Next action

1. Player formal Stage 1 sign-off (optional remaining F5).  
2. **AI Economy 1.5** (goal → demand → workers) before T2 — see TD-02.  
3. Optional later: TD-01 placement parity; zone harvest Stage B; victory-rule policy for TD-03.
