extends Node
## Autoload — per-team resource stockpiles (Stage 1).
## HUD / legacy fields (wood, stone, ...) mirror team 0 only.
## Cost API is Dictionary-based: keys = BaseResource.Type (int), values = amount.

signal resources_changed

## HUD mirrors (team 0). Prefer get_stock(team_id, type) in new code.
var wood: int = 100
var stone: int = 0
var gold: int = 0
var food: int = 0
var horses: int = 0

## team_id -> { BaseResource.Type -> int }
var _stocks: Dictionary = {}


func _ready() -> void:
	_ensure_team(0)
	_ensure_team(1)
	_set_stock(0, BaseResource.Type.WOOD, 100)
	_set_stock(1, BaseResource.Type.WOOD, 100)
	_sync_hud()
	resources_changed.emit()
	print("ResourceManager ready. Wood: ", wood, " Horses: ", horses, " (per-team stocks)")


func _ensure_team(team_id: int) -> void:
	if _stocks.has(team_id):
		return
	_stocks[team_id] = {
		BaseResource.Type.WOOD: 0,
		BaseResource.Type.STONE: 0,
		BaseResource.Type.GOLD: 0,
		BaseResource.Type.FOOD: 0,
		BaseResource.Type.HORSES: 0,
	}


func _sync_hud() -> void:
	wood = get_stock(0, BaseResource.Type.WOOD)
	stone = get_stock(0, BaseResource.Type.STONE)
	gold = get_stock(0, BaseResource.Type.GOLD)
	food = get_stock(0, BaseResource.Type.FOOD)
	horses = get_stock(0, BaseResource.Type.HORSES)


## Build a cost dictionary from individual amounts.
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


static func cost_watchtower() -> Dictionary:
	return make_cost(40, 20)


func get_stock(team_id: int, resource_type: int = -1) -> int:
	## get_stock(type) legacy → team 0; get_stock(team, type) → per-team.
	if resource_type < 0:
		resource_type = team_id
		team_id = 0
	_ensure_team(team_id)
	var bag: Dictionary = _stocks[team_id]
	return int(bag.get(resource_type, 0))


func _set_stock(team_id: int, resource_type: int, value: int) -> void:
	_ensure_team(team_id)
	value = maxi(value, 0)
	(_stocks[team_id] as Dictionary)[resource_type] = value
	if team_id == 0:
		_sync_hud()


## Remove up to amount; returns how many were actually removed (raid siphon).
## team_id default 0 for legacy raid calls.
func remove(resource_type: int, amount: int, team_id: int = 0) -> int:
	if amount <= 0:
		return 0
	var have: int = get_stock(team_id, resource_type)
	var taken: int = mini(amount, have)
	if taken <= 0:
		return 0
	_set_stock(team_id, resource_type, have - taken)
	resources_changed.emit()
	return taken


func can_afford(cost: Dictionary, team_id: int = 0) -> bool:
	if cost == null or cost.is_empty():
		return true
	for key in cost.keys():
		var need: int = int(cost[key])
		if need <= 0:
			continue
		if get_stock(team_id, int(key)) < need:
			return false
	return true


func spend(cost: Dictionary, team_id: int = 0) -> bool:
	if not can_afford(cost, team_id):
		return false
	for key in cost.keys():
		var need: int = int(cost[key])
		if need <= 0:
			continue
		var t: int = int(key)
		_set_stock(team_id, t, get_stock(team_id, t) - need)
	resources_changed.emit()
	return true


func add(resource_type: int, amount: int, team_id: int = 0) -> void:
	if amount <= 0:
		return
	_set_stock(team_id, resource_type, get_stock(team_id, resource_type) + amount)
	resources_changed.emit()
	if team_id == 0:
		match resource_type:
			BaseResource.Type.WOOD:
				print("Stockpile Wood: ", wood)
			BaseResource.Type.STONE:
				print("Stockpile Stone: ", stone)
			BaseResource.Type.HORSES:
				print("Stockpile Horses: ", horses)
			_:
				pass


func add_wood(amount: int, team_id: int = 0) -> void:
	add(BaseResource.Type.WOOD, amount, team_id)


func add_stone(amount: int, team_id: int = 0) -> void:
	add(BaseResource.Type.STONE, amount, team_id)


func add_gold(amount: int, team_id: int = 0) -> void:
	add(BaseResource.Type.GOLD, amount, team_id)


func add_food(amount: int, team_id: int = 0) -> void:
	add(BaseResource.Type.FOOD, amount, team_id)


func add_horses(amount: int, team_id: int = 0) -> void:
	add(BaseResource.Type.HORSES, amount, team_id)


func debug_stock_line(team_id: int) -> String:
	return "team=%d W=%d S=%d H=%d" % [
		team_id,
		get_stock(team_id, BaseResource.Type.WOOD),
		get_stock(team_id, BaseResource.Type.STONE),
		get_stock(team_id, BaseResource.Type.HORSES),
	]
