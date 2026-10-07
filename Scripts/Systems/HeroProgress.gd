extends RefCounted

class_name HeroProgress

## M31/M32 — match-persistent hero level + 6 artifact slots.

const SLOT_COUNT := 6
const ARTIFACT_HP := 25
const ARTIFACT_DMG := 5

static var hero_level: int = 1
static var artifact_count: int = 0
static var bonus_hp: int = 0
static var bonus_dmg: int = 0
## Each entry: "" empty, or id e.g. "MELEE", "ARCHER", "DEBUG"
static var slots: Array = ["", "", "", "", "", ""]


static func reset_match() -> void:
	hero_level = 1
	artifact_count = 0
	bonus_hp = 0
	bonus_dmg = 0
	slots = ["", "", "", "", "", ""]


static func first_free_slot() -> int:
	for i in SLOT_COUNT:
		if str(slots[i]) == "":
			return i
	return -1


static func is_inventory_full() -> bool:
	return first_free_slot() < 0


## Returns true if artifact was stored in a slot.
static func grant_artifact(source_name: String = "camp") -> bool:
	var idx: int = first_free_slot()
	if idx < 0:
		print("[M32] inventory FULL (6/6) — cannot loot ", source_name)
		return false

	var id: String = source_name.strip_edges()
	if id.is_empty():
		id = "ART"
	# Keep label short for UI
	if id.length() > 8:
		id = id.substr(0, 8)
	slots[idx] = id

	artifact_count += 1
	hero_level = 1 + artifact_count
	bonus_hp += ARTIFACT_HP
	bonus_dmg += ARTIFACT_DMG
	print("[M32] ARTIFACT ", id, " → slot ", idx,
		" level=", hero_level,
		" arts=", artifact_count,
		" +HP=", bonus_hp, " +DMG=", bonus_dmg)

	var tree := Engine.get_main_loop()
	if tree != null and tree is SceneTree:
		for n in (tree as SceneTree).get_nodes_in_group("Hero"):
			if n == null or not is_instance_valid(n):
				continue
			if n.has_method("apply_progress_bonuses"):
				n.call("apply_progress_bonuses")
				break
	return true


static func slot_label(i: int) -> String:
	if i < 0 or i >= SLOT_COUNT:
		return ""
	return str(slots[i])
