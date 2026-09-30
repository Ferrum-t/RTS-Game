extends MeshInstance3D

## M20.2 / M24 — World fog plane driven by VisibilityMap.
## Plane slightly larger than playable bounds; shader UV maps fog_tex to ±95 only.

const MAP_HALF := 95.0
const PLANE_MARGIN := 24.0
const PLANE_Y := 0.15


func _ready() -> void:
	_ensure_black_background()

	var plane_half := MAP_HALF + PLANE_MARGIN
	var plane := PlaneMesh.new()
	plane.size = Vector2(plane_half * 2.0, plane_half * 2.0)
	mesh = plane
	position = Vector3(0.0, PLANE_Y, 0.0)
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var mat := ShaderMaterial.new()
	var sh: Shader = load("res://Shaders/fog_overlay.gdshader") as Shader
	if sh == null:
		push_error("FogOverlay: missing fog_overlay.gdshader")
		return
	mat.shader = sh
	mat.set_shader_parameter("map_half", MAP_HALF)
	mat.set_shader_parameter("plane_half", plane_half)
	material_override = mat

	var vm := get_node_or_null("/root/VisibilityMap")
	if vm != null:
		if vm.has_signal("visibility_updated"):
			vm.visibility_updated.connect(_on_visibility_updated)
		_apply_texture(vm)
	else:
		call_deferred("_try_bind_vm")


func _ensure_black_background() -> void:
	var w3d := get_viewport().world_3d
	if w3d == null:
		return
	var env: Environment = w3d.environment
	if env == null:
		env = Environment.new()
		w3d.environment = env
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.0, 0.0, 0.0, 1.0)


func _try_bind_vm() -> void:
	var vm := get_node_or_null("/root/VisibilityMap")
	if vm == null:
		return
	if vm.has_signal("visibility_updated") and not vm.visibility_updated.is_connected(_on_visibility_updated):
		vm.visibility_updated.connect(_on_visibility_updated)
	_apply_texture(vm)


func _on_visibility_updated() -> void:
	var vm := get_node_or_null("/root/VisibilityMap")
	if vm != null:
		_apply_texture(vm)


func _apply_texture(vm) -> void:
	if material_override == null:
		return
	if not vm.has_method("get_fog_texture"):
		return
	var tex: Texture2D = vm.get_fog_texture()
	(material_override as ShaderMaterial).set_shader_parameter("fog_tex", tex)
