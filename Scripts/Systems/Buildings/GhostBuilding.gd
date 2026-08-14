extends Node3D

class_name GhostBuilding

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var area: Area3D = $Area3D

@export var green_material: Material
@export var red_material: Material

var can_build := true


func _ready() -> void:
	if area:
		area.monitoring = true
	update_build_state()


func _process(_delta: float) -> void:
	update_position()
	update_build_state()


func update_position() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	var mouse := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mouse)
	var dir := camera.project_ray_normal(mouse)

	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 500.0)
	query.collide_with_areas = false

	var result := space.intersect_ray(query)
	if result:
		global_position = Vector3(result.position.x, result.position.y, result.position.z)


func update_build_state() -> void:
	if area == null:
		return

	var bodies := area.get_overlapping_bodies()
	can_build = true

	for body in bodies:
		if body.is_in_group("Obstacle") or body.is_in_group("Unit") or body is BaseBuilding:
			can_build = false
			break

	if mesh:
		if can_build and green_material:
			mesh.material_override = green_material
		elif not can_build and red_material:
			mesh.material_override = red_material
