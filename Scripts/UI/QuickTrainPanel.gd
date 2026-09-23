extends PanelContainer

## M19.2 — Remote train strip. Visible when player has TC and/or Barracks.
## Child buttons: QuickWorker / QuickSoldier (TrainWorkerButton / TrainSoldierButton scripts).

const PLAYER_TEAM := 0

@onready var worker_btn: Button = $Margin/HBox/QuickWorker
@onready var soldier_btn: Button = $Margin/HBox/QuickSoldier


func _ready() -> void:
	_refresh_visibility()


func _process(_delta: float) -> void:
	_refresh_visibility()


func _refresh_visibility() -> void:
	var has_tc := _has_player_tc()
	var has_barracks := _has_player_barracks()
	visible = has_tc or has_barracks
	if worker_btn:
		worker_btn.visible = has_tc
	if soldier_btn:
		soldier_btn.visible = has_barracks


func _has_player_tc() -> bool:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return false
	for tc in bm.town_centers:
		if tc == null or not is_instance_valid(tc):
			continue
		if int(tc.get("team_id")) != PLAYER_TEAM:
			continue
		if tc.get("is_destroyed") == true:
			continue
		return true
	return false


func _has_player_barracks() -> bool:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return false
	for b in bm.barracks_list:
		if b == null or not is_instance_valid(b):
			continue
		if int(b.get("team_id")) != PLAYER_TEAM:
			continue
		if b.get("is_destroyed") == true:
			continue
		return true
	return false
