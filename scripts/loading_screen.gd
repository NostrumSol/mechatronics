extends Control
class_name LoadingScreen

@export var progress_bar : ProgressBar
var next_scene = "uid://blfmthqw01wqh"

func _ready():
	RoomManager.generation_state_updated.connect(_on_generation_state_updated)
	RoomManager.generate_floor.call_deferred()

func _on_generation_state_updated(state: RoomManager.GenerationState) -> void:
	progress_bar.value = _get_progress(state)
	if state == RoomManager.GenerationState.FINISHED:
		PlayerManager.player.camera.enabled = true
		queue_free()
	
func _get_progress(state: RoomManager.GenerationState) -> float:
	match state:
		RoomManager.GenerationState.NOT_STARTED: return 0.0
		RoomManager.GenerationState.GENERATING_LAYOUT:   return 20.0
		RoomManager.GenerationState.MAPPING_DOORS:   return 40.0
		RoomManager.GenerationState.ASSIGNING_TYPES:   return 60.0
		RoomManager.GenerationState.INSTANTIATING_ROOMS:   return 80.0
		RoomManager.GenerationState.FINISHED:   return 100.0
		_: return 0.0
