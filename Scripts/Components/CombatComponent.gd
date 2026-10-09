extends RefCounted

class_name CombatComponent

enum Status {
	IDLE,
	CHASING,
	IN_RANGE,
	TARGET_LOST,
	TARGET_DEAD,
}

var owner: BaseUnit
var status: Status = Status.IDLE
var target: BaseUnit = null

var attack_damage: int = 10
var attack_range: float = 2.0
var attack_cooldown: float = 1.0
var chase_retarget_distance: float = 1.0

var attack_timer: float = 0.0
var _in_melee: bool = false
## M35.8-B3 — ring of approach points when path is BLOCKED near target
var _approach_slot: int = 0
const APPROACH_SLOTS := 6


func _init(unit: BaseUnit) -> void:
	owner = unit


func set_target(t: BaseUnit) -> void:
	target = t
	_in_melee = false
	_approach_slot = 0
	status = Status.CHASING if t != null else Status.IDLE
	attack_timer = 0.0


func clear() -> void:
	target = null
	_in_melee = false
	_approach_slot = 0
	status = Status.IDLE
	attack_timer = 0.0


func _exit_range() -> float:
	return attack_range * 1.35


func update(delta: float) -> void:
	if owner == null or not is_instance_valid(owner):
		return
	if target == null or not is_instance_valid(target):
		_in_melee = false
		status = Status.TARGET_LOST
		return
	if target.unit_state == BaseUnit.UnitState.DEAD:
		_in_melee = false
		status = Status.TARGET_DEAD
		return

	var distance := owner.global_position.distance_to(target.global_position)

	if distance > attack_range:
		_in_melee = false
		status = Status.CHASING
		if _allows_move_fire() and owner.unit_state == BaseUnit.UnitState.MOVING:
			return
		var r: float = maxf(attack_range * 0.75, 0.8)
		var chase_pos := target.global_position
		# If path stuck, step around the target on a ring (unblocks frozen melee)
		if owner.movement != null and owner.movement.status == MovementComponent.Status.BLOCKED:
			_approach_slot = (_approach_slot + 1) % APPROACH_SLOTS
			var ang: float = float(_approach_slot) * TAU / float(APPROACH_SLOTS)
			chase_pos = target.global_position + Vector3(cos(ang) * r, 0.0, sin(ang) * r)
			chase_pos.y = 0.0
			owner.movement.set_target(chase_pos)
			owner.movement.update(delta)
			return
		var to_t := target.global_position - owner.global_position
		to_t.y = 0.0
		if to_t.length() > 0.1:
			chase_pos = target.global_position - to_t.normalized() * r
		chase_pos.y = 0.0
		owner.movement.ensure_moving_to(chase_pos, maxf(chase_retarget_distance, 1.2))
		owner.movement.update(delta)
		return

	# In range
	if _allows_move_fire():
		_strike_while_moving(delta, target)
		return

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

	if _uses_projectile():
		var is_stone: bool = int(owner.damage_type) == int(DamageType.Type.SIEGE)
		print(owner.name, " fires projectile at ", target.name, " for ", attack_damage, " dmg (stone=", is_stone, ")")
		Projectile.fire(owner, target, attack_damage, owner, is_stone)
		return

	print(owner.name, " hits ", target.name, " for ", attack_damage, " dmg (HP ", max(target.health - attack_damage, 0), "/", target.max_health, ")")
	target.take_damage(attack_damage, owner)

	if not is_instance_valid(target) or target.unit_state == BaseUnit.UnitState.DEAD:
		_in_melee = false
		status = Status.TARGET_DEAD


func _uses_projectile() -> bool:
	if owner == null:
		return false
	var dt: int = int(owner.damage_type)
	return dt == int(DamageType.Type.RANGED) or dt == int(DamageType.Type.SIEGE)
