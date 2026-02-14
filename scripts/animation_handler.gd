extends Node

@export var player_input : PlayerInputHandler
@export var player : Player
@export var sprite : AnimatedSprite2D

func _process(delta: float) -> void:
	if player.velocity == Vector2.ZERO:
		sprite.play("idle") # we can nuke other sprites later
	else:
		sprite.play("moving") # and this lol
