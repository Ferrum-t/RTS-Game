extends Node3D

class_name EnemySpawner

## Phase 7 — periodic enemy unit waves near enemy base.
## Spawns existing unit scenes (Soldier default), team_id=1, attaches EnemyAIComponent.

@export var unit_scene: PackedScene
@export var team_id: int = 1
@export var spawn_interval: float = 12.0
@export var wave_size: int = 1
@export var max_units_alive: int = 6
@export var spawn_offset: Vector3 = Vector3(3.0, 0.0, 2.0)
@export var aggro_radius: float = 22.0
@export var enabled: bool = true
@export var first_spawn_delay: float = 8.0

var _timer: float = 0.0
var _alive: Array[BaseUnit] = []


func _ready() -> void:
	if unit_scene == null:
		unit_scene = load("res://Scenes/Units/soldier.tscn") as PackedScene
	_timer = first_spawn_delay
	print("EnemySpawner ready at ", global_position, " interval=", spawn_interval)


func _physics_process(delta: float) -> void:
	if not enabled:
		return
	var mm := get_node_or_null("/root/MatchManager")
	if mm != null and mm.has_method("is_playing") and not mm.is_playing():
		return

	_prune_alive()
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = spawn_interval
	_spawn_wave()


func _prune_alive() -> void:
	var next: Array[BaseUnit] = []
	for u in _alive:
		if u != null and is_instance_valid(u) and u.unit_state != BaseUnit.UnitState.DEAD:
			next.append(u)
	_alive = next


func _spawn_wave() -> void:
	if unit_scene == null:
		return
	var room: int = max_units_alive - _alive.size()
	if room <= 0:
		return
	var count: int = mini(wave_size, room)
	var parent := get_tree().current_scene
	if parent == null:
		return
	var units_parent: Node = parent.get_node_or_null("Units")
	if units_parent == null:
		units_parent = parent

	for i in range(count):
		var node := unit_scene.instantiate()
		if not (node is BaseUnit):
			node.queue_free()
			continue
		var unit := node as BaseUnit
		unit.team_id = team_id
		units_parent.add_child(unit)
		var jitter := Vector3(float(i) * 1.2, 0.0, float(i % 2) * 1.1)
		unit.global_position = global_position + spawn_offset + jitter
		EnemyAIComponent.attach_to(unit, aggro_radius)
		_alive.append(unit)
		print("EnemySpawner: spawned ", unit.name, " team ", team_id, " at ", unit.global_position)
