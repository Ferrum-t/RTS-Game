extends BaseBuilding

class_name TownCenter


func _ready() -> void:
	super()
	add_to_group("Obstacle")
	print("TownCenter ready at: ", global_position)
