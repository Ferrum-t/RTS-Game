extends Node3D

## Phase 3 SPIKE controller — automated sequence. Does not modify production systems.

const WORKER_SCENE := preload("res://Scenes/Units/worker.tscn")
const BUILDING_SCRIPT := preload("res://Scripts/Spike/Phase3MobileBuilding.gd")

const OLD_POS := Vector3(0.0, 0.0, 5.0)
const NEW_POS := Vector3(12.0, 0.0, 5.0)
const WORKER_START := Vector3(-10.0, 0.0, 5.0)
const TARGET_THROUGH := Vector3(10.0, 0.0, 5.0)
const TARGET_BEHIND_OLD := Vector3(10.0, 0.0, 5.0)
const TARGET_THROUGH_NEW := Vector3(20.0, 0.0, 5.0)
const TARGET_THROUGH_OLD_AFTER := Vector3(0.0, 0.0, 5.0)

var _building: CharacterBody3D = null
var _worker: BaseUnit = null
var _phase: int = 0
var _timer: float = 0.0
var _results: Dictionary = {}


func _ready() -> void:
	print("========== PHASE 3 SPIKE START ==========")
	print("[SPIKE] FACTS from production scenes:")
	print("[SPIKE]   TownCenter: StaticBody3D, collision_layer DEFAULT=1, mask DEFAULT=1, Box 4x2x4")
	print("[SPIKE]   Worker: CharacterBody3D, collision_layer=2, mask DEFAULT=1 (BaseUnit forces mask=1 in _ready)")
	print("[SPIKE]   NavBake: register_building / unregister_building / update_building_position by instance_id")
	print("[SPIKE]   MovementComponent: requires owner: BaseUnit — cannot attach to plain CharacterBody3D")
	print("[SPIKE]   → Test2 uses test-only NavAgent mover on building (same physics body type)")
	call_deferred("_start_sequence")


func _start_sequence() -> void:
	# Give MatchManager / initial nav bake a moment if present
	await get_tree().create_timer(0.5).timeout
	_spawn_building(OLD_POS)
	_building.register_nav()
	await get_tree().create_timer(0.4).timeout
	_spawn_worker()
	await get_tree().create_timer(0.2).timeout
	await _test1_physics_and_nav()
	await _test2_building_moves()
	await _test3_reregister()
	_print_summary()


func _spawn_building(pos: Vector3) -> void:
	_building = CharacterBody3D.new()
	_building.set_script(BUILDING_SCRIPT)
	add_child(_building)
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

	# Script _ready already ran; force layer after add
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


func _test1_physics_and_nav() -> void:
	print("---------- TEST 1: stationary CharacterBody as building ----------")
	# A: try to walk through building (direct target past center)
	_worker.replace_order_move(TARGET_THROUGH)
	var hit_building := false
	var blocked_or_stopped := false
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 5000:
		await get_tree().physics_frame
		if _worker.get_slide_collision_count() > 0:
			var col := _worker.get_slide_collision(0)
			if col and col.get_collider() == _building:
				hit_building = true
				print("[SPIKE] TEST1-A physics: Worker is_on_wall=", _worker.is_on_wall(),
					" slide_count=", _worker.get_slide_collision_count(),
					" collider=", col.get_collider().name)
				break
		if _worker.unit_state == BaseUnit.UnitState.IDLE and _worker.global_position.distance_to(WORKER_START) > 1.0:
			# stopped without reaching far side
			if _worker.global_position.x < OLD_POS.x + 2.0:
				blocked_or_stopped = true
				break

	var reached_far := _worker.global_position.x > OLD_POS.x + 3.0
	_results["T1_physics_blocks"] = hit_building or (blocked_or_stopped and not reached_far)
	print("[SPIKE] TEST1-A result hit_building=", hit_building,
		" blocked_or_stopped=", blocked_or_stopped,
		" reached_far_side=", reached_far,
		" worker_pos=", _worker.global_position)

	# Reset worker left of building
	_worker.velocity = Vector3.ZERO
	_worker.global_position = WORKER_START
	await get_tree().physics_frame

	# B: path around — target behind building; expect path_n > 1 or worker goes around
	_worker.replace_order_move(TARGET_BEHIND_OLD)
	await get_tree().create_timer(0.3).timeout
	var path_n := 0
	if _worker.nav_agent:
		_worker.nav_agent.get_next_path_position()
		path_n = _worker.nav_agent.get_current_navigation_path().size()
	print("[SPIKE] TEST1-B nav path_n=", path_n, " bake footprints expect >=1")

	t0 = Time.get_ticks_msec()
	var went_around := false
	while Time.get_ticks_msec() - t0 < 8000:
		await get_tree().physics_frame
		var p := _worker.global_position
		# around = significant Z deviation while approaching, or reached x past building without stuck at wall
		if absf(p.z - OLD_POS.z) > 2.5:
			went_around = true
		if p.distance_to(TARGET_BEHIND_OLD) < 1.5:
			went_around = true
			break
		if _worker.unit_state == BaseUnit.UnitState.IDLE and p.distance_to(WORKER_START) > 2.0:
			break

	_results["T1_nav_avoids"] = path_n > 1 or went_around
	print("[SPIKE] TEST1-B result path_n=", path_n, " went_around_or_arrived=", went_around,
		" worker_pos=", _worker.global_position)


