extends Node

class_name EconomicAIController

## Stage 1 threshold AI + M17.0 second TC + M17.1 expansion economy polish.
## DECISION only. EXECUTION via shared systems.
##
## M17.1 scope (locked):
##   A expand once per match (_expanded_once)
##   B desired workers 4 (1 TC) / 6 (2 TC)
##   C soft harvest bias toward under-served TC (no worker assignment system)
##   D wood pressure before dual-floor
## Out of scope: 2nd Barracks, towers, repair, combat brain, Climate, 3rd TC, Economy 1.5 planner.

@export var team_id: int = 1
@export var desired_worker_count: int = 4
## Extra workers when alive TC count >= 2 (M17.1-B). Total goal = desired + extra.
@export var extra_workers_at_two_tc: int = 2
@export var attack_threshold: int = 3
@export var decision_interval: float = 1.5
@export var barracks_offset: Vector3 = Vector3(4.0, 0.0, 3.0)
## Soft floor for both wood and stone; below → prefer that resource (after wood pressure).
@export var stock_floor: int = 100
## M17.1-D — if wood below this, force WOOD harvest (covers Soldier 80 / Worker 50).
@export var production_wood_floor: int = 80
## Soft blend: score = worker_dist*(1-w) + underserved_tc_dist*w (M17.1-C).
@export_range(0.0, 0.5, 0.05) var underserved_tc_bias: float = 0.3

## M17.0 — expand thresholds (after Barracks exists, while still on 1 TC).
@export var expand_wood_min: int = 250
@export var expand_stone_min: int = 100
@export var max_ai_tc: int = 2
## Offset from first TC; opposite side of barracks_offset to reduce overlap (TD-01).
@export var second_tc_offset: Vector3 = Vector3(-10.0, 0.0, 6.0)

var _timer: float = 0.0
var _barracks_data: BuildingData = null
var _tc_data: BuildingData = null
## True after we first crossed attack_threshold; reset when army falls below.
var _attack_issued: bool = false
## Alternates preferred type when both stocks are above floor.
var _harvest_flip: int = 0
## M17.1-A — one expansion attempt success per match (no rebuild after TC2 loss).
var _expanded_once: bool = false


func _ready() -> void:
	_barracks_data = load("res://Data/Buildings/BarracksData.tres") as BuildingData
	_tc_data = load("res://Data/Buildings/TownCenterData.tres") as BuildingData
	_timer = 0.5
	print(
		"[AI_ECO] controller ready team=", team_id,
		" workers_base=", desired_worker_count,
		" +extra_at_2tc=", extra_workers_at_two_tc,
		" attack_at=", attack_threshold,
		" stock_floor=", stock_floor,
		" wood_pressure=", production_wood_floor,
		" expand_at W>=", expand_wood_min, " S>=", expand_stone_min,
		" max_tc=", max_ai_tc,
		" expand_once=true"
	)


func _physics_process(delta: float) -> void:
	var mm := get_node_or_null("/root/MatchManager")
	if mm != null and mm.has_method("is_playing") and not mm.is_playing():
		return

	_timer -= delta
	if _timer > 0.0:
		return
	_timer = decision_interval
	_think()


func _think() -> void:
	var rm := get_node_or_null("/root/ResourceManager")
	var workers := _team_workers()
	var soldiers := _team_soldiers()
	var wood := 0
	var stone := 0
	if rm:
		wood = rm.get_stock(team_id, BaseResource.Type.WOOD)
		stone = rm.get_stock(team_id, BaseResource.Type.STONE)
	var tcs: Array = _team_town_centers()
	var goal: int = _worker_goal(tcs.size())
	print(
		"[AI_ECO] workers=", workers.size(), "/", goal,
		" soldiers=", soldiers.size(),
		" tc=", tcs.size(),
		" wood=", wood, " stone=", stone,
		" expanded=", _expanded_once
	)

	_assign_idle_workers(workers, tcs)

	if tcs.is_empty():
		return

	# M17.1-B — train until soft goal (4 or 6).
	if workers.size() < goal:
		_try_train_worker_any_tc(tcs)

	var first_tc: BaseBuilding = tcs[0] as BaseBuilding
	var barracks := _team_barracks()
	if barracks == null:
		_try_build_barracks(first_tc)
		return

	# M17.1-A — at most one successful expand per match.
	if not _expanded_once and tcs.size() < max_ai_tc:
		_try_expand_second_tc(first_tc, wood, stone)

	if barracks is Barracks:
		var b := barracks as Barracks
		if not b.is_training:
			if b.try_train_soldier():
				print("[AI_ECO] training Soldier")

	soldiers = _team_soldiers()
	if soldiers.size() >= attack_threshold:
		if not _attack_issued:
			print("[AI_ECO] attack threshold reached army=", soldiers.size())
			_attack_issued = true
			var n: int = _attach_ai_to_army(soldiers)
			print("[AI_ECO] attack issued on ", n, " soldiers")
		else:
			var n: int = _attach_ai_to_army(soldiers)
			if n > 0:
				print("[AI_ECO] attack reinforcements +", n)
	else:
		_attack_issued = false


