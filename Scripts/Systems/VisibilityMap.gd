extends Node

## M20.1 data + M20.2 fog image + hide enemy 3D outside VISIBLE.

const PLAYER_TEAM := 0
const MAP_MIN_X := -95.0
const MAP_MAX_X := 95.0
const MAP_MIN_Z := -95.0
const MAP_MAX_Z := 95.0
const CELL_SIZE := 4.0
const UPDATE_INTERVAL := 0.2
const UNIT_STATE_DEAD := 7
const DEPLOYED := 0

enum CellState {
	UNEXPLORED = 0,
	EXPLORED = 1,
	VISIBLE = 2,
}

const RADIUS_WORKER := 11.0
const RADIUS_SOLDIER := 13.0
const RADIUS_CAVALRY := 13.0
const RADIUS_SIEGE := 12.0
const RADIUS_DEFAULT_UNIT := 12.0
const RADIUS_TC := 15.0
const RADIUS_BARRACKS := 12.0
const RADIUS_WATCHTOWER := 20.0

signal visibility_updated

var _cols: int = 0
var _rows: int = 0
var _cells: PackedByteArray = PackedByteArray()
var _timer: float = 0.0
var _fog_image: Image
var _fog_texture: ImageTexture


func _ready() -> void:
	_cols = int(ceil((MAP_MAX_X - MAP_MIN_X) / CELL_SIZE))
	_rows = int(ceil((MAP_MAX_Z - MAP_MIN_Z) / CELL_SIZE))
	_cells.resize(_cols * _rows)
	_cells.fill(CellState.UNEXPLORED)
	_fog_image = Image.create(_cols, _rows, false, Image.FORMAT_RGB8)
	_fog_texture = ImageTexture.create_from_image(_fog_image)
	call_deferred("force_update")


func _process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = UPDATE_INTERVAL
	_update_visibility()


func force_update() -> void:
	_update_visibility()


func world_to_cell(pos: Vector3) -> Vector2i:
	var cx := int(floor((pos.x - MAP_MIN_X) / CELL_SIZE))
	var cz := int(floor((pos.z - MAP_MIN_Z) / CELL_SIZE))
	return Vector2i(clampi(cx, 0, _cols - 1), clampi(cz, 0, _rows - 1))


func get_cell_state(cell: Vector2i) -> int:
	if cell.x < 0 or cell.y < 0 or cell.x >= _cols or cell.y >= _rows:
		return CellState.UNEXPLORED
	return int(_cells[cell.y * _cols + cell.x])


func is_visible_world(pos: Vector3) -> bool:
	return get_cell_state(world_to_cell(pos)) == CellState.VISIBLE


func is_explored_world(pos: Vector3) -> bool:
	var s := get_cell_state(world_to_cell(pos))
	return s == CellState.EXPLORED or s == CellState.VISIBLE


