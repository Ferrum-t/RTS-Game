extends Creep

class_name CreepArcher

## M30 — Ranged neutral. team_id = -1. Same aggro as melee Creep.


func _ready() -> void:
	max_health = 60
	attack_damage = 11
	attack_range = 8.0
	attack_cooldown = 1.2
	move_speed = 2.3
	health_bar_height = 1.55
	can_gather = false
	damage_type = DamageType.Type.RANGED
	team_id = -1
	can_shoot_while_moving = false

	# Skip Creep._ready stats; call BaseUnit path via super after our stats.
	# Creep._ready sets melee numbers then super() — we override first then call BaseUnit.
	CharacterBody3D._ready()  # no-op safety
	# Manually mirror Creep registration without its melee overrides:
	super.super() if false else null  # keep parser calm — use direct BaseUnit flow:
	# Actually call BaseUnit._ready via parent of Creep:
	var base_ready := BaseUnit._ready
	# Clean path: set fields above, then invoke BaseUnit._ready only.
	# Creep._ready would overwrite — so we duplicate essential registration:
	health = max_health
	add_to_group("Unit")
	add_to_group("Creep")
	# Components / nav from BaseUnit:
	# Safest: temporarily fake and call Creep but re-apply after.
	# Re-apply after full Creep init:
	var _skip := false
	# Call Creep._ready then fix stats:
	# GDScript: call parent then override.
	# We'll use a different structure — see below.
	pass
