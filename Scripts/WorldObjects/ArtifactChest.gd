extends StaticBody3D

class_name ArtifactChest

## M31 — gold chest. Drop at last kill. Click → Temirbat walks & picks up.

const PICKUP_RADIUS := 2.5
var _taken: bool = false
var _ordered: bool = false
var source_label: String = "camp"


func _ready() -> void:
	add_to_group("ArtifactChest")
	collision_layer = 1
	collision_mask = 0
	input_ray_pickable = true
	_setup_collision()
	_build_mesh()
	print("[M31] ArtifactChest at ", global_position, " — click to loot")


func _setup_collision() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.2, 1.0, 1.2)
	shape.shape = box
	shape.position = Vector3(0.0, 0.5, 0.0)
	add_child(shape)


func _input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if _taken:
		return
	if not (event is InputEventMouseButton and event.pressed):
		return
	var mb := event as InputEventMouseButton
	# LMB or RMB on chest → order selected hero to loot
	if mb.button_index != MOUSE_BUTTON_LEFT and mb.button_index != MOUSE_BUTTON_RIGHT:
		return
	_order_hero_to_loot()
	get_viewport().set_input_as_handled()


func _order_hero_to_loot() -> void:
	var hero: Node = _find_selected_hero()
	if hero == null:
		hero = _find_any_player_hero()
	if hero == null:
		print("[M31] Click chest — no Temirbat (train/select hero first)")
		return
	_ordered = true
	if hero.has_method("replace_order_move"):
		hero.replace_order_move(global_position)
	print("[M31] Temirbat ordered to loot chest at ", global_position)


func _find_selected_hero() -> Node:
	for n in get_tree().get_nodes_in_group("Hero"):
		if not is_instance_valid(n):
			continue
		if n.get("selected") == true and int(n.get("team_id")) == 0:
			if n.get("unit_state") != null and int(n.unit_state) == int(BaseUnit.UnitState.DEAD):
				continue
			return n
	return null


func _find_any_player_hero() -> Node:
	for n in get_tree().get_nodes_in_group("Hero"):
		if not is_instance_valid(n):
			continue
		if int(n.get("team_id")) != 0:
			continue
		if n.get("unit_state") != null and int(n.unit_state) == int(BaseUnit.UnitState.DEAD):
			continue
		return n
	return null


func _process(_delta: float) -> void:
	if _taken or not _ordered:
		return
	for n in get_tree().get_nodes_in_group("Hero"):
		if not is_instance_valid(n):
			continue
		if int(n.get("team_id")) != 0:
			continue
		if n.get("unit_state") != null and int(n.unit_state) == int(BaseUnit.UnitState.DEAD):
			continue
		if global_position.distance_squared_to(n.global_position) <= PICKUP_RADIUS * PICKUP_RADIUS:
			_pickup(n)
			return


func _pickup(_hero: Node) -> void:
	if _taken:
		return
	_taken = true
	HeroProgress.grant_artifact(source_label)
	print("[M31] Temirbat looted artifact (", source_label, ")")
	queue_free()


func _build_mesh() -> void:
	var box := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.9, 0.6, 0.7)
	box.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.95, 0.75, 0.15, 1)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.8, 0.2)
	mat.emission_energy_multiplier = 1.8
	box.material_override = mat
	box.position = Vector3(0, 0.35, 0)
	add_child(box)
	var lid := MeshInstance3D.new()
	var lm := BoxMesh.new()
	lm.size = Vector3(0.95, 0.12, 0.75)
	lid.mesh = lm
	var lmat := StandardMaterial3D.new()
	lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lmat.albedo_color = Color(0.75, 0.5, 0.1, 1)
	lid.material_override = lmat
	lid.position = Vector3(0, 0.7, 0)
	add_child(lid)
