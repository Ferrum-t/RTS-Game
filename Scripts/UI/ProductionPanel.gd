extends PanelContainer

@onready var container: VBoxContainer = $VBoxContainer

@export var unit_catalog: UnitCatalog
@export var production_button_scene: PackedScene
@export var production_manager: NodePath

var production_service: ProductionManager

func _ready() -> void:
	if unit_catalog == null:
		push_error("UnitCatalog is not assigned!")
		return
	if production_button_scene == null:
		push_error("ProductionButton scene is not assigned!")
		return

	if production_manager != null and not production_manager.is_empty():
		production_service = get_node(production_manager) as ProductionManager

	for unit_data in unit_catalog.units:
		var button = production_button_scene.instantiate() as Button
		if button is ProductionButton:
			var production_button: ProductionButton = button as ProductionButton
			production_button.setup(unit_data)
			production_button.production_service = production_service
		container.add_child(button)
