extends RefCounted

class_name MovementComponent

## Movement with corner-clearing building bypass.
## Detour sits beside + slightly past the building toward the goal.

var owner: BaseUnit
var agent: NavigationAgent3D

var arrival_distance: float = 0.45
var building_clearance: float = 4.5
var separation_radius: float = 1.1
var separation_strength: float = 2.0

var _detour: Vector3 = Vector3.ZERO
var _has_detour: bool = false


func _init(unit: BaseUnit) -> void:
	owner = unit

	agent = NavigationAgent3D.new()
	owner.add_child(agent)

	agent.path_desired_distance = 0.5
	agent.target_desired_distance = arrival_distance
	agent.avoidance_enabled = false
	agent.radius = 0.4
	agent.height = 1.2
	agent.max_speed = owner.move_speed


func set_target(world_pos: Vector3) -> void:
	var p := world_pos
	p.y = 0.0
	owner.move_target = p
	agent.target_position = p
	_has_detour = false
	if owner.unit_state != BaseUnit.UnitState.RETURNING \
		and owner.unit_state != BaseUnit.UnitState.HARVESTING:
		_update_detour()


func update(_delta: float) -> void:
	agent.max_speed = owner.move_speed

	var final_target := owner.move_target
	final_target.y = 0.0

	var to_final := final_target - owner.global_position
	to_final.y = 0.0
	if to_final.length() <= arrival_distance:
		_has_detour = false
		_stop_moving()
		return

	var allow_detour := owner.unit_state != BaseUnit.UnitState.RETURNING \
		and owner.unit_state != BaseUnit.UnitState.HARVESTING

	if allow_detour:
		_update_detour()
	else:
		_has_detour = false

	var seek := final_target
	if _has_detour:
		var to_detour := _detour - owner.global_position
		to_detour.y = 0.0
		if to_detour.length() <= 0.8:
			_has_detour = false
			seek = final_target
		else:
			seek = _detour

	if agent.target_position.distance_to(seek) > 0.15:
		agent.target_position = seek

	var to_seek := seek - owner.global_position
	to_seek.y = 0.0
	if to_seek.length() < 0.01:
		_stop_moving()
		return

	var direction := to_seek.normalized()

	var sep := _separation()
	if sep.length_squared() > 0.001:
		direction = (direction + sep * separation_strength).normalized()

	owner.velocity = direction * owner.move_speed
	owner.move_and_slide()


func _update_detour() -> void:
	var space := owner.get_world_3d().direct_space_state
	if space == null:
		_has_detour = false
		return

	var origin := owner.global_position + Vector3(0.0, 0.5, 0.0)
	var goal := owner.move_target + Vector3(0.0, 0.5, 0.0)
	var offset := goal - origin
	var dist := offset.length()
	if dist < 1.0:
		_has_detour = false
		return

	var hit := _ray(space, origin, offset / dist, dist)
	if hit.is_empty():
		_has_detour = false
		return

	var collider = hit.get("collider")
	if collider == null or not (collider is BaseBuilding):
		_has_detour = false
		return

	var building := collider as BaseBuilding
	var center: Vector3 = building.global_position
	center.y = 0.0

	var from: Vector3 = owner.global_position
	from.y = 0.0
	var final_t: Vector3 = owner.move_target
	final_t.y = 0.0

	var to_center: Vector3 = center - from
	to_center.y = 0.0
	if to_center.length() < 0.01:
		_has_detour = false
		return

	var side := Vector3(-to_center.z, 0.0, to_center.x).normalized()

	# Place waypoint beside building AND a bit past it toward the goal (clears corners)
	var toward_goal: Vector3 = final_t - center
	toward_goal.y = 0.0
	var past := Vector3.ZERO
	if toward_goal.length() > 0.1:
		past = toward_goal.normalized() * 2.5

	var wp_a: Vector3 = center + side * building_clearance + past
	var wp_b: Vector3 = center - side * building_clearance + past

	var cost_a := from.distance_to(wp_a) + wp_a.distance_to(final_t)
	var cost_b := from.distance_to(wp_b) + wp_b.distance_to(final_t)

	_detour = wp_a if cost_a <= cost_b else wp_b
	_detour.y = 0.0
	_has_detour = true


func _stop_moving() -> void:
	owner.velocity = Vector3.ZERO
	_has_detour = false
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


func _ray(space: PhysicsDirectSpaceState3D, origin: Vector3, dir: Vector3, dist: float) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(origin, origin + dir * dist)
	query.collision_mask = 1
	query.exclude = [owner.get_rid()]
	return space.intersect_ray(query)
