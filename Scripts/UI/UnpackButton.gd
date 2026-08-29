extends Button

## Unpack all team-0 MobileBuildings that are MOBILE (TC + Watchtowers).


func _ready() -> void:
	text = "Unpack"
	pressed.connect(_on_pressed)


func _process(_delta: float) -> void:
	_refresh_enabled()


func _refresh_enabled() -> void:
	disabled = _count_unpackable() == 0


func _on_pressed() -> void:
	var n: int = 0
	for b in _player_mobile_buildings():
		if int(b.get("deployment_state")) != DeploymentState.State.MOBILE:
			continue
		if b.get("is_destroyed") == true:
			continue
		if b.has_method("request_unpack") and b.request_unpack():
			n += 1
	print("Unpack: started on ", n, " mobile building(s)")


func _count_unpackable() -> int:
	var c: int = 0
	for b in _player_mobile_buildings():
		if b.get("is_destroyed") == true:
			continue
		if int(b.get("deployment_state")) == DeploymentState.State.MOBILE:
			c += 1
	return c


func _player_mobile_buildings() -> Array:
	var out: Array = []
	var bm: Node = get_node_or_null("/root/BuildingManager")
	if bm == null:
		return out
	var list = bm.get("buildings")
	if list == null:
		return out
	for item in list:
		var b: Node = item as Node
		if b == null or not is_instance_valid(b):
			continue
		if int(b.get("team_id")) != 0:
			continue
		if not (b is MobileBuilding):
			continue
		out.append(b)
	return out
