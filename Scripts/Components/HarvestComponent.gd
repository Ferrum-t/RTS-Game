extends RefCounted

class_name HarvestComponent

## M2 + harvest-approach: reports Status only.
## Does NOT drive velocity / move_and_slide / NavigationAgent.
## stand_pos is computed once per harvest order and snapped to NavMesh.
## Environment Zones Stage B: per-tick gather amount × get_multiplier_at(resource).

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

## Locked stand position for current harvest order (not recomputed each frame).
var approach_pos: Vector3 = Vector3.ZERO
var _stand_locked: bool = false

## Last zone multiplier applied while gathering (for change-only debug print).
var _last_zone_mult: float = -1.0


func _init(unit: BaseUnit) -> void:
	owner = unit


func reset() -> void:
	_timer = 0.0
	_stuck_near = 0.0
	approach_pos = Vector3.ZERO
	_stand_locked = false
	_last_zone_mult = -1.0
	status = Status.IDLE


func get_status() -> Status:
	return status


## Stand point near resource, snapped onto walkable NavMesh.
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
	return _snap_to_navmesh(stand)


func _snap_to_navmesh(pos: Vector3) -> Vector3:
	if owner == null or not is_instance_valid(owner):
		return pos
	var world := owner.get_world_3d()
	if world == null:
		return pos
	var map_rid: RID = world.get_navigation_map()
	if not map_rid.is_valid():
		return pos
	var closest: Vector3 = NavigationServer3D.map_get_closest_point(map_rid, pos)
	closest.y = 0.0
	return closest


func _ensure_stand_locked(resource: BaseResource) -> void:
	if _stand_locked:
		return
	approach_pos = get_approach_position(resource)
	_stand_locked = true


func _zone_multiplier_at(resource: BaseResource) -> float:
	var ez: Node = Engine.get_main_loop().root.get_node_or_null("/root/EnvironmentZoneService")
	if ez == null:
		return 1.0
	if not ez.has_method("get_multiplier_at"):
		return 1.0
	return float(ez.call("get_multiplier_at", resource.global_position))


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

	_ensure_stand_locked(resource)

	var to_res: Vector3 = resource.global_position - owner.global_position
	to_res.y = 0.0
	var dist := to_res.length()

	var in_range := dist <= approach_distance
	if not in_range and dist <= approach_distance + 1.0:
		_stuck_near += delta
		if _stuck_near >= 0.35:
			in_range = true
	else:
		_stuck_near = 0.0

	if not in_range:
		if status != Status.MOVING_TO_RESOURCE:
			print("[HARVEST] ", owner.name, " approach target=", resource.name, " stand_pos=", approach_pos)
		status = Status.MOVING_TO_RESOURCE
		return

	if status != Status.GATHERING:
		print("[HARVEST] ", owner.name, " GATHERING at ", resource.name)
	status = Status.GATHERING
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = harvest_interval

	# Environment Zones Stage B: scale per-tick request by zone at resource position.
	var zone_mult: float = _zone_multiplier_at(resource)
	if _last_zone_mult < 0.0:
		_last_zone_mult = zone_mult
	elif not is_equal_approx(zone_mult, _last_zone_mult):
		print(
			"[ZONE] ", owner.name, " harvesting ", resource.name,
			" — zone_mult changed ", _last_zone_mult, " → ", zone_mult
		)
		_last_zone_mult = zone_mult

	var request_amount: int = maxi(1, int(round(float(harvest_amount) * zone_mult)))
	var got: int = resource.harvest(request_amount)
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
		4:
			owner.inventory.add_horses(amount)
			print(owner.name, " Horses: ", owner.inventory.horses, " (bag ", owner.inventory.get_total(), "/", owner.inventory.capacity, ")")
		_:
			owner.inventory.add_wood(amount)
			print(owner.name, " Wood: ", owner.inventory.wood, " (bag ", owner.inventory.get_total(), "/", owner.inventory.capacity, ")")
