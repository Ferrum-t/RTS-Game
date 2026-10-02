extends CharacterBody3D

class_name BaseUnit


enum UnitState
{
	IDLE,
	MOVING,
	HARVESTING,
	RETURNING,
	BUILDING,
	REPAIRING,
	ATTACKING,
	DEAD
}


@export var team_id: int = 0
@export var move_speed := 2.4
@export var max_health := 100
@export var deposit_distance := 3.5
@export var attack_damage := 10
@export var attack_range := 2.0
@export var attack_cooldown := 1.0
@export var building_attack_range := 6.5
@export var building_exit_range_mult := 1.2
@export var health_bar_height := 1.6
@export var can_gather: bool = true
## M26: Horse Archer — fire while pathing; MOVE keeps attack_target.
var can_shoot_while_moving: bool = false
@export var damage_type: int = DamageType.Type.MELEE

var health := 100
var selected := false
var unit_state : UnitState = UnitState.IDLE
var current_order: Order = Order.none()
var move_target : Vector3
var harvest_target : BaseResource = null
var build_target : BaseBuilding = null
var repair_target : BaseBuilding = null
var attack_target : BaseUnit = null
var attack_building_target : BaseBuilding = null
var return_target : Node3D = null
var movement : MovementComponent
var inventory : InventoryComponent
var harvest : HarvestComponent
var combat : CombatComponent
var health_bar: HealthBar3D = null
var nav_agent: NavigationAgent3D = null
var _selection_ring: MeshInstance3D = null
var last_move_end_reason: String = ""
var _building_attack_timer: float = 0.0
var _siege_stuck_time: float = 0.0
var _siege_last_pos: Vector3 = Vector3.ZERO
var _siege_in_range: bool = false
var _build_stuck_time: float = 0.0
var _build_last_pos: Vector3 = Vector3.ZERO
var _acquire_timer: float = 0.0

const GRAVITY := 30.0
const HEALTH_BAR_SCENE := preload("res://Scenes/UI/HealthBar3D.tscn")
const APPROACH_RETARGET_DIST := 0.9
const BUILD_STAND_DIST := 3.0
const BUILD_FOOTPRINT_MARGIN := 1.25
const ACQUIRE_RADIUS := 12.0
const ACQUIRE_SCAN_INTERVAL := 0.4

func _ready() -> void:
	health = max_health
	add_to_group("Unit")
	collision_layer = 2
	collision_mask = 1
	var pos := global_position
	pos.y = 0.0
	global_position = pos
	UnitManager.register_unit(self)
	nav_agent = NavigationAgent3D.new()
	nav_agent.name = "NavigationAgent3D"
	add_child(nav_agent)
	movement = MovementComponent.new(self, nav_agent)
	inventory = InventoryComponent.new(self)
	harvest = HarvestComponent.new(self)
	combat = CombatComponent.new(self)
	combat.attack_damage = attack_damage
	combat.attack_range = attack_range
	combat.attack_cooldown = attack_cooldown
	_setup_health_bar()
	_setup_selection_ring()
	print(name, " ready at ", global_position)

func _setup_health_bar() -> void:
	if HEALTH_BAR_SCENE == null:
		return
	health_bar = HEALTH_BAR_SCENE.instantiate() as HealthBar3D
	if health_bar == null:
		return
	add_child(health_bar)
	health_bar.position = Vector3(0.0, health_bar_height, 0.0)
	health_bar.set_health(health, max_health)

func _setup_selection_ring() -> void:
	_selection_ring = MeshInstance3D.new()
	_selection_ring.name = "SelectionRing"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.55
	torus.outer_radius = 0.72
	torus.rings = 12
	torus.ring_segments = 24
	_selection_ring.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 1.0, 0.3, 0.85)
	mat.emission_enabled = true
	mat.emission = Color(0.15, 0.9, 0.25)
	mat.emission_energy_multiplier = 1.2
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_selection_ring.material_override = mat
	_selection_ring.position = Vector3(0.0, 0.05, 0.0)
	_selection_ring.visible = false
	add_child(_selection_ring)

func _physics_process(delta: float) -> void:
	if unit_state == UnitState.DEAD: return
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	match unit_state:
		UnitState.MOVING: update_moving(delta)
		UnitState.HARVESTING: update_harvesting(delta)
		UnitState.RETURNING: update_return(delta)
		UnitState.BUILDING: update_building(delta)
		UnitState.REPAIRING: update_repairing(delta)
		UnitState.ATTACKING: update_attacking(delta)
		UnitState.IDLE: _try_idle_acquire(delta)
		_: pass
	move_and_slide()

