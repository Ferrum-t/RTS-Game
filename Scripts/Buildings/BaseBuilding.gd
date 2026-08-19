extends StaticBody3D

class_name BaseBuilding

@export var team_id: int = 0
@export var max_health: int = 500

var health: int = 500
var is_destroyed: bool = false

var _nav_obstacle: NavigationObstacle3D


func _ready() -> void:
	health = max_health
	is_destroyed = false

	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.register_building(self)

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


func damage(amount: int) -> void:
	if is_destroyed:
		return
	health -= amount
	if health <= 0:
		health = 0
		die()


func die() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	health = 0
	print(name, " destroyed (team ", team_id, ")")
	queue_free()
