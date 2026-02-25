extends Resource
class_name DamageInstance

enum DamageType{
	PHYSICAL,
	BURN,
	TRUE
}

@export var damage_type : DamageType = DamageType.PHYSICAL
@export var damage_value : float

func _init(value: float = damage_value, type: DamageType = damage_type) -> void:
	damage_type = type
	damage_value = value
