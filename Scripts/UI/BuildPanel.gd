extends PanelContainer

@onready var container = $VBoxContainer

@export var build_catalog : BuildCatalog
@export var build_button_scene : PackedScene


func _ready():

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
