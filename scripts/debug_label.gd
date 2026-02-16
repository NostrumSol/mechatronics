extends RichTextLabel

func _process(delta: float) -> void:
	var to_write = ""
	var fps = Engine.get_frames_per_second()
	var player_state = PlayerManager.get_player_state()
	
	to_write += "FPS" + ": " + str(fps) + "\n"
	text = to_write
