extends RefCounted

class_name DeploymentComponent

## Phase 4/8.1 FSM: DEPLOYED → PACKING → MOBILE → UNPACKING → DEPLOYED
## Phase 8.2: placement validation before UNPACKING; progress for UI.

signal state_changed(old_state: int, new_state: int)
signal pack_started()
signal pack_finished()
signal move_started(target: Vector3)
signal move_arrived(position: Vector3)
signal unpack_started()
signal unpack_finished()
signal unpack_blocked(reason: String)

var owner: CharacterBody3D = null

var pack_time: float = 2.0
var unpack_time: float = 2.0
var mobile_move_speed: float = 1.5
var mobile_arrival_distance: float = 0.55

var _timer: float = 0.0
var _timer_max: float = 0.0
var _moving: bool = false
var _move_target: Vector3 = Vector3.ZERO


func _init(building: CharacterBody3D) -> void:
	owner = building


func get_state() -> int:
	return int(owner.get("deployment_state"))


## 1.0 at start of PACKING/UNPACKING, 0.0 when timer finishes.
func get_transition_progress() -> float:
	var st: int = get_state()
	if st != DeploymentState.State.PACKING and st != DeploymentState.State.UNPACKING:
		return 0.0
	if _timer_max <= 0.0:
		return 0.0
	return clampf(_timer / _timer_max, 0.0, 1.0)


func can_pack() -> bool:
	if owner == null or not is_instance_valid(owner):
		return false
	if owner.get("is_destroyed") == true:
		return false
	if get_state() != DeploymentState.State.DEPLOYED:
		return false
	if owner.get("is_training") == true:
		return false
	return true


func can_move() -> bool:
	if owner == null or not is_instance_valid(owner):
		return false
	if get_state() != DeploymentState.State.MOBILE:
		return false
	return true


func can_unpack() -> bool:
	if owner == null or not is_instance_valid(owner):
		return false
	if get_state() != DeploymentState.State.MOBILE:
		return false
	if _moving:
		return false
	return true


func request_pack() -> bool:
	if not can_pack():
		print(owner.name, " Deployment: cannot pack")
		return false
	_set_state(DeploymentState.State.PACKING)
	_timer_max = pack_time
	_timer = pack_time
	_moving = false
	pack_started.emit()
	print(owner.name, " Deployment: PACKING (", pack_time, "s)")
	return true


func request_move_to(world_pos: Vector3) -> bool:
	if not can_move():
		print(owner.name, " Deployment: cannot move (need MOBILE)")
		return false
	_move_target = world_pos
	_move_target.y = 0.0
	_moving = true
	_apply_mobile_collision()
	move_started.emit(_move_target)
	print(owner.name, " Deployment: move to ", _move_target)
	return true


func request_unpack() -> bool:
	if not can_unpack():
		print(owner.name, " Deployment: cannot unpack")
		return false
	# Phase 8.2 — refuse unpack if footprint overlaps other buildings.
	var reason: String = _validate_placement()
	if reason != "":
		unpack_blocked.emit(reason)
		print(owner.name, " Deployment: unpack blocked — ", reason)
		return false
	_moving = false
	owner.velocity = Vector3.ZERO
	_apply_deployed_collision()
	_register_nav()
	_set_state(DeploymentState.State.UNPACKING)
	_timer_max = unpack_time
	_timer = unpack_time
	unpack_started.emit()
	print(owner.name, " Deployment: UNPACKING at ", owner.global_position, " (", unpack_time, "s)")
	return true


func cancel_move() -> void:
	if get_state() != DeploymentState.State.MOBILE:
		return
	_moving = false
	owner.velocity = Vector3.ZERO
	print(owner.name, " Deployment: move cancelled (still MOBILE)")


