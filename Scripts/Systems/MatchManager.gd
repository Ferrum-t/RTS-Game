extends Node

## M9 — Playable Match Loop.
## Owns match state only. Does not drive movement, orders, harvest, or combat.

enum MatchState {
	PLAYING,
	VICTORY,
	DEFEAT,
}

var state: MatchState = MatchState.PLAYING

var _player_had_building: bool = false
var _enemy_had_building: bool = false
var _result_label: Label = null

const TOWN_CENTER_SCENE := preload("res://Scenes/Buildings/TownCenter.tscn")
const SOLDIER_SCENE := preload("res://Scenes/Units/soldier.tscn")

## Near existing Workers at (7,0,0) / (10,0,0)
const PLAYER_TC_POS := Vector3(2.0, 0.0, -2.0)
## Far from player start
const ENEMY_TC_POS := Vector3(-18.0, 0.0, 12.0)
const ENEMY_SOLDIER_OFFSET := Vector3(3.5, 0.0, 0.0)


func _ready() -> void:
	call_deferred("_setup_match")


func is_playing() -> bool:
	return state == MatchState.PLAYING


func _setup_match() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return

	# Player Town Center (team 0)
	var player_tc: Node3D = TOWN_CENTER_SCENE.instantiate()
	player_tc.team_id = 0
	player_tc.position = PLAYER_TC_POS
	scene.add_child(player_tc)

	# Enemy Town Center (team 1)
	var enemy_tc: Node3D = TOWN_CENTER_SCENE.instantiate()
	enemy_tc.team_id = 1
	enemy_tc.position = ENEMY_TC_POS
	scene.add_child(enemy_tc)

	# Enemy Soldier (team 1) — static target, no AI
	var units_parent: Node = scene.get_node_or_null("Units")
	if units_parent == null:
		units_parent = scene
	var soldier: Node3D = SOLDIER_SCENE.instantiate()
	soldier.team_id = 1
	units_parent.add_child(soldier)
	soldier.global_position = ENEMY_TC_POS + ENEMY_SOLDIER_OFFSET

	_ensure_result_label()
	print("MATCH: PLAYING (player TC team 0, enemy TC+Soldier team 1)")


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
	# Center via offsets after anchors
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
