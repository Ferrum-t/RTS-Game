# CURRENT STATE

**Single source of truth (gameplay):** [`nomad_wars_v1_scope_and_architecture.md`](nomad_wars_v1_scope_and_architecture.md)  
**Lore vs MVP conflicts:** [`LORE_MVP_SCOPE_OVERRIDE.md`](LORE_MVP_SCOPE_OVERRIDE.md)  
**Progression vision (not MVP):** [`12_PROGRESSION_AND_TIER_SYSTEM.md`](12_PROGRESSION_AND_TIER_SYSTEM.md)

**Branch:** `nomads-wars-grok`

## Snapshot (2026-08-30)

| Item | State |
|------|--------|
| Formation-offsets + Phase 8.x | **ACCEPTED** |
| Environment Zones v1.0 | **ACCEPTED** |
| Enemy AI (threat, waves, names) | **ACCEPTED** |
| Polish + selection-aware control | **ACCEPTED** |
| Balance Pass (spawn tempo) | **IN PROGRESS** — 15/30/45 tested; **20 pending**; AFK criterion open |
| Spawner values (both files) | interval/delay **30**, max_alive **6** |
| `12_PROGRESSION_AND_TIER_SYSTEM.md` | **ADDED** (vision; T2/T3/Places/air/magic not v1.0) |
| `DESIGN_DEPLOYMENT_EFFICIENCY.md` §8 | Tier×mobility table filled **provisional** |
| Heroes / T2+ / Places of Power | **NOT v1.0** (override + vision) |

## Pointer sync (this commit)

| File | Synced with scope §0? |
|------|------------------------|
| `CURRENT_STATE.md` | **yes** |
| `TODO.md` | **yes** |
| `nomad_wars_v1_scope_and_architecture.md` | **yes** (2026-08-30) |
| `LORE_MVP_SCOPE_OVERRIDE.md` | update with T2+/Places/air |
| `DESIGN_DEPLOYMENT_EFFICIENCY.md` | **yes** (§8) |

## Next candidates

1. Finish Balance Pass (20s + AFK) — **when player resumes**
2. Building Health Bar (isolated)
3. Zones v1.1
4. T2 mobility only after the above

## Residual tech debt

- MatchManager vs EnemySpawner duplicated spawn config
- MOBILE unit pass-through
- Unpack validation (terrain/resources)
