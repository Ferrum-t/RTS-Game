extends Node

## Environment Zones — Stage 1.5 Slice A: fixed climate regions + seasonal state.
## Geometry does not move. Season changes state only.
## Public API for harvest: get_multiplier_at(world_pos) — signature preserved.
## HarvestComponent is not modified in Slice A.
## No velocity / drift / bounce / TRANSITION / overlap priority.

enum ClimateState {
	COLD,
	FAVORABLE,
	DRY,
}

## Schedule templates: equal thirds of season_progress.
## A: FAV → DRY → COLD
## B: DRY → COLD → FAV
## C: COLD → FAV → DRY
enum ScheduleId {
	A,
	B,
	C,
}

const _MULT := {
	ClimateState.FAVORABLE: 1.5,
	ClimateState.DRY: 0.5,
	ClimateState.COLD: 0.5,
}

const _COLOR := {
	ClimateState.FAVORABLE: Color(0.15, 0.8, 0.25, 0.55),
	ClimateState.DRY: Color(0.95, 0.38, 0.12, 0.62),
	ClimateState.COLD: Color(0.25, 0.55, 1.0, 0.68),
}

## Minimum gap so circles neither overlap nor touch.
const REGION_GAP := 2.0

## Full season cycle length (seconds). Export for F5 tuning only.
@export var season_duration_sec: float = 180.0

## Debug ground discs (static). Color follows current state.
@export var debug_draw: bool = true

## season_progress ∈ [0, 1). Advances from season_duration_sec.
var season_progress: float = 0.0

var regions: Array = []
var _visual_root: Node3D = null
var _last_logged_slot: int = -1


class ClimateRegion:
	extends RefCounted
	var id: String = ""
	var center: Vector3 = Vector3.ZERO
	var radius: float = 14.0
	var schedule_id: int = ScheduleId.A
	var mesh_instance: MeshInstance3D = null
	var label: Label3D = null


func _ready() -> void:
	_spawn_regions()
	_assert_non_overlap()
	if debug_draw:
		_ensure_visual_root()
		_build_visuals()
	_print_startup()


func _process(delta: float) -> void:
	if season_duration_sec <= 0.001:
		return
	var prev_slot: int = _season_slot(season_progress)
	season_progress = fposmod(season_progress + delta / season_duration_sec, 1.0)
	var slot: int = _season_slot(season_progress)
	if slot != prev_slot:
		_on_season_slot_changed(slot)
	_update_visual_colors()


## Public API — used by HarvestComponent. Do not change signature.
## Neutral land (outside all regions) → 1.0
func get_multiplier_at(world_pos: Vector3) -> float:
	var region: ClimateRegion = get_region_at(world_pos)
	if region == null:
		return 1.0
	var state: int = get_region_state(region)
	return float(_MULT.get(state, 1.0))


func get_region_at(world_pos: Vector3) -> ClimateRegion:
	var p := Vector2(world_pos.x, world_pos.z)
	for r in regions:
		var region: ClimateRegion = r
		var c := Vector2(region.center.x, region.center.z)
		if p.distance_to(c) <= region.radius:
			return region
	return null


func get_region_state(region: ClimateRegion) -> int:
	if region == null:
		return ClimateState.FAVORABLE
	return _state_for_schedule(region.schedule_id, _season_slot(season_progress))


func _season_slot(progress: float) -> int:
	var p: float = fposmod(progress, 1.0)
	var slot: int = int(floor(p * 3.0))
	if slot > 2:
		slot = 2
	return slot


func _state_for_schedule(schedule_id: int, slot: int) -> int:
	# Tables match pre-code validation.
	match schedule_id:
		ScheduleId.A:
			# FAV → DRY → COLD
			match slot:
				0:
					return ClimateState.FAVORABLE
				1:
					return ClimateState.DRY
				_:
					return ClimateState.COLD
		ScheduleId.B:
			# DRY → COLD → FAV
			match slot:
				0:
					return ClimateState.DRY
				1:
					return ClimateState.COLD
				_:
					return ClimateState.FAVORABLE
		ScheduleId.C:
			# COLD → FAV → DRY
			match slot:
				0:
					return ClimateState.COLD
				1:
					return ClimateState.FAVORABLE
				_:
					return ClimateState.DRY
		_:
			return ClimateState.FAVORABLE


func _spawn_regions() -> void:
	regions.clear()
	# Pre-code validated layout (GAP>=2, home coverage of TC + starter resources).
	var specs: Array = [
		{"id": "R0", "center": Vector3(32.0, 0.0, -30.0), "radius": 14.0, "schedule": ScheduleId.A},
		{"id": "R1", "center": Vector3(-30.0, 0.0, 30.0), "radius": 14.0, "schedule": ScheduleId.A},
		{"id": "R2", "center": Vector3(55.0, 0.0, 5.0), "radius": 14.0, "schedule": ScheduleId.B},
		{"id": "R3", "center": Vector3(-55.0, 0.0, -5.0), "radius": 14.0, "schedule": ScheduleId.C},
	]
	for s in specs:
		var region := ClimateRegion.new()
		region.id = str(s["id"])
		region.center = s["center"]
		region.radius = float(s["radius"])
		region.schedule_id = int(s["schedule"])
		regions.append(region)


