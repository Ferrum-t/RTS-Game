extends RefCounted

class_name HarvestComponent

var owner: BaseUnit

## Must be larger than resource collision radius + unit radius
## Stone sphere r=0.7, unit ~0.5 → contact ~1.2; use 2.5 so we always gather
var approach_distance: float = 2.5
var harvest_amount: int = 10
var harvest_interval: float = 0.7
var _timer: float = 0.0
var _stuck_near: float = 0.0


func _init(unit: BaseUnit) -> void:
	owner = unit


func reset() -> void:
	_timer = 0.0
	_stuck_near = 0.0


func update(delta: float) -> void:
	if owner.inventory != null and owner.inventory.is_full():
		print(owner.name, " inventory full, returning to Town Center")
		owner.unit_state = BaseUnit.UnitState.RETURNING
		owner.return_target = null
		owner.velocity = Vector3.ZERO
		_stuck_near = 0.0
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

	# In range OR stuck against the resource collider → gather
	var in_range := dist <= approach_distance
	if not in_range and dist <= approach_distance + 1.0:
		_stuck_near += delta
		if _stuck_near >= 0.35:
			in_range = true
	else:
		_stuck_near = 0.0

	if not in_range:
		var stand_pos: Vector3 = resource.global_position
		if dist > 0.01:
			stand_pos = resource.global_position - to_res.normalized() * (approach_distance * 0.85)
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

	# Gather
	owner.velocity = Vector3.ZERO
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = harvest_interval

	var got: int = resource.harvest(harvest_amount)
	if got <= 0:
		print(owner.name, " — resource empty")
		owner.harvest_target = null
		owner.unit_state = BaseUnit.UnitState.IDLE
		return

	if owner.inventory == null:
		return

	# Remaining bag space (total capacity)
	var space_left: int = owner.inventory.capacity - owner.inventory.get_total()
	if space_left <= 0:
		owner.unit_state = BaseUnit.UnitState.RETURNING
		return
	got = mini(got, space_left)

	_add_to_inventory(resource, got)

	if owner.inventory.is_full():
		print(owner.name, " inventory full, returning to Town Center")
		owner.unit_state = BaseUnit.UnitState.RETURNING
		owner.return_target = null


func _add_to_inventory(resource: BaseResource, amount: int) -> void:
	var t = resource.resource_type
	# Compare as int — more reliable across class reloads
	var ti: int = int(t)
	match ti:
		1: # STONE
			owner.inventory.add_stone(amount)
			print(owner.name, " Stone: ", owner.inventory.stone, " (bag ", owner.inventory.get_total(), "/", owner.inventory.capacity, ")")
		2: # GOLD
			owner.inventory.gold = mini(owner.inventory.gold + amount, owner.inventory.capacity)
			print(owner.name, " Gold: ", owner.inventory.gold)
		3: # FOOD
			owner.inventory.food = mini(owner.inventory.food + amount, owner.inventory.capacity)
			print(owner.name, " Food: ", owner.inventory.food)
		_: # WOOD (0) and fallback
			owner.inventory.add_wood(amount)
			print(owner.name, " Wood: ", owner.inventory.wood, " (bag ", owner.inventory.get_total(), "/", owner.inventory.capacity, ")")
