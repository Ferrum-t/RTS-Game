extends BaseBuilding

class_name MobileBuilding

## CharacterBody3D building that can pack / move / unpack via DeploymentComponent.
## Phase 8.2: DeploymentConfig drives timings, speed, vulnerability.

@export var deployment_config: DeploymentConfig = null

@export var pack_time: float = 2.0
@export var unpack_time: float = 2.0
@export var mobile_move_speed: float = 1.5
@export var mobile_arrival_distance: float = 0.55
## Incoming damage mult in transit (overridden by deployment_config if set).
@export var transit_vulnerability: float = 1.0

var deployment: DeploymentComponent = null
var _progress_bar: Node3D = null
var _range_ring: MeshInstance3D = null


func _ready() -> void:
	_apply_deployment_config()
	super()
	deployment = DeploymentComponent.new(self)
	deployment.pack_time = pack_time
	deployment.unpack_time = unpack_time
	deployment.mobile_move_speed = mobile_move_speed
	deployment.mobile_arrival_distance = mobile_arrival_distance
	deployment.unpack_blocked.connect(_on_unpack_blocked)
	deployment.state_changed.connect(_on_deployment_state_changed)
	_setup_progress_bar()
	_setup_range_ring()


func _apply_deployment_config() -> void:
	if deployment_config == null:
		vulnerability_multiplier = transit_vulnerability
		return
	pack_time = deployment_config.pack_duration
	unpack_time = deployment_config.unpack_duration
	mobile_move_speed = deployment_config.mobile_move_speed
	mobile_arrival_distance = deployment_config.mobile_arrival_distance
	transit_vulnerability = deployment_config.vulnerability_multiplier
	vulnerability_multiplier = transit_vulnerability


func _physics_process(delta: float) -> void:
	if is_destroyed:
		return
	if deployment:
		deployment.update(delta)
	_update_progress_bar()


func request_pack() -> bool:
	return deployment != null and deployment.request_pack()


func request_move_to(world_pos: Vector3) -> bool:
	return deployment != null and deployment.request_move_to(world_pos)


func request_unpack() -> bool:
	return deployment != null and deployment.request_unpack()


func cancel_move() -> void:
	if deployment:
		deployment.cancel_move()


func get_deployment_state() -> int:
	return deployment_state


func is_deployed() -> bool:
	return deployment_state == DeploymentState.State.DEPLOYED


func get_transition_progress() -> float:
	if deployment == null:
		return 0.0
	return deployment.get_transition_progress()


func _on_unpack_blocked(reason: String) -> void:
	print(name, " Deployment: unpack blocked — ", reason)


func _on_deployment_state_changed(_old: int, new_state: int) -> void:
	_update_range_ring_visibility(new_state)


func _setup_progress_bar() -> void:
	var bar := MeshInstance3D.new()
	bar.name = "DeploymentProgressBar"
	var box := BoxMesh.new()
	box.size = Vector3(2.0, 0.12, 0.12)
	bar.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.75, 1.0, 0.95)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bar.material_override = mat
	bar.position = Vector3(0.0, 5.0, 0.0)
	bar.visible = false
	add_child(bar)
	_progress_bar = bar


func _update_progress_bar() -> void:
	if _progress_bar == null or deployment == null:
		return
	var st: int = deployment_state
	var in_transition: bool = (
		st == DeploymentState.State.PACKING
		or st == DeploymentState.State.UNPACKING
	)
	_progress_bar.visible = in_transition
	if not in_transition:
		return
	var p: float = clampf(deployment.get_transition_progress(), 0.0, 1.0)
	# Progress = time remaining ratio inverted → filled amount grows as work completes.
	var done: float = 1.0 - p
	_progress_bar.scale = Vector3(maxi(done, 0.05), 1.0, 1.0)
	var cam := get_viewport().get_camera_3d()
	if cam:
		_progress_bar.global_transform.basis = cam.global_transform.basis


func _setup_range_ring() -> void:
	var radius: float = 0.0
	if deployment_config != null:
		radius = deployment_config.attack_range_display
	if radius <= 0.0:
		return
	var ring := MeshInstance3D.new()
	ring.name = "AttackRangeRing"
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = 0.05
	cyl.radial_segments = 48
	ring.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.9, 0.4, 0.25)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring.material_override = mat
	ring.position = Vector3(0.0, 0.05, 0.0)
	ring.visible = false
	add_child(ring)
	_range_ring = ring


func _update_range_ring_visibility(state: int) -> void:
	if _range_ring == null:
		return
	# Show while mobile / unpacking so player sees coverage of the landing spot.
	_range_ring.visible = (
		state == DeploymentState.State.MOBILE
		or state == DeploymentState.State.UNPACKING
	)
