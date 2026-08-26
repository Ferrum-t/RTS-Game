extends StaticBody3D

class_name BaseResource

## 0=wood, 1=stone, 2=gold, 3=food, 4=horses
enum Type { WOOD = 0, STONE = 1, GOLD = 2, FOOD = 3, HORSES = 4 }

@export var resource_type: Type = Type.WOOD
@export var resource_amount: int = 500
## NavMesh carve half-extents (XZ). Keeps paths outside physics shape.
@export var nav_half_extents: Vector3 = Vector3(1.0, 1.0, 1.0)


func _ready() -> void:
	add_to_group("Resource")
	print(name, " resource ready type=", resource_type, " amount=", resource_amount)
	# Register as nav obstruction so harvest paths go around trees/stones/herds
	# (same bake pipeline as buildings — not a second pathfinding system).
	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav != null and nav.has_method("register_building"):
		nav.register_building(self, nav_half_extents)
	tree_exiting.connect(_on_tree_exiting)


func _on_tree_exiting() -> void:
	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav != null and nav.has_method("unregister_building"):
		nav.unregister_building(self)


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
