# PHASE_8_1_MOBILE_TOWER.md

**Status:** Next implementation phase  
**Depends on:** Phase 8.0 Watchtower (ACCEPTED)  
**Date:** 2026-08-27

---

## Goal

Prove that a Watchtower can:

```
DEPLOYED → PACKING → MOBILE → move → ARRIVED → UNPACKING → DEPLOYED
```

and that combat (from 8.0) still works correctly when the tower is DEPLOYED again.

This phase does **not** implement deployment efficiency multipliers.

---

## Architecture rule

MobileTower reuses the existing mobile-building contract:

```
CharacterBody3D
    └── DeploymentComponent (or equivalent building-mover)
          ├── PACKING
          ├── MOBILE
          ├── UNPACKING
          └── DEPLOYED
```

Do **not** attach `MovementComponent` from units.
Use the same building-mover path that TownCenter already uses.

---

## In scope

1. Watchtower can enter PACKING → MOBILE.
2. While MOBILE it can receive a move order and travel.
3. On arrive → UNPACKING → DEPLOYED.
4. NavigationBakeService: footprint cleared on MOBILE, re-registered on DEPLOYED.
5. Combat (BuildingCombatComponent from 8.0) remains active only in DEPLOYED  
   (or follows current existing behaviour — do not invent new efficiency rules).
6. Acceptance logs similar to existing TownCenter deployment logs.

---

## Explicitly out of scope

- `deployment_overrides` affecting damage / range / attack speed
- Tier-based penalty reduction
- Horse / transport cost
- Settlement mass
- Raise entire aul
- UI efficiency indicators
- Cancel PACKING rules
- Vision changes
- Any balance coefficients

Those belong to Phase 8.2+ and design docs.

---

## Acceptance (F5)

1. Spawn / place Watchtower.
2. Issue raise / pack command → log shows PACKING → MOBILE.
3. Issue move order → tower moves, NavMesh footprint updated.
4. Arrive → UNPACKING → DEPLOYED, footprint restored.
5. Enemy soldier enters range while DEPLOYED → `[TOWER] acquired` / `hits` as in 8.0.
6. No errors, no Variant/type warnings in Output.

---

## Notes

- Keep changes minimal and local.
- Prefer extending existing DeploymentComponent / TownCenter mover rather than new movement systems.
- After 8.1 is accepted, Phase 8.2 can safely experiment with efficiency.
