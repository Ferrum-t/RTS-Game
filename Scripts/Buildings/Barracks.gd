extends BaseBuilding

class_name Barracks

## Military production. Soldiers + Cavalry + SiegeUnit.
## M19.1: Soldier queue max 5; Cavalry/Siege remain single-slot.
## M21.1: Soldier/Cavalry cost Food; refund on cancel.

const MAX_TRAIN_QUEUE := 5

@export var soldier_scene: PackedScene
@export var soldier_cost_wood: int = 80
@export var soldier_cost_food: int = 2
@export var soldier_train_time: float = 6.5

@export var cavalry_scene: PackedScene
@export var cavalry_cost_wood: int = 100
@export var cavalry_cost_horses: int = 1
@export var cavalry_cost_food: int = 2
@export var cavalry_train_time: float = 6.0

@export var siege_scene: PackedScene
@export var siege_cost_wood: int = 150
@export var siege_cost_stone: int = 50
@export var siege_train_time: float = 8.0

var is_training: bool = false
var train_timer: float = 0.0
var train_time_total: float = 0.0
var _pending_scene: PackedScene = null
var _pending_label: String = ""
var _pending_cost_wood: int = 0
var _pending_cost_food: int = 0
var _pending_cost_stone: int = 0
var _pending_cost_horses: int = 0
var _train_queue: Array = []


func _ready() -> void:
	super()
	add_to_group("Obstacle")
	if soldier_scene == null:
		soldier_scene = load("res://Scenes/Units/soldier.tscn") as PackedScene
	if cavalry_scene == null:
		cavalry_scene = load("res://Scenes/Units/cavalry.tscn") as PackedScene
	if siege_scene == null:
		siege_scene = load("res://Scenes/Units/siege_unit.tscn") as PackedScene
	print("Barracks ready at: ", global_position)
	if DebugFlags.BUILDING_HOTKEYS and OS.is_debug_build() and team_id == 0:
		print("Barracks debug: C=Cavalry  R=Siege (150W+50S)")


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
	if team_id != 0 or is_destroyed:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key := event as InputEventKey
	match key.keycode:
		KEY_C:
			try_train_cavalry()
			get_viewport().set_input_as_handled()
		KEY_R:
			try_train_siege()
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


func try_train_soldier() -> bool:
	if not is_constructed:
		print("Barracks: still under construction")
		return false
	if soldier_scene == null:
		push_error("Barracks: soldier_scene is null")
		return false
	if is_training and _pending_label != "Soldier":
		print("Barracks: busy training ", _pending_label)
		return false
	if get_train_pipeline_count() >= MAX_TRAIN_QUEUE:
		print("Barracks: train queue full (", MAX_TRAIN_QUEUE, ")")
		return false
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return false
	var cost: Dictionary = ResourceManager.make_cost(soldier_cost_wood, 0, 0, soldier_cost_food)
	if not rm.spend(cost, team_id):
		print("Barracks: not enough resources for Soldier (need W:", soldier_cost_wood, " F:", soldier_cost_food, ") team=", team_id)
		return false
	if not is_training:
		_start_train(soldier_scene, soldier_train_time, "Soldier", soldier_cost_wood, 0, 0, soldier_cost_food)
		print("Barracks: training Soldier... (", soldier_train_time, "s, cost ", soldier_cost_wood, " wood + ", soldier_cost_food, " food)")
	else:
		_train_queue.append({
			"scene": soldier_scene,
			"time": soldier_train_time,
			"label": "Soldier",
			"cost_wood": soldier_cost_wood,
			"cost_stone": 0,
			"cost_horses": 0,
			"cost_food": soldier_cost_food,
		})
		print("Barracks: queued Soldier (queue=", _train_queue.size(), " pipeline=", get_train_pipeline_count(), ")")
	return true


func try_train_cavalry() -> bool:
	if not is_constructed:
		print("Barracks: still under construction")
		return false
	if is_training or not _train_queue.is_empty():
		print("Barracks: already training")
		return false
	if cavalry_scene == null:
		push_error("Barracks: cavalry_scene is null")
		return false
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return false
	var cost: Dictionary = ResourceManager.make_cost(
		cavalry_cost_wood, 0, 0, cavalry_cost_food, cavalry_cost_horses
	)
	if not rm.can_afford(cost, team_id):
		print("Barracks: not enough resources for Cavalry (need W:", cavalry_cost_wood, " F:", cavalry_cost_food, " H:", cavalry_cost_horses, ")")
		return false
	if not rm.spend(cost, team_id):
		return false
	_start_train(cavalry_scene, cavalry_train_time, "Cavalry", cavalry_cost_wood, 0, cavalry_cost_horses, cavalry_cost_food)
	print("Barracks: training Cavalry... (", cavalry_train_time, "s, cost ", cavalry_cost_wood, " wood + ", cavalry_cost_food, " food + ", cavalry_cost_horses, " horse)")
	return true


