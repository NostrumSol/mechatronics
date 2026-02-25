extends Area2D
class_name GibOnBodyEnteredComponent

func _on_body_entered(body: Node2D) -> void:
	await get_tree().process_frame
	get_parent().queue_free()
