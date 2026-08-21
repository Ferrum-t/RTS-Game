extends Node

## M6: thin nav bake helper. Not a gameplay manager.
## Runtime buildings register footprints → debounced NavigationMesh rebake.
## M6.8 DIAG: dump actual baked mesh near footprints (no gameplay change).

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

## Last applied mesh (for diagnostics only)
var _last_mesh: NavigationMesh = null


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
		_last_mesh = nav_mesh
		bake_id += 1
		print("NavigationBakeService: mesh applied, footprints=", _footprints.size(), " bake_id=", bake_id, " agent_radius=", AGENT_RADIUS)
		_diag_dump_mesh(nav_mesh)

	if _pending_after_bake:
		_pending_after_bake = false
		request_rebake()


func _diag_dump_mesh(nav_mesh: NavigationMesh) -> void:
	if nav_mesh == null:
		return
	var verts: PackedVector3Array = nav_mesh.get_vertices()
	var poly_count: int = nav_mesh.get_polygon_count()
	print("[NAV_MESH_DIAG] vertices=", verts.size(), " polygons=", poly_count)

	if _footprints.is_empty():
		print("[NAV_MESH_DIAG] no footprints — skip local dump")
		return

	for id in _footprints.keys():
		var data: Dictionary = _footprints[id]
		var center: Vector3 = data["center"]
		var he: Vector3 = data["half_extents"]
		var hx: float = he.x + FOOTPRINT_MARGIN
		var hz: float = he.z + FOOTPRINT_MARGIN
		var xmin := center.x - hx
		var xmax := center.x + hx
		var zmin := center.z - hz
		var zmax := center.z + hz
		print(
			"[NAV_MESH_DIAG] footprint center=", center,
			" nav_he=", he,
			" carved_outline X=[", xmin, ", ", xmax, "] Z=[", zmin, ", ", zmax, "]"
		)

		# Vertices inside / near carved box (pad 0.5 for boundary)
		var pad := 0.5
		var near_indices: Array[int] = []
		for i in range(verts.size()):
			var v: Vector3 = verts[i]
			if v.x >= xmin - pad and v.x <= xmax + pad and v.z >= zmin - pad and v.z <= zmax + pad:
				near_indices.append(i)
				var inside_carve := v.x >= xmin and v.x <= xmax and v.z >= zmin and v.z <= zmax
				print("[NAV_MESH_DIAG] vertex[", i, "]=", v, " inside_carve=", inside_carve)

		# Polygons that touch the padded region
		var polys_near := 0
		var polys_inside_any_vert := 0
		for pi in range(poly_count):
			var poly: PackedInt32Array = nav_mesh.get_polygon(pi)
			var touches := false
			var any_inside := false
			var poly_verts: Array = []
			for k in range(poly.size()):
				var idx: int = poly[k]
				if idx < 0 or idx >= verts.size():
					continue
				var pv: Vector3 = verts[idx]
				poly_verts.append(pv)
				if pv.x >= xmin - pad and pv.x <= xmax + pad and pv.z >= zmin - pad and pv.z <= zmax + pad:
					touches = true
				if pv.x >= xmin and pv.x <= xmax and pv.z >= zmin and pv.z <= zmax:
					any_inside = true
			if touches:
				polys_near += 1
				if any_inside:
					polys_inside_any_vert += 1
				print("[NAV_MESH_DIAG] poly[", pi, "] verts=", poly_verts, " any_vert_inside_carve=", any_inside)
		print("[NAV_MESH_DIAG] polys_near_carve=", polys_near, " polys_with_vert_inside_carve=", polys_inside_any_vert)

		# Known problematic waypoint from stuck log (relative check uses this bake's center)
		var test_pts: Array[Vector3] = [
			Vector3(3.065122, 0.0, -1.500356),
			Vector3(2.790336, 0.0, -2.5509),
			Vector3(center.x + 2.39, 0.0, center.z - 1.21), # ~same offset as problem wp from logged center
		]
		for tp in test_pts:
			var in_carve := tp.x >= xmin and tp.x <= xmax and tp.z >= zmin and tp.z <= zmax
			var in_poly := _point_in_any_polygon_xz(nav_mesh, verts, tp)
			print(
				"[NAV_MESH_DIAG] test_point=", tp,
				" inside_carve_aabb=", in_carve,
				" inside_any_nav_polygon=", in_poly
			)


func _point_in_any_polygon_xz(nav_mesh: NavigationMesh, verts: PackedVector3Array, p: Vector3) -> bool:
	var pc: int = nav_mesh.get_polygon_count()
	for pi in range(pc):
		var poly: PackedInt32Array = nav_mesh.get_polygon(pi)
		if poly.size() < 3:
			continue
		# Fan triangulation from first vertex
		var i0: int = poly[0]
		if i0 < 0 or i0 >= verts.size():
			continue
		var a: Vector3 = verts[i0]
		for k in range(1, poly.size() - 1):
			var i1: int = poly[k]
			var i2: int = poly[k + 1]
			if i1 < 0 or i1 >= verts.size() or i2 < 0 or i2 >= verts.size():
				continue
			var b: Vector3 = verts[i1]
			var c: Vector3 = verts[i2]
			if _point_in_triangle_xz(p, a, b, c):
				return true
	return false


func _point_in_triangle_xz(p: Vector3, a: Vector3, b: Vector3, c: Vector3) -> bool:
	var px := p.x
	var pz := p.z
	var v0x := c.x - a.x
	var v0z := c.z - a.z
	var v1x := b.x - a.x
	var v1z := b.z - a.z
	var v2x := px - a.x
	var v2z := pz - a.z
	var dot00 := v0x * v0x + v0z * v0z
	var dot01 := v0x * v1x + v0z * v1z
	var dot02 := v0x * v2x + v0z * v2z
	var dot11 := v1x * v1x + v1z * v1z
	var dot12 := v1x * v2x + v1z * v2z
	var inv := dot00 * dot11 - dot01 * dot01
	if absf(inv) < 0.0000001:
		return false
	inv = 1.0 / inv
	var u := (dot11 * dot02 - dot01 * dot12) * inv
	var v := (dot00 * dot12 - dot01 * dot02) * inv
	return u >= -0.001 and v >= -0.001 and (u + v) <= 1.001


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
