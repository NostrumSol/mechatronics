extends ResourceComponent
class_name EnergyComponent

@export var max_energy: float:
	get: return max_resource
	set(value): set_max_resource(value)

var energy: float:
	get: return resource
	set(value): resource = value

func has_energy_remaining() -> bool:
	return has_resource_remaining()

func get_energy_percentage() -> float:
	return get_resource_percentage()
