extends Node3D

class_name GhostBuilding

@onready var mesh := $MeshInstance3D
@onready var area := $Area3D

@export var green_material: Material
@export var red_material: Material

var can_build := true


func _ready():
	area.monitoring = true
	update_build_state()


func _process(_delta):

	update_position()
	update_build_state()


func update_position():

	var camera = get_viewport().get_camera_3d()

	if camera == null:
		return

	var mouse = get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse)
	var dir = camera.project_ray_normal(mouse)

	var space = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(
		from,
		from + dir * 500
	)

	var result = space.intersect_ray(query)

	if result:
		global_position = result.position

func update_build_state():

	var bodies = area.get_overlapping_bodies()

	can_build = true

	for body in bodies:

		if body.is_in_group("Obstacle"):

			can_build = false
			break

	if can_build:
		mesh.material_override = green_material
	else:
		mesh.material_override = red_material
