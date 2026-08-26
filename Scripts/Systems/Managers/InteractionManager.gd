extends Node

class_name InteractionManager

@export var command_manager: CommandManager

const BUILDING_APPROACH_DISTANCE := 3.5


func handle_right_click(
	selected_units: Array[BaseUnit],
	collider,
	world_position: Vector3
) -> void:

	# No units selected: if player TC is MOBILE, RMB ground = move destination
	# (replaces fixed debug KEY_M target for normal play).
	if selected_units.is_empty():
		if collider is BaseUnit or collider is BaseResource or collider is BaseBuilding:
			return
		_try_move_mobile_town_center(world_position)
		return

	if command_manager == null:
		push_warning("InteractionManager: command_manager not set")
		return

	# Click on unit: attack only if enemy; same team → no-op
	if collider is BaseUnit:
		var target := collider as BaseUnit
		if not is_instance_valid(target):
			return
		if target.unit_state == BaseUnit.UnitState.DEAD:
			return

		var can_any := false
		for u in selected_units:
			if TeamRules.can_attack(u, target):
				can_any = true
				break

		if can_any:
			command_manager.issue_attack(selected_units, target)
		return

	if collider is BaseResource:
		if TeamRules.can_harvest(selected_units[0], collider):
			command_manager.issue_harvest(selected_units, collider)
		return

	if collider is BaseBuilding:
		var building := collider as BaseBuilding
		if not is_instance_valid(building) or building.is_destroyed:
			return

		var can_siege := false
		for u in selected_units:
			if TeamRules.can_attack_building(u, building):
				can_siege = true
				break

		if can_siege:
			command_manager.issue_attack_building(selected_units, building)
		else:
			var outside := _outside_point(building, world_position)
			command_manager.issue_move(selected_units, outside)
		return

	command_manager.issue_move(selected_units, world_position)


func _try_move_mobile_town_center(world_position: Vector3) -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return
	for tc in bm.town_centers:
		if tc == null or not is_instance_valid(tc):
			continue
		if int(tc.get("team_id")) != 0:
			continue
		if int(tc.get("deployment_state")) != DeploymentState.State.MOBILE:
			continue
		if tc.has_method("request_move_to"):
			var dest := world_position
			dest.y = 0.0
			tc.request_move_to(dest)
			print("TownCenter Deployment: move via RMB to ", dest)
			return


func _outside_point(building: BaseBuilding, click_pos: Vector3) -> Vector3:
	var center: Vector3 = building.global_position
	center.y = 0.0
	var dir: Vector3 = click_pos - center
	dir.y = 0.0
	if dir.length() < 0.15:
		dir = Vector3(1.0, 0.0, 0.0)
	else:
		dir = dir.normalized()
	var result: Vector3 = center + dir * BUILDING_APPROACH_DISTANCE
	result.y = 0.0
	return result
