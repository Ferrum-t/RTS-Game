extends CharacterBody3D

class_name BaseUnit


enum UnitState
{
	IDLE,
	MOVING,
	HARVESTING,
	RETURNING,
	BUILDING,
	ATTACKING,
	DEAD
}


@export var team_id: int = 0
@export var move_speed := 4.0
@export var max_health := 100
@export var deposit_distance := 3.5
@export var attack_damage := 10
@export var attack_range := 2.0
@export var attack_cooldown := 1.0
@export var building_attack_range := 6.5
## Exit building attack only past this multiple of building_attack_range (hysteresis).
@export var building_exit_range_mult := 1.2
@export var health_bar_height := 1.6
## Phase 5: Cavalry sets false — cannot take HARVEST orders
@export var can_gather: bool = true
## Phase 6: building damage modifier class
@export var damage_type: int = DamageType.Type.MELEE

var health := 100

var selected := false

var unit_state : UnitState = UnitState.IDLE
## M8.1: intent as Order object (execution still uses target fields below)
var current_order: Order = Order.none()

var move_target : Vector3

var harvest_target : BaseResource = null
var build_target : BaseBuilding = null
var attack_target : BaseUnit = null
var attack_building_target : BaseBuilding = null

var return_target : Node3D = null

var movement : MovementComponent
var inventory : InventoryComponent
var harvest : HarvestComponent
var combat : CombatComponent
var health_bar: HealthBar3D = null
var nav_agent: NavigationAgent3D = null

var last_move_end_reason: String = ""
var _building_attack_timer: float = 0.0
var _siege_stuck_time: float = 0.0
var _siege_last_pos: Vector3 = Vector3.ZERO
## Polish: locked in building strike range (hysteresis).
var _siege_in_range: bool = false

const GRAVITY := 30.0
const HEALTH_BAR_SCENE := preload("res://Scenes/UI/HealthBar3D.tscn")
## M6.3: only rebuild path when approach point drifts this far
const APPROACH_RETARGET_DIST := 0.9


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


func _physics_process(delta: float) -> void:
	if unit_state == UnitState.DEAD:
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	match unit_state:
		UnitState.MOVING:
			update_moving(delta)
		UnitState.HARVESTING:
			update_harvesting(delta)
		UnitState.RETURNING:
			update_return(delta)
		UnitState.ATTACKING:
			update_attacking(delta)
		_:
			pass

	move_and_slide()


func update_moving(delta: float) -> void:
	if movement == null:
		return
	movement.update(delta)
	match movement.status:
		MovementComponent.Status.ARRIVED:
			last_move_end_reason = "arrived"
			current_order = Order.none()
			unit_state = UnitState.IDLE
		MovementComponent.Status.FAILED:
			last_move_end_reason = "failed"
			current_order = Order.none()
			unit_state = UnitState.IDLE
		_:
			pass


func update_harvesting(delta: float) -> void:
	harvest.update(delta)

	match harvest.status:
		HarvestComponent.Status.BAG_FULL:
			if movement:
				movement.cancel()
			return_target = null
			unit_state = UnitState.RETURNING
		HarvestComponent.Status.RESOURCE_GONE:
			if movement:
				movement.cancel()
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
		_:
			pass


func update_attacking(delta: float) -> void:
	if current_order.type == Order.Type.ATTACK_BUILDING or attack_building_target != null:
		update_attacking_building(delta)
		return

	combat.update(delta)

	match combat.status:
		CombatComponent.Status.TARGET_LOST:
			attack_target = null
			current_order = Order.none()
			velocity = Vector3.ZERO
			unit_state = UnitState.IDLE
		CombatComponent.Status.TARGET_DEAD:
			attack_target = null
			current_order = Order.none()
			velocity = Vector3.ZERO
			unit_state = UnitState.IDLE
		_:
			pass


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
	if moved < 0.03:
		_siege_stuck_time += delta
	else:
		_siege_stuck_time = 0.0

	if _siege_in_range:
		if dist > exit_range:
			_siege_in_range = false
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

	# Approach building
	var approach := building.global_position
	if to_b.length() > 0.1:
		approach = building.global_position - to_b.normalized() * (building_attack_range * 0.7)
	approach.y = 0.0
	movement.ensure_moving_to(approach, APPROACH_RETARGET_DIST)
	movement.update(delta)


func _siege_hold_and_strike(delta: float, building: BaseBuilding) -> void:
	if movement and movement.status == MovementComponent.Status.MOVING:
		movement.cancel()
	velocity = Vector3.ZERO
	_building_attack_timer -= delta
	if _building_attack_timer > 0.0:
		return
	_building_attack_timer = attack_cooldown
	if building.has_method("apply_damage"):
		building.apply_damage(attack_damage, self)
	elif building.has_method("take_damage"):
		building.take_damage(attack_damage, self)
	else:
		building.health = maxi(0, building.health - attack_damage)


