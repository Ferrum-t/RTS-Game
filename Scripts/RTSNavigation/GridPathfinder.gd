extends Node

class_name GridPathfinder

@export var grid: RTSGridMap


func find_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var actual_start = start
	var actual_goal = goal
	
	if grid != null:
		if not is_walkable(start):
			actual_start = find_nearest_walkable(start, 4)
			if actual_start == Vector2i(-1, -1):
				print("[PATH_ADJUST] Start cell occupied and no walkable replacement found near: ", start)
				return []
			print("[PATH_ADJUST] Start cell occupied, adjusted to: ", actual_start)
			
		if not is_walkable(goal):
			actual_goal = find_nearest_walkable(goal, 4)
			if actual_goal == Vector2i(-1, -1):
				print("[PATH_ADJUST] Goal cell occupied and no walkable replacement found near: ", goal)
				return []
			print("[PATH_ADJUST] Goal cell occupied, adjusted to: ", actual_goal)

	print("START:", actual_start)
	print("GOAL:", actual_goal)
	print("GRID IN FIND_PATH:", grid)
	print("START WALKABLE:", is_walkable(actual_start))
	print("GOAL WALKABLE:", is_walkable(actual_goal))

	var open_list: Array[PathNode] = []
	var closed_list: Array[Vector2i] = []

	var start_node = PathNode.new()
	start_node.cell = actual_start
	start_node.g_cost = 0
	start_node.h_cost = heuristic(actual_start, actual_goal)
	start_node.parent = null

	open_list.append(start_node)

	while open_list.size() > 0:
		var current = get_lowest_f_node(open_list)
		if current == null:
			break
		open_list.erase(current)
		closed_list.append(current.cell)

		if current.cell == actual_goal:
			return reconstruct_path(current)

		for neighbor in get_neighbors(current.cell):
			if closed_list.has(neighbor):
				continue

			var new_g = current.g_cost + 1
			var existing_node: PathNode = null
			for node in open_list:
				if node.cell == neighbor:
					existing_node = node
					break

			if existing_node != null:
				if new_g < existing_node.g_cost:
					existing_node.g_cost = new_g
					existing_node.parent = current
				continue

			var neighbor_node = PathNode.new()
			neighbor_node.cell = neighbor
			neighbor_node.parent = current
			neighbor_node.g_cost = new_g
			neighbor_node.h_cost = heuristic(neighbor, actual_goal)

			open_list.append(neighbor_node)

	return []


func find_nearest_walkable(cell: Vector2i, max_distance: int = 4) -> Vector2i:
	if is_walkable(cell):
		return cell
		
	# Поиск по спирали от центра наружу
	for r in range(1, max_distance + 1):
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				if abs(dx) == r or abs(dy) == r:
					var check_cell = cell + Vector2i(dx, dy)
					if grid != null and check_cell.x >= 0 and check_cell.x < grid.grid_width and check_cell.y >= 0 and check_cell.y < grid.grid_height:
						if not grid.is_cell_occupied(check_cell):
							return check_cell
							
	return Vector2i(-1, -1) # Возвращаем невалидную ячейку, если не нашли свободную


func get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	if grid == null:
		return neighbors

	var directions = [
		Vector2i(0, 1),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(1, 0)
	]

	for dir in directions:
		var neighbor = cell + dir
		if neighbor.x >= 0 and neighbor.x < grid.grid_width and neighbor.y >= 0 and neighbor.y < grid.grid_height:
			if not grid.is_cell_occupied(neighbor):
				neighbors.append(neighbor)

	return neighbors


func heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


func is_walkable(cell: Vector2i) -> bool:
	if grid == null:
		return false
	return not grid.is_cell_occupied(cell)


func get_lowest_f_node(open_list: Array[PathNode]) -> PathNode:
	if open_list.is_empty():
		return null

	var lowest_node = open_list[0]
	for i in range(1, open_list.size()):
		var node = open_list[i]
		var node_f = node.f_cost()
		var lowest_f = lowest_node.f_cost()
		if node_f < lowest_f:
			lowest_node = node
		elif node_f == lowest_f:
			if node.h_cost < lowest_node.h_cost:
				lowest_node = node

	return lowest_node


func reconstruct_path(goal_node: PathNode) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	if goal_node == null:
		return path

	var current = goal_node
	while current != null:
		path.append(current.cell)
		current = current.parent

	path.reverse()
	return path


class PathNode:
	var cell: Vector2i
	var g_cost: int
	var h_cost: int
	var parent: PathNode

	func f_cost() -> int:
		return g_cost + h_cost
