# PHASE_8_2_INTEGRATION.md

**Status:** Implemented on `nomads-wars-grok`  
**Date:** 2026-08-27  
**Depends on:** Phase 8.1 MobileTower (ACCEPTED)

---

## Scope delivered

| Feature | Implementation |
|---------|----------------|
| Deployment config | `Scripts/Data/DeploymentConfig.gd` + presets |
| Transit vulnerability | `BaseBuilding.damage()` multiplies when not DEPLOYED |
| Placement validation | `DeploymentComponent._validate_placement()` before UNPACKING |
| Progress bar | World-space mesh on `MobileBuilding` during PACKING/UNPACKING |
| Attack range ring | Watchtower ring visible in MOBILE / UNPACKING |
| UI overlap fix | `Scenes/UI/ui.tscn` — single `LeftPanel` VBox |

**Not in 8.2:** attack/production efficiency tables, horse logistics, settlement mass (see `DESIGN_DEPLOYMENT_EFFICIENCY.md` / backlog).

---

## Presets

| Building | pack | unpack | move speed | vulnerability |
|----------|------|--------|------------|---------------|
| TownCenter | 5.0s | 5.0s | 2.5 | 1.5 |
| Watchtower | 2.0s | 2.0s | 4.0 | 1.3 |

Applied in `_ready` via `DeploymentConfig.preset_*()` if `deployment_config` is null.

---

## Integration points

### Damage

```
BuildingDamageRules (type mult)
  → BaseBuilding.damage(amount)
       if state != DEPLOYED and vulnerability_multiplier > 1:
           amount *= vulnerability_multiplier
```

Log line (debug): `transit dmg 5 × 1.5 → 8 (state=2)`

### Unpack validation

Before entering UNPACKING, AABB-XZ overlap check vs other registered buildings.
On fail: stay MOBILE, emit `unpack_blocked`, print reason. No nav re-register.

### UI

- Progress bar: child of MobileBuilding, billboard, scale by transition progress.
- Range ring: CylinderMesh, radius from `attack_range_display` (14 for tower).
- Left HUD: BuildPanel + ActionPanel stacked in one VBox — no overlap.

---

## F5 acceptance

1. Pull, F5. TC log shows `pack=5.0s vuln=1.5`; tower `pack=2.0s speed=4.0 vuln=1.3`.
2. Pack tower → progress bar visible ~2s → MOBILE → range ring on.
3. RMB move → ARRIVED; U on free ground → UNPACKING → DEPLOYED; combat resumes.
4. Move tower onto another building footprint → U → `unpack blocked — footprint overlaps ...`, stays MOBILE.
5. Hit TC while MOBILE → `transit dmg` line, larger HP drop than 5.
6. Left panel buttons no longer stack on each other.

---

## Files touched

- `Scripts/Data/DeploymentConfig.gd` (new)
- `Scripts/Buildings/BaseBuilding.gd`
- `Scripts/Buildings/MobileBuilding.gd`
- `Scripts/Buildings/TownCenter.gd`
- `Scripts/Buildings/MobileTower.gd`
- `Scripts/Components/DeploymentComponent.gd`
- `Scenes/UI/ui.tscn`
- `Docs/PHASE_8_2_INTEGRATION.md` (this file)
