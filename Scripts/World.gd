extends Node3D


func _ready() -> void:
	call_deferred("_spawn_m30_camps")


func _spawn_m30_camps() -> void:
	# VERY close to player TC (28,-22) so easy to find
	# MELEE orange ~ SE of base, ARCHER still near enemy side but closer
	var setups: Array = [
		{"pos": Vector3(40.0, 0.0, -38.0), "kind": 0},
		{"pos": Vector3(-40.0, 0.0, 38.0), "kind": 1},
	]
	var camp_script: Script = load("res://Scripts/WorldObjects/NeutralCamp.gd") as Script
	if camp_script == null:
		push_error("M30: NeutralCamp.gd missing")
		return
	for i in setups.size():
		var cfg: Dictionary = setups[i]
		var camp := Node3D.new()
		camp.set_script(camp_script)
		camp.name = "NeutralCamp_%d" % (i + 1)
		add_child(camp)
		camp.global_position = cfg["pos"]
		if camp.has_method("setup_kind"):
			camp.setup_kind(int(cfg["kind"]))
		print("[M30] World spawned NeutralCamp_", i + 1, " kind=", cfg["kind"], " at ", cfg["pos"])


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
		# Debug: L = spawn loot chest at Temirbat feet
		if event.keycode == KEY_L and OS.is_debug_build():
			_debug_spawn_chest_at_hero()
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ConstructionManager.confirm_build()


func _debug_spawn_chest_at_hero() -> void:
	var pos := Vector3(30.0, 0.0, -25.0)
	for n in get_tree().get_nodes_in_group("Hero"):
		if is_instance_valid(n) and n is Node3D:
			pos = (n as Node3D).global_position + Vector3(2.0, 0.0, 2.0)
			break
	var chest := StaticBody3D.new()
	var script: Script = load("res://Scripts/WorldObjects/ArtifactChest.gd") as Script
	if script == null:
		print("[M31] debug: ArtifactChest.gd missing")
		return
	chest.set_script(script)
	chest.name = "ArtifactChest_DEBUG"
	add_child(chest)
	chest.global_position = pos
	if "source_label" in chest:
		chest.source_label = "DEBUG"
	print("[M31] DEBUG chest at ", pos, " — press L near hero")
