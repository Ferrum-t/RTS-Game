extends RefCounted

class_name HarvestComponent

var owner: BaseUnit

## Stand this far from the resource while gathering (must be > collision radius)
var approach_distance: float = 2.2
var harvest_amount: int = 10
var harvest_interval: float = 0.8
var _timer: float = 0.0


func _init(unit: BaseUnit) -> void:
	owner = unit


func update(delta: float) -> void:
	if owner.inventory != null and owner.inventory.is_full():
		print(owner.name, " inventory full, returning to Town Center")
		owner.unit_state = BaseUnit.UnitState.RETURNING
		owner.return_target = null
		owner.velocity = Vector3.ZERO
		return

	var resource: BaseResource = owner.harvest_target
	if resource == null or not is_instance_valid(resource):
		owner.harvest_target = null
		owner.unit_state = BaseUnit.UnitState.IDLE
		owner.velocity = Vector3.ZERO
		return

	var to_res: Vector3 = resource.global_position - owner.global_position
	to_res.y = 0.0
	var dist := to_res.length()

	# Approach — stop at approach_distance, do not walk into the collider
	if dist > approach_distance:
		var stand_pos: Vector3 = resource.global_position - to_res.normalized() * approach_distance
		stand_pos.y = 0.0
		owner.move_target = stand_pos
		if owner.movement:
			owner.movement.set_target(stand_pos)
			# Temporary MOVING-like path without leaving HARVESTING state
			owner.movement.update(delta)
		return

	# In range — gather
	owner.velocity = Vector3.ZERO
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = harvest_interval

	if resource.has_method("harvest"):
		var got: int = resource.harvest(harvest_amount)
		if got > 0 and owner.inventory:
			owner.inventory.add_wood(got)
			print(owner.name, " Wood: ", owner.inventory.wood, "/", owner.inventory.max_wood)
		elif got <= 0:
			# Resource depleted
			owner.harvest_target = null
			owner.unit_state = BaseUnit.UnitState.IDLE
