extends BaseBuilding

class_name TownCenter

@export var interaction_distance: float = 3.0

@export var starting_resources: Dictionary = {
	"Wood": 500,
	"Stone": 300,
	"Gold": 200,
	"Food": 100
}

var stored_resources: Dictionary = {
	"Wood": 0,
	"Stone": 0,
	"Gold": 0,
	"Food": 0
}

func _ready() -> void:
	super()
	deposit_resources(starting_resources)
	print("TownCenter:", global_position)


func deposit_resources(resources: Dictionary) -> void:
	var deposited: Dictionary = {}
	for resource_name in resources.keys():
		var amount: int = int(resources[resource_name])
		if amount <= 0:
			continue
		if stored_resources.has(resource_name):
			stored_resources[resource_name] += amount
		else:
			stored_resources[resource_name] = amount
		deposited[resource_name] = amount
	if deposited.size() > 0:
		print("Deposited to TownCenter:", deposited)
		print("Current stock:", stored_resources)

func can_afford(cost: Dictionary) -> bool:
	for resource_name in cost.keys():
		var amount: int = int(cost[resource_name])
		if amount <= 0:
			continue
		if int(stored_resources.get(resource_name, 0)) < amount:
			return false
	return true

func spend_resources(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for resource_name in cost.keys():
		var amount: int = int(cost[resource_name])
		if amount <= 0:
			continue
		stored_resources[resource_name] = int(stored_resources.get(resource_name, 0)) - amount
	print("Spent resources:", cost)
	print("Current stock:", stored_resources)
	return true
