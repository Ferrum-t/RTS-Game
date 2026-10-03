extends BaseBuilding

class_name Orunqar

## M27/M29/M31 — train/revive Temirbat. Rally point for exit.

@export var temirbat_scene: PackedScene
@export var temirbat_cost_wood: int = 120
@export var temirbat_cost_food: int = 3
@export var temirbat_cost_horses: int = 1
@export var temirbat_train_time: float = 8.0
@export var revive_cooldown: float = 30.0

var is_training: bool = false
var train_timer: float = 0.0
var train_time_total: float = 0.0

## Where trained Temirbat walks after door. Right-click ground with Orunqar selected.
var rally_point: Vector3 = Vector3.ZERO
var has_rally: bool = false

static var match_hero_alive: bool = false
static var match_revive_cd: float = 0.0

static var match_hero_trained: bool:
	get:
		return match_hero_alive


func _ready() -> void:
	base_max_health = 400
	max_health = 400
	health = 400
	super()
	add_to_group("Obstacle")
	add_to_group("Orunqar")
	nav_half_extents = Vector3(2.0, 1.0, 2.0)
	if temirbat_scene == null:
		temirbat_scene = load("res://Scenes/Units/temirbat.tscn") as PackedScene
	# Default rally: in front of current building position
	rally_point = global_position + Vector3(6.0, 0.0, 0.0)
	has_rally = true
	print("Orunqar ready at ", global_position)
	if OS.is_debug_build() and team_id == 0:
		print("Orunqar: T = train · right-click ground = rally")


func _process(delta: float) -> void:
	if match_revive_cd > 0.0:
		match_revive_cd = maxf(0.0, match_revive_cd - delta)
	if not is_training:
		return
	train_timer -= delta
	if train_timer <= 0.0:
		_finish_training()


func set_rally(world_pos: Vector3) -> void:
	rally_point = world_pos
	has_rally = true
	print("Orunqar rally → ", rally_point)


func _unhandled_input(event: InputEvent) -> void:
	if team_id != 0 or is_destroyed:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if not OS.is_debug_build():
		return
	var key := event as InputEventKey
	if key.keycode == KEY_T:
		try_train_temirbat()
		get_viewport().set_input_as_handled()


static func notify_hero_fallen() -> void:
	match_hero_alive = false
	match_revive_cd = 30.0
	print("Orunqar: Temirbat fallen — revive available in 30s")


func can_train_temirbat() -> bool:
	if not is_constructed or is_destroyed:
		return false
	if match_hero_alive:
		return false
	if match_revive_cd > 0.0:
		return false
	if is_training:
		return false
	for n in get_tree().get_nodes_in_group("Hero"):
		if n is Temirbat and is_instance_valid(n) and n.unit_state != BaseUnit.UnitState.DEAD:
			if int(n.team_id) == int(team_id):
				match_hero_alive = true
				return false
	return true


func try_train_temirbat() -> bool:
	if not can_train_temirbat():
		if match_hero_alive:
			print("Orunqar: Temirbat already alive")
		elif match_revive_cd > 0.0:
			print("Orunqar: revive CD %.0fs" % match_revive_cd)
		else:
			print("Orunqar: cannot train Temirbat")
		return false
	if temirbat_scene == null:
		push_error("Orunqar: temirbat_scene is null")
		return false

	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return false
	var cost := ResourceManager.make_cost(temirbat_cost_wood, 0, 0, temirbat_cost_food, temirbat_cost_horses)
	if not rm.can_afford(cost, team_id):
		print("Orunqar: not enough resources for Temirbat (need W:", temirbat_cost_wood, " F:", temirbat_cost_food, " H:", temirbat_cost_horses, ")")
		return false
	if not rm.spend(cost, team_id):
		return false

	is_training = true
	train_time_total = temirbat_train_time
	train_timer = temirbat_train_time
	print("Orunqar: training Temirbat... (", temirbat_train_time, "s)")
	return true


func _finish_training() -> void:
	is_training = false
	match_hero_alive = true
	match_revive_cd = 0.0

	var unit: Node3D = temirbat_scene.instantiate()
	if unit == null:
		match_hero_alive = false
		return
	unit.name = "Temirbat"
	if "team_id" in unit:
		unit.team_id = team_id

	# Always use CURRENT Orunqar position (not cached from build frame)
	var door: Vector3 = global_position + Vector3(3.5, 0.0, 0.0)
	var slot: Vector3 = rally_point if has_rally else (door + Vector3(4.0, 0.0, 2.0))
	get_tree().current_scene.add_child(unit)
	# Set position before physics ticks
	unit.global_position = door
	if unit is Node3D:
		unit.global_position = door
	if unit is BaseUnit and unit.has_method("replace_order_move"):
		unit.replace_order_move(slot)
	print("Orunqar: Temirbat at door ", door, " → rally ", slot)


func get_train_progress() -> float:
	if not is_training or train_time_total <= 0.0:
		return 0.0
	return clampf(1.0 - (train_timer / train_time_total), 0.0, 1.0)
