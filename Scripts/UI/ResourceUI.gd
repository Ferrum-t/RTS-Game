extends Label

## Simple top-bar resource display.
## Same pattern for every stockpile field (Wood/Stone/Gold/Food/Horses).


func _ready() -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.resources_changed.connect(_on_resources_changed)
		_on_resources_changed()
	else:
		text = "Wood: 0"
		push_warning("ResourceManager not found")


func _on_resources_changed() -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	text = "Wood: %d    Stone: %d    Gold: %d    Food: %d    Horses: %d" % [
		rm.wood, rm.stone, rm.gold, rm.food, rm.horses
	]
