extends Node

class_name InteractionManager

@export var command_manager: CommandManager

const BUILDING_APPROACH_DISTANCE := 3.5
## Must match DeploymentComponent._validate_placement margin.
const UNPACK_MARGIN := 0.4
## Extra gap so two large footprints still unpack after arrive.
const FORMATION_BUFFER := 1.5


func handle_right_click(
	selected_units: Array[BaseUnit],
	collider,
	world_position: Vector3
) -> void:

	# Empty unit selection + RMB ground = whole player caravan (all MOBILE).
	# Buildings are not in SelectionManager yet — selection-aware move is deferred.
	if selected_units.is_empty():
		if collider is BaseUnit or collider is BaseResource or collider is BaseBuilding:
			return
		_try_move_mobile_buildings(world_position)
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


## Caravan move: every team-0 MOBILE building gets its own dest (no shared point).
func _try_move_mobile_buildings(world_position: Vector3) -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return

	var mobiles: Array = []
	for tc in bm.town_centers:
		if _is_movable_player_building(tc):
			mobiles.append(tc)
	for w in bm.watchtowers_list:
		if _is_movable_player_building(w):
			mobiles.append(w)

	if mobiles.is_empty():
		return

	var anchor: Vector3 = world_position
	anchor.y = 0.0
	var spacing: float = _building_formation_spacing(mobiles)
	var dests: Array[Vector3] = _building_formation_dests(anchor, mobiles.size(), spacing)

	for i in range(mobiles.size()):
		var building: Variant = mobiles[i]
		var dest: Vector3 = dests[i]
		building.request_move_to(dest)
		var label: String = str(building.name)
		print(
			label, " Deployment: move via RMB to ", dest,
			" (slot ", i, "/", mobiles.size(), " spacing=", snappedf(spacing, 0.1), ")"
		)


func _is_movable_player_building(building: Variant) -> bool:
	if building == null or not is_instance_valid(building):
		return false
	if int(building.get("team_id")) != 0:
		return false
	if int(building.get("deployment_state")) != DeploymentState.State.MOBILE:
		return false
	if not building.has_method("request_move_to"):
		return false
	return true


## Worst-case pair: 2 * max(nav_half_extents.xz) + unpack margin + buffer.
func _building_formation_spacing(mobiles: Array) -> float:
	var max_he: float = 2.2
	for b in mobiles:
		if b == null or not is_instance_valid(b):
			continue
		var raw: Variant = b.get("nav_half_extents")
		if raw is Vector3:
			var v: Vector3 = raw
			max_he = maxf(max_he, maxf(v.x, v.z))
	return max_he * 2.0 + UNPACK_MARGIN + FORMATION_BUFFER


## Centered grid around anchor. Does not touch Formation.gd (unit spacing).
func _building_formation_dests(anchor: Vector3, count: int, spacing: float) -> Array[Vector3]:
	var out: Array[Vector3] = []
	if count <= 0:
		return out
	if count == 1:
		out.append(anchor)
		return out

	var cols: int = int(ceili(sqrt(float(count))))
	var rows: int = int(ceili(float(count) / float(cols)))
	var i: int = 0
	for row in range(rows):
		for col in range(cols):
			if i >= count:
				break
			var ox: float = (float(col) - float(cols - 1) * 0.5) * spacing
			var oz: float = (float(row) - float(rows - 1) * 0.5) * spacing
			out.append(Vector3(anchor.x + ox, 0.0, anchor.z + oz))
			i += 1
		if i >= count:
			break
	return out


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
