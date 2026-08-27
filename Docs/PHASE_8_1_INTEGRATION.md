# PHASE_8_1_INTEGRATION.md

**Status:** Implemented on branch `nomads-wars-grok`  
**Date:** 2026-08-27

---

## What changed

| File | Change |
|------|--------|
| `Scripts/Buildings/MobileTower.gd` | **New.** Extends `MobileBuilding`. Deployment via `DeploymentComponent`. Debug keys P/M/U. |
| `Scripts/Buildings/Watchtower.gd` | Now `extends MobileTower` (keeps `class_name Watchtower`). |
| Scene `Watchtower.tscn` | Unchanged — still has child `BuildingCombatComponent`. |

No changes to `BaseBuilding`, `DeploymentComponent`, `BuildingCombatComponent`, `NavigationBakeService`, MatchManager.

---

## Hierarchy

```
BaseBuilding
  └── MobileBuilding          # creates DeploymentComponent in _ready
        └── MobileTower       # Obstacle group, debug pack/move/unpack
              └── Watchtower  # class_name for BuildingManager
```

Scene nodes (unchanged):

```
Watchtower (CharacterBody3D)  ← script Watchtower.gd
├── MeshInstance3D
├── CollisionShape3D
└── BuildingCombatComponent   ← attack only while DEPLOYED
```

---

## Behaviour contract (Phase 8.1)

| State | Movement | Nav footprint | Combat |
|-------|----------|--------------|--------|
| DEPLOYED | no | registered | **on** (BuildingCombatComponent) |
| PACKING | no | still registered until pack finishes | **off** |
| MOBILE | yes (building-mover velocity) | unregistered | **off** |
| UNPACKING | no | re-registered at start of unpack | **off** |

Combat gate is already in `BuildingCombatComponent`:

```gdscript
if b.deployment_state != DeploymentState.State.DEPLOYED:
    _clear_target("not deployed")
    return
```

PACKING / UNPACKING are atomic timers inside `DeploymentComponent` — new pack/unpack requests are rejected until the timer finishes (`can_pack` / `can_unpack`).

**No** deployment efficiency multipliers. Stats stay 100%.

---

## F5 acceptance

1. Pull `nomads-wars-grok`, F5.
2. Output: `Watchtower registered`, `[TOWER] ... ready ... deployment=0`, combat ready.
3. Select tower context / debug (team 0):
   - **P** → `Deployment: PACKING` → `MOBILE (footprint cleared)`
   - **M** → `Deployment: move to ...` → `ARRIVED`
   - **U** → `Deployment: UNPACKING` → `DEPLOYED at ...`
4. While DEPLOYED, enemy Soldier in range → `[TOWER] acquired` / `hits` as in 8.0.
5. While MOBILE / PACKING / UNPACKING → no new acquires (combat gated).
6. No type/Variant errors in Output.

---

## Out of scope (do not regress into 8.1)

- `deployment_overrides` affecting damage/range/speed
- Horses, settlement mass, aul raise
- NavigationAgent3D on buildings (TownCenter uses velocity mover — same path)
- UI efficiency indicators
