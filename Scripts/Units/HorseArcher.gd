extends BaseUnit

class_name HorseArcher

## M25 — mounted ranged. M26 — shoot-on-move (kite).
## Projectile arrow via CombatComponent (same path as Mergen).


func _ready() -> void:
	max_health = 90
	attack_damage = 13
	attack_range = 10.0
	attack_cooldown = 1.0
	move_speed = 4.8
	health_bar_height = 1.85
	can_gather = false
	damage_type = DamageType.Type.RANGED
	can_shoot_while_moving = true

	super()
	print("HorseArcher spawned at ", global_position)
