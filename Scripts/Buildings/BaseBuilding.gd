extends StaticBody3D

class_name BaseBuilding


func _ready() -> void:
	add_to_group("Obstacle")

	# Access Autoload by node path — avoids class_name vs singleton conflict
	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.register_building(self)
	else:
		push_warning("BuildingManager autoload not found")


func _exit_tree() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.unregister_building(self)
