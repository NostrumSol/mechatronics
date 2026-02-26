extends Node

var player: Player
var menus : PlayerMenus

func _ready() -> void:
	RoomManager.player_created.connect(_on_player_created)
	
func _on_player_created() -> void:
	player = PlayerManager.player
	menus = player.menus

func get_menus() -> PlayerMenus:
	return menus

func get_shop_menu() -> ShopMenu:
	return menus.shop_menu
