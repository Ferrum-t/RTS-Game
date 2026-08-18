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


@export var move_speed := 4.0
@export var max_health := 100
@export var deposit_distance := 3.5
@export var attack_damage := 10
@export var attack_range := 2.0
@export var attack_cooldown := 1.0
@export var health_bar_height := 1.6

var health := 100

var selected := false

var unit_state : UnitState = UnitState.IDLE

var move_target : Vector3

var harvest_target : BaseResource = null
var build_target : BaseBuilding = null
var attack_target : BaseUnit = null

var return_target : Node3D = null

var movement : MovementComponent
var inventory : InventoryComponent
var harvest : HarvestComponent
var combat : CombatComponent
var health_bar: HealthBar3D = null

## M1: why we entered IDLE after a move
var last_move_end_reason: String = ""

const GRAVITY := 30.0
const HEALTH_BAR_SCENE := preload("res://Scenes/UI/HealthBar3D.tscn")


func _ready() -> void:
	health = max_health
	add_to_group("Unit")

	collision_layer = 2
	collision_mask = 1

	var pos := global_position
	pos.y = 0.0
	global_position = pos

	UnitManager.register_unit(self)

	movement = MovementComponent.new(self)
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


## M1: Unit consumes Movement status
func update_moving(delta: float) -> void:
	movement.update(delta)

	match movement.status:
		MovementComponent.Status.ARRIVED:
			last_move_end_reason = "ARRIVED"
			unit_state = UnitState.IDLE
		MovementComponent.Status.BLOCKED:
			last_move_end_reason = "BLOCKED"
			unit_state = UnitState.IDLE
		MovementComponent.Status.FAILED:
			last_move_end_reason = "FAILED"
			unit_state = UnitState.IDLE
		MovementComponent.Status.CANCELLED:
			last_move_end_reason = "CANCELLED"
			unit_state = UnitState.IDLE
		_:
			pass


## M2: Unit consumes Harvest status
func update_harvesting(delta: float) -> void:
	harvest.update(delta)

	match harvest.status:
		HarvestComponent.Status.BAG_FULL:
			return_target = null
			unit_state = UnitState.RETURNING
		HarvestComponent.Status.RESOURCE_GONE:
			harvest_target = null
			velocity = Vector3.ZERO
			unit_state = UnitState.IDLE
		_:
			pass # MOVING_TO_RESOURCE / GATHERING — stay HARVESTING


## M2: Unit consumes Combat status
func update_attacking(delta: float) -> void:
	combat.update(delta)

	match combat.status:
		CombatComponent.Status.TARGET_LOST:
			attack_target = null
			velocity = Vector3.ZERO
			unit_state = UnitState.IDLE
		CombatComponent.Status.TARGET_DEAD:
			attack_target = null
			velocity = Vector3.ZERO
			unit_state = UnitState.IDLE
		_:
			pass # CHASING / IN_RANGE — stay ATTACKING


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
		move_target = approach
		movement.set_target(move_target)
		movement.update(delta)
		return

	velocity = Vector3.ZERO
	var deposited_wood: int = inventory.wood
	var deposited_stone: int = inventory.stone
	var deposited_gold: int = inventory.gold
	var deposited_food: int = inventory.food

	inventory.clear()

	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.add_wood(deposited_wood)
		rm.add_stone(deposited_stone)
		rm.add_gold(deposited_gold)
		rm.add_food(deposited_food)

	print(name, " deposited W:", deposited_wood, " S:", deposited_stone, " at ", return_target.name)

	return_target = null

	if harvest_target != null and is_instance_valid(harvest_target):
		if harvest:
			harvest.reset()
		unit_state = UnitState.HARVESTING
	else:
		unit_state = UnitState.IDLE


func update_build(_delta: float) -> void:
	pass


func set_move_target(target: Vector3) -> void:
	move_target = target
	unit_state = UnitState.MOVING
	harvest_target = null
	attack_target = null
	return_target = null
	last_move_end_reason = ""
	if harvest:
		harvest.reset()
	if combat:
		combat.reset()
	if movement:
		movement.request_move(target)


func set_harvest_target(resource: BaseResource) -> void:
	harvest_target = resource
	attack_target = null
	return_target = null
	unit_state = UnitState.HARVESTING
	if combat:
		combat.reset()
	if harvest:
		harvest.reset()


func set_build_target(building: BaseBuilding) -> void:
	build_target = building
	attack_target = null
	unit_state = UnitState.BUILDING


func set_attack_target(enemy: BaseUnit) -> void:
	if enemy == null or enemy == self:
		return
	attack_target = enemy
	harvest_target = null
	return_target = null
	unit_state = UnitState.ATTACKING
	if harvest:
		harvest.reset()
	if combat:
		combat.reset()
	print(name, " -> attack ", enemy.name)


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
	if movement:
		movement.cancel()
	if harvest:
		harvest.reset()
	if combat:
		combat.reset()
	print(name, " died")
	queue_free()
