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
