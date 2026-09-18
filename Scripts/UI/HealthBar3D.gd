extends Node3D

## RTS-style floating HP / construction bar.
## Full billboard (always faces camera) so it stays readable from high angle.

class_name HealthBar3D

@onready var fill: MeshInstance3D = $Fill
@onready var background: MeshInstance3D = $Background

var max_health: int = 100
var bar_width: float = 2.0
## When true, bar stays visible at any ratio (construction site).
var _construction_mode: bool = false


func setup(p_max_health: int) -> void:
	_construction_mode = false
	max_health = maxi(p_max_health, 1)
	_sync_mesh_width()
	set_health(max_health)


func _sync_mesh_width() -> void:
	var w: float = maxf(bar_width, 0.5)
	if background != null and background.mesh is QuadMesh:
		(background.mesh as QuadMesh).size = Vector2(w, 0.28)
	if fill != null and fill.mesh is QuadMesh:
		(fill.mesh as QuadMesh).size = Vector2(w, 0.22)


func set_health(current: int) -> void:
	if _construction_mode:
		return
	var ratio := clampf(float(current) / float(max_health), 0.0, 1.0)

	# Hidden at full HP
	visible = ratio < 1.0 and current > 0

	_apply_fill_ratio(ratio)
	_update_fill_color(ratio)


## M10.2 — show construction progress 0..1, always visible until complete.
func set_build_progress(frac: float) -> void:
	_construction_mode = true
	var ratio := clampf(frac, 0.0, 1.0)
	visible = true
	_apply_fill_ratio(ratio)

	var mat := _fill_material()
	if mat != null:
		if ratio < 0.5:
			mat.albedo_color = Color(0.25, 0.75, 1.0, 1)
		elif ratio < 1.0:
			mat.albedo_color = Color(1.0, 0.9, 0.2, 1)
		else:
			mat.albedo_color = Color(0.2, 1.0, 0.35, 1)


func clear_construction_mode() -> void:
	_construction_mode = false


## Left-edge fixed: scale X by ratio, shift so left stays aligned with background.
func _apply_fill_ratio(ratio: float) -> void:
	if fill == null:
		return
	var w: float = maxf(bar_width, 0.5)
	fill.scale = Vector3(maxf(ratio, 0.001), 1.0, 1.0)
	# QuadMesh is centered at origin; after scale, left edge at -ratio*w/2.
	# Want left edge at -w/2 → offset by -w/2 * (1 - ratio).
	fill.position = Vector3(-w * 0.5 * (1.0 - ratio), 0.0, 0.0)


func _fill_material() -> StandardMaterial3D:
	if fill == null:
		return null
	var mat = fill.get_active_material(0)
	if mat is StandardMaterial3D:
		return mat as StandardMaterial3D
	return null


func _update_fill_color(ratio: float) -> void:
	var m := _fill_material()
	if m == null:
		return
	if ratio > 0.5:
		m.albedo_color = Color(0.2, 1.0, 0.25, 1)
	elif ratio > 0.25:
		m.albedo_color = Color(1.0, 0.9, 0.1, 1)
	else:
		m.albedo_color = Color(1.0, 0.2, 0.15, 1)


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return

	# True billboard: copy camera rotation so the quad is always face-on
	global_transform.basis = cam.global_transform.basis
