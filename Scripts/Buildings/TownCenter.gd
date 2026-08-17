extends BaseBuilding

class_name TownCenter

@export var worker_scene: PackedScene
@export var soldier_scene: PackedScene

@export var worker_cost_wood: int = 50
@export var worker_train_time: float = 3.0

@export var soldier_cost_wood: int = 80
@export var soldier_train_time: float = 5.0

@export var spawn_offset: Vector3 = Vector3(3.0, 0.0, 0.0)

var is_training: bool = false
var train_timer: float = 0.0
var _pending_scene: PackedScene = null
var _pending_name: String = ""


func _ready() -> void:
	super()
	add_to_group("Obstacle")
	if worker_scene == null:
		worker_scene = load("res://Scenes/Units/worker.tscn") as PackedScene
	if soldier_scene == null:
		soldier_scene = load("res://Scenes/Units/soldier.tscn") as PackedScene
	print("TownCenter ready at: ", global_position)


func _process(delta: float) -> void:
	if not is_training:
		return
	train_timer -= delta
	if train_timer <= 0.0:
		_finish_training()


func try_train_worker() -> bool:
	return _start_training(worker_scene, worker_cost_wood, worker_train_time, "Worker")


func try_train_soldier() -> bool:
	return _start_training(soldier_scene, soldier_cost_wood, soldier_train_time, "Soldier")


func _start_training(scene: PackedScene, wood_cost: int, time: float, unit_name: String) -> bool:
	if is_training:
		print("TownCenter: already training ", _pending_name)
		return false

	if scene == null:
		push_error("TownCenter: scene is null for ", unit_name)
		return false

	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		push_warning("ResourceManager not found")
		return false

	if not rm.spend(wood_cost):
		print("TownCenter: not enough wood for ", unit_name, " (need ", wood_cost, ")")
		return false

	is_training = true
	train_timer = time
	_pending_scene = scene
	_pending_name = unit_name
	print("TownCenter: training ", unit_name, "... (", time, "s, cost ", wood_cost, " wood)")
	return true


func _finish_training() -> void:
	is_training = false
	train_timer = 0.0

	if _pending_scene == null:
		push_error("TownCenter: pending scene is null")
		return

	var unit := _pending_scene.instantiate()
	var units_parent := get_tree().current_scene.get_node_or_null("Units")
	if units_parent == null:
		units_parent = get_tree().current_scene

	units_parent.add_child(unit)
	unit.global_position = global_position + spawn_offset

	print("TownCenter: ", _pending_name, " trained at ", unit.global_position)
	_pending_scene = null
	_pending_name = ""
