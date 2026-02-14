extends ProgressBar

@export var health_component : HealthComponent

func _ready() -> void:
	assert(health_component != null, "No health component connected to healthbar!")
	
	health_component.health_changed.connect(_on_health_changed)

func _on_health_changed(update: HealthUpdate) -> void:
	value = update.HealthPercentage * 100
	