func update_moving(delta: float) -> void:
	if movement == null: return
	movement.update(delta)
	# M26: kite — fire at retained target while pathing (HA only).
	if can_shoot_while_moving and attack_target != null and is_instance_valid(attack_target):
		if attack_target.unit_state != UnitState.DEAD and combat != null:
			combat.update(delta)
			if combat.status == CombatComponent.Status.TARGET_DEAD or combat.status == CombatComponent.Status.TARGET_LOST:
				attack_target = null
	match movement.status:
		MovementComponent.Status.ARRIVED:
			last_move_end_reason = "arrived"
			current_order = Order.none()
			if can_shoot_while_moving and attack_target != null and is_instance_valid(attack_target) and attack_target.unit_state != UnitState.DEAD:
				unit_state = UnitState.ATTACKING
			else:
				unit_state = UnitState.IDLE
		MovementComponent.Status.FAILED:
			last_move_end_reason = "failed"
			current_order = Order.none()
			if can_shoot_while_moving and attack_target != null and is_instance_valid(attack_target) and attack_target.unit_state != UnitState.DEAD:
				unit_state = UnitState.ATTACKING
			else:
				unit_state = UnitState.IDLE
		_: pass

func update_harvesting(delta: float) -> void:
	harvest.update(delta)
	match harvest.status:
		HarvestComponent.Status.BAG_FULL:
			if movement: movement.cancel()
			return_target = null
			unit_state = UnitState.RETURNING
		HarvestComponent.Status.RESOURCE_GONE:
			if movement: movement.cancel()
			harvest_target = null
			current_order = Order.none()
			velocity = Vector3.ZERO
			unit_state = UnitState.IDLE
		HarvestComponent.Status.MOVING_TO_RESOURCE:
			var stand: Vector3 = harvest.approach_pos
			if stand == Vector3.ZERO and harvest_target != null:
				stand = harvest.get_approach_position(harvest_target)
			movement.ensure_moving_to(stand, APPROACH_RETARGET_DIST)
			movement.update(delta)
		HarvestComponent.Status.GATHERING:
			if movement and movement.status == MovementComponent.Status.MOVING:
				movement.cancel()
			velocity = Vector3.ZERO
		_: pass

func update_attacking(delta: float) -> void:
	if current_order.type == Order.Type.ATTACK_BUILDING or attack_building_target != null:
		update_attacking_building(delta)
		return
	combat.update(delta)
	match combat.status:
		CombatComponent.Status.TARGET_LOST, CombatComponent.Status.TARGET_DEAD:
			attack_target = null
			current_order = Order.none()
			velocity = Vector3.ZERO
			unit_state = UnitState.IDLE
			_try_reacquire_after_kill()
		_: pass


func _try_reacquire_after_kill() -> void:
	if unit_state != UnitState.IDLE:
		return
	var enemy := _find_nearest_acquire_target()
	if enemy == null:
		return
	replace_order_attack(enemy)
	if OS.is_debug_build():
		print(name, " REACQUIRE -> ", enemy.name)


func update_attacking_building(delta: float) -> void:
	var building := attack_building_target
	if building == null or not is_instance_valid(building) or building.is_destroyed or building.health <= 0:
		_clear_building_attack()
		return
	var to_b := building.global_position - global_position
	to_b.y = 0.0
	var dist := to_b.length()
	var exit_range: float = building_attack_range * building_exit_range_mult
	var moved := global_position.distance_to(_siege_last_pos)
	_siege_last_pos = global_position
	if moved < 0.03: _siege_stuck_time += delta
	else: _siege_stuck_time = 0.0
	if _siege_in_range:
		if dist > exit_range: _siege_in_range = false
		else:
			_siege_hold_and_strike(delta, building)
			return
	var in_range := dist <= building_attack_range
	if not in_range and _siege_stuck_time > 0.8 and dist <= building_attack_range + 1.5:
		in_range = true
	if in_range:
		_siege_in_range = true
		_siege_hold_and_strike(delta, building)
		return
	var approach := building.global_position
	if to_b.length() > 0.1:
		approach = building.global_position - to_b.normalized() * (building_attack_range * 0.7)
	approach.y = 0.0
	movement.ensure_moving_to(approach, APPROACH_RETARGET_DIST)
	movement.update(delta)

func _siege_hold_and_strike(delta: float, building: BaseBuilding) -> void:
	if movement and movement.status == MovementComponent.Status.MOVING: movement.cancel()
	velocity = Vector3.ZERO
	_building_attack_timer -= delta
	if _building_attack_timer > 0.0: return
	_building_attack_timer = attack_cooldown
	var dt: int = int(damage_type)
	if dt == int(DamageType.Type.SIEGE) or dt == int(DamageType.Type.RANGED):
		var is_stone: bool = dt == int(DamageType.Type.SIEGE)
		Projectile.fire(self, building, attack_damage, self, is_stone)
		return
	if building.has_method("damage"):
		building.damage(attack_damage, team_id)
	elif building.has_method("apply_damage"):
		building.apply_damage(attack_damage, self)
	elif building.has_method("take_damage"):
		building.take_damage(attack_damage, self)

