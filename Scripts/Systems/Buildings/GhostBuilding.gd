extends StaticBody3D

class_name GhostBuilding

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var area: Area3D = $Area3D

@export var green_material: Material
@export var red_material: Material

var can_build := true


func _ready() -> void:
	if area != null:
		area.monitoring = true
		area.collision_mask = 12 # Detect Layer 3 (Buildings, val 4) and Layer 4 (Resources, val 8)
	update_build_state()


func _process(_delta: float) -> void:
	update_position()
	update_build_state()


func update_position() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	var mouse: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse)
	var direction: Vector3 = camera.project_ray_normal(mouse)
	var space := get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.create(
		from,
		from + direction * 500.0
	)
	query.exclude = [get_rid()]
	var result := space.intersect_ray(query)
	if result:
		global_position = result.position


func update_build_state() -> void:
	can_build = true
	if area == null:
		return

	var bodies := area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Obstacle"):
			can_build = false
			break

	if mesh != null:
		mesh.material_override = green_material if can_build else red_material
