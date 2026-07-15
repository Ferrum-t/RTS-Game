extends BaseJob

class_name HarvestJob


enum Phase
{
	MOVE_TO_RESOURCE,
	HARVEST,
	MOVE_TO_BASE,
	DEPOSIT
}


var phase: Phase = Phase.MOVE_TO_RESOURCE

var resource: BaseResource

var town_center: TownCenter


func _init(
	p_resource: BaseResource
) -> void:

	resource = p_resource


func start(unit: BaseUnit) -> void:

	town_center = BuildingManager.get_nearest_town_center(
		unit.global_position
	)

	unit.set_harvest_target(resource)


func update(
	unit: BaseUnit,
	delta: float
) -> void:

	match phase:

		Phase.MOVE_TO_RESOURCE:

			if unit.current_state == "harvesting":

				phase = Phase.HARVEST

		Phase.HARVEST:

			if unit.carried_amount >= unit.carry_capacity:

				phase = Phase.MOVE_TO_BASE

				unit.target_position = town_center.global_position

				unit.current_state = "moving_to_base"

		Phase.MOVE_TO_BASE:

			if unit.current_state == "depositing":

				phase = Phase.DEPOSIT

		Phase.DEPOSIT:

			if unit.current_state == "harvesting":

				phase = Phase.HARVEST
