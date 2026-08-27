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
var _progress_bg: MeshInstance3D = null
var _progress_fill: MeshInstance3D = null
var _range_ring: MeshInstance3D = null
const _BAR_WIDTH: float = 2.2
const _BAR_HEIGHT: float = 5.2


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
	# Dark background track
	var bg := MeshInstance3D.new()
	bg.name = "DeploymentProgressBg"
	var bg_mesh := BoxMesh.new()
	bg_mesh.size = Vector3(_BAR_WIDTH, 0.14, 0.14)
	bg.mesh = bg_mesh
	var bg_mat := StandardMaterial3D.new()
	bg_mat.albedo_color = Color(0.08, 0.08, 0.1, 0.9)
	bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bg.material_override = bg_mat
	bg.position = Vector3(0.0, _BAR_HEIGHT, 0.0)
	bg.visible = false
	add_child(bg)
	_progress_bg = bg

	# Cyan fill grows left → right as pack/unpack completes
	var fill := MeshInstance3D.new()
	fill.name = "DeploymentProgressBar"
	var fill_mesh := BoxMesh.new()
	fill_mesh.size = Vector3(_BAR_WIDTH, 0.16, 0.16)
	fill.mesh = fill_mesh
	var fill_mat := StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.15, 0.85, 1.0, 1.0)
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fill.material_override = fill_mat
	fill.position = Vector3(0.0, _BAR_HEIGHT, 0.0)
	fill.visible = false
	add_child(fill)
	_progress_fill = fill


func _update_progress_bar() -> void:
	if _progress_fill == null or deployment == null:
		return
	var st: int = deployment_state
	var in_transition: bool = (
		st == DeploymentState.State.PACKING
		or st == DeploymentState.State.UNPACKING
	)
	if _progress_bg:
		_progress_bg.visible = in_transition
	_progress_fill.visible = in_transition
	if not in_transition:
		return

	var remaining: float = clampf(deployment.get_transition_progress(), 0.0, 1.0)
	var done: float = 1.0 - remaining
	done = maxf(done, 0.02)
	# Scale fill width; keep left edge fixed under the bar center-left.
	_progress_fill.scale = Vector3(done, 1.0, 1.0)
	_progress_fill.position = Vector3(-_BAR_WIDTH * 0.5 * (1.0 - done), _BAR_HEIGHT, 0.0)
	if _progress_bg:
		_progress_bg.position = Vector3(0.0, _BAR_HEIGHT, 0.0)


func _setup_range_ring() -> void:
	var radius: float = 0.0
	if deployment_config != null:
		radius = deployment_config.attack_range_display
	if radius <= 0.0:
		return
	# Thin torus outline — NOT a solid disc (CylinderMesh looked like a giant blotch).
	var ring := MeshInstance3D.new()
	ring.name = "AttackRangeRing"
	var torus := TorusMesh.new()
	torus.inner_radius = maxf(radius - 0.35, 0.5)
	torus.outer_radius = radius
	torus.rings = 48
	torus.ring_segments = 16
	ring.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.25, 1.0, 0.45, 0.55)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring.material_override = mat
	# Flat on ground
	ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	ring.position = Vector3(0.0, 0.08, 0.0)
	ring.visible = false
	add_child(ring)
	_range_ring = ring


func _update_range_ring_visibility(state: int) -> void:
	if _range_ring == null:
		return
	_range_ring.visible = (
		state == DeploymentState.State.MOBILE
		or state == DeploymentState.State.UNPACKING
	)
