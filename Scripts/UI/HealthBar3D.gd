extends Node3D

## RTS-style floating HP bar.
## Full billboard (always faces camera) so it stays readable from high angle.

class_name HealthBar3D

@onready var fill: MeshInstance3D = $Fill
@onready var background: MeshInstance3D = $Background

var max_health: int = 100
var bar_width: float = 2.0


func setup(p_max_health: int) -> void:
	max_health = maxi(p_max_health, 1)
	set_health(max_health)


func set_health(current: int) -> void:
	var ratio := clampf(float(current) / float(max_health), 0.0, 1.0)

	# Hidden at full HP
	visible = ratio < 1.0 and current > 0

	if fill == null:
		return

	# Shrink from the right (left edge fixed)
	fill.scale = Vector3(ratio, 1.0, 1.0)
	fill.position.x = -bar_width * 0.5 * (1.0 - ratio)
	fill.position.z = 0.0
	fill.position.y = 0.0

	_update_fill_color(ratio)


func _update_fill_color(ratio: float) -> void:
	var mat := fill.get_active_material(0)
	if mat is StandardMaterial3D:
		var m := mat as StandardMaterial3D
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
