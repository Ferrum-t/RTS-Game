# TODO

**Source of truth:** `Docs/nomad_wars_v1_scope_and_architecture.md` §0 / §4  
**Lore vs MVP conflicts:** `Docs/LORE_MVP_SCOPE_OVERRIDE.md`

## Current Sprint

**Active:** Balance pass (waves / economy / HP — skilled player can win)

### Done (phases 7–12 +)

- [x] Phase 7–8.2, Stuck, Formation-offsets
- [x] Environment Zones v1.0 (A+B + visual priority)
- [x] Enemy AI strengthening
- [x] Polish: debug hotkeys gated, readable names
- [x] Selection-aware Pack/Unpack/RMB (selected vs all caravan)
- [x] Billboard pack bar (QuadMesh + camera basis)
- [x] Doc: `LORE_MVP_SCOPE_OVERRIDE.md` (universal MVP override; covers 05 + 09 hero lists)

## Next candidates (after balance)

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
