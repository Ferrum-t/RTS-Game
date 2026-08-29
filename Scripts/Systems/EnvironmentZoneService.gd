extends Node

## Environment Zones v1.0 — Stage A: drifting zone blobs + ground visual.
## Stage B (harvest multiplier) is NOT wired here — wait for F5 acceptance of A.
## Lore limit: zones affect resource gather rate only (02_GEOGRAPHY §12/§38).

enum ZoneType {
	FAVORABLE,
	TRANSITION,
	DRY,
	COLD,
}

## Priority when blobs overlap (higher wins). TRANSITION is background only.
const _PRIORITY := {
	ZoneType.COLD: 3,
	ZoneType.DRY: 2,
	ZoneType.FAVORABLE: 1,
	ZoneType.TRANSITION: 0,
}

const _MULT := {
	ZoneType.FAVORABLE: 1.5,
	ZoneType.TRANSITION: 1.0,
	ZoneType.DRY: 0.5,
	ZoneType.COLD: 0.5,
}

const _COLOR := {
	ZoneType.FAVORABLE: Color(0.2, 0.85, 0.3, 0.28),
	ZoneType.DRY: Color(0.95, 0.4, 0.15, 0.28),
	ZoneType.COLD: Color(0.35, 0.65, 1.0, 0.28),
}

## Playable AABB on XZ (from MatchManager spawn layout ≈ ±20; pad for drift).
@export var map_min_x: float = -28.0
@export var map_max_x: float = 28.0
@export var map_min_z: float = -28.0
@export var map_max_z: float = 28.0

## Tick interval for movement (not every physics frame).
@export var tick_interval: float = 0.2

## Default blob radii / speeds (units/sec). Crossing ~40–50 units ≈ 40–50s at 1.0.
@export var default_radius: float = 10.0
@export var default_speed: float = 1.0

var blobs: Array = []
var _tick_accum: float = 0.0
var _visual_root: Node3D = null


class ZoneBlob:
	extends RefCounted
	var type: int = ZoneType.FAVORABLE
	var position: Vector3 = Vector3.ZERO
	var radius: float = 10.0
	var velocity: Vector3 = Vector3.ZERO
	var mesh_instance: MeshInstance3D = null


func _ready() -> void:
	_spawn_default_blobs()
	_ensure_visual_root()
	_build_visuals()
	_print_startup()


func _process(delta: float) -> void:
	_tick_accum += delta
	if _tick_accum < tick_interval:
		return
	var step: float = _tick_accum
	_tick_accum = 0.0
	_move_blobs(step)


## Public API for Stage B (harvest). Safe to call now; always returns 1.0 outside blobs.
func get_multiplier_at(world_pos: Vector3) -> float:
	var p := Vector3(world_pos.x, 0.0, world_pos.z)
	var best_type: int = ZoneType.TRANSITION
	var best_pri: int = -1
	for b in blobs:
		var blob: ZoneBlob = b
		if blob.type == ZoneType.TRANSITION:
			continue
		var d: float = Vector2(p.x - blob.position.x, p.z - blob.position.z).length()
		if d > blob.radius:
			continue
		var pri: int = int(_PRIORITY.get(blob.type, 0))
		if pri > best_pri:
			best_pri = pri
			best_type = blob.type
	if best_pri < 0:
		return 1.0
	return float(_MULT.get(best_type, 1.0))


