extends RefCounted

class_name HarvestComponent

var owner: BaseUnit

var harvest_timer := 0.0
var harvest_interval := 1.0
var harvest_amount := 10


func _init(unit: BaseUnit):

	owner = unit


func update(delta):

	if owner.harvest_target == null:

		owner.unit_state = BaseUnit.UnitState.IDLE
		return

	var resource := owner.harvest_target

	# если инвентарь полный
	if owner.inventory.is_full():

		owner.unit_state = BaseUnit.UnitState.RETURNING
		return

	var distance := owner.global_position.distance_to(resource.global_position)

	# сначала подойти
	if distance > 2.0:

		owner.move_target = resource.global_position
		owner.movement.update(delta)
		return

	# добыча
	harvest_timer += delta

	if harvest_timer >= harvest_interval:

		harvest_timer = 0.0

		owner.inventory.add_wood(harvest_amount)

		print(
			owner.name,
			" Wood: ",
			owner.inventory.wood,
			"/",
			owner.inventory.capacity
		)
