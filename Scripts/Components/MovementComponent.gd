extends RefCounted

class_name MovementComponent

## Direct move + two-point building detour (side, then past corner).

var owner: BaseUnit

var arrival_distance: float = 0.5
var building_clearance: float = 5.5
var separation_radius: float = 1.1
var separation_strength: float = 1.8

# Detour path: index 0 = side point, index 1 = past-corner point
var _waypoints: Array[Vector3] = []
var _wp_index: int = 0

var _stuck_time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO


func _init(unit: BaseUnit) -> void:
	owner = unit
	_last_pos = unit.global_position


func set_target(world_pos: Vector3) -> void:
	var p := world_pos
	p.y = 0.0
	owner.move_target = p
	_waypoints.clear()
	_wp_index = 0
	_stuck_time = 0.0
	if _can_use_detour():
		_build_detour()


func update(delta: float) -> void:
	var final_target := owner.move_target
	final_target.y = 0.0

	var to_final := final_target - owner.global_position
	to_final.y = 0.0
	if to_final.length() <= arrival_distance:
		_waypoints.clear()
		_stop_if_moving()
		return

	if _can_use_detour():
		if _waypoints.is_empty() and _line_blocked(owner.global_position, final_target):
			_build_detour()
		elif not _waypoints.is_empty() and not _line_blocked(owner.global_position, final_target):
			# Straight path free again
			_waypoints.clear()
			_wp_index = 0
	else:
		_waypoints.clear()
		_wp_index = 0

	var seek := final_target
	if _wp_index < _waypoints.size():
		var wp: Vector3 = _waypoints[_wp_index]
		var to_wp := wp - owner.global_position
		to_wp.y = 0.0
		if to_wp.length() <= 0.9:
			_wp_index += 1
			if _wp_index < _waypoints.size():
				seek = _waypoints[_wp_index]
			else:
				seek = final_target
		else:
			seek = wp

	var to_seek := seek - owner.global_position
	to_seek.y = 0.0
	if to_seek.length() < 0.01:
		_stop_if_moving()
		return

	var direction := to_seek.normalized()

	# Stuck on a corner: slide sideways along the block
	var moved := owner.global_position.distance_to(_last_pos)
	_last_pos = owner.global_position
	if moved < 0.02:
		_stuck_time += delta
	else:
		_stuck_time = 0.0

	if _stuck_time > 0.25:
		var side := Vector3(-direction.z, 0.0, direction.x)
		# Prefer the side that still aims toward the goal
		if side.dot(to_final) < 0.0:
			side = -side
		direction = (direction * 0.3 + side).normalized()
		# Rebuild a wider detour once if stuck long
		if _stuck_time > 0.6 and _can_use_detour():
			building_clearance = 6.5
			_build_detour()
			building_clearance = 5.5
			_stuck_time = 0.0

	var sep := _separation()
	if sep.length_squared() > 0.001:
		direction = (direction + sep * separation_strength).normalized()

	owner.velocity = direction * owner.move_speed
	owner.move_and_slide()


func _can_use_detour() -> bool:
	return owner.unit_state == BaseUnit.UnitState.MOVING


func _build_detour() -> void:
	_waypoints.clear()
	_wp_index = 0

	var from: Vector3 = owner.global_position
	from.y = 0.0
	var final_t: Vector3 = owner.move_target
	final_t.y = 0.0

	if not _line_blocked(from, final_t):
		return

	var hit := _ray_to(from, final_t)
	if hit.is_empty():
		return

	var collider = hit.get("collider")
	if collider == null or not (collider is BaseBuilding):
		return

	var center: Vector3 = (collider as BaseBuilding).global_position
	center.y = 0.0

	var to_center := center - from
	to_center.y = 0.0
	if to_center.length() < 0.01:
		return

	var side := Vector3(-to_center.z, 0.0, to_center.x).normalized()
	var toward_goal := final_t - center
	toward_goal.y = 0.0
	var past_dir := Vector3.ZERO
	if toward_goal.length() > 0.1:
		past_dir = toward_goal.normalized()

	# Pick shorter side
	var side_a := side
	var side_b := -side
	var cost_a := from.distance_to(center + side_a * building_clearance) + (center + side_a * building_clearance).distance_to(final_t)
	var cost_b := from.distance_to(center + side_b * building_clearance) + (center + side_b * building_clearance).distance_to(final_t)
	var chosen_side := side_a if cost_a <= cost_b else side_b

	# 1) Beside the building
	var wp_side: Vector3 = center + chosen_side * building_clearance
	wp_side.y = 0.0
	# 2) Past the corner toward the goal (clears the angle)
	var wp_past: Vector3 = center + chosen_side * building_clearance + past_dir * 4.0
	wp_past.y = 0.0

	_waypoints.append(wp_side)
	_waypoints.append(wp_past)


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
	if offset.length() < 0.2:
		return {}
	var query := PhysicsRayQueryParameters3D.create(a, a + offset)
	query.collision_mask = 1
	query.exclude = [owner.get_rid()]
	return space.intersect_ray(query)


func _stop_if_moving() -> void:
	owner.velocity = Vector3.ZERO
	_waypoints.clear()
	_wp_index = 0
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
