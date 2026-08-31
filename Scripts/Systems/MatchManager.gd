extends Node

## M9 — Playable Match Loop.
## Stage 1: Economic AI opponent (T1) is default pressure source.
## EnemySpawner remains available as Pressure Test Mode (disabled by default).

enum MatchState {
	PLAYING,
	VICTORY,
	DEFEAT,
}

var state: MatchState = MatchState.PLAYING

## true = Economic AI (Stage 1). false = classic wave Pressure Test Mode.
@export var use_economic_ai: bool = true
@export var pressure_test_waves: bool = false

var _player_had_building: bool = false
var _enemy_had_building: bool = false
var _result_label: Label = null

const TOWN_CENTER_SCENE := preload("res://Scenes/Buildings/TownCenter.tscn")
const WATCHTOWER_SCENE := preload("res://Scenes/Buildings/Watchtower.tscn")
const SOLDIER_SCENE := preload("res://Scenes/Units/soldier.tscn")
const WORKER_SCENE := preload("res://Scenes/Units/worker.tscn")

## Bases spread on 200×200 map. Target TC–TC distance ~75 (was ~24).
const PLAYER_TC_POS := Vector3(28.0, 0.0, -22.0)
const PLAYER_WATCHTOWER_OFFSET := Vector3(0.0, 0.0, 6.0)
const ENEMY_TC_POS := Vector3(-28.0, 0.0, 28.0)
const ENEMY_WORKER_OFFSETS := [
	Vector3(2.5, 0.0, 1.0),
	Vector3(3.5, 0.0, -1.0),
]
const ENEMY_SPAWNER_OFFSET := Vector3(2.0, 0.0, 4.0)


func _ready() -> void:
	call_deferred("_setup_match")


func is_playing() -> bool:
	return state == MatchState.PLAYING


func _setup_match() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return

	var player_tc: Node3D = TOWN_CENTER_SCENE.instantiate()
	player_tc.name = "TownCenter"
	player_tc.team_id = 0
	player_tc.position = PLAYER_TC_POS
	scene.add_child(player_tc)

	var player_wt: Node3D = WATCHTOWER_SCENE.instantiate()
	player_wt.name = "Watchtower"
	player_wt.team_id = 0
	player_wt.position = PLAYER_TC_POS + PLAYER_WATCHTOWER_OFFSET
	scene.add_child(player_wt)

	var enemy_tc: Node3D = TOWN_CENTER_SCENE.instantiate()
	enemy_tc.name = "EnemyTownCenter"
	enemy_tc.team_id = 1
	enemy_tc.position = ENEMY_TC_POS
	scene.add_child(enemy_tc)

	var units_parent: Node = scene.get_node_or_null("Units")
	if units_parent == null:
		units_parent = scene

	if use_economic_ai:
		var i := 0
		for off in ENEMY_WORKER_OFFSETS:
			var w: Node3D = WORKER_SCENE.instantiate()
			w.name = "AIWorker_%d" % i
			if w is BaseUnit:
				(w as BaseUnit).team_id = 1
			units_parent.add_child(w)
			w.global_position = ENEMY_TC_POS + off
			i += 1

		var eco := EconomicAIController.new()
		eco.name = "EconomicAIController"
		eco.team_id = 1
		scene.add_child(eco)
		var dx: float = ENEMY_TC_POS.x - PLAYER_TC_POS.x
		var dz: float = ENEMY_TC_POS.z - PLAYER_TC_POS.z
		var tc_dist: float = sqrt(dx * dx + dz * dz)
		print("MATCH: PLAYING Stage1 Economic AI (team1 TC+workers, waves OFF)")
		print("MAP: PlayerTC=", PLAYER_TC_POS, " EnemyTC=", ENEMY_TC_POS, " distance=", snappedf(tc_dist, 0.1))
	else:
		var soldier: Node3D = SOLDIER_SCENE.instantiate()
		soldier.name = "EnemySoldier_0"
		if soldier is BaseUnit:
			(soldier as BaseUnit).team_id = 1
		units_parent.add_child(soldier)
		soldier.global_position = ENEMY_TC_POS + Vector3(3.5, 0.0, 0.0)
		if soldier is BaseUnit:
			EnemyAIComponent.attach_to(soldier as BaseUnit, 24.0)

		var spawner := EnemySpawner.new()
		spawner.name = "EnemySpawner"
		spawner.team_id = 1
		spawner.enabled = pressure_test_waves
		spawner.spawn_interval = 30.0
		spawner.first_spawn_delay = 30.0
		spawner.wave_size = 1
		spawner.max_wave_size = 3
		spawner.max_units_alive = 6
		spawner.escalate_after_waves = 3
		spawner.unit_scene = SOLDIER_SCENE
		spawner.position = ENEMY_TC_POS + ENEMY_SPAWNER_OFFSET
		scene.add_child(spawner)
		print("MATCH: PLAYING Pressure Test (waves=", pressure_test_waves, ")")

	_ensure_result_label()


func _process(_delta: float) -> void:
	if state != MatchState.PLAYING:
		return
	_evaluate()


func _evaluate() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return

	var player_alive := 0
	var enemy_alive := 0

	for b in bm.buildings:
		if b == null or not is_instance_valid(b):
			continue
		if b.get("is_destroyed") == true:
			continue
		if b.get("health") != null and int(b.health) <= 0:
			continue

		var tid: int = int(b.team_id)
		if tid == 0:
			player_alive += 1
			_player_had_building = true
		elif tid == 1:
			enemy_alive += 1
			_enemy_had_building = true

	if _enemy_had_building and enemy_alive == 0:
		_set_victory()
	elif _player_had_building and player_alive == 0:
		_set_defeat()


func _set_victory() -> void:
	if state != MatchState.PLAYING:
		return
	state = MatchState.VICTORY
	print("MATCH: VICTORY")
	_show_result("VICTORY")


func _set_defeat() -> void:
	if state != MatchState.PLAYING:
		return
	state = MatchState.DEFEAT
	print("MATCH: DEFEAT")
	_show_result("DEFEAT")


func _ensure_result_label() -> void:
	if _result_label != null and is_instance_valid(_result_label):
		return
	var scene := get_tree().current_scene
	if scene == null:
		return

	var layer: CanvasLayer = null
	var ui_root := scene.get_node_or_null("UI")
	if ui_root is CanvasLayer:
		layer = ui_root as CanvasLayer
	else:
		layer = CanvasLayer.new()
		layer.name = "MatchUI"
		scene.add_child(layer)

	_result_label = Label.new()
	_result_label.name = "MatchResultLabel"
	_result_label.visible = false
	_result_label.set_anchors_preset(Control.PRESET_CENTER)
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override("font_size", 64)
	_result_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_result_label.offset_left = -200.0
	_result_label.offset_right = 200.0
	_result_label.offset_top = -40.0
	_result_label.offset_bottom = 40.0
	layer.add_child(_result_label)


func _show_result(text: String) -> void:
	_ensure_result_label()
	if _result_label == null:
		return
	_result_label.text = text
	_result_label.visible = true