func try_train_siege() -> bool:
	if not is_constructed:
		print("Barracks: still under construction")
		return false
	if is_training or not _train_queue.is_empty():
		print("Barracks: already training")
		return false
	if siege_scene == null:
		push_error("Barracks: siege_scene is null")
		return false
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return false
	var cost: Dictionary = ResourceManager.make_cost(siege_cost_wood, siege_cost_stone)
	if not rm.can_afford(cost, team_id):
		print("Barracks: not enough resources for Siege (need W:", siege_cost_wood, " S:", siege_cost_stone, ")")
		return false
	if not rm.spend(cost, team_id):
		return false
	_start_train(siege_scene, siege_train_time, "Siege", siege_cost_wood, siege_cost_stone, 0, 0)
	print("Barracks: training SiegeUnit... (", siege_train_time, "s, cost ", siege_cost_wood, " wood + ", siege_cost_stone, " stone)")
	return true


func cancel_train_last() -> bool:
	if not _train_queue.is_empty():
		var e: Dictionary = _train_queue.pop_back()
		_refund_entry(e)
		print("Barracks: cancel last queued ", e.get("label", "?"))
		return true
	if is_training and _pending_label == "Soldier":
		_refund_active()
		print("Barracks: cancel current Soldier")
		_clear_active_train()
		_start_next_from_queue()
		return true
	return false


func cancel_train_all() -> bool:
	var any := false
	while not _train_queue.is_empty():
		var e: Dictionary = _train_queue.pop_back()
		_refund_entry(e)
		any = true
	if is_training and _pending_label == "Soldier":
		_refund_active()
		_clear_active_train()
		any = true
	if any:
		print("Barracks: cancel all Soldier training")
	return any


func _start_train(
	scene: PackedScene,
	t: float,
	label: String,
	cost_wood: int,
	cost_stone: int = 0,
	cost_horses: int = 0,
	cost_food: int = 0
) -> void:
	is_training = true
	train_time_total = t
	train_timer = t
	_pending_scene = scene
	_pending_label = label
	_pending_cost_wood = cost_wood
	_pending_cost_stone = cost_stone
	_pending_cost_horses = cost_horses
	_pending_cost_food = cost_food


func _clear_active_train() -> void:
	is_training = false
	train_timer = 0.0
	train_time_total = 0.0
	_pending_scene = null
	_pending_label = ""
	_pending_cost_wood = 0
	_pending_cost_stone = 0
	_pending_cost_horses = 0
	_pending_cost_food = 0


func _start_next_from_queue() -> void:
	if _train_queue.is_empty():
		return
	var e: Dictionary = _train_queue.pop_front()
	_start_train(
		e.get("scene") as PackedScene,
		float(e.get("time", soldier_train_time)),
		str(e.get("label", "Soldier")),
		int(e.get("cost_wood", soldier_cost_wood)),
		int(e.get("cost_stone", 0)),
		int(e.get("cost_horses", 0)),
		int(e.get("cost_food", 0))
	)
	print("Barracks: starting next from queue → ", _pending_label)


func _refund_entry(e: Dictionary) -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	var w: int = int(e.get("cost_wood", 0))
	var s: int = int(e.get("cost_stone", 0))
	var h: int = int(e.get("cost_horses", 0))
	var f: int = int(e.get("cost_food", 0))
	if w > 0:
		rm.add_wood(w, team_id)
	if s > 0:
		rm.add_stone(s, team_id)
	if h > 0:
		rm.add_horses(h, team_id)
	if f > 0:
		rm.add_food(f, team_id)


func _refund_active() -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	if _pending_cost_wood > 0:
		rm.add_wood(_pending_cost_wood, team_id)
	if _pending_cost_stone > 0:
		rm.add_stone(_pending_cost_stone, team_id)
	if _pending_cost_horses > 0:
		rm.add_horses(_pending_cost_horses, team_id)
	if _pending_cost_food > 0:
		rm.add_food(_pending_cost_food, team_id)


func _finish_training() -> void:
	var scene := _pending_scene
	var label := _pending_label
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
	var out_label := label if label != "" else "unit"
	if unit is SiegeUnit:
		out_label = "SiegeUnit"
	elif unit is Cavalry:
		out_label = "Cavalry"
	elif unit is Soldier:
		out_label = "Soldier"
	print("Barracks: ", out_label, " trained at door ", door, " → slot ", dest)
	_start_next_from_queue()
