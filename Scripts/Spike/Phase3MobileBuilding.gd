extends CharacterBody3D

class_name Phase3MobileBuilding

## SPIKE ONLY — not production. CharacterBody3D stand-in for a mobile building.
## Deployed: layer 1, mask 1 (blocks Worker like TownCenter).
## Mobile: FLOATING + mask 0 so move_and_slide is not stuck on Ground (layer 1).

const NAV_HALF := Vector3(2.2, 1.0, 2.2)
const MOVE_SPEED := 4.0
const ARRIVAL := 0.55

var team_id: int = 3
var nav_agent: NavigationAgent3D = null
var _move_target: Vector3 = Vector3.ZERO
var _moving: bool = false
var last_move_status: String = "IDLE"


func _ready() -> void:
	name = "SpikeMobileBuilding"
	collision_layer = 1
	collision_mask = 1
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	floor_stop_on_slope = true

	nav_agent = NavigationAgent3D.new()
	nav_agent.name = "NavigationAgent3D"
	add_child(nav_agent)
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = ARRIVAL
	nav_agent.radius = 0.4
	nav_agent.height = 1.2
	nav_agent.avoidance_enabled = false
	nav_agent.path_max_distance = 50.0

	_print_collision_diag()


func _print_collision_diag() -> void:
	var shape_info := "none"
	var cs := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if cs and cs.shape:
		if cs.shape is BoxShape3D:
			var b := cs.shape as BoxShape3D
			shape_info = "BoxShape3D size=%s offset=%s" % [b.size, cs.position]
		else:
			shape_info = str(cs.shape.get_class())
	print("[SPIKE] building collision_layer=", collision_layer,
		" collision_mask=", collision_mask,
		" motion_mode=", motion_mode,
		" shape=", shape_info,
		" pos=", global_position,
		" team_id=", team_id)


func register_nav() -> void:
	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.register_building(self, NAV_HALF)
		print("[SPIKE] register_building at ", global_position)


func unregister_nav() -> void:
	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.unregister_building(self)
		print("[SPIKE] unregister_building")


func update_nav_position() -> void:
	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.update_building_position(self)
		print("[SPIKE] update_building_position → ", global_position)


func request_move_to(world_pos: Vector3) -> void:
	_move_target = world_pos
	_move_target.y = 0.0
	_moving = true
	last_move_status = "MOVING"
	# MOBILE: do not stick on Ground (layer 1) or other static geometry
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	collision_mask = 0
	if nav_agent:
		nav_agent.target_position = _move_target
	print("[SPIKE] building request_move_to ", _move_target,
		" (FLOATING, mask=0)")


func stop_move() -> void:
	_moving = false
	velocity = Vector3.ZERO
	last_move_status = "IDLE"
	_set_deployed_collision()


func _set_deployed_collision() -> void:
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	collision_layer = 1
	collision_mask = 1


func _physics_process(_delta: float) -> void:
	if not _moving:
		velocity = Vector3.ZERO
		return

	var to_final := _move_target - global_position
	to_final.y = 0.0
	if to_final.length() <= ARRIVAL:
		velocity = Vector3.ZERO
		_moving = false
		last_move_status = "ARRIVED"
		_set_deployed_collision()
		print("[SPIKE] building ARRIVED at ", global_position,
			" (restored GROUNDED mask=1)")
		return

	# Prefer direct horizontal move while unregistered (nav optional)
	var dir := to_final.normalized()
	velocity.x = dir.x * MOVE_SPEED
	velocity.z = dir.z * MOVE_SPEED
	velocity.y = 0.0
	move_and_slide()

	# If still not progressing (safety), kinematic fallback
	if get_slide_collision_count() > 0 or global_position.distance_to(_move_target) > to_final.length() - 0.01:
		pass

	if Engine.get_physics_frames() % 30 == 0:
		print("[SPIKE] building moving pos=", global_position,
			" vel=", velocity, " status=", last_move_status,
			" mask=", collision_mask, " target=", _move_target)
