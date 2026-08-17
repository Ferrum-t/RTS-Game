extends RefCounted

class_name MovementComponent

## Pathfinding via Godot NavigationServer3D.
## Each unit has a NavigationAgent3D that follows the navmesh
## and uses RVO avoidance for units + NavigationObstacle3D buildings.

var owner: BaseUnit
var agent: NavigationAgent3D


func _init(unit: BaseUnit) -> void:
	owner = unit
	agent = NavigationAgent3D.new()
	owner.add_child(agent)

	agent.path_desired_distance = 0.4
	agent.target_desired_distance = 0.35
	agent.avoidance_enabled = true
	agent.radius = 0.45
	agent.height = 1.2
	agent.neighbor_distance = 4.0
	agent.max_neighbors = 8
	agent.time_horizon_agents = 1.0
	agent.time_horizon_obstacles = 0.5
	agent.max_speed = owner.move_speed
	agent.avoidance_layers = 1
	agent.avoidance_mask = 1

	# Avoidance callback (Godot 4 velocity-based avoidance)
	if agent.has_signal("velocity_computed"):
		agent.velocity_computed.connect(_on_velocity_computed)


func set_target(world_pos: Vector3) -> void:
	agent.target_position = world_pos


func update(_delta: float) -> void:
	agent.max_speed = owner.move_speed

	# Keep agent target in sync with unit move_target
	if agent.target_position.distance_to(owner.move_target) > 0.1:
		agent.target_position = owner.move_target

	if agent.is_navigation_finished():
		owner.velocity = Vector3.ZERO
		if owner.unit_state == BaseUnit.UnitState.MOVING:
			owner.unit_state = BaseUnit.UnitState.IDLE
		return

	var next_pos: Vector3 = agent.get_next_path_position()
	var to_next: Vector3 = next_pos - owner.global_position
	to_next.y = 0.0

	if to_next.length() < 0.05:
		owner.velocity = Vector3.ZERO
		return

	var desired_vel: Vector3 = to_next.normalized() * owner.move_speed

	if agent.avoidance_enabled:
		agent.set_velocity(desired_vel)
		# Actual velocity applied in _on_velocity_computed
	else:
		owner.velocity = desired_vel
		owner.move_and_slide()


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	owner.velocity = safe_velocity
	owner.move_and_slide()
