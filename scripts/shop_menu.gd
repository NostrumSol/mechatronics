extends Control
class_name ShopMenu

@export var container : HBoxContainer
const SHOP_ITEM_SCENE = preload("uid://c36pfdih1sxp0")

## Adds an item instance to the shop, then returns a reference to it.
func add_item(shop_data: ShopItemInstance) -> ShopItem:
	var new_item = SHOP_ITEM_SCENE.instantiate() as ShopItem
	container.add_child(new_item)
	
	new_item.set_shop_data(shop_data)
	return new_item

func remove_item(item: ShopItem) -> void:
	for existing_item: ShopItem in container.get_children():
		if existing_item == item:
			existing_item.queue_free()

## Removes all item instances in the shop
func clear_items() -> void:
	for child in container.get_children():
		child.queue_free()

func _on_button_pressed() -> void:
	hide()
