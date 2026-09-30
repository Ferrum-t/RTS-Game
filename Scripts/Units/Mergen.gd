extends BaseUnit

class_name Mergen

## M23 — foot archer (ranged instant hit via CombatComponent range).
## Player-only train in M23; no AI train.


func _ready() -> void:
	max_health = 70
	attack_damage = 14
	attack_range = 11.0
	attack_cooldown = 1.1
	move_speed = 2.5
	health_bar_height = 1.75
	can_gather = false
	damage_type = DamageType.Type.RANGED

	super()
	print("Mergen spawned at ", global_position)
