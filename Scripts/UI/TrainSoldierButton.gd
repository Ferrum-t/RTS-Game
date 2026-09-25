extends Button

## M19.2 — Train Soldier with remote routing.
## selected Barracks → first with free queue slot → first living player Barracks.
## M21.1: affordability includes Food.

const COST_WOOD := 80
const COST_FOOD := 2
const PLAYER_TEAM := 0
const MAX_QUEUE := 5


func _ready() -> void:
	text = "Soldier (80W+2F)"
	pressed.connect(_on_pressed)
	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.resources_changed.connect(_refresh_state)
	_refresh_state()


func _process(_delta: float) -> void:
	_refresh_state()


func _refresh_state() -> void:
	var barracks = _resolve_barracks()
	var rm := get_node_or_null("/root/ResourceManager")
	if barracks == null:
		disabled = true
		text = "Soldier — no Barracks"
		tooltip_text = "No player Barracks"
		return
	var pipeline: int = 0
	if barracks.has_method("get_train_pipeline_count"):
		pipeline = int(barracks.get_train_pipeline_count())
	if pipeline >= MAX_QUEUE:
		disabled = true
		text = "Soldier — queue full"
		tooltip_text = "Training queue full (5)"
		return
	if rm == null or not rm.can_afford(ResourceManager.make_cost(COST_WOOD, 0, 0, COST_FOOD), PLAYER_TEAM):
		disabled = true
		text = "Soldier — need resources"
		tooltip_text = "Need 80 wood + 2 food"
		return
	disabled = false
	text = "Soldier (80W+2F)"
	tooltip_text = "Train Soldier (80W + 2 Food)"


func _on_pressed() -> void:
	var barracks = _resolve_barracks()
	if barracks == null:
		print("Train Soldier: no Barracks")
		return
	if barracks.has_method("try_train_soldier"):
		barracks.try_train_soldier()


func _resolve_barracks():
	var selected = _selected_barracks()
	if selected != null:
		return selected
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return null
	for b in bm.barracks_list:
		if not _is_valid_player_barracks(b):
			continue
		if b.has_method("get_train_pipeline_count"):
			if int(b.get_train_pipeline_count()) < MAX_QUEUE:
				return b
		else:
			return b
	for b in bm.barracks_list:
		if _is_valid_player_barracks(b):
			return b
	return null


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


func _selected_barracks():
	var sm: Node = get_tree().get_first_node_in_group("selection_manager")
	if sm == null or not sm.has_method("get_selected_mobile_buildings"):
		return null
	for b in sm.get_selected_mobile_buildings():
		if _is_valid_player_barracks(b):
			return b
	return null
