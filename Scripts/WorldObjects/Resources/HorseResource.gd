extends BaseResource

class_name HorseResource

## Semi-static herd node — harvest like Tree/Stone (v1.0, no AI flee).


func _ready() -> void:
	resource_type = Type.HORSES
	if resource_amount <= 0 or resource_amount == 500:
		resource_amount = 200
	super()