func _worker_goal(tc_count: int) -> int:
	if tc_count >= 2:
		return desired_worker_count + extra_workers_at_two_tc
	return desired_worker_count


func _try_train_worker_any_tc(tcs: Array) -> void:
	for node in tcs:
		if not (node is TownCenter):
			continue
		var tcn := node as TownCenter
		if tcn.is_training:
			continue
		if not tcn.is_deployed():
			continue
		if tcn.try_train_worker():
			print("[AI_ECO] training Worker at ", tcn.name)
			return


func _try_expand_second_tc(anchor_tc: BaseBuilding, wood: int, stone: int) -> void:
	if _expanded_once:
		return
	if anchor_tc == null or not is_instance_valid(anchor_tc):
		return
	if _tc_data == null:
		return
	if wood < expand_wood_min or stone < expand_stone_min:
		return

	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	var cost: Dictionary = _tc_data.get_cost_dict()
	if not rm.can_afford(cost, team_id):
		return

	var cm := get_node_or_null("/root/ConstructionManager")
	if cm == null or not cm.has_method("place_building_for_team"):
		return

	var pos: Vector3 = anchor_tc.global_position + second_tc_offset
	pos.y = 0.0
	print("[AI_ECO] expanding 2nd TC at ", pos, " (W=", wood, " S=", stone, ")")
	var built = cm.place_building_for_team(_tc_data, pos, team_id, true)
	if built != null:
		_expanded_once = true
		print("[AI_ECO] 2nd TC completed ", built.name, " team=", team_id, " expand_once locked")


func _try_build_barracks(tc: BaseBuilding) -> void:
	if _barracks_data == null:
		return
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	var cost: Dictionary = _barracks_data.get_cost_dict()
	if not rm.can_afford(cost, team_id):
		return
	var cm := get_node_or_null("/root/ConstructionManager")
	if cm == null or not cm.has_method("place_building_for_team"):
		return
	var pos: Vector3 = tc.global_position + barracks_offset
	pos.y = 0.0
	print("[AI_ECO] building Barracks at ", pos)
	var built = cm.place_building_for_team(_barracks_data, pos, team_id)
	if built != null:
		print("[AI_ECO] Barracks completed ", built.name)


func _assign_idle_workers(workers: Array, tcs: Array) -> void:
	var underserved: BaseBuilding = _underserved_tc(workers, tcs)
	for w in workers:
		if not (w is BaseUnit):
			continue
		var u := w as BaseUnit
		if u.unit_state == BaseUnit.UnitState.DEAD:
			continue
		if u.unit_state == BaseUnit.UnitState.HARVESTING \
			or u.unit_state == BaseUnit.UnitState.RETURNING \
			or u.unit_state == BaseUnit.UnitState.MOVING:
			continue
		if u.current_order != null and u.current_order.type != Order.Type.NONE:
			continue
		var res := _pick_resource_for_worker(u, underserved)
		if res == null:
			continue
		u.replace_order_harvest(res)


## TC with fewest workers for whom it is the nearest alive TC (soft load, not assignment).
func _underserved_tc(workers: Array, tcs: Array) -> BaseBuilding:
	if tcs.size() < 2:
		return null
	var counts: Dictionary = {}
	for tc in tcs:
		counts[tc] = 0
	for w in workers:
		if not (w is BaseUnit):
			continue
		var u := w as BaseUnit
		if u.unit_state == BaseUnit.UnitState.DEAD:
			continue
		var nearest: BaseBuilding = null
		var best_d := INF
		for tc in tcs:
			if tc == null or not is_instance_valid(tc):
				continue
			var d: float = u.global_position.distance_squared_to((tc as Node3D).global_position)
			if d < best_d:
				best_d = d
				nearest = tc as BaseBuilding
		if nearest != null and counts.has(nearest):
			counts[nearest] = int(counts[nearest]) + 1
	var under: BaseBuilding = null
	var under_n := 999999
	for tc in tcs:
		var n: int = int(counts.get(tc, 0))
		if n < under_n:
			under_n = n
			under = tc as BaseBuilding
	return under


