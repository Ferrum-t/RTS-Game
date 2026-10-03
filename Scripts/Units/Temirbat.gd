extends BaseUnit

class_name Temirbat

## M27–M30 — Semi-Hero.
## Soft aura, camp HP/dmg buffs, mana + Qırğın, death text, respawn.

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
	move_speed = 3.1
	health_bar_height = 2.15
	can_gather = false
	damage_type = DamageType.Type.MELEE
	can_shoot_while_moving = false

	super()
	add_to_group("Hero")
	Orunqar.match_hero_alive = true
	Orunqar.match_revive_cd = 0.0
	_setup_hero_aura()
	_setup_mana_bar()
	print("Temirbat spawned at ", global_position)


func die() -> void:
	_show_hero_fallen_banner()
	Orunqar.notify_hero_fallen()
	super.die()


func _show_hero_fallen_banner() -> void:
	var ui_root: Node = get_tree().root.get_node_or_null("UI")
	if ui_root == null:
		for n in get_tree().get_nodes_in_group("ui"):
			ui_root = n
			break
	if ui_root == null:
		var scene := get_tree().current_scene
		if scene:
			for c in scene.get_children():
				if c is CanvasLayer:
					ui_root = c
					break
	if ui_root == null:
		print(HERO_DISPLAY_NAME, " has fallen!")
		return

	var label := Label.new()
	label.name = "HeroFallenBanner"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = HERO_DISPLAY_NAME + " has fallen"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color(1.0, 0.32, 0.22, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 6)

	ui_root.add_child(label)
	label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	label.offset_top = 80.0
	label.offset_bottom = 120.0
	label.offset_left = -280.0
	label.offset_right = 280.0

	var tw := label.create_tween()
	tw.tween_interval(2.5)
	tw.tween_property(label, "modulate:a", 0.0, 0.9)
	tw.tween_callback(label.queue_free)
	print(HERO_DISPLAY_NAME, " has fallen!")


func _process(delta: float) -> void:
	if unit_state == UnitState.DEAD:
		return
	if mana < MANA_MAX:
		mana = minf(MANA_MAX, mana + MANA_REGEN * delta)
		_update_mana_bar()
	if _qirgin_cd > 0.0:
		_qirgin_cd = maxf(0.0, _qirgin_cd - delta)
	_billboard_mana_bar()


func _unhandled_input(event: InputEvent) -> void:
	if team_id != 0 or unit_state == UnitState.DEAD:
		return
	if not selected:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key := event as InputEventKey
	if key.keycode == KEY_Q:
		try_cast_qirgin()
		get_viewport().set_input_as_handled()


func can_cast_qirgin() -> bool:
	if unit_state == UnitState.DEAD:
		return false
	if _qirgin_cd > 0.0:
		return false
	if mana < QIRGIN_COST:
		return false
	return true


func try_cast_qirgin() -> bool:
	if not can_cast_qirgin():
		if OS.is_debug_build():
			if mana < QIRGIN_COST:
				print("Temirbat Qırğın blocked — mana ", int(mana), "/", int(QIRGIN_COST))
			elif _qirgin_cd > 0.0:
				print("Temirbat Qırğın blocked — CD ", "%.1f" % _qirgin_cd, "s")
		return false
	mana -= QIRGIN_COST
	_qirgin_cd = QIRGIN_COOLDOWN
	_update_mana_bar()
	_apply_qirgin_damage()
	_flash_cast_vfx()
	print("Temirbat Qırğın! mana=", int(mana), " CD=", QIRGIN_COOLDOWN)
	return true