func _spawn_default_blobs() -> void:
	blobs.clear()
	# 2× FAVORABLE, 1× DRY, 1× COLD — positions near play area so motion is visible in F5.
	var specs: Array = [
		{ "type": ZoneType.FAVORABLE, "pos": Vector3(8.0, 0.0, 4.0), "vel": Vector3(-0.7, 0.0, 0.6) },
		{ "type": ZoneType.FAVORABLE, "pos": Vector3(-10.0, 0.0, -6.0), "vel": Vector3(0.8, 0.0, 0.5) },
		{ "type": ZoneType.DRY, "pos": Vector3(0.0, 0.0, 14.0), "vel": Vector3(0.5, 0.0, -0.9) },
		{ "type": ZoneType.COLD, "pos": Vector3(-14.0, 0.0, 8.0), "vel": Vector3(0.9, 0.0, -0.4) },
	]
	for s in specs:
		var blob := ZoneBlob.new()
		blob.type = int(s["type"])
		blob.position = s["pos"]
		blob.radius = default_radius
		var v: Vector3 = s["vel"]
		v.y = 0.0
		if v.length() > 0.001:
			v = v.normalized() * default_speed
		blob.velocity = v
		blobs.append(blob)


func _move_blobs(delta: float) -> void:
	for b in blobs:
		var blob: ZoneBlob = b
		blob.position += blob.velocity * delta
		blob.position.y = 0.0
		_bounce_blob(blob)
		if blob.mesh_instance != null and is_instance_valid(blob.mesh_instance):
			blob.mesh_instance.global_position = Vector3(blob.position.x, 0.05, blob.position.z)


func _bounce_blob(blob: ZoneBlob) -> void:
	var bounced := false
	var r: float = blob.radius * 0.25  # soft pad so disc edge stays roughly on map
	if blob.position.x - r < map_min_x:
		blob.position.x = map_min_x + r
		blob.velocity.x = absf(blob.velocity.x)
		bounced = true
	elif blob.position.x + r > map_max_x:
		blob.position.x = map_max_x - r
		blob.velocity.x = -absf(blob.velocity.x)
		bounced = true
	if blob.position.z - r < map_min_z:
		blob.position.z = map_min_z + r
		blob.velocity.z = absf(blob.velocity.z)
		bounced = true
	elif blob.position.z + r > map_max_z:
		blob.position.z = map_max_z - r
		blob.velocity.z = -absf(blob.velocity.z)
		bounced = true
	if bounced:
		print("[ZONE] blob type=", _type_name(blob.type), " bounced at edge pos=", blob.position)


func _ensure_visual_root() -> void:
	if _visual_root != null and is_instance_valid(_visual_root):
		return
	var scene := get_tree().current_scene
	if scene == null:
		# Autoload may run before main scene; defer.
		call_deferred("_ensure_visual_root")
		call_deferred("_build_visuals")
		return
	_visual_root = Node3D.new()
	_visual_root.name = "EnvironmentZoneVisuals"
	scene.add_child(_visual_root)


func _build_visuals() -> void:
	if _visual_root == null or not is_instance_valid(_visual_root):
		return
	for child in _visual_root.get_children():
		child.queue_free()
	for b in blobs:
		var blob: ZoneBlob = b
		if blob.type == ZoneType.TRANSITION:
			continue
		var mi := MeshInstance3D.new()
		mi.name = "ZoneDisc_%s" % _type_name(blob.type)
		mi.mesh = _make_ground_disc_mesh(blob.radius, 48)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = _COLOR.get(blob.type, Color(1, 1, 1, 0.25))
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.no_depth_test = false
		mi.material_override = mat
		mi.position = Vector3(blob.position.x, 0.05, blob.position.z)
		_visual_root.add_child(mi)
		blob.mesh_instance = mi


## Flat filled disc on XZ (Y up) — same spirit as MobileBuilding._make_ground_ring_mesh.
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
	print("[ZONE] EnvironmentZoneService ready — blobs=", blobs.size())
	for b in blobs:
		var blob: ZoneBlob = b
		print(
			"[ZONE] blob type=", _type_name(blob.type),
			" pos=", blob.position,
			" radius=", blob.radius,
			" vel=", blob.velocity
		)


func _type_name(t: int) -> String:
	match t:
		ZoneType.FAVORABLE:
			return "FAVORABLE"
		ZoneType.TRANSITION:
			return "TRANSITION"
		ZoneType.DRY:
			return "DRY"
		ZoneType.COLD:
			return "COLD"
		_:
			return str(t)
