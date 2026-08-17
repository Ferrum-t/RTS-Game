extends RefCounted

class_name InventoryComponent

var owner: BaseUnit

var wood := 0
var stone := 0
var gold := 0
var food := 0

var capacity := 50


func _init(unit: BaseUnit) -> void:
	owner = unit


func is_full() -> bool:
	return get_total() >= capacity


func clear() -> void:
	wood = 0
	stone = 0
	gold = 0
	food = 0


func add_wood(amount: int) -> void:
	wood = clampi(wood + amount, 0, capacity)


func add_stone(amount: int) -> void:
	stone = clampi(stone + amount, 0, capacity)


func has_resources() -> bool:
	return wood > 0 or stone > 0 or gold > 0 or food > 0


func get_total() -> int:
	return wood + stone + gold + food
