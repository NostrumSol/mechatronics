extends Node2D
class_name ExitDoor

func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/loading_screen.tscn")
