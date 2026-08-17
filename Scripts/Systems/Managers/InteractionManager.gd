extends Node

class_name InteractionManager

@export var command_manager: CommandManager

const BUILDING_APPROACH_DISTANCE := 3.5


func handle_right_click(
	selected_units: Array[BaseUnit],
	collider,
	world_position: Vector3
) -> void:

	if selected_units.is_empty():
		return

	if command_manager == null:
		push_warning("InteractionManager: command_manager not set")
		return

	# Attack unit
	if collider is BaseUnit:
		var enemy := collider as BaseUnit
		if enemy.unit_state != BaseUnit.UnitState.DEAD:
			command_manager.issue_attack(selected_units, enemy)
			return

	# Harvest resource
	if collider is BaseResource:
		command_manager.issue_harvest(selected_units, collider)
		return

	# Click on building → move to a point OUTSIDE it (never inside)
	if collider is BaseBuilding:
		var building := collider as BaseBuilding
		var outside := _outside_point(building, world_position)
		command_manager.issue_move(selected_units, outside)
		return

	# Ground move
	command_manager.issue_move(selected_units, world_position)


func _outside_point(building: BaseBuilding, click_pos: Vector3) -> Vector3:
	var center: Vector3 = building.global_position
	center.y = 0.0
	var dir: Vector3 = click_pos - center
	dir.y = 0.0
	if dir.length() < 0.15:
		# Click near center — pick a default outward direction
		dir = Vector3(1.0, 0.0, 0.0)
	else:
		dir = dir.normalized()
	var result: Vector3 = center + dir * BUILDING_APPROACH_DISTANCE
	result.y = 0.0
	return result
