extends Node

class_name EconomicAIController

## Stage 1 threshold AI + M17.0 minimal expansion (max 2 TC).
## DECISION only. EXECUTION via shared systems.

@export var team_id: int = 1
@export var desired_worker_count: int = 4
@export var attack_threshold: int = 3
@export var decision_interval: float = 1.5
@export var barracks_offset: Vector3 = Vector3(4.0, 0.0, 3.0)
## Soft floor for both wood and stone; below → prefer that resource.
@export var stock_floor: int = 100

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


func _ready() -> void:
	_barracks_data = load("res://Data/Buildings/BarracksData.tres") as BuildingData
	_tc_data = load("res://Data/Buildings/TownCenterData.tres") as BuildingData
	_timer = 0.5
	print(
		"[AI_ECO] controller ready team=", team_id,
		" workers_goal=", desired_worker_count,
		" attack_at=", attack_threshold,
		" stock_floor=", stock_floor,
		" expand_at W>=", expand_wood_min, " S>=", expand_stone_min,
		" max_tc=", max_ai_tc
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
	print(
		"[AI_ECO] workers=", workers.size(), " soldiers=", soldiers.size(),
		" tc=", tcs.size(), " wood=", wood, " stone=", stone
	)

	_assign_idle_workers(workers)

	if tcs.is_empty():
		return

	# M17.0 — train workers from ANY free alive TC (total goal still desired_worker_count).
	if workers.size() < desired_worker_count:
		_try_train_worker_any_tc(tcs)

	var first_tc: BaseBuilding = tcs[0] as BaseBuilding
	var barracks := _team_barracks()
	if barracks == null:
		_try_build_barracks(first_tc)
		return

	# M17.0 — one expansion to max_ai_tc after Barracks exists.
	if tcs.size() < max_ai_tc:
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
	# Instant READY — same Stage-1 path as Barracks (start_constructed default true).
	var built = cm.place_building_for_team(_tc_data, pos, team_id, true)
	if built != null:
		print("[AI_ECO] 2nd TC completed ", built.name, " team=", team_id)


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


func _assign_idle_workers(workers: Array) -> void:
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
		var res := _pick_resource_for_worker(u)
		if res == null:
			continue
		u.replace_order_harvest(res)


func _pick_resource_for_worker(u: BaseUnit) -> BaseResource:
	var rm := get_node_or_null("/root/ResourceManager")
	var wood := 0
	var stone := 0
	if rm:
		wood = rm.get_stock(team_id, BaseResource.Type.WOOD)
		stone = rm.get_stock(team_id, BaseResource.Type.STONE)

	var floor: int = maxi(stock_floor, 1)
	var prefer_type: int
	if stone < floor:
		prefer_type = BaseResource.Type.STONE
	elif wood < floor:
		prefer_type = BaseResource.Type.WOOD
	else:
		prefer_type = BaseResource.Type.WOOD if (_harvest_flip % 2 == 0) else BaseResource.Type.STONE
		_harvest_flip += 1

	var best: BaseResource = null
	var best_d := INF
	for n in u.get_tree().get_nodes_in_group("Resource"):
		if not (n is BaseResource):
			continue
		var r := n as BaseResource
		if r.resource_amount <= 0:
			continue
		if int(r.resource_type) != prefer_type:
			continue
		var d := u.global_position.distance_squared_to(r.global_position)
		if d < best_d:
			best_d = d
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


## All alive TCs for this team (M17.0 multi-TC).
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


## First alive TC (Barracks placement anchor).
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
