extends Node

var current_ghost: GhostBuilding = null
var current_building_data: BuildingData = null

func start_building(data: BuildingData) -> void:

	if current_ghost != null:
		current_ghost.queue_free()

	current_building_data = data

	current_ghost = data.ghost_scene.instantiate()

	get_tree().current_scene.add_child(current_ghost)

	print("Started building mode.")
	
func confirm_build() -> void:

	if current_ghost == null:
		return

	if !current_ghost.can_build:
		print("Can't build here.")
		return

	# Сохраняем позицию ДО удаления
	var position = current_ghost.global_position

	# Создаем настоящее здание
	var building = current_building_data.building_scene.instantiate()
	get_tree().current_scene.add_child(building)

	# Теперь можно установить позицию
	building.global_position = position

	# И только теперь удалить призрак
	current_ghost.queue_free()
	current_ghost = null

	print("Building placed.")
