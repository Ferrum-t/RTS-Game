extends RefCounted

class_name MovementComponent

## M1 Movement contract:
## - Owns path execution + MovementStatus only
## - NEVER writes owner.unit_state
## - Backend: SimpleDetour (waypoints + rays); swappable later

enum Status {
	IDLE,
	MOVING,
	ARRIVED,
	BLOCKED,
	FAILED,
	CANCELLED,
}

var owner: BaseUnit
var status: Status = Status.IDLE

var arrival_distance: float = 0.5
var building_clearance: float = 5.5
var tree_clearance: float = 2.6
var separation_radius: float = 1.1
var separation_strength: float = 1.8

## No progress for this long → BLOCKED (after recovery attempts)
var block_timeout: float = 1.75

var _waypoints: Array[Vector3] = []
var _wp_index: int = 0

var _stuck_time: float = 0.0
var _no_progress_time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO


func _init(unit: BaseUnit) -> void:
	owner = unit
	_last_pos = unit.global_position
	status = Status.IDLE


## Public contract: request a new geometric goal.
func request_move(world_pos: Vector3) -> void:
	set_target(world_pos)


## Kept for callers (BaseUnit.set_move_target, update_return).
func set_target(world_pos: Vector3) -> void:
	var p := world_pos
	p.y = 0.0
	owner.move_target = p
	_waypoints.clear()
	_wp_index = 0
	_stuck_time = 0.0
	_no_progress_time = 0.0
	status = Status.MOVING
	if _can_use_detour():
		_build_detour()


func cancel() -> void:
	owner.velocity = Vector3.ZERO
	_waypoints.clear()
	_wp_index = 0
	_stuck_time = 0.0
	_no_progress_time = 0.0
	status = Status.CANCELLED


func get_status() -> Status:
	return status


func get_target() -> Vector3:
	return owner.move_target


func update(delta: float) -> void:
	# Terminal statuses stay until new request_move / cancel handled by Unit
	if status == Status.ARRIVED or status == Status.BLOCKED \
		or status == Status.FAILED or status == Status.CANCELLED:
		owner.velocity = Vector3.ZERO
		return

	var final_target := owner.move_target
	final_target.y = 0.0

	var to_final := final_target - owner.global_position
	to_final.y = 0.0
	var dist_final := to_final.length()

	# --- Arrival (final target only) ---
	if dist_final <= arrival_distance:
		_set_arrived()
		return

	# Active move
	if status == Status.IDLE:
		status = Status.MOVING

	if _can_use_detour():
		if _waypoints.is_empty() and _line_blocked(owner.global_position, final_target):
			_build_detour()
		elif not _waypoints.is_empty() and not _line_blocked(owner.global_position, final_target):
			# Line of sight clear — drop detour, go direct
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
		if to_wp.length() <= 0.85:
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
		# Degenerate seek but not at final — rebuild detour or count as no progress
		if _can_use_detour():
			_build_detour()
		_no_progress_time += delta
		if _no_progress_time >= block_timeout:
			_set_blocked()
		return

	var direction := to_seek.normalized()

	# Stuck recovery
	var moved := owner.global_position.distance_to(_last_pos)
	_last_pos = owner.global_position
	if moved < 0.02:
		_stuck_time += delta
		_no_progress_time += delta
	else:
		_stuck_time = 0.0
		_no_progress_time = 0.0

	if _stuck_time > 0.2:
		var side := Vector3(-direction.z, 0.0, direction.x)
		if side.dot(to_final) < 0.0:
			side = -side
		direction = (direction * 0.25 + side).normalized()
		if _stuck_time > 0.45 and _can_use_detour():
			_build_detour()
			_stuck_time = 0.0

	if _no_progress_time >= block_timeout:
		_set_blocked()
		return

	var sep := _separation()
	if sep.length_squared() > 0.001:
		direction = (direction + sep * separation_strength).normalized()

	status = Status.MOVING
	owner.velocity = direction * owner.move_speed
	owner.move_and_slide()


func _set_arrived() -> void:
	owner.velocity = Vector3.ZERO
	_waypoints.clear()
	_wp_index = 0
	_stuck_time = 0.0
	_no_progress_time = 0.0
	status = Status.ARRIVED
	# Does NOT touch owner.unit_state (M1 contract)


func _set_blocked() -> void:
	owner.velocity = Vector3.ZERO
	_waypoints.clear()
	_wp_index = 0
	_stuck_time = 0.0
	_no_progress_time = 0.0
	status = Status.BLOCKED
	# Does NOT touch owner.unit_state (M1 contract)


func _can_use_detour() -> bool:
	# Detour only for explicit move orders (unit in MOVING).
	# Harvest / Return / Attack approach without detour.
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
	if collider == null:
		return

	var clearance := 0.0
	var center := Vector3.ZERO

	if collider is BaseBuilding:
		clearance = building_clearance
		center = (collider as BaseBuilding).global_position
	elif collider is BaseResource:
		clearance = tree_clearance
		center = (collider as BaseResource).global_position
	elif collider is StaticBody3D:
		clearance = tree_clearance
		center = (collider as StaticBody3D).global_position
	else:
		return

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

	var side_a := side
	var side_b := -side
	var cost_a := from.distance_to(center + side_a * clearance) + (center + side_a * clearance).distance_to(final_t)
	var cost_b := from.distance_to(center + side_b * clearance) + (center + side_b * clearance).distance_to(final_t)
	var chosen_side := side_a if cost_a <= cost_b else side_b

	var past_amount := 3.0 if collider is BaseBuilding else 2.2
	var wp_side: Vector3 = center + chosen_side * clearance
	wp_side.y = 0.0
	var wp_past: Vector3 = center + chosen_side * clearance + past_dir * past_amount
	wp_past.y = 0.0

	_waypoints.append(wp_side)
	_waypoints.append(wp_past)


func _line_blocked(from: Vector3, to: Vector3) -> bool:
	var hit := _ray_to(from, to)
	if hit.is_empty():
		return false
	var c = hit.get("collider")
	return c is BaseBuilding or c is BaseResource


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
