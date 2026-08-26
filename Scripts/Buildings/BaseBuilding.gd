extends CharacterBody3D

class_name BaseBuilding

## Static gameplay buildings (Barracks) and base for MobileBuilding (TownCenter).
## CharacterBody3D so TownCenter can move without losing BaseBuilding type for siege/CommandManager.
## Non-mobile buildings never call move_and_slide with nonzero velocity.

@export var team_id: int = 0
@export var max_health: int = 500
## Half-extents of footprint used for NavMesh obstruction (XZ)
@export var nav_half_extents: Vector3 = Vector3(2.2, 1.0, 2.2)

@export var tier: int = 1 # 1..3
@export var tier_modifiers: Array[Dictionary] = [
	{},
	{"max_health": 1.5},
	{"max_health": 2.0},
]
## deployment_overrides[DeploymentState.State] -> Dictionary{stat_name -> multiplier}
@export var deployment_overrides: Dictionary = {}

## Phase 6: enable loot siphon on raid damage (TownCenter / Barracks).
@export var is_lootable: bool = true
@export var loot_ratio: float = 0.5

var deployment_state: int = DeploymentState.State.DEPLOYED

## Value from inspector before tier/deployment resolve (set once in _ready)
var base_max_health: int = 500
var health: int = 500
var is_destroyed: bool = false
var lootable: LootableComponent = null


func get_current_stat(stat_name: String, base_value: float) -> float:
	var value := base_value
	if tier >= 1 and tier <= tier_modifiers.size():
		value *= float(tier_modifiers[tier - 1].get(stat_name, 1.0))
	var overrides: Dictionary = deployment_overrides.get(deployment_state, {})
	value *= float(overrides.get(stat_name, 1.0))
	return value


func recompute_stats() -> void:
	max_health = int(get_current_stat("max_health", float(base_max_health)))
	health = mini(health, max_health)


func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED

	base_max_health = max_health
	max_health = int(get_current_stat("max_health", float(base_max_health)))
	health = max_health
	is_destroyed = false
	deployment_state = DeploymentState.State.DEPLOYED

	if is_lootable:
		_setup_lootable()

	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.register_building(self)

	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.register_building(self, nav_half_extents)


func _setup_lootable() -> void:
	lootable = LootableComponent.new()
	lootable.name = "LootableComponent"
	lootable.loot_ratio = loot_ratio
	add_child(lootable)
	lootable.setup(self)


func _exit_tree() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.unregister_building(self)

	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.unregister_building(self)


## amount is already modified (building multipliers applied by attacker).
## attacker_team_id >= 0 triggers loot siphon when lootable is present.
func damage(amount: int, attacker_team_id: int = -1) -> void:
	if is_destroyed:
		return
	health -= amount
	if lootable != null and attacker_team_id >= 0 and amount > 0:
		var looted: Dictionary = lootable.extract_loot(float(amount), attacker_team_id)
		var remaining: Dictionary = lootable.snapshot_stock()
		print(
			"[RAID] Attacker dealt ", amount,
			" damage (team ", attacker_team_id, "). Siphoned loot: ",
			LootableComponent.format_stock(looted),
			". Enemy remaining: ",
			LootableComponent.format_stock(remaining)
		)
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
