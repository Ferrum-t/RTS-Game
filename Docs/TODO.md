# TODO

**Source of truth:** `Docs/nomad_wars_v1_scope_and_architecture.md` §0 / §4

## Current Sprint

- [x] Phase 7–8.2, Stuck, Formation-offsets
- [x] Environment Zones v1.0 (A+B + visual priority)
- [x] Enemy AI strengthening
- [x] Polish: debug hotkeys gated, readable names
- [x] Selection-aware Pack/Unpack/RMB (selected vs all caravan)
- [x] Billboard pack bar (QuadMesh + camera basis)

## Next candidates (pick one per session)

- [ ] **Balance pass** — waves, building costs, harvest rates, HP so a skilled player can win
- [ ] **Zones v1.1** — seasonal / frontal pressure (replace pure blobs)
- [ ] Unpack validation vs resources/terrain
- [ ] Raise Settlement (TC only) as explicit separate command

---

## Technical Debt Backlog

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
