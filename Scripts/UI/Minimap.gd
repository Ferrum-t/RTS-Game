extends PanelContainer

## M20 — Basic Minimap (Variant A: static background).
## Player units/buildings + camera rect + click-to-pan.
## M20.1: enemy markers only when VisibilityMap says VISIBLE.

const PLAYER_TEAM := 0
const MARKER_INTERVAL := 0.15
const MAP_MIN_X := -95.0
const MAP_MAX_X := 95.0
const MAP_MIN_Z := -95.0
const MAP_MAX_Z := 95.0
const PANEL_SIZE := 170.0

var _bg: Texture2D
var _marker_timer: float = 0.0
var _cam_rig: Node3D = null
var _unit_uvs: PackedVector2Array = PackedVector2Array()
var _building_uvs: PackedVector2Array = PackedVector2Array()
var _enemy_unit_uvs: PackedVector2Array = PackedVector2Array()
var _enemy_building_uvs: PackedVector2Array = PackedVector2Array()
var _cam_uv: Vector2 = Vector2(0.5, 0.5)
var _dragging: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(PANEL_SIZE, PANEL_SIZE)
	size = Vector2(PANEL_SIZE, PANEL_SIZE)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_bg = _make_static_background()
	call_deferred("_find_camera_rig")
	_collect_markers()


func set_background(tex: Texture2D) -> void:
	_bg = tex
	queue_redraw()


func world_to_uv(pos: Vector3) -> Vector2:
	var u := inverse_lerp(MAP_MIN_X, MAP_MAX_X, pos.x)
	var v := inverse_lerp(MAP_MIN_Z, MAP_MAX_Z, pos.z)
	return Vector2(clampf(u, 0.0, 1.0), clampf(v, 0.0, 1.0))


func uv_to_world(uv: Vector2) -> Vector3:
	var x := lerpf(MAP_MIN_X, MAP_MAX_X, clampf(uv.x, 0.0, 1.0))
	var z := lerpf(MAP_MIN_Z, MAP_MAX_Z, clampf(uv.y, 0.0, 1.0))
	return Vector3(x, 0.0, z)


func _process(delta: float) -> void:
	_marker_timer -= delta
	if _marker_timer <= 0.0:
		_marker_timer = MARKER_INTERVAL
		_collect_markers()
	_update_camera_uv()
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if _bg != null:
		draw_texture_rect(_bg, r, false)
	else:
		draw_rect(r, Color(0.12, 0.18, 0.14))
	draw_rect(r, Color(0.35, 0.5, 0.4, 0.9), false, 2.0)

	for i in range(_building_uvs.size()):
		var p: Vector2 = _building_uvs[i] * size
		draw_rect(Rect2(p - Vector2(3.5, 3.5), Vector2(7, 7)), Color(0.3, 0.75, 1.0))

	for i in range(_unit_uvs.size()):
		var p: Vector2 = _unit_uvs[i] * size
		draw_circle(p, 2.8, Color(0.35, 0.9, 0.45))

	for i in range(_enemy_building_uvs.size()):
		var p: Vector2 = _enemy_building_uvs[i] * size
		draw_rect(Rect2(p - Vector2(3.5, 3.5), Vector2(7, 7)), Color(0.95, 0.25, 0.2))
	for i in range(_enemy_unit_uvs.size()):
		var p: Vector2 = _enemy_unit_uvs[i] * size
		draw_circle(p, 2.8, Color(0.95, 0.35, 0.3))

	var c: Vector2 = _cam_uv * size
	var half := Vector2(16.0, 12.0)
	draw_rect(Rect2(c - half, half * 2.0), Color(1.0, 0.95, 0.35, 0.95), false, 1.6)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_dragging = true
				_pan_to_local(mb.position)
				accept_event()
			else:
				_dragging = false
				accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_pan_to_local((event as InputEventMouseMotion).position)
		accept_event()


func _pan_to_local(local_pos: Vector2) -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var uv := Vector2(local_pos.x / size.x, local_pos.y / size.y)
	uv = Vector2(clampf(uv.x, 0.0, 1.0), clampf(uv.y, 0.0, 1.0))
	var world := uv_to_world(uv)
	var rig := _get_camera_rig()
	if rig == null:
		return
	var y: float = rig.global_position.y
	rig.global_position = Vector3(world.x, y, world.z)
	if rig.has_method("_clamp_to_map"):
		rig.call("_clamp_to_map")
	else:
		rig.global_position.x = clampf(rig.global_position.x, MAP_MIN_X, MAP_MAX_X)
		rig.global_position.z = clampf(rig.global_position.z, MAP_MIN_Z, MAP_MAX_Z)


