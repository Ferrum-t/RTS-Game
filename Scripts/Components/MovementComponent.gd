extends RefCounted

class_name MovementComponent

## M35.5 WC3-style: NO RVO. Path + light soft body. Velocity only (BaseUnit does move_and_slide once).

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
var block_timeout: float = 3.2
var body_radius: float = 0.95
var body_push: float = 0.9
var waypoint_skip_distance: float = 0.45
var default_retarget_distance: float = 0.85

var _stuck_time: float = 0.0
var _no_progress_time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO
var _last_bake_id: int = -1

var _current_waypoint_index: int = 0
var _last_path_size: int = 0
var _blocked_hold: float = 0.0
var _wait_timer: float = 0.0


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
	agent.radius = 0.45
	agent.height = 1.2
	agent.path_max_distance = 50.0
	agent.avoidance_enabled = false
	agent.max_speed = 12.0


func request_move(world_pos: Vector3) -> void:
	set_target(world_pos)


func set_target(world_pos: Vector3) -> void:
	var p := world_pos
	p.y = 0.0
	owner.move_target = p
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_blocked_hold = 0.0
	_wait_timer = 0.0
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
	_blocked_hold = 0.0
	_wait_timer = 0.0
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

	if status == Status.ARRIVED or status == Status.IDLE or status == Status.FAILED:
		var idle_sep := _soft_body()
		if idle_sep.length_squared() > 0.04:
			idle_sep = idle_sep.normalized() * minf(owner.move_speed * 0.25, 0.7)
			owner.velocity.x = idle_sep.x
			owner.velocity.z = idle_sep.z
			return
		owner.velocity = Vector3.ZERO
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
			return
		return

	if status == Status.BLOCKED:
		owner.velocity = Vector3.ZERO
		_blocked_hold += delta
		if _blocked_hold >= 0.45:
			_blocked_hold = 0.0
			_no_progress_time = 0.0
			_stuck_time = 0.0
			_wait_timer = 0.0
			var nudge := _side_nudge()
			var retry: Vector3 = owner.move_target + nudge
			retry.y = 0.0
			status = Status.MOVING
			if agent:
				agent.target_position = retry
			_current_waypoint_index = 0
			_last_path_size = 0
		return

	if _wait_timer > 0.0:
		_wait_timer -= delta
		owner.velocity = Vector3.ZERO
		return

	var final_target := owner.move_target
	final_target.y = 0.0
	var to_final := final_target - owner.global_position
	to_final.y = 0.0
	if to_final.length() <= arrival_distance:
		_set_arrived()
		return

	if status == Status.IDLE:
		status = Status.MOVING

	_refresh_path_if_bake_changed()

	if agent == null:
		_direct_steer(final_target)
		return

	var follow := _get_follow_point(final_target)
	follow.y = 0.0
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

	var sep := _soft_body()
	var speed: float = owner.move_speed
	if sep.length_squared() > 0.001:
		var sep_n := sep.normalized()
		var ahead: float = direction.dot(-sep_n)
		if ahead > 0.55 and sep.length() > 0.6:
			if owner.unit_state != BaseUnit.UnitState.ATTACKING:
				_wait_timer = 0.06
				owner.velocity = Vector3.ZERO
				return
		var blended := direction * 0.9 + sep_n * body_push * 0.35
		if blended.length_squared() > 0.0001:
			direction = blended.normalized()
		speed *= 0.95

	status = Status.MOVING
	owner.velocity.x = direction.x * speed
	owner.velocity.z = direction.z * speed
	_face_move_dir(owner.velocity)


func _side_nudge() -> Vector3:
	var seed: int = int(owner.get_instance_id()) if owner else 0
	var a: float = float((seed * 37) % 360) * 0.0174533
	var r: float = 1.25 + float((seed * 13) % 10) * 0.1
	return Vector3(cos(a) * r, 0.0, sin(a) * r)


func _direct_steer(final_target: Vector3) -> void:
	var to_seek := final_target - owner.global_position
	to_seek.y = 0.0
	if to_seek.length() <= arrival_distance:
		_set_arrived()
		return
	var direction := to_seek.normalized()
	var sep := _soft_body()
	if sep.length_squared() > 0.001:
		var blended := direction + sep.normalized() * 0.6
		if blended.length_squared() > 0.0001:
			direction = blended.normalized()
	status = Status.MOVING
	owner.velocity.x = direction.x * owner.move_speed
	owner.velocity.z = direction.z * owner.move_speed
	_face_move_dir(owner.velocity)


func _set_arrived() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_blocked_hold = 0.0
	_wait_timer = 0.0
	_current_waypoint_index = 0
	_last_path_size = 0
	status = Status.ARRIVED


func _set_blocked() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_blocked_hold = 0.0
	status = Status.BLOCKED


func _face_move_dir(vel: Vector3) -> void:
	if owner == null or not is_instance_valid(owner):
		return
	var d := Vector3(vel.x, 0.0, vel.z)
	if d.length_squared() < 0.0004:
		return
	d = d.normalized()
	owner.rotation.y = atan2(-d.x, -d.z)


func _soft_body() -> Vector3:
	var push := Vector3.ZERO
	if UnitManager == null or owner == null:
		return push
	var attack_scale: float = 1.0
	if owner.unit_state == BaseUnit.UnitState.ATTACKING:
		attack_scale = 0.15
	var my_team: int = int(owner.team_id)
	for other in UnitManager.units:
		if other == null or other == owner or not is_instance_valid(other):
			continue
		if other.unit_state == BaseUnit.UnitState.DEAD:
			continue
		var offset := owner.global_position - other.global_position
		offset.y = 0.0
		var dist := offset.length()
		if dist < 0.001:
			var seed: int = int(owner.get_instance_id())
			var a: float = float((seed * 41) % 360) * 0.0174533
			push += Vector3(cos(a), 0.0, sin(a))
			continue
		var r: float = body_radius
		var w: float = 1.0
		if int(other.team_id) != my_team:
			r = body_radius * 0.75
			w = 0.55
		if dist >= r:
			continue
		var t: float = 1.0 - dist / r
		push += offset.normalized() * (t * t) * w * attack_scale
	return push
