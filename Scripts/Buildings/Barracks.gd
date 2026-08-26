extends BaseBuilding

class_name Barracks

## Military production. Soldiers + Cavalry (horses gate).

@export var soldier_scene: PackedScene
@export var soldier_cost_wood: int = 80
@export var soldier_train_time: float = 5.0

@export var cavalry_scene: PackedScene
@export var cavalry_cost_wood: int = 100
@export var cavalry_cost_horses: int = 1
@export var cavalry_train_time: float = 6.0

@export var spawn_offset: Vector3 = Vector3(3.0, 0.0, 0.0)

var is_training: bool = false
var train_timer: float = 0.0
var _pending_scene: PackedScene = null


func _ready() -> void:
	super()
	add_to_group("Obstacle")
	if soldier_scene == null:
		soldier_scene = load("res://Scenes/Units/soldier.tscn") as PackedScene
	if cavalry_scene == null:
		cavalry_scene = load("res://Scenes/Units/cavalry.tscn") as PackedScene
	print("Barracks ready at: ", global_position)
	if OS.is_debug_build() and team_id == 0:
		print("Barracks debug: C=train Cavalry (100 wood + 1 horse)")


func _process(delta: float) -> void:
	if not is_training:
		return
	train_timer -= delta
	if train_timer <= 0.0:
		_finish_training()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if team_id != 0 or is_destroyed:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key := event as InputEventKey
	if key.keycode == KEY_C:
		try_train_cavalry()
		get_viewport().set_input_as_handled()


func try_train_soldier() -> bool:
	if is_training:
		print("Barracks: already training")
		return false

	if soldier_scene == null:
		push_error("Barracks: soldier_scene is null")
		return false

	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return false

	var cost: Dictionary = ResourceManager.make_cost(soldier_cost_wood)
	if not rm.spend(cost):
		print("Barracks: not enough wood for Soldier (need ", soldier_cost_wood, ")")
		return false

	is_training = true
	train_timer = soldier_train_time
	_pending_scene = soldier_scene
	print("Barracks: training Soldier... (", soldier_train_time, "s, cost ", soldier_cost_wood, " wood)")
	return true


func try_train_cavalry() -> bool:
	if is_training:
		print("Barracks: already training")
		return false

	if cavalry_scene == null:
		push_error("Barracks: cavalry_scene is null")
		return false

	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return false

	var cost: Dictionary = ResourceManager.make_cost(
		cavalry_cost_wood, 0, 0, 0, cavalry_cost_horses
	)
	if not rm.can_afford(cost):
		print(
			"Barracks: not enough resources for Cavalry (need W:",
			cavalry_cost_wood,
			" Horses:",
			cavalry_cost_horses,
			" have W:",
			rm.wood,
			" H:",
			rm.horses,
			")"
		)
		return false

	if not rm.spend(cost):
		return false

	is_training = true
	train_timer = cavalry_train_time
	_pending_scene = cavalry_scene
	print(
		"Barracks: training Cavalry... (",
		cavalry_train_time,
		"s, cost ",
		cavalry_cost_wood,
		" wood + ",
		cavalry_cost_horses,
		" horse)"
	)
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
	unit.global_position = global_position + spawn_offset

	var label := "unit"
	if unit is Cavalry:
		label = "Cavalry"
	elif unit is Soldier:
		label = "Soldier"
	print("Barracks: ", label, " trained at ", unit.global_position)
	_pending_scene = null
