extends Button

## Pack all team-0 MobileBuildings that are DEPLOYED (TC + Watchtowers).
## Raise Entire Settlement style — not TC-only.


func _ready() -> void:
	text = "Pack"
	pressed.connect(_on_pressed)


func _process(_delta: float) -> void:
	_refresh_enabled()


func _refresh_enabled() -> void:
	disabled = _count_packable() == 0


func _on_pressed() -> void:
	var n: int = 0
	for b in _player_mobile_buildings():
		if int(b.get("deployment_state")) != DeploymentState.State.DEPLOYED:
			continue
		if b.get("is_destroyed") == true:
			continue
		if b.has_method("request_pack") and b.request_pack():
			n += 1
	print("Pack: started on ", n, " mobile building(s)")


func _count_packable() -> int:
	var c: int = 0
	for b in _player_mobile_buildings():
		if b.get("is_destroyed") == true:
			continue
		if int(b.get("deployment_state")) == DeploymentState.State.DEPLOYED:
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
