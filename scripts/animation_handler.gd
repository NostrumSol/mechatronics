extends Node

@export var body : CharacterBody2D
@export var sprite : AnimatedSprite2D

func _update(delta: float) -> void:
	if body.velocity == Vector2.ZERO:
		sprite.play("idle") # we can nuke other sprites later
	else:
		sprite.play("moving") # and this lol