func _clear_building_attack() -> void:
	attack_building_target = null
	_siege_in_range = false
	_siege_stuck_time = 0.0
	current_order = Order.none()
	velocity = Vector3.ZERO
	unit_state = UnitState.IDLE

func update_return(delta: float) -> void:
	if return_target == null or not is_instance_valid(return_target):
		return_target = _find_nearest_tc()
	if return_target == null:
		unit_state = UnitState.IDLE
		return
	var dest := return_target.global_position
	dest.y = 0.0
	movement.ensure_moving_to(dest, APPROACH_RETARGET_DIST)
	movement.update(delta)
	if global_position.distance_to(dest) <= deposit_distance:
		if inventory:
			inventory.deposit_all(return_target)
		return_target = null
		if harvest_target != null and is_instance_valid(harvest_target):
			unit_state = UnitState.HARVESTING
		else:
			unit_state = UnitState.IDLE

func _find_nearest_tc() -> Node3D:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null: return null
	var best: Node3D = null
	var best_d := INF
	for tc in bm.town_centers:
		if tc == null or not is_instance_valid(tc): continue
		if int(tc.get("team_id")) != team_id: continue
		if tc.get("is_destroyed") == true: continue
		if tc.get("is_constructed") == false: continue
		if tc.get("deployment_state") != null and int(tc.deployment_state) != 0: continue
		var d := global_position.distance_to(tc.global_position)
		if d < best_d:
			best_d = d
			best = tc
	return best

func _try_idle_acquire(delta: float) -> void:
	_acquire_timer -= delta
	if _acquire_timer > 0.0: return
	_acquire_timer = ACQUIRE_SCAN_INTERVAL
	var enemy := _find_nearest_acquire_target()
	if enemy == null: return
	replace_order_attack(enemy)
	if OS.is_debug_build():
		print(name, " ACQUIRE -> ", enemy.name)

func _find_nearest_acquire_target() -> BaseUnit:
	var um := get_node_or_null("/root/UnitManager")
	if um == null or not ("units" in um): return null
	var best: BaseUnit = null
	var best_d := ACQUIRE_RADIUS
	for u in um.units:
		if u == null or not is_instance_valid(u): continue
		if not (u is BaseUnit): continue
		var other := u as BaseUnit
		if other == self: continue
		if other.team_id == team_id: continue
		if other.unit_state == UnitState.DEAD: continue
		if other.has_method("is_dead") and other.is_dead(): continue
		var d := global_position.distance_to(other.global_position)
		if d <= best_d:
			best_d = d
			best = other
	return best

func take_damage(amount: int, source = null) -> void:
	if unit_state == UnitState.DEAD: return
	health = max(health - amount, 0)
	if health_bar: health_bar.set_health(health, max_health)
	if health <= 0:
		_die()
		return
	# M13 retaliation: only from IDLE
	if unit_state != UnitState.IDLE: return
	if source == null or not is_instance_valid(source): return
	if not (source is BaseUnit): return
	var attacker := source as BaseUnit
	if attacker.team_id == team_id: return
	if attacker.unit_state == UnitState.DEAD: return
	if unit_state == UnitState.ATTACKING and attack_target == attacker:
		return
	replace_order_attack(attacker)
	if OS.is_debug_build():
		print(name, " RETALIATE -> ", attacker.name)

func _die() -> void:
	unit_state = UnitState.DEAD
	velocity = Vector3.ZERO
	if movement: movement.cancel()
	print(name, " died")
	UnitManager.unregister_unit(self)
	queue_free()

func set_selected(value: bool) -> void:
	selected = value
	if _selection_ring != null and is_instance_valid(_selection_ring):
		_selection_ring.visible = value

func replace_order_move(pos: Vector3) -> void:
	current_order = Order.new(Order.Type.MOVE, null, {"pos": pos})
	move_target = pos
	harvest_target = null
	build_target = null
	repair_target = null
	# M26: Horse Archer keeps combat target while kiting away.
	var keep_atk: BaseUnit = null
	if can_shoot_while_moving and attack_target != null and is_instance_valid(attack_target):
		if attack_target.unit_state != UnitState.DEAD:
			keep_atk = attack_target
	attack_target = keep_atk
	attack_building_target = null
	return_target = null
	_build_stuck_time = 0.0
	if harvest: harvest.reset()
	if movement: movement.set_target(pos)
	unit_state = UnitState.MOVING

