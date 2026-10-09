extends BaseUnit

class_name Temirbat

## M27–M31 — Semi-Hero + persistent artifacts/level via HeroProgress.

var has_camp_buff: bool = false
var has_dmg_buff: bool = false
const CAMP_BUFF_HP := 40
const CAMP_BUFF_DMG := 10

const MANA_MAX := 100.0
const MANA_REGEN := 2.0
const QIRGIN_COST := 40.0
const QIRGIN_COOLDOWN := 12.0
const QIRGIN_RADIUS := 3.5
const QIRGIN_DAMAGE := 40

var mana: float = MANA_MAX
var _qirgin_cd: float = 0.0
var _hero_aura: MeshInstance3D = null
var _mana_bar_bg: MeshInstance3D = null
var _mana_bar_fill: MeshInstance3D = null
var _mana_bar_y: float = 1.87
const MANA_BAR_WIDTH := 2.0

const HERO_DISPLAY_NAME := "Temirbat"


func _ready() -> void:
	max_health = 220
	attack_damage = 32
	attack_range = 2.5
	attack_cooldown = 0.75
	move_speed = 3.6
	health_bar_height = 2.15
	can_gather = false
	damage_type = DamageType.Type.MELEE
	can_shoot_while_moving = false

	super()
	add_to_group("Hero")
	_setup_hero_aura()
	_setup_mana_bar()
	print("Temirbat spawned at ", global_position)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if unit_state == UnitState.DEAD:
		return
	mana = minf(MANA_MAX, mana + MANA_REGEN * delta)
	if _qirgin_cd > 0.0:
		_qirgin_cd = maxf(0.0, _qirgin_cd - delta)
	_update_mana_bar()


func can_cast_qirgin() -> bool:
	return mana >= QIRGIN_COST and _qirgin_cd <= 0.0 and unit_state != UnitState.DEAD


func try_cast_qirgin() -> bool:
	if not can_cast_qirgin():
		return false
	mana -= QIRGIN_COST
	_qirgin_cd = QIRGIN_COOLDOWN
	var center := global_position
	center.y = 0.0
	var r2 := QIRGIN_RADIUS * QIRGIN_RADIUS
	for n in get_tree().get_nodes_in_group("Unit"):
		if not (n is BaseUnit):
			continue
		var u := n as BaseUnit
		if u == self or not is_instance_valid(u):
			continue
		if u.unit_state == UnitState.DEAD:
			continue
		if not TeamRules.can_attack(self, u):
			continue
		var d := global_position.distance_squared_to(u.global_position)
		if d > r2:
			continue
		u.take_damage(QIRGIN_DAMAGE, self)
	for n in get_tree().get_nodes_in_group("Building"):
		if not (n is BaseBuilding):
			continue
		var b := n as BaseBuilding
		if not is_instance_valid(b) or b.is_destroyed:
			continue
		if int(b.team_id) == int(team_id):
			continue
		var d2 := global_position.distance_squared_to(b.global_position)
		if d2 > r2:
			continue
		if b.has_method("damage"):
			b.damage(QIRGIN_DAMAGE, team_id)
		elif b.has_method("apply_damage"):
			b.apply_damage(QIRGIN_DAMAGE, self)
		elif b.has_method("take_damage"):
			b.take_damage(QIRGIN_DAMAGE, self)
	print(name, " QIRGIN AoE dmg=", QIRGIN_DAMAGE, " r=", QIRGIN_RADIUS)
	return true


func die() -> void:
	var death_pos := global_position
	var lvl := 1
	var hp := get_node_or_null("/root/HeroProgress")
	if hp != null and hp.has_method("get_level"):
		lvl = int(hp.get_level())
	var ui := get_node_or_null("/root/UIManager")
	if ui != null and ui.has_method("show_hero_death_banner"):
		ui.show_hero_death_banner(HERO_DISPLAY_NAME, lvl, death_pos)
	elif OS.is_debug_build():
		print(HERO_DISPLAY_NAME, " (Level ", lvl, ") has fallen")
	super.die()


