extends Node3D

const FIBER_RESOURCE_SCENE: PackedScene = preload("res://Scenes/Resorces/Fiber.tscn")
const CRYSTAL_RESOURCE_SCENE: PackedScene = preload("res://Scenes/Resorces/Crystal.tscn")
const ORE_RESOURCE_SCENE: PackedScene = preload("res://Scenes/Resorces/Ore.tscn")

@export var construction_manager: NodePath
@export var interaction_manager: NodePath

var construction_service
var interaction_service: InteractionManager
var resources_node: Node


func _ready() -> void:
	set_process_input(true)
	set_process_unhandled_input(true)

	# Автоматически запекаем навигационную сетку на старте игры.
	# Это гарантирует, что NavigationMesh всегда будет содержать актуальные полигоны в рантайме,
	# даже если сцена не была предварительно запечена в редакторе.
	var nav_region := get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	if nav_region != null:
		print("[NAV_DEBUG] Baking...")
		nav_region.bake_navigation_mesh(false) # Синхронное запекание на главном потоке

		var nav_mesh := nav_region.navigation_mesh
		if nav_mesh != null:
			print("[NAV_DEBUG] Vertices immediately: ", nav_mesh.vertices.size())
			print("[NAV_DEBUG] Polygons immediately: ", nav_mesh.get_polygon_count())
			print("[NAV_DEBUG] Map RID: ", nav_region.get_navigation_map())
			_async_check_bake(nav_mesh)

	if construction_manager != NodePath() and not construction_manager.is_empty():
		construction_service = get_node(construction_manager) as ConstructionManager
	elif has_node("/root/ConstructionManager"):
		construction_service = get_node("/root/ConstructionManager") as ConstructionManager
	if interaction_manager != NodePath() and not interaction_manager.is_empty():
		interaction_service = get_node(interaction_manager) as InteractionManager

	resources_node = get_node_or_null("Recources")
	if resources_node != null:
		spawn_resources()


func _process(_delta: float) -> void:
	pass


func _async_check_bake(nav_mesh: NavigationMesh) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	if nav_mesh != null:
		print("[NAV_DEBUG_AFTER_BAKE] Vertices: ", nav_mesh.vertices.size())
		print("[NAV_DEBUG_AFTER_BAKE] Polygons: ", nav_mesh.get_polygon_count())


func spawn_resources() -> void:
	var resource_spawns := [
		{
			"scene": FIBER_RESOURCE_SCENE,
			"positions": [Vector3(6, 0, -10), Vector3(10, 0, -8)]
		},
		{
			"scene": CRYSTAL_RESOURCE_SCENE,
			"positions": [Vector3(-6, 0, -8), Vector3(-10, 0, -6)]
		},
		{
			"scene": ORE_RESOURCE_SCENE,
			"positions": [Vector3(2, 0, -14), Vector3(-2, 0, -16)]
		}
	]

	for spawn in resource_spawns:
		var scene: PackedScene = spawn["scene"]
		for spawn_position in spawn["positions"]:
			var instance: Node = scene.instantiate()
			if instance is Node3D:
				resources_node.add_child(instance)
				(instance as Node3D).global_position = spawn_position
			else:
				resources_node.add_child(instance)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var manager = construction_service
		if manager == null and has_node("/root/ConstructionManager"):
			manager = get_node("/root/ConstructionManager") as ConstructionManager
		if manager != null and manager.is_building_mode:
			print("World: confirm build click")
			manager.confirm_build()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var manager = construction_service
		if manager == null and has_node("/root/ConstructionManager"):
			manager = get_node("/root/ConstructionManager") as ConstructionManager
		if manager != null and manager.is_building_mode:
			print("World: confirm build click")
			manager.confirm_build()
