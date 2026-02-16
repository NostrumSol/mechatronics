extends Node2D
class_name MoveTowardsTargetComponent

@export var movement_speed := 50.0
@export var body : CharacterBody2D
@export var nav : NavigationAgent2D
@export var dash : DashComponent
@export var timer : Timer

@export var path_update_interval := 0.1

func _ready() -> void:
	nav.velocity_computed.connect(_on_velocity_computed)
	timer.timeout.connect(_on_path_update_timer_timeout)
	timer.wait_time = path_update_interval
	timer.autostart = true
	_on_path_update_timer_timeout()

func _on_path_update_timer_timeout() -> void:
	var player = PlayerManager.player
	if not player:
		return
		
	nav.target_position = player.global_position

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	var player = PlayerManager.player
	
	if not player:
		return
	
	if nav.is_navigation_finished():
		direction = Vector2.ZERO
	else:
		var next_path = nav.get_next_path_position()
		if next_path == global_position:
			direction = global_position.direction_to(player.global_position)
		else:
			direction = global_position.direction_to(next_path)
	
	var desired_velocity = direction * movement_speed
	if desired_velocity.length_squared() > 0:
		nav.velocity = desired_velocity
	
	body.move_and_slide()

func _on_velocity_computed(safe_velocity) -> void:
	if dash != null and dash.is_dashing:
		return
	
	if not is_instance_valid(body) or not body.is_inside_tree():
		return
	
	body.velocity = safe_velocity
	
	if safe_velocity.length_squared() > 0:
		body.rotation = safe_velocity.angle()

func _exit_tree():
	if nav and nav.velocity_computed.is_connected(_on_velocity_computed):
		nav.velocity_computed.disconnect(_on_velocity_computed)
