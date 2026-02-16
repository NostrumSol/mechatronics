extends ResourceComponent
class_name HealthComponent

signal died

var has_died := false

@export var max_health: float:
	get: return max_resource
	set(value): set_max_resource(value)

var health: float:
	get: return resource
	set(value): resource = value

func damage(amount: float) -> void:
	decrease(amount)

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
