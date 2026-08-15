class_name RTSGridMap
extends Node

var cell_size: float = 1.0
var grid_width: int = 128
var grid_height: int = 128

var occupancy: Array = []
# Maps obstacle instance ID -> Array[Vector2i] of occupied cells
var obstacle_cells: Dictionary = {}


func _ready() -> void:
	ensure_initialized()


func ensure_initialized() -> void:
	if occupancy.is_empty():
		occupancy.resize(grid_width)
		for x in range(grid_width):
			var column: Array[int] = []
			column.resize(grid_height)
			column.fill(0)
			occupancy[x] = column


func world_to_cell(world_pos: Vector3) -> Vector2i:
	var x: int = int(floor(world_pos.x / cell_size)) + int(grid_width / 2)
	var y: int = int(floor(world_pos.z / cell_size)) + int(grid_height / 2)
	return Vector2i(x, y)


func cell_to_world(cell: Vector2i) -> Vector3:
	var shifted_x: float = float(cell.x - grid_width / 2)
	var shifted_z: float = float(cell.y - grid_height / 2)
	var x: float = (shifted_x + 0.5) * cell_size
	var z: float = (shifted_z + 0.5) * cell_size
	return Vector3(x, 0.0, z)


func is_cell_occupied(cell: Vector2i) -> bool:
	ensure_initialized()
	var result: bool = true
	if cell.x >= 0 and cell.x < grid_width and cell.y >= 0 and cell.y < grid_height:
		result = occupancy[cell.x][cell.y] > 0
	else:
		result = true
	return result


func set_cell_occupied(cell: Vector2i, occupied: bool) -> void:
	ensure_initialized()
	if cell.x >= 0 and cell.x < grid_width and cell.y >= 0 and cell.y < grid_height:
		if occupied:
			if occupancy[cell.x][cell.y] == 0:
				occupancy[cell.x][cell.y] = 1
		else:
			occupancy[cell.x][cell.y] = 0


func occupy_rectangle(origin: Vector2i, size: Vector2i) -> void:
	for x in range(size.x):
		for y in range(size.y):
			set_cell_occupied(Vector2i(origin.x + x, origin.y + y), true)
	debug_print_grid()


func debug_print_grid() -> void:
	print("--- Occupied Cells ---")
	for x in range(grid_width):
		for y in range(grid_height):
			if is_cell_occupied(Vector2i(x, y)):
				print("Cell occupied: ", Vector2i(x, y), " | count: ", occupancy[x][y])
	print("----------------------")


func free_rectangle(origin: Vector2i, size: Vector2i) -> void:
	for x in range(size.x):
		for y in range(size.y):
			set_cell_occupied(Vector2i(origin.x + x, origin.y + y), false)


func is_rectangle_free(origin: Vector2i, size: Vector2i) -> bool:
	for x in range(size.x):
		for y in range(size.y):
			if is_cell_occupied(Vector2i(origin.x + x, origin.y + y)):
				return false
	return true


