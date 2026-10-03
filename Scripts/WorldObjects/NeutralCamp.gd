extends Node3D

class_name NeutralCamp

## M27/M30 — Static creep camp.
## MELEE: 4 Creeps, 80W+40S + HP buff on Temirbat
## ARCHER: 3 CreepArchers, 120W+60S + dmg buff on Temirbat

enum CampKind { MELEE, ARCHER }

var camp_kind: CampKind = CampKind.MELEE
var creep_scene: PackedScene
var creep_count: int = 4
var reward_wood: int = 80
var reward_stone: int = 40
var spawn_radius: float = 3.5

var _creeps: Array = []
var _cleared: bool = false
var _reward_team: int = 0
var _configured: bool = false


func _ready() -> void:
	add_to_group("NeutralCamp")
	# If World already called setup_kind, spawn now; else wait one frame.
	if _configured:
		_finish_setup()
	else:
		call_deferred("_finish_setup")


## Called by World before/after add_child. kind: 0=MELEE, 1=ARCHER
func setup_kind(kind: int) -> void:
	camp_kind = CampKind.ARCHER if kind == 1 else CampKind.MELEE
	_configured = true
	_apply_kind_defaults()
	if is_inside_tree() and _creeps.is_empty() and not _cleared:
		_finish_setup()


func _apply_kind_defaults() -> void:
	match camp_kind:
		CampKind.ARCHER:
			creep_count = 3
			reward_wood = 120
			reward_stone = 60
			spawn_radius = 4.0
			if creep_scene == null:
				creep_scene = load("res://Scenes/Units/creep_archer.tscn") as PackedScene
		_:
			creep_count = 4
			reward_wood = 80
			reward_stone = 40
			spawn_radius = 3.5
			if creep_scene == null:
				creep_scene = load("res://Scenes/Units/creep.tscn") as PackedScene


func _finish_setup() -> void:
	if not _configured:
		_apply_kind_defaults()
		_configured = true
	if has_node("CampMarker"):
		return  # already set up
	_setup_marker()
	_spawn_creeps()
	print("[M30] NeutralCamp READY kind=", CampKind.keys()[camp_kind],
		" pos=", global_position, " creeps=", creep_count)


func _setup_marker() -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = "CampMarker"
	var cyl := CylinderMesh.new()
	# Tall pillar so camera spots it easily
	cyl.top_radius = 0.6
	cyl.bottom_radius = 1.4
	cyl.height = 4.0
	mesh.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	if camp_kind == CampKind.ARCHER:
		mat.albedo_color = Color(0.25, 0.45, 0.95, 1.0)
		mat.emission = Color(0.2, 0.4, 1.0)
		mat.emission_energy_multiplier = 2.0
	else:
		mat.albedo_color = Color(0.85, 0.35, 0.12, 1.0)
		mat.emission = Color(0.9, 0.3, 0.05)
		mat.emission_energy_multiplier = 2.0
	mesh.material_override = mat
	mesh.position = Vector3(0.0, 2.0, 0.0)
	add_child(mesh)
	# Ground disc
	var disc := MeshInstance3D.new()
	var dmesh := CylinderMesh.new()
	dmesh.top_radius = 2.5
	dmesh.bottom_radius = 2.5
	dmesh.height = 0.12
	disc.mesh = dmesh
	var dmat := StandardMaterial3D.new()
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmat.albedo_color = mat.albedo_color
	dmat.albedo_color.a = 0.7
	disc.material_override = dmat
	disc.position = Vector3(0.0, 0.06, 0.0)
	add_child(disc)


func note_attacker_team(team: int) -> void:
	if team != -1:
		_reward_team = team


func _spawn_creeps() -> void:
	if creep_scene == null:
		push_error("NeutralCamp: creep_scene null kind=", camp_kind)
		return
	for i in creep_count:
		var angle: float = TAU * float(i) / float(creep_count)
		var offset := Vector3(cos(angle) * spawn_radius, 0.0, sin(angle) * spawn_radius)
		var c: Node3D = creep_scene.instantiate()
		if c == null:
			continue
		c.name = ("CreepArcher_%d" if camp_kind == CampKind.ARCHER else "Creep_%d") % i
		var parent: Node = get_tree().current_scene
		if parent == null:
			parent = self
		parent.add_child(c)
		c.global_position = global_position + offset
		if c is Creep:
			var creep: Creep = c as Creep
			creep.owning_camp = self
			_creeps.append(creep)
			creep.tree_exiting.connect(_on_creep_exiting.bind(creep))
	print("[M30] spawned ", _creeps.size(), " creeps kind=", CampKind.keys()[camp_kind])


func _on_creep_exiting(creep: Creep) -> void:
	_creeps.erase(creep)
	if _cleared:
		return
	if _creeps.is_empty():
		_grant_reward()


func _grant_reward() -> void:
	_cleared = true
	var team: int = _reward_team
	var rm := get_node_or_null("/root/ResourceManager")
	if rm:
		rm.add_wood(reward_wood, team)
		rm.add_stone(reward_stone, team)
	print("[M30] CAMP CLEARED kind=", CampKind.keys()[camp_kind],
		" → +", reward_wood, "W +", reward_stone, "S team=", team)

	for n in get_tree().get_nodes_in_group("Hero"):
		if n is Temirbat and is_instance_valid(n) and n.unit_state != BaseUnit.UnitState.DEAD:
			var hero: Temirbat = n as Temirbat
			if camp_kind == CampKind.ARCHER:
				hero.apply_dmg_buff()
			else:
				hero.apply_camp_buff()
			break
