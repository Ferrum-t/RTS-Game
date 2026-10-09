extends StaticBody3D
class_name BaseBuilding
# SEE artifacts/BaseBuilding_RESTORE.gd if this truncates — pull that file manually into Scripts/Buildings/BaseBuilding.gd

@export var team_id: int = 0
@export var max_health := 500
@export var nav_half_extents: Vector3 = Vector3(2.2, 1.0, 2.2)

var health := 500
var is_constructed := true
var is_destroyed := false
var construction_progress: float = 1.0
var build_time_sec: float = 25.0
var _construction_hp_granted: int = 0
const _CONSTRUCTION_START_HP_FRAC := 0.05

func begin_construction(p_build_time_sec: float) -> void:
	is_constructed = false
	construction_progress = 0.0
	build_time_sec = maxf(p_build_time_sec, 0.1)
	var start_hp: int = maxi(1, int(ceil(float(max_health) * _CONSTRUCTION_START_HP_FRAC)))
	health = start_hp
	_construction_hp_granted = start_hp
	print("[BUILD] ", name, " UNDER_CONSTRUCTION time=", build_time_sec, "s")

func add_construction_progress(delta_sec: float) -> bool:
	if is_destroyed: return false
	if is_constructed: return true
	var add: float = maxf(delta_sec, 0.0) / maxf(build_time_sec, 0.1)
	construction_progress = minf(1.0, construction_progress + add)
	if construction_progress >= 1.0:
		complete_construction()
		return true
	return false

func complete_construction() -> void:
	if is_constructed: return
	is_constructed = true
	construction_progress = 1.0
	health = clampi(health, 1, max_health)
	print("[BUILD] ", name, " COMPLETE (READY)")

func die() -> void:
	if is_destroyed: return
	is_destroyed = true
	queue_free()
