extends Node

var popup : ErrorPopupHandler

func _ready() -> void:
	RoomManager.player_created.connect(_on_player_created)

func _on_player_created() -> void:
	var player = PlayerManager.player
	popup = player.ui.popup
