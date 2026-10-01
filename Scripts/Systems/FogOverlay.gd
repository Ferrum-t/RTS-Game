extends MeshInstance3D

## M20.2 / M24 — World fog plane driven by VisibilityMap.
## Also sets void background + ambient + one sun (so scene is not flat-lit).

const MAP_MIN := -95.0
const MAP_MAX := 95.0
const PLANE_Y := 0.15


func _ready() -> void:
	_ensure_lighting()

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


func _ensure_lighting() -> void:
	var w3d := get_viewport().world_3d
	if w3d != null:
		var env: Environment = w3d.environment
		if env == null:
			env = Environment.new()
			w3d.environment = env
		# Black void past the map — ambient must NOT sample this black.
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.0, 0.0, 0.0, 1.0)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		# Low fill so DirectionalLight + shadows read clearly (hand-paint friendly).
		env.ambient_light_color = Color(0.28, 0.30, 0.36)
		env.ambient_light_energy = 0.32

	# One sun if the scene has no DirectionalLight3D yet.
	var parent := get_parent()
	if parent == null:
		return
	for c in parent.get_children():
		if c is DirectionalLight3D:
			_configure_sun(c as DirectionalLight3D)
			return
	var sun := DirectionalLight3D.new()
	sun.name = "SunLight"
	_configure_sun(sun)
	parent.add_child(sun)


func _configure_sun(sun: DirectionalLight3D) -> void:
	sun.light_energy = 1.25
	sun.light_color = Color(1.0, 0.95, 0.88)
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.shadow_blur = 1.0
	# Late-afternoon angle — readable form on boxes / future hand-painted meshes.
	sun.rotation_degrees = Vector3(-48.0, -35.0, 0.0)


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
