extends Node3D

## Floating HP bar above units.
## Shrinks from the RIGHT toward the LEFT (right edge moves inward).

class_name HealthBar3D

@onready var fill: MeshInstance3D = $Fill
@onready var background: MeshInstance3D = $Background

var max_health: int = 100
var _full_width: float = 1.4


func _ready() -> void:
	if fill and fill.mesh is BoxMesh:
		_full_width = (fill.mesh as BoxMesh).size.x


func setup(p_max_health: int) -> void:
	max_health = maxi(p_max_health, 1)
	set_health(max_health)


func set_health(current: int) -> void:
	var ratio := clampf(float(current) / float(max_health), 0.0, 1.0)

	# Show only when damaged
	visible = ratio < 1.0 and ratio > 0.0

	if fill == null:
		return

	# Scale width by remaining HP
	fill.scale = Vector3(ratio, 1.0, 1.0)

	# Anchor to the LEFT: bar empties on the RIGHT (right -> left)
	# Center of scaled fill shifts left as ratio drops
	fill.position.x = -_full_width * 0.5 * (1.0 - ratio)
	# Slight Z offset so green doesn't z-fight with gray background
	fill.position.z = 0.03

	_update_fill_color(ratio)


func _update_fill_color(ratio: float) -> void:
	if fill == null:
		return
	var mat := fill.get_active_material(0)
	if mat is StandardMaterial3D:
		var m := mat as StandardMaterial3D
		# Green -> yellow -> red as HP drops
		if ratio > 0.5:
			m.albedo_color = Color(0.25, 0.95, 0.3, 1)
		elif ratio > 0.25:
			m.albedo_color = Color(0.95, 0.85, 0.15, 1)
		else:
			m.albedo_color = Color(0.95, 0.2, 0.15, 1)


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	# Face camera on Y only (keep bar horizontal)
	var cam_pos := cam.global_position
	var my_pos := global_position
	var dir := cam_pos - my_pos
	dir.y = 0.0
	if dir.length_squared() > 0.001:
		look_at(my_pos + dir, Vector3.UP)
