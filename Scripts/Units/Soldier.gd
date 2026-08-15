extends BaseUnit

class_name Soldier

func _ready() -> void:
	super()
	
	# Динамически создаем CombatComponent, если он отсутствует в сцене
	var combat = get_node_or_null("CombatComponent")
	if combat == null:
		combat = get_node_or_null("Components/CombatComponent")
	if combat == null:
		combat = CombatComponent.new()
		combat.name = "CombatComponent"
		combat.attack_damage = 15
		combat.attack_range = 2.0
		combat.attack_cooldown = 1.0
		add_child(combat)
		
	print("Soldier ready")
