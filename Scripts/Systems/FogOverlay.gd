extends MeshInstance3D

## M20.2 — World fog plane driven by VisibilityMap (single source of truth).

const MAP_MIN := -95.0
const MAP_MAX := 95.0
const PLANE_Y := 0.12


func _ready() -> void:
	var size := MAP_MAX - MAP_MIN
	var plane := PlaneMesh.new()
	plane.size = Vector2(size, size)
	mesh = plane
	position = Vector3(0.0, PLANE_Y, 0.0)
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var mat := ShaderMaterial.new()
	var sh: Shader = load("res://Shaders/fog_overlay.gdshader") as Shader
	if sh == null:
		push_error("FogOverlay: missing fog_overlay.gdshader")
		return
	mat.shader = sh
	material_override = mat

	var vm := get_node_or_null("/root/VisibilityMap")
	if vm != null:
		if vm.has_signal("visibility_updated"):
			vm.visibility_updated.connect(_on_visibility_updated)
		_apply_texture(vm)
	else:
		call_deferred("_try_bind_vm")


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