func _setup_mana_bar() -> void:
	var mat_bg := StandardMaterial3D.new()
	mat_bg.albedo_color = Color(0.08, 0.08, 0.2, 0.85)
	mat_bg.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_bg.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var box_bg := BoxMesh.new()
	box_bg.size = Vector3(MANA_BAR_WIDTH, 0.08, 0.08)
	_mana_bar_bg = MeshInstance3D.new()
	_mana_bar_bg.mesh = box_bg
	_mana_bar_bg.material_override = mat_bg
	_mana_bar_bg.position = Vector3(0.0, _mana_bar_y, 0.0)
	add_child(_mana_bar_bg)
	var mat_fill := StandardMaterial3D.new()
	mat_fill.albedo_color = Color(0.25, 0.45, 1.0, 0.95)
	mat_fill.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_fill.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var box_fill := BoxMesh.new()
	box_fill.size = Vector3(MANA_BAR_WIDTH, 0.08, 0.08)
	_mana_bar_fill = MeshInstance3D.new()
	_mana_bar_fill.mesh = box_fill
	_mana_bar_fill.material_override = mat_fill
	_mana_bar_fill.position = Vector3(0.0, _mana_bar_y, 0.0)
	add_child(_mana_bar_fill)
	_update_mana_bar()


func _update_mana_bar() -> void:
	if _mana_bar_fill == null or not is_instance_valid(_mana_bar_fill):
		return
	var ratio := clampf(mana / MANA_MAX, 0.0, 1.0)
	var fill_origin := Vector3(-MANA_BAR_WIDTH * 0.5 * (1.0 - ratio), _mana_bar_y, 0.0)
	var basis := Basis.IDENTITY.scaled(Vector3(maxf(ratio, 0.001), 1.0, 1.0))
	_mana_bar_fill.global_transform = Transform3D(basis, global_position + fill_origin)
	# Keep local Y; simpler scale approach:
	_mana_bar_fill.position = Vector3(-MANA_BAR_WIDTH * 0.5 * (1.0 - ratio), _mana_bar_y, 0.0)
	_mana_bar_fill.scale = Vector3(maxf(ratio, 0.001), 1.0, 1.0)


func _setup_hero_aura() -> void:
	_hero_aura = MeshInstance3D.new()
	_hero_aura.name = "HeroAura"
	var quad := QuadMesh.new()
	_hero_aura.mesh = quad
	quad.size = Vector2(2.4, 2.4)
	_hero_aura.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	_hero_aura.position = Vector3(0.0, 0.05, 0.0)
	_hero_aura.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_hero_aura.material_override = _make_soft_aura_shader()
	add_child(_hero_aura)


func _make_soft_aura_shader() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 glow_color : source_color = vec4(1.0, 0.82, 0.15, 1.0);
uniform float inner_radius : hint_range(0.0, 1.0) = 0.15;
uniform float soft_edge : hint_range(0.05, 1.0) = 0.55;
uniform float intensity : hint_range(0.1, 3.0) = 1.35;

void fragment() {
	vec2 p = UV - vec2(0.5);
	float dist = length(p) * 2.0;
	float alpha = 1.0 - smoothstep(inner_radius, soft_edge, dist);
	alpha = pow(alpha, 1.35);
	ALBEDO = glow_color.rgb * intensity;
	ALPHA = alpha * glow_color.a;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("glow_color", Color(1.0, 0.85, 0.2, 1.0))
	mat.set_shader_parameter("inner_radius", 0.12)
	mat.set_shader_parameter("soft_edge", 0.72)
	mat.set_shader_parameter("intensity", 1.45)
	return mat


func apply_camp_buff() -> void:
	if has_camp_buff:
		return
	has_camp_buff = true
	max_health += CAMP_BUFF_HP
	health = mini(health + CAMP_BUFF_HP, max_health)
	if health_bar:
		health_bar.setup(max_health)
		health_bar.set_health(health)
	print(name, " CAMP BUFF +", CAMP_BUFF_HP, " HP → max=", max_health)


func apply_dmg_buff() -> void:
	if has_dmg_buff:
		return
	has_dmg_buff = true
	attack_damage += CAMP_BUFF_DMG
	print(name, " ARCHER CAMP BUFF +", CAMP_BUFF_DMG, " dmg → ", attack_damage)
