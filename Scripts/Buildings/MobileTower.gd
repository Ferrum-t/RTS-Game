extends MobileBuilding

class_name MobileTower

## Phase 8.1 — mobile defensive tower.
## Deployment: DeploymentComponent (same path as TownCenter).
## Combat: child BuildingCombatComponent (Phase 8.0) — fires only while DEPLOYED.
## No deployment efficiency multipliers (Phase 8.2).
## No unit MovementComponent.

func _ready() -> void:
	super()
	add_to_group("Obstacle")
	print(
		"[TOWER] ", name, " ready team=", team_id,
		" HP=", health, "/", max_health,
		" deployment=", deployment_state
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
