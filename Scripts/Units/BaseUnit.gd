extends CharacterBody3D

class_name BaseUnit

enum UnitState {
	IDLE,
	MOVING,
	HARVESTING,
	RETURNING,
	DEPOSITING,
	BUILDING,
	ATTACKING,
	DEATH
}

@export var health: int = 100

var selected: bool = false
var move_target: Vector3 = Vector3.ZERO
var harvest_target: BaseResource = null
var unit_state: UnitState = UnitState.IDLE

var _harvest_navigation_target := Vector3.ZERO

@onready var movement: MovementComponent = ($MovementComponent if has_node("MovementComponent") else get_node_or_null("Components/MovementComponent")) as MovementComponent
@onready var inventory: InventoryComponent = ($InventoryComponent if has_node("InventoryComponent") else get_node_or_null("Components/InventoryComponent")) as InventoryComponent
@onready var harvest_component: HarvestComponent = ($HarvestComponent if has_node("HarvestComponent") else get_node_or_null("Components/HarvestComponent")) as HarvestComponent


func _ready() -> void:
	collision_layer = 2
	collision_mask = 13
	add_to_group("Unit")

	# Динамически создаем MovementComponent, если он отсутствует в сцене
	if movement == null:
		movement = MovementComponent.new()
		add_child(movement)

	# Динамически создаем HealthComponent, если он отсутствует в сцене
	var health_comp = get_node_or_null("HealthComponent")
	if health_comp == null:
		health_comp = get_node_or_null("Components/HealthComponent")
	if health_comp == null:
		health_comp = HealthComponent.new()
		health_comp.name = "HealthComponent"
		health_comp.max_health = health
		add_child(health_comp)

	UnitManager.register_unit(self)


func _exit_tree() -> void:
	if is_instance_valid(self):
		UnitManager.unregister_unit(self)


func select() -> void:
	selected = true
	var ring = get_node_or_null("SelectionRing")
	if ring != null:
		ring.visible = true


func deselect() -> void:
	selected = false
	var ring = get_node_or_null("SelectionRing")
	if ring != null:
		ring.visible = false


func set_move_target(target: Vector3) -> void:
	move_target = target
	harvest_target = null  # Очищаем сбор ресурсов при ручном приказе перемещения
	_harvest_navigation_target = Vector3.ZERO # Сбрасываем сохраненную цель
	unit_state = UnitState.MOVING
	if movement != null:
		movement.move_to(target)


func set_harvest_target(resource: BaseResource) -> void:
	harvest_target = resource
	_harvest_navigation_target = Vector3.ZERO # Сбрасываем сохраненную цель при новой команде
	if resource != null:
		unit_state = UnitState.IDLE  # Переводим в IDLE, чтобы стейт-машина запустила движение


func move_to_harvest_target() -> void:
	if movement != null and harvest_target != null and is_instance_valid(harvest_target):
		var target_pos := harvest_target.global_position
		var map := get_world_3d().get_navigation_map()
		var map_valid := map.is_valid()
		
		# Если навигационная карта еще невалидна, не начинаем движение
		# и остаемся в состоянии IDLE, чтобы повторить вызов на следующем кадре.
		if not map_valid:
			print("[DIAG_HARVEST_NAV] Map not valid yet, waiting for next frame...")
			return
			
		var closest := NavigationServer3D.map_get_closest_point(map, target_pos)
		
		# --- РАСШИРЕННАЯ ДИАГНОСТИКА ПО ТРЕБОВАНИЮ ПОЛЬЗОВАТЕЛЯ ---
		var region: NavigationRegion3D = null
		if is_inside_tree() and get_tree().current_scene != null:
			region = get_tree().current_scene.find_child("NavigationRegion3D", true, false) as NavigationRegion3D
			
		var region_rid := RID()
		var map_region_count := 0
		var all_region_nodes_count := 0
		
		if region != null:
			region_rid = region.get_rid()
		
		# Считаем количество нод региона в сцене
		if is_inside_tree() and get_tree().current_scene != null:
			var nodes := get_tree().current_scene.find_children("*", "NavigationRegion3D", true, false)
			all_region_nodes_count = nodes.size()
			
		# Считаем количество регионов, зарегистрированных сервером на этой карте
		var registered_regions := NavigationServer3D.map_get_regions(map)
		map_region_count = registered_regions.size()
		
		# Находим ближайшие точки для разных позиций в целях сравнения
		var worker_pos := global_position # Для Worker, вызывающего функцию
		var player_node = get_tree().current_scene.find_child("player", true, false)
		var player_pos := Vector3.ZERO
		if player_node != null and player_node is Node3D:
			player_pos = (player_node as Node3D).global_position
			
		var closest_for_tree := NavigationServer3D.map_get_closest_point(map, target_pos)
		var closest_for_worker := NavigationServer3D.map_get_closest_point(map, worker_pos)
		var closest_for_player := NavigationServer3D.map_get_closest_point(map, player_pos)
		
		print("[DIAG_HARVEST_NAV_COMPREHENSIVE]")
		print("NavigationMap RID: ", map)
		print("NavigationRegion3D RID: ", region_rid)
		print("Количество NavigationRegion3D в текущем World: ", all_region_nodes_count)
		print("Количество регионов, зарегистрированных на карте: ", map_region_count)
		if region != null:
			print("NavigationRegion3D enabled: ", region.enabled)
			print("NavigationMesh valid: ", region.navigation_mesh != null)
			print("NavigationRegion3D global_transform: ", region.global_transform)
		print("Ближайшая точка для Tree: ", closest_for_tree)
		print("Ближайшая точка для позиции Worker: ", closest_for_worker)
		print("Ближайшая точка для позиции Player: ", closest_for_player)
		print("Расстояние между Tree и ближайшей точкой: ", target_pos.distance_to(closest_for_tree))
		# --------------------------------------------------------
		
		var dist_closest_to_resource := closest.distance_to(target_pos)
		var dist_unit_to_closest := global_position.distance_to(closest)
		
		# Выводим подробную диагностику по требованию пользователя
		print("[DIAG_HARVEST_NAV]")
		print("Unit: ", name)
		print("Resource: ", harvest_target.name)
		print("ResourcePosition: ", target_pos)
		print("MapValid: ", map_valid)
		print("ClosestPoint: ", closest)
		print("DistanceClosestToResource: ", dist_closest_to_resource)
		print("DistanceUnitToClosest: ", dist_unit_to_closest)
		
		# Проверяем, не нацелены ли мы уже на ту же точку и не стоим ли мы практически в ней
		var dist_to_nav_target := global_position.distance_to(closest)
		if _harvest_navigation_target.is_equal_approx(closest) and dist_to_nav_target < 0.6:
			print("[DIAG_HARVEST_NAV_REPEAT]")
			print("Unit: ", name)
			print("NavigationTarget: ", closest)
			print("DistanceToNavigationTarget: ", dist_to_nav_target)
			return # Избегаем бесконечного повторного вызова
		
		_harvest_navigation_target = closest
		movement.move_to(closest)


