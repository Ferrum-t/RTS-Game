extends Node3D

## Phase 3 SPIKE controller — automated sequence. Does not modify production systems.
## v2: physics-only probe (no nav path) + unregister before building move.

const WORKER_SCENE := preload("res://Scenes/Units/worker.tscn")
const BUILDING_SCRIPT := preload("res://Scripts/Spike/Phase3MobileBuilding.gd")

const OLD_POS := Vector3(0.0, 0.0, 5.0)
const NEW_POS := Vector3(12.0, 0.0, 5.0)
const WORKER_START := Vector3(-10.0, 0.0, 5.0)
const TARGET_BEHIND_OLD := Vector3(10.0, 0.0, 5.0)

var _building: Phase3MobileBuilding = null
var _worker: BaseUnit = null
var _results: Dictionary = {}


func _ready() -> void:
	print("========== PHASE 3 SPIKE START (v2) ==========")
	print("[SPIKE] FACTS: TC L1/M1 Box4; Worker L2/M1; NavBake by instance_id")
	print("[SPIKE] MovementComponent requires BaseUnit — building uses test-only mover")
	print("[SPIKE] v2: physics probe = direct velocity (no NavAgent path)")
	print("[SPIKE] v2: building move = unregister → move → register")
	call_deferred("_start_sequence")


func _start_sequence() -> void:
	await get_tree().create_timer(0.5).timeout
	_spawn_building(OLD_POS)
	# Physics probe BEFORE register (no carve → Worker can drive into collider)
	await _spawn_worker()
	await get_tree().create_timer(0.15).timeout
	await _test1a_physics_only()
	# Then register for nav tests
	_building.register_nav()
	await get_tree().create_timer(0.5).timeout
	await _test1b_nav_avoids()
	await _test2_building_moves_unregistered()
	await _test3_reregister()
	_print_summary()


func _spawn_building(pos: Vector3) -> void:
	var node := CharacterBody3D.new()
	node.set_script(BUILDING_SCRIPT)
	add_child(node)
	_building = node as Phase3MobileBuilding
	_building.global_position = pos

	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(4, 2, 4)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.2, 0.8)
	box_mesh.material = mat
	mesh.mesh = box_mesh
	mesh.position = Vector3(0, 1, 0)
	_building.add_child(mesh)

	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4, 2, 4)
	cs.shape = shape
	cs.position = Vector3(0, 1, 0)
	cs.name = "CollisionShape3D"
	_building.add_child(cs)

	_building.collision_layer = 1
	_building.collision_mask = 1
	_building._print_collision_diag()


func _spawn_worker() -> void:
	_worker = WORKER_SCENE.instantiate() as BaseUnit
	add_child(_worker)
	_worker.global_position = WORKER_START
	_worker.team_id = 0
	await get_tree().physics_frame
	print("[SPIKE] worker collision_layer=", _worker.collision_layer,
		" collision_mask=", _worker.collision_mask,
		" pos=", _worker.global_position)


## Drive Worker into building with raw velocity — no MovementComponent / no NavAgent path.
func _test1a_physics_only() -> void:
	print("---------- TEST 1A: physics-only (direct velocity, no nav path) ----------")
	_worker.global_position = Vector3(-6.0, 0.0, 5.0)
	_worker.velocity = Vector3.ZERO
	# Cancel any order / freeze unit AI so movement component does not steer
	_worker.unit_state = BaseUnit.UnitState.IDLE
	_worker.current_order = Order.none()
	if _worker.movement:
		_worker.movement.cancel()
	await get_tree().physics_frame

	var hit_building: bool = false
	var max_x: float = _worker.global_position.x
	var t0: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 3000:
		# Force unit_state IDLE every frame so BaseUnit.update_idle only does move_and_slide with our velocity
		_worker.unit_state = BaseUnit.UnitState.IDLE
		_worker.velocity = Vector3(6.0, 0.0, 0.0)
		# BaseUnit._physics_process will also call move_and_slide in IDLE — set velocity before it runs
		await get_tree().physics_frame
		max_x = maxf(max_x, _worker.global_position.x)
		if _worker.get_slide_collision_count() > 0:
			var col := _worker.get_slide_collision(0)
			if col and col.get_collider() == _building:
				hit_building = true
				print("[SPIKE] TEST1A physics HIT: is_on_wall=", _worker.is_on_wall(),
					" slide_count=", _worker.get_slide_collision_count(),
					" collider=", col.get_collider().name,
					" worker_pos=", _worker.global_position)
				break
		if _worker.is_on_wall():
			print("[SPIKE] TEST1A is_on_wall=true pos=", _worker.global_position,
				" slide=", _worker.get_slide_collision_count())

	# Building center x=0, half-extent 2 → wall at x≈-2. Worker half 0.25 → stop near x≈-2.25
	var stopped_before_center: bool = max_x < 0.5 and _worker.global_position.x < 1.0
	_results["T1_physics_blocks"] = hit_building or (stopped_before_center and _worker.global_position.x > -4.0)
	print("[SPIKE] TEST1A result hit_building=", hit_building,
		" max_x=", max_x,
		" final_pos=", _worker.global_position,
		" stopped_before_center=", stopped_before_center)

	_worker.velocity = Vector3.ZERO


