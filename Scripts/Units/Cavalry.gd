extends BaseUnit

class_name Cavalry

## Mounted combat unit. Faster, stronger; cannot harvest.


func _ready() -> void:
	max_health = 180
	attack_damage = 25
	attack_range = 2.4
	attack_cooldown = 0.85
	move_speed = 6.5
	health_bar_height = 1.9
	can_gather = false

	super()
	print("Cavalry spawned at ", global_position)
