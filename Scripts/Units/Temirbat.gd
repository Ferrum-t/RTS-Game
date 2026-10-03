extends BaseUnit

class_name Temirbat

## M27 — Semi-Hero. Melee, clearly stronger than Soldier.
## Soft radial golden aura under feet (Warcraft-style additive glow).
## Camp buff: +40 max_health (flag, no inventory).
## Mana bar deferred until spells exist.

var has_camp_buff: bool = false
const CAMP_BUFF_HP := 40

var _hero_aura: MeshInstance3D = null


func _ready() -> void:
	max_health = 220
	attack_damage = 32
	attack_range = 2.5
	attack_cooldown = 0.75
	move_speed = 3.1
	health_bar_height = 2.15
	can_gather = false
	damage_type = DamageType.Type.MELEE
	can_shoot_while_moving = false

	super()
	add_to_group("Hero")
	_setup_hero_aura()
	print("Temirbat spawned at ", global_position)


func _setup_hero_aura() -> void:
	# Flat disc + soft radial shader (like WC3 hero glow under unit)
	_hero_aura = MeshInstance3D.new()
	_hero_aura.name = "HeroAura"
	var quad := QuadMesh.new()
	quad.size = Vector2(2.4, 2.4)
	_hero_aura.mesh = quad
	# Lie flat on ground (QuadMesh faces +Z by default → rotate to face up)
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
	// UV centered: 0 at center, 1 at edge of quad
	vec2 p = UV - vec2(0.5);
	float dist = length(p) * 2.0; // 0 center → 1 edge
	// Soft falloff: full in center core, smooth fade to transparent
	float alpha = 1.0 - smoothstep(inner_radius, soft_edge, dist);
	alpha = pow(alpha, 1.35); // slightly softer tail
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