func _test2_building_moves() -> void:
	print("---------- TEST 2: CharacterBody can move ----------")
	_worker.velocity = Vector3.ZERO
	_worker.replace_order_move(WORKER_START)
	await get_tree().create_timer(0.2).timeout

	var start := _building.global_position
	_building.request_move_to(NEW_POS)
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 10000:
		await get_tree().physics_frame
		if _building.last_move_status == "ARRIVED":
			break

	var moved := start.distance_to(_building.global_position) > 5.0
	var arrived := _building.last_move_status == "ARRIVED"
	_results["T2_moves"] = moved
	_results["T2_arrived"] = arrived
	print("[SPIKE] TEST2 result moved=", moved, " arrived=", arrived,
		" pos=", _building.global_position, " status=", _building.last_move_status)
	print("[SPIKE] TEST2 NOTE: production MovementComponent not used (typed to BaseUnit)")


func _test3_reregister() -> void:
	print("---------- TEST 3: unregister old + register new obstruction ----------")
	var old_p := OLD_POS
	var new_p := _building.global_position
	new_p.y = 0.0

	# Ensure building is at NEW_POS and nav footprint matches
	_building.global_position = NEW_POS
	_building.unregister_nav()
	await get_tree().create_timer(0.15).timeout
	_building.register_nav()
	await get_tree().create_timer(0.5).timeout

	print("[SPIKE] TEST3 footprints should be at NEW only. old=", old_p, " new=", NEW_POS)

	# A: walk through NEW position — should block / avoid
	_worker.global_position = Vector3(NEW_POS.x - 10.0, 0.0, NEW_POS.z)
	_worker.velocity = Vector3.ZERO
	await get_tree().physics_frame
	_worker.replace_order_move(Vector3(NEW_POS.x + 10.0, 0.0, NEW_POS.z))
	var hit_new := false
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 5000:
		await get_tree().physics_frame
		if _worker.get_slide_collision_count() > 0:
			var col := _worker.get_slide_collision(0)
			if col and col.get_collider() == _building:
				hit_new = true
				print("[SPIKE] TEST3-A physics hit NEW building collider=", col.get_collider().name)
				break
	_results["T3_new_blocks_physics"] = hit_new
	print("[SPIKE] TEST3-A new_blocks_physics=", hit_new, " worker_pos=", _worker.global_position)

	# Nav avoid new
	_worker.global_position = Vector3(NEW_POS.x - 10.0, 0.0, NEW_POS.z)
	await get_tree().physics_frame
	_worker.replace_order_move(Vector3(NEW_POS.x + 10.0, 0.0, NEW_POS.z))
	await get_tree().create_timer(0.3).timeout
	var path_new := 0
	if _worker.nav_agent:
		_worker.nav_agent.get_next_path_position()
		path_new = _worker.nav_agent.get_current_navigation_path().size()
	_results["T3_new_nav_path"] = path_new
	print("[SPIKE] TEST3-A nav path_n around NEW=", path_new)

	# B: walk through OLD position — should be free (no collider, path can be short)
	_worker.global_position = Vector3(OLD_POS.x - 8.0, 0.0, OLD_POS.z)
	_worker.velocity = Vector3.ZERO
	await get_tree().physics_frame
	_worker.replace_order_move(Vector3(OLD_POS.x + 8.0, 0.0, OLD_POS.z))
	var t1 := Time.get_ticks_msec()
	var crossed_old := false
	var hit_ghost := false
	while Time.get_ticks_msec() - t1 < 6000:
		await get_tree().physics_frame
		if _worker.get_slide_collision_count() > 0:
			var col2 := _worker.get_slide_collision(0)
			if col2 and col2.get_collider() == _building:
				hit_ghost = true
		if _worker.global_position.x > OLD_POS.x + 3.0:
			crossed_old = true
			break
		if _worker.unit_state == BaseUnit.UnitState.IDLE and _worker.global_position.distance_to(Vector3(OLD_POS.x - 8.0, 0.0, OLD_POS.z)) > 5.0:
			if _worker.global_position.x > OLD_POS.x:
				crossed_old = true
			break

	_results["T3_old_free_physics"] = crossed_old and not hit_ghost
	print("[SPIKE] TEST3-B old_free crossed=", crossed_old, " hit_building_at_old=", hit_ghost,
		" worker_pos=", _worker.global_position)

	await get_tree().create_timer(0.2).timeout
	if _worker.nav_agent:
		_worker.nav_agent.get_next_path_position()
		var path_old := _worker.nav_agent.get_current_navigation_path().size()
		print("[SPIKE] TEST3-B path_n for route through OLD area (may still be mid-move)=", path_old)


func _print_summary() -> void:
	print("========== PHASE 3 SPIKE SUMMARY ==========")
	print("[SPIKE] T1 physics blocks Worker: ", _results.get("T1_physics_blocks", false))
	print("[SPIKE] T1 nav avoids building: ", _results.get("T1_nav_avoids", false))
	print("[SPIKE] T2 building moves: ", _results.get("T2_moves", false))
	print("[SPIKE] T2 building ARRIVED: ", _results.get("T2_arrived", false))
	print("[SPIKE] T3 NEW blocks physics: ", _results.get("T3_new_blocks_physics", false))
	print("[SPIKE] T3 NEW nav path_n: ", _results.get("T3_new_nav_path", 0))
	print("[SPIKE] T3 OLD free physics: ", _results.get("T3_old_free_physics", false))
	print("[SPIKE] Collision: building L1/M1, worker L2/M1 — same pairing as TownCenter↔Worker")
	print("[SPIKE] Production MovementComponent requires BaseUnit — spike used test-only mover")
	print("========== PHASE 3 SPIKE END — paste full log ==========")
