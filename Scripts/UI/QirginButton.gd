extends Button

## M28 — Cast Qırğın when Temirbat is selected.


func _ready() -> void:
	text = "Qırğın (Q) 40 mana"
	pressed.connect(_on_pressed)
	_refresh()


func _process(_delta: float) -> void:
	_refresh()


func _refresh() -> void:
	var hero := _resolve_temirbat()
	if hero == null:
		disabled = true
		text = "Qırğın — no hero"
		return
	if not hero.can_cast_qirgin():
		disabled = true
		if hero._qirgin_cd > 0.0:
			text = "Qırğın CD %.0fs" % hero._qirgin_cd
		elif hero.mana < Temirbat.QIRGIN_COST:
			text = "Qırğın — need mana (%d)" % int(hero.mana)
		else:
			text = "Qırğın — blocked"
		return
	disabled = false
	text = "Qırğın (Q) 40 mana"


func _on_pressed() -> void:
	var hero := _resolve_temirbat()
	if hero:
		hero.try_cast_qirgin()


func _resolve_temirbat() -> Temirbat:
	var sm := get_node_or_null("/root/SelectionManager")
	if sm != null and sm.has_method("get_valid_selection"):
		for u in sm.get_valid_selection():
			if u is Temirbat and is_instance_valid(u) and u.unit_state != BaseUnit.UnitState.DEAD:
				return u as Temirbat
	for n in get_tree().get_nodes_in_group("Hero"):
		if n is Temirbat and is_instance_valid(n) and int(n.team_id) == 0 and n.unit_state != BaseUnit.UnitState.DEAD:
			if n.selected:
				return n as Temirbat
	return null
