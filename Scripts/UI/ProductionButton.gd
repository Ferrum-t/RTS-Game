extends Button

class_name ProductionButton

var unit_data: UnitData
var production_service: ProductionManager

func _ready() -> void:
	pressed.connect(_on_pressed)

func setup(data: UnitData) -> void:
	unit_data = data
	if data == null:
		text = "Train"
		return
	var cost_text := data.get_cost_text()
	text = data.unit_name
	if cost_text != "":
		text += "\n" + cost_text

func _on_pressed() -> void:
	if unit_data == null:
		return
	if production_service != null:
		production_service.produce_unit(unit_data)
	else:
		print("Production service is not assigned")
