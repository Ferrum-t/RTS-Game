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

var health := 100

var selected := false

var unit_state : UnitState = UnitState.IDLE

var move_target : Vector3

var harvest_target : BaseResource = null
var build_target : BaseBuilding = null
var attack_target : BaseUnit = null


var movement : MovementComponent
var inventory : InventoryComponent
var harvest : HarvestComponent


func _ready():

	health = max_health

	add_to_group("Unit")

	UnitManager.register_unit(self)

	movement = MovementComponent.new(self)
	inventory = InventoryComponent.new(self)
	harvest = HarvestComponent.new(self)


func _exit_tree():

	UnitManager.unregister_unit(self)


func _physics_process(delta):

	match unit_state:

		UnitState.IDLE:
			update_idle(delta)

		UnitState.MOVING:
			movement.update(delta)

		UnitState.HARVESTING:
			harvest.update(delta)

		UnitState.RETURNING:
			update_return(delta)

		UnitState.BUILDING:
			update_build(delta)

		UnitState.ATTACKING:
			update_attack(delta)

		UnitState.DEAD:
			pass


func update_idle(_delta):

	velocity = Vector3.ZERO


func update_return(_delta):

	pass


func update_build(_delta):

	pass


func update_attack(_delta):

	pass


func set_move_target(target: Vector3):

	move_target = target
	unit_state = UnitState.MOVING


func set_harvest_target(resource: BaseResource):

	harvest_target = resource
	unit_state = UnitState.HARVESTING


func set_build_target(building: BaseBuilding):

	build_target = building
	unit_state = UnitState.BUILDING


func set_attack_target(enemy: BaseUnit):

	attack_target = enemy
	unit_state = UnitState.ATTACKING


func select():

	selected = true
	print(name, " selected")


func deselect():

	selected = false
	print(name, " deselected")


func damage(amount: int):

	health -= amount

	if health <= 0:
		die()


func die():

	unit_state = UnitState.DEAD
	queue_free()
