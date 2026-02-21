extends Area2D
class_name PickUpRadius

@export var scrap : Scrap
	
func _on_body_entered(body: Node2D) -> void:
	PlayerManager.add_scrap(scrap.scrap_value)
	get_parent().queue_free()
