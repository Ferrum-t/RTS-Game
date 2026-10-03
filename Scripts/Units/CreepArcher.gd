extends Creep

class_name CreepArcher

## M30 — Ranged neutral creep for Archer camp.
## Same aggro / camp ownership as melee Creep.


func _ready() -> void:
	super._ready()
	# Override melee defaults from Creep
	max_health = 60
	health = 60
	attack_damage = 11
	attack_range = 8.0
	attack_cooldown = 1.2
	move_speed = 2.3
	health_bar_height = 1.55
	damage_type = DamageType.Type.RANGED
	can_shoot_while_moving = false
	if health_bar and health_bar.has_method("setup"):
		health_bar.setup(max_health)
		health_bar.set_health(health)
	print("CreepArcher spawned at ", global_position)
