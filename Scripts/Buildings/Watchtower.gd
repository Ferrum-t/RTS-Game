extends BaseBuilding

class_name Watchtower

## Phase 8.0 — stationary defensive tower.
## Auto-attack lives on child BuildingCombatComponent (timer scan of UnitManager.units).
## Phase 8.1 MobileTower will add DeploymentComponent — do not add it here.

func _ready() -> void:
	super()
	add_to_group("Obstacle")
	print("[TOWER] ", name, " ready team=", team_id, " HP=", health, "/", max_health)