func update(delta: float) -> void:
	if owner == null or not is_instance_valid(owner):
		return
	if owner.get("is_destroyed") == true:
		return

	var st: int = get_state()
	match st:
		DeploymentState.State.PACKING:
			_timer -= delta
			if _timer <= 0.0:
				_finish_pack()
		DeploymentState.State.MOBILE:
			_update_move(delta)
		DeploymentState.State.UNPACKING:
			_timer -= delta
			if _timer <= 0.0:
				_finish_unpack()
		_:
			owner.velocity = Vector3.ZERO


func _finish_pack() -> void:
	_unregister_nav()
	_set_state(DeploymentState.State.MOBILE)
	_apply_mobile_collision()
	owner.velocity = Vector3.ZERO
	_moving = false
	pack_finished.emit()
	print(owner.name, " Deployment: MOBILE (footprint cleared)")


func _finish_unpack() -> void:
	_set_state(DeploymentState.State.DEPLOYED)
	_apply_deployed_collision()
	unpack_finished.emit()
	print(owner.name, " Deployment: DEPLOYED at ", owner.global_position)


func _update_move(_delta: float) -> void:
	if not _moving:
		owner.velocity = Vector3.ZERO
		return

	var to_t: Vector3 = _move_target - owner.global_position
	to_t.y = 0.0
	if to_t.length() <= mobile_arrival_distance:
		owner.velocity = Vector3.ZERO
		_moving = false
		var pos: Vector3 = owner.global_position
		pos.y = 0.0
		owner.global_position = pos
		move_arrived.emit(pos)
		print(owner.name, " Deployment: ARRIVED ", pos)
		return

	var dir: Vector3 = to_t.normalized()
	owner.velocity = Vector3(dir.x * mobile_move_speed, 0.0, dir.z * mobile_move_speed)
	owner.move_and_slide()
	var p: Vector3 = owner.global_position
	p.y = 0.0
	owner.global_position = p
	owner.velocity.y = 0.0


func _set_state(new_state: int) -> void:
	var old_state: int = get_state()
	if old_state == new_state:
		return
	owner.set("deployment_state", new_state)
	if owner.has_method("recompute_stats"):
		owner.recompute_stats()
	state_changed.emit(old_state, new_state)


## Returns empty string if OK, else human-readable block reason.
func _validate_placement() -> String:
	var bm := owner.get_node_or_null("/root/BuildingManager")
	if bm == null:
		return ""
	var he: Vector3 = Vector3(2.2, 1.0, 2.2)
	if owner.get("nav_half_extents") != null:
		he = owner.nav_half_extents
	var my_pos: Vector3 = owner.global_position
	my_pos.y = 0.0
	var margin: float = 0.4
	for b in bm.buildings:
		if b == null or not is_instance_valid(b):
			continue
		if b == owner:
			continue
		if b.get("is_destroyed") == true:
			continue
		if b.get("health") != null and int(b.health) <= 0:
			continue
		var other_he: Vector3 = Vector3(2.2, 1.0, 2.2)
		if b.get("nav_half_extents") != null:
			other_he = b.nav_half_extents
		var op: Vector3 = b.global_position
		op.y = 0.0
		var dx: float = absf(my_pos.x - op.x)
		var dz: float = absf(my_pos.z - op.z)
		var need_x: float = he.x + other_he.x + margin
		var need_z: float = he.z + other_he.z + margin
		if dx < need_x and dz < need_z:
			return "footprint overlaps " + str(b.name)
	return ""


func _unregister_nav() -> void:
	var nav := owner.get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.unregister_building(owner)


func _register_nav() -> void:
	var nav := owner.get_node_or_null("/root/NavigationBakeService")
	if nav == null:
		return
	var he: Vector3 = Vector3(2.2, 1.0, 2.2)
	if owner.get("nav_half_extents") != null:
		he = owner.nav_half_extents
	nav.register_building(owner, he)


func _apply_mobile_collision() -> void:
	owner.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	owner.collision_layer = 1
	owner.collision_mask = 1


func _apply_deployed_collision() -> void:
	owner.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	owner.collision_layer = 1
	owner.collision_mask = 1
	owner.velocity = Vector3.ZERO
