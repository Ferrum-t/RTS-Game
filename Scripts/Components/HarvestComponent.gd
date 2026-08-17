extends RefCounted

class_name HarvestComponent

var owner: BaseUnit

var approach_distance: float = 1.7
var harvest_amount: int = 10
var harvest_interval: float = 0.8
var _timer: float = 0.0


func _init(unit: BaseUnit) -> void:
	owner = unit


func update(delta: float) -> void:
	if owner.inventory != null and owner.inventory.is_full():
		print(owner.name, " inventory full, returning to Town Center")
		owner.unit_state = BaseUnit.UnitState.RETURNING
		owner.return_target = null
		owner.velocity = Vector3.ZERO
		return

	var resource: BaseResource = owner.harvest_target
	if resource == null or not is_instance_valid(resource):
		owner.harvest_target = null
		owner.unit_state = BaseUnit.UnitState.IDLE
		owner.velocity = Vector3.ZERO
		return

	var to_res: Vector3 = resource.global_position - owner.global_position
	to_res.y = 0.0
	var dist := to_res.length()

	if dist > approach_distance:
		var stand_pos: Vector3 = resource.global_position
		if to_res.length() > 0.01:
			stand_pos = resource.global_position - to_res.normalized() * approach_distance
		stand_pos.y = 0.0
		owner.move_target = stand_pos
		var step := stand_pos - owner.global_position
		step.y = 0.0
		if step.length() > 0.05:
			owner.velocity = step.normalized() * owner.move_speed
			owner.move_and_slide()
		else:
			owner.velocity = Vector3.ZERO
		return

	owner.velocity = Vector3.ZERO
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = harvest_interval

	var got: int = resource.harvest(harvest_amount)
	if got > 0 and owner.inventory:
		_add_to_inventory(resource.resource_type, got)
	elif got <= 0:
		owner.harvest_target = null
		owner.unit_state = BaseUnit.UnitState.IDLE


func _add_to_inventory(type: BaseResource.Type, amount: int) -> void:
	match type:
		BaseResource.Type.WOOD:
			owner.inventory.add_wood(amount)
			print(owner.name, " Wood: ", owner.inventory.wood, "/", owner.inventory.capacity)
		BaseResource.Type.STONE:
			owner.inventory.stone = mini(owner.inventory.stone + amount, owner.inventory.capacity)
			print(owner.name, " Stone: ", owner.inventory.stone, "/", owner.inventory.capacity)
		BaseResource.Type.GOLD:
			owner.inventory.gold = mini(owner.inventory.gold + amount, owner.inventory.capacity)
			print(owner.name, " Gold: ", owner.inventory.gold, "/", owner.inventory.capacity)
		BaseResource.Type.FOOD:
			owner.inventory.food = mini(owner.inventory.food + amount, owner.inventory.capacity)
			print(owner.name, " Food: ", owner.inventory.food, "/", owner.inventory.capacity)
