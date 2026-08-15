extends Node

class_name CombatComponent

@export var attack_damage: int = 10
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.0

@onready var unit: BaseUnit = get_parent() as BaseUnit

var current_target: Node3D = null
var cooldown_timer: float = 0.0


func _ready() -> void:
	pass


func set_target(new_target: Node3D) -> void:
	current_target = new_target
	if unit != null:
		unit.unit_state = BaseUnit.UnitState.ATTACKING


func _physics_process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	if unit == null or unit.unit_state != BaseUnit.UnitState.ATTACKING:
		return

	if current_target == null or not is_instance_valid(current_target):
		current_target = null
		unit.unit_state = BaseUnit.UnitState.IDLE
		return

	var dist := unit.global_position.distance_to(current_target.global_position)
	if dist <= attack_range:
		# Stop parent unit's movement
		if unit.movement != null:
			unit.movement.move_to(unit.global_position)
			unit.velocity = Vector3.ZERO

		if cooldown_timer <= 0.0:
			attack()
			cooldown_timer = attack_cooldown
	else:
		# Chase target
		if unit.movement != null:
			unit.movement.move_to(current_target.global_position)
			unit.unit_state = BaseUnit.UnitState.ATTACKING  # Keep parent in ATTACKING state


func attack() -> void:
	if current_target == null:
		return

	print("[COMBAT_DEBUG] ", unit.name, " attacked ", current_target.name, " for ", attack_damage, " damage!")

	# Deal damage using HealthComponent
	var health_comp = current_target.get_node_or_null("HealthComponent")
	if health_comp == null:
		health_comp = current_target.get_node_or_null("Components/HealthComponent")

	if health_comp != null and health_comp.has_method("take_damage"):
		health_comp.take_damage(attack_damage)
	elif current_target.has_method("take_damage"):
		current_target.take_damage(attack_damage)
