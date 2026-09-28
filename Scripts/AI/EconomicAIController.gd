extends Node

class_name EconomicAIController

## Stage 1 threshold AI + M17.0–M17.3 multi-base eco/military + local tower.
## DECISION only. EXECUTION via shared systems.
##
## M17.3 Level 1 (locked):
##   1× Watchtower once near TC2 after _second_barracks_once
##   watchtower_offset = (-4, 0, 4), _watchtower_once (no rebuild)
##   BuildingCombatComponent / EnemyAI unchanged
## OUT: defense brain, multi-tower, rebuild, Climate, army split
##
## M18.1 Balance P1: attack_threshold 3 → 5 (later first wave)
## M21.4 — AI Yurt when Food < threshold (max 2), after 1st Barracks, before expand

@export var team_id: int = 1
@export var desired_worker_count: int = 4
## Extra workers when alive TC count >= 2 (M17.1-B). Total goal = desired + extra.
@export var extra_workers_at_two_tc: int = 2
@export var attack_threshold: int = 5  ## M18.1 P1: was 3
@export var decision_interval: float = 1.5
@export var barracks_offset: Vector3 = Vector3(4.0, 0.0, 3.0)
## M17.2 — offset from the TC chosen for 2nd Barracks (prefer farthest from Barracks1).
@export var second_barracks_offset: Vector3 = Vector3(4.0, 0.0, -3.0)
@export var max_ai_barracks: int = 2
## M17.3 — offset from TC2 (farthest TC) for the single AI Watchtower.
@export var watchtower_offset: Vector3 = Vector3(-4.0, 0.0, 4.0)
@export var max_ai_watchtowers: int = 1
## M21.4 — AI Yurt food supply.
@export var yurt_offset: Vector3 = Vector3(5.0, 0.0, -4.0)
@export var yurt_offset_2: Vector3 = Vector3(-5.0, 0.0, -4.0)
@export var max_ai_yurts: int = 2
@export var food_yurt_threshold: int = 6
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
var _watchtower_data: BuildingData = null
var _yurt_data: BuildingData = null
## True after we first crossed attack_threshold; reset when army falls below.
var _attack_issued: bool = false
## Alternates preferred type when both stocks are above floor.
var _harvest_flip: int = 0
## M17.1-A — one expansion success per match (no rebuild after TC2 loss).
var _expanded_once: bool = false
## M17.2 — one successful 2nd Barracks per match (no rebuild).
var _second_barracks_once: bool = false
## M17.3 — one successful Watchtower per match (no rebuild).
var _watchtower_once: bool = false


func _ready() -> void:
	_barracks_data = load("res://Data/Buildings/BarracksData.tres") as BuildingData
	_tc_data = load("res://Data/Buildings/TownCenterData.tres") as BuildingData
	_watchtower_data = load("res://Data/Buildings/WatchtowerData.tres") as BuildingData
	_yurt_data = load("res://Data/Buildings/YurtData.tres") as BuildingData
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
		" max_barracks=", max_ai_barracks,
		" max_towers=", max_ai_watchtowers,
		" max_yurts=", max_ai_yurts,
		" food_yurt_threshold=", food_yurt_threshold,
		" expand_once=true second_barracks_once=true watchtower_once=true"
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
	var food := 0
	if rm:
		wood = rm.get_stock(team_id, BaseResource.Type.WOOD)
		stone = rm.get_stock(team_id, BaseResource.Type.STONE)
		food = rm.get_stock(team_id, BaseResource.Type.FOOD)
	var tcs: Array = _team_town_centers()
	var barracks_list: Array = _team_barracks_list()
	var goal: int = _worker_goal(tcs.size())
	print(
		"[AI_ECO] workers=", workers.size(), "/", goal,
		" soldiers=", soldiers.size(),
		" tc=", tcs.size(),
		" barracks=", barracks_list.size(),
		" wood=", wood, " stone=", stone, " food=", food,
		" yurts=", _team_yurt_count(),
		" expanded=", _expanded_once,
		" b2=", _second_barracks_once,
		" w1=", _watchtower_once
	)

	_assign_idle_workers(workers, tcs)

	if tcs.is_empty():
		return

	if workers.size() < goal:
		_try_train_worker_any_tc(tcs)

	var first_tc: BaseBuilding = tcs[0] as BaseBuilding
	if barracks_list.is_empty():
		_try_build_barracks(first_tc)
		return

	# M21.4 — Yurt when Food low (after 1st Barracks, before expand / 2nd barracks / tower).
	if food < food_yurt_threshold and _team_yurt_count() < max_ai_yurts:
		_try_build_yurt(first_tc)

	# M17.0/17.1 — at most one TC expand per match.
	if not _expanded_once and tcs.size() < max_ai_tc:
		_try_expand_second_tc(first_tc, wood, stone)
		tcs = _team_town_centers()

	# M17.2 — 2nd Barracks once near farthest TC from existing barracks (TC2).
	if not _second_barracks_once \
		and tcs.size() >= 2 \
		and barracks_list.size() < max_ai_barracks:
		var anchor: BaseBuilding = _pick_tc_for_second_barracks(tcs, barracks_list)
		_try_build_second_barracks(anchor)
		barracks_list = _team_barracks_list()

	# M17.3 — 1× Watchtower once near TC2 after 2nd Barracks success.
	if not _watchtower_once \
		and _second_barracks_once \
		and tcs.size() >= 2 \
		and _team_watchtower_count() < max_ai_watchtowers:
		var tower_anchor: BaseBuilding = _pick_tc_for_second_barracks(tcs, barracks_list)
		_try_build_watchtower(tower_anchor)

	# M17.2 — train from any free Barracks.
	_try_train_soldier_any_barracks(barracks_list)

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
		if tcn.has_method("try_train_worker"):
			if tcn.try_train_worker():
				print("[AI_ECO] training Worker at ", tcn.name)
				return