func _assert_non_overlap() -> void:
	for i in range(regions.size()):
		for j in range(i + 1, regions.size()):
			var a: ClimateRegion = regions[i]
			var b: ClimateRegion = regions[j]
			var d: float = Vector2(a.center.x - b.center.x, a.center.z - b.center.z).length()
			var need: float = a.radius + b.radius + REGION_GAP
			if d < need:
				push_error(
					"[ZONE] OVERLAP/TOUCH %s-%s dist=%.2f need=%.2f (gap=%.1f)"
					% [a.id, b.id, d, need, REGION_GAP]
				)
			else:
				print("[ZONE] non-overlap OK %s-%s dist=%.2f need=%.2f" % [a.id, b.id, d, need])


func _on_season_slot_changed(slot: int) -> void:
	_last_logged_slot = slot
	print("[ZONE] season slot → ", slot, " progress=", snappedf(season_progress, 0.001))
	for r in regions:
		var region: ClimateRegion = r
		var st: int = get_region_state(region)
		print(
			"[ZONE] ", region.id,
			" state=", _state_name(st),
			" mult=", float(_MULT.get(st, 1.0)),
			" center=", region.center,
			" radius=", region.radius
		)


func _ensure_visual_root() -> void:
	if _visual_root != null and is_instance_valid(_visual_root):
		return
	var scene := get_tree().current_scene
	if scene == null:
		call_deferred("_ensure_visual_root")
		call_deferred("_build_visuals")
		return
	_visual_root = Node3D.new()
	_visual_root.name = "EnvironmentZoneVisuals"
	scene.add_child(_visual_root)


func _build_visuals() -> void:
	if not debug_draw:
		return
	if _visual_root == null or not is_instance_valid(_visual_root):
		return
	for child in _visual_root.get_children():
		child.queue_free()

	for r in regions:
		var region: ClimateRegion = r
		var st: int = get_region_state(region)

		var mi := MeshInstance3D.new()
		mi.name = "RegionDisc_%s" % region.id
		mi.mesh = _make_ground_disc_mesh(region.radius, 48)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = _COLOR.get(st, Color(1, 1, 1, 0.5))
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
		mi.material_override = mat
		# Static position — never updated for motion.
		mi.position = Vector3(region.center.x, 0.05, region.center.z)
		_visual_root.add_child(mi)
		region.mesh_instance = mi

		var lbl := Label3D.new()
		lbl.name = "RegionLabel_%s" % region.id
		lbl.text = "%s\n%s" % [region.id, _state_name(st)]
		lbl.font_size = 48
		lbl.modulate = Color(1, 1, 1, 0.9)
		lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lbl.position = Vector3(region.center.x, 2.5, region.center.z)
		_visual_root.add_child(lbl)
		region.label = lbl


func _update_visual_colors() -> void:
	if not debug_draw:
		return
	for r in regions:
		var region: ClimateRegion = r
		var st: int = get_region_state(region)
		if region.mesh_instance != null and is_instance_valid(region.mesh_instance):
			var mat: StandardMaterial3D = region.mesh_instance.material_override as StandardMaterial3D
			if mat != null:
				mat.albedo_color = _COLOR.get(st, Color(1, 1, 1, 0.5))
			# Position stays fixed — no motion.
			region.mesh_instance.position = Vector3(region.center.x, 0.05, region.center.z)
		if region.label != null and is_instance_valid(region.label):
			region.label.text = "%s\n%s" % [region.id, _state_name(st)]
			region.label.position = Vector3(region.center.x, 2.5, region.center.z)


func _make_ground_disc_mesh(radius: float, segments: int) -> ArrayMesh:
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var indices := PackedInt32Array()
	verts.append(Vector3.ZERO)
	norms.append(Vector3.UP)
	for i in range(segments):
		var a: float = TAU * float(i) / float(segments)
		verts.append(Vector3(cos(a) * radius, 0.0, sin(a) * radius)
		norms.append(Vector3.UP)
	for i in range(segments):
		var i0 := 0
		var i1 := 1 + i
		var i2 := 1 + ((i + 1) % segments)
		indices.append_array([i0, i1, i2])
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = norms
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _print_startup() -> void:
	print("[ZONE] EnvironmentZoneService Slice A ready — fixed regions=", regions.size())
	print("[ZONE] season_progress=", season_progress, " duration_sec=", season_duration_sec)
	for r in regions:
		var region: ClimateRegion = r
		var st: int = get_region_state(region)
		print(
			"[ZONE] ", region.id,
			" center=", region.center,
			" radius=", region.radius,
			" schedule=", _schedule_name(region.schedule_id),
			" state=", _state_name(st),
			" mult=", float(_MULT.get(st, 1.0))
		)
	# Explicit: no motion fields
	print("[ZONE] motion=none velocity=none bounce=none TRANSITION=none priority=none")


func _state_name(t: int) -> String:
	match t:
		ClimateState.FAVORABLE:
			return "FAVORABLE"
		ClimateState.DRY:
			return "DRY"
		ClimateState.COLD:
			return "COLD"
		_:
			return str(t)


func _schedule_name(s: int) -> String:
	match s:
		ScheduleId.A:
			return "A"
		ScheduleId.B:
			return "B"
		ScheduleId.C:
			return "C"
		_:
			return str(s)
