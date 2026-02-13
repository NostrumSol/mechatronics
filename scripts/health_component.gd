extends Node2D
class_name HealthComponent

signal health_changed(HealthUpdate)
signal died
var has_died := false

@export var max_health := 100.0
var health := 100.0:  set = _set_health, get = _get_health

func _ready() -> void:
	initialize_health()

func initialize_health() -> void:
	health = max_health

func damage(amount: float) -> void:
	health -= amount

func heal(amount: float) -> void:
	damage(-amount)

func set_max_health(amount: float) -> void:
	max_health = amount
	if health > max_health:
		health = max_health

func _get_health() -> float:
	return health
	
func _set_health(value: float) -> void:
	var prev_health = health
	health = clampf(value, 0.0, max_health)
	
	var health_update = HealthUpdate.new()
	health_update.PreviousHealth = prev_health
	health_update.CurrentHealth = health
	health_update.MaxHealth = max_health
	
	health_changed.emit(health_update)
	
	if not has_health_remaining() and not has_died:
		has_died = true
		died.emit()
	
func has_health_remaining() -> bool:
	return health > 0

func get_health_percentage() -> float:
	if max_health <= 0:
		return 0.0
	return clampf(health / max_health, 0.0, 1.0)
