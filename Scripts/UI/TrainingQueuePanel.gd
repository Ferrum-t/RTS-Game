extends PanelContainer

## M19.1 — Selection-only training queue UI for player TC / Barracks.
## Shows pipeline labels, progress of current unit, Cancel last / Cancel all.

const PLAYER_TEAM := 0

var _progress: ProgressBar
var _queue_label: Label
var _title: Label
var _btn_last: Button
var _btn_all: Button
var _building: Node = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	visible = false


func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	_title = Label.new()
	_title.text = "Training"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_title)

	_progress = ProgressBar.new()
	_progress.custom_minimum_size = Vector2(180, 14)
	_progress.max_value = 1.0
	_progress.value = 0.0
	_progress.show_percentage = false
	vbox.add_child(_progress)

	_queue_label = Label.new()
	_queue_label.text = "Queue: —"
	_queue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_queue_label.custom_minimum_size = Vector2(180, 0)
	vbox.add_child(_queue_label)

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(h)

	_btn_last = Button.new()
	_btn_last.text = "Cancel last"
	_btn_last.pressed.connect(_on_cancel_last)
	h.add_child(_btn_last)

	_btn_all = Button.new()
	_btn_all.text = "Cancel all"
	_btn_all.pressed.connect(_on_cancel_all)
	h.add_child(_btn_all)


func _process(_delta: float) -> void:
	_building = _resolve_selected_building()
	if _building == null:
		visible = false
		return

	visible = true
	var labels: Array = []
	if _building.has_method("get_queue_labels"):
		labels = _building.get_queue_labels()
	var progress: float = 0.0
	if _building.has_method("get_train_progress"):
		progress = float(_building.get_train_progress())
	var count: int = 0
	if _building.has_method("get_train_pipeline_count"):
		count = int(_building.get_train_pipeline_count())

	var kind := "Building"
	if _building is TownCenter:
		kind = "Town Center"
	elif _building is Barracks:
		kind = "Barracks"
	_title.text = "%s · train %d/%d" % [kind, count, 5]

	_progress.value = progress
	if count <= 0:
		_queue_label.text = "Queue: empty"
		_progress.value = 0.0
	else:
		var parts: PackedStringArray = PackedStringArray()
		for i in range(labels.size()):
			var mark := "▶ " if i == 0 else "· "
			parts.append(mark + str(labels[i]))
		_queue_label.text = " ".join(parts)

	var busy: bool = count > 0
	_btn_last.disabled = not busy
	_btn_all.disabled = not busy


func _resolve_selected_building() -> Node:
	var sm: Node = get_tree().get_first_node_in_group("selection_manager")
	if sm == null or not sm.has_method("get_selected_mobile_buildings"):
		return null
	for b in sm.get_selected_mobile_buildings():
		if b == null or not is_instance_valid(b):
			continue
		if int(b.get("team_id")) != PLAYER_TEAM:
			continue
		if b.get("is_destroyed") == true:
			continue
		if b is TownCenter or b is Barracks:
			return b
	return null


func _on_cancel_last() -> void:
	if _building != null and is_instance_valid(_building) and _building.has_method("cancel_train_last"):
		_building.cancel_train_last()


func _on_cancel_all() -> void:
	if _building != null and is_instance_valid(_building) and _building.has_method("cancel_train_all"):
		_building.cancel_train_all()