func _clear_building_attack() -> void:
	attack_building_target = null
	_building_attack_timer = 0.0
	_siege_stuck_time = 0.0
	_siege_in_range = false
	velocity = Vector3.ZERO
	current_order = Order.none()
	unit_state = UnitState.IDLE


func update_return(delta: float) -> void:
	# Drop invalid / enemy / destroyed deposit target
	if return_target != null and is_instance_valid(return_target):
		if return_target.get("is_destroyed") == true:
			return_target = null
		elif return_target.get("health") != null and int(return_target.health) <= 0:
			return_target = null
		elif return_target.get("team_id") != null and int(return_target.team_id) != team_id:
			return_target = null
	else:
		return_target = null

	if return_target == null:
		var bm := get_node_or_null("/root/BuildingManager")
		if bm:
			return_target = bm.get_nearest_town_center(global_position, team_id)

		if return_target == null:
			print(name, " — no own-team Town Center found, keeping inventory")
			unit_state = UnitState.IDLE
			velocity = Vector3.ZERO
			return

	var distance := global_position.distance_to(return_target.global_position)

	if distance > deposit_distance:
		var to_tc := return_target.global_position - global_position
		to_tc.y = 0.0
		var approach := return_target.global_position
		if to_tc.length() > 0.1:
			approach = return_target.global_position - to_tc.normalized() * 0.5
		approach.y = 0.0
		movement.ensure_moving_to(approach, APPROACH_RETARGET_DIST)
		movement.update(delta)
		return

	velocity = Vector3.ZERO
	var deposited_wood: int = inventory.wood
	var deposited_stone: int = inventory.stone
	var deposited_gold: int = inventory.gold
	var deposited_food: int = inventory.food
	var deposited_horses: int = inventory.horses

	inventory.clear()

	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.add_wood(deposited_wood, team_id)
		rm.add_stone(deposited_stone, team_id)
		rm.add_gold(deposited_gold, team_id)
		rm.add_food(deposited_food, team_id)
		rm.add_horses(deposited_horses, team_id)

	print(
		name,
		" deposited W:", deposited_wood,
		" S:", deposited_stone,
		" H:", deposited_horses,
		" at ", return_target.name
	)

	return_target = null

	if harvest_target != null and is_instance_valid(harvest_target):
		if harvest:
			harvest.reset()
		if movement:
			movement.cancel()
		unit_state = UnitState.HARVESTING
	else:
		current_order = Order.none()
		unit_state = UnitState.IDLE


func take_damage(amount: int, _source: Node = null) -> void:
	if unit_state == UnitState.DEAD:
		return
	health = maxi(0, health - amount)
	if health_bar:
		health_bar.set_health(health, max_health)
	if health <= 0:
		die()


func die() -> void:
	unit_state = UnitState.DEAD
	current_order = Order.none()
	velocity = Vector3.ZERO
	if movement:
		movement.cancel()
	print(name, " died")
	UnitManager.unregister_unit(self)
	queue_free()


func set_selected(value: bool) -> void:
	selected = value


func replace_order_move(pos: Vector3) -> void:
	current_order = Order.move_to(pos)
	move_target = pos
	harvest_target = null
	attack_target = null
	attack_building_target = null
	return_target = null
	if harvest:
		harvest.reset()
	if movement:
		movement.move_to(pos)
	unit_state = UnitState.MOVING


func replace_order_harvest(resource: BaseResource) -> void:
	if not can_gather:
		return
	if resource == null or not is_instance_valid(resource):
		return
	current_order = Order.harvest(resource)
	harvest_target = resource
	attack_target = null
	attack_building_target = null
	return_target = null
	if harvest:
		harvest.reset()
	unit_state = UnitState.HARVESTING


func replace_order_attack(enemy: BaseUnit) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	current_order = Order.attack_unit(enemy)
	attack_target = enemy
	attack_building_target = null
	harvest_target = null
	return_target = null
	if harvest:
		harvest.reset()
	unit_state = UnitState.ATTACKING


func replace_order_attack_building(building: BaseBuilding) -> void:
	if building == null or not is_instance_valid(building):
		return
	current_order = Order.attack_building(building)
	attack_building_target = building
	attack_target = null
	harvest_target = null
	return_target = null
	_siege_in_range = false
	_siege_stuck_time = 0.0
	_siege_last_pos = global_position
	_building_attack_timer = 0.0
	if harvest:
		harvest.reset()
	unit_state = UnitState.ATTACKING
