extends AnimatedSprite2D

@export var bob_amplitude: float = 0.01
@export var bob_speed: float = 0.8
var start_y: float

func _ready() -> void:
	start_y = position.y

func _process(delta: float) -> void:
	_face_towards_mouse()
	_bob_up_and_down()

func _bob_up_and_down() -> void:
	var new_y = start_y + sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_amplitude
	position.y += new_y
	
func _face_towards_mouse() -> void:
	var mouse_delta = global_position.direction_to(get_global_mouse_position())
	if abs(mouse_delta.y) > abs(mouse_delta.x):
		if mouse_delta.y > 0:
			play("south")
		else:
			play("north")
	else:
		if mouse_delta.x > 0:
			play("east")
		else:
			play("west")
