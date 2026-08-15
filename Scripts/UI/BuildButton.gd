extends Button

class_name BuildButton

var building_data: BuildingData
var construction_service: ConstructionManager = null

func _ready() -> void:
	pressed.connect(_on_pressed)


func setup(data: BuildingData) -> void:
	building_data = data
	if data == null:
		text = "Build"
		return
	var cost_text := data.get_cost_text()
	text = data.building_name
	if cost_text != "":
		text += "\n" + cost_text


func _on_pressed() -> void:
	var target_name := "null"
	if building_data != null:
		target_name = building_data.building_name
	print("BuildButton pressed for:", target_name)
	if building_data == null:
		return

	if construction_service == null:
		var root := get_tree().get_root()
		if root.has_node("ConstructionManager"):
			construction_service = root.get_node("ConstructionManager") as ConstructionManager

	if construction_service != null:
		print("BuildButton using construction_service")
		construction_service.start_building(building_data)
		return

	var root := get_tree().get_root()
	if root.has_node("ConstructionManager"):
		var manager = root.get_node("ConstructionManager") as ConstructionManager
		print("BuildButton found /root/ConstructionManager")
		manager.start_building(building_data)
		return

	push_error("ConstructionManager is not available via root or autoload")
