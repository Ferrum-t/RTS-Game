extends Node

class_name EconomicAIController

## Stage 1 — threshold economic AI for one team (default team 1).
## DECISION only. EXECUTION via shared systems.

@export var team_id: int = 1
@export var desired_worker_count: int = 4
@export var attack_threshold: int = 3
@export var decision_interval: float = 1.5
@export var barracks_offset: Vector3 = Vector3(4.0, 0.0, 3.0)

var _timer: float = 0.0
var _barracks_data: BuildingData = null
## True after we first crossed attack_threshold; reset when army falls below.
var _attack_issued: bool = false


func _ready() -> void:
	_barracks_data = load("res://Data/Buildings/BarracksData.tres") as BuildingData
	_timer = 0.5
	print("[AI_ECO] controller ready team=", team_id,
		" workers_goal=", desired_worker_count,
		" attack_at=", attack_threshold)


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
	print("[AI_ECO] workers=", workers.size(), " soldiers=", soldiers.size(),
		" wood=", wood, " stone=", stone)

	_assign_idle_workers(workers)

	var tc := _team_town_center()
	if tc == null:
		return

	if workers.size() < desired_worker_count and tc is TownCenter:
		var tcn := tc as TownCenter
		if not tcn.is_training and tcn.is_deployed():
			if tcn.try_train_worker():
				print("[AI_ECO] training Worker")

	var barracks := _team_barracks()
	if barracks == null:
		_try_build_barracks(tc)
		return

	if barracks is Barracks:
		var b := barracks as Barracks
		if not b.is_training:
			if b.try_train_soldier():
				print("[AI_ECO] training Soldier")

	soldiers = _team_soldiers()
	if soldiers.size() >= attack_threshold:
		if not _attack_issued:
			# First time army crosses threshold — one decision, one log line.
			print("[AI_ECO] attack threshold reached army=", soldiers.size())
			_attack_issued = true
			var n: int = _attach_ai_to_army(soldiers)
			print("[AI_ECO] attack issued on ", n, " soldiers")
		else:
			# Late-trained soldiers after the wave started: attach only if missing AI.
			var n: int = _attach_ai_to_army(soldiers)
			if n > 0:
				print("[AI_ECO] attack reinforcements +", n)
	else:
		# Army collapsed below threshold — allow a future re-issue.
		_attack_issued = false


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
	var need_stone := false
	var rm := get_node_or_null("/root/ResourceManager")
	if rm and rm.get_stock(team_id, BaseResource.Type.STONE) < 50:
		need_stone = true
	var best: BaseResource = null
	var best_d := INF
	for n in u.get_tree().get_nodes_in_group("Resource"):
		if not (n is BaseResource):
			continue
		var r := n as BaseResource
		if r.resource_amount <= 0:
			continue
		var is_stone := int(r.resource_type) == BaseResource.Type.STONE
		if need_stone and not is_stone:
			continue
		if not need_stone and is_stone:
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


## Attach EnemyAIComponent only to soldiers that lack it. Returns how many were newly attached.
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


func _team_town_center() -> BaseBuilding:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm == null:
		return null
	for tc in bm.town_centers:
		if tc == null or not is_instance_valid(tc):
			continue
		if int(tc.team_id) != team_id:
			continue
		if tc.get("is_destroyed") == true:
			continue
		return tc as BaseBuilding
	return null


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
