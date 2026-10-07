extends RefCounted

class_name MovementComponent

## M6 Movement + M34 crowd polish (softer RVO, blocked recovery, less jitter)

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
## Was 1.75 — longer so rear units don't flip MOVING/BLOCKED every frame
var block_timeout: float = 2.6
var separation_radius: float = 1.35
var separation_strength: float = 0.85
var waypoint_skip_distance: float = 0.4
var default_retarget_distance: float = 0.85

var _stuck_time: float = 0.0
var _no_progress_time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO
var _last_bake_id: int = -1

var _current_waypoint_index: int = 0
var _last_path_size: int = 0
var _awaiting_avoidance: bool = false
var _blocked_hold: float = 0.0
var _jitter_dampen: float = 0.0


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
	agent.path_desired_distance = 0.55
	agent.target_desired_distance = arrival_distance
	# Slightly larger agent = fewer overlaps / less thrash
	agent.radius = 0.55
	agent.height = 1.2
	agent.path_max_distance = 50.0
	agent.avoidance_enabled = true
	# Softer, earlier avoidance — less last-second twitch
	agent.neighbor_distance = 4.5
	agent.max_neighbors = 12
	agent.time_horizon_agents = 1.4
	agent.time_horizon_obstacles = 0.0
	agent.max_speed = 12.0
	agent.avoidance_layers = 1
	agent.avoidance_mask = 1
	if not agent.velocity_computed.is_connected(_on_velocity_computed):
		agent.velocity_computed.connect(_on_velocity_computed)


func request_move(world_pos: Vector3) -> void:
	set_target(world_pos)


func set_target(world_pos: Vector3) -> void:
	var p := world_pos
	p.y = 0.0
	owner.move_target = p
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_blocked_hold = 0.0
	_jitter_dampen = 0.0
	_last_pos = owner.global_position
	_current_waypoint_index = 0
	_last_path_size = 0
	_awaiting_avoidance = false
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
	_blocked_hold = 0.0
	_jitter_dampen = 0.0
	_current_waypoint_index = 0
	_last_path_size = 0
	_awaiting_avoidance = false
	status = Status.CANCELLED
	if agent:
		agent.target_position = owner.global_position
		if agent.avoidance_enabled:
			agent.set_velocity(Vector3.ZERO)


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

	# Soft recovery from BLOCKED — pause briefly, then nudge sideways and retry
	if status == Status.BLOCKED:
		owner.velocity = Vector3.ZERO
		_blocked_hold += delta
		if _blocked_hold >= 0.55:
			_blocked_hold = 0.0
			_no_progress_time = 0.0
			_stuck_time = 0.0
			var nudge := _side_nudge()
			var retry: Vector3 = owner.move_target + nudge
			retry.y = 0.0
			status = Status.MOVING
			if agent:
				agent.target_position = retry
			_current_waypoint_index = 0
			_last_path_size = 0
		else:
			return

	if status == Status.ARRIVED or status == Status.FAILED:
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
		if moved0 < 0.025:
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
	if moved < 0.025:
		_stuck_time += delta
		_no_progress_time += delta
		_jitter_dampen = minf(1.0, _jitter_dampen + delta * 1.5)
	else:
		_stuck_time = 0.0
		_no_progress_time = 0.0
		_jitter_dampen = maxf(0.0, _jitter_dampen - delta * 2.0)

	if _no_progress_time >= block_timeout:
		_set_blocked()
		return

	var sep := _separation()
	if sep.length_squared() > 0.001:
		# When nearly stuck, lean harder on separation so rear units slide out
		var sep_w: float = separation_strength * (1.0 + _jitter_dampen * 0.8)
		direction = (direction + sep * sep_w).normalized()

	status = Status.MOVING
	var speed_scale: float = 1.0 - _jitter_dampen * 0.35
	var desired := Vector3(
		direction.x * owner.move_speed * speed_scale,
		0.0,
		direction.z * owner.move_speed * speed_scale
	)

	if agent.avoidance_enabled:
		agent.max_speed = maxf(owner.move_speed * speed_scale, 0.1)
		_awaiting_avoidance = true
		agent.set_velocity(desired)
	else:
		owner.velocity.x = desired.x
		owner.velocity.z = desired.z
		_face_move_dir(owner.velocity)
		owner.move_and_slide()


func _side_nudge() -> Vector3:
	# Stable-ish lateral offset from instance id so neighbors pick different sides
	var seed: int = int(owner.get_instance_id()) if owner else 0
	var a: float = float((seed * 37) % 360) * 0.0174533
	var r: float = 1.1 + float((seed * 13) % 10) * 0.08
	return Vector3(cos(a) * r, 0.0, sin(a) * r)


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if not _awaiting_avoidance:
		return
	_awaiting_avoidance = false
	if status != Status.MOVING:
		return
	if owner == null or not is_instance_valid(owner):
		return
	# Ignore near-zero safe velocity when still far — apply soft separation slide instead of freeze-twitch
	var spd_sq: float = safe_velocity.x * safe_velocity.x + safe_velocity.z * safe_velocity.z
	if spd_sq < 0.04 and _jitter_dampen > 0.35:
		var sep := _separation()
		if sep.length_squared() > 0.001:
			sep = sep.normalized() * owner.move_speed * 0.45
			owner.velocity.x = sep.x
			owner.velocity.z = sep.z
			_face_move_dir(owner.velocity)
			owner.move_and_slide()
			return
	owner.velocity.x = safe_velocity.x
	owner.velocity.z = safe_velocity.z
	_face_move_dir(owner.velocity)
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
	_face_move_dir(owner.velocity)
	owner.move_and_slide()


func _set_arrived() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_blocked_hold = 0.0
	_jitter_dampen = 0.0
	_current_waypoint_index = 0
	_last_path_size = 0
	_awaiting_avoidance = false
	status = Status.ARRIVED
	if agent and agent.avoidance_enabled:
		agent.set_velocity(Vector3.ZERO)


func _set_blocked() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_blocked_hold = 0.0
	_awaiting_avoidance = false
	status = Status.BLOCKED
	if agent and agent.avoidance_enabled:
		agent.set_velocity(Vector3.ZERO)


func _set_failed() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_blocked_hold = 0.0
	_awaiting_avoidance = false
	status = Status.FAILED
	if agent and agent.avoidance_enabled:
		agent.set_velocity(Vector3.ZERO)


func _face_move_dir(vel: Vector3) -> void:
	if owner == null or not is_instance_valid(owner):
		return
	var d := Vector3(vel.x, 0.0, vel.z)
	if d.length_squared() < 0.0004:
		return
	d = d.normalized()
	owner.rotation.y = atan2(-d.x, -d.z)


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
