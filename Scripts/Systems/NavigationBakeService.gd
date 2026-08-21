extends Node

## M6: thin nav bake helper. Not a gameplay manager.
## Runtime buildings register footprints → debounced NavigationMesh rebake.

const DEBOUNCE_SEC := 0.08
const MAP_HALF := 50.0
## DIAG TEMP: was 0.55 — doubled to 1.1 to measure actual clearance change
const AGENT_RADIUS := 1.1
const AGENT_HEIGHT := 1.5
const DEFAULT_BUILDING_HALF := 2.2
const FOOTPRINT_MARGIN := 0.7

## id (instance_id) -> { center: Vector3, half_extents: Vector3 }
var _footprints: Dictionary = {}

var _debounce_left: float = -1.0
var _baking: bool = false
var _bake_generation: int = 0
var _pending_after_bake: bool = false

## Incremented when a mesh is successfully applied (Movement watches this)
var bake_id: int = 0

var _region: NavigationRegion3D = null


func _ready() -> void:
	call_deferred("_initial_bake")


func _process(delta: float) -> void:
	if _debounce_left < 0.0:
		return
	_debounce_left -= delta
	if _debounce_left <= 0.0:
		_debounce_left = -1.0
		_run_bake()


func register_building(building: Node3D, half_extents: Vector3 = Vector3.ZERO) -> void:
	if building == null or not is_instance_valid(building):
		return
	var id: int = building.get_instance_id()
	var he := half_extents
	if he == Vector3.ZERO:
		he = Vector3(DEFAULT_BUILDING_HALF, 1.0, DEFAULT_BUILDING_HALF)
	_footprints[id] = {
		"center": building.global_position,
		"half_extents": he,
	}
	request_rebake()


func unregister_building(building: Node3D) -> void:
	if building == null:
		return
	var id: int = building.get_instance_id()
	if _footprints.has(id):
		_footprints.erase(id)
		request_rebake()


func update_building_position(building: Node3D) -> void:
	if building == null or not is_instance_valid(building):
		return
	var id: int = building.get_instance_id()
	if not _footprints.has(id):
		return
	_footprints[id]["center"] = building.global_position
	request_rebake()


func request_rebake() -> void:
	if _baking:
		_pending_after_bake = true
		return
	_debounce_left = DEBOUNCE_SEC


func _initial_bake() -> void:
	_resolve_region()
	_run_bake()


func _resolve_region() -> void:
	if _region != null and is_instance_valid(_region):
		return
	var scene := get_tree().current_scene
	if scene == null:
		return
	_region = scene.find_child("NavigationRegion3D", true, false) as NavigationRegion3D


func _run_bake() -> void:
	_resolve_region()
	if _region == null:
		push_warning("NavigationBakeService: NavigationRegion3D not found")
		return
	if _baking:
		_pending_after_bake = true
		return

	_baking = true
	_bake_generation += 1
	var gen := _bake_generation

	var nav_mesh := NavigationMesh.new()
	nav_mesh.agent_radius = AGENT_RADIUS
	nav_mesh.agent_height = AGENT_HEIGHT
	nav_mesh.agent_max_climb = 0.3
	nav_mesh.agent_max_slope = 45.0
	nav_mesh.cell_size = 0.25
	nav_mesh.cell_height = 0.25

	var source := NavigationMeshSourceGeometryData3D.new()
	_add_ground_faces(source)
	_add_building_obstructions(source)

	NavigationServer3D.bake_from_source_geometry_data(
		nav_mesh,
		source,
		_on_bake_done.bind(nav_mesh, gen)
	)


func _on_bake_done(nav_mesh: NavigationMesh, gen: int) -> void:
	_baking = false
	if gen != _bake_generation:
		if _pending_after_bake:
			_pending_after_bake = false
			request_rebake()
		return

	_resolve_region()
	if _region != null and is_instance_valid(_region):
		_region.navigation_mesh = nav_mesh
		bake_id += 1
		print("NavigationBakeService: mesh applied, footprints=", _footprints.size(), " bake_id=", bake_id, " agent_radius=", AGENT_RADIUS)

	if _pending_after_bake:
		_pending_after_bake = false
		request_rebake()


func _add_ground_faces(source: NavigationMeshSourceGeometryData3D) -> void:
	var s := MAP_HALF
	var faces := PackedVector3Array([
		Vector3(-s, 0.0, -s), Vector3(s, 0.0, -s), Vector3(s, 0.0, s),
		Vector3(-s, 0.0, -s), Vector3(s, 0.0, s), Vector3(-s, 0.0, s),
	])
	source.add_faces(faces, Transform3D.IDENTITY)


func _add_building_obstructions(source: NavigationMeshSourceGeometryData3D) -> void:
	for id in _footprints.keys():
		var data: Dictionary = _footprints[id]
		var center: Vector3 = data["center"]
		var he: Vector3 = data["half_extents"]
		var hx: float = he.x + FOOTPRINT_MARGIN
		var hz: float = he.z + FOOTPRINT_MARGIN
		var outline := PackedVector3Array([
			Vector3(center.x - hx, 0.0, center.z - hz),
			Vector3(center.x + hx, 0.0, center.z - hz),
			Vector3(center.x + hx, 0.0, center.z + hz),
			Vector3(center.x - hx, 0.0, center.z + hz),
		])
		source.add_projected_obstruction(outline, 0.0, 4.0, true)
