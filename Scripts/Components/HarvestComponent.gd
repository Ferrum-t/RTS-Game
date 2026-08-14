extends RefCounted

class_name HarvestComponent

var owner: BaseUnit

var harvest_timer := 0.0
var harvest_interval := 1.0
var harvest_amount := 10
var approach_distance := 2.0


func _init(unit: BaseUnit) -> void:
	owner = unit


func update(delta: float) -> void:
	if owner.harvest_target == null or not is_instance_valid(owner.harvest_target):
		owner.harvest_target = null
		owner.unit_state = BaseUnit.UnitState.IDLE
		return

	# Inventory full → go return resources
	if owner.inventory.is_full():
		owner.unit_state = BaseUnit.UnitState.RETURNING
		print(owner.name, " inventory full, returning to Town Center")
		return

	var resource := owner.harvest_target
	var distance := owner.global_position.distance_to(resource.global_position)

	# Approach resource
	if distance > approach_distance:
		owner.move_target = resource.global_position
		owner.movement.update(delta)
		return

	# Stop and harvest
	owner.velocity = Vector3.ZERO
	harvest_timer += delta

	if harvest_timer >= harvest_interval:
		harvest_timer = 0.0
		owner.inventory.add_wood(harvest_amount)
		print(
			owner.name,
			" Wood: ",
			owner.inventory.wood,
			"/",
			owner.inventory.capacity
		)
