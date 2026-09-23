extends PanelContainer

## Climate Visual v0.1 — V1/V2 home-region HUD.
## Displays the player's home region R0 state and existing harvest multiplier.
## Feedback is visual only; no climate or gameplay rules are changed here.

const STATE_COLD := 0
const STATE_FAVORABLE := 1
const STATE_DRY := 2

const COLOR_COLD := Color(0.25, 0.55, 1.0, 0.95)
const COLOR_FAVORABLE := Color(0.15, 0.8, 0.25, 0.95)
const COLOR_DRY := Color(0.95, 0.38, 0.12, 0.95)
const COLOR_TEXT := Color(1.0, 1.0, 1.0, 1.0)
const COLOR_TEXT_MUTED := Color(0.82, 0.88, 0.92, 1.0)

const FLASH_DURATION := 0.45
const UPDATE_INTERVAL := 0.1

var _service: Node = null
var _region: RefCounted = null
var _state: int = -1
var _multiplier: float = 1.0
var _elapsed: float = 0.0
var _flash_tween: Tween = null

var _title_label: Label
var _state_label: Label
var _mult_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(230.0, 66.0)

	_build_contents()
	_resolve_climate_service()
	_refresh(true)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < UPDATE_INTERVAL:
		return
	_elapsed = 0.0
	_refresh(false)


func _build_contents() -> void:
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 7)
	add_child(margin)

	var rows := VBoxContainer.new()
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_theme_constant_override("separation", 1)
	margin.add_child(rows)

	_title_label = Label.new()
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_label.text = "HOME REGION · R0"
	_title_label.add_theme_font_size_override("font_size", 12)
	_title_label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	rows.add_child(_title_label)

	var state_row := HBoxContainer.new()
	state_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	state_row.add_theme_constant_override("separation", 12)
	rows.add_child(state_row)

	_state_label = Label.new()
	_state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_state_label.add_theme_font_size_override("font_size", 18)
	_state_label.add_theme_color_override("font_color", COLOR_TEXT)
	state_row.add_child(_state_label)

	_mult_label = Label.new()
	_mult_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mult_label.add_theme_font_size_override("font_size", 18)
	_mult_label.add_theme_color_override("font_color", COLOR_TEXT)
	state_row.add_child(_mult_label)

	_set_panel_style(COLOR_FAVORABLE, false)


func _resolve_climate_service() -> void:
	_service = get_node_or_null("/root/EnvironmentZoneService")
	if _service == null:
		return

	for region in _service.regions:
		if region.id == "R0":
			_region = region
			return


func _refresh(initial: bool) -> void:
	if _service == null or not is_instance_valid(_service):
		_resolve_climate_service()
		if _service == null:
			return

	if _region == null:
		for region in _service.regions:
			if region.id == "R0":
				_region = region
				break
		if _region == null:
			return

	var new_state: int = int(_service.get_region_state(_region))
	var new_multiplier: float = float(_service.get_multiplier_at(_region.center))
	var changed := new_state != _state

	_state = new_state
	_multiplier = new_multiplier
	_update_text()
	_set_panel_style(_state_color(_state), changed and not initial)

	if changed and not initial:
		_play_state_change_feedback()


func _update_text() -> void:
	_state_label.text = _state_name(_state)
	_mult_label.text = "×%.1f" % _multiplier


func _state_name(state: int) -> String:
	match state:
		STATE_COLD:
			return "COLD"
		STATE_FAVORABLE:
			return "FAVORABLE"
		STATE_DRY:
			return "DRY"
		_:
			return "UNKNOWN"


func _state_color(state: int) -> Color:
	match state:
		STATE_COLD:
			return COLOR_COLD
		STATE_FAVORABLE:
			return COLOR_FAVORABLE
		STATE_DRY:
			return COLOR_DRY
		_:
			return COLOR_FAVORABLE


func _set_panel_style(state_color: Color, emphasized: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(state_color.r * 0.16, state_color.g * 0.16, state_color.b * 0.16, 0.92)
	style.border_color = state_color
	style.set_border_width_all(2 if emphasized else 1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 6
	add_theme_stylebox_override("panel", style)


func _play_state_change_feedback() -> void:
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()

	var base_scale := scale
	scale = base_scale * 1.04
	modulate = Color(1.0, 1.0, 1.0, 1.0)

	_flash_tween = create_tween()
	_flash_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_property(self, "scale", base_scale, FLASH_DURATION)
