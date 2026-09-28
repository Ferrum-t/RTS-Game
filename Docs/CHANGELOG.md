# CHANGELOG

## 2026-09-28 — M21.4 AI Food + Yurt ACCEPTED

- `EconomicAIController`: Food < 6 → build Yurt (max 2) after 1st Barracks
- Restored AI harvest resource pick (`BaseResource.resource_amount`) after regression
- AI income via existing Yurt tick; train resumes when Food recovers
- F5: harvest/deposit, yurts 1–2, expand flags, 0 script errors

## 2026-09-28 — Mobility / deploy notes

- Manual Unpack remains default (no auto-unpack on ARRIVED)
- TD-DEPLOY-01: optional auto-unpack UX toggle — idea only in TECH_DEBT

## 2026-09-25 — M20.2 Fog Visual (B2) ACCEPTED

- World + minimap fog from shared `VisibilityMap` (cell 4, no soft edges)
- Enemy units/buildings hidden in 3D outside VISIBLE
- Pixelated world fog accepted as intentional v0; polish out of scope
- ConstructionManager: safe handling of freed pending builder


## v0.1

- Selection system
- Multi-selection
- Building placement
- Ghost building
- Command system
- MovementComponent
- Base FSM
- Unit registration

---

## Next

Open next LOCK from CURRENT_STATE / playtest priorities
