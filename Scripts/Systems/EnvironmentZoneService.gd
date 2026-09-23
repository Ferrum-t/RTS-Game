extends Node

## Environment Zones — Stage 1.5 Seasonal Front v0 (layout: Variant B 8×r21).
## Geometry does not move. Season changes state via global temperature field.
## T(z,s) = T0 + A * sin(2π s) - G * z   (+Z = north, colder)
## Public API for harvest: get_multiplier_at(world_pos) — signature preserved.
## No velocity / drift / bounce / TRANSITION / overlap priority / per-region schedules.
## Climate v0.1: C2 horse gate + C3 R0 home signal (see Docs/CLIMATE_V0_1_SCOPE_LOCK.md).
## ME-0: enriched R0 climate feedback (mult + pressure hint; info only).

enum ClimateState {
	COLD,
	FAVORABLE,
	DRY,
}

## Seasonal Front v0 — approved numerical set (pre-code review).
const T0: float = 0.0
const A: float = 1.0
const G: float = 0.014
const T_COLD: float = -0.55
const T_HOT: float = 0.55

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

## Full season cycle length (seconds). Climate Visual v0.1: 360s.
@export var season_duration_sec: float = 360.0

## Debug ground discs (static). Color follows current state.
@export var debug_draw: bool = true

## season_progress ∈ [0, 1). s0 = 0.0 at match start (approved).
var season_progress: float = 0.0

var regions: Array = []
var _visual_root: Node3D = null
## Fingerprint of region states for change logging (F5).
var _last_state_fingerprint: String = ""
## Climate v0.1 C3 — previous state per region id (for home-region signal).
var _prev_states: Dictionary = {}


class ClimateRegion:
	extends RefCounted
	var id: String = ""
	var center: Vector3 = Vector3.ZERO
	var radius: float = 21.0
	var mesh_instance: MeshInstance3D = null
	var label: Label3D = null


func _ready() -> void:
	_spawn_regions()
	_assert_non_overlap()
	if debug_draw:
		_ensure_visual_root()
		_build_visuals()
	_print_startup()
	_last_state_fingerprint = _state_fingerprint()
	_snapshot_states()
	# Herds may spawn after this node — apply gate once scene is ready.
	call_deferred("_update_horse_climate_gates")


func _process(delta: float) -> void:
	if season_duration_sec <= 0.001:
		return
	season_progress = fposmod(season_progress + delta / season_duration_sec, 1.0)
	var fp: String = _state_fingerprint()
	if fp != _last_state_fingerprint:
		_last_state_fingerprint = fp
		_on_climate_states_changed()
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
	return _state_from_temperature(_temperature_at_z(region.center.z, season_progress))


## T(z, s) = T0 + A * sin(2π s) - G * z
func _temperature_at_z(z: float, s: float) -> float:
	return T0 + A * sin(TAU * s) - G * z


func _state_from_temperature(t: float) -> int:
	if t < T_COLD:
		return ClimateState.COLD
	if t > T_HOT:
		return ClimateState.DRY
	return ClimateState.FAVORABLE


func _spawn_regions() -> void:
	regions.clear()
	# Expanded Climate Geometry v0.1 — Variant B (8 × r21). Geometry fixed; state from seasonal front.
	var specs: Array = [
		{"id": "R0", "center": Vector3(32.0, 0.0, -30.0), "radius": 21.0},
		{"id": "R1", "center": Vector3(-30.0, 0.0, 30.0), "radius": 21.0},
		{"id": "R2", "center": Vector3(77.0, 0.0, 0.0), "radius": 21.0},
		{"id": "R3", "center": Vector3(60.0, 0.0, 72.0), "radius": 21.0},
		{"id": "R4", "center": Vector3(-7.0, 0.0, 77.0), "radius": 21.0},
		{"id": "R5", "center": Vector3(-72.0, 0.0, 60.0), "radius": 21.0},
		{"id": "R6", "center": Vector3(-77.0, 0.0, -7.0), "radius": 21.0},
		{"id": "R7", "center": Vector3(0.0, 0.0, -77.0), "radius": 21.0},
	]
	for s in specs:
		var region := ClimateRegion.new()
		region.id = str(s["id"])
		region.center = s["center"]
		region.radius = float(s["radius"])
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


func _state_fingerprint() -> String:
	var parts: PackedStringArray = PackedStringArray()
	for r in regions:
		var region: ClimateRegion = r
		parts.append("%s:%s" % [region.id, _state_name(get_region_state(region))])
	return "|".join(parts)


func _on_climate_states_changed() -> void:
	print("[ZONE] climate state change progress=", snappedf(season_progress, 0.001))
	for r in regions:
		var region: ClimateRegion = r
		var st: int = get_region_state(region)
		var temp: float = _temperature_at_z(region.center.z, season_progress)
		print(
			"[ZONE] ", region.id,
			" state=", _state_name(st),
			" T=", snappedf(temp, 0.01),
			" mult=", float(_MULT.get(st, 1.0)),
			" center=", region.center,
			" radius=", region.radius
		)
	# Climate v0.1 C3 — player home region R0 signal only.
	_emit_home_region_signal("R0")
	_snapshot_states()
	# Climate v0.1 C2 — reversible horse availability.
	_update_horse_climate_gates()


