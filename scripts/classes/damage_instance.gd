extends Resource
class_name DamageInstance

enum DamageType{
	PHYSICAL,
	BURN,
	TRUE
}

@export var damage_type : DamageType = DamageType.PHYSICAL
@export var damage_value : float
