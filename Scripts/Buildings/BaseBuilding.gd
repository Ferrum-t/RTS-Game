extends StaticBody3D

class_name BaseBuilding


func _ready():
	collision_layer = 4
	add_to_group("Obstacle")
	BuildingManager.register_building(self)
	
	# Откладываем регистрацию препятствия на сетке, чтобы дать время
	# установить точные координаты/трансформы при динамическом спавне.
	call_deferred("_register_obstacle")


func _register_obstacle():
	if not is_inside_tree():
		return
	var grid = get_tree().get_root().find_child("GridMap", true, false)
	if grid != null:
		grid.occupy_obstacle(self, true)


func _exit_tree():
	BuildingManager.unregister_building(self)
	
	var grid = get_tree().get_root().find_child("GridMap", true, false)
	if grid != null:
		grid.occupy_obstacle(self, false)
