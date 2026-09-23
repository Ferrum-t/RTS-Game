extends MobileBuilding

class_name TownCenter

## Economy hub. Trains Workers only while DEPLOYED.
## M19.1: queue max 5, spend on enqueue, cancel last/all refund.

const MAX_TRAIN_QUEUE := 5

@export var worker_scene: PackedScene
@export var worker_cost_wood: int = 50
@export var worker_train_time: float = 3.0

var is_training: bool = false
var train_timer: float = 0.0
var train_time_total: float = 0.0
var _pending_scene: PackedScene = null
var _pending_label: String = ""
var _pending_cost_wood: int = 0
## Waiting entries after current: {scene, time, label, cost_wood}
var _train_queue: Array = []


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


func get_train_pipeline_count() -> int:
	return (1 if is_training else 0) + _train_queue.size()


func get_train_progress() -> float:
	if not is_training or train_time_total <= 0.0:
		return 0.0
	return clampf(1.0 - (train_timer / train_time_total), 0.0, 1.0)


func get_queue_labels() -> Array:
	var out: Array = []
	if is_training and _pending_label != "":
		out.append(_pending_label)
	for e in _train_queue:
		out.append(str(e.get("label", "?")))
	return out


func try_train_worker() -> bool:
	if not is_constructed:
		print("TownCenter: still under construction")
		return false

	if not is_deployed():
		print("TownCenter: train only while DEPLOYED (state=", deployment_state, ")")
		return false

	if worker_scene == null:
		push_error("TownCenter: worker_scene is null")
		return false

	if get_train_pipeline_count() >= MAX_TRAIN_QUEUE:
		print("TownCenter: train queue full (", MAX_TRAIN_QUEUE, ")")
		return false

	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return false

	var cost: Dictionary = ResourceManager.make_cost(worker_cost_wood)
	if not rm.spend(cost, team_id):
		print("TownCenter: not enough wood for Worker (need ", worker_cost_wood, ") team=", team_id)
		return false

	if not is_training:
		_start_train(worker_scene, worker_train_time, "Worker", worker_cost_wood)
		print("TownCenter: training Worker... (", worker_train_time, "s, cost ", worker_cost_wood, " wood)")
	else:
		_train_queue.append({
			"scene": worker_scene,
			"time": worker_train_time,
			"label": "Worker",
			"cost_wood": worker_cost_wood,
		})
		print("TownCenter: queued Worker (queue=", _train_queue.size(), " pipeline=", get_train_pipeline_count(), ")")
	return true


func cancel_train_last() -> bool:
	if not _train_queue.is_empty():
		var e: Dictionary = _train_queue.pop_back()
		_refund_wood(int(e.get("cost_wood", 0)))
		print("TownCenter: cancel last queued Worker refund=", e.get("cost_wood", 0))
		return true
	if is_training:
		_refund_wood(_pending_cost_wood)
		print("TownCenter: cancel current Worker refund=", _pending_cost_wood)
		_clear_active_train()
		_start_next_from_queue()
		return true
	return false


func cancel_train_all() -> bool:
	var any := false
	while not _train_queue.is_empty():
		var e: Dictionary = _train_queue.pop_back()
		_refund_wood(int(e.get("cost_wood", 0)))
		any = true
	if is_training:
		_refund_wood(_pending_cost_wood)
		_clear_active_train()
		any = true
	if any:
		print("TownCenter: cancel all training")
	return any


func _start_train(scene: PackedScene, t: float, label: String, cost_wood: int) -> void:
	is_training = true
	train_time_total = t
	train_timer = t
	_pending_scene = scene
	_pending_label = label
	_pending_cost_wood = cost_wood


func _clear_active_train() -> void:
	is_training = false
	train_timer = 0.0
	train_time_total = 0.0
	_pending_scene = null
	_pending_label = ""
	_pending_cost_wood = 0


func _start_next_from_queue() -> void:
	if _train_queue.is_empty():
		return
	var e: Dictionary = _train_queue.pop_front()
	_start_train(
		e.get("scene") as PackedScene,
		float(e.get("time", worker_train_time)),
		str(e.get("label", "Worker")),
		int(e.get("cost_wood", worker_cost_wood))
	)
	print("TownCenter: starting next from queue → ", _pending_label)


func _refund_wood(amount: int) -> void:
	if amount <= 0:
		return
	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.add_wood(amount, team_id)


func _finish_training() -> void:
	var scene := _pending_scene
	_clear_active_train()

	if scene == null:
		_start_next_from_queue()
		return

	var unit := scene.instantiate()
	var units_parent := get_tree().current_scene.get_node_or_null("Units")
	if units_parent == null:
		units_parent = get_tree().current_scene

	units_parent.add_child(unit)
	var door := get_door_position()
	unit.global_position = door

	var dest := next_rally_destination()
	if unit is BaseUnit:
		var bu := unit as BaseUnit
		bu.team_id = team_id
		bu.replace_order_move(dest)

	print("TownCenter: Worker trained team=", team_id, " door=", door, " → slot ", dest)
	_start_next_from_queue()


func debug_pack() -> void:
	request_pack()


func debug_move(world_pos: Vector3) -> void:
	request_move_to(world_pos)


func debug_unpack() -> void:
	request_unpack()
