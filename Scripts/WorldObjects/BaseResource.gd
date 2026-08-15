extends StaticBody3D

class_name BaseResource

@export var resource_name: String = "Wood"
@export var amount: int = 300
@export var interaction_distance: float = 2.5
@export var max_amount: int = 300

var remaining_amount: int


func _ready() -> void:
	collision_layer = 8
	collision_mask = 1
	remaining_amount = max_amount
	add_to_group("Resource")
	add_to_group("Obstacle")
	
	# Откладываем регистрацию препятствия на сетке, чтобы дать время
	# установить точные координаты/трансформы при динамическом спавне.
	call_deferred("_register_obstacle")


func _register_obstacle() -> void:
	if not is_inside_tree():
		return
	var grid = get_tree().get_root().find_child("GridMap", true, false)
	if grid != null:
		grid.occupy_obstacle(self, true)


func _exit_tree() -> void:
	var grid = get_tree().get_root().find_child("GridMap", true, false)
	if grid != null:
		grid.occupy_obstacle(self, false)


func harvest(amount: int) -> int:
	var actual_harvest: int = min(amount, remaining_amount)
	remaining_amount -= actual_harvest

	if remaining_amount <= 0:
		queue_free()

	return actual_harvest


func is_depleted() -> bool:
	return remaining_amount <= 0


func get_resource_type() -> String:
	return resource_name
