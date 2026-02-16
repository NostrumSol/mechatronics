extends Node

@export var health_component: HealthComponent

func _ready() -> void:
	health_component.died.connect(_on_died)

func _on_died() -> void:
	get_parent().queue_free()
