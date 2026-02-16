extends Node
class_name DashComponent

@export var body : CharacterBody2D
@export var player_input : PlayerInputHandler

@export var dash_cooldown_timer : Timer
@export var dash_cooldown := 3.0

@export var dash_duration_timer : Timer
@export var dash_duration := 1.0

@export var dash_velocity = 100.0
var is_dashing := false

func _ready() -> void:
	dash_duration_timer.timeout.connect(_on_dash_end)
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_end)

func start_dash(dir: Vector2) -> void:
	if player_input:
		player_input.current_state = player_input.PlayerState.DASHING
		
	dash_duration_timer.start()
	
	var dash_vector = dir * dash_velocity
	body.velocity += dash_vector
	dash_cooldown_timer.start(dash_cooldown)
	
	is_dashing = true

func can_dash() -> bool:
	return dash_cooldown_timer.time_left <= 0 and not is_dashing

func _on_dash_end() -> void:
	if player_input:
		player_input.current_state = player_input.PlayerState.IDLE
	is_dashing = false
	
func _on_dash_cooldown_end() -> void:
	pass # do vfx or something idk
