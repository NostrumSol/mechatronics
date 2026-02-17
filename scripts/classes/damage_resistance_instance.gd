extends Resource
class_name DamageResistanceInstance

@export var damage_type : DamageInstance.DamageType
@export var resistance_value : float:
		set(value):
			resistance_value = mini(value, 100)
