extends PanelContainer

## M10.1c — Worker build buttons: Watchtower, Barracks, Town Center, Yurt.
## Visibility is owned by parent CommandBar WorkerGroup.
## Affordability still refreshed while visible.

@onready var container = $VBoxContainer

@export var build_catalog : BuildCatalog
@export var build_button_scene : PackedScene

var _buttons: Array[BuildButton] = []


func _ready() -> void:
	if build_catalog == null:
		push_error("BuildCatalog is not assigned!")
		return

	if build_button_scene == null:
		push_error("BuildButton scene is not assigned!")
		return

	for building in build_catalog.buildings:
		if building == null:
			continue
		if not _is_worker_buildable(building):
			continue
		var button = build_button_scene.instantiate()
		button.setup(building)
		container.add_child(button)
		if button is BuildButton:
			_buttons.append(button as BuildButton)


func _process(_delta: float) -> void:
	if visible:
		_refresh_affordability()


func _is_worker_buildable(data: BuildingData) -> bool:
	var n: String = str(data.building_name).strip_edges().to_lower().replace(" ", "")
	return n == "watchtower" or n == "barracks" or n == "towncenter" or n == "yurt"


func _refresh_affordability() -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	for btn in _buttons:
		if btn == null or not is_instance_valid(btn):
			continue
		if btn.building_data == null:
			btn.disabled = true
			continue
		if rm == null:
			btn.disabled = false
			continue
		var cost: Dictionary = btn.building_data.get_cost_dict()
		btn.disabled = not rm.can_afford(cost, 0)
