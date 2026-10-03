extends BaseUnit

class_name Creep

## M27/M31 — Neutral. team_id = -1. Notifies camp on death.

const AGGRO_RADIUS := 11.0

var owning_camp: Node = null
var _camp_notified: bool = false


func _ready() -> void:
	max_health = 80
	attack_damage = 12
	attack_range = 2.0
	attack_cooldown = 1.1
	move_speed = 2.5
	health_bar_height = 1.6
	can_gather = false
	damage_type = DamageType.Type.MELEE
	team_id = -1
	can_shoot_while_moving = false

	super()
	add_to_group("Creep")
	print("Creep spawned at ", global_position)


func take_damage(amount: int, source: Node = null) -> void:
	if source != null and is_instance_valid(source) and "team_id" in source:
		var t: int = int(source.team_id)
		if t != -1 and owning_camp != null and owning_camp.has_method("note_attacker_team"):
			owning_camp.note_attacker_team(t)
	super.take_damage(amount, source)


func die() -> void:
	_notify_camp_death()
	super.die()


func _notify_camp_death() -> void:
	if _camp_notified:
		return
	_camp_notified = true
	if owning_camp != null and is_instance_valid(owning_camp):
		if owning_camp.has_method("on_creep_died"):
			owning_camp.on_creep_died(self)
			print("[M30] Creep.die → camp notified at ", global_position)


func _try_idle_acquire(delta: float) -> void:
	_acquire_timer -= delta
	if _acquire_timer > 0.0:
		return
	_acquire_timer = ACQUIRE_SCAN_INTERVAL
	if unit_state != UnitState.IDLE:
		return
	var enemy := _find_nearest_hostile()
	if enemy == null:
		return
	replace_order_attack(enemy)


func _find_nearest_hostile() -> BaseUnit:
	var best: BaseUnit = null
	var best_dist_sq: float = AGGRO_RADIUS * AGGRO_RADIUS
	for n in get_tree().get_nodes_in_group("Unit"):
		if not (n is BaseUnit):
			continue
		var other: BaseUnit = n as BaseUnit
		if other == self or not is_instance_valid(other):
			continue
		if other.unit_state == UnitState.DEAD:
			continue
		if int(other.team_id) == -1:
			continue
		var d_sq: float = global_position.distance_squared_to(other.global_position)
		if d_sq > best_dist_sq:
			continue
		best_dist_sq = d_sq
		best = other
	return best
