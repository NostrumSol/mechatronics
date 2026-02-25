extends Control

@export var start : Button

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/loading_screen.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
