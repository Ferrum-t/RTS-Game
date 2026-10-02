extends RefCounted

class_name CombatComponent

## M2: reports Status; BaseUnit owns unit_state transitions.
## M6.3: chase must call ensure_moving_to / set_target — not only move_target + update.
## Polish: hysteresis — enter attack at attack_range, leave only past exit_range.
## M13: _strike passes owner as damage source so IDLE targets can retaliate.
## M23.1: RANGED/SIEGE spawn Projectile (damage on arrival); MELEE instant.
## M26: Horse Archer can fire in-range without canceling movement (shoot-on-move).

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
		if not _allows_move_fire():
			owner.velocity = Vector3.ZERO
		_in_melee = false
		status = Status.TARGET_LOST
		return

	if target.unit_state == BaseUnit.UnitState.DEAD:
		if not _allows_move_fire():
			owner.velocity = Vector3.ZERO
		_in_melee = false
		status = Status.TARGET_DEAD
		return

	var distance := owner.global_position.distance_to(target.global_position)

	# M26: while player is MOVING (kite), do not chase — only fire if still in range.
	if distance > attack_range:
		_in_melee = false
		status = Status.CHASING
		if _allows_move_fire() and owner.unit_state == BaseUnit.UnitState.MOVING:
			return
		var chase_pos := target.global_position
		chase_pos.y = 0.0
		owner.movement.ensure_moving_to(chase_pos, chase_retarget_distance)
		owner.movement.update(delta)
		return

	# In range
	if _allows_move_fire():
		_strike_while_moving(delta, target)
		return

	# Classic stop-to-shoot / melee hold (Mergen, Soldier, Cavalry, …)
	if _in_melee:
		if distance > _exit_range():
			_in_melee = false
			status = Status.CHASING
		else:
			_hold_and_strike(delta, target)
			return

	_in_melee = true
	_hold_and_strike(delta, target)


func _allows_move_fire() -> bool:
	return owner != null and owner.can_shoot_while_moving


func _strike_while_moving(delta: float, target: BaseUnit) -> void:
	status = Status.IN_RANGE
	# Do NOT cancel movement or zero velocity — kite.
	attack_timer -= delta
	if attack_timer <= 0.0:
		attack_timer = attack_cooldown
		_strike(target)


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

	# M23.1: ranged/siege fire projectile; damage on arrival. Melee stays instant.
	if _uses_projectile():
		var is_stone: bool = int(owner.damage_type) == int(DamageType.Type.SIEGE)
		print(owner.name, " fires projectile at ", target.name, " for ", attack_damage, " dmg (stone=" , is_stone, ")")
		Projectile.fire(owner, target, attack_damage, owner, is_stone)
		return

	print(owner.name, " hits ", target.name, " for ", attack_damage, " dmg (HP ", max(target.health - attack_damage, 0), "/", target.max_health, ")")
	# M13: pass owner so IDLE target can retaliate (unit-vs-unit only).
	target.take_damage(attack_damage, owner)

	if not is_instance_valid(target) or target.unit_state == BaseUnit.UnitState.DEAD:
		_in_melee = false
		status = Status.TARGET_DEAD


func _uses_projectile() -> bool:
	if owner == null:
		return false
	var dt: int = int(owner.damage_type)
	return dt == int(DamageType.Type.RANGED) or dt == int(DamageType.Type.SIEGE)
