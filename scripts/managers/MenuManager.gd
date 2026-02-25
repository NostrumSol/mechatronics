extends Node

var player: Player
var menus : PlayerMenus

func _ready() -> void:
	await RoomManager.player_created
	player = PlayerManager.player
	menus = player.menus

func get_menus() -> PlayerMenus:
	return menus

func get_shop_menu() -> ShopMenu:
	return menus.shop_menu