func replace_order_harvest(resource: BaseResource) -> void:
	if not can_gather: return
	if resource == null or not is_instance_valid(resource): return
	current_order = Order.new(Order.Type.HARVEST, resource)
	harvest_target = resource
	build_target = null
	repair_target = null
	attack_target = null
	attack_building_target = null
	return_target = null
	_build_stuck_time = 0.0
	if harvest: harvest.reset()
	unit_state = UnitState.HARVESTING

func replace_order_attack(enemy: BaseUnit) -> void:
	if enemy == null or not is_instance_valid(enemy): return
	current_order = Order.new(Order.Type.ATTACK, enemy)
	attack_target = enemy
	attack_building_target = null
	harvest_target = null
	build_target = null
	repair_target = null
	return_target = null
	_build_stuck_time = 0.0
	if harvest: harvest.reset()
	unit_state = UnitState.ATTACKING

func replace_order_attack_building(building: BaseBuilding) -> void:
	if building == null or not is_instance_valid(building): return
	current_order = Order.new(Order.Type.ATTACK_BUILDING, building)
	attack_building_target = building
	attack_target = null
	harvest_target = null
	build_target = null
	repair_target = null
	return_target = null
	_build_stuck_time = 0.0
	_siege_in_range = false
	_siege_stuck_time = 0.0
	_siege_last_pos = global_position
	_building_attack_timer = 0.0
	if harvest: harvest.reset()
	unit_state = UnitState.ATTACKING

func replace_order_build(building: BaseBuilding) -> void:
	if building == null or not is_instance_valid(building): return
	current_order = Order.new(Order.Type.BUILD, building)
	build_target = building
	repair_target = null
	harvest_target = null
	attack_target = null
	attack_building_target = null
	return_target = null
	_build_stuck_time = 0.0
	_build_last_pos = global_position
	if harvest: harvest.reset()
	unit_state = UnitState.BUILDING

func replace_order_repair(building: BaseBuilding) -> void:
	if building == null or not is_instance_valid(building): return
	current_order = Order.new(Order.Type.REPAIR, building)
	repair_target = building
	build_target = null
	harvest_target = null
	attack_target = null
	attack_building_target = null
	return_target = null
	_build_stuck_time = 0.0
	if harvest: harvest.reset()
	unit_state = UnitState.REPAIRING

func is_dead() -> bool:
	return unit_state == UnitState.DEAD

func update_building(delta: float) -> void:
	if build_target == null or not is_instance_valid(build_target):
		build_target = null
		unit_state = UnitState.IDLE
		return
	if build_target.get("is_constructed") == true:
		build_target = null
		unit_state = UnitState.IDLE
		return
	var dest := build_target.global_position
	dest.y = 0.0
	var dist := global_position.distance_to(dest)
	if dist > BUILD_STAND_DIST + BUILD_FOOTPRINT_MARGIN:
		movement.ensure_moving_to(dest, APPROACH_RETARGET_DIST)
		movement.update(delta)
		var moved := global_position.distance_to(_build_last_pos)
		_build_last_pos = global_position
		if moved < 0.03: _build_stuck_time += delta
		else: _build_stuck_time = 0.0
		return
	if movement and movement.status == MovementComponent.Status.MOVING: movement.cancel()
	velocity = Vector3.ZERO
	if build_target.has_method("request_build_tick"):
		build_target.request_build_tick(self, delta)
	elif build_target.has_method("add_construction_progress"):
		build_target.add_construction_progress(delta)

func update_repairing(delta: float) -> void:
	if repair_target == null or not is_instance_valid(repair_target):
		repair_target = null
		unit_state = UnitState.IDLE
		return
	if repair_target.get("is_destroyed") == true:
		repair_target = null
		unit_state = UnitState.IDLE
		return
	var max_hp: int = int(repair_target.get("max_health") if repair_target.get("max_health") != null else 100)
	var hp: int = int(repair_target.get("health") if repair_target.get("health") != null else max_hp)
	if hp >= max_hp:
		repair_target = null
		unit_state = UnitState.IDLE
		return
	var dest := repair_target.global_position
	dest.y = 0.0
	var dist := global_position.distance_to(dest)
	if dist > BUILD_STAND_DIST + BUILD_FOOTPRINT_MARGIN:
		movement.ensure_moving_to(dest, APPROACH_RETARGET_DIST)
		movement.update(delta)
		return
	if movement and movement.status == MovementComponent.Status.MOVING: movement.cancel()
	velocity = Vector3.ZERO
	if repair_target.has_method("request_repair_tick"):
		repair_target.request_repair_tick(self, delta)
