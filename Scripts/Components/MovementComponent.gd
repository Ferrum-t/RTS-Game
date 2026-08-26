extends RefCounted

class_name MovementComponent

## M6 Movement (M1 status contract)
## M6.4: monotonic waypoint index
## M6.5: get_next_path_position() wakes NavigationAgent path query before reading path
## M6.6: path exhausted → last path point / ARRIVED (never raw final_target)

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
var agent: NavigationAgent3D = null

var arrival_distance: float = 0.55
var block_timeout: float = 1.75
## Soft push between units (RVO avoidance still off — keeps M6 path contract simple).
var separation_radius: float = 1.55
var separation_strength: float = 2.0
var waypoint_skip_distance: float = 0.4
var default_retarget_distance: float = 0.85

var _stuck_time: float = 0.0
var _no_progress_time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO
var _last_bake_id: int = -1

var _current_waypoint_index: int = 0
var _last_path_size: int = 0


func _init(unit: BaseUnit, nav_agent: NavigationAgent3D = null) -> void:
	owner = unit
	agent = nav_agent
	_last_pos = unit.global_position
	status = Status.IDLE
	if agent:
		_configure_agent()


func set_agent(nav_agent: NavigationAgent3D) -> void:
	agent = nav_agent
	if agent:
		_configure_agent()


func _configure_agent() -> void:
	agent.path_desired_distance = 0.5
	agent.target_desired_distance = arrival_distance
	agent.radius = 0.4
	agent.height = 1.2
	agent.avoidance_enabled = false
	agent.path_max_distance = 50.0


func request_move(world_pos: Vector3) -> void:
	set_target(world_pos)


func set_target(world_pos: Vector3) -> void:
	var p := world_pos
	p.y = 0.0
	owner.move_target = p
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_last_pos = owner.global_position
	_current_waypoint_index = 0
	_last_path_size = 0
	status = Status.MOVING
	if agent:
		agent.target_position = p


func ensure_moving_to(world_pos: Vector3, retarget_distance: float = -1.0) -> void:
	var p := world_pos
	p.y = 0.0
	var thresh := retarget_distance
	if thresh < 0.0:
		thresh = default_retarget_distance

	if status == Status.CANCELLED \
		or status == Status.IDLE \
		or status == Status.ARRIVED \
		or status == Status.BLOCKED \
		or status == Status.FAILED:
		set_target(p)
		return

	var cur := owner.move_target
	cur.y = 0.0
	if cur.distance_to(p) > thresh:
		set_target(p)
		return

	owner.move_target = p
	if status != Status.MOVING:
		status = Status.MOVING


func cancel() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_current_waypoint_index = 0
	_last_path_size = 0
	status = Status.CANCELLED
	if agent:
		agent.target_position = owner.global_position


func get_status() -> Status:
	return status


func get_target() -> Vector3:
	return owner.move_target


func _refresh_path_if_bake_changed() -> void:
	var nav = owner.get_node_or_null("/root/NavigationBakeService")
	if nav == null or not ("bake_id" in nav):
		return
	var bid: int = nav.bake_id
	if bid == _last_bake_id:
		return
	_last_bake_id = bid
	if status == Status.MOVING and agent:
		_current_waypoint_index = 0
		_last_path_size = 0
		agent.target_position = owner.move_target
		_no_progress_time = 0.0
		_stuck_time = 0.0