func _try_train_soldier_any_barracks(barracks_list: Array) -> void:
	for node in barracks_list:
		if not (node is Barracks):
			continue
		var b := node as Barracks
		if b.has_method("get_train_pipeline_count") and int(b.get_train_pipeline_count()) >= 5:
			continue
		if b.has_method("try_train_soldier"):
			if b.try_train_soldier():
				print("[AI_ECO] training Soldier at ", b.name)
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


## M17.2 — second Barracks once; anchor = TC farthest from existing barracks (TC2 side).
func _try_build_second_barracks(anchor_tc: BaseBuilding) -> void:
	if _second_barracks_once:
		return
	if anchor_tc == null or not is_instance_valid(anchor_tc):
		return
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
	var pos: Vector3 = anchor_tc.global_position + second_barracks_offset
	pos.y = 0.0
	print("[AI_ECO] building 2nd Barracks at ", pos, " near ", anchor_tc.name)
	var built = cm.place_building_for_team(_barracks_data, pos, team_id, true)
	if built != null:
		_second_barracks_once = true
		print(
			"[AI_ECO] 2nd Barracks completed ", built.name,
			" team=", team_id, " second_barracks_once locked"
		)


## M17.3 — one Watchtower once near TC2; combat via BuildingCombatComponent as-is.
func _try_build_watchtower(anchor_tc: BaseBuilding) -> void:
	if _watchtower_once:
		return
	if anchor_tc == null or not is_instance_valid(anchor_tc):
		return
	if _watchtower_data == null:
		return
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	var cost: Dictionary = _watchtower_data.get_cost_dict()
	if not rm.can_afford(cost, team_id):
		return
	var cm := get_node_or_null("/root/ConstructionManager")
	if cm == null or not cm.has_method("place_building_for_team"):
		return
	var pos: Vector3 = anchor_tc.global_position + watchtower_offset
	pos.y = 0.0
	print("[AI_ECO] building Watchtower at ", pos, " near ", anchor_tc.name)
	var built = cm.place_building_for_team(_watchtower_data, pos, team_id, true)
	if built != null:
		_watchtower_once = true
		print(
			"[AI_ECO] Watchtower completed ", built.name,
			" team=", team_id, " watchtower_once locked"
		)


## Prefer the alive TC farthest from current barracks centroid (= TC2 after expand).
func _pick_tc_for_second_barracks(tcs: Array, barracks_list: Array) -> BaseBuilding:
	if tcs.is_empty():
		return null
	if barracks_list.is_empty():
		return tcs[0] as BaseBuilding
	var cx := 0.0
	var cz := 0.0
	var n: int = 0
	for b in barracks_list:
		if b == null or not is_instance_valid(b):
			continue
		cx += b.global_position.x
		cz += b.global_position.z
		n += 1
	if n <= 0:
		return tcs[0] as BaseBuilding
	cx /= float(n)
	cz /= float(n)
	var best: BaseBuilding = null
	var best_d2 := -1.0
	for tc in tcs:
		if tc == null or not is_instance_valid(tc):
			continue
		var dx: float = tc.global_position.x - cx
		var dz: float = tc.global_position.z - cz
		var d2: float = dx * dx + dz * dz
		if d2 > best_d2:
			best_d2 = d2
			best = tc as BaseBuilding
	return best if best != null else tcs[0] as BaseBuilding


func _assign_idle_workers(workers: Array, tcs: Array) -> void:
	if workers.is_empty() or tcs.is_empty():
		return
	for w in workers:
		if w == null or not is_instance_valid(w):
			continue
		if not (w is Worker):
			continue
		var u := w as Worker
		if u.unit_state == BaseUnit.UnitState.DEAD:
			continue
		if u.unit_state != BaseUnit.UnitState.IDLE:
			continue
		var res = _pick_resource_for_worker(u, tcs)
		if res == null:
			continue
		if u.has_method("replace_order_harvest"):
			u.replace_order_harvest(res)


