extends Node

class_name HarvestComponent

@export var harvest_time: float = 1.0
@export var harvest_amount: int = 1

var _timer: float = 0.0
@onready var unit: BaseUnit = get_parent() as BaseUnit


func tick_harvest(delta: float, target_resource: Node) -> void:
	if target_resource == null or not is_instance_valid(target_resource):
		return

	_timer += delta
	if _timer >= harvest_time:
		_timer = 0.0

		if target_resource.has_method("harvest"):
			var gathered: int = target_resource.call("harvest", harvest_amount)

			if gathered > 0 and unit.inventory != null:
				var res_name: String = target_resource.get("resource_name") if "resource_name" in target_resource else "Resource"
				var overflow: int = unit.inventory.add_resource(res_name, gathered)
				if overflow > 0:
					print("Inventory full!")
