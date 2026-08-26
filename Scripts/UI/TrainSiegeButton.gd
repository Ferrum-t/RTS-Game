extends Button

## Trains a SiegeUnit from the first Barracks (150 wood + 50 stone).

const COST_WOOD := 150
const COST_STONE := 50


func _ready() -> void:
	text = "Train Siege (150W + 50S)"
	pressed.connect(_on_pressed)

	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.resources_changed.connect(_on_resources_changed)
		_on_resources_changed()


func _on_resources_changed() -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	disabled = not rm.can_afford(ResourceManager.make_cost(COST_WOOD, COST_STONE))


func _on_pressed() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		push_warning("BuildingManager not found")
		return

	var barracks = null
	if bm.has_method("get_first_barracks"):
		barracks = bm.get_first_barracks()
	elif "barracks_list" in bm and not bm.barracks_list.is_empty():
		barracks = bm.barracks_list[0]

	if barracks == null:
		print("Train Siege: build a Barracks first")
		return

	if barracks.has_method("try_train_siege"):
		barracks.try_train_siege()
