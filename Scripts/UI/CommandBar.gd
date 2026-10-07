extends PanelContainer

## M10.1b/c — Bottom Command Bar.
## M27: Orunqar → Train Temirbat.
## M28: Temirbat → Qırğın.
## M32: Temirbat → 6 inventory slots.

enum Context {
	NONE,
	WORKER,
	BARRACKS,
	TOWN_CENTER,
	WATCHTOWER,
	ORUNQAR,
	HERO,
}

@onready var worker_group: Control = $Margin/HBox/WorkerGroup
@onready var barracks_group: Control = $Margin/HBox/BarracksGroup
@onready var town_center_group: Control = $Margin/HBox/TownCenterGroup
@onready var watchtower_group: Control = $Margin/HBox/WatchtowerGroup
@onready var orunqar_group: Control = $Margin/HBox/OrunqarGroup
@onready var hero_group: Control = $Margin/HBox/HeroGroup

var _last_context: int = Context.NONE
var _inv_row: HBoxContainer = null
var _slot_btns: Array = []


func _ready() -> void:
	_ensure_inventory_ui()
	_apply_context(Context.NONE)


func _process(_delta: float) -> void:
	var ctx: int = _resolve_context()
	if ctx != _last_context:
		if _last_context == Context.WORKER and ctx != Context.WORKER:
			_cancel_ghost()
		_apply_context(ctx)
		_last_context = ctx
	if ctx == Context.HERO:
		_refresh_inventory_slots()


func _ensure_inventory_ui() -> void:
	if hero_group == null:
		return
	if _inv_row != null and is_instance_valid(_inv_row):
		return
	_inv_row = HBoxContainer.new()
	_inv_row.name = "InventoryRow"
	_inv_row.add_theme_constant_override("separation", 4)
	var title := Label.new()
	title.text = "Inv"
	title.add_theme_font_size_override("font_size", 12)
	_inv_row.add_child(title)
	_slot_btns.clear()
	for i in HeroProgress.SLOT_COUNT:
		var b := Button.new()
		b.custom_minimum_size = Vector2(44, 36)
		b.focus_mode = Control.FOCUS_NONE
		b.disabled = true
		b.text = "·"
		b.tooltip_text = "Artifact slot %d" % (i + 1)
		_inv_row.add_child(b)
		_slot_btns.append(b)
	hero_group.add_child(_inv_row)
	# Keep Qırğın first if present: move inv after ability buttons
	_inv_row.move_to_front()
	var q := hero_group.get_node_or_null("QirginButton")
	if q:
		hero_group.move_child(q, 0)
		hero_group.move_child(_inv_row, 1)


func _refresh_inventory_slots() -> void:
	if _slot_btns.is_empty():
		_ensure_inventory_ui()
	for i in _slot_btns.size():
		var b: Button = _slot_btns[i] as Button
		if b == null:
			continue
		var lab: String = HeroProgress.slot_label(i)
		if lab.is_empty():
			b.text = "·"
			b.modulate = Color(0.55, 0.55, 0.6, 1)
			b.tooltip_text = "Empty slot %d" % (i + 1)
		else:
			b.text = lab.substr(0, 4)
			b.modulate = Color(1.0, 0.85, 0.25, 1)
			b.tooltip_text = "%s  (+%d HP +%d dmg)" % [lab, HeroProgress.ARTIFACT_HP, HeroProgress.ARTIFACT_DMG]


func _resolve_context() -> int:
	var sm := _selection_manager()
	if sm == null:
		return Context.NONE

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
		if b is Watchtower or b is MobileTower:
			return Context.WATCHTOWER
		if b is Orunqar:
			return Context.ORUNQAR
		if b is BaseBuilding:
			return Context.NONE

	if not sm.has_method("get_valid_selection"):
		return Context.NONE
	var units: Array = sm.get_valid_selection()
	for u in units:
		if u is Temirbat and is_instance_valid(u):
			var h: BaseUnit = u as BaseUnit
			if h.team_id == 0 and h.unit_state != BaseUnit.UnitState.DEAD:
				return Context.HERO
	for u in units:
		if u is Worker and is_instance_valid(u):
			var w: BaseUnit = u as BaseUnit
			if w.team_id == 0 and w.unit_state != BaseUnit.UnitState.DEAD:
				return Context.WORKER
	return Context.NONE


func _apply_context(ctx: int) -> void:
	var show_bar: bool = (
		ctx == Context.WORKER
		or ctx == Context.BARRACKS
		or ctx == Context.TOWN_CENTER
		or ctx == Context.WATCHTOWER
		or ctx == Context.ORUNQAR
		or ctx == Context.HERO
	)
	visible = show_bar
	if worker_group:
		worker_group.visible = ctx == Context.WORKER
	if barracks_group:
		barracks_group.visible = ctx == Context.BARRACKS
	if town_center_group:
		town_center_group.visible = ctx == Context.TOWN_CENTER
	if watchtower_group:
		watchtower_group.visible = ctx == Context.WATCHTOWER
	if orunqar_group:
		orunqar_group.visible = ctx == Context.ORUNQAR
	if hero_group:
		hero_group.visible = ctx == Context.HERO
		if ctx == Context.HERO:
			_ensure_inventory_ui()
			_refresh_inventory_slots()


func _cancel_ghost() -> void:
	var cm := get_node_or_null("/root/ConstructionManager")
	if cm == null:
		cm = get_tree().root.get_node_or_null("ConstructionManager")
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
