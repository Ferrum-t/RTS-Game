extends RefCounted

class_name CombatComponent

## M2: reports Status; BaseUnit owns unit_state transitions.
## M6.3: chase must call ensure_moving_to / set_target — not only move_target + update.
## Polish: hysteresis — enter attack at attack_range, leave only past exit_range.

enum Status {
	IDLE,
	CHASING,
	IN_RANGE,
	TARGET_LOST,
	TARGET_DEAD,
	CANCELLED,
}

var owner: BaseUnit
var status: Status = Status.IDLE

var attack_damage: int = 10
var attack_range: float = 2.0
var attack_cooldown: float = 1.0
var attack_timer: float = 0.0

## Exit melee only when farther than attack_range * this (hysteresis).
var exit_range_mult: float = 1.25

## True while locked in melee; prevents CHASE/ATTACK oscillation.
var _in_melee: bool = false

## Retarget chase path when enemy moved this far from last path target
var chase_retarget_distance: float = 1.0


func _init(unit: BaseUnit) -> void:
	owner = unit


func reset() -> void:
	attack_timer = 0.0
	_in_melee = false
	status = Status.IDLE


func get_status() -> Status:
	return status


func _exit_range() -> float:
	return attack_range * exit_range_mult


func update(delta: float) -> void:
	var target := owner.attack_target

	if target == null or not is_instance_valid(target):
		owner.velocity = Vector3.ZERO
		_in_melee = false
		status = Status.TARGET_LOST
		return

	if target.unit_state == BaseUnit.UnitState.DEAD:
		owner.velocity = Vector3.ZERO
		_in_melee = false
		status = Status.TARGET_DEAD
		return

	var distance := owner.global_position.distance_to(target.global_position)

	# Hysteresis: once in melee, stay until past exit_range
	if _in_melee:
		if distance > _exit_range():
			_in_melee = false
			status = Status.CHASING
		else:
			_hold_and_strike(delta, target)
			return

	if distance > attack_range:
		status = Status.CHASING
		var chase_pos := target.global_position
		chase_pos.y = 0.0
		owner.movement.ensure_moving_to(chase_pos, chase_retarget_distance)
		owner.movement.update(delta)
		return

	# Enter melee — freeze path agent
	_in_melee = true
	_hold_and_strike(delta, target)


func _hold_and_strike(delta: float, target: BaseUnit) -> void:
	status = Status.IN_RANGE
	if owner.movement:
		owner.movement.cancel()
	owner.velocity = Vector3.ZERO
	attack_timer -= delta
	if attack_timer <= 0.0:
		attack_timer = attack_cooldown
		_strike(target)


func _strike(target: BaseUnit) -> void:
	if target == null or not is_instance_valid(target):
		_in_melee = false
		status = Status.TARGET_LOST
		return
	if target.unit_state == BaseUnit.UnitState.DEAD:
		_in_melee = false
		status = Status.TARGET_DEAD
		return

	print(owner.name, " hits ", target.name, " for ", attack_damage, " dmg (HP ", max(target.health - attack_damage, 0), "/", target.max_health, ")")
	target.take_damage(attack_damage)

	if not is_instance_valid(target) or target.unit_state == BaseUnit.UnitState.DEAD:
		_in_melee = false
		status = Status.TARGET_DEAD
