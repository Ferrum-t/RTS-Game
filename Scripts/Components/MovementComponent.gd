extends RefCounted

class_name MovementComponent

## M6 Movement (M1 status contract):
## - Owns path execution + MovementStatus only
## - NEVER writes owner.unit_state
## - Backend: NavigationAgent3D path follow
## - ARRIVED = distance to move_target only (M1)
## - is_navigation_finished must NOT force FAILED while far from target

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
var separation_radius: float = 1.1
var separation_strength: float = 1.2

var _stuck_time: float = 0.0
var _no_progress_time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO
var _repath_cooldown: float = 0.0
var _last_bake_id: int = -1


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
	# Do not use a tight path_max_distance — it caused spurious path invalidation
	agent.path_max_distance = 50.0


func request_move(world_pos: Vector3) -> void:
	set_target(world_pos)


func set_target(world_pos: Vector3) -> void:
	var p := world_pos
	p.y = 0.0
	owner.move_target = p
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_repath_cooldown = 0.0
	_last_pos = owner.global_position
	status = Status.MOVING
	_apply_agent_target(p)


func cancel() -> void:
	owner.velocity = Vector3.ZERO
	_stuck_time = 0.0
	_no_progress_time = 0.0
	_repath_cooldown = 0.0
	status = Status.CANCELLED
	if agent:
		agent.target_position = owner.global_position


func get_status() -> Status:
	return status


func get_target() -> Vector3:
	return owner.move_target


func _apply_agent_target(p: Vector3) -> void:
	if agent == null:
		return
	agent.target_position = p


func _refresh_path_if_bake_changed() -> void:
	var nav = owner.get_node_or_null("/root/NavigationBakeService")
	if nav == null:
		return
	if not ("bake_id" in nav):
		return
	var bid: int = nav.bake_id
	if bid == _last_bake_id:
		return
	_last_bake_id = bid
	if status == Status.MOVING and agent:
		_apply_agent_target(owner.move_target)
		_no_progress_time = 0.0
		_stuck_time = 0.0
		_repath_cooldown = 0.15


func update(delta: float) -> void:
	if status == Status.CANCELLED:
		owner.velocity = Vector3.ZERO
		return

	# Terminal states: resume only if set_target already flipped to MOVING,
	# or legacy wake when still far (kept for safety).
	if status == Status.ARRIVED or status == Status.BLOCKED or status == Status.FAILED:
		var wake := owner.move_target - owner.global_position
		wake.y = 0.0
		if wake.length() > arrival_distance * 1.25:
			status = Status.MOVING
			_stuck_time = 0.0
			_no_progress_time = 0.0
			_repath_cooldown = 0.0
			_apply_agent_target(owner.move_target)
		else:
			owner.velocity = Vector3.ZERO
			return

	var final_target := owner.move_target
	final_target.y = 0.0
	var to_final := final_target - owner.global_position
	to_final.y = 0.0
	var dist_final := to_final.length()

	# --- M1 ARRIVED: distance only ---
	if dist_final <= arrival_distance:
		_set_arrived()
		return

	if status == Status.IDLE:
		status = Status.MOVING

	_refresh_path_if_bake_changed()

	if agent == null:
		_direct_steer(delta, final_target)
		return

	if _repath_cooldown > 0.0:
		_repath_cooldown -= delta

	# Path not ready / finished while still far: keep MOVING, repath, do NOT FAILED
	if agent.is_navigation_finished():
		if _repath_cooldown <= 0.0:
			_apply_agent_target(final_target)
			_repath_cooldown = 0.2
		# Soft wait — no terminal status
		owner.velocity = Vector3.ZERO
		# Still count wall-clock stuck only if we never get a path and never move
		var moved_f := owner.global_position.distance_to(_last_pos)
		_last_pos = owner.global_position
		if moved_f < 0.02:
			_no_progress_time += delta
		else:
			_no_progress_time = 0.0
		if _no_progress_time >= block_timeout * 2.0:
			_set_blocked()
		return

	var next := agent.get_next_path_position()
	next.y = 0.0
	var to_next := next - owner.global_position
	to_next.y = 0.0
	var next_len := to_next.length()

	# Near next waypoint but not at final target: advance along path, do not BLOCK yet
	if next_len < 0.05:
		# Ask agent for a fresh next; if still near self, wait briefly
		if _repath_cooldown <= 0.0:
			_apply_agent_target(final_target)
			_repath_cooldown = 0.1
		var moved_n := owner.global_position.distance_to(_last_pos)
		_last_pos = owner.global_position
		if moved_n < 0.02:
			_no_progress_time += delta
		else:
			_no_progress_time = 0.0
		if _no_progress_time >= block_timeout:
			_set_blocked()
		return

	var direction := to_next.normalized()

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
