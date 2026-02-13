extends Control

func _ready() -> void:
	$CenterContainer/MainButtons/Start.grab_focus()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/blank_scene.tscn")
	RoomManager.generate_floor()

func _on_options_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/menus/settings_menu.tscn")
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
