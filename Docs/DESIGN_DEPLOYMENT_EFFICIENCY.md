# DESIGN_DEPLOYMENT_EFFICIENCY.md

**Project:** Nomad Wars  
**Status:** Design Spec (mechanical contract)  
**Date:** 2026-08-27  
**Scope:** How deployment state affects building capabilities  
**Not for implementation in Phase 8.1**

---

## 1. Purpose

This document defines the **mechanical contract** between `DeploymentState` and the rest of the game systems.

It does **not** lock balance numbers.

Three levels must stay separate:

1. **Philosophy** — mobility has a cost (see `MOBILE_SETTLEMENTS.md`)
2. **Mechanical contract** — DEPLOYED / MOBILE / transition states change which functions are available and how strong they are (this document)
3. **Balance coefficients** — exact multipliers (future, after prototypes)

---

## 2. Source of truth

```
BaseBuilding
  ├── deployment_state : DeploymentState.State
  ├── get_current_stat(stat_name, base_value) → float
  │     ├── tier_modifiers
  │     └── deployment_overrides[deployment_state]
  └── recompute_stats()
```

Combat, Production, Range, Attack Speed, Vision etc. must read **resolved** values.
They must not hardcode `if mobile: ...`.

`BuildingDamageRules` currently only applies `DamageType` multipliers.
Deployment modifiers for incoming/outgoing damage belong in the same resolution path later (Phase 8.2+).

---

## 3. States

| State      | Meaning                          | Movement | Combat | Production |
|------------|----------------------------------|----------|--------|------------|
| DEPLOYED   | Fully functional camp            | No       | Full   | Full       |
| PACKING    | Transition → mobile              | No       | Reduced / limited | Off |
| MOBILE     | Caravan / on the move            | Yes      | Reduced | Off / limited |
| UNPACKING  | Transition → deployed            | No       | Reduced / limited | Off |

PACKING and UNPACKING are **distinct** from MOBILE.
They create a tactical vulnerability window.

---

## 4. Function categories (preferred over flat %)

Instead of "everything × 0.5", classify building functions:

**Category A — usable while mobile**  
Minimal defense, detection, command/vision, resource storage.

**Category B — degraded while mobile**  
Attack damage, attack range, attack speed, some production.

**Category C — requires DEPLOYED**  
Full production, research, construction, heavy siege abilities, most specials.

Town Center is special: it is the core of the society, not a regular tower.
Exact rules for TC production while MOBILE are still open design decisions.

---

## 5. Balance principles (more important than numbers)

1. Mobility must have a meaningful opportunity cost.
2. Mobility must not become a hard punishment.
3. Deployment penalties must not stack redundantly  
   (time + % + horses + mass all at once = death spiral).
4. A mobile building should retain enough function to remain useful  
   (especially towers protecting a caravan).
5. Tier progression should reduce mobility *penalties*,  
   not only increase raw power.
6. Exact coefficients are experimental until validated by gameplay.
7. The player must be able to **feel** the penalty  
   (UI indicator and/or clear visual change).

---

## 6. What is explicitly out of scope for now

- Concrete % tables (T1 40%, T2 70% …)
- Horse-based transport capacity
- Settlement mass / density / inertia
- Full aul raise (all buildings at once)
- Migration signals to enemies
- Vision changes while mobile
- Cancel/interrupt rules during PACKING (to be decided later)

These live in backlog / future docs.

---

## 7. Implementation order

| Phase | Goal |
|-------|------|
| 8.1   | MobileTower physical + nav + combat cycle works in DEPLOYED |
| 8.2   | Wire `deployment_overrides` into combat/production (small controlled experiment) |
| later | TC-specific rules, Tier reduction of penalties, horses, mass |

---

## 8. Open design questions (do not answer with code yet)

- TC Worker production while MOBILE: 0% or strongly reduced?
- Does MOBILE tower keep shooting (reduced) or stop completely?
- Can PACKING be cancelled? Until which point?
- Does MOBILE building remain a NavMesh obstacle or is footprint cleared?  
  (Current code clears footprint on MOBILE — keep as contract unless changed intentionally.)
- How is the efficiency penalty communicated to the player?
