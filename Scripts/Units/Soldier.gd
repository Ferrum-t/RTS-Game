extends BaseUnit

class_name Soldier

## Combat unit. Stronger than Worker, no special harvest overrides.


func _ready() -> void:
	# Stats before super() so components pick them up in BaseUnit._ready
	max_health = 150
	attack_damage = 20
	attack_range = 2.2
	attack_cooldown = 0.9
	move_speed = 2.25
	health_bar_height = 1.8
	damage_type = DamageType.Type.MELEE

	super()
	print("Soldier spawned at ", global_position)
