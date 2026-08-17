extends RefCounted

class_name MovementComponent

var owner: BaseUnit

var separation_radius: float = 1.2
var separation_strength: float = 3.0

## How far ahead to check for walls/buildings
var avoid_distance: float = 1.8
var avoid_strength: float = 2.5


func _init(unit: BaseUnit) -> void:
	owner = unit


func update(_delta: float) -> void:
	var to_target := owner.move_target - owner.global_position
	to_target.y = 0.0

	if to_target.length() < 0.15:
		owner.velocity = Vector3.ZERO
		if owner.unit_state == BaseUnit.UnitState.MOVING:
			owner.unit_state = BaseUnit.UnitState.IDLE
		return

	var direction := to_target.normalized()

	# Soft separation from other units
	var separation := _compute_separation()
	if separation.length_squared() > 0.001:
		direction = (direction + separation * separation_strength).normalized()

	# Steer around static obstacles (buildings, trees)
	var avoid := _compute_obstacle_avoidance(direction)
	if avoid.length_squared() > 0.001:
		direction = (direction + avoid * avoid_strength).normalized()

	owner.velocity = direction * owner.move_speed
	owner.move_and_slide()


func _compute_separation() -> Vector3:
	var push := Vector3.ZERO
	var um := UnitManager
	if um == null:
		return push

	for other in um.units:
		if other == null or other == owner or not is_instance_valid(other):
			continue
		if other.unit_state == BaseUnit.UnitState.DEAD:
			continue

		var offset: Vector3 = owner.global_position - other.global_position
	offset.y = 0.0
		var dist := offset.length()

		if dist < 0.001 or dist >= separation_radius:
			continue

		var force := (1.0 - dist / separation_radius)
		push += offset.normalized() * force

	return push


func _compute_obstacle_avoidance(move_dir: Vector3) -> Vector3:
	var space := owner.get_world_3d().direct_space_state
	if space == null:
		return Vector3.ZERO

	var origin := owner.global_position + Vector3(0.0, 0.5, 0.0)
	var forward := move_dir.normalized()

	# Center ray
	var hit := _ray(space, origin, forward, avoid_distance)
	if hit.is_empty():
		return Vector3.ZERO

	# Feel left and right to choose free side
	var left_dir := Vector3(-forward.z, 0.0, forward.x)
	var right_dir := -left_dir

	var hit_left := _ray(space, origin, (forward + left_dir).normalized(), avoid_distance)
	var hit_right := _ray(space, origin, (forward + right_dir).normalized(), avoid_distance)

	var steer := Vector3.ZERO
	if hit_left.is_empty() and not hit_right.is_empty():
		steer = left_dir
	elif hit_right.is_empty() and not hit_left.is_empty():
		steer = right_dir
	elif hit_left.is_empty() and hit_right.is_empty():
		# Both open — pick side closer to target
		var to_target := owner.move_target - owner.global_position
		to_target.y = 0.0
		steer = left_dir if left_dir.dot(to_target) >= right_dir.dot(to_target) else right_dir
	else:
		# Both blocked — push along wall normal
		var n: Vector3 = hit.normal
		n.y = 0.0
		if n.length_squared() > 0.001:
			steer = n.normalized()
		else:
			steer = left_dir

	return steer


func _ray(space: PhysicsDirectSpaceState3D, origin: Vector3, dir: Vector3, dist: float) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(origin, origin + dir * dist)
	query.collision_mask = 1 # world / buildings / trees
	query.exclude = [owner.get_rid()]
	return space.intersect_ray(query)
