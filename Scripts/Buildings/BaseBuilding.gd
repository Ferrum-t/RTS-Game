extends CharacterBody3D

class_name BaseBuilding

## Static gameplay buildings (Barracks) and base for MobileBuilding (TownCenter).
## CharacterBody3D so TownCenter can move without losing BaseBuilding type for siege/CommandManager.
## Non-mobile buildings never call move_and_slide with nonzero velocity.

enum VisualState {
	INTACT,
	DAMAGED,
	BURNING,
	DESTROYED,
}

@export var team_id: int = 0
@export var max_health: int = 500
## Half-extents of footprint used for NavMesh obstruction (XZ)
@export var nav_half_extents: Vector3 = Vector3(2.2, 1.0, 2.2)

@export var tier: int = 1 # 1..3
@export var tier_modifiers: Array[Dictionary] = [
	{},
	{"max_health": 1.5},
	{"max_health": 2.0},
]
## deployment_overrides[DeploymentState.State] -> Dictionary{stat_name -> multiplier}
@export var deployment_overrides: Dictionary = {}

## Phase 6: enable loot siphon on raid damage (TownCenter / Barracks).
@export var is_lootable: bool = true
@export var loot_ratio: float = 0.5
## Per-hit [RAID] lines only when true (mass siege spam otherwise).
@export var raid_debug_verbose: bool = false

var deployment_state: int = DeploymentState.State.DEPLOYED

## Value from inspector before tier/deployment resolve (set once in _ready)
var base_max_health: int = 500
var health: int = 500
var is_destroyed: bool = false
var lootable: LootableComponent = null

## Phase 6.2 — presentation only; DESTROYED mirrors is_destroyed / die().
var visual_state: int = VisualState.INTACT
## Cached albedo from scene mesh material (captured once).
var _visual_base_albedo: Color = Color(1, 1, 1, 1)
var _visual_base_captured: bool = false

## Accumulated loot this raid (for one summary line on destroy).
var _raid_loot_total: Dictionary = {}
var _raid_damage_total: int = 0


func get_current_stat(stat_name: String, base_value: float) -> float:
	var value := base_value
	if tier >= 1 and tier <= tier_modifiers.size():
		value *= float(tier_modifiers[tier - 1].get(stat_name, 1.0))
	var overrides: Dictionary = deployment_overrides.get(deployment_state, {})
	value *= float(overrides.get(stat_name, 1.0))
	return value


func recompute_stats() -> void:
	max_health = int(get_current_stat("max_health", float(base_max_health)))
	health = mini(health, max_health)
	_refresh_visual_state()


func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED

	base_max_health = max_health
	max_health = int(get_current_stat("max_health", float(base_max_health)))
	health = max_health
	is_destroyed = false
	deployment_state = DeploymentState.State.DEPLOYED
	_raid_loot_total.clear()
	_raid_damage_total = 0

	if is_lootable:
		_setup_lootable()

	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.register_building(self)

	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.register_building(self, nav_half_extents)

	_capture_visual_base_albedo()
	_refresh_visual_state()


func _setup_lootable() -> void:
	lootable = LootableComponent.new()
	lootable.name = "LootableComponent"
	lootable.loot_ratio = loot_ratio
	add_child(lootable)
	lootable.setup(self)


func _exit_tree() -> void:
	var bm := get_node_or_null("/root/BuildingManager")
	if bm:
		bm.unregister_building(self)

	var nav := get_node_or_null("/root/NavigationBakeService")
	if nav:
		nav.unregister_building(self)


## amount is already modified (building multipliers applied by attacker).
## attacker_team_id >= 0 triggers loot siphon when lootable is present.
func damage(amount: int, attacker_team_id: int = -1) -> void:
	if is_destroyed:
		return
	health -= amount
	if lootable != null and attacker_team_id >= 0 and amount > 0:
		var looted: Dictionary = lootable.extract_loot(float(amount), attacker_team_id)
		_raid_damage_total += amount
		for k in looted.keys():
			var key: int = int(k)
			_raid_loot_total[key] = int(_raid_loot_total.get(key, 0)) + int(looted[k])
		if raid_debug_verbose:
			var remaining: Dictionary = lootable.snapshot_stock()
			print(
				"[RAID] Attacker dealt ", amount,
				" damage (team ", attacker_team_id, "). Siphoned loot: ",
				LootableComponent.format_stock(looted),
				". Enemy remaining: ",
				LootableComponent.format_stock(remaining)
			)
	if health <= 0:
		health = 0
		die()
	else:
		_refresh_visual_state()


func die() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	health = 0
	_refresh_visual_state()
	if is_lootable and _raid_damage_total > 0:
		print(
			"[RAID] ", name, " destroyed — total damage siphoned from: ",
			_raid_damage_total,
			" HP-equiv. Loot total: ",
			LootableComponent.format_stock(_raid_loot_total)
		)
	print(name, " destroyed (team ", team_id, ")")
	queue_free()


## Phase 6.2 — HP event only. DESTROYED follows is_destroyed (die()), not a second destroy path.
func _refresh_visual_state() -> void:
	var next: int = VisualState.INTACT
	if is_destroyed or health <= 0:
		next = VisualState.DESTROYED
	elif max_health <= 0:
		next = VisualState.INTACT
	else:
		var ratio: float = float(health) / float(max_health)
		if ratio > 0.75:
			next = VisualState.INTACT
		elif ratio > 0.25:
			next = VisualState.DAMAGED
		else:
			next = VisualState.BURNING

	if next == visual_state:
		_apply_visual_presentation(next)
		return

	var prev: int = visual_state
	visual_state = next
	_apply_visual_presentation(next)
	if OS.is_debug_build():
		print(
			"[BUILDING_VIS] ", name,
			" ", _visual_state_name(prev), " → ", _visual_state_name(next),
			" HP ", health, "/", max_health
		)


func _visual_state_name(s: int) -> String:
	match s:
		VisualState.INTACT:
			return "INTACT"
		VisualState.DAMAGED:
			return "DAMAGED"
		VisualState.BURNING:
			return "BURNING"
		VisualState.DESTROYED:
			return "DESTROYED"
		_:
			return "?"


func _capture_visual_base_albedo() -> void:
	if _visual_base_captured:
		return
	for child in get_children():
		if not (child is MeshInstance3D):
			continue
		var mi := child as MeshInstance3D
		var mat: Material = mi.material_override
		if mat == null:
			mat = mi.get_active_material(0)
		if mat is StandardMaterial3D:
			_visual_base_albedo = (mat as StandardMaterial3D).albedo_color
			_visual_base_captured = true
			return
	_visual_base_albedo = Color(0.77, 0.66, 0.46, 1.0)
	_visual_base_captured = true


## Godot 4 MeshInstance3D has no modulate (CanvasItem only). Tint via material_override.
func _apply_visual_presentation(state: int) -> void:
	_capture_visual_base_albedo()
	var tint := Color(1.0, 1.0, 1.0, 1.0)
	match state:
		VisualState.INTACT:
			tint = Color(1.0, 1.0, 1.0, 1.0)
		VisualState.DAMAGED:
			tint = Color(1.0, 0.85, 0.35, 1.0)
		VisualState.BURNING:
			tint = Color(1.0, 0.4, 0.2, 1.0)
		VisualState.DESTROYED:
			tint = Color(0.3, 0.3, 0.3, 1.0)
	var albedo: Color = _visual_base_albedo * tint
	for child in get_children():
		if not (child is MeshInstance3D):
			continue
		var mi := child as MeshInstance3D
		var std := StandardMaterial3D.new()
		std.albedo_color = albedo
		mi.material_override = std
