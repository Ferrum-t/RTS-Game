extends RefCounted

class_name CombatComponent

## M2: reports Status; BaseUnit owns unit_state transitions.

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


func _init(unit: BaseUnit) -> void:
	owner = unit


func reset() -> void:
	attack_timer = 0.0
	status = Status.IDLE


func get_status() -> Status:
	return status


func update(delta: float) -> void:
	var target := owner.attack_target

	if target == null or not is_instance_valid(target):
		owner.velocity = Vector3.ZERO
		status = Status.TARGET_LOST
		return

	if target.unit_state == BaseUnit.UnitState.DEAD:
		owner.velocity = Vector3.ZERO
		status = Status.TARGET_DEAD
		return

	var distance := owner.global_position.distance_to(target.global_position)

	if distance > attack_range:
		status = Status.CHASING
		owner.move_target = target.global_position
		owner.movement.update(delta)
		# M1: Movement does not write unit_state; Unit keeps ATTACKING
		return

	status = Status.IN_RANGE
	owner.velocity = Vector3.ZERO
	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_timer = attack_cooldown
		_strike(target)


func _strike(target: BaseUnit) -> void:
	if target == null or not is_instance_valid(target):
		status = Status.TARGET_LOST
		return
	if target.unit_state == BaseUnit.UnitState.DEAD:
		status = Status.TARGET_DEAD
		return

	print(owner.name, " hits ", target.name, " for ", attack_damage, " dmg (HP ", max(target.health - attack_damage, 0), "/", target.max_health, ")")
	target.damage(attack_damage)

	# Target may die / free during damage
	if not is_instance_valid(target) or target.unit_state == BaseUnit.UnitState.DEAD:
		status = Status.TARGET_DEAD
