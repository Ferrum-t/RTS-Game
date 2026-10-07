extends Button

## Unpack selected player MobileBuildings if any are selected;
## otherwise unpack all team-0 MOBILE buildings.


func _ready() -> void:
	text = "Unpack"
	pressed.connect(_on_pressed)


func _process(_delta: float) -> void:
	_refresh_enabled()


func _refresh_enabled() -> void:
	disabled = _unpackable_targets().is_empty()


func _on_pressed() -> void:
	var targets: Array = _unpackable_targets()
	if targets.is_empty():
		print("Unpack: no mobile building ready (still moving or not packed)")
		return
	var n: int = 0
	var failed: int = 0
	for b in targets:
		if b.has_method("request_unpack") and b.request_unpack():
			n += 1
		else:
			failed += 1
	var mode: String = "selected" if _has_building_selection() else "all"
	print("Unpack: started on ", n, " mobile building(s) [", mode, "]")
	if n == 0 and failed > 0:
		print("Unpack: blocked — too close to another building. Move tower a bit, then Unpack.")
		text = "Blocked!"
		await get_tree().create_timer(1.2).timeout
		if is_instance_valid(self):
			text = "Unpack"


func _unpackable_targets() -> Array:
	var out: Array = []
	for b in _candidate_buildings():
		if b.get("is_destroyed") == true:
			continue
		if int(b.get("deployment_state")) != DeploymentState.State.MOBILE:
			continue
		var dep = b.get("deployment")
		if dep != null and dep.has_method("can_unpack") and not dep.can_unpack():
			continue
		out.append(b)
	return out


func _candidate_buildings() -> Array:
	if _has_building_selection():
		return _selected_buildings()
	return _all_player_mobile()


func _has_building_selection() -> bool:
	return not _selected_buildings().is_empty()


func _selected_buildings() -> Array:
	var sm: Node = get_tree().get_first_node_in_group("selection_manager")
	if sm == null:
		return []
	if sm.has_method("get_selected_mobile_buildings"):
		return sm.get_selected_mobile_buildings()
	return []


func _all_player_mobile() -> Array:
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
