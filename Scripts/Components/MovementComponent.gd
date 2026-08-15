extends RefCounted

class_name MovementComponent

var owner: BaseUnit


func _init(unit: BaseUnit) -> void:
	owner = unit


func update(_delta: float) -> void:
	var direction := owner.move_target - owner.global_position
	direction.y = 0.0

	if direction.length() < 0.15:
		owner.velocity = Vector3.ZERO
		# Only go IDLE if we were MOVING (combat keeps ATTACKING)
		if owner.unit_state == BaseUnit.UnitState.MOVING:
			owner.unit_state = BaseUnit.UnitState.IDLE
		return

	owner.velocity = direction.normalized() * owner.move_speed
	owner.move_and_slide()
