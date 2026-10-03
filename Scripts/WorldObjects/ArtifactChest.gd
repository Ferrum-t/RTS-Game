extends Node3D

class_name ArtifactChest

## M31 — gold chest on ground. Temirbat picks up in radius → HeroProgress.

const PICKUP_RADIUS := 2.8
var _taken: bool = false
var source_label: String = "camp"


func _ready() -> void:
	add_to_group("ArtifactChest")
	_build_mesh()
	print("[M31] ArtifactChest at ", global_position)


func _process(_delta: float) -> void:
	if _taken:
		return
	for n in get_tree().get_nodes_in_group("Hero"):
		if not (n is Temirbat):
			continue
		var h: Temirbat = n as Temirbat
		if not is_instance_valid(h) or h.unit_state == BaseUnit.UnitState.DEAD:
			continue
		if global_position.distance_squared_to(h.global_position) <= PICKUP_RADIUS * PICKUP_RADIUS:
			_pickup(h)
			return


func _pickup(_hero: Temirbat) -> void:
	if _taken:
		return
	_taken = true
	HeroProgress.grant_artifact(source_label)
	print("[M31] Temirbat picked up artifact (", source_label, ")")
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
	# Lid hint
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
