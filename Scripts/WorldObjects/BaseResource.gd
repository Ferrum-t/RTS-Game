extends StaticBody3D

class_name BaseResource

@export var resource_name := "Wood"
@export var amount := 300
@export var interaction_distance := 2.5

func _ready():
	add_to_group("Resource")
	add_to_group("Obstacle")
