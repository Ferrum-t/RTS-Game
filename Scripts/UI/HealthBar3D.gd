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
var _meshes_synced: bool = false


func setup(p_max_health: int) -> void:
	_construction_mode = false
	max_health = maxi(p_max_health, 1)
	_ensure_meshes()
	set_health(max_health)


func _ensure_meshes() -> void:
	if fill == null:
		fill = get_node_or_null("Fill") as MeshInstance3D
	if background == null:
		background = get_node_or_null("Background") as MeshInstance3D
	_sync_mesh_width()


func _sync_mesh_width() -> void:
	var w: float = maxf(bar_width, 0.5)
	# Unique mesh copies so instances do not share SubResource sizes.
	if background != null:
		var bg_q := QuadMesh.new()
		bg_q.size = Vector2(w, 0.32)
		background.mesh = bg_q
		background.scale = Vector3.ONE
		background.position = Vector3.ZERO
		var bg_mat := StandardMaterial3D.new()
		bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bg_mat.albedo_color = Color(0.05, 0.05, 0.05, 1)
		bg_mat.no_depth_test = true
		bg_mat.render_priority = 5
		background.material_override = bg_mat
	if fill != null:
		var fill_q := QuadMesh.new()
		fill_q.size = Vector2(w, 0.24)
		fill.mesh = fill_q
		fill.scale = Vector3.ONE
		fill.position = Vector3.ZERO
		var fill_mat := StandardMaterial3D.new()
		fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fill_mat.albedo_color = Color(0.2, 1.0, 0.25, 1)
		fill_mat.no_depth_test = true
		fill_mat.render_priority = 6
		fill.material_override = fill_mat
	_meshes_synced = true


func set_health(current: int) -> void:
	if _construction_mode:
		return
	_ensure_meshes()
	var ratio := clampf(float(current) / float(max_health), 0.0, 1.0)

	# Hidden at full HP
	visible = ratio < 1.0 and current > 0

	_apply_fill_ratio(ratio)
	_update_fill_color(ratio)


## M10.2 — show construction progress 0..1, always visible until complete.
func set_build_progress(frac: float) -> void:
	_construction_mode = true
	_ensure_meshes()
	var ratio := clampf(frac, 0.0, 1.0)
	visible = true
	# Background stays full width; only fill grows.
	if background != null:
		background.scale = Vector3.ONE
		background.position = Vector3.ZERO
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
	var r: float = clampf(ratio, 0.0, 1.0)
	if r < 0.001:
		fill.visible = false
		return
	fill.visible = true
	fill.scale = Vector3(r, 1.0, 1.0)
	# Quad centered at origin; after scale left at -r*w/2; want left at -w/2.
	fill.position = Vector3(-w * 0.5 * (1.0 - r), 0.0, 0.02)


func _fill_material() -> StandardMaterial3D:
	if fill == null:
		return null
	var mat = fill.material_override
	if mat is StandardMaterial3D:
		return mat as StandardMaterial3D
	mat = fill.get_active_material(0)
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
