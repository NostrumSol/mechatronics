extends Node

@export var body : CharacterBody2D
@export var sprite : AnimatedSprite2D

func _process(delta: float) -> void:
	if body.flashlight.enabled:
		if body.velocity == Vector2.ZERO:
			sprite.play("idle_on")
		else:
			sprite.play("moving_on")
	else:
		if body.velocity == Vector2.ZERO:
			sprite.play("idle_off")
		else:
			sprite.play("moving_off")
