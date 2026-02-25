extends Node
class_name OutlineComponent

@export var sprite : Sprite2D
@export var outline_color := Color.BLUE
@export var outline_size := Vector2(1.1, 1.1)
@export var outline_visible := false

var outline_sprite : Sprite2D

# TODO: add a fade in/out effect later
func _ready() -> void:
	outline_sprite = sprite.duplicate()
	sprite.add_child(outline_sprite)
	outline_sprite.z_index = sprite.z_index - 1
	outline_sprite.global_position = sprite.global_position
	outline_sprite.modulate = outline_color
	outline_sprite.scale = outline_size
	outline_sprite.visible = outline_visible

func set_visibility(state: bool) -> void:
	outline_sprite.visible = state
	outline_visible = state
