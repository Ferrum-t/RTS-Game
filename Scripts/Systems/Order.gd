extends RefCounted
class_name Order

## M8.1 — player/AI intent as a data object.
## Execution still lives on BaseUnit target fields + components.
## Order does not drive velocity, pathfinding, or unit_state by itself.

enum Type {
	NONE,
	MOVE,
	HARVEST,
	ATTACK,
	ATTACK_BUILDING,
	BUILD,
}

var type: Type = Type.NONE
var target: Variant = null
var params: Dictionary = {}


func _init(p_type: Type = Type.NONE, p_target: Variant = null, p_params: Dictionary = {}) -> void:
	type = p_type
	target = p_target
	params = p_params


static func none() -> Order:
	return Order.new(Type.NONE, null, {})


func is_none() -> bool:
	return type == Type.NONE


func type_name() -> String:
	match type:
		Type.NONE:
			return "NONE"
		Type.MOVE:
			return "MOVE"
		Type.HARVEST:
			return "HARVEST"
		Type.ATTACK:
			return "ATTACK"
		Type.ATTACK_BUILDING:
			return "ATTACK_BUILDING"
		Type.BUILD:
			return "BUILD"
		_:
			return str(type)
