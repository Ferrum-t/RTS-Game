extends RefCounted

class_name MovementComponent

## Reliable RTS movement (foundation):
## - Walk straight to the goal
## - If a building blocks the line, go to a side waypoint, then to the goal
## - No NavigationAgent (flat navmesh was fighting local steers)

var owner: BaseUnit

var arrival_distance: float = 0.5
var building_clearance: float = 5.0
var separation_radius: float = 1.1
var separation_strength: float = 1.8

var _detour: Vector3 = Vector3.ZERO
var _has_detour: bool = false


func _init(unit: BaseUnit) -> void:
	owner = unit


func set_target(world_pos: Vector3) -> void:
	var p := world_pos
	p.y = 0.0
	owner.move_target = p
	_has_detour = false
	if _can_use_detour():
		_compute_detour()


func update(_delta: float) -> void:
	var final_target := owner.move_target
	final_target.y = 0.0

	var to_final := final_target - owner.global_position
	to_final.y = 0.0
	var dist_final := to_final.length()

	if dist_final <= arrival_distance:
		_has_detour = false
		_stop_if_moving()
		return

	# Recompute detour only for normal move orders
	if _can_use_detour():
		if not _has_detour:
			_compute_detour()
		elif not _line_blocked(owner.global_position, final_target):
			# Path opened — cancel detour
			_has_detour = false
	else:
		_has_detour = false

	var seek := final_target
	if _has_detour:
		var to_detour := _detour - owner.global_position
		to_detour.y = 0.0
		if to_detour.length() <= 0.9:
			_has_detour = false
			seek = final_target
		else:
			seek = _detour

	var to_seek := seek - owner.global_position
	to_seek.y = 0.0
	if to_seek.length() < 0.01:
		_stop_if_moving()
		return

	var direction := to_seek.normalized()

	var sep := _separation()
	if sep.length_squared() > 0.001:
		direction = (direction + sep * separation_strength).normalized()

	owner.velocity = direction * owner.move_speed
	owner.move_and_slide()


func _can_use_detour() -> bool:
	return owner.unit_state == BaseUnit.UnitState.MOVING


func _compute_detour() -> void:
	var from: Vector3 = owner.global_position
	from.y = 0.0
	var final_t: Vector3 = owner.move_target
	final_t.y = 0.0

	if not _line_blocked(from, final_t):
		_has_detour = false
		return

	var hit := _ray_to(from, final_t)
	if hit.is_empty():
		_has_detour = false
		return

	var collider = hit.get("collider")
	if collider == null or not (collider is BaseBuilding):
		_has_detour = false
		return

	var center: Vector3 = (collider as BaseBuilding).global_position
	center.y = 0.0

	var to_center := center - from
	to_center.y = 0.0
	if to_center.length() < 0.01:
		_has_detour = false
		return

	var side := Vector3(-to_center.z, 0.0, to_center.x).normalized()
	var toward_goal := final_t - center
	toward_goal.y = 0.0
	var past := Vector3.ZERO
	if toward_goal.length() > 0.1:
		past = toward_goal.normalized() * 3.0

	var wp_a: Vector3 = center + side * building_clearance + past
	var wp_b: Vector3 = center - side * building_clearance + past
	wp_a.y = 0.0
	wp_b.y = 0.0

	var cost_a := from.distance_to(wp_a) + wp_a.distance_to(final_t)
	var cost_b := from.distance_to(wp_b) + wp_b.distance_to(final_t)

	_detour = wp_a if cost_a <= cost_b else wp_b
	_has_detour = true


func _line_blocked(from: Vector3, to: Vector3) -> bool:
	var hit := _ray_to(from, to)
	if hit.is_empty():
		return false
	return hit.get("collider") is BaseBuilding


func _ray_to(from: Vector3, to: Vector3) -> Dictionary:
	var space := owner.get_world_3d().direct_space_state
	if space == null:
		return {}
	var a := from + Vector3(0.0, 0.5, 0.0)
	var b := to + Vector3(0.0, 0.5, 0.0)
	var offset := b - a
	var dist := offset.length()
	if dist < 0.2:
		return {}
	var query := PhysicsRayQueryParameters3D.create(a, a + offset)
	query.collision_mask = 1
	query.exclude = [owner.get_rid()]
	return space.intersect_ray(query)


func _stop_if_moving() -> void:
	owner.velocity = Vector3.ZERO
	if owner.unit_state == BaseUnit.UnitState.MOVING:
		owner.unit_state = BaseUnit.UnitState.IDLE


func _separation() -> Vector3:
	var push := Vector3.ZERO
	if UnitManager == null:
		return push
	for other in UnitManager.units:
		if other == null or other == owner or not is_instance_valid(other):
			continue
		if other.unit_state == BaseUnit.UnitState.DEAD:
			continue
		var offset := owner.global_position - other.global_position
		offset.y = 0.0
		var dist := offset.length()
		if dist < 0.001 or dist >= separation_radius:
			continue
		push += offset.normalized() * (1.0 - dist / separation_radius)
	return push
