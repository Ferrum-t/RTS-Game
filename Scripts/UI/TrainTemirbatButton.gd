extends Button

## M27/M29/M33 — Train or revive Temirbat from Orunqar (max 1 alive).

const COST_WOOD := 120
const COST_FOOD := 3
const COST_HORSES := 1
const PLAYER_TEAM := 0


func _ready() -> void:
	text = "Temirbat (120W+3F+1H)"
	pressed.connect(_on_pressed)
	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.resources_changed.connect(_refresh_state)
	_refresh_state()


func _process(_delta: float) -> void:
	_refresh_state()


func _refresh_state() -> void:
	var orun = _resolve_orunqar()
	var rm := get_node_or_null("/root/ResourceManager")
	if orun == null:
		disabled = true
		text = "Temirbat — no Orunqar"
		return
	if Orunqar.match_hero_alive:
		disabled = true
		text = "Temirbat — alive"
		return
	if Orunqar.match_revive_cd > 0.0:
		disabled = true
		text = "Revive in %.0fs" % Orunqar.match_revive_cd
		return
	if orun.is_training:
		disabled = true
		var p: float = 0.0
		if orun.has_method("get_train_progress"):
			p = float(orun.get_train_progress())
		text = "Training... %d%%" % int(p * 100.0)
		return
	if rm == null or not rm.can_afford(ResourceManager.make_cost(COST_WOOD, 0, 0, COST_FOOD, COST_HORSES), PLAYER_TEAM):
		disabled = true
		text = "Temirbat — need resources"
		return
	disabled = false
	text = "Temirbat (120W+3F+1H)"


func _on_pressed() -> void:
	var orun = _resolve_orunqar()
	if orun and orun.has_method("try_train_temirbat"):
		orun.try_train_temirbat()


func _resolve_orunqar():
	var sm := get_node_or_null("/root/SelectionManager")
	if sm != null:
		if sm.has_method("get_selected_buildings"):
			for b in sm.get_selected_buildings():
				if b is Orunqar and is_instance_valid(b) and not b.is_destroyed:
					return b
		elif sm.has_method("get_selected_mobile_buildings"):
			for b in sm.get_selected_mobile_buildings():
				if b is Orunqar and is_instance_valid(b) and not b.is_destroyed:
					return b
		elif "selected_buildings" in sm:
			for b in sm.selected_buildings:
				if b is Orunqar and is_instance_valid(b) and not b.is_destroyed:
					return b
	for n in get_tree().get_nodes_in_group("Orunqar"):
		if n is Orunqar and is_instance_valid(n) and int(n.team_id) == PLAYER_TEAM and not n.is_destroyed:
			return n
	return null
