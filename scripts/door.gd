extends Area2D
class_name Door

@export var direction: Vector2i
@export var enabled := true

signal door_entered(direction: Vector2i) 

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("doors")

func _on_body_entered(body) -> void:
	if enabled and body is Player:
		door_entered.emit(direction)
