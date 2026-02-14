extends Node2D

@export var movement_speed := 50.0
@export var body : CharacterBody2D

@onready var nav: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	nav.velocity_computed.connect(_on_velocity_computed)

func _physics_process(delta: float) -> void:
	var target = PlayerManager.player
	var target_position = target.global_position
	
	nav.target_position = target_position
	if nav.is_navigation_finished():
		return
	
	var current_position = global_position
	var next_path_position = nav.get_next_path_position()
	var direction = current_position.direction_to(next_path_position)
	var velocity = direction * movement_speed
	
	nav.velocity = velocity
	body.move_and_slide()

func _on_velocity_computed(safe_velocity) -> void:
	body.velocity = safe_velocity
	
