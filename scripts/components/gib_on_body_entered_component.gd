extends Area2D
class_name GibOnBodyEnteredComponent

func _on_body_entered(body: Node2D) -> void:
	get_parent().queue_free()