func _collect_markers() -> void:
	_unit_uvs = PackedVector2Array()
	_building_uvs = PackedVector2Array()
	_enemy_unit_uvs = PackedVector2Array()
	_enemy_building_uvs = PackedVector2Array()

	var um := get_node_or_null("/root/UnitManager")
	if um != null and "units" in um:
		for u in um.units:
			if u == null or not is_instance_valid(u):
				continue
			if int(u.get("team_id")) != PLAYER_TEAM:
				continue
			if u.has_method("is_dead") and u.is_dead():
				continue
			if u.get("unit_state") != null and int(u.unit_state) == 7:
				continue
			_unit_uvs.append(world_to_uv(u.global_position))

	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return
	_append_buildings(bm.get("town_centers"))
	_append_buildings(bm.get("barracks_list"))
	_append_buildings(bm.get("watchtowers_list"))

	var vm := get_node_or_null("/root/VisibilityMap")
	if um != null and "units" in um:
		for u in um.units:
			if u == null or not is_instance_valid(u):
				continue
			if int(u.get("team_id")) == PLAYER_TEAM:
				continue
			if u.has_method("is_dead") and u.is_dead():
				continue
			if u.get("unit_state") != null and int(u.unit_state) == 7:
				continue
			if vm != null and vm.has_method("is_visible_world"):
				if not vm.is_visible_world(u.global_position):
					continue
			else:
				continue
			_enemy_unit_uvs.append(world_to_uv(u.global_position))
	if bm != null:
		_append_enemy_buildings(bm.get("town_centers"), vm)
		_append_enemy_buildings(bm.get("barracks_list"), vm)
		_append_enemy_buildings(bm.get("watchtowers_list"), vm)


func _append_buildings(list_val) -> void:
	if list_val == null:
		return
	for b in list_val:
		if b == null or not is_instance_valid(b):
			continue
		if int(b.get("team_id")) != PLAYER_TEAM:
			continue
		if b.get("is_destroyed") == true:
			continue
		_building_uvs.append(world_to_uv((b as Node3D).global_position))


func _append_enemy_buildings(list_val, vm) -> void:
	if list_val == null:
		return
	for b in list_val:
		if b == null or not is_instance_valid(b):
			continue
		if int(b.get("team_id")) == PLAYER_TEAM:
			continue
		if b.get("is_destroyed") == true:
			continue
		if vm != null and vm.has_method("is_visible_world"):
			if not vm.is_visible_world((b as Node3D).global_position):
				continue
		else:
			continue
		_enemy_building_uvs.append(world_to_uv((b as Node3D).global_position))


func _update_camera_uv() -> void:
	var rig := _get_camera_rig()
	if rig == null:
		return
	_cam_uv = world_to_uv(rig.global_position)


func _get_camera_rig() -> Node3D:
	if _cam_rig != null and is_instance_valid(_cam_rig):
		return _cam_rig
	_find_camera_rig()
	return _cam_rig


func _find_camera_rig() -> void:
	_cam_rig = null
	var tree := get_tree()
	if tree == null:
		return
	for n in tree.get_nodes_in_group("rts_camera"):
		if n is Node3D:
			_cam_rig = n as Node3D
			return
	var root := tree.current_scene
	if root == null:
		return
	_cam_rig = _search_camera_rig(root)


func _search_camera_rig(node: Node) -> Node3D:
	if node is Node3D and node.get("map_min_x") != null and node.get("camera") != null:
		return node as Node3D
	for c in node.get_children():
		var found := _search_camera_rig(c)
		if found != null:
			return found
	return null


func _make_static_background() -> Texture2D:
	var res := 128
	var img := Image.create(res, res, false, Image.FORMAT_RGB8)
	var base := Color(0.11, 0.16, 0.13)
	var line := Color(0.17, 0.23, 0.18)
	var accent := Color(0.14, 0.22, 0.17)
	img.fill(base)
	for i in range(0, res, 16):
		for j in range(res):
			img.set_pixel(i, j, line)
			img.set_pixel(j, i, line)
	for y in range(res):
		for x in range(res):
			var dx := float(x) / float(res) - 0.5
			var dy := float(y) / float(res) - 0.5
			if dx * dx + dy * dy < 0.18:
				var c := img.get_pixel(x, y)
				img.set_pixel(x, y, c.lerp(accent, 0.35))
	return ImageTexture.create_from_image(img)
