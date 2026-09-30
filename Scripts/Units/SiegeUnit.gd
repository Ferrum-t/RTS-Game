extends BaseUnit

class_name SiegeUnit

## Осадный таран / Siege Engine — SIEGE damage 2.0x vs buildings.
## M23.1: ranged stone projectile (attack_range ~9); HP/dmg unchanged.


func _ready() -> void:
	max_health = 200
	attack_damage = 30
	attack_range = 9.0
	attack_cooldown = 1.4
	building_attack_range = 9.0
	move_speed = 1.8
	health_bar_height = 1.5
	can_gather = false
	damage_type = DamageType.Type.SIEGE

	super()
	print("SiegeUnit spawned at ", global_position)
