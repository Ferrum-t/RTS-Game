# Phase 8.0 Integration — Watchtower

**Branch:** `nomads-wars-grok`  
**Status:** wired, waiting F5  
**Frozen:** Combat / Deployment / Team / Match win-lose / NavBake — not refactored.

---

## Already in repo (not changed this pass)

- `ResourceManager.cost_watchtower()` → `make_cost(40, 20)` (Wood 40 / Stone 20).
  Catalog cost lives on `BuildingData` fields, not a string-keyed dict.
- `BuildingManager.watchtowers_list` + `register`/`unregister` + `get_first_watchtower()`.
  `building is Watchtower` now resolves because `class_name Watchtower` exists.

---

## Added

| File | Role |
|------|------|
| `Scripts/Components/BuildingCombatComponent.gd` | Auto-attack. Scan `UnitManager.units` every `scan_interval=0.4`. No Area3D, no PhysicsQuery. Calls frozen `BaseUnit.damage(amount)`. |
| `Scripts/Buildings/Watchtower.gd` | `extends BaseBuilding`. Stationary. No DeploymentComponent (that is 8.1). |
| `Scenes/Buildings/Watchtower.tscn` | CharacterBody3D + mesh + collision + combat child. HP 350. |
| `Data/Buildings/WatchtowerData.tres` | Catalog entry: Wood 40 / Stone 20, shared ghost. |
| `Data/BuildCatalog.tres` | Third button in BuildPanel. |
| `Scripts/Systems/MatchManager.gd` | Spawns player Watchtower at TC + `(0, 0, 6)` on the enemy march path. Win/Lose formula unchanged (all buildings still count). |

---

## Combat contract (tower → unit)

- Filter: `team_id` != host, not DEAD, in `attack_range` (14).
- Keep target until `attack_range * 1.15` (anti-flicker only; not unit CombatComponent hysteresis).
- Strike: 12 dmg / 1.0s cooldown, `DamageType.RANGED` (unused vs units; reserved).
- Fires only while `deployment_state == DEPLOYED` (8.1-ready, no extra work now).
- Does **not** issue Orders. Does **not** attack buildings.

Logs (filter Output on `[TOWER]`):

```
[TOWER] Watchtower ready team=0 HP=350/350
[TOWER] Watchtower combat ready team=0 range=14.0 dmg=12
Watchtower registered: Watchtower
[TOWER] Watchtower acquired Soldier dist=11.2 team=1
[TOWER] Watchtower hits Soldier for 12 dmg (HP 88/100)
```

---

## F5 checklist

1. Pull `nomads-wars-grok`, F5 World.
2. Confirm Output: `Watchtower registered` + `[TOWER] ... ready`.
3. Wait for team-1 Soldier to march toward player TC (~10s first wave / start soldier).
4. Confirm `[TOWER] acquired` then repeating `hits` — no Area3D, no physics query errors.
5. Friendly workers next to the tower are **not** acquired (same `team_id`).
6. BuildPanel shows **Watchtower (W:40, S:20)**. Extra tower needs 20 stone (start stone is 0).
7. Match still prints PLAYING / VICTORY / DEFEAT. DEFEAT now requires destroying TC **and** the Watchtower (frozen "all buildings" rule).

Paste the `[TOWER]` slice here if anything looks wrong.

---

## Not in 8.0

- MobileTower / DeploymentComponent on towers (Phase 8.1).
- EnemyAI Watchtower scoring (generic building `-dist` is enough).
- Unique ghost mesh (reuses `GhostBuilding.tscn`).
