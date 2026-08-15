extends Resource

class_name BuildingData

@export var building_name : String

@export var building_scene : PackedScene

@export var ghost_scene : PackedScene

@export var icon : Texture2D

@export_group("Cost")

@export var wood : int = 0
@export var stone : int = 0
@export var gold : int = 0
@export var food : int = 0

func get_cost() -> Dictionary:
	return {
		"Wood": wood,
		"Stone": stone,
		"Gold": gold,
		"Food": food
	}

func get_cost_text() -> String:
	var parts := []
	if wood > 0:
		parts.append("%dw" % wood)
	if stone > 0:
		parts.append("%ds" % stone)
	if gold > 0:
		parts.append("%dg" % gold)
	if food > 0:
		parts.append("%df" % food)
	var result := ""
	for i in range(parts.size()):
		result += parts[i]
		if i < parts.size() - 1:
			result += " "
	return result
