extends Node

var popup : ErrorPopupHandler

func _ready() -> void:
	await RoomManager.player_created
	var player = PlayerManager.player
	popup = player.ui.popup
