extends StaticBody3D

class_name BaseBuilding

@export var team_id: int = 0
@export var max_health: int = 500
## Half-extents of footprint used for NavMesh obstruction (XZ)
@export var nav_half_extents: Vector3 = Vector3(2.2, 1.0, 2.2)

var health: int = 500
var is_destroyed: bool = false


func _ready() -> void:
	health = max_health
	is_destroyed = false

	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.register_building(self)

	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.register_building(self, nav_half_extents)


func _exit_tree() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.unregister_building(self)

	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.unregister_building(self)


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
