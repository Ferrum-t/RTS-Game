extends RefCounted

class_name MovementComponent

## M6 Movement — DIAG only for empty path (path_n=0). No behavior change.

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
var waypoint_skip_distance: float = 0.4
var default_retarget_distance: float = 0.85

var _stuck_time: float = 0.0
var _no_progress_time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO
var _last_bake_id: int = -1
var _path_diag_timer: float = 0.0


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
	status = Status.MOVING
	if agent:
		agent.target_position = p
	print("[MOVE_SET] ", owner.name, " set_target=", p, " pos=", owner.global_position)
	_diag_agent_map("set_target")


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
	status = Status.CANCELLED
	if agent:
		agent.target_position = owner.global_position


func get_status() -> Status:
	return status


func get_target() -> Vector3:
	return owner.move_target


func _diag_agent_map(tag: String) -> void:
	if agent == null or owner == null:
		print("[AGENT_MAP_DIAG] ", tag, " agent_or_owner_null")
		return

	var agent_in_tree := agent.is_inside_tree()
	var owner_in_tree := owner.is_inside_tree()
	var agent_map := RID()
	var world_map := RID()
	var region_map := RID()
	var region_layers := -1
	var agent_layers := -1
	var map_ok := false
	var region_rid := RID()

	if agent_in_tree:
		agent_map = agent.get_navigation_map()
		agent_layers = agent.navigation_layers
	if owner_in_tree:
		world_map = owner.get_world_3d().get_navigation_map()
		map_ok = agent_map == world_map and agent_map.is_valid()

	var nav = owner.get_node_or_null("/root/NavigationBakeService")
	if nav != null and owner_in_tree:
		var scene := owner.get_tree().current_scene
		if scene:
			var region := scene.find_child("NavigationRegion3D", true, false) as NavigationRegion3D
			if region:
				region_rid = region.get_rid()
				region_layers = region.navigation_layers
				if region.is_inside_tree():
					region_map = region.get_navigation_map()

	var path_n := -1
	if agent_in_tree:
		path_n = agent.get_current_navigation_path().size()

	print(
		"[AGENT_MAP_DIAG] ", tag, " ", owner.name,
		" agent_in_tree=", agent_in_tree,
		" owner_in_tree=", owner_in_tree,
		" agent_map_valid=", agent_map.is_valid(),
		" world_map_valid=", world_map.is_valid(),
		" maps_equal=", agent_map == world_map,
		" region_map_valid=", region_map.is_valid(),
		" agent_vs_region_map=", agent_map == region_map,
		" agent_layers=", agent_layers,
		" region_layers=", region_layers,
		" path_n=", path_n,
		" bake_id=", nav.bake_id if nav else -1
	)


func _refresh_path_if_bake_changed() -> void:
	var nav = owner.get_node_or_null("/root/NavigationBakeService")
	if nav == null or not ("bake_id" in nav):
		return
	var bid: int = nav.bake_id
	if bid == _last_bake_id:
		return
	_last_bake_id = bid
	if status == Status.MOVING and agent:
		agent.target_position = owner.move_target
		_no_progress_time = 0.0
		_stuck_time = 0.0


func _get_follow_point(final_target: Vector3) -> Vector3:
	if agent == null:
		return final_target

	var path: PackedVector3Array = agent.get_current_navigation_path()
	var pos := owner.global_position
	pos.y = 0.0

	# Throttle PATH_DIAG ~4/sec to keep log readable
	if _path_diag_timer <= 0.0:
		_path_diag_timer = 0.25
		print(
			"[PATH_DIAG] ",
			owner.name,
			" path_n=", path.size(),
			" pos=", owner.global_position,
			" final=", final_target,
			" next=", path[0] if path.size() > 0 else null,
			" finished=", agent.is_navigation_finished()
		)

	if path.is_empty():
		return final_target

	var start_i := 0
	if agent.has_method("get_current_navigation_path_index"):
		start_i = int(agent.get_current_navigation_path_index())
		start_i = clampi(start_i, 0, path.size() - 1)

	for i in range(start_i, path.size()):
		var p: Vector3 = path[i]
		p.y = 0.0
		if pos.distance_to(p) > waypoint_skip_distance:
			return p

	return final_target


func update(delta: float) -> void:
	if _path_diag_timer > 0.0:
		_path_diag_timer -= delta

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
	status = Status.ARRIVED


func _set_blocked() -> void:
	_diag_agent_map("blocked")
	print(
		"[BLOCKED_DIAG] ",
		owner.name,
		" pos=", owner.global_position,
		" path_n=", agent.get_current_navigation_path().size() if agent else -1,
		" finished=", agent.is_navigation_finished() if agent else null,
		" target=", agent.target_position if agent else null,
		" move_target=", owner.move_target,
		" status=", status
	)
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
