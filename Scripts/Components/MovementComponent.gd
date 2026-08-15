extends Node

class_name MovementComponent

@export var speed: float = 5.0
@export var acceleration: float = 30.0

@onready var unit: BaseUnit = get_parent() as BaseUnit
var nav_agent: NavigationAgent3D

var _first_frame := false
var _target_position := Vector3.ZERO

var grid_path: Array[Vector2i] = []
var current_path_index: int = 0
var current_cell_target_pos: Vector3 = Vector3.ZERO

# Переменные для обнаружения застревания (Stuck Detection)
var _stuck_timer: float = 0.0
var _last_position: Vector3 = Vector3.ZERO
var _requested_velocity := Vector3.ZERO


func _ready() -> void:
	if unit != null:
		nav_agent = unit.get_node_or_null("NavigationAgent3D") as NavigationAgent3D
		if nav_agent == null:
			# Сцена не содержит NavigationAgent3D, создаем его динамически
			nav_agent = NavigationAgent3D.new()
			nav_agent.path_desired_distance = 0.5
			nav_agent.target_desired_distance = 0.5
			
			# Подключаем tree_entered для безопасной инициализации после входа в SceneTree
			nav_agent.tree_entered.connect(_on_nav_agent_tree_entered)
			
			# Добавляем в родителя отложенно и безопасно
			unit.call_deferred("add_child", nav_agent)
			print("[DIAG_NAV_LIFECYCLE] Instantiated NavigationAgent3D for ", unit.name, ". Requesting add_child.call_deferred")
		else:
			# Узел уже был пре-дефайнен в сцене, инициализируем его сразу
			_initialize_nav_agent()


func _on_nav_agent_tree_entered() -> void:
	# Откладываем инициализацию параметров, чтобы Godot успел связать агент с картой World3D
	call_deferred("_initialize_nav_agent")


func _initialize_nav_agent() -> void:
	if nav_agent == null or not nav_agent.is_inside_tree():
		return
		
	# Настройка параметров обхода препятствий (avoidance)
	nav_agent.radius = 0.5
	nav_agent.neighbor_distance = 10.0
	nav_agent.max_neighbors = 10
	nav_agent.time_horizon_agents = 1.0
	nav_agent.avoidance_layers = 1
	nav_agent.avoidance_mask = 1
	
	# Активируем обход RVO только после входа в дерево
	nav_agent.avoidance_enabled = true
	
	print("[DIAG_NAV_AGENT_INIT] Unit: ", unit.name,
		" | avoidance_enabled: ", nav_agent.avoidance_enabled,
		" | avoidance_layer: ", nav_agent.avoidance_layers,
		" | avoidance_mask: ", nav_agent.avoidance_mask,
		" | radius: ", nav_agent.radius,
		" | neighbor_distance: ", nav_agent.neighbor_distance,
		" | max_neighbors: ", nav_agent.max_neighbors)
	
	# Подключаем сигнал velocity_computed
	if not nav_agent.velocity_computed.is_connected(_on_velocity_computed):
		nav_agent.velocity_computed.connect(_on_velocity_computed)
		
	# Запуск отложенной проверки на валидность карты
	_verify_rvo_ready()


func _verify_rvo_ready() -> void:
	if nav_agent == null or not nav_agent.is_inside_tree():
		return
		
	var map := nav_agent.get_navigation_map()
	var server_map := NavigationServer3D.agent_get_map(nav_agent.get_rid()) if nav_agent.get_rid().is_valid() else RID()
	
	if map.is_valid() and server_map.is_valid() and map == server_map:
		print("[RVO_READY] ", unit.name, " registered on navigation map. Map RID: ", map, " | Agent RID: ", nav_agent.get_rid())
	else:
		# Если на первом кадре запуска игры навигационная карта еще не синхронизировалась,
		# переносим проверку на следующий физический кадр.
		var tree = get_tree()
		if tree != null:
			await tree.physics_frame
			_verify_rvo_ready()


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if unit != null:
		print("[RVO_CALLBACK] ", unit.name)
		
		# --- ВРЕМЕННАЯ ДИАГНОСТИКА ПО ЗАПРОСУ ПОЛЬЗОВАТЕЛЯ ---
		var my_rid := nav_agent.get_rid() if nav_agent else RID()
		var my_map := nav_agent.get_navigation_map() if nav_agent else RID()
		var world_3d_map := unit.get_world_3d().get_navigation_map() if unit.is_inside_tree() else RID()
		
		# Считываем позицию агента с сервера навигации
		var agent_server_pos := NavigationServer3D.agent_get_position(my_rid) if my_rid.is_valid() else Vector3.ZERO
		var pos_diff := unit.global_position.distance_to(agent_server_pos)
		
		# Определение размеров CollisionShape3D
		var shape_info := "No CollisionShape3D"
		var col_shape_node = unit.get_node_or_null("CollisionShape3D")
		if col_shape_node == null:
			for child in unit.get_children():
				if child is CollisionShape3D:
					col_shape_node = child
					break
		if col_shape_node != null and col_shape_node is CollisionShape3D:
			var shape = col_shape_node.shape
			if shape != null:
				if shape is CylinderShape3D:
					shape_info = "Cylinder(radius: " + str(shape.radius) + ", height: " + str(shape.height) +