func _snapshot_states() -> void:
	_prev_states.clear()
	for r in regions:
		var region: ClimateRegion = r
		_prev_states[region.id] = get_region_state(region)


func _region_by_id(region_id: String) -> ClimateRegion:
	for r in regions:
		var region: ClimateRegion = r
		if region.id == region_id:
			return region
	return null


func _emit_home_region_signal(region_id: String) -> void:
	var region: ClimateRegion = _region_by_id(region_id)
	if region == null:
		return
	var st: int = get_region_state(region)
	var prev: int = int(_prev_states.get(region_id, st))
	if prev == st:
		return
	var mult: float = float(_MULT.get(st, 1.0))
	# ME-0: legible pressure hint (info only — no mechanical change).
	var pressure: String
	if st == ClimateState.COLD or st == ClimateState.DRY:
		pressure = "home pressure ↑ — harvest weaker, horses offline in region"
	else:
		pressure = "home pressure ↓ — harvest strong, horses available in region"
	print(
		"[CLIMATE] ", region_id, " ",
		_state_name(prev), " → ", _state_name(st),
		"  mult=", mult, "  (", pressure, ")"
	)


## Climate v0.1 C2 — suspend herds in COLD/DRY; resume in FAVORABLE.
## Neutral land (outside regions) stays available. Never queue_free.
func _update_horse_climate_gates() -> void:
	var tree := get_tree()
	if tree == null:
		return
	for n in tree.get_nodes_in_group("Resource"):
		if not (n is HorseResource):
			continue
		var herd := n as HorseResource
		if herd == null or not is_instance_valid(herd):
			continue
		var region: ClimateRegion = get_region_at(herd.global_position)
		var favorable: bool = true
		if region != null:
			favorable = get_region_state(region) == ClimateState.FAVORABLE
		herd.set_climate_suspended(not favorable)


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
		var is_home := region.id == "R0"

		var mi := MeshInstance3D.new()
		mi.name = "RegionDisc_%s" % region.id
		mi.mesh = _make_ground_disc_mesh(region.radius, 48)
		var mat := StandardMaterial3D.new()
		var base_color: Color = _COLOR.get(st, Color(1, 1, 1, 0.5))
		if is_home:
			base_color.a = 0.85
		mat.albedo_color = base_color
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
		lbl.text = "%s\n%s\nx%.1f" % [region.id, _state_name(st), float(_MULT.get(st, 1.0))]
		lbl.font_size = 64 if is_home else 48
		lbl.modulate = Color(1, 1, 1, 1.0 if is_home else 0.9)
		lbl.outline_size = 12 if is_home else 4
		lbl.outline_modulate = Color(0, 0, 0, 0.9)
		lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lbl.position = Vector3(region.center.x, 3.0 if is_home else 2.5, region.center.z)
		_visual_root.add_child(lbl)
		region.label = lbl


func _update_visual_colors() -> void:
	if not debug_draw:
		return
	for r in regions:
		var region: ClimateRegion = r
		var st: int = get_region_state(region)
		var is_home := region.id == "R0"
		if region.mesh_instance != null and is_instance_valid(region.mesh_instance):
			var mat: StandardMaterial3D = region.mesh_instance.material_override as StandardMaterial3D
			if mat != null:
				var base_color: Color = _COLOR.get(st, Color(1, 1, 1, 0.5))
				base_color.a = 0.85 if is_home else base_color.a
				mat.albedo_color = base_color
			# Position stays fixed — no motion.
			region.mesh_instance.position = Vector3(region.center.x, 0.05, region.center.z)
		if region.label != null and is_instance_valid(region.label):
			region.label.text = "%s\n%s\nx%.1f" % [region.id, _state_name(st), float(_MULT.get(st, 1.0))]
			region.label.font_size = 64 if is_home else 48
			region.label.modulate = Color(1, 1, 1, 1.0 if is_home else 0.9)
			region.label.outline_size = 12 if is_home else 4
			region.label.position = Vector3(region.center.x, 3.0 if is_home else 2.5, region.center.z)


func _make_ground_disc_mesh(radius: float, segments: int) -> ArrayMesh:
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var indices := PackedInt32Array()
	verts.append(Vector3.ZERO)
	norms.append(Vector3.UP)
	for i in range(segments):
		var a: float = TAU * float(i) / float(segments)
		verts.append(Vector3(cos(a) * radius, 0.0, sin(a) * radius))
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
	print("[ZONE] EnvironmentZoneService Seasonal Front v0 — fixed regions=", regions.size())
	print("[ZONE] field T=T0+A*sin(2pi*s)-G*z  T0=", T0, " A=", A, " G=", G, " T_cold=", T_COLD, " T_hot=", T_HOT)
	print("[ZONE] season_progress=", season_progress, " duration_sec=", season_duration_sec)
	for r in regions:
		var region: ClimateRegion = r
		var st: int = get_region_state(region)
		var t: float = _temperature_at_z(region.center.z, season_progress)
		print(
			"[ZONE] ", region.id,
			" center=", region.center,
			" radius=", region.radius,
			" T=", snappedf(t, 0.01),
			" state=", _state_name(st),
			" mult=", float(_MULT.get(st, 1.0))
		)
	print("[ZONE] motion=none velocity=none bounce=none TRANSITION=none priority=none schedule=none")


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
