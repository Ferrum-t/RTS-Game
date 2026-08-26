extends Button

## Pack first player Town Center (DEPLOYED → PACKING → MOBILE).
## Same path as TownCenter debug KEY_P → debug_pack() → request_pack().


func _ready() -> void:
	text = "Pack TC"
	pressed.connect(_on_pressed)


func _process(_delta: float) -> void:
	_refresh_enabled()


func _refresh_enabled() -> void:
	var tc := _get_player_tc()
	if tc == null:
		disabled = true
		return
	var st: int = int(tc.get("deployment_state"))
	# Pack only from DEPLOYED (same as DeploymentComponent.can_pack)
	disabled = st != DeploymentState.State.DEPLOYED or tc.get("is_destroyed") == true


func _on_pressed() -> void:
	var tc := _get_player_tc()
	if tc == null:
		print("Pack: no player Town Center")
		return
	if tc.has_method("request_pack"):
		tc.request_pack()
	elif tc.has_method("debug_pack"):
		tc.debug_pack()


func _get_player_tc():
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return null
	for tc in bm.town_centers:
		if tc == null or not is_instance_valid(tc):
			continue
		if int(tc.get("team_id")) == 0:
			return tc
	return null
