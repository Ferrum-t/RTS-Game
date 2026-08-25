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
@export var health_bar_height := 1.6
## Phase 5: Cavalry sets false — cannot take HARVEST orders
@export var can_gather: bool = true

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
	health_bar = HEALTH_BAR_SCENE.instantiate() as HealthBar3D
	add_child(health_bar)
	health_bar.position = Vector3(0.0, health_bar_height, 0.0)
	health_bar.setup(max_health)


func _exit_tree() -> void:
	UnitManager.unregister_unit(self)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	match unit_state:
		UnitState.IDLE:
			update_idle(delta)
		UnitState.MOVING:
			update_moving(delta)
		UnitState.HARVESTING:
			update_harvesting(delta)
		UnitState.RETURNING:
			update_return(delta)
		UnitState.BUILDING:
			update_build(delta)
		UnitState.ATTACKING:
			update_attacking(delta)
		UnitState.DEAD:
			pass

	if global_position.y < 0.0:
		global_position.y = 0.0
		velocity.y = 0.0


func update_idle(_delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	move_and_slide()


func update_moving(delta: float) -> void:
	movement.update(delta)

	match movement.status:
		MovementComponent.Status.ARRIVED:
			last_move_end_reason = "ARRIVED"
			current_order = Order.none()
			unit_state = UnitState.IDLE
		MovementComponent.Status.BLOCKED:
			last_move_end_reason = "BLOCKED"
			current_order = Order.none()
			unit_state = UnitState.IDLE
		MovementComponent.Status.FAILED:
			last_move_end_reason = "FAILED"
			current_order = Order.none()
			unit_state = UnitState.IDLE
		MovementComponent.Status.CANCELLED:
			last_move_end_reason = "CANCELLED"
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

	var moved := global_position.distance_to(_siege_last_pos)
	_siege_last_pos = global_position
	if moved < 0.03:
		_siege_stuck_time += delta
	else:
		_siege_stuck_time = 0.0

	var in_range := dist <= building_attack_range
	if not in_range and dist <= building_attack_range + 2.5 and _siege_stuck_time >= 0.35:
		in_range = true

	if not in_range:
		var stand := maxf(building_attack_range * 0.9, 5.0)
		var approach := building.global_position
		if to_b.length() > 0.1:
			approach = building.global_position - to_b.normalized() * stand
		approach.y = 0.0
		movement.ensure_moving_to(approach, APPROACH_RETARGET_DIST)
		movement.update(delta)
		return

	if movement:
		movement.cancel()
	velocity = Vector3.ZERO
	_siege_stuck_time = 0.0

	_building_attack_timer -= delta
	if _building_attack_timer > 0.0:
		return
	_building_attack_timer = attack_cooldown

	print(name, " hits building ", building.name, " for ", attack_damage, " dmg (HP ", max(building.health - attack_damage, 0), "/", building.max_health, ")")
	building.damage(attack_damage)

	if not is_instance_valid(building) or building.is_destroyed or building.health <= 0:
		_clear_building_attack()


func _clear_building_attack() -> void:
	attack_building_target = null
	_building_attack_timer = 0.0
	_siege_stuck_time = 0.0
	velocity = Vector3.ZERO
	current_order = Order.none()
	unit_state = UnitState.IDLE


func update_return(delta: float) -> void:
	if return_target == null or not is_instance_valid(return_target):
		var bm := get_node_or_null("/root/BuildingManager")
		if bm:
			return_target = bm.get_nearest_town_center(global_position)

		if return_target == null:
			print(name, " — no Town Center found, staying with full inventory")
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
		rm.add_wood(deposited_wood)
		rm.add_stone(deposited_stone)
		rm.add_gold(deposited_gold)
		rm.add_food(deposited_food)
		rm.add_horses(deposited_horses)

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


func update_build(_delta: float) -> void:
	pass


## M8.1 — single dispatch entry for player/AI intent.
func replace_order(order: Order) -> void:
	if order == null:
		order = Order.none()

	match order.type:
		Order.Type.NONE:
			current_order = Order.none()
		Order.Type.MOVE:
			var dest: Vector3 = order.target as Vector3
			current_order = order
			set_move_target(dest)
		Order.Type.HARVEST:
			var resource: BaseResource = order.target as BaseResource
			if resource == null or not is_instance_valid(resource):
				return
			if not can_gather:
				return
			if not TeamRules.can_harvest(self, resource):
				return
			current_order = order
			set_harvest_target(resource)
		Order.Type.ATTACK:
			var enemy: BaseUnit = order.target as BaseUnit
			if not TeamRules.can_attack(self, enemy):
				return
			current_order = order
			set_attack_target(enemy)
		Order.Type.ATTACK_BUILDING:
			var building: BaseBuilding = order.target as BaseBuilding
			var ok := TeamRules.can_attack_building(self, building)
			if not ok:
				return
			current_order = order
			set_attack_building_target(building)
		Order.Type.BUILD:
			var b: BaseBuilding = order.target as BaseBuilding
			if b == null or not is_instance_valid(b):
				return
			current_order = order
			set_build_target(b)


func replace_order_move(destination: Vector3) -> void:
	replace_order(Order.new(Order.Type.MOVE, destination))


func replace_order_harvest(resource: BaseResource) -> void:
	replace_order(Order.new(Order.Type.HARVEST, resource))


func replace_order_attack(enemy: BaseUnit) -> void:
	replace_order(Order.new(Order.Type.ATTACK, enemy))


func replace_order_attack_building(building: BaseBuilding) -> void:
	replace_order(Order.new(Order.Type.ATTACK_BUILDING, building))


func replace_order_build(building: BaseBuilding) -> void:
	replace_order(Order.new(Order.Type.BUILD, building))


func set_move_target(target: Vector3) -> void:
	move_target = target
	unit_state = UnitState.MOVING
	harvest_target = null
	attack_target = null
	attack_building_target = null
	return_target = null
	_building_attack_timer = 0.0
	_siege_stuck_time = 0.0
	last_move_end_reason = ""
	if harvest:
		harvest.reset()
	if combat:
		combat.reset()
	if movement:
		movement.request_move(target)


func set_harvest_target(resource: BaseResource) -> void:
	if not can_gather:
		return
	harvest_target = resource
	attack_target = null
	attack_building_target = null
	return_target = null
	_building_attack_timer = 0.0
	unit_state = UnitState.HARVESTING
	if combat:
		combat.reset()
	if harvest:
		harvest.reset()
	if movement:
		movement.cancel()


func set_build_target(building: BaseBuilding) -> void:
	build_target = building
	attack_target = null
	attack_building_target = null
	unit_state = UnitState.BUILDING


func set_attack_target(enemy: BaseUnit) -> void:
	if not TeamRules.can_attack(self, enemy):
		return
	attack_target = enemy
	attack_building_target = null
	harvest_target = null
	return_target = null
	_building_attack_timer = 0.0
	unit_state = UnitState.ATTACKING
	if harvest:
		harvest.reset()
	if combat:
		combat.reset()
	print(name, " -> attack ", enemy.name)


func set_attack_building_target(building: BaseBuilding) -> void:
	if not TeamRules.can_attack_building(self, building):
		return
	attack_building_target = building
	attack_target = null
	harvest_target = null
	return_target = null
	_building_attack_timer = 0.0
	_siege_stuck_time = 0.0
	_siege_last_pos = global_position
	unit_state = UnitState.ATTACKING
	if current_order == null or current_order.type != Order.Type.ATTACK_BUILDING:
		current_order = Order.new(Order.Type.ATTACK_BUILDING, building)
	if harvest:
		harvest.reset()
	if combat:
		combat.reset()
	if movement:
		movement.cancel()
	print(name, " -> attack building ", building.name, " (team ", building.team_id, ")")


func select() -> void:
	selected = true
	if has_node("SelectionRing"):
		$SelectionRing.visible = true
	print(name, " selected (HP ", health, "/", max_health, ")")


func deselect() -> void:
	selected = false
	if has_node("SelectionRing"):
		$SelectionRing.visible = false
	print(name, " deselected")


func damage(amount: int) -> void:
	if unit_state == UnitState.DEAD:
		return
	health -= amount
	if health_bar:
		health_bar.set_health(health)
	if health <= 0:
		health = 0
		die()


func die() -> void:
	unit_state = UnitState.DEAD
	current_order = Order.none()
	attack_building_target = null
	if movement:
		movement.cancel()
	if harvest:
		harvest.reset()
	if combat:
		combat.reset()
	print(name, " died")
	queue_free()
