extends Node

class_name BuildingCombatComponent

## Phase 8.0 — building auto-attack.
## Acquire: scan UnitManager.units on a timer. No Area3D, no PhysicsQuery.
## Damage: frozen BaseUnit.damage(amount) contract.
## Does not issue Orders and does not touch Movement / Harvest / Match.

@export var attack_range: float = 14.0
@export var attack_damage: int = 12
@export var attack_cooldown: float = 1.0
@export var scan_interval: float = 0.4
@export var damage_type: int = DamageType.Type.RANGED
## Keep current target until it leaves attack_range * this (anti-flicker).
@export var exit_range_mult: float = 1.15

var _scan_timer: float = 0.0
var _attack_timer: float = 0.0
## Untyped so a freed instance is not forced through BaseUnit arg checks.
var _target: Object = null


func _ready() -> void:
	_scan_timer = 0.0
	_attack_timer = 0.0
	var b: BaseBuilding = _host()
	if b == null:
		return
	print(
		"[TOWER] ", b.name, " combat ready team=", b.team_id,
		" range=", attack_range, " dmg=", attack_damage
	)


func _process(delta: float) -> void:
	var b: BaseBuilding = _host()
	if b == null or b.is_destroyed or b.health <= 0:
		_clear_target("host dead")
		return
	if b.deployment_state != DeploymentState.State.DEPLOYED:
		_clear_target("not deployed")
		return

	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = scan_interval
		_acquire(b)

	# Freed units must not be passed into typed BaseUnit parameters.
	if not is_instance_valid(_target):
		if _target != null:
			_clear_target("freed")
		return

	if not _is_target_valid(b, _target, true):
		_clear_target("lost")
		return

	if _attack_timer > 0.0:
		return
	_strike(b, _target as BaseUnit)


func _host() -> BaseBuilding:
	var p: Node = get_parent()
	if p is BaseBuilding:
		return p as BaseBuilding
	return null


func _acquire(b: BaseBuilding) -> void:
	if is_instance_valid(_target) and _is_target_valid(b, _target, true):
		return
	if not is_instance_valid(_target):
		_target = null

	var um: Node = get_node_or_null("/root/UnitManager")
	if um == null:
		return

	var units: Array = um.get("units") as Array
	var best: BaseUnit = null
	var best_dist: float = INF
	var origin: Vector3 = b.global_position
	for u in units:
		if not is_instance_valid(u):
			continue
		if not (u is BaseUnit):
			continue
		var unit: BaseUnit = u as BaseUnit
		if not _is_target_valid(b, unit, false):
			continue
		var dist: float = origin.distance_to(unit.global_position)
		if dist > attack_range:
			continue
		if dist < best_dist:
			best_dist = dist
			best = unit

	if best == null:
		_target = null
		return

	if _target != best:
		_target = best
		print(
			"[TOWER] ", b.name, " acquired ", best.name,
			" dist=", snappedf(best_dist, 0.1), " team=", best.team_id
		)


## unit is Object so callers can pass a possibly-freed ref without typed-arg crash.
func _is_target_valid(b: BaseBuilding, unit: Object, use_exit_range: bool) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	if not (unit is BaseUnit):
		return false
	var u: BaseUnit = unit as BaseUnit
	if u.unit_state == BaseUnit.UnitState.DEAD:
		return false
	if int(u.team_id) == int(b.team_id):
		return false
	var limit: float = attack_range
	if use_exit_range:
		limit = attack_range * exit_range_mult
	if b.global_position.distance_to(u.global_position) > limit:
		return false
	return true


func _strike(b: BaseBuilding, unit: BaseUnit) -> void:
	if not is_instance_valid(unit) or not _is_target_valid(b, unit, true):
		_clear_target("invalid strike")
		return
	_attack_timer = attack_cooldown
	var hp_after: int = maxi(unit.health - attack_damage, 0)
	print(
		"[TOWER] ", b.name, " hits ", unit.name, " for ", attack_damage,
		" dmg (HP ", hp_after, "/", unit.max_health, ")"
	)
	unit.damage(attack_damage)
	if not is_instance_valid(unit) or unit.unit_state == BaseUnit.UnitState.DEAD:
		_clear_target("killed")


func _clear_target(reason: String) -> void:
	if _target == null:
		return
	var b: BaseBuilding = _host()
	var host_name: String = "tower"
	if b != null and is_instance_valid(b):
		host_name = str(b.name)
	print("[TOWER] ", host_name, " lost target (", reason, ")")
	_target = null
