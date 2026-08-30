# TODO

**Source of truth:** `Docs/nomad_wars_v1_scope_and_architecture.md` §0 / §4  
**Lore vs MVP conflicts:** `Docs/LORE_MVP_SCOPE_OVERRIDE.md`  
**Progression vision (not MVP):** `Docs/12_PROGRESSION_AND_TIER_SYSTEM.md`

## Current Sprint

**Active:** Balance pass — **paused mid-pass** for design-sync (tiers / Places of Power vision).

Wave tempo data:

| Interval | Note |
|----------|------|
| 15s | Survive ~wave 9; still feels rushed |
| 30s | Victory wave 5 with army; gaps feel long; no AFK log |
| 45s | Too soft; early worker-rush |
| **20s** | **Next isolated test** (not run yet) |

### Done (phases 7–12 +)

- [x] Phase 7–8.2, Stuck, Formation-offsets
- [x] Environment Zones v1.0 (A+B + visual priority)
- [x] Enemy AI strengthening
- [x] Polish: debug hotkeys gated, readable names
- [x] Selection-aware Pack/Unpack/RMB (selected vs all caravan)
- [x] Billboard pack bar (QuadMesh + camera basis)
- [x] Doc: `LORE_MVP_SCOPE_OVERRIDE.md`
- [x] Doc: `12_PROGRESSION_AND_TIER_SYSTEM.md` (vision only)
- [x] Doc: `DESIGN_DEPLOYMENT_EFFICIENCY.md` §8 tier×mobility table (provisional)

## Next candidates

- [ ] **Balance Pass finish** — interval 20 + AFK tail after wave 5
- [ ] **Building Health Bar** — billboard on damage only (all buildings)
- [ ] **Zones v1.1** — seasonal / frontal pressure
- [ ] Unpack validation vs resources/terrain
- [ ] Raise Settlement (TC only) as explicit separate command
- [ ] T2 mobility row only (after T1 balance + Zones v1.1) — see `12_PROGRESSION…`

---

## Technical Debt Backlog

- [ ] **EnemySpawner config single source** (MatchManager currently overrides script defaults)
- [ ] **Staggered Nav Updates:** frame-sliced path recalc at 50+ units
- [ ] **Aggro Leashing**
- [ ] **Data-Driven Stats** in `.tres`
- [ ] **Safe Instance Checks**
- [ ] **Idle Worker UI Event**
- [ ] Watchtower ghost shared footprint
- [ ] MOBILE unit↔building physical collision (optional polish)
- [ ] Multi-select buildings (Shift+click)

---

## Known residual

- [ ] SiegeUnit corners / agent radius vs bake
- [ ] Mobile TC path through resource collision (partial)
- [ ] RVO fine-tune / wall-nudge near buildings
