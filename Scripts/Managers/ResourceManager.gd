extends Node
## Autoload singleton — player resource stockpile.
## Cost API is Dictionary-based: keys = BaseResource.Type (int), values = amount.
## Stock fields (wood/stone/...) kept for HUD and deposit convenience.

signal resources_changed

var wood: int = 100
var stone: int = 0
var gold: int = 0
var food: int = 0
var horses: int = 0

func _ready() -> void:
	resources_changed.emit()
	print("ResourceManager ready. Wood: ", wood, " Horses: ", horses)

## Build a cost dictionary from individual amounts (call sites / BuildingData).
static func make_cost(
	wood_amt: int = 0,
	stone_amt: int = 0,
	gold_amt: int = 0,
	food_amt: int = 0,
	horses_amt: int = 0
) -> Dictionary:
	var cost: Dictionary = {}
	if wood_amt > 0:
		cost[BaseResource.Type.WOOD] = wood_amt
	if stone_amt > 0:
		cost[BaseResource.Type.STONE] = stone_amt
	if gold_amt > 0:
		cost[BaseResource.Type.GOLD] = gold_amt
	if food_amt > 0:
		cost[BaseResource.Type.FOOD] = food_amt
	if horses_amt > 0:
		cost[BaseResource.Type.HORSES] = horses_amt
	return cost

## Phase 8.0 — Watchtower cost helper (Wood 40 / Stone 20).
static func cost_watchtower() -> Dictionary:
	return make_cost(40, 20)

func get_stock(resource_type: int) -> int:
	match resource_type:
		BaseResource.Type.WOOD:
			return wood
		BaseResource.Type.STONE:
			return stone
		BaseResource.Type.GOLD:
			return gold
		BaseResource.Type.FOOD:
			return food
		BaseResource.Type.HORSES:
			return horses
		_:
			return 0

func _set_stock(resource_type: int, value: int) -> void:
	value = maxi(value, 0)
	match resource_type:
		BaseResource.Type.WOOD:
			wood = value
		BaseResource.Type.STONE:
			stone = value
		BaseResource.Type.GOLD:
			gold = value
		BaseResource.Type.FOOD:
			food = value
		BaseResource.Type.HORSES:
			horses = value

## Remove up to amount; returns how many were actually removed (raid siphon).
func remove(resource_type: int, amount: int) -> int:
	if amount <= 0:
		return 0
	var have: int = get_stock(resource_type)
	var taken: int = mini(amount, have)
	if taken <= 0:
		return 0
	_set_stock(resource_type, have - taken)
	resources_changed.emit()
	return taken

func can_afford(cost: Dictionary) -> bool:
	if cost == null or cost.is_empty():
		return true
	for key in cost.keys():
		var need: int = int(cost[key])
		if need <= 0:
			continue
		if get_stock(int(key)) < need:
			return false
	return true

func spend(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for key in cost.keys():
		var need: int = int(cost[key])
		if need <= 0:
			continue
		var t: int = int(key)
		_set_stock(t, get_stock(t) - need)
	resources_changed.emit()
	return true

func add(resource_type: int, amount: int) -> void:
	if amount <= 0:
		return
	_set_stock(resource_type, get_stock(resource_type) + amount)
	resources_changed.emit()
	match resource_type:
		BaseResource.Type.WOOD:
			print("Stockpile Wood: ", wood)
		BaseResource.Type.STONE:
			print("Stockpile Stone: ", stone)
		BaseResource.Type.HORSES:
			print("Stockpile Horses: ", horses)
		_:
			pass

func add_wood(amount: int) -> void:
	add(BaseResource.Type.WOOD, amount)

func add_stone(amount: int) -> void:
	add(BaseResource.Type.STONE, amount)

func add_gold(amount: int) -> void:
	add(BaseResource.Type.GOLD, amount)

func add_food(amount: int) -> void:
	add(BaseResource.Type.FOOD, amount)

func add_horses(amount: int) -> void:
	add(BaseResource.Type.HORSES, amount)
