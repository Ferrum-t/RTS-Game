extends RefCounted

class_name MovementComponent

var owner: BaseUnit

## How strongly units push away from each other while moving.
var separation_radius: float = 1.2
var separation_strength: float = 3.0


func _init(unit: BaseUnit) -> void:
	owner = unit


func update(_delta: float) -> void:
	var to_target := owner.move_target - owner.global_position
	to_target.y = 0.0

	if to_target.length() < 0.15:
		owner.velocity = Vector3.ZERO
		if owner.unit_state == BaseUnit.UnitState.MOVING:
			owner.unit_state = BaseUnit.UnitState.IDLE
		return

	var direction := to_target.normalized()

	# Soft separation — steer away from nearby units so they don't stack/stuck
	var separation := _compute_separation()
	if separation.length_squared() > 0.001:
		direction = (direction + separation * separation_strength).normalized()

	owner.velocity = direction * owner.move_speed
	owner.move_and_slide()


func _compute_separation() -> Vector3:
	var push := Vector3.ZERO
	var um := UnitManager
	if um == null:
		return push

	for other in um.units:
		if other == null or other == owner or not is_instance_valid(other):
			continue
		if other.unit_state == BaseUnit.UnitState.DEAD:
			continue

		var offset: Vector3 = owner.global_position - other.global_position
		offset.y = 0.0
		var dist := offset.length()

		if dist < 0.001 or dist >= separation_radius:
			continue

		# Closer = stronger push
		var force := (1.0 - dist / separation_radius)
		push += offset.normalized() * force

	return push
