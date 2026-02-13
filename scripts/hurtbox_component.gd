extends Area2D

@export var healthComponent : HealthComponent

signal hit_by_projectile(projectile : Area2D)

func _ready() -> void:
	healthComponent.died.connect(_on_died)

func _on_area_entered(area: Area2D) -> void:
	healthComponent.damage(area.damage)
	hit_by_projectile.emit(area)

func _on_died() -> void:
	get_parent().queue_free()
