extends BaseBuilding

class_name TownCenter

## Economy hub. Trains Workers only. Soldiers come from Barracks.

@export var worker_scene: PackedScene
@export var worker_cost_wood: int = 50
@export var worker_train_time: float = 3.0
@export var spawn_offset: Vector3 = Vector3(3.0, 0.0, 0.0)

var is_training: bool = false
var train_timer: float = 0.0
var _pending_scene: PackedScene = null


func _ready() -> void:
	super()
	add_to_group("Obstacle")
	if worker_scene == null:
		worker_scene = load("res://Scenes/Units/worker.tscn") as PackedScene
	print("TownCenter ready at: ", global_position)


func _process(delta: float) -> void:
	if not is_training:
		return
	train_timer -= delta
	if train_timer <= 0.0:
		_finish_training()


func try_train_worker() -> bool:
	if is_training:
		print("TownCenter: already training Worker")
		return false

	if worker_scene == null:
		push_error("TownCenter: worker_scene is null")
		return false

	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return false

	if not rm.spend(worker_cost_wood):
		print("TownCenter: not enough wood for Worker (need ", worker_cost_wood, ")")
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
	unit.global_position = global_position + spawn_offset

	print("TownCenter: Worker trained at ", unit.global_position)
	_pending_scene = null
