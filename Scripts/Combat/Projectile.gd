extends Node3D

class_name Projectile

## M23.1 — visual + damage-on-arrival. No miss, straight path, optional track of live target.

const ARROW_SPEED := 32.0
const STONE_SPEED := 20.0
const MIN_FLY := 0.12
const MAX_FLY := 0.50
const HEIGHT_OFFSET := 1.0

var _target: Object = null
var _damage: int = 0
var _source: Node = null
var _fly_time: float = 0.2
var _elapsed: float = 0.0
var _start: Vector3 = Vector3.ZERO
var _end: Vector3 = Vector3.ZERO
var _is_stone: bool = false
var _mesh: MeshInstance3D = null


static func fire(
	from: Node3D,
	target: Object,
	damage: int,
	source: Node,
	is_stone: bool = false
) -> void:
	if from == null or target == null or not is_instance_valid(target):
		return
	var scene := from.get_tree().current_scene
	if scene == null:
		return
	var p := Projectile.new()
	scene.add_child(p)
	var origin: Vector3 = from.global_position + Vector3(0.0, HEIGHT_OFFSET, 0.0)
	p.global_position = origin
	p._configure(origin, target, damage, source, is_stone)


func _configure(
	origin: Vector3,
	target: Object,
	damage: int,
	source: Node,
	is_stone: bool
) -> void:
	_target = target
	_damage = damage
	_source = source
	_is_stone = is_stone
	_start = origin
	_end = _aim_point(target)
	var speed: float = STONE_SPEED if is_stone else ARROW_SPEED
	var dist: float = _start.distance_to(_end)
	_fly_time = clampf(dist / speed, MIN_FLY, MAX_FLY)
	_elapsed = 0.0
	_build_mesh()
	_orient()


func _aim_point(target: Object) -> Vector3:
	if target is Node3D and is_instance_valid(target):
		var n := target as Node3D
		return n.global_position + Vector3(0.0, HEIGHT_OFFSET * 0.85, 0.0)
	return _start + Vector3(0.0, 0.0, 1.0)


func _build_mesh() -> void:
	_mesh = MeshInstance3D.new()
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if _is_stone:
		mat.albedo_color = Color(0.45, 0.42, 0.38, 1.0)
		var sphere := SphereMesh.new()
		sphere.radius = 0.18
		sphere.height = 0.36
		_mesh.mesh = sphere
	else:
		mat.albedo_color = Color(0.85, 0.7, 0.35, 1.0)
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.04
		cyl.bottom_radius = 0.04
		cyl.height = 0.55
		_mesh.mesh = cyl
	_mesh.material_override = mat
	add_child(_mesh)


func _orient() -> void:
	var dir := _end - global_position
	if dir.length_squared() < 0.0001:
		return
	dir = dir.normalized()
	if _is_stone:
		return
	look_at(global_position + dir, Vector3.UP)
	rotate_object_local(Vector3.RIGHT, PI * 0.5)


func _process(delta: float) -> void:
	_elapsed += delta
	if is_instance_valid(_target):
		_end = _aim_point(_target)
	var t: float = 1.0
	if _fly_time > 0.0:
		t = clampf(_elapsed / _fly_time, 0.0, 1.0)
	global_position = _start.lerp(_end, t)
	_orient()
	if t >= 1.0:
		_apply_damage()
		queue_free()


func _apply_damage() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	if _target is BaseUnit:
		var u := _target as BaseUnit
		if u.unit_state == BaseUnit.UnitState.DEAD:
			return
		u.take_damage(_damage, _source)
		return
	if _target is BaseBuilding:
		var b := _target as BaseBuilding
		if b.is_destroyed or b.health <= 0:
			return
		if b.has_method("take_damage"):
			b.take_damage(_damage, _source)
		elif b.has_method("damage"):
			b.damage(_damage, 0)
