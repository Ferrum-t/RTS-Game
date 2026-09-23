extends Button

## M19.2 — Train Worker with remote routing.
## selected TC → first with free queue slot → first living player TC.

const COST_WOOD := 50
const PLAYER_TEAM := 0
const MAX_QUEUE := 5


func _ready() -> void:
	text = "Worker (50W)"
	pressed.connect(_on_pressed)
	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.resources_changed.connect(_refresh_state)
	_refresh_state()


func _process(_delta: float) -> void:
	_refresh_state()


func _refresh_state() -> void:
	var tc = _resolve_town_center()
	var rm := get_node_or_null("/root/ResourceManager")
	if tc == null:
		disabled = true
		text = "Worker — no TC"
		tooltip_text = "No player Town Center"
		return
	var pipeline: int = 0
	if tc.has_method("get_train_pipeline_count"):
		pipeline = int(tc.get_train_pipeline_count())
	if pipeline >= MAX_QUEUE:
		disabled = true
		text = "Worker — queue full"
		tooltip_text = "Training queue full (5)"
		return
	if rm == null or not rm.can_afford(ResourceManager.make_cost(COST_WOOD), PLAYER_TEAM):
		disabled = true
		text = "Worker — need 50W"
		tooltip_text = "Not enough wood (50)"
		return
	disabled = false
	text = "Worker (50W)"
	tooltip_text = "Train Worker (uses M19.1 queue)"


func _on_pressed() -> void:
	var tc = _resolve_town_center()
	if tc == null:
		print("Train Worker: no Town Center")
		return
	if tc.has_method("try_train_worker"):
		tc.try_train_worker()


func _resolve_town_center():
	var selected = _selected_town_center()
	if selected != null:
		return selected
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null or bm.town_centers.is_empty():
		return null
	# Prefer free queue slot
	for tc in bm.town_centers:
		if not _is_valid_player_tc(tc):
			continue
		if tc.has_method("get_train_pipeline_count"):
			if int(tc.get_train_pipeline_count()) < MAX_QUEUE:
				return tc
		else:
			return tc
	# Fallback: first living
	for tc in bm.town_centers:
		if _is_valid_player_tc(tc):
			return tc
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


func _selected_town_center():
	var sm: Node = get_tree().get_first_node_in_group("selection_manager")
	if sm == null or not sm.has_method("get_selected_mobile_buildings"):
		return null
	for b in sm.get_selected_mobile_buildings():
		if _is_valid_player_tc(b):
			return b
	return null
