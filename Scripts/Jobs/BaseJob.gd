extends RefCounted

class_name BaseJob


var finished: bool = false


@warning_ignore("unused_parameter")
func start(unit: BaseUnit) -> void:
	pass


@warning_ignore("unused_parameter")
func update(unit: BaseUnit, delta: float) -> void:
	pass


func is_finished() -> bool:
	return finished
