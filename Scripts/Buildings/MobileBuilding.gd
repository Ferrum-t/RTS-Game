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
var _progress_root: Node3D = null
var _progress_bg: MeshInstance3D = null
var _progress_fill: MeshInstance3D = null
var _range_ring: MeshInstance3D = null
var _select_ring: MeshInstance3D = null
const _BAR_WIDTH: float = 2.2
const _BAR_HEIGHT: float = 5.2
const _BAR_THICKNESS: float = 0.16


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
	_setup_select_ring()


func set_building_selected(on: bool) -> void:
	super.set_building_selected(on)
	if _select_ring:
		_select_ring.visible = on


func _setup_select_ring() -> void:
	var ring := MeshInstance3D.new()
	ring.name = "BuildingSelectRing"
	var he: float = 2.5
	if nav_half_extents is Vector3:
		he = maxf(nav_half_extents.x, nav_half_extents.z) + 0.4
	ring.mesh = _make_ground_ring_mesh(he, 0.18, 48)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.15, 0.85)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring.material_override = mat
	ring.position = Vector3(0.0, 0.08, 0.0)
	ring.visible = false
	add_child(ring)
	_select_ring = ring


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
	var root := Node3D.new()
	root.name = "DeploymentProgressRoot"
	root.position = Vector3(0.0, _BAR_HEIGHT, 0.0)
	root.visible = false
	add_child(root)
	_progress_root = root

	var bg := MeshInstance3D.new()
	bg.name = "DeploymentProgressBg"
	var bg_mesh := QuadMesh.new()
	bg_mesh.size = Vector2(_BAR_WIDTH, _BAR_THICKNESS)
	bg.mesh = bg_mesh
	var bg_mat := StandardMaterial3D.new()
	bg_mat.albedo_color = Color(0.08, 0.08, 0.1, 0.92)
	bg_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bg_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	bg.material_override = bg_mat
	root.add_child(bg)
	_progress_bg = bg

	var fill := MeshInstance3D.new()
	fill.name = "DeploymentProgressBar"
	var fill_mesh := QuadMesh.new()
	fill_mesh.size = Vector2(_BAR_WIDTH, _BAR_THICKNESS)
	fill.mesh = fill_mesh
	var fill_mat := StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.15, 0.85, 1.0, 1.0)
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fill_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	fill.material_override = fill_mat
	fill.position = Vector3(0.0, 0.0, 0.001)
	root.add_child(fill)
	_progress_fill = fill


func _update_progress_bar() -> void:
	if _progress_root == null or _progress_fill == null or deployment == null:
		return
	var st: int = deployment_state
	var in_transition: bool = (
		st == DeploymentState.State.PACKING
		or st == DeploymentState.State.UNPACKING
	)
	_progress_root.visible = in_transition
	if not in_transition:
		return

	_billboard_progress_toward_camera()

	var remaining: float = clampf(deployment.get_transition_progress(), 0.0, 1.0)
	var done: float = 1.0 - remaining
	done = maxf(done, 0.02)
	_progress_fill.scale = Vector3(done, 1.0, 1.0)
	_progress_fill.position = Vector3(-_BAR_WIDTH * 0.5 * (1.0 - done), 0.0, 0.001)
	if _progress_bg:
		_progress_bg.position = Vector3(0.0, 0.0, 0.0)


func _billboard_progress_toward_camera() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		return
	var origin: Vector3 = _progress_root.global_position
	_progress_root.global_transform = Transform3D(cam.global_transform.basis, origin)


func _setup_range_ring() -> void:
	var radius: float = 0.0
	if deployment_config != null:
		radius = deployment_config.attack_range_display
	if radius <= 0.0:
		return

	var ring := MeshInstance3D.new()
	ring.name = "AttackRangeRing"
	ring.mesh = _make_ground_ring_mesh(radius, 0.28, 64)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.25, 1.0, 0.45, 0.7)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring.material_override = mat
	ring.position = Vector3(0.0, 0.12, 0.0)
	ring.visible = false
	add_child(ring)
	_range_ring = ring


func _make_ground_ring_mesh(radius: float, thickness: float, segments: int) -> ArrayMesh:
	var r_out: float = radius
	var r_in: float = maxf(radius - thickness, 0.5)
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var indices := PackedInt32Array()
	for i in range(segments):
		var a0: float = TAU * float(i) / float(segments)
		var a1: float = TAU * float(i + 1) / float(segments)
		var c0 := Vector3(cos(a0), 0.0, sin(a0))
		var c1 := Vector3(cos(a1), 0.0, sin(a1))
		var base: int = verts.size()
		verts.append(c0 * r_in)
		verts.append(c0 * r_out)
		verts.append(c1 * r_out)
		verts.append(c1 * r_in)
		for _j in range(4):
			norms.append(Vector3.UP)
		indices.append_array([base + 0, base + 1, base + 2, base + 0, base + 2, base + 3])

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = norms
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _update_range_ring_visibility(state: int) -> void:
	if _range_ring == null:
		return
	_range_ring.visible = (
		state == DeploymentState.State.MOBILE
		or state == DeploymentState.State.UNPACKING
	)
