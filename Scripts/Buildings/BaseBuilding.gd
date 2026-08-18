extends StaticBody3D

class_name BaseBuilding

@export var team_id: int = 0

var _nav_obstacle: NavigationObstacle3D


func _ready() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.register_building(self)

	# RVO obstacle — agents feel a solid body around the building
	_nav_obstacle = NavigationObstacle3D.new()
	add_child(_nav_obstacle)
	_nav_obstacle.radius = 2.8
	_nav_obstacle.height = 3.0
	_nav_obstacle.avoidance_enabled = true
	_nav_obstacle.avoidance_layers = 1


func _exit_tree() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.unregister_building(self)