func is_unit_visible_to_player(unit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	if int(unit.get("team_id")) == PLAYER_TEAM:
		return true
	return is_visible_world((unit as Node3D).global_position)


func is_building_visible_to_player(building) -> bool:
	if building == null or not is_instance_valid(building):
		return false
	if int(building.get("team_id")) == PLAYER_TEAM:
		return true
	return is_visible_world((building as Node3D).global_position)


func get_grid_size() -> Vector2i:
	return Vector2i(_cols, _rows)


func get_cell_size() -> float:
	return CELL_SIZE


func get_fog_texture() -> ImageTexture:
	return _fog_texture


func get_map_bounds() -> Rect2:
	return Rect2(MAP_MIN_X, MAP_MIN_Z, MAP_MAX_X - MAP_MIN_X, MAP_MAX_Z - MAP_MIN_Z)


func _update_visibility() -> void:
	for i in range(_cells.size()):
		if _cells[i] == CellState.VISIBLE:
			_cells[i] = CellState.EXPLORED

	var um := get_node_or_null("/root/UnitManager")
	if um != null and "units" in um:
		for u in um.units:
			if not _is_valid_player_unit(u):
				continue
			_stamp_circle((u as Node3D).global_position, _unit_radius(u))

	var bm := get_node_or_null("/root/BuildingManager")
	if bm != null:
		_stamp_buildings(bm.get("town_centers"), RADIUS_TC)
		_stamp_buildings(bm.get("barracks_list"), RADIUS_BARRACKS)
		_stamp_buildings(bm.get("watchtowers_list"), RADIUS_WATCHTOWER)

	_rebuild_fog_image()
	_apply_enemy_world_visibility(um, bm)
	visibility_updated.emit()


func _rebuild_fog_image() -> void:
	for z in range(_rows):
		for x in range(_cols):
			var s := int(_cells[z * _cols + x])
			var v: int = 0
			if s == CellState.VISIBLE:
				v = 255
			elif s == CellState.EXPLORED:
				v = 128
			_fog_image.set_pixel(x, z, Color8(v, v, v))
	_fog_texture.update(_fog_image)


func _apply_enemy_world_visibility(um, bm) -> void:
	if um != null and "units" in um:
		for u in um.units:
			if u == null or not is_instance_valid(u):
				continue
			if not (u is Node3D):
				continue
			var n := u as Node3D
			if int(u.get("team_id")) == PLAYER_TEAM:
				n.visible = true
				continue
			if u.has_method("is_dead") and u.is_dead():
				n.visible = false
				continue
			if u.get("unit_state") != null and int(u.unit_state) == UNIT_STATE_DEAD:
				n.visible = false
				continue
			n.visible = is_visible_world(n.global_position)

	if bm == null:
		return
	_set_enemy_building_vis(bm.get("town_centers"))
	_set_enemy_building_vis(bm.get("barracks_list"))
	_set_enemy_building_vis(bm.get("watchtowers_list"))
	if bm.get("buildings") != null:
		_set_enemy_building_vis(bm.get("buildings"))


func _set_enemy_building_vis(list_val) -> void:
	if list_val == null:
		return
	for b in list_val:
		if b == null or not is_instance_valid(b):
			continue
		if not (b is Node3D):
			continue
		var n := b as Node3D
		if int(b.get("team_id")) == PLAYER_TEAM:
			n.visible = true
			continue
		if b.get("is_destroyed") == true:
			n.visible = false
			continue
		n.visible = is_visible_world(n.global_position)


func _stamp_buildings(list_val, radius: float) -> void:
	if list_val == null:
		return
	for b in list_val:
		if not _is_valid_player_building(b):
			continue
		_stamp_circle((b as Node3D).global_position, radius)


func _is_valid_player_unit(u) -> bool:
	if u == null or not is_instance_valid(u):
		return false
	if int(u.get("team_id")) != PLAYER_TEAM:
		return false
	if u.has_method("is_dead") and u.is_dead():
		return false
	if u.get("unit_state") != null and int(u.unit_state) == UNIT_STATE_DEAD:
		return false
	return true


func _is_valid_player_building(b) -> bool:
	if b == null or not is_instance_valid(b):
		return false
	if int(b.get("team_id")) != PLAYER_TEAM:
		return false
	if b.get("is_destroyed") == true:
		return false
	if b.get("is_constructed") == false:
		return false
	if b.get("deployment_state") != null and int(b.deployment_state) != DEPLOYED:
		return false
	return true


func _unit_radius(u) -> float:
	if u is Worker:
		return RADIUS_WORKER
	if u is Soldier:
		return RADIUS_SOLDIER
	if u.get_script() != null:
		var path := str(u.get_script().resource_path)
		if "Cavalry" in path:
			return RADIUS_CAVALRY
		if "Siege" in path:
			return RADIUS_SIEGE
		if "Worker" in path:
			return RADIUS_WORKER
		if "Soldier" in path:
			return RADIUS_SOLDIER
	var sn := str(u.name) if u != null else ""
	if "Cavalry" in sn:
		return RADIUS_CAVALRY
	if "Siege" in sn:
		return RADIUS_SIEGE
	return RADIUS_DEFAULT_UNIT


func _stamp_circle(center: Vector3, radius: float) -> void:
	if radius <= 0.0:
		return
	var cell_r := int(ceil(radius / CELL_SIZE))
	var cc := world_to_cell(center)
	var r2 := radius * radius
	for dz in range(-cell_r, cell_r + 1):
		for dx in range(-cell_r, cell_r + 1):
			var cx := cc.x + dx
			var cz := cc.y + dz
			if cx < 0 or cz < 0 or cx >= _cols or cz >= _rows:
				continue
			var wx := MAP_MIN_X + (float(cx) + 0.5) * CELL_SIZE
			var wz := MAP_MIN_Z + (float(cz) + 0.5) * CELL_SIZE
			var ddx := wx - center.x
			var ddz := wz - center.z
			if ddx * ddx + ddz * ddz > r2:
				continue
			_cells[cz * _cols + cx] = CellState.VISIBLE
