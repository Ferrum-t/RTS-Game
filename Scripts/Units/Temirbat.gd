extends BaseUnit

class_name Temirbat

## M27 — Semi-Hero. Melee, clearly stronger than Soldier.
## Permanent golden aura under feet (always visible).
## Camp buff: +40 max_health (flag, no inventory).
## Mana bar deferred until spells exist.

var has_camp_buff: bool = false
const CAMP_BUFF_HP := 40

var _hero_aura: MeshInstance3D = null
var _hero_aura_outer: MeshInstance3D = null


func _ready() -> void:
	# Noticeably above Soldier (150 HP / 20 dmg)
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
	# Inner bright disc (Warcraft-style hero glow)
	_hero_aura = MeshInstance3D.new()
	_hero_aura.name = "HeroAura"
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.85
	cyl.bottom_radius = 0.85
	cyl.height = 0.06
	cyl.radial_segments = 24
	_hero_aura.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.82, 0.15, 0.75)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.75, 0.1)
	mat.emission_energy_multiplier = 2.4
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_hero_aura.material_override = mat
	_hero_aura.position = Vector3(0.0, 0.04, 0.0)
	_hero_aura.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_hero_aura)

	# Outer soft ring (larger, more transparent)
	_hero_aura_outer = MeshInstance3D.new()
	_hero_aura_outer.name = "HeroAuraOuter"
	var cyl2 := CylinderMesh.new()
	cyl2.top_radius = 1.15
	cyl2.bottom_radius = 1.15
	cyl2.height = 0.04
	cyl2.radial_segments = 24
	_hero_aura_outer.mesh = cyl2
	var mat2 := StandardMaterial3D.new()
	mat2.albedo_color = Color(1.0, 0.9, 0.35, 0.35)
	mat2.emission_enabled = true
	mat2.emission = Color(1.0, 0.85, 0.2)
	mat2.emission_energy_multiplier = 1.2
	mat2.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat2.cull_mode = BaseMaterial3D.CULL_DISABLED
	_hero_aura_outer.material_override = mat2
	_hero_aura_outer.position = Vector3(0.0, 0.03, 0.0)
	_hero_aura_outer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_hero_aura_outer)


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
