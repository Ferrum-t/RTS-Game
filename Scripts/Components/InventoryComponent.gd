extends Node

class_name InventoryComponent

@export var capacity: int = 10

var resources: Dictionary = {}


func add_resource(resource_name: String, amount: int) -> int:
	var current_load: int = get_total_load()
	var space_left: int = capacity - current_load
	if space_left <= 0:
		return amount

	if amount <= space_left:
		resources[resource_name] = resources.get(resource_name, 0) + amount
		return 0
	else:
		resources[resource_name] = resources.get(resource_name, 0) + space_left
		return amount - space_left


func get_total_load() -> int:
	var total: int = 0
	for value in resources.values():
		total += int(value)
	return total


func is_full() -> bool:
	return get_total_load() >= capacity


func drain_all() -> Dictionary:
	var temp: Dictionary = resources.duplicate()
	resources.clear()
	return temp


func get_resource_names() -> Array:
	return resources.keys()


func get_resource(resource_name: String) -> int:
	return resources.get(resource_name, 0)
