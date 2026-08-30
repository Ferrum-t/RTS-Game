# DESIGN_DEPLOYMENT_EFFICIENCY.md

**Project:** Nomad Wars  
**Status:** Design Spec (mechanical contract)  
**Date:** 2026-08-27 (tier table filled 2026-08-30 — still provisional)  
**Scope:** How deployment state affects building capabilities  
**Related vision:** `12_PROGRESSION_AND_TIER_SYSTEM.md` (T1–T3 names + mobility row)

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
Deployment modifiers for incoming/outgoing damage belong in the same resolution path later.

---

## 3. States

| State      | Meaning                          | Movement | Combat | Production |
|------------|----------------------------------|----------|--------|------------|
| DEPLOYED   | Fully functional camp            | No       | Full   | Full       |
| PACKING    | Transition → mobile              | No       | Reduced / limited | Off |
| MOBILE     | Caravan / on the move            | Yes      | Reduced / off (current v1.0: attack off) | Off / limited |
| UNPACKING  | Transition → deployed            | No       | Reduced / limited | Off |

PACKING and UNPACKING are **distinct** from MOBILE.
They create a tactical vulnerability window.

**v1.0 conscious choice:** MOBILE combat attack **off**; transit vuln TC ×1.5 / tower ×1.3. Revisit only on a dedicated balance milestone (`12_PROGRESSION…` tier row may soften vuln later).

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

- Horse-based transport capacity
- Settlement mass / density / inertia
- Migration signals to enemies
- Vision changes while mobile
- Cancel/interrupt rules during PACKING (to be decided later)
- Implementing T2/T3 upgrade UI / costs (see `12_PROGRESSION_AND_TIER_SYSTEM.md`)

These live in backlog / vision docs.

---

## 7. Implementation order

| Phase | Goal |
|-------|------|
| 8.1–8.2 | MobileTower + DeploymentConfig / transit vuln — **DONE** |
| v1.0 | Binary MOBILE combat off + fixed vuln — **DONE** (conscious) |
| later | Fill `tier_modifiers` from §8 table (T2 first); TC-specific MOBILE production rules |
| later | Season resistance while migrating (needs Zones v1.1) |

---

## 8. Tier × mobility table (PROVISIONAL — do not implement until T1 balance is closed)

From vision doc `12_PROGRESSION_AND_TIER_SYSTEM.md` §3. Names: T1 Аул / T2 Орда / T3 Каганат.

| Parameter | T1 Aul | T2 Horde | T3 Kaganate |
|-----------|--------|----------|-------------|
| pack/unpack time (× base) | 1.0 | 0.7 | 0.4 |
| mobile move_speed (× base) | 1.0 | 1.3 | 1.6 |
| vulnerability_multiplier (transit) | current (1.5 / 1.3) | −20% | −40% |
| tower range / dmg (DEPLOYED) | base | +15% | +30% |
| resistance to seasonal zone penalty | none | partial | immunity while migrating |

**MVP:** only T1 column behavior as currently coded. T2/T3 rows are design targets for post–v1.0 (or late v1.x after Zones v1.1), not silent scope expansion.

---

## 9. Open design questions (do not answer with code yet)

- TC Worker production while MOBILE: 0% or strongly reduced?
- After balance: does MOBILE tower keep reduced shooting or stay fully off?
- Can PACKING be cancelled? Until which point?
- Does MOBILE building remain a NavMesh obstacle or is footprint cleared?  
  (Current code clears footprint on MOBILE — keep as contract unless changed intentionally.)
- How is the efficiency / tier bonus communicated to the player?
- Exact numeric costs for tier upgrade (must not import WC3 tables blindly).
