extends BaseUnit

class_name Temirbat

## M27 — Semi-Hero. Melee, stronger Soldier. One per match from Orunqar.
## Permanent camp buff: +30 max_health (flag, no inventory).

var has_camp_buff: bool = false
const CAMP_BUFF_HP := 30


func _ready() -> void:
	max_health = 180
	attack_damage = 25
	attack_range = 2.4
	attack_cooldown = 0.85
	move_speed = 2.9
	health_bar_height = 2.0
	can_gather = false
	damage_type = DamageType.Type.MELEE
	can_shoot_while_moving = false

	super()
	add_to_group("Hero")
	print("Temirbat spawned at ", global_position)


func apply_camp_buff() -> void:
	if has_camp_buff:
		return
	has_camp_buff = true
	max_health += CAMP_BUFF_HP
	health = mini(health + CAMP_BUFF_HP, max_health)
	if health_bar:
		health_bar.setup(max_health)
		health_bar.set_health(health)
	print(name, " CAMP BUFF +", CAMP_BUFF_HP, " HP → max=", max_health)
