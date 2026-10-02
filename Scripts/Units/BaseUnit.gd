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
	if HEALTH_BAR_SCENE == null: return
	health_bar = HEALTH_BAR_SCENE.instantiate() as HealthBar3D
	if health_bar == null: return
	add_child(health_bar)
	health_bar.position = Vector3(0.0, health_bar_height, 0.0)
	health_bar.setup(max_health)
	health_bar.set_health(health)
