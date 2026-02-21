extends Area2D
class_name MoveToRadius

var tween : Tween
@export var tween_duration := 0.3

func _on_body_entered(body: Node2D) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	
	tween.tween_property(get_parent(), "global_position",\
	 body.global_position, tween_duration)
	
	
	
