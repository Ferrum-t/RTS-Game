extends Button

class_name BuildButton

var building_data: BuildingData


func setup(data: BuildingData):

	building_data = data

	text = data.building_name


func _pressed():

	ConstructionManager.start_building(building_data)
