extends BaseBuilding

class_name TownCenter

@export var worker_scene: PackedScene
@export var train_cost_wood: int = 50
@export var train_time: float = 3.0
@export var spawn_offset: Vector3 = Vector3(3.0, 0.0, 0.0)

var is_training: bool = false
var train_timer: float = 0.0


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
		print("TownCenter: already training a Worker")
		return false

	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		push_warning("ResourceManager not found")
		return false

	if not rm.spend(train_cost_wood):
		print("TownCenter: not enough wood (need ", train_cost_wood, ")")
		return false

	is_training = true
	train_timer = train_time
	print("TownCenter: training Worker... (", train_time, "s)")
	return true


func _finish_training() -> void:
	is_training = false
	train_timer = 0.0

	if worker_scene == null:
		push_error("TownCenter: worker_scene is null")
		return

	var worker := worker_scene.instantiate()
	var units_parent := get_tree().current_scene.get_node_or_null("Units")
	if units_parent == null:
		units_parent = get_tree().current_scene

	units_parent.add_child(worker)
	worker.global_position = global_position + spawn_offset

	print("TownCenter: Worker trained at ", worker.global_position)