func _test1b_nav_avoids() -> void:
	print("---------- TEST 1B: nav path around registered building ----------")
	_worker.global_position = WORKER_START
	_worker.velocity = Vector3.ZERO
	await get_tree().physics_frame
	_worker.replace_order_move(TARGET_BEHIND_OLD)
	await get_tree().create_timer(0.35).timeout

	var path_n: int = 0
	if _worker.nav_agent:
		_worker.nav_agent.get_next_path_position()
		path_n = _worker.nav_agent.get_current_navigation_path().size()
	print("[SPIKE] TEST1B nav path_n=", path_n)

	var t0: int = Time.get_ticks_msec()
	var went_around: bool = false
	while Time.get_ticks_msec() - t0 < 8000:
		await get_tree().physics_frame
		var p: Vector3 = _worker.global_position
		if absf(p.z - OLD_POS.z) > 2.5:
			went_around = true
		if p.distance_to(TARGET_BEHIND_OLD) < 1.5:
			went_around = true
			break
		if _worker.unit_state == BaseUnit.UnitState.IDLE and p.distance_to(WORKER_START) > 2.0:
			break

	_results["T1_nav_avoids"] = path_n > 1 or went_around
	print("[SPIKE] TEST1B result path_n=", path_n, " went_around_or_arrived=", went_around,
		" worker_pos=", _worker.global_position)


func _test2_building_moves_unregistered() -> void:
	print("---------- TEST 2: building moves AFTER unregister ----------")
	_worker.velocity = Vector3.ZERO
	_worker.unit_state = BaseUnit.UnitState.IDLE
	if _worker.movement:
		_worker.movement.cancel()
	_worker.global_position = Vector3(-15.0, 0.0, 5.0)

	# Critical: remove footprint before moving so building is not carved into its own obstacle
	_building.unregister_nav()
	await get_tree().create_timer(0.4).timeout

	var start: Vector3 = _building.global_position
	_building.request_move_to(NEW_POS)
	var t0: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 12000:
		await get_tree().physics_frame
		if _building.last_move_status == "ARRIVED":
			break

	var moved: bool = start.distance_to(_building.global_position) > 5.0
	var arrived: bool = (_building.last_move_status == "ARRIVED")
	_results["T2_moves"] = moved
	_results["T2_arrived"] = arrived
	print("[SPIKE] TEST2 result moved=", moved, " arrived=", arrived,
		" pos=", _building.global_position, " status=", _building.last_move_status)

	# Snap if still not there (should not be needed if PASS)
	if not arrived:
		_building.stop_move()
		_building.global_position = NEW_POS
		print("[SPIKE] TEST2 FAIL fallback teleport to NEW_POS for TEST3")

	_building.register_nav()
	await get_tree().create_timer(0.5).timeout


