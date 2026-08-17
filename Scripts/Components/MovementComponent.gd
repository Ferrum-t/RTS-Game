extends RefCounted

class_name MovementComponent

## Hybrid movement:
## - NavigationAgent path on flat navmesh
## - Ray steer only around BUILDINGS (not trees/resources)
## - Soft separation between units
## - Clean arrival stop

var owner: BaseUnit
var agent: NavigationAgent3D

var arrival_distance: float = 0.45
var avoid_distance: float = 1.6
var avoid_strength: float = 2.0
var separation_radius: float = 1.1
var separation_strength: float = 2.0

var _stuck_time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO


func _init(unit: BaseUnit) -> void:
	owner = unit
	_last_pos = unit.global_position

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
	_stuck_time = 0.0


func update(delta: float) -> void:
	agent.max_speed = owner.move_speed

	var target := owner.move_target
	target.y = 0.0

	var to_target := target - owner.global_position
	to_target.y = 0.0
	var dist_to_target := to_target.length()

	if dist_to_target <= arrival_distance:
		_stop_moving()
		return

	if agent.target_position.distance_to(target) > 0.05:
		agent.target_position = target

	# Preferred direction from nav path or direct line
	var direction := to_target.normalized()
	if not agent.is_navigation_finished():
		var next_pos: Vector3 = agent.get_next_path_position()
		var to_next: Vector3 = next_pos - owner.global_position
		to_next.y = 0.0
		if to_next.length() > 0.08:
			direction = to_next.normalized()

	# Only avoid buildings — never trees/resources (need to approach them)
	var avoid := _building_avoidance(direction)
	if avoid.length_squared() > 0.001:
		# Weaker blend when close to final target so deposit/approach works
		var blend := avoid_strength
		if dist_to_target < 3.5:
			blend *= 0.35
		direction = (direction + avoid * blend).normalized()

	var sep := _separation()
	if sep.length_squared() > 0.001:
		direction = (direction + sep * separation_strength).normalized()

	# Mild stuck escape (no wild side-swapping)
	var moved := owner.global_position.distance_to(_last_pos)
	_last_pos = owner.global_position
	if moved < 0.015 and dist_to_target > arrival_distance * 2.0:
		_stuck_time += delta
	else:
		_stuck_time = 0.0

	if _stuck_time > 0.5:
		var side := Vector3(-direction.z, 0.0, direction.x)
		direction = (direction * 0.5 + side).normalized()

	owner.velocity = direction * owner.move_speed
	owner.move_and_slide()


func _stop_moving() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	if owner.unit_state == BaseUnit.UnitState.MOVING:
		owner.unit_state = BaseUnit.UnitState.IDLE


func _building_avoidance(move_dir: Vector3) -> Vector3:
	var space := owner.get_world_3d().direct_space_state
	if space == null:
		return Vector3.ZERO

	var origin := owner.global_position + Vector3(0.0, 0.5, 0.0)
	var forward := move_dir.normalized()
	var hit := _ray(space, origin, forward, avoid_distance)
	if hit.is_empty():
		return Vector3.ZERO

	var collider = hit.get("collider")
	# IMPORTANT: only buildings, never resources/trees
	if collider == null or not (collider is BaseBuilding):
		return Vector3.ZERO

	var n: Vector3 = hit.normal
	n.y = 0.0
	if n.length_squared() < 0.001:
		n = Vector3(-forward.z, 0.0, forward.x)
	else:
		n = n.normalized()

	var left := Vector3(-forward.z, 0.0, forward.x)
	var right := -left
	var hit_l := _ray(space, origin, (forward + left * 0.8).normalized(), avoid_distance)
	var hit_r := _ray(space, origin, (forward + right * 0.8).normalized(), avoid_distance)

	var left_blocked := not hit_l.is_empty() and hit_l.get("collider") is BaseBuilding
	var right_blocked := not hit_r.is_empty() and hit_r.get("collider") is BaseBuilding

	if not left_blocked and right_blocked:
		return left
	if not right_blocked and left_blocked:
		return right

	var to_goal := owner.move_target - owner.global_position
	to_goal.y = 0.0
	if left.dot(to_goal) >= right.dot(to_goal):
		return (left + n * 0.5).normalized()
	return (right + n * 0.5).normalized()


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