func occupy_obstacle(obstacle: StaticBody3D, occupy: bool) -> void:
	if obstacle == null:
		return
	
	ensure_initialized()
	var obstacle_id = obstacle.get_instance_id()
	
	if not occupy:
		# Safe release using cached cells if available
		if obstacle_cells.has(obstacle_id):
			var cells = obstacle_cells[obstacle_id]
			for cell in cells:
				if cell.x >= 0 and cell.x < grid_width and cell.y >= 0 and cell.y < grid_height:
					occupancy[cell.x][cell.y] = max(0, occupancy[cell.x][cell.y] - 1)
			obstacle_cells.erase(obstacle_id)
			print("[GRID] Safely released obstacle ", obstacle.name, " from grid map using cached cells.")
			return
		
		# Fallback if not cached
		var min_x = INF
		var max_x = -INF
		var min_z = INF
		var max_z = -INF
		
		var shapes_list = []
		_find_collision_shapes(obstacle, shapes_list)
		
		var shapes_found = false
		for child in shapes_list:
			if child is CollisionShape3D and not child.disabled:
				var shape = child.shape
				if shape != null:
					shapes_found = true
					var local_aabb = _get_local_aabb(shape)
					var corners = _get_aabb_corners(local_aabb)
					for corner in corners:
						var global_corner = child.global_transform * corner
						min_x = min(min_x, global_corner.x)
						max_x = max(max_x, global_corner.x)
						min_z = min(min_z, global_corner.z)
						max_z = max(max_z, global_corner.z)
		
		if not shapes_found:
			min_x = obstacle.global_position.x - 0.5
			max_x = obstacle.global_position.x + 0.5
			min_z = obstacle.global_position.z - 0.5
			max_z = obstacle.global_position.z + 0.5
			
		var start_cell = world_to_cell(Vector3(min_x, 0.0, min_z))
		var end_cell = world_to_cell(Vector3(max_x, 0.0, max_z))
		
		for x in range(min(start_cell.x, end_cell.x), max(start_cell.x, end_cell.x) + 1):
			for y in range(min(start_cell.y, end_cell.y), max(start_cell.y, end_cell.y) + 1):
				if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
					occupancy[x][y] = max(0, occupancy[x][y] - 1)
		print("[GRID] Released obstacle ", obstacle.name, " from grid map using fallback calculation.")
		return

	# occupy is true
	# First, if already registered, release it to avoid double registration
	if obstacle_cells.has(obstacle_id):
		occupy_obstacle(obstacle, false)
		
	var min_x = INF
	var max_x = -INF
	var min_z = INF
	var max_z = -INF
	
	var shapes_list = []
	_find_collision_shapes(obstacle, shapes_list)
	
	var shapes_found = false
	for child in shapes_list:
		if child is CollisionShape3D and not child.disabled:
			var shape = child.shape
			if shape != null:
				shapes_found = true
				var local_aabb = _get_local_aabb(shape)
				var corners = _get_aabb_corners(local_aabb)
				for corner in corners:
					var global_corner = child.global_transform * corner
					min_x = min(min_x, global_corner.x)
					max_x = max(max_x, global_corner.x)
					min_z = min(min_z, global_corner.z)
					max_z = max(max_z, global_corner.z)

	if not shapes_found:
		min_x = obstacle.global_position.x - 0.5
		max_x = obstacle.global_position.x + 0.5
		min_z = obstacle.global_position.z - 0.5
		max_z = obstacle.global_position.z + 0.5
		
	var start_cell = world_to_cell(Vector3(min_x, 0.0, min_z))
	var end_cell = world_to_cell(Vector3(max_x, 0.0, max_z))
	
	var occupied_list: Array[Vector2i] = []
	for x in range(min(start_cell.x, end_cell.x), max(start_cell.x, end_cell.x) + 1):
		for y in range(min(start_cell.y, end_cell.y), max(start_cell.y, end_cell.y) + 1):
			if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
				occupancy[x][y] += 1
				occupied_list.append(Vector2i(x, y))
				
	obstacle_cells[obstacle_id] = occupied_list
	print("[GRID] Registered obstacle ", obstacle.name, " occupying cells: ", occupied_list)


func _find_collision_shapes(node: Node, shapes_list: Array) -> void:
	if node is CollisionShape3D:
		shapes_list.append(node)
	for child in node.get_children():
		_find_collision_shapes(child, shapes_list)


func _get_local_aabb(shape: Shape3D) -> AABB:
	if shape is BoxShape3D:
		return AABB(-shape.size / 2.0, shape.size)
	elif shape is SphereShape3D:
		var r = shape.radius
		return AABB(Vector3(-r, -r, -r), Vector3(r * 2, r * 2, r * 2))
	elif shape is CylinderShape3D:
		var r = shape.radius
		var h = shape.height
		return AABB(Vector3(-r, -h/2.0, -r), Vector3(r * 2, h, r * 2))
	elif shape is CapsuleShape3D:
		var r = shape.radius
		var h = shape.height
		return AABB(Vector3(-r, -h/2.0, -r), Vector3(r * 2, h, r * 2))
	else:
		return AABB(Vector3(-0.5, -0.5, -0.5), Vector3(1.0, 1.0, 1.0))


func _get_aabb_corners(aabb: AABB) -> Array[Vector3]:
	return [
		Vector3(aabb.position.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.position.x + aabb.size.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.position.x, aabb.position.y + aabb.size.y, aabb.position.z),
		Vector3(aabb.position.x + aabb.size.x, aabb.position.y + aabb.size.y, aabb.position.z),
		Vector3(aabb.position.x, aabb.position.y, aabb.position.z + aabb.size.z),
		Vector3(aabb.position.x + aabb.size.x, aabb.position.y, aabb.position.z + aabb.size.z),
		Vector3(aabb.position.x, aabb.position.y + aabb.size.y, aabb.position.z + aabb.size.z),
		Vector3(aabb.position.x + aabb.size.x, aabb.position.y + aabb.size.y, aabb.position.z + aabb.size.z),
	]