func _apply_qirgin_damage() -> void:
	var r_sq: float = QIRGIN_RADIUS * QIRGIN_RADIUS
	for n in get_tree().get_nodes_in_group("Unit"):
		if not (n is BaseUnit):
			continue
		var other: BaseUnit = n as BaseUnit
		if other == self or not is_instance_valid(other):
			continue
		if other.unit_state == UnitState.DEAD:
			continue
		if not TeamRules.can_attack(self, other):
			continue
		if global_position.distance_squared_to(other.global_position) > r_sq:
			continue
		other.take_damage(QIRGIN_DAMAGE, self)
	for n in get_tree().get_nodes_in_group("Building"):
		if not (n is BaseBuilding):
			continue
		var b: BaseBuilding = n as BaseBuilding
		if not is_instance_valid(b) or b.is_destroyed:
			continue
		if int(b.team_id) == int(team_id):
			continue
		if global_position.distance_squared_to(b.global_position) > r_sq:
			continue
		if b.has_method("damage"):
			b.damage(QIRGIN_DAMAGE, team_id)
		elif b.has_method("take_damage"):
			b.take_damage(QIRGIN_DAMAGE, self)
		elif b.has_method("apply_damage"):
			b.apply_damage(QIRGIN_DAMAGE, self)
		else:
			b.health = maxi(0, b.health - QIRGIN_DAMAGE)
			if b.health <= 0 and b.has_method("die"):
				b.die()


func _flash_cast_vfx() -> void:
	var flash := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(QIRGIN_RADIUS * 2.2, QIRGIN_RADIUS * 2.2)
	flash.mesh = quad
	flash.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	flash.position = Vector3(0.0, 0.08, 0.0)
	flash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;
uniform float life : hint_range(0.0, 1.0) = 1.0;
void fragment() {
	vec2 p = UV - vec2(0.5);
	float dist = length(p) * 2.0;
	float a = (1.0 - smoothstep(0.2, 0.95, dist)) * life;
	ALBEDO = vec3(1.0, 0.75, 0.2) * 2.0;
	ALPHA = a;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("life", 1.0)
	flash.material_override = mat
	add_child(flash)
	var tw := create_tween()
	tw.tween_method(func(v: float): mat.set_shader_parameter("life", v), 1.0, 0.0, 0.35)
	tw.tween_callback(flash.queue_free)


func _setup_mana_bar() -> void:
	_mana_bar_y = health_bar_height - 0.28
	_mana_bar_bg = MeshInstance3D.new()
	_mana_bar_bg.name = "ManaBarBg"
	var bg_q := QuadMesh.new()
	bg_q.size = Vector2(MANA_BAR_WIDTH, 0.14)
	_mana_bar_bg.mesh = bg_q
	var bg_mat := StandardMaterial3D.new()
	bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bg_mat.albedo_color = Color(0.05, 0.05, 0.12, 1)
	bg_mat.no_depth_test = true
	bg_mat.render_priority = 5
	_mana_bar_bg.material_override = bg_mat
	add_child(_mana_bar_bg)

	_mana_bar_fill = MeshInstance3D.new()
	_mana_bar_fill.name = "ManaBarFill"
	var fill_q := QuadMesh.new()
	fill_q.size = Vector2(MANA_BAR_WIDTH, 0.10)
	_mana_bar_fill.mesh = fill_q
	var fill_mat := StandardMaterial3D.new()
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fill_mat.albedo_color = Color(0.25, 0.55, 1.0, 1)
	fill_mat.no_depth_test = true
	fill_mat.render_priority = 6
	_mana_bar_fill.material_override = fill_mat
	add_child(_mana_bar_fill)
	_update_mana_bar()


func _update_mana_bar() -> void:
	if _mana_bar_fill == null:
		return
	var ratio := clampf(mana / MANA_MAX, 0.0, 1.0)
	_mana_bar_fill.scale = Vector3(maxf(ratio, 0.001), 1.0, 1.0)


func _billboard_mana_bar() -> void:
	if _mana_bar_bg == null or _mana_bar_fill == null:
		return
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var basis := cam.global_transform.basis
	var origin := global_position + Vector3(0.0, _mana_bar_y, 0.0)
	_mana_bar_bg.global_transform = Transform3D(basis, origin)
	var ratio := clampf(mana / MANA_MAX, 0.0, 1.0)
	var fill_origin := origin + basis * Vector3(-MANA_BAR_WIDTH * 0.5 * (1.0 - ratio), 0.0, 0.02)
	_mana_bar_fill.global_transform = Transform3D(basis, fill_origin)
	_mana_bar_fill.scale = Vector3(maxf(ratio, 0.001), 1.0, 1.0)


func _setup_hero_aura() -> void:
	_hero_aura = MeshInstance3D.new()
	_hero_aura.name = "HeroAura"
	var quad := QuadMesh.new()
	quad.size = Vector2(2.4, 2.4)
	_hero_aura.mesh = quad
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
