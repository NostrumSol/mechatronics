extends ProgressBar

@export var energy_component : EnergyComponent

func _ready() -> void:
	energy_component.resource_changed.connect(_on_energy_changed)

func _on_energy_changed(update: ResourceUpdate) -> void:
	value = update.ResourcePercentage * 100
	
