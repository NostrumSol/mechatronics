extends Control
class_name LoadingScreen

@export var progress_bar : ProgressBar

func _ready():
	RoomManager.generation_state_updated.connect(_on_generation_state_updated)
	RoomManager.generate_floor()

func _on_generation_state_updated(state: RoomManager.GenerationState) -> void:
	progress_bar.value = GameManager._get_generation_progress(state)
	if state == RoomManager.GenerationState.FINISHED:
		PlayerManager.player.camera.enabled = true
		queue_free()
	
