extends CharacterBody3D

class_name BaseUnit


enum UnitState
{
	IDLE,
	MOVING,
	HARVESTING,
	RETURNING,
	BUILDING,
	ATTACKING,
	DEAD
}


@export var move_speed := 4.0
@export var max_health := 100
@export var deposit_distance := 3.0

var health := 100

var selected := false

var unit_state : UnitState = UnitState.IDLE

var move_target : Vector3

var harvest_target : BaseResource = null
var build_target : BaseBuilding = null
var attack_target : BaseUnit = null

var return_target : Node3D = null

var movement : MovementComponent
var inventory : InventoryComponent
var harvest : HarvestComponent


func _ready() -> void:
	health = max_health
	add_to_group("Unit")
	UnitManager.register_unit(self)

	movement = MovementComponent.new(self)
	inventory = InventoryComponent.new(self)
	harvest = HarvestComponent.new(self)


func _exit_tree() -> void:
	UnitManager.unregister_unit(self)


func _physics_process(delta: float) -> void:
	match unit_state:
		UnitState.IDLE:
			update_idle(delta)
		UnitState.MOVING:
			movement.update(delta)
		UnitState.HARVESTING:
			harvest.update(delta)
		UnitState.RETURNING:
			update_return(delta)
		UnitState.BUILDING:
			update_build(delta)
		UnitState.ATTACKING:
			update_attack(delta)
		UnitState.DEAD:
			pass


func update_idle(_delta: float) -> void:
	velocity = Vector3.ZERO


func update_return(delta: float) -> void:
	# Find Town Center if we don't have one yet
	if return_target == null or not is_instance_valid(return_target):
		var bm := get_node_or_null("/root/BuildingManager")
		if bm:
			return_target = bm.get_nearest_town_center(global_position)

		if return_target == null:
			print(name, " — no Town Center found, staying with full inventory")
			unit_state = UnitState.IDLE
			velocity = Vector3.ZERO
			return

	var distance := global_position.distance_to(return_target.global_position)

	# Move towards Town Center
	if distance > deposit_distance:
		move_target = return_target.global_position
		movement.update(delta)
		return

	# Arrived — deposit resources
	velocity = Vector3.ZERO
	var deposited_wood := inventory.wood
	inventory.clear()
	print(name, " deposited ", deposited_wood, " wood at ", return_target.name)

	return_target = null

	# Go back to harvesting if we still have a resource target
	if harvest_target != null and is_instance_valid(harvest_target):
		unit_state = UnitState.HARVESTING
	else:
		unit_state = UnitState.IDLE


func update_build(_delta: float) -> void:
	pass


func update_attack(_delta: float) -> void:
	pass


func set_move_target(target: Vector3) -> void:
	move_target = target
	unit_state = UnitState.MOVING
	harvest_target = null
	return_target = null


func set_harvest_target(resource: BaseResource) -> void:
	harvest_target = resource
	return_target = null
	unit_state = UnitState.HARVESTING


func set_build_target(building: BaseBuilding) -> void:
	build_target = building
	unit_state = UnitState.BUILDING


func set_attack_target(enemy: BaseUnit) -> void:
	attack_target = enemy
	unit_state = UnitState.ATTACKING


func select() -> void:
	selected = true
	print(name, " selected")


func deselect() -> void:
	selected = false
	print(name, " deselected")


func damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()


func die() -> void:
	unit_state = UnitState.DEAD
	queue_free()
