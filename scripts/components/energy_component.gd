extends ResourceComponent
class_name EnergyComponent

var energy: float:
	get: return resource
	set(value): resource = value

func has_energy_remaining() -> bool:
	return has_resource_remaining()

func get_energy_percentage() -> float:
	return get_resource_percentage()