func _underserved_tc(workers: Array, tcs: Array) -> BaseBuilding:
	if tcs.is_empty():
		return null
	var counts: Dictionary = {}
	for tc in tcs:
		if tc != null and is_instance_valid(tc):
			counts[tc] = 0
	for w in workers:
		if w == null or not is_instance_valid(w):
			continue
		var nearest = null
		var best := INF
		for tc in tcs:
			if tc == null or not is_instance_valid(tc):
				continue
			var d: float = w.global_position.distance_squared_to(tc.global_position)
			if d < best:
				best = d
				nearest = tc
		if nearest != null and counts.has(nearest):
			counts[nearest] = int(counts[nearest]) + 1
	var pick: BaseBuilding = null
	var pick_n := 999999
	for tc in counts.keys():
		var c: int = int(counts[tc])
		if c < pick_n:
			pick_n = c
			pick = tc as BaseBuilding
	return pick


func _pick_resource_for_worker(worker: Worker, tcs: Array):
	var rm := get_node_or_null("/root/ResourceManager")
	var wood := 0
	var stone := 0
	if rm:
		wood = rm.get_stock(team_id, BaseResource.Type.WOOD)
		stone = rm.get_stock(team_id, BaseResource.Type.STONE)
	var floor: int = stock_floor
	var prefer: int = BaseResource.Type.WOOD
	if wood < production_wood_floor:
		prefer = BaseResource.Type.WOOD
	elif stone < floor:
		prefer = BaseResource.Type.STONE
	elif wood < floor:
		prefer = BaseResource.Type.WOOD
	else:
		_harvest_flip = 1 - _harvest_flip
		prefer = BaseResource.Type.WOOD if _harvest_flip == 0 else BaseResource.Type.STONE
	var best = null
	var best_score := INF
	var underserved: BaseBuilding = _underserved_tc(_team_workers(), tcs)
	for n in get_tree().get_nodes_in_group("Resource"):
		if n == null or not is_instance_valid(n):
			continue
		if not n.has_method("get_resource_type"):
			continue
		var rt = n.get_resource_type() if n.has_method("get_resource_type") else n.get("resource_type")
		if int(rt) != prefer:
			continue
		if n.has_method("is_depleted") and n.is_depleted():
			continue
		var amount = n.get("amount") if n.get("amount") != null else 1
		if int(amount) <= 0:
			continue
		var d_w: float = worker.global_position.distance_to(n.global_position)
		var d_tc: float = 0.0
		if underserved != null:
			d_tc = underserved.global_position.distance_to(n.global_position)
		var score: float = d_w * (1.0 - underserved_tc_bias) + d_tc * underserved_tc_bias
		if score < best_score:
			best_score = score
			best = n
	return best


func _attach_ai_to_army(soldiers: Array) -> int:
	var n: int = 0
	for u in soldiers:
		if u == null or not is_instance_valid(u):
			continue
		if u.get_node_or_null("EnemyAIComponent") != null:
			continue
		var ai := EnemyAIComponent.new()
		u.add_child(ai)
		n += 1
	return n


## M21.4 — AI Yurt near first TC; constructed=true (instant READY + income).
func _try_build_yurt(anchor_tc: BaseBuilding) -> void:
	if anchor_tc == null or not is_instance_valid(anchor_tc):
		return
	if _yurt_data == null:
		return
	var count: int = _team_yurt_count()
	if count >= max_ai_yurts:
		return
	var rm := get_node_or_null("/root/ResourceManager")
	if rm == null:
		return
	var cost: Dictionary = _yurt_data.get_cost_dict()
	if not rm.can_afford(cost, team_id):
		return
	var cm := get_node_or_null("/root/ConstructionManager")
	if cm == null or not cm.has_method("place_building_for_team"):
		return
	var off: Vector3 = yurt_offset if count == 0 else yurt_offset_2
	var pos: Vector3 = anchor_tc.global_position + off
	pos.y = 0.0
	print("[AI_ECO] building Yurt at ", pos, " near ", anchor_tc.name, " (food low, yurts=", count, "/", max_ai_yurts, ")")
	var built = cm.place_building_for_team(_yurt_data, pos, team_id, true)
	if built != null:
		print("[AI_ECO] Yurt completed ", built.name, " team=", team_id)


func _team_yurt_count() -> int:
	var n: int = 0
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return 0
	for b in bm.buildings:
		if b == null or not is_instance_valid(b):
			continue
		if not (b is Yurt):
			continue
		if int(b.team_id) != team_id:
			continue
		if b.get("is_destroyed") == true:
			continue
		if b.get("health") != null and int(b.health) <= 0:
			continue
		n += 1
	return n


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


func _team_barracks_list() -> Array:
	var out: Array = []
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return out
	for b in bm.barracks_list:
		if b == null or not is_instance_valid(b):
			continue
		if int(b.team_id) != team_id:
			continue
		if b.get("is_destroyed") == true:
			continue
		if b.get("health") != null and int(b.health) <= 0:
			continue
		out.append(b)
	return out


func _team_barracks() -> BaseBuilding:
	var list: Array = _team_barracks_list()
	if list.is_empty():
		return null
	return list[0] as BaseBuilding


func _team_watchtower_count() -> int:
	var n: int = 0
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return 0
	for w in bm.watchtowers_list:
		if w == null or not is_instance_valid(w):
			continue
		if int(w.team_id) != team_id:
			continue
		if w.get("is_destroyed") == true:
			continue
		if w.get("health") != null and int(w.health) <= 0:
			continue
		n += 1
	return n


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
