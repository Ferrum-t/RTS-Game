extends Node

class_name InteractionManager

@export var command_manager: CommandManager


func handle_right_click(
	selected_units: Array[BaseUnit],
	collider,
	world_position: Vector3
) -> void:
	print("[DIAG] InteractionManager: handle_right_click with ", selected_units.size(), " units, collider: ", collider.name if collider else "null")
	if selected_units.is_empty():
		return
	if command_manager == null:
		push_error("CommandManager is not assigned to InteractionManager")
		return

	var resource: BaseResource = resolve_resource_collider(collider)
	if resource != null:
		print("[DIAG] InteractionManager: Resolved resource ", resource.name, ", issuing harvest")
		command_manager.issue_harvest(selected_units, resource)
		return

	var attack_target: Node = resolve_attack_target(collider)
	if attack_target != null and attack_target not in selected_units:
		print("[DIAG] InteractionManager: Resolved attack target ", attack_target.name, ", issuing attack")
		command_manager.issue_attack(selected_units, attack_target)
		return

	print("[DIAG] InteractionManager: Issuing move to ", world_position)
	command_manager.issue_move(selected_units, world_position)


func resolve_attack_target(collider) -> Node:
	if collider is Node:
		var node := collider as Node
		while node != null:
			if node.has_node("HealthComponent") or node.has_node("Components/HealthComponent") or node.has_method("take_damage"):
				return node
			node = node.get_parent() as Node
	return null


func resolve_resource_collider(collider) -> BaseResource:
	if collider is BaseResource:
		return collider
	if collider is Node:
		var node := collider as Node
		while node != null:
			if node is BaseResource:
				return node as BaseResource
			node = node.get_parent() as Node
	return null
