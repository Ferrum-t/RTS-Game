extends RefCounted

class_name HarvestComponent

## M2 + harvest-approach fix: reports Status only.
## Does NOT drive velocity / move_and_slide / NavigationAgent.
## BaseUnit + MovementComponent handle HOW to reach the resource.

enum Status {
	IDLE,
	MOVING_TO_RESOURCE,
	GATHERING,
	BAG_FULL,
	RESOURCE_GONE,
	CANCELLED,
}

var owner: BaseUnit
var status: Status = Status.IDLE

var approach_distance: float = 2.5
var harvest_amount: int = 10
var harvest_interval: float = 0.7
var _timer: float = 0.0
var _stuck_near: float = 0.0

## Last computed stand position (for BaseUnit → Movement)
var approach_pos: Vector3 = Vector3.ZERO


func _init(unit: BaseUnit) -> void:
	owner = unit


func reset() -> void:
	_timer = 0.0
	_stuck_near = 0.0
	approach_pos = Vector3.ZERO
	status = Status.IDLE


func get_status() -> Status:
	return status


## Stand point near resource (same formula as before: ~2.125 from center).
func get_approach_position(resource: BaseResource) -> Vector3:
	if resource == null or not is_instance_valid(resource):
		return owner.global_position
	var to_res: Vector3 = resource.global_position - owner.global_position
	to_res.y = 0.0
	var dist := to_res.length()
	var stand: Vector3 = resource.global_position
	if dist > 0.01:
		stand = resource.global_position - to_res.normalized() * (approach_distance * 0.85)
	stand.y = 0.0
	return stand


func update(delta: float) -> void:
	if owner.inventory != null and owner.inventory.is_full():
		print(owner.name, " inventory full, returning to Town Center")
		_stuck_near = 0.0
		status = Status.BAG_FULL
		return

	var resource: BaseResource = owner.harvest_target
	if resource == null or not is_instance_valid(resource):
		status = Status.RESOURCE_GONE
		return

	var to_res: Vector3 = resource.global_position - owner.global_position
	to_res.y = 0.0
	var dist := to_res.length()

	approach_pos = get_approach_position(resource)

	var in_range := dist <= approach_distance
	if not in_range and dist <= approach_distance + 1.0:
		_stuck_near += delta
		if _stuck_near >= 0.35:
			in_range = true
	else:
		_stuck_near = 0.0

	if not in_range:
		# BaseUnit drives Movement toward approach_pos
		if status != Status.MOVING_TO_RESOURCE:
			print("[HARVEST] ", owner.name, " approach target=", resource.name, " stand_pos=", approach_pos)
		status = Status.MOVING_TO_RESOURCE
		return

	# Gather — no locomotion here
	if status != Status.GATHERING:
		print("[HARVEST] ", owner.name, " GATHERING at ", resource.name)
	status = Status.GATHERING
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = harvest_interval

	var got: int = resource.harvest(harvest_amount)
	if got <= 0:
		print(owner.name, " — resource empty")
		status = Status.RESOURCE_GONE
		return

	if owner.inventory == null:
		return

	var space_left: int = owner.inventory.capacity - owner.inventory.get_total()
	if space_left <= 0:
		status = Status.BAG_FULL
		return
	got = mini(got, space_left)

	_add_to_inventory(resource, got)

	if owner.inventory.is_full():
		print(owner.name, " inventory full, returning to Town Center")
		status = Status.BAG_FULL


func _add_to_inventory(resource: BaseResource, amount: int) -> void:
	var ti: int = int(resource.resource_type)
	match ti:
		1:
			owner.inventory.add_stone(amount)
			print(owner.name, " Stone: ", owner.inventory.stone, " (bag ", owner.inventory.get_total(), "/", owner.inventory.capacity, ")")
		2:
			owner.inventory.gold = mini(owner.inventory.gold + amount, owner.inventory.capacity)
			print(owner.name, " Gold: ", owner.inventory.gold)
		3:
			owner.inventory.food = mini(owner.inventory.food + amount, owner.inventory.capacity)
			print(owner.name, " Food: ", owner.inventory.food)
		_:
			owner.inventory.add_wood(amount)
			print(owner.name, " Wood: ", owner.inventory.wood, " (bag ", owner.inventory.get_total(), "/", owner.inventory.capacity, ")")
