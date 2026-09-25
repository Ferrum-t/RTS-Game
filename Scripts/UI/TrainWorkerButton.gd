extends Button

## Train Worker — selected TC → first living player TC.
## M21.1: affordability includes Food.

const COST_WOOD := 50
const COST_FOOD := 1
const PLAYER_TEAM := 0
const MAX_QUEUE := 5


func _ready() -> void:
	text = "Worker (50W+1F)"
	pressed.connect(_on_pressed)
	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.resources_changed.connect(_refresh_state)
	_refresh_state()


func _process(_delta: float) -> void:
	_refresh_state()


func _refresh_state() -> void:
	var tc = _resolve_tc()
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
	if rm == null or not rm.can_afford(ResourceManager.make_cost(COST_WOOD, 0, 0, COST_FOOD), PLAYER_TEAM):
		disabled = true
		text = "Worker — need resources"
		tooltip_text = "Need 50 wood + 1 food"
		return
	disabled = false
	text = "Worker (50W+1F)"
	tooltip_text = "Train Worker (50W + 1 Food)"


func _on_pressed() -> void:
	var tc = _resolve_tc()
	if tc == null:
		print("Train Worker: no Town Center")
		return
	if tc.has_method("try_train_worker"):
		tc.try_train_worker()


func _resolve_tc():
	var selected = _selected_tc()
	if selected != null:
		return selected
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return null
	if bm.has_method("get_first_town_center"):
		return bm.get_first_town_center(PLAYER_TEAM)
	for b in bm.town_centers:
		if b == null or not is_instance_valid(b):
			continue
		if int(b.get("team_id")) != PLAYER_TEAM:
			continue
		if b.get("is_destroyed") == true:
			continue
		return b
	return null


func _selected_tc():
	var sm: Node = get_tree().get_first_node_in_group("selection_manager")
	if sm == null or not sm.has_method("get_selected_mobile_buildings"):
		return null
	for b in sm.get_selected_mobile_buildings():
		if b is TownCenter and is_instance_valid(b):
			if int(b.get("team_id")) == PLAYER_TEAM and b.get("is_destroyed") != true:
				return b
	return null
