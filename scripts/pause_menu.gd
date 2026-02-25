extends Control
class_name PauseMenu

var isPaused = false

@export var continue_button : Button
@export var main_menu_button : Button
@export var quit_button : Button

func _ready() -> void:
	unpause()
	continue_button.pressed.connect(_on_continue_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if isPaused:
			unpause()
		else:
			pause()

func pause() -> void:
	show()
	isPaused = true
	get_tree().paused = true
	
	continue_button.grab_focus()

func unpause() -> void:
	hide()
	isPaused = false
	get_tree().paused = false

func _on_continue_pressed() -> void:
	unpause()

func _on_main_menu_pressed() -> void:
	unpause()
	RoomManager.end_game()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
