extends Node

class_name HealthComponent

signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 100
@onready var current_health: int = max_health


func _ready() -> void:
	current_health = max_health


func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	current_health -= amount
	current_health = max(0, current_health)
	print("[HEALTH_DEBUG] ", get_parent().name, " took ", amount, " damage. Current health: ", current_health, "/", max_health)

	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()


func heal(amount: int) -> void:
	if current_health <= 0:
		return
	current_health += amount
	current_health = min(max_health, current_health)
	health_changed.emit(current_health, max_health)


func die() -> void:
	print("[HEALTH_DEBUG] ", get_parent().name, " died!")
	died.emit()

	var parent = get_parent()
	if parent != null:
		if "unit_state" in parent:
			parent.unit_state = 7 # DEATH is index 7 in BaseUnit.UnitState
		parent.queue_free()
