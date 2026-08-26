extends Node

class_name EnemyAIComponent

## Phase 7 — lightweight enemy brain.
## Does NOT move/attack itself. Issues BaseUnit.replace_order_* only.
## Unit execution stays: MovementComponent + CombatComponent + siege path.

enum BrainState {
	IDLE,
	MARCH,
	CHASE,
	ATTACK,
}

@export var aggro_radius: float = 22.0
@export var reeval_interval: float = 0.55
@export var prefer_buildings: bool = true

var unit: BaseUnit = null
var brain_state: int = BrainState.IDLE
var _timer: float = 0.0
var _march_building: BaseBuilding = null


func setup(owner_unit: BaseUnit) -> void:
	unit = owner_unit
	brain_state = BrainState.IDLE
	_timer = 0.0
	_march_building = null


func _physics_process(delta: float) -> void:
	if unit == null or not is_instance_valid(unit):
		queue_free()
		return
	if unit.unit_state == BaseUnit.UnitState.DEAD:
		return
	if unit.team_id != 1:
		return

	var mm := get_node_or_null("/root/MatchManager")
	if mm != null and mm.has_method("is_playing") and not mm.is_playing():
		return

	_timer -= delta
	if _timer > 0.0:
		_validate_current_order()
		return
	_timer = reeval_interval
	_think()


func _validate_current_order() -> void:
	if unit == null:
		return
	var order: Order = unit.current_order
	if order == null or order.type == Order.Type.NONE:
		if brain_state != BrainState.IDLE and brain_state != BrainState.MARCH:
			brain_state = BrainState.IDLE
		return
	match order.type:
		Order.Type.ATTACK:
			var u: BaseUnit = order.target as BaseUnit
			if u == null or not is_instance_valid(u) or u.unit_state == BaseUnit.UnitState.DEAD:
				brain_state = BrainState.IDLE
		Order.Type.ATTACK_BUILDING:
			var b: BaseBuilding = order.target as BaseBuilding
			if b == null or not is_instance_valid(b) or b.is_destroyed or b.health <= 0:
				brain_state = BrainState.IDLE
		_:
			pass


func _think() -> void:
	var target_unit: BaseUnit = _find_priority_unit()
	var target_building: BaseBuilding = _find_priority_building()

	# Priority: SiegeUnit > buildings (if prefer) > other units > march to TC
	if target_unit != null and target_unit is SiegeUnit:
		_issue_attack_unit(target_unit)
		return

	if prefer_buildings and target_building != null:
		_issue_attack_building(target_building)
		return

	if target_unit != null:
		_issue_attack_unit(target_unit)
		return

	if target_building != null:
		_issue_attack_building(target_building)
		return

	_issue_march_to_player_base()


func _issue_attack_unit(enemy: BaseUnit) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	if not TeamRules.can_attack(unit, enemy):
		return
	var cur := unit.current_order
	if cur != null and cur.type == Order.Type.ATTACK and cur.target == enemy:
		brain_state = BrainState.ATTACK if unit.unit_state == BaseUnit.UnitState.ATTACKING else BrainState.CHASE
		return
	unit.replace_order_attack(enemy)
	brain_state = BrainState.CHASE


func _issue_attack_building(building: BaseBuilding) -> void:
	if building == null or not is_instance_valid(building):
		return
	if not TeamRules.can_attack_building(unit, building):
		return
	var cur := unit.current_order
	if cur != null and cur.type == Order.Type.ATTACK_BUILDING and cur.target == building:
		brain_state = BrainState.ATTACK if unit.unit_state == BaseUnit.UnitState.ATTACKING else BrainState.CHASE
		return
	unit.replace_order_attack_building(building)
	brain_state = BrainState.CHASE


func _issue_march_to_player_base() -> void:
	var base := _get_player_town_center()
	if base == null:
		brain_state = BrainState.IDLE
		return
	_march_building = base
	# March = attack building order (siege/move-in-range already in BaseUnit)
	var cur := unit.current_order
	if cur != null and cur.type == Order.Type.ATTACK_BUILDING and cur.target == base:
		brain_state = BrainState.MARCH
		return
	if unit.unit_state == BaseUnit.UnitState.ATTACKING and unit.attack_building_target == base:
		brain_state = BrainState.MARCH
		return
	unit.replace_order_attack_building(base)
	brain_state = BrainState.MARCH


func _find_priority_unit() -> BaseUnit:
	if unit == null:
		return null
	var best: BaseUnit = null
	var best_score: float = -INF
	var origin := unit.global_position
	for n in unit.get_tree().get_nodes_in_group("Unit"):
		if not (n is BaseUnit):
			continue
		var other := n as BaseUnit
		if other == unit:
			continue
		if not is_instance_valid(other):
			continue
		if other.unit_state == BaseUnit.UnitState.DEAD:
			continue
		if other.team_id != 0:
			continue
		var dist := origin.distance_to(other.global_position)
		if dist > aggro_radius:
			continue
		if not TeamRules.can_attack(unit, other):
			continue
		var score: float = -dist
		if other is SiegeUnit:
			score += 1000.0
		elif other is Cavalry:
			score += 50.0
		if score > best_score:
			best_score = score
			best = other
	return best


func _find_priority_building() -> BaseBuilding:
	if unit == null:
		return null
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return null
	var best: BaseBuilding = null
	var best_score: float = -INF
	var origin := unit.global_position
	for b in bm.buildings:
		if b == null or not is_instance_valid(b):
			continue
		if not (b is BaseBuilding):
			continue
		var building := b as BaseBuilding
		if building.team_id != 0:
			continue
		if building.is_destroyed or building.health <= 0:
			continue
		var dist := origin.distance_to(building.global_position)
		if dist > aggro_radius * 1.35:
			continue
		if not TeamRules.can_attack_building(unit, building):
			continue
		var score: float = -dist
		if building is TownCenter:
			score += 200.0
		elif building is Barracks:
			score += 120.0
		if score > best_score:
			best_score = score
			best = building
	return best


func _get_player_town_center() -> BaseBuilding:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return null
	for tc in bm.town_centers:
		if tc == null or not is_instance_valid(tc):
			continue
		if tc is BaseBuilding and (tc as BaseBuilding).team_id == 0:
			var b := tc as BaseBuilding
			if not b.is_destroyed and b.health > 0:
				return b
	return null


static func attach_to(unit: BaseUnit, aggro: float = 22.0) -> EnemyAIComponent:
	if unit == null or not is_instance_valid(unit):
		return null
	for c in unit.get_children():
		if c is EnemyAIComponent:
			return c as EnemyAIComponent
	var ai := EnemyAIComponent.new()
	ai.name = "EnemyAIComponent"
	ai.aggro_radius = aggro
	unit.add_child(ai)
	ai.setup(unit)
	return ai
