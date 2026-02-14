extends Resource
class_name ItemData

enum Rarity {
	SUB_OPTIMAL,
	WILL_DO,
	SATISFACTORY,
	OPTIMAL,
}

@export var item_name : String
var item_id = item_name.to_lower().replace(" ", "_")

@export var texture: Texture2D
@export var rarity : Rarity
@export var grid_cells : Array[Vector2i]
@export var weapon_stat_modifiers : Dictionary = {}
@export var player_stat_modifiers : Dictionary = {}

@export var components: Array[ItemComponent] = []
	
