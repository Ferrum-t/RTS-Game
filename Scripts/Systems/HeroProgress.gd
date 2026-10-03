extends Node

class_name HeroProgress

## M31 — survives Temirbat death/respawn (match-only, not save file).

static var hero_level: int = 1
static var artifact_count: int = 0
static var bonus_hp: int = 0
static var bonus_dmg: int = 0

const ARTIFACT_HP := 25
const ARTIFACT_DMG := 5


static func reset_match() -> void:
	hero_level = 1
	artifact_count = 0
	bonus_hp = 0
	bonus_dmg = 0


static func grant_artifact(source_name: String = "camp") -> void:
	artifact_count += 1
	hero_level = 1 + artifact_count
	bonus_hp += ARTIFACT_HP
	bonus_dmg += ARTIFACT_DMG
	print("[M31] ARTIFACT from ", source_name,
		" → level=", hero_level,
		" arts=", artifact_count,
		" +HP=", bonus_hp, " +DMG=", bonus_dmg)
	# Apply to living hero if any
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	for n in tree.get_nodes_in_group("Hero"):
		if n is Temirbat and is_instance_valid(n) and n.unit_state != BaseUnit.UnitState.DEAD:
			n.apply_progress_bonuses()
			break