func _get_follow_point(final_target: Vector3) -> Vector3:
	if agent == null:
		return final_target

	# M6.5: wake NavigationAgent internal path query (Godot 4.7).
	agent.get_next_path_position()

	var path: PackedVector3Array = agent.get_current_navigation_path()
	var pos := owner.global_position
	pos.y = 0.0

	if path.is_empty():
		_current_waypoint_index = 0
		_last_path_size = 0
		return final_target

	if path.size() != _last_path_size:
		_current_waypoint_index = 0
		_last_path_size = path.size()

	if _current_waypoint_index >= path.size():
		_current_waypoint_index = maxi(path.size() - 1, 0)

	while _current_waypoint_index < path.size():
		var wp: Vector3 = path[_current_waypoint_index]
		wp.y = 0.0
		if pos.distance_to(wp) <= waypoint_skip_distance:
			_current_waypoint_index += 1
			continue
		break

	# M6.6: path exhausted → last path point, NEVER raw final_target
	if _current_waypoint_index >= path.size():
		var last: Vector3 = path[path.size() - 1]
		last.y = 0.0
		return last

	var follow: Vector3 = path[_current_waypoint_index]
	follow.y = 0.0
	return follow


func update(delta: float) -> void:
	if status == Status.CANCELLED:
		owner.velocity = Vector3.ZERO
		return

	if status == Status.ARRIVED or status == Status.BLOCKED or status == Status.FAILED:
		var wake := owner.move_target - owner.global_position
		wake.y = 0.0
		if wake.length() > arrival_distance * 1.25:
			status = Status.MOVING
			_stuck_time = 0.0
			_no_progress_time = 0.0
			_current_waypoint_index = 0
			_last_path_size = 0
			if agent:
				agent.target_position = owner.move_target
		else:
			owner.velocity = Vector3.ZERO
			return

	var final_target := owner.move_target
	final_target.y = 0.0
	var to_final := final_target - owner.global_position
	to_final.y = 0.0
	var dist_final := to_final.length()

	if dist_final <= arrival_distance:
		_set_arrived()
		return

	if status == Status.IDLE:
		status = Status.MOVING

	_refresh_path_if_bake_changed()

	if agent == null:
		_direct_steer(delta, final_target)
		return

	var follow := _get_follow_point(final_target)
	follow.y = 0.0
	var path_n := 0
	if agent:
		path_n = agent.get_current_navigation_path().size()

	# M6.6: reached last path point after path exhausted → ARRIVED (nav edge)
	if path_n > 0 and _current_waypoint_index >= path_n:
		var to_edge := follow - owner.global_position
		to_edge.y = 0.0
		if to_edge.length() <= arrival_distance:
			_set_arrived()
			return

	var to_follow := follow - owner.global_position
	to_follow.y = 0.0

	if to_follow.length() < 0.001:
		var moved0 := owner.global_position.distance_to(_last_pos)
		_last_pos = owner.global_position
		if moved0 < 0.02:
			_no_progress_time += delta
		else:
			_no_progress_time = 0.0
		if _no_progress_time >= block_timeout:
			_set_blocked()
		owner.velocity = Vector3.ZERO
		return

	var direction := to_follow.normalized()

	var moved := owner.global_position.distance_to(_last_pos)
	_last_pos = owner.global_position
	if moved < 0.02:
		_stuck_time += delta
		_no_progress_time += delta
	else:
		_stuck_time = 0.0
		_no_progress_time = 0.0

	if _no_progress_time >= block_timeout:
		_set_blocked()
		return

	var sep := _separation()
	if sep.length_squared() > 0.001:
		direction = (direction + sep * separation_strength).normalized()

	status = Status.MOVING
	owner.velocity.x = direction.x * owner.move_speed
	owner.velocity.z = direction.z * owner.move_speed
	owner.move_and_slide()


func _direct_steer(_delta: float, final_target: Vector3) -> void:
	var to_seek := final_target - owner.global_position
	to_seek.y = 0.0
	if to_seek.length() <= arrival_distance:
		_set_arrived()
		return
	var direction := to_seek.normalized()
	status = Status.MOVING
	owner.velocity.x = direction.x * owner.move_speed
	owner.velocity.z = direction.z * owner.move_speed
	owner.move_and_slide()


func _set_arrived() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_current_waypoint_index = 0
	_last_path_size = 0
	status = Status.ARRIVED


func _set_blocked() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	_no_progress_time = 0.0
	status = Status.BLOCKED


func _set_failed() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	_no_progress_time = 0.0
	status = Status.FAILED


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
