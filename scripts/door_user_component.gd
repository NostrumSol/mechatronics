extends Node
#class_name DoorUserComponent
#
#@export var player_input: PlayerInputHandler
#
#signal door_entered(direction)
#
#func _on_door_area_entered(area: Area2D):
	#if player_input.current_state == PlayerInputHandler.PlayerState.TRAVERSING:
		#return
	#
	#var direction = Vector2i.ZERO
	#match area.name:
		#"Top_Border": direction = Vector2i.UP
		#"Bottom_Border": direction = Vector2i.DOWN
		#"Left_Border": direction = Vector2i.LEFT
		#"Right_Border": direction = Vector2i.RIGHT
	#
	#if direction != Vector2i.ZERO:
		#door_entered.emit(direction)
