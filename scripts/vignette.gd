extends ColorRect

var tween : Tween
var shader = material as ShaderMaterial

func _ready() -> void:
	RoomManager.started_traversing.connect(_on_start_traversing)
	RoomManager.finished_traversing.connect(_on_finished_traversing)

func _on_start_traversing() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_method(
		func(value):
			shader.set_shader_parameter("Vignette Intensity", value),
			1.0,
			15.0,
			0.5
	)
	

func _on_finished_traversing() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_method(
		func(value):
			shader.set_shader_parameter("Vignette Intensity", value),
			15.0,
			1.0,
			3
	)
