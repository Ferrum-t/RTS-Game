extends Button

## Trains SiegeUnit from selected Barracks, else first owned (150 wood + 50 stone).

const COST_WOOD := 150
const COST_STONE := 50
const PLAYER_TEAM := 0


func _ready() -> void:
	text = "Siege (150W+50S)"
	pressed.connect(_on_pressed)

	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.resources_changed.connect(_on_resources_changed)
		_on_resources_changed()


func _on_resources_changed() -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	disabled = not rm.can_afford(
		ResourceManager.make_cost(COST_WOOD, COST_STONE),
		PLAYER_TEAM
	)


func _on_pressed() -> void:
	var barracks = _resolve_barracks()
	if barracks == null:
		print("Train Siege: build a Barracks first (your team)")
		return
	if barracks.has_method("try_train_siege"):
		barracks.try_train_siege()


func _resolve_barracks():
	var selected = _selected_barracks()
	if selected != null:
		return selected
	var bm := get_node_or_null("/root/BuildingManager")
	if bm != null and bm.has_method("get_first_barracks"):
		return bm.get_first_barracks(PLAYER_TEAM)
	return null


func _selected_barracks():
	var sm: Node = get_tree().get_first_node_in_group("selection_manager")
	if sm == null or not sm.has_method("get_selected_mobile_buildings"):
		return null
	for b in sm.get_selected_mobile_buildings():
		if b is Barracks and is_instance_valid(b):
			if int(b.get("team_id")) == PLAYER_TEAM and b.get("is_destroyed") != true:
				return b
	return null
