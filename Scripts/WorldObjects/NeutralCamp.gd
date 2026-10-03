extends Node3D

class_name NeutralCamp

## M27/M30 — Static creep camp.
## MELEE: 4 Creeps, 80W+40S + HP buff
## ARCHER: 3 CreepArchers, 120W+60S + dmg buff

enum CampKind { MELEE, ARCHER }

@export var camp_kind: CampKind = CampKind.MELEE
@export var creep_scene: PackedScene
@export var creep_count: int = 4
@export var reward_wood: int = 80
@export var reward_stone: int = 40
@export var spawn_radius: float = 3.5

var _creeps: Array = []
var _cleared: bool = false
var _reward_team: int = 0


func _ready() -> void:
	add_to_group("NeutralCamp")
	_apply_kind_defaults()
	if creep_scene == null:
		if camp_kind == CampKind.ARCHER:
			creep_scene = load("res://Scenes/Units/creep_archer.tscn") as PackedScene
		else:
			creep_scene = load("res://Scenes/Units/creep.tscn") as PackedScene
	call_deferred("_spawn_creeps")
	_setup_marker()
	print("NeutralCamp kind=", CampKind.keys()[camp_kind], " at ", global_position)


func _apply_kind_defaults() -> void:
	match camp_kind:
		CampKind.ARCHER:
			creep_count = 3
			reward_wood = 120
			reward_stone = 60
			spawn_radius = 4.0
		_:
			creep_count = 4
			reward_wood = 80
			reward_stone = 40
			spawn_radius = 3.5


func _setup_marker() -> void:
	var mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.2
	cyl.bottom_radius = 1.2
	cyl.height = 0.15
	mesh.mesh = cyl
	var mat := StandardMaterial3D.new()
	if camp_kind == CampKind.ARCHER:
		mat.albedo_color = Color(0.2, 0.35, 0.65, 0.9)
	else:
		mat.albedo_color = Color(0.55, 0.25, 0.15, 0.9)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material_override = mat
	mesh.position = Vector3(0.0, 0.08, 0.0)
	add_child(mesh)


func note_attacker_team(team: int) -> void:
	if team != -1:
		_reward_team = team


func _spawn_creeps() -> void:
	if creep_scene == null:
		push_error("NeutralCamp: creep_scene null")
		return
	for i in creep_count:
		var angle: float = TAU * float(i) / float(creep_count)
		var offset := Vector3(cos(angle) * spawn_radius, 0.0, sin(angle) * spawn_radius)
		var c: Node3D = creep_scene.instantiate()
		if c == null:
			continue
		c.name = ("CreepArcher_%d" if camp_kind == CampKind.ARCHER else "Creep_%d") % i
		get_tree().current_scene.add_child(c)
		c.global_position = global_position + offset
		if c is Creep:
			var creep: Creep = c as Creep
			creep.owning_camp = self
			_creeps.append(creep)
			creep.tree_exiting.connect(_on_creep_exiting.bind(creep))
	print("NeutralCamp spawned ", _creeps.size(), " creeps kind=", CampKind.keys()[camp_kind])


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
	print("NeutralCamp CLEARED kind=", CampKind.keys()[camp_kind],
		" → +", reward_wood, "W +", reward_stone, "S team=", team)

	for n in get_tree().get_nodes_in_group("Hero"):
		if n is Temirbat and is_instance_valid(n) and n.unit_state != BaseUnit.UnitState.DEAD:
			var hero: Temirbat = n as Temirbat
			if camp_kind == CampKind.ARCHER:
				hero.apply_dmg_buff()
			else:
				hero.apply_camp_buff()
			break