func _test3_reregister() -> void:
	print("---------- TEST 3: NEW blocked (physics+nav), OLD free ----------")
	# Ensure at NEW and registered
	if _building.global_position.distance_to(NEW_POS) > 0.5:
		_building.global_position = NEW_POS
		_building.unregister_nav()
		await get_tree().create_timer(0.15).timeout
		_building.register_nav()
		await get_tree().create_timer(0.5).timeout

	print("[SPIKE] TEST3 building at ", _building.global_position, " old was ", OLD_POS)

	# 3A physics-only into NEW building
	_worker.global_position = Vector3(NEW_POS.x - 6.0, 0.0, NEW_POS.z)
	_worker.velocity = Vector3.ZERO
	_worker.unit_state = BaseUnit.UnitState.IDLE
	if _worker.movement:
		_worker.movement.cancel()
	await get_tree().physics_frame

	var hit_new: bool = false
	var t0: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 3000:
		_worker.unit_state = BaseUnit.UnitState.IDLE
		_worker.velocity = Vector3(6.0, 0.0, 0.0)
		await get_tree().physics_frame
		if _worker.get_slide_collision_count() > 0:
			var col := _worker.get_slide_collision(0)
			if col and col.get_collider() == _building:
				hit_new = true
				print("[SPIKE] TEST3A physics HIT NEW collider=", col.get_collider().name,
					" pos=", _worker.global_position)
				break
	_results["T3_new_blocks_physics"] = hit_new
	print("[SPIKE] TEST3A new_blocks_physics=", hit_new, " worker_pos=", _worker.global_position)
	_worker.velocity = Vector3.ZERO

	# 3A nav around NEW
	_worker.global_position = Vector3(NEW_POS.x - 10.0, 0.0, NEW_POS.z)
	await get_tree().physics_frame
	_worker.replace_order_move(Vector3(NEW_POS.x + 10.0, 0.0, NEW_POS.z))
	await get_tree().create_timer(0.35).timeout
	var path_new: int = 0
	if _worker.nav_agent:
		_worker.nav_agent.get_next_path_position()
		path_new = _worker.nav_agent.get_current_navigation_path().size()
	_results["T3_new_nav_path"] = path_new
	print("[SPIKE] TEST3A nav path_n around NEW=", path_new)

	# 3B physics-only through OLD (should be free — no collider there)
	_worker.global_position = Vector3(OLD_POS.x - 6.0, 0.0, OLD_POS.z)
	_worker.velocity = Vector3.ZERO
	_worker.unit_state = BaseUnit.UnitState.IDLE
	if _worker.movement:
		_worker.movement.cancel()
	await get_tree().physics_frame

	var crossed_old: bool = false
	var hit_ghost: bool = false
	var t1: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t1 < 3000:
		_worker.unit_state = BaseUnit.UnitState.IDLE
		_worker.velocity = Vector3(6.0, 0.0, 0.0)
		await get_tree().physics_frame
		if _worker.get_slide_collision_count() > 0:
			var col2 := _worker.get_slide_collision(0)
			if col2 and col2.get_collider() == _building:
				hit_ghost = true
		if _worker.global_position.x > OLD_POS.x + 2.0:
			crossed_old = true
			break

	_results["T3_old_free_physics"] = crossed_old and not hit_ghost
	print("[SPIKE] TEST3B old_free crossed=", crossed_old, " hit_ghost=", hit_ghost,
		" worker_pos=", _worker.global_position)
	_worker.velocity = Vector3.ZERO


func _print_summary() -> void:
	print("========== PHASE 3 SPIKE SUMMARY (v2) ==========")
	print("[SPIKE] T1A physics blocks Worker: ", _results.get("T1_physics_blocks", false))
	print("[SPIKE] T1B nav avoids building: ", _results.get("T1_nav_avoids", false))
	print("[SPIKE] T2 building moves (after unregister): ", _results.get("T2_moves", false))
	print("[SPIKE] T2 building ARRIVED: ", _results.get("T2_arrived", false))
	print("[SPIKE] T3 NEW blocks physics: ", _results.get("T3_new_blocks_physics", false))
	print("[SPIKE] T3 NEW nav path_n: ", _results.get("T3_new_nav_path", 0))
	print("[SPIKE] T3 OLD free physics: ", _results.get("T3_old_free_physics", false))
	print("========== PHASE 3 SPIKE END — paste full log ==========")
