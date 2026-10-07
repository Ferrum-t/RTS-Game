extends CanvasLayer

## M33 — Warcraft-like selection info (unit stats + hero level progress).
## Spawns itself under the current scene if missing.

const PLAYER_TEAM := 0

var _root: PanelContainer
var _name_lbl: Label
var _hp_bar: ProgressBar
var _hp_lbl: Label
var _mana_bar: ProgressBar
var _mana_lbl: Label
var _level_bar: ProgressBar
var _level_lbl: Label
var _stats_lbl: Label


func _ready() -> void:
	layer = 20
	_build_ui()
	visible = true


func _build_ui() -> void:
	_root = PanelContainer.new()
	_root.name = "SelectionInfoRoot"
	_root.anchor_left = 0.0
	_root.anchor_top = 1.0
	_root.anchor_right = 0.0
	_root.anchor_bottom = 1.0
	_root.offset_left = 12.0
	_root.offset_top = -210.0
	_root.offset_right = 240.0
	_root.offset_bottom = -12.0
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	_root.add_child(margin)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	margin.add_child(v)

	_name_lbl = Label.new()
	_name_lbl.text = "—"
	_name_lbl.add_theme_font_size_override("font_size", 15)
	v.add_child(_name_lbl)

	_hp_lbl = Label.new()
	_hp_lbl.text = "HP"
	_hp_lbl.add_theme_font_size_override("font_size", 11)
	v.add_child(_hp_lbl)
	_hp_bar = ProgressBar.new()
	_hp_bar.custom_minimum_size = Vector2(200, 12)
	_hp_bar.max_value = 1.0
	_hp_bar.show_percentage = false
	_hp_bar.modulate = Color(0.3, 0.85, 0.35)
	v.add_child(_hp_bar)

	_mana_lbl = Label.new()
	_mana_lbl.text = "Mana"
	_mana_lbl.add_theme_font_size_override("font_size", 11)
	v.add_child(_mana_lbl)
	_mana_bar = ProgressBar.new()
	_mana_bar.custom_minimum_size = Vector2(200, 10)
	_mana_bar.max_value = 1.0
	_mana_bar.show_percentage = false
	_mana_bar.modulate = Color(0.35, 0.55, 1.0)
	v.add_child(_mana_bar)

	_level_lbl = Label.new()
	_level_lbl.text = "Level"
	_level_lbl.add_theme_font_size_override("font_size", 11)
	v.add_child(_level_lbl)
	_level_bar = ProgressBar.new()
	_level_bar.custom_minimum_size = Vector2(200, 10)
	_level_bar.max_value = 1.0
	_level_bar.show_percentage = false
	_level_bar.modulate = Color(0.95, 0.8, 0.2)
	v.add_child(_level_bar)

	_stats_lbl = Label.new()
	_stats_lbl.text = ""
	_stats_lbl.add_theme_font_size_override("font_size", 12)
	_stats_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_stats_lbl)

	_root.visible = false


func _process(_delta: float) -> void:
	var unit := _resolve_unit()
	if unit == null:
		_root.visible = false
		return
	_root.visible = true
	_fill_unit(unit)


func _resolve_unit() -> BaseUnit:
	var sm := get_node_or_null("/root/SelectionManager")
	if sm == null:
		var nodes := get_tree().get_nodes_in_group("selection_manager")
		if nodes.size() > 0:
			sm = nodes[0]
	if sm == null or not sm.has_method("get_valid_selection"):
		return null
	var units: Array = sm.get_valid_selection()
	# Prefer hero if in selection
	for u in units:
		if u is Temirbat and is_instance_valid(u) and int(u.team_id) == PLAYER_TEAM:
			if u.unit_state != BaseUnit.UnitState.DEAD:
				return u as BaseUnit
	for u in units:
		if u is BaseUnit and is_instance_valid(u) and int(u.team_id) == PLAYER_TEAM:
			if u.unit_state != BaseUnit.UnitState.DEAD:
				return u as BaseUnit
	return null


func _fill_unit(u: BaseUnit) -> void:
	var is_hero: bool = u is Temirbat
	var title: String = str(u.name)
	if is_hero:
		title = "Temirbat  ·  Level %d" % HeroProgress.hero_level
	elif u is Worker:
		title = "Worker"
	_name_lbl.text = title

	var hp: float = float(u.health)
	var mhp: float = maxf(1.0, float(u.max_health))
	_hp_bar.value = clampf(hp / mhp, 0.0, 1.0)
	_hp_lbl.text = "HP  %d / %d" % [int(hp), int(mhp)]

	if is_hero:
		var hero: Temirbat = u as Temirbat
		var mana: float = float(hero.mana)
		var mmana: float = float(Temirbat.MANA_MAX)
		_mana_bar.visible = true
		_mana_lbl.visible = true
		_level_bar.visible = true
		_level_lbl.visible = true
		_mana_bar.value = clampf(mana / maxf(1.0, mmana), 0.0, 1.0)
		_mana_lbl.text = "Mana  %d / %d" % [int(mana), int(mmana)]
		# Level progress: artifacts toward soft cap 6 (each artifact = +1 level)
		var arts: int = HeroProgress.artifact_count
		var next_need: int = 1  # next artifact levels up
		# Show bar as arts/6 power growth; level text shows current
		_level_bar.value = clampf(float(arts) / float(HeroProgress.SLOT_COUNT), 0.0, 1.0)
		_level_lbl.text = "Level %d  ·  artifacts %d/%d  (next art = level up)" % [
			HeroProgress.hero_level, arts, HeroProgress.SLOT_COUNT
		]
		_stats_lbl.text = "Damage  %d\nArmor  —\n+HP %d   +Dmg %d" % [
			int(hero.attack_damage),
			HeroProgress.bonus_hp,
			HeroProgress.bonus_dmg,
		]
	else:
		_mana_bar.visible = false
		_mana_lbl.visible = false
		_level_bar.visible = false
		_level_lbl.visible = false
		var dmg: int = int(u.attack_damage) if "attack_damage" in u else 0
		_stats_lbl.text = "Damage  %d\nArmor  —" % dmg
