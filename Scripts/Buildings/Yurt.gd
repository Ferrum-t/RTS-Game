extends BaseBuilding

class_name Yurt

## M21.2 — Static food supply tent. Passive stock income while READY.
## No Pack/Unpack. No training. No AI auto-build.

const FOOD_PER_TICK := 1
const TICK_SEC := 8.0

var _tick_timer: float = 0.0


func _ready() -> void:
	base_max_health = 300
	max_health = 300
	health = 300
	super()
	add_to_group("Obstacle")
	nav_half_extents = Vector3(1.6, 1.0, 1.6)
	print("Yurt ready at: ", global_position, " team=", team_id)


func _process(delta: float) -> void:
	if not is_constructed or is_destroyed or health <= 0:
		_tick_timer = 0.0
		return
	_tick_timer += delta
	if _tick_timer < TICK_SEC:
		return
	_tick_timer = 0.0
	_grant_food()


func _grant_food() -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	rm.add_food(FOOD_PER_TICK, team_id)
	if team_id == 0 and OS.is_debug_build():
		print("[YURT] +", FOOD_PER_TICK, " Food team=", team_id, " (tick ", TICK_SEC, "s)")
