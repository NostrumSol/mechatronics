extends Area2D

signal door_entered(direction)

@export var direction: Vector2i
@export var enabled := true

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(_body) -> void:
	if enabled:
		door_entered.emit(direction)
