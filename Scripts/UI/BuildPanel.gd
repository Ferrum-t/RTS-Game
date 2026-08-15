extends PanelContainer

@onready var container: VBoxContainer = $VBoxContainer

@export var build_catalog: BuildCatalog
@export var build_button_scene: PackedScene
@export var construction_manager: NodePath

var resource_summary_label: Label
var selected_unit_summary_label: Label
var selection_manager: SelectionManager = null

func _ready() -> void:
	if build_catalog == null:
		push_error("BuildCatalog is not assigned!")
		return
	if build_button_scene == null:
		push_error("BuildButton scene is not assigned!")
		return

	resource_summary_label = Label.new()
	resource_summary_label.text = "Base stock:\nLoading..."
	resource_summary_label.size_flags_horizontal = Control.SIZE_FILL
	resource_summary_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	container.add_child(resource_summary_label)

	selected_unit_summary_label = Label.new()
	selected_unit_summary_label.text = "Selected unit:\nNone"
	selected_unit_summary_label.size_flags_horizontal = Control.SIZE_FILL
	selected_unit_summary_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	container.add_child(selected_unit_summary_label)

	var current_scene := get_tree().get_current_scene()
	if current_scene != null:
		selection_manager = current_scene.get_node_or_null("Managers/SelectionManager") as SelectionManager

	var manager = null
	if construction_manager != null and not construction_manager.is_empty():
		manager = get_node_or_null(construction_manager) as ConstructionManager

	for building in build_catalog.buildings:
		var button = build_button_scene.instantiate() as Button
		if button is BuildButton:
			var build_button: BuildButton = button as BuildButton
			build_button.setup(building)
			if manager != null:
				build_button.construction_service = manager
			container.add_child(build_button)

func _process(_delta: float) -> void:
	update_resource_label()
	update_selected_unit_label()

func update_resource_label() -> void:
	var town_center: TownCenter = BuildingManager.get_nearest_town_center(Vector3.ZERO)
	var lines = []
	if town_center == null:
		lines.append("TownCenter not available")
	else:
		var stock: Dictionary = town_center.stored_resources
		var resource_names: Array = stock.keys()
		resource_names.sort()
		for resource_name in resource_names:
			var amount: int = int(stock.get(resource_name, 0))
			lines.append("%s: %d" % [resource_name, amount])

	var summary_text := "Base stock:\n"
	for i in range(lines.size()):
		summary_text += lines[i]
		if i < lines.size() - 1:
			summary_text += "\n"
	resource_summary_label.text = summary_text

func update_selected_unit_label() -> void:
	if selection_manager == null:
		var current_scene := get_tree().get_current_scene()
		if current_scene != null:
			selection_manager = current_scene.get_node_or_null("Managers/SelectionManager") as SelectionManager
	if selection_manager == null:
		selected_unit_summary_label.text = "Selected unit:\nNot found"
		return

	if selection_manager.selected_units.is_empty():
		selected_unit_summary_label.text = "Selected unit:\nNone"
		return

	var unit: BaseUnit = selection_manager.selected_units[0]
	if unit == null or not is_instance_valid(unit):
		selected_unit_summary_label.text = "Selected unit:\nNone"
		return

	var inventory: InventoryComponent = unit.inventory
	if inventory == null:
		selected_unit_summary_label.text = "Selected unit:\nNo inventory"
		return

	var lines = []
	lines.append("%s" % unit.name)
	lines.append("State: %s" % [get_unit_state_text(unit)])
	lines.append("Load: %d/%d" % [inventory.get_total_load(), inventory.capacity])
	var resource_names: Array = inventory.get_resource_names()
	for resource_name in resource_names:
		lines.append("%s: %d" % [resource_name, inventory.get_resource(resource_name)])

	var summary_text := "Selected unit:\n"
	for i in range(lines.size()):
		summary_text += lines[i]
		if i < lines.size() - 1:
			summary_text += "\n"
	selected_unit_summary_label.text = summary_text

func get_unit_state_text(unit: BaseUnit) -> String:
	match unit.unit_state:
		BaseUnit.UnitState.IDLE:
			return "Idle"
		BaseUnit.UnitState.MOVING:
			return "Moving"
		BaseUnit.UnitState.HARVESTING:
			return "Mining"
		BaseUnit.UnitState.RETURNING:
			return "Returning to base"
		BaseUnit.UnitState.DEPOSITING:
			return "Depositing"
		BaseUnit.UnitState.BUILDING:
			return "Building"
		BaseUnit.UnitState.ATTACKING:
			return "Attacking"
		BaseUnit.UnitState.DEATH:
			return "Dead"
		_:
			return "Unknown"