func _pick_resource_for_worker(u: BaseUnit, underserved: BaseBuilding) -> BaseResource:
	var rm := get_node_or_null("/root/ResourceManager")
	var wood := 0
	var stone := 0
	if rm:
		wood = rm.get_stock(team_id, BaseResource.Type.WOOD)
		stone = rm.get_stock(team_id, BaseResource.Type.STONE)

	var floor: int = maxi(stock_floor, 1)
	var prefer_type: int
	# M17.1-D — production wood pressure first (avoid stone hoard / zero wood).
	if wood < production_wood_floor:
		prefer_type = BaseResource.Type.WOOD
	elif stone < floor:
		prefer_type = BaseResource.Type.STONE
	elif wood < floor:
		prefer_type = BaseResource.Type.WOOD
	else:
		prefer_type = BaseResource.Type.WOOD if (_harvest_flip % 2 == 0) else BaseResource.Type.STONE
		_harvest_flip += 1

	var bias: float = clampf(underserved_tc_bias, 0.0, 0.5)
	var best: BaseResource = null
	var best_score := INF
	for n in u.get_tree().get_nodes_in_group("Resource"):
		if not (n is BaseResource):
			continue
		var r := n as BaseResource
		if r.resource_amount <= 0:
			continue
		if int(r.resource_type) != prefer_type:
			continue
		var d_w: float = u.global_position.distance_squared_to(r.global_position)
		var score: float = d_w
		# M17.1-C — soft pull toward under-served TC resource neighborhood.
		if underserved != null and bias > 0.0:
			var d_tc: float = underserved.global_position.distance_squared_to(r.global_position)
			score = d_w * (1.0 - bias) + d_tc * bias
		if score < best_score:
			best_score = score
			best = r
	if best != null:
		return best

	for n in u.get_tree().get_nodes_in_group("Resource"):
		if n is BaseResource and (n as BaseResource).resource_amount > 0:
			return n as BaseResource
	return null


func _attach_ai_to_army(soldiers: Array) -> int:
	var newly: int = 0
	for s in soldiers:
		if not (s is BaseUnit):
			continue
		var u := s as BaseUnit
		if u.unit_state == BaseUnit.UnitState.DEAD:
			continue
		var had_ai := false
		for c in u.get_children():
			if c is EnemyAIComponent:
				had_ai = true
				break
		if had_ai:
			continue
		EnemyAIComponent.attach_to(u, 24.0)
		newly += 1
	return newly


func _team_town_centers() -> Array:
	var out: Array = []
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return out
	for tc in bm.town_centers:
		if tc == null or not is_instance_valid(tc):
			continue
		if int(tc.team_id) != team_id:
			continue
		if tc.get("is_destroyed") == true:
			continue
		if tc.get("health") != null and int(tc.health) <= 0:
			continue
		out.append(tc)
	return out


func _team_town_center() -> BaseBuilding:
	var tcs: Array = _team_town_centers()
	if tcs.is_empty():
		return null
	return tcs[0] as BaseBuilding


func _team_barracks() -> BaseBuilding:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return null
	for b in bm.barracks_list:
		if b == null or not is_instance_valid(b):
			continue
		if int(b.team_id) != team_id:
			continue
		if b.get("is_destroyed") == true:
			continue
		return b as BaseBuilding
	return null


func _team_workers() -> Array:
	var out: Array = []
	for n in get_tree().get_nodes_in_group("Unit"):
		if n is Worker and int(n.team_id) == team_id:
			if n.unit_state != BaseUnit.UnitState.DEAD:
				out.append(n)
	return out


func _team_soldiers() -> Array:
	var out: Array = []
	for n in get_tree().get_nodes_in_group("Unit"):
		if not (n is BaseUnit):
			continue
		var u := n as BaseUnit
		if int(u.team_id) != team_id:
			continue
		if u.unit_state == BaseUnit.UnitState.DEAD:
			continue
		if u is Soldier or u is Cavalry or u is SiegeUnit:
			out.append(u)
	return out
