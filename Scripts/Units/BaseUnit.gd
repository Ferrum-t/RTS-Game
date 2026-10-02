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

func _setup_selection_ring() -> void:
	_selection_ring = MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 0.55
	ring.outer_radius = 0.7
	ring.rings = 12
	ring.ring_segments = 24
	_selection_ring.mesh = ring
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.9, 0.3, 0.85)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_selection_ring.material_override = mat
	_selection_ring.position = Vector3(0, 0.05, 0)
	_selection_ring.visible = false
	add_child(_selection_ring)

func _physics_process(delta: float) -> void:
	if unit_state == UnitState.DEAD:
		velocity = Vector3.ZERO
		return
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	match unit_state:
		UnitState.IDLE:
			update_idle(delta)
		UnitState.MOVING: update_moving(delta)
		UnitState.HARVESTING: update_harvesting(delta)
		UnitState.RETURNING: update_returning(delta)
		UnitState.BUILDING: update_building(delta)
		UnitState.REPAIRING: update_repairing(delta)
		UnitState.ATTACKING: update_attacking(delta)
		_: pass
	move_and_slide()

func update_idle(delta: float) -> void:
	velocity = Vector3.ZERO
	_acquire_timer -= delta
	if _acquire_timer <= 0.0:
		_acquire_timer = ACQUIRE_SCAN_INTERVAL
		_try_auto_acquire()

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
