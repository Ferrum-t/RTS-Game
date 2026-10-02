extends Node3D


func _ready() -> void:
	call_deferred("_spawn_m27_camps")


func _spawn_m27_camps() -> void:
	# 2 NeutralCamps away from R0/R1 home zones
	var positions: Array[Vector3] = [
		Vector3(55.0, 0.0, -55.0),
		Vector3(-55.0, 0.0, 55.0),
	]
	var camp_script: Script = load("res://Scripts/WorldObjects/NeutralCamp.gd") as Script
	if camp_script == null:
		push_error("M27: NeutralCamp.gd missing")
		return
	for i in positions.size():
		var camp := Node3D.new()
		camp.set_script(camp_script)
		camp.name = "NeutralCamp_%d" % (i + 1)
		add_child(camp)
		camp.global_position = positions[i]
		print("[M27] NeutralCamp_", i + 1, " at ", positions[i])


func _process(_delta) -> void:
	pass


func _unhandled_input(event) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			var cm := get_node_or_null("/root/ConstructionManager")
			if cm != null and cm.has_method("is_placing") and cm.is_placing():
				cm.cancel_build_mode()
				get_viewport().set_input_as_handled()
				return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ConstructionManager.confirm_build()
