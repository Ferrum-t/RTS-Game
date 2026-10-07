extends StaticBody3D

class_name ArtifactChest

## M31/M32 — chest. Click/attack Temirbat. Fills first free inventory slot.

const PICKUP_RADIUS := 3.0
var _taken: bool = false
var _ordered: bool = false
var source_label: String = "camp"


func _ready() -> void:
	add_to_group("ArtifactChest")
	add_to_group("LootChest")
	collision_layer = 1
	collision_mask = 0
	input_ray_pickable = true
	_setup_collision()
	_build_mesh()
	print("[M31] ArtifactChest SPAWNED at ", global_position, " — click or attack with Temirbat")


func _setup_collision() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.0, 2.5, 2.0)
	shape.shape = box
	shape.position = Vector3(0.0, 1.2, 0.0)
	add_child(shape)


func take_damage(_amount: int, source: Node = null) -> void:
	if _taken:
		return
	if source != null and is_instance_valid(source):
		if source.is_in_group("Hero") or (source is Temirbat):
			_ordered = true
			if global_position.distance_squared_to(source.global_position) <= PICKUP_RADIUS * PICKUP_RADIUS:
				_pickup(source)
				return
			if source.has_method("replace_order_move"):
				source.replace_order_move(global_position)
			print("[M31] Hero attacked chest — walk to loot")


func damage(amount: int, _attacker_team: int = -1) -> void:
	take_damage(amount, null)


func _input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if _taken:
		return
	if not (event is InputEventMouseButton and event.pressed):
		return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT and mb.button_index != MOUSE_BUTTON_RIGHT:
		return
	_order_hero_to_loot()
	get_viewport().set_input_as_handled()


func _order_hero_to_loot() -> void:
	if HeroProgress.is_inventory_full():
		print("[M32] inventory full — cannot order loot")
		return
	var hero: Node = _find_selected_hero()
	if hero == null:
		hero = _find_any_player_hero()
	if hero == null:
		print("[M31] Click chest — train/select Temirbat first")
		return
	_ordered = true
	if hero.has_method("replace_order_move"):
		hero.replace_order_move(global_position)
	print("[M31] Temirbat ordered to loot chest")


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
	if _taken:
		return
	if not _ordered:
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
	if not HeroProgress.grant_artifact(source_label):
		# Inventory full — leave chest on ground
		_ordered = false
		print("[M32] loot failed — inventory full, chest stays")
		return
	_taken = true
	print("[M32] LOOTED artifact (", source_label, ") at ", global_position)
	queue_free()


func _build_mesh() -> void:
	var pillar := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.35
	cyl.bottom_radius = 0.55
	cyl.height = 5.0
	pillar.mesh = cyl
	var pmat := StandardMaterial3D.new()
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pmat.albedo_color = Color(1.0, 0.85, 0.1, 1)
	pmat.emission_enabled = true
	pmat.emission = Color(1.0, 0.9, 0.2)
	pmat.emission_energy_multiplier = 3.5
	pillar.material_override = pmat
	pillar.position = Vector3(0.0, 2.5, 0.0)
	add_child(pillar)

	var box := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.4, 0.9, 1.0)
	box.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.95, 0.7, 0.1, 1)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.75, 0.15)
	mat.emission_energy_multiplier = 2.5
	box.material_override = mat
	box.position = Vector3(0, 0.5, 0)
	add_child(box)

	var lid := MeshInstance3D.new()
	var lm := BoxMesh.new()
	lm.size = Vector3(1.5, 0.2, 1.1)
	lid.mesh = lm
	var lmat := StandardMaterial3D.new()
	lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lmat.albedo_color = Color(0.8, 0.45, 0.05, 1)
	lid.material_override = lmat
	lid.position = Vector3(0, 1.05, 0)
	add_child(lid)

	var disc := MeshInstance3D.new()
	var dmesh := CylinderMesh.new()
	dmesh.top_radius = 2.2
	dmesh.bottom_radius = 2.2
	dmesh.height = 0.08
	disc.mesh = dmesh
	var dmat := StandardMaterial3D.new()
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmat.albedo_color = Color(1.0, 0.9, 0.2, 0.65)
	dmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dmat.emission_enabled = true
	dmat.emission = Color(1.0, 0.85, 0.1)
	dmat.emission_energy_multiplier = 2.0
	disc.material_override = dmat
	disc.position = Vector3(0.0, 0.04, 0.0)
	add_child(disc)
