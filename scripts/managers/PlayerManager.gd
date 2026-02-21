extends Node

var player : Player

func get_player_state() -> PlayerInputHandler.PlayerState:
	return player.player_input.current_state

func add_scrap(amount: float) -> void:
	player.scrap.increase(amount)
