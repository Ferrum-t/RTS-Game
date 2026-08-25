extends StaticBody3D

class_name BaseBuilding

@export var team_id: int = 0
@export var max_health: int = 500
## Half-extents of footprint used for NavMesh obstruction (XZ)
@export var nav_half_extents: Vector3 = Vector3(2.2, 1.0, 2.2)

@export var tier: int = 1 # 1..3
## tier_modifiers[tier-1] -> Dictionary{stat_name: String -> multiplier: float}
## Defaults for F5: tier1=1.0x, tier2=1.5x, tier3=2.0x on max_health
@export var tier_modifiers: Array[Dictionary] = [
	{},
	{"max_health": 1.5},
	{"max_health": 2.0},
]
## deployment_overrides[DeploymentState.State] -> Dictionary{stat_name -> multiplier}
## Пустой по умолчанию — переходы между состояниями появятся в фазе 4.
@export var deployment_overrides: Dictionary = {}

var deployment_state: int = DeploymentState.State.DEPLOYED

var health: int = 500
var is_destroyed: bool = false


func get_current_stat(stat_name: String, base_value: float) -> float:
	var value := base_value
	if tier >= 1 and tier <= tier_modifiers.size():
		value *= float(tier_modifiers[tier - 1].get(stat_name, 1.0))
	var overrides: Dictionary = deployment_overrides.get(deployment_state, {})
	value *= float(overrides.get(stat_name, 1.0))
	return value


func _ready() -> void:
	max_health = int(get_current_stat("max_health", float(max_health)))
	health = max_health
	is_destroyed = false

	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.register_building(self)

	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.register_building(self, nav_half_extents)


func _exit_tree() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.unregister_building(self)

	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.unregister_building(self)


func damage(amount: int) -> void:
	if is_destroyed:
		return
	health -= amount
	if health <= 0:
		health = 0
		die()


func die() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	health = 0
	print(name, " destroyed (team ", team_id, ")")
	queue_free()
