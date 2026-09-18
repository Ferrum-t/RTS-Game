extends Button

## Requests selected Town Center (else first owned) to train a Worker.

const COST_WOOD := 50
const PLAYER_TEAM := 0


func _ready() -> void:
	text = "Worker (50W)"
	pressed.connect(_on_pressed)

	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.resources_changed.connect(_on_resources_changed)
		_on_resources_changed()


func _on_resources_changed() -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	disabled = not rm.can_afford(ResourceManager.make_cost(COST_WOOD), PLAYER_TEAM)


func _on_pressed() -> void:
	var tc = _resolve_town_center()
	if tc == null:
		print("Train Worker: no Town Center built yet")
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
	for tc in bm.town_centers:
		if tc == null or not is_instance_valid(tc):
			continue
		if int(tc.get("team_id")) != PLAYER_TEAM:
			continue
		if tc.get("is_destroyed") == true:
			continue
		return tc
	return null


func _selected_town_center():
	var sm: Node = get_tree().get_first_node_in_group("selection_manager")
	if sm == null or not sm.has_method("get_selected_mobile_buildings"):
		return null
	for b in sm.get_selected_mobile_buildings():
		if b is TownCenter and is_instance_valid(b):
			if int(b.get("team_id")) == PLAYER_TEAM and b.get("is_destroyed") != true:
				return b
	return null
