extends ResourceComponent
class_name HealthComponent

@export var resist : DamageResistanceComponent
signal died

var has_died := false

func damage(damage_instance : DamageInstance) -> void:
	if resist:
		var resistances := resist.resistances
		if resistances.is_empty():
			decrease(damage_instance.damage_value)
			return # No resistances; return early.
		
		for resistance in resistances:
			if resistance.damage_type == damage_instance.damage_type:
				damage_instance.damage_value -= resistance.resistance_value
				
	decrease(damage_instance.damage_value)

func heal(amount: float) -> void:
	increase(amount)

func _set_resource(value: float) -> void:
	super(value)

	if not has_health_remaining() and not has_died:
		has_died = true
		died.emit()

func has_health_remaining() -> bool:
	return has_resource_remaining()

func get_health_percentage() -> float:
	return get_resource_percentage()
