extends StaticBody3D

class_name BaseBuilding


func _ready():

	BuildingManager.register_building(self)


func _exit_tree():

	BuildingManager.unregister_building(self)
