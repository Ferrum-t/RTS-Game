extends Button

class_name BuildButton

var building_data: BuildingData


func setup(data: BuildingData) -> void:
	building_data = data
	if data == null:
		text = "?"
		return

	var cost_parts: PackedStringArray = []
	if data.wood > 0:
		cost_parts.append("W:%d" % data.wood)
	if data.stone > 0:
		cost_parts.append("S:%d" % data.stone)
	if data.gold > 0:
		cost_parts.append("G:%d" % data.gold)
	if data.food > 0:
		cost_parts.append("F:%d" % data.food)

	if cost_parts.is_empty():
		text = data.building_name
	else:
		text = "%s (%s)" % [data.building_name, ", ".join(cost_parts)]


func _pressed() -> void:
	if building_data == null:
		return
	ConstructionManager.start_building(building_data)
