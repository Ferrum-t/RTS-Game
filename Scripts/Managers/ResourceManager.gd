extends Node

## Autoload singleton — player resource stockpile.
## No class_name (avoids conflict with Autoload name).

signal resources_changed

var wood: int = 100
var stone: int = 0
var gold: int = 0
var food: int = 0


func _ready() -> void:
	resources_changed.emit()
	print("ResourceManager ready. Wood: ", wood)


func add_wood(amount: int) -> void:
	if amount <= 0:
		return
	wood += amount
	resources_changed.emit()
	print("Stockpile Wood: ", wood)


func add_stone(amount: int) -> void:
	if amount <= 0:
		return
	stone += amount
	resources_changed.emit()


func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	gold += amount
	resources_changed.emit()


func add_food(amount: int) -> void:
	if amount <= 0:
		return
	food += amount
	resources_changed.emit()


func can_afford(wood_cost: int = 0, stone_cost: int = 0, gold_cost: int = 0, food_cost: int = 0) -> bool:
	return wood >= wood_cost and stone >= stone_cost and gold >= gold_cost and food >= food_cost


func spend(wood_cost: int = 0, stone_cost: int = 0, gold_cost: int = 0, food_cost: int = 0) -> bool:
	if not can_afford(wood_cost, stone_cost, gold_cost, food_cost):
		return false
	wood -= wood_cost
	stone -= stone_cost
	gold -= gold_cost
	food -= food_cost
	resources_changed.emit()
	return true
