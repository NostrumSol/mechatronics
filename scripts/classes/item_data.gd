extends Resource
class_name ItemData

enum Rarity {
	SUB_OPTIMAL,
	WILL_DO,
	SATISFACTORY,
	OPTIMAL,
}

@export var item_name : String
@export var item_id : String = ""
@export var item_description : String
@export var texture: Texture2D
@export var rarity : Rarity
@export var grid_cells : Array[Vector2i]
@export var weapon_stat_modifiers : Dictionary = {}
@export var player_stat_modifiers : Dictionary = {}
@export var components: Array[ItemComponent] = []

func get_occupied_cells(anchor_cell: Vector2i, rotation: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for offset in grid_cells:
		var rotated_offset = offset
		match rotation:
			1: # 90° clockwise
				rotated_offset = Vector2i(-offset.y, offset.x)
			2: # 180°
				rotated_offset = Vector2i(-offset.x, -offset.y)
			3: # 270° clockwise
				rotated_offset = Vector2i(offset.y, -offset.x)
		result.append(anchor_cell + rotated_offset)
	
	return result
	
func _init():
	if item_id.is_empty() and not item_name.is_empty():
		item_id = item_name.to_lower().replace(" ", "_")
