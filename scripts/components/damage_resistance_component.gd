extends Node
class_name DamageResistanceComponent

@export var resistances : Array[DamageResistanceInstance] = []

func set_damage_resistance_value(resistance: DamageResistanceInstance, new_value: float) -> void:
	if not has_damage_resistance(resistance):
		add_damage_resistance(resistance)
	
	resistances[resistance].resistance_value = new_value

func set_damage_resistance_type(resistance: DamageResistanceInstance, new_type: DamageInstance.DamageType) -> void:
	if not has_damage_resistance(resistance):
		add_damage_resistance(resistance)
	
	resistances[resistance].damage_type = new_type

func ensure_damage_resistance(resistance: DamageResistanceInstance) -> DamageResistanceInstance:
	if not resistances.has(resistance):
		add_damage_resistance(resistance)
	
	return resistances[resistance]
	
func add_damage_resistance(resistance: DamageResistanceInstance) -> void:
	resistances.append(resistance)

func remove_damage_resistance(resistance: DamageResistanceInstance) -> void:
	resistances.erase(resistance)

func remove_all_damage_resistances() -> void:
	resistances.clear()

func has_damage_resistance(resistance: DamageResistanceInstance) -> bool:
	return resistances.has(resistance)
