extends ProgressBar

@export var health_component : HealthComponent

func _ready() -> void:
	health_component.resource_changed.connect(_on_health_changed)

func _on_health_changed(update: ResourceUpdate) -> void:
	value = update.ResourcePercentage * 100
	
