extends PanelContainer

## M10.1 — Worker Construction UI.
## Visible only while at least one team-0 Worker is selected.
## Buttons disable when team 0 cannot afford the cost.

@onready var container = $VBoxContainer

@export var build_catalog : BuildCatalog
@export var build_button_scene : PackedScene

var _buttons: Array[BuildButton] = []


func _ready() -> void:
	visible = false

	if build_catalog == null:
		push_error("BuildCatalog is not assigned!")
		return

	if build_button_scene == null:
		push_error("BuildButton scene is not assigned!")
		return

	for building in build_catalog.buildings:
		var button = build_button_scene.instantiate()
		button.setup(building)
		container.add_child(button)
		if button is BuildButton:
			_buttons.append(button as BuildButton)


func _process(_delta: float) -> void:
	var has_worker := _has_selected_worker()
	if visible != has_worker:
		visible = has_worker
		if not has_worker:
			# Leaving worker selection cancels in-progress ghost placement.
			var cm := get_node_or_null("/root/ConstructionManager")
			if cm != null and cm.has_method("cancel_build_mode"):
				cm.cancel_build_mode()
	if visible:
		_refresh_affordability()


func _has_selected_worker() -> bool:
	var sm := _selection_manager()
	if sm == null:
		return false
	if not sm.has_method("get_valid_selection"):
		return false
	var selected: Array = sm.get_valid_selection()
	for u in selected:
		if u is Worker and is_instance_valid(u):
			var w: BaseUnit = u as BaseUnit
			if w.team_id == 0 and w.unit_state != BaseUnit.UnitState.DEAD:
				return true
	return false


func _selection_manager() -> Node:
	var sm := get_node_or_null("/root/SelectionManager")
	if sm != null:
		return sm
	var nodes := get_tree().get_nodes_in_group("selection_manager")
	if nodes.size() > 0:
		return nodes[0]
	return null


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
