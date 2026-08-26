extends Button

## Unpack first player Town Center (MOBILE → UNPACKING → DEPLOYED).
## Same path as TownCenter debug KEY_U → debug_unpack() → request_unpack().


func _ready() -> void:
	text = "Unpack TC"
	pressed.connect(_on_pressed)


func _process(_delta: float) -> void:
	_refresh_enabled()


func _refresh_enabled() -> void:
	var tc: Node = _get_player_tc()
	if tc == null:
		disabled = true
		return
	var st: int = int(tc.get("deployment_state"))
	# Unpack only from MOBILE (same as DeploymentComponent.can_unpack)
	disabled = st != DeploymentState.State.MOBILE or tc.get("is_destroyed") == true


func _on_pressed() -> void:
	var tc: Node = _get_player_tc()
	if tc == null:
		print("Unpack: no player Town Center")
		return
	if tc.has_method("request_unpack"):
		tc.request_unpack()
	elif tc.has_method("debug_unpack"):
		tc.debug_unpack()


func _get_player_tc() -> Node:
	var bm: Node = get_node_or_null("/root/BuildingManager")
	if bm == null:
		return null
	var list: Array = bm.get("town_centers")
	if list == null:
		return null
	for item in list:
		var tc: Node = item as Node
		if tc == null or not is_instance_valid(tc):
			continue
		if int(tc.get("team_id")) == 0:
			return tc
	return null
