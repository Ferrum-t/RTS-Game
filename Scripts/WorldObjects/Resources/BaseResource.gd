extends StaticBody3D

class_name BaseResource

@export var resource_amount: int = 500


func _ready() -> void:
	add_to_group("Resource")


## Take up to `amount` from this node. Returns how much was actually taken.
func harvest(amount: int) -> int:
	if amount <= 0 or resource_amount <= 0:
		return 0
	var taken: int = mini(amount, resource_amount)
	resource_amount -= taken
	if resource_amount <= 0:
		resource_amount = 0
		queue_free()
	return taken
