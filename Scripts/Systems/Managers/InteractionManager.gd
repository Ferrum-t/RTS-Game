extends Node

class_name InteractionManager

@export var command_manager: CommandManager


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

	# Move to ground
	command_manager.issue_move(selected_units, world_position)
