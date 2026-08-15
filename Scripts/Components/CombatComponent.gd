extends RefCounted

class_name CombatComponent

var owner: BaseUnit

var attack_damage: int = 10
var attack_range: float = 2.0
var attack_cooldown: float = 1.0
var attack_timer: float = 0.0


func _init(unit: BaseUnit) -> void:
	owner = unit


func update(delta: float) -> void:
	var target := owner.attack_target

	if target == null or not is_instance_valid(target):
		owner.attack_target = null
		owner.unit_state = BaseUnit.UnitState.IDLE
		owner.velocity = Vector3.ZERO
		return

	if target.unit_state == BaseUnit.UnitState.DEAD:
		owner.attack_target = null
		owner.unit_state = BaseUnit.UnitState.IDLE
		owner.velocity = Vector3.ZERO
		return

	var distance := owner.global_position.distance_to(target.global_position)

	# Approach target
	if distance > attack_range:
		owner.move_target = target.global_position
		owner.movement.update(delta)
		# Keep ATTACKING state (movement component sets IDLE on arrival — override)
		if owner.unit_state != BaseUnit.UnitState.ATTACKING:
			owner.unit_state = BaseUnit.UnitState.ATTACKING
		return

	# In range — stop and strike
	owner.velocity = Vector3.ZERO
	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_timer = attack_cooldown
		_strike(target)


func _strike(target: BaseUnit) -> void:
	if target == null or not is_instance_valid(target):
		return

	print(owner.name, " hits ", target.name, " for ", attack_damage, " dmg (HP ", max(target.health - attack_damage, 0), "/", target.max_health, ")")
	target.damage(attack_damage)
