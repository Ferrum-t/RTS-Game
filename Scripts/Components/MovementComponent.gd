extends RefCounted

class_name MovementComponent

## Hybrid movement for RTS foundation:
## 1) NavigationAgent3D gives a path on the walkable navmesh
## 2) Raycasts steer around dynamic buildings (navmesh is a flat plane;
##    obstacles are avoided locally so units don't tunnel into walls)
## 3) Clear arrival stop so units don't wander forever

var owner: BaseUnit
var agent: NavigationAgent3D

var arrival_distance: float = 0.4
var avoid_distance: float = 2.2
var avoid_strength: float = 3.5
var separation_radius: float = 1.3
var separation_strength: float = 2.5

var _stuck_time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO


func _init(unit: BaseUnit) -> void:
	owner = unit
	_last_pos = unit.global_position

	agent = NavigationAgent3D.new()
	owner.add_child(agent)

	agent.path_desired_distance = 0.5
	agent.target_desired_distance = arrival_distance
	agent.avoidance_enabled = false # we do our own steering (more predictable)
	agent.radius = 0.45
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

	# --- Arrival ---
	var to_target := target - owner.global_position
	to_target.y = 0.0
	if to_target.length() <= arrival_distance:
		_stop_moving()
		return

	# Keep agent target synced
	if agent.target_position.distance_to(target) > 0.05:
		agent.target_position = target

	# Preferred direction: next nav path point, or direct if path not ready
	var direction := to_target.normalized()
	if not agent.is_navigation_finished():
		var next_pos: Vector3 = agent.get_next_path_position()
		var to_next: Vector3 = next_pos - owner.global_position
		to_next.y = 0.0
		if to_next.length() > 0.05:
			direction = to_next.normalized()

	# Steer around buildings / trees (physics layer 1)
	var avoid := _obstacle_avoidance(direction)
	if avoid.length_squared() > 0.001:
		direction = (direction + avoid * avoid_strength).normalized()

	# Soft separation from other units
	var sep := _separation()
	if sep.length_squared() > 0.001:
		direction = (direction + sep * separation_strength).normalized()

	# Stuck detection — if barely moving while still far from target, push sideways
	var moved := owner.global_position.distance_to(_last_pos)
	_last_pos = owner.global_position
	if moved < 0.02:
		_stuck_time += delta
	else:
		_stuck_time = 0.0

	if _stuck_time > 0.35:
		var side := Vector3(-direction.z, 0.0, direction.x)
		# Alternate side over time
		if int(_stuck_time * 2.0) % 2 == 1:
			side = -side
		direction = (direction + side * 2.0).normalized()

	owner.velocity = direction * owner.move_speed
	owner.move_and_slide()


func _stop_moving() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	if owner.unit_state == BaseUnit.UnitState.MOVING:
		owner.unit_state = BaseUnit.UnitState.IDLE


func _obstacle_avoidance(move_dir: Vector3) -> Vector3:
	var space := owner.get_world_3d().direct_space_state
	if space == null:
		return Vector3.ZERO

	var origin := owner.global_position + Vector3(0.0, 0.5, 0.0)
	var forward := move_dir.normalized()
	var hit := _ray(space, origin, forward, avoid_distance)
	if hit.is_empty():
		return Vector3.ZERO

	# Don't avoid the ground plane — only tall colliders (buildings/trees)
	var collider = hit.get("collider")
	if collider != null and collider is StaticBody3D:
		var n: Vector3 = hit.normal
		n.y = 0.0
		if n.length_squared() < 0.001:
			n = Vector3(-forward.z, 0.0, forward.x)
		else:
			n = n.normalized()

		var left := Vector3(-forward.z, 0.0, forward.x)
		var right := -left
		var hit_l := _ray(space, origin, (forward + left).normalized(), avoid_distance)
		var hit_r := _ray(space, origin, (forward + right).normalized(), avoid_distance)

		if hit_l.is_empty() and not hit_r.is_empty():
			return left
		if hit_r.is_empty() and not hit_l.is_empty():
			return right

		# Prefer side aligned with remaining path to final target
		var to_goal := owner.move_target - owner.global_position
		to_goal.y = 0.0
		if left.dot(to_goal) >= right.dot(to_goal):
			return left + n
		return right + n

	return Vector3.ZERO


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
