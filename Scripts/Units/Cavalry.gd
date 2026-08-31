extends BaseUnit

class_name Cavalry

## Mounted combat unit. Faster, stronger; cannot harvest.
## Phase 6: still MELEE vs buildings (0.25x). Future siege units use SIEGE.


func _ready() -> void:
	max_health = 180
	attack_damage = 25
	attack_range = 2.4
	attack_cooldown = 0.85
	move_speed = 3.25
	health_bar_height = 1.9
	can_gather = false
	damage_type = DamageType.Type.MELEE

	super()
	print("Cavalry spawned at ", global_position)
