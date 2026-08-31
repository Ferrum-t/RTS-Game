extends MobileBuilding

class_name TownCenter

## Economy hub. Trains Workers only while DEPLOYED.
## Phase 8.2: DeploymentConfig preset_town_center().

@export var worker_scene: PackedScene
@export var worker_cost_wood: int = 50
@export var worker_train_time: float = 3.0
@export var spawn_offset: Vector3 = Vector3(3.0, 0.0, 0.0)

var is_training: bool = false
var train_timer: float = 0.0
var _pending_scene: PackedScene = null


func _ready() -> void:
	is_lootable = true
	loot_ratio = 0.5
	if deployment_config == null:
		deployment_config = DeploymentConfig.preset_town_center()
	super()
	add_to_group("Obstacle")
	if worker_scene == null:
		worker_scene = load("res://Scenes/Units/worker.tscn") as PackedScene
	print("TownCenter ready at: ", global_position, " deployment=", deployment_state,
		" pack=", pack_time, "s vuln=", vulnerability_multiplier)
	if DebugFlags.BUILDING_HOTKEYS and OS.is_debug_build() and team_id == 0:
		print("TownCenter debug keys: P=pack  M=move(8,0,5)  U=unpack")


func _process(delta: float) -> void:
	if not is_training:
		return
	train_timer -= delta
	if train_timer <= 0.0:
		_finish_training()


func _unhandled_input(event: InputEvent) -> void:
	if not DebugFlags.BUILDING_HOTKEYS:
		return
	if not OS.is_debug_build():
		return
	if team_id != 0:
		return
	if is_destroyed:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key := event as InputEventKey
	match key.keycode:
		KEY_P:
			debug_pack()
			get_viewport().set_input_as_handled()
		KEY_M:
			debug_move(Vector3(8.0, 0.0, 5.0))
			get_viewport().set_input_as_handled()
		KEY_U:
			debug_unpack()
			get_viewport().set_input_as_handled()


func try_train_worker() -> bool:
	if not is_deployed():
		print("TownCenter: train only while DEPLOYED (state=", deployment_state, ")")
		return false

	if is_training:
		print("TownCenter: already training Worker")
		return false

	if worker_scene == null:
		push_error("TownCenter: worker_scene is null")
		return false

	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return false

	var cost: Dictionary = ResourceManager.make_cost(worker_cost_wood)
	if not rm.spend(cost, team_id):
		print("TownCenter: not enough wood for Worker (need ", worker_cost_wood, ") team=", team_id)
		return false

	is_training = true
	train_timer = worker_train_time
	_pending_scene = worker_scene
	print("TownCenter: training Worker... (", worker_train_time, "s, cost ", worker_cost_wood, " wood)")
	return true


func _finish_training() -> void:
	is_training = false
	train_timer = 0.0

	if _pending_scene == null:
		return

	var unit := _pending_scene.instantiate()
	var units_parent := get_tree().current_scene.get_node_or_null("Units")
	if units_parent == null:
		units_parent = get_tree().current_scene

	units_parent.add_child(unit)
	if unit is BaseUnit:
		(unit as BaseUnit).team_id = team_id
	unit.global_position = next_spawn_position()

	print("TownCenter: Worker trained team=", team_id, " at ", unit.global_position)
	_pending_scene = null


func debug_pack() -> void:
	request_pack()


func debug_move(world_pos: Vector3) -> void:
	request_move_to(world_pos)


func debug_unpack() -> void:
	request_unpack()
