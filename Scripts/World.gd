extends Node3D



func _ready() -> void:
	pass

func _process(_delta):
	pass

func _unhandled_input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ConstructionManager.confirm_build()
