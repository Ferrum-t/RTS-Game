extends BaseResource

class_name HorseResource

## Semi-static herd — harvest like Tree/Stone (v1.0, no AI flee).
## Climate v0.1 C2: reversible suspend in COLD/DRY; resume on FAVORABLE.
## queue_free only via normal depletion in BaseResource.harvest.

var climate_suspended: bool = false
var _climate_cached_amount: int = 0


func _ready() -> void:
	resource_type = Type.HORSES
	if resource_amount <= 0 or resource_amount == 500:
		resource_amount = 200
	super()


## Climate v0.1 — never frees the node; amount restored on resume.
func set_climate_suspended(suspended: bool) -> void:
	if suspended:
		if climate_suspended:
			return
		climate_suspended = true
		_climate_cached_amount = resource_amount
		resource_amount = 0
		print("[CLIMATE] horse suspended ", name, " cached=", _climate_cached_amount)
	else:
		if not climate_suspended:
			return
		climate_suspended = false
		resource_amount = maxi(_climate_cached_amount, 0)
		_climate_cached_amount = 0
		print("[CLIMATE] horse resumed ", name, " amount=", resource_amount)


func is_climate_suspended() -> bool:
	return climate_suspended


func harvest(amount: int) -> int:
	if climate_suspended:
		return 0
	return super.harvest(amount)
