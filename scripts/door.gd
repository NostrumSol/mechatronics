extends Area2D
class_name Door

enum door_state {
	OPENING,
	CLOSING,
	IDLE,
}

@export var sprite: AnimatedSprite2D
@export var hiss: AudioStreamPlayer2D
@export var direction: Vector2i

@export var enabled := true
var state := door_state.IDLE

signal door_entered(direction: Vector2i, door: Door) 

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body) -> void:
	if can_traverse_door() and body is Player:
		door_entered.emit(direction, self)
		play_open_animation()

func _on_animation_finished() -> void:
	if state == door_state.OPENING:
		play_close_animation()
	else:
		state = door_state.IDLE

func play_open_animation() -> void:
	sprite.play("opening")
	state = door_state.OPENING
	hiss.play()

func play_close_animation() -> void:
	sprite.play_backwards("opening")
	state = door_state.CLOSING

func can_traverse_door() -> bool:
	return enabled and state != door_state.OPENING
