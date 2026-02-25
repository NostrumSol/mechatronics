extends Control
class_name ShopItem

@export var price_label : RichTextLabel
@export var item_texture_rect : TextureRect
@export var item_name_label : RichTextLabel
@export var item_description_label : RichTextLabel
@export var purchase_button : Button

var current_shop_data: ShopItemInstance
var current_item_data: ItemData

func set_shop_data(shop_data: ShopItemInstance) -> void:
	var price = shop_data.price
	price_label.text = "COST: %d SCRAP" % price
	set_item_data(shop_data.item)
	
	current_shop_data = shop_data

func set_item_data(item_data: ItemData) -> void:
	item_name_label.text = item_data.item_name
	item_description_label.text = item_data.item_description
	item_texture_rect.texture = item_data.texture
	
	var rarity_color = ItemData.rarity_to_color(item_data.rarity)
	item_name_label.push_color(rarity_color)
	
	current_item_data = item_data
