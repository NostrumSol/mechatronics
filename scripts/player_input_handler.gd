extends Node2D
class_name PlayerInputHandler

@export var player : Player
@export var dash : DashComponent
@export var pause : PauseMenu

var direction : Vector2

enum PlayerState
{
	IDLE,
	DASHING,
	TRAVERSING,
}

var current_state := PlayerState.IDLE

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") and dash.can_dash():
		dash.start_dash(direction)
	if event.is_action_pressed("flashlight"):
		player.flashlight.enabled = !player.flashlight.enabled
	if event.is_action_pressed("pause"):
		if pause.isPaused:
			pause.unpause()
		else:
			pause.pause()
	
func _process(_delta: float) -> void:
	if current_state == PlayerState.DASHING:
		player.move_and_slide()
		return
	elif current_state == PlayerState.TRAVERSING:
		return
	
	var focused_control = get_viewport().gui_get_focus_owner()
	if focused_control and (focused_control is LineEdit or focused_control is TextEdit):
		player.velocity = player.velocity.move_toward(Vector2.ZERO, player.movement_speed)
		player.move_and_slide()
		return
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		player.velocity = direction * player.movement_speed
	else:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, player.movement_speed)
		
	player.move_and_slide()
