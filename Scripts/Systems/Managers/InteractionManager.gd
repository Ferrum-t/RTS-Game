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

	# -------------------------
	# Resource
	# -------------------------

	if collider is BaseResource:

		command_manager.issue_harvest(
			selected_units,
			collider
		)

		return

	# -------------------------
	# Ground
	# -------------------------

	command_manager.issue_move(
		selected_units,
		world_position
	)
