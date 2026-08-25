extends StaticBody3D

class_name BaseResource

## 0=wood, 1=stone, 2=gold, 3=food, 4=horses
enum Type { WOOD = 0, STONE = 1, GOLD = 2, FOOD = 3, HORSES = 4 }

@export var resource_type: Type = Type.WOOD
@export var resource_amount: int = 500


func _ready() -> void:
	add_to_group("Resource")
	print(name, " resource ready type=", resource_type, " amount=", resource_amount)


func harvest(amount: int) -> int:
	if amount <= 0 or resource_amount <= 0:
		return 0
	var taken: int = mini(amount, resource_amount)
	resource_amount -= taken
	if resource_amount <= 0:
		resource_amount = 0
		print(name, " depleted")
		queue_free()
	return taken
