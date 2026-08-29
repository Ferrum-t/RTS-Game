# CURRENT STATE

**Single source of truth (gameplay):** [`nomad_wars_v1_scope_and_architecture.md`](nomad_wars_v1_scope_and_architecture.md)  
**Lore vs MVP conflicts:** [`LORE_MVP_SCOPE_OVERRIDE.md`](LORE_MVP_SCOPE_OVERRIDE.md)

**Branch:** `nomads-wars-grok`

## Snapshot (2026-08-29)

| Item | State |
|------|--------|
| Formation-offsets + Phase 8.x | **ACCEPTED** |
| Environment Zones v1.0 (blobs + harvest mult + visual priority) | **ACCEPTED** |
| Enemy AI (threat, waves, names) | **ACCEPTED** |
| Polish (debug hotkeys gated, readable names) | **ACCEPTED** |
| Selection-aware building control (selected vs entire caravan) | **ACCEPTED** |
| Doc sync: heroes NOT v1.0 MVP | **DONE** (`LORE_MVP_SCOPE_OVERRIDE.md`) |
| Known lore conflicts: 05 §37, 09 §32 (HERO in MVP lists) | **OVERRIDDEN** |
| `01_WORLD_AND_PLANET.md` | **EXISTS** |
| Raise TC-only as separate command | Named backlog |

## Pointer sync (this commit)

| File | Synced with scope §0? |
|------|------------------------|
| `CURRENT_STATE.md` | **yes** |
| `TODO.md` | **yes** (sprint = balance pass) |
| `ROADMAP.md` | yes (from prior sync; still valid) |
| `GROK_WORKLOG.md` | update with this override in next worklog entry |
| `05_FACTIONS_MVP_OVERRIDE.md` | **pointer** → `LORE_MVP_SCOPE_OVERRIDE.md` |

## Next candidates

1. **Balance pass** (waves / economy / HP) — **Current Sprint**
2. Zones v1.1 (seasonal migration pressure)
3. Unpack vs resources/terrain
4. Tech debt: MOBILE collision, multi-select (Shift)

## Residual tech debt

- MOBILE unit pass-through
- Unpack validation (terrain/resources)
- SiegeUnit agent radius vs bake (minor)
