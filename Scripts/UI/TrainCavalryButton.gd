extends Button

## Trains Cavalry from the player's Barracks (100 wood + 1 horse).

const COST_WOOD := 100
const COST_HORSES := 1
const PLAYER_TEAM := 0


func _ready() -> void:
	text = "Train Cavalry (100W + 1H)"
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
		ResourceManager.make_cost(COST_WOOD, 0, 0, 0, COST_HORSES),
		PLAYER_TEAM
	)


func _on_pressed() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		push_warning("BuildingManager not found")
		return

	var barracks = null
	if bm.has_method("get_first_barracks"):
		barracks = bm.get_first_barracks(PLAYER_TEAM)

	if barracks == null:
		print("Train Cavalry: build a Barracks first (your team)")
		return

	if barracks.has_method("try_train_cavalry"):
		barracks.try_train_cavalry()
