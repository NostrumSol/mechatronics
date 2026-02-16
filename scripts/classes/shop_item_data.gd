extends Node
class_name ShopItemData

@export var item : ItemData
@export var price : int

var rarity : ItemData.Rarity = item.rarity
var description : String = item.item_description
