extends Control

signal selection_finished(rect: Rect2)

@onready var rect := $SelectionRect

var dragging := false
var start_position := Vector2.ZERO
func _ready():
	print(rect)
	rect.visible = false

func _unhandled_input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				start_position = event.position
				rect.visible = true
				rect.position = start_position
				rect.size = Vector2.ZERO
			else:
				dragging = false
				rect.visible = false
				var selection = Rect2(rect.position, rect.size)
				print(selection)
				selection_finished.emit(selection)
				

func _process(_delta):
	if not dragging:
		return
	var current = get_viewport().get_mouse_position()
	rect.position = Vector2(
	min(start_position.x, current.x),
	min(start_position.y, current.y)
)
	rect.size = Vector2(
	abs(current.x - start_position.x),
	abs(current.y - start_position.y)
)
func get_selection_rect() -> Rect2:

	return Rect2(rect.position, rect.size)
