extends StaticBody3D

class_name BaseBuilding

var _nav_obstacle: NavigationObstacle3D


func _ready() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.register_building(self)

	# Runtime obstacle for NavigationAgent avoidance (no full navmesh rebake needed)
	_nav_obstacle = NavigationObstacle3D.new()
	add_child(_nav_obstacle)
	_nav_obstacle.radius = 2.0
	_nav_obstacle.height = 3.0
	_nav_obstacle.avoidance_enabled = true
	_nav_obstacle.avoidance_layers = 1

	print(name, " registered: ", name)


func _exit_tree() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.unregister_building(self)
