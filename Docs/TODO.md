# TODO

**Source of truth for milestones:** `Docs/nomad_wars_v1_scope_and_architecture.md` §0 / §4

## Current Sprint

- [x] Phase 7 — Enemy AI Waves & Match Loop
- [x] Deposit team_id filter (no enemy TC)
- [x] Attack Hysteresis & RVO Avoidance
- [x] Phase 8.0–8.2 Watchtower / MobileTower / DeploymentConfig
- [x] Stuck detection (STUCK stays MOBILE, no auto-unpack)
- [x] Billboard pack/unpack progress bar
- [ ] **Formation-offsets** — multi-MOBILE RMB destinations (code in; **WAITING F5**)

---

## Technical Debt Backlog

- [ ] **Staggered Nav Updates:** frame-sliced path recalc at 50+ units
- [ ] **Aggro Leashing:** chase distance limit + return home
- [ ] **Data-Driven Stats:** HP / damage / speed / range in `.tres`
- [ ] **Safe Instance Checks:** stronger `is_instance_valid()` on mass destroy
- [ ] **Idle Worker UI Event:** no own-team TC for deposit
- [ ] Watchtower ghost uses shared `GhostBuilding.tscn` (footprint larger than tower)
- [ ] Hide debug hotkeys P/M/U/C/R before public build
- [ ] Readable names for enemy buildings (not `@CharacterBody3D@N`)

---

## Known residual (not blocking formation F5)

- [ ] SiegeUnit corners / larger agent radius vs bake
- [ ] Mobile TC path through resource collision (partial)
- [ ] RVO fine-tune per unit type (Siege larger radius)
- [ ] RVO wall-nudge near building corners (accepted tech debt)

---

## Next after F5 formation-offsets

1. Environment Zones (external pressure — mobility needs a reason)
2. Open design decisions already fixed in scope §0 (MOBILE combat binary, selection-aware building move deferred)
3. Medium: placement validation vs resources/terrain (C)
4. Later: Enemy AI vs MOBILE buildings (D)