func _physics_process(delta: float) -> void:
	match unit_state:
		UnitState.IDLE:
			if harvest_target != null and is_instance_valid(harvest_target):
				var dist := global_position.distance_to(harvest_target.global_position)
				if dist <= harvest_target.interaction_distance:
					print("[DIAG_HARVEST_TRANSITION]")
					print("Unit: ", name)
					print("Distance: ", dist)
					print("InteractionDistance: ", harvest_target.interaction_distance)
					unit_state = UnitState.HARVESTING
				else:
					move_to_harvest_target()

		UnitState.MOVING:
			if harvest_target != null and is_instance_valid(harvest_target):
				var dist := global_position.distance_to(harvest_target.global_position)
				if dist <= harvest_target.interaction_distance:
					print("[DIAG_HARVEST_TRANSITION]")
					print("Unit: ", name)
					print("Distance: ", dist)
					print("InteractionDistance: ", harvest_target.interaction_distance)
					unit_state = UnitState.HARVESTING
					velocity = Vector3.ZERO
					if movement != null:
						movement.stop_movement()
					return
			if movement != null:
				movement.process_movement(delta)

		UnitState.HARVESTING:
			if harvest_target != null and is_instance_valid(harvest_target):
				if inventory != null and inventory.is_full():
					unit_state = UnitState.RETURNING
				elif harvest_component != null:
					harvest_component.tick_harvest(delta, harvest_target)
			else:
				unit_state = UnitState.IDLE

		UnitState.RETURNING:
			var tc = BuildingManager.get_nearest_town_center(global_position)
			if tc != null and is_instance_valid(tc):
				var dist = global_position.distance_to(tc.global_position)
				var interaction_dist = tc.interaction_distance if "interaction_distance" in tc else 3.0
				print("[DIAG_RETURNING] Worker pos: ", global_position, " | TC pos: ", tc.global_position, " | Distance: ", dist, " | InteractionDistance: ", interaction_dist)
				if dist < interaction_dist:
					unit_state = UnitState.DEPOSITING
					velocity = Vector3.ZERO
					if movement != null and movement.nav_agent != null:
						movement.nav_agent.target_position = global_position
				else:
					if movement != null:
						movement.move_to(tc.global_position)
						unit_state = UnitState.RETURNING # Предотвращаем смену стейта на MOVING из-за вызова movement.move_to()
						movement.process_movement(delta)
			else:
				unit_state = UnitState.IDLE

		UnitState.DEPOSITING:
			var tc = BuildingManager.get_nearest_town_center(global_position)
			if tc != null and is_instance_valid(tc):
				if inventory != null:
					var resources: Dictionary = inventory.drain_all()
					if tc.has_method("deposit_resources"):
						tc.deposit_resources(resources)

				if harvest_target != null and is_instance_valid(harvest_target):
					unit_state = UnitState.IDLE
					move_to_harvest_target()
				else:
					unit_state = UnitState.IDLE
			else:
				unit_state = UnitState.IDLE
