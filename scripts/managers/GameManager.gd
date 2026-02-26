extends Node

func _get_generation_progress(state: RoomManager.GenerationState) -> float:
	match state:
		RoomManager.GenerationState.NOT_STARTED: return 0.0
		RoomManager.GenerationState.GENERATING_LAYOUT:   return 20.0
		RoomManager.GenerationState.MAPPING_DOORS:   return 40.0
		RoomManager.GenerationState.ASSIGNING_TYPES:   return 60.0
		RoomManager.GenerationState.INSTANTIATING_ROOMS:   return 80.0
		RoomManager.GenerationState.FINISHED:   return 100.0
		_: return 0.0
