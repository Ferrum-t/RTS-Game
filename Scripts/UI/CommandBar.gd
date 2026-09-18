extends PanelContainer

## M10.1b — Bottom Command Bar.
## Selection → context → show one command group, hide the rest.
## Does not change train/build mechanics — only visibility routing.

enum Context {
	NONE,
	WORKER,
	BARRACKS,
	TOWN_CENTER,
	WATCHTOWER,
}

@onready var worker_group: Control = $Margin/HBox/WorkerGroup
@onready var barracks_group: Control = $Margin/HBox/BarracksGroup
@onready var town_center_group: Control = $Margin/HBox/TownCenterGroup

var _last_context: int = Context.NONE


func _ready() -> void:
	_apply_context(Context.NONE)


func _process(_delta: float) -> void:
	var ctx: int = _resolve_context()
	if ctx != _last_context:
		if _last_context == Context.WORKER and ctx != Context.WORKER:
			_cancel_ghost()
		_apply_context(ctx)
		_last_context = ctx


func _resolve_context() -> int:
	var sm := _selection_manager()
	if sm == null:
		return Context.NONE

	# Buildings exclusive with units in SelectionManager.
	var buildings: Array = []
	if sm.has_method("get_selected_mobile_buildings"):
		buildings = sm.get_selected_mobile_buildings()
	for b in buildings:
		if b == null or not is_instance_valid(b):
			continue
		if b is Barracks:
			return Context.BARRACKS
		if b is TownCenter:
			return Context.TOWN_CENTER
		if b is Watchtower:
			return Context.WATCHTOWER
		if b is BaseBuilding:
			return Context.NONE

	if not sm.has_method("get_valid_selection"):
		return Context.NONE
	var units: Array = sm.get_valid_selection()
	for u in units:
		if u is Worker and is_instance_valid(u):
			var w: BaseUnit = u as BaseUnit
			if w.team_id == 0 and w.unit_state != BaseUnit.UnitState.DEAD:
				return Context.WORKER
	return Context.NONE


func _apply_context(ctx: int) -> void:
	var show_bar: bool = ctx == Context.WORKER or ctx == Context.BARRACKS or ctx == Context.TOWN_CENTER
	visible = show_bar
	if worker_group:
		worker_group.visible = ctx == Context.WORKER
	if barracks_group:
		barracks_group.visible = ctx == Context.BARRACKS
	if town_center_group:
		town_center_group.visible = ctx == Context.TOWN_CENTER


func _cancel_ghost() -> void:
	var cm := get_node_or_null("/root/ConstructionManager")
	if cm != null and cm.has_method("cancel_build_mode"):
		cm.cancel_build_mode()


func _selection_manager() -> Node:
	var sm := get_node_or_null("/root/SelectionManager")
	if sm != null:
		return sm
	var nodes := get_tree().get_nodes_in_group("selection_manager")
	if nodes.size() > 0:
		return nodes[0]
	return null
