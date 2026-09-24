extends PanelContainer

## M19.3 — Quick Select Building (Variant A).
## Replaces remote Worker/Soldier with TC / Barracks select.
## Routes into SelectionManager.select_building → existing CommandBar + Queue.
## No camera jump, no train API / AI / economy changes.

const PLAYER_TEAM := 0

@onready var tc_btn: Button = $Margin/HBox/QuickWorker
@onready var barracks_btn: Button = $Margin/HBox/QuickSoldier


func _ready() -> void:
	if tc_btn:
		tc_btn.text = "TC"
		tc_btn.tooltip_text = "Select Town Center"
		if not tc_btn.pressed.is_connected(_on_tc_pressed):
			tc_btn.pressed.connect(_on_tc_pressed)
	if barracks_btn:
		barracks_btn.text = "Barracks"
		barracks_btn.tooltip_text = "Select Barracks"
		if not barracks_btn.pressed.is_connected(_on_barracks_pressed):
			barracks_btn.pressed.connect(_on_barracks_pressed)
	_refresh()


func _process(_delta: float) -> void:
	_refresh()


func _refresh() -> void:
	var has_tc := _resolve_town_center() != null
	var has_barracks := _resolve_barracks() != null
	visible = has_tc or has_barracks
	if tc_btn:
		tc_btn.visible = has_tc
		tc_btn.disabled = not has_tc
	if barracks_btn:
		barracks_btn.visible = has_barracks
		barracks_btn.disabled = not has_barracks


func _on_tc_pressed() -> void:
	var tc = _resolve_town_center()
	if tc == null:
		return
	_select_building(tc)


func _on_barracks_pressed() -> void:
	var b = _resolve_barracks()
	if b == null:
		return
	_select_building(b)


func _select_building(building: Node) -> void:
	var sm := _selection_manager()
	if sm == null:
		return
	if sm.has_method("select_building"):
		sm.select_building(building)
	if OS.is_debug_build():
		print("[QUICK] selected ", building.name)


func _resolve_town_center():
	var selected = _selected_of_type(true)
	if selected != null:
		return selected
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return null
	for tc in bm.town_centers:
		if _is_valid_player_tc(tc):
			return tc
	return null


func _resolve_barracks():
	var selected = _selected_of_type(false)
	if selected != null:
		return selected
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return null
	for b in bm.barracks_list:
		if _is_valid_player_barracks(b):
			return b
	return null


func _selected_of_type(want_tc: bool):
	var sm := _selection_manager()
	if sm == null or not sm.has_method("get_selected_mobile_buildings"):
		return null
	for b in sm.get_selected_mobile_buildings():
		if want_tc and _is_valid_player_tc(b):
			return b
		if not want_tc and _is_valid_player_barracks(b):
			return b
	return null


func _is_valid_player_tc(tc) -> bool:
	if tc == null or not is_instance_valid(tc):
		return false
	if not (tc is TownCenter):
		return false
	if int(tc.get("team_id")) != PLAYER_TEAM:
		return false
	if tc.get("is_destroyed") == true:
		return false
	return true


func _is_valid_player_barracks(b) -> bool:
	if b == null or not is_instance_valid(b):
		return false
	if not (b is Barracks):
		return false
	if int(b.get("team_id")) != PLAYER_TEAM:
		return false
	if b.get("is_destroyed") == true:
		return false
	return true


func _selection_manager() -> Node:
	var sm := get_node_or_null("/root/SelectionManager")
	if sm != null:
		return sm
	var nodes := get_tree().get_nodes_in_group("selection_manager")
	if nodes.size() > 0:
		return nodes[0]
	return null
