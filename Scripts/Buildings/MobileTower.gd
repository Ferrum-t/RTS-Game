extends MobileBuilding

class_name MobileTower

## Phase 8.1 mobility + Phase 8.2 DeploymentConfig (fast pack, vuln 1.3, range ring).

func _ready() -> void:
	if deployment_config == null:
		deployment_config = DeploymentConfig.preset_watchtower()
	super()
	add_to_group("Obstacle")
	print(
		"[TOWER] ", name, " ready team=", team_id,
		" HP=", health, "/", max_health,
		" deployment=", deployment_state,
		" pack=", pack_time, "s speed=", mobile_move_speed,
		" vuln=", vulnerability_multiplier
	)
	if OS.is_debug_build() and team_id == 0:
		print("[TOWER] debug keys: P=pack  M=move(8,0,5)  U=unpack")


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if team_id != 0:
		return
	if is_destroyed:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key := event as InputEventKey
	match key.keycode:
		KEY_P:
			request_pack()
			get_viewport().set_input_as_handled()
		KEY_M:
			request_move_to(global_position + Vector3(8.0, 0.0, 5.0))
			get_viewport().set_input_as_handled()
		KEY_U:
			request_unpack()
			get_viewport().set_input_as_handled()
