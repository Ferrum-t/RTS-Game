extends Node3D

## Simple 3D HP bar that floats above a unit.
## - Always faces the camera (billboard)
## - Green fill scales with health percent
## - Hides when unit is at full HP (less clutter)

class_name HealthBar3D

@onready var fill: MeshInstance3D = $Fill

var max_health: int = 100
var _full_width: float = 1.0


func _ready() -> void:
	if fill and fill.mesh is BoxMesh:
		_full_width = (fill.mesh as BoxMesh).size.x


func setup(p_max_health: int) -> void:
	max_health = maxi(p_max_health, 1)
	set_health(max_health)


func set_health(current: int) -> void:
	var ratio := clampf(float(current) / float(max_health), 0.0, 1.0)

	# Hide when full — less visual noise in large armies
	visible = ratio < 1.0 and ratio > 0.0

	if fill == null:
		return

	# Scale only X so the bar shrinks from full width to empty
	fill.scale = Vector3(ratio, 1.0, 1.0)
	# Keep left edge anchored (bar empties to the right)
	fill.position.x = -_full_width * 0.5 * (1.0 - ratio)


func _process(_delta: float) -> void:
	# Billboard: rotate bar to face the active camera
	var cam := get_viewport().get_camera_3d()
	if cam:
		look_at(cam.global_position, Vector3.UP)
		# look_at points -Z at target; flatten so bar stays upright
		rotation.x = 0.0
		rotation.z = 0.0
