extends Button

## Requests the first Town Center to train a Soldier (80 wood).

const COST_WOOD := 80


func _ready() -> void:
	text = "Train Soldier (80 Wood)"
	pressed.connect(_on_pressed)

	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.resources_changed.connect(_on_resources_changed)
		_on_resources_changed()


func _on_resources_changed() -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	disabled = rm.wood < COST_WOOD


func _on_pressed() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		push_warning("BuildingManager not found")
		return

	if bm.town_centers.is_empty():
		print("Train Soldier: no Town Center built yet")
		return

	var tc = bm.town_centers[0]
	if tc and tc.has_method("try_train_soldier"):
		tc.try_train_soldier()
