extends Node3D


func _ready() -> void:
	pass


func _process(_delta) -> void:
	pass


func _unhandled_input(event) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			var cm := get_node_or_null("/root/ConstructionManager")
			if cm != null and cm.has_method("is_placing") and cm.is_placing():
				cm.cancel_build_mode()
				get_viewport().set_input_as_handled()
				return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ConstructionManager.confirm_build()
