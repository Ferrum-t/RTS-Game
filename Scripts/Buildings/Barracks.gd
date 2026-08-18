extends BaseBuilding

class_name Barracks

## Military production building. Trains Soldiers (not Workers).

@export var soldier_scene: PackedScene
@export var soldier_cost_wood: int = 80
@export var soldier_train_time: float = 5.0
@export var spawn_offset: Vector3 = Vector3(3.0, 0.0, 0.0)

var is_training: bool = false
var train_timer: float = 0.0
var _pending_scene: PackedScene = null


func _ready() -> void:
	super()
	add_to_group("Obstacle")
	if soldier_scene == null:
		soldier_scene = load("res://Scenes/Units/soldier.tscn") as PackedScene
	print("Barracks ready at: ", global_position)


func _process(delta: float) -> void:
	if not is_training:
		return
	train_timer -= delta
	if train_timer <= 0.0:
		_finish_training()


func try_train_soldier() -> bool:
	if is_training:
		print("Barracks: already training Soldier")
		return false

	if soldier_scene == null:
		push_error("Barracks: soldier_scene is null")
		return false

	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return false

	if not rm.spend(soldier_cost_wood):
		print("Barracks: not enough wood for Soldier (need ", soldier_cost_wood, ")")
		return false

	is_training = true
	train_timer = soldier_train_time
	_pending_scene = soldier_scene
	print("Barracks: training Soldier... (", soldier_train_time, "s, cost ", soldier_cost_wood, " wood)")
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

	print("Barracks: Soldier trained at ", unit.global_position)
	_pending_scene = null
